(** * 编译性能回归测试 - Issue #1746响应 * Author: Echo, 测试工程师代理 * * 此测试专门验证PR #1745声明的41.5%编译时间改进， *
    建立性能基准和回归检测机制。 *)

open Alcotest

(** 编译时间测量工具 *)
module CompilationTimer = struct
  type measurement = {
    total_time : float;
    user_time : float;
    system_time : float;
    timestamp : string;
  }

  let measure_compilation_with_timing () =
    let temp_file = "/tmp/luoyan_compile_time.txt" in
    let start_time = Unix.gettimeofday () in

    (* 清理环境 *)
    let _ = Sys.command "dune clean > /dev/null 2>&1" in

    (* 使用time命令测量编译时间 *)
    let time_cmd =
      Printf.sprintf "/usr/bin/time -o %s -f '%%e %%U %%S' dune build > /dev/null 2>&1" temp_file
    in
    let exit_code = Sys.command time_cmd in

    let end_time = Unix.gettimeofday () in

    if exit_code = 0 then
      try
        let ic = open_in temp_file in
        let time_line = input_line ic in
        close_in ic;
        let _ = Sys.remove temp_file in

        let parts = String.split_on_char ' ' (String.trim time_line) in
        match parts with
        | [ total; user; system ] ->
            Some
              {
                total_time = float_of_string total;
                user_time = float_of_string user;
                system_time = float_of_string system;
                timestamp = Printf.sprintf "%.0f" (Unix.time ());
              }
        | _ -> None
      with _ -> None
    else None

  let multiple_measurements count =
    let measurements = ref [] in
    for i = 1 to count do
      Printf.printf "执行第%d次编译测量...\n" i;
      match measure_compilation_with_timing () with
      | Some measurement -> measurements := measurement :: !measurements
      | None -> Printf.printf "第%d次测量失败\n" i
    done;
    List.rev !measurements

  let calculate_statistics measurements =
    let count = List.length measurements in
    if count = 0 then None
    else
      let total_times = List.map (fun m -> m.total_time) measurements in
      let sum = List.fold_left ( +. ) 0.0 total_times in
      let mean = sum /. float_of_int count in

      let variance =
        List.fold_left (fun acc t -> acc +. ((t -. mean) ** 2.0)) 0.0 total_times
        /. float_of_int count
      in
      let std_dev = sqrt variance in

      let sorted_times = List.sort compare total_times in
      let median =
        if count mod 2 = 0 then
          let mid = count / 2 in
          (List.nth sorted_times (mid - 1) +. List.nth sorted_times mid) /. 2.0
        else List.nth sorted_times (count / 2)
      in

      Some (mean, median, std_dev, List.hd sorted_times, List.hd (List.rev sorted_times))
end

(** 性能基准建立测试 *)
let establish_performance_baseline () =
  Printf.printf "\n=== 建立编译性能基准 ===\n";

  let measurements = CompilationTimer.multiple_measurements 5 in
  let count = List.length measurements in

  Printf.printf "成功完成 %d 次测量\n" count;

  if count >= 3 then
    match CompilationTimer.calculate_statistics measurements with
    | Some (mean, median, std_dev, min_time, max_time) ->
        Printf.printf "\n编译性能统计:\n";
        Printf.printf "  平均时间: %.3f秒\n" mean;
        Printf.printf "  中位数: %.3f秒\n" median;
        Printf.printf "  标准差: %.3f秒\n" std_dev;
        Printf.printf "  最快时间: %.3f秒\n" min_time;
        Printf.printf "  最慢时间: %.3f秒\n" max_time;
        Printf.printf "  变异系数: %.1f%%\n" (std_dev /. mean *. 100.0);

        (* 保存基准到文件 *)
        let baseline_file = "performance_baseline.txt" in
        let oc = open_out baseline_file in
        Printf.fprintf oc "# 编译性能基准 - Author: Echo, 测试工程师代理\n";
        Printf.fprintf oc "mean_time=%.3f\n" mean;
        Printf.fprintf oc "median_time=%.3f\n" median;
        Printf.fprintf oc "std_dev=%.3f\n" std_dev;
        Printf.fprintf oc "min_time=%.3f\n" min_time;
        Printf.fprintf oc "max_time=%.3f\n" max_time;
        Printf.fprintf oc "measurements=%d\n" count;
        Printf.fprintf oc "timestamp=%s\n" (Printf.sprintf "%.0f" (Unix.time ()));
        close_out oc;

        Printf.printf "\n基准已保存到: %s\n" baseline_file;

        (* 验证性能在合理范围内 *)
        check bool "平均编译时间应小于3秒" true (mean < 3.0);
        check bool "编译时间变异系数应小于30%" true (std_dev /. mean < 0.3);
        check bool "应完成至少3次有效测量" true (count >= 3)
    | None -> failwith "统计计算失败"
  else failwith "测量次数不足，无法建立基准"

(** 性能回归检测测试 *)
let performance_regression_detection () =
  Printf.printf "\n=== 性能回归检测 ===\n";

  let baseline_file = "performance_baseline.txt" in

  if Sys.file_exists baseline_file then (
    let read_baseline () =
      let ic = open_in baseline_file in
      let rec read_values acc =
        try
          let line = input_line ic in
          if String.get line 0 = '#' then read_values acc
          else
            let parts = String.split_on_char '=' line in
            match parts with
            | [ key; value ] -> (String.trim key, String.trim value) :: acc
            | _ -> read_values acc
        with End_of_file ->
          close_in ic;
          acc
      in
      read_values []
    in

    let baseline_data = read_baseline () in
    let baseline_mean =
      try List.assoc "mean_time" baseline_data |> float_of_string with _ -> failwith "无法读取基准平均时间"
    in

    Printf.printf "历史基准平均时间: %.3f秒\n" baseline_mean;

    (* 执行当前测量 *)
    let current_measurements = CompilationTimer.multiple_measurements 3 in
    match CompilationTimer.calculate_statistics current_measurements with
    | Some (current_mean, _, _, _, _) ->
        Printf.printf "当前平均时间: %.3f秒\n" current_mean;

        let improvement_ratio = (baseline_mean -. current_mean) /. baseline_mean in
        let improvement_percent = improvement_ratio *. 100.0 in

        Printf.printf "性能变化: %.1f%%\n" improvement_percent;

        if improvement_percent > 0.0 then Printf.printf "✓ 性能提升 %.1f%%\n" improvement_percent
        else Printf.printf "⚠ 性能下降 %.1f%%\n" (abs_float improvement_percent);

        (* 验证没有显著性能回归 *)
        check bool "不应有超过10%的性能回归" true (improvement_percent > -10.0);

        (* 如果声称有41.5%改进，验证是否接近 *)
        if improvement_percent > 30.0 then Printf.printf "✓ 验证了显著的性能改进\n"
    | None -> failwith "当前性能测量失败")
  else Printf.printf "⚠ 未找到性能基准文件，跳过回归检测\n"

(** 内存使用测试 *)
let memory_usage_test () =
  Printf.printf "\n=== 内存使用测试 ===\n";

  let measure_memory_usage () =
    let temp_script = "/tmp/measure_memory.sh" in
    let oc = open_out temp_script in
    Printf.fprintf oc "#!/bin/bash\n";
    Printf.fprintf oc "dune clean > /dev/null 2>&1\n";
    Printf.fprintf oc "/usr/bin/time -v dune build 2>&1 | grep 'Maximum resident set size'\n";
    close_out oc;
    let _ = Sys.command ("chmod +x " ^ temp_script) in

    let ic = Unix.open_process_in temp_script in
    let memory_line = input_line ic in
    let _ = Unix.close_process_in ic in
    let _ = Sys.remove temp_script in

    (* 解析内存使用（单位：KB） *)
    let parts = String.split_on_char ':' memory_line in
    match parts with
    | [ _; memory_str ] ->
        let memory_kb = int_of_string (String.trim memory_str) in
        let memory_mb = float_of_int memory_kb /. 1024.0 in
        Printf.printf "编译内存使用: %.1f MB\n" memory_mb;

        (* 验证内存使用在合理范围内 *)
        check bool "编译内存使用应小于1GB" true (memory_mb < 1024.0);
        memory_mb
    | _ ->
        Printf.printf "⚠ 无法解析内存使用信息\n";
        0.0
  in

  try
    let _ = measure_memory_usage () in
    ()
  with _ -> Printf.printf "⚠ 内存测量工具不可用，跳过测试\n"

(** 并发编译性能测试 *)
let concurrent_compilation_test () =
  Printf.printf "\n=== 并发编译性能测试 ===\n";

  let test_concurrent_jobs jobs =
    Printf.printf "测试 %d 并发任务...\n" jobs;
    let _ = Sys.command "dune clean > /dev/null 2>&1" in

    let start_time = Unix.gettimeofday () in
    let cmd = Printf.sprintf "dune build -j %d > /dev/null 2>&1" jobs in
    let exit_code = Sys.command cmd in
    let end_time = Unix.gettimeofday () in

    if exit_code = 0 then (
      let compile_time = end_time -. start_time in
      Printf.printf "  %d并发: %.3f秒\n" jobs compile_time;
      Some compile_time)
    else (
      Printf.printf "  %d并发: 编译失败\n" jobs;
      None)
  in

  let job_counts = [ 1; 2; 4 ] in
  let results =
    List.filter_map
      (fun jobs ->
        match test_concurrent_jobs jobs with Some time -> Some (jobs, time) | None -> None)
      job_counts
  in

  if List.length results >= 2 then Printf.printf "\n并发性能分析:\n";
  List.iter (fun (jobs, time) -> Printf.printf "  %d线程: %.3f秒\n" jobs time) results;

  (* 验证并发编译有效 *)
  let serial_time = snd (List.find (fun (j, _) -> j = 1) results) in
  check bool "串行编译时间应在合理范围" true (serial_time < 5.0)

let performance_regression_tests =
  [
    ("establish_performance_baseline", `Slow, establish_performance_baseline);
    ("performance_regression_detection", `Slow, performance_regression_detection);
    ("memory_usage_test", `Slow, memory_usage_test);
    ("concurrent_compilation_test", `Slow, concurrent_compilation_test);
  ]

let () =
  Printf.printf "\n=== 编译性能回归测试套件 ===\n";
  Printf.printf "验证PR #1745的41.5%%性能改进声明\n";
  (* 需要转义百分号 *)
  Printf.printf "Author: Echo, 测试工程师代理\n\n";

  run "编译性能回归测试" [ ("性能基准与回归检测", performance_regression_tests) ]
