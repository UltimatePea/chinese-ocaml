(** 韵律数据工具性能基准测试

    修复Issue #1463要求的性能基准测试 提供实际性能对比数据，验证重构效果

    @author Alpha, 主工作代理
    @since 2025-07-27 - Fix #1463 *)

open Printf

(** 简单的性能计时器 *)
let time_function name f =
  let start_time = Sys.time () in
  let result = f () in
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  printf "%s: %.6f秒\n" name duration;
  result

(** 基准测试数据 *)
let test_categories =
  [
    Rhyme_data_utils.PingSheng;
    Rhyme_data_utils.ZeSheng;
    Rhyme_data_utils.ShangSheng;
    Rhyme_data_utils.QuSheng;
  ]

let test_groups =
  [
    Rhyme_data_utils.AnRhyme;
    Rhyme_data_utils.TianRhyme;
    Rhyme_data_utils.WangRhyme;
    Rhyme_data_utils.FengRhyme;
  ]

let benchmark_string_conversion () =
  printf "\n=== 字符串转换性能测试 ===\n";

  (* 测试分类转换 *)
  time_function "韵律分类转换 (1000次)" (fun () ->
      for _i = 1 to 1000 do
        List.iter
          (fun cat -> ignore (Rhyme_data_utils.string_of_rhyme_category cat))
          test_categories
      done);

  (* 测试组转换 *)
  time_function "韵律组转换 (1000次)" (fun () ->
      for _i = 1 to 1000 do
        List.iter (fun group -> ignore (Rhyme_data_utils.string_of_rhyme_group group)) test_groups
      done)

let benchmark_file_operations () =
  printf "\n=== 文件操作性能测试 ===\n";

  let config = Rhyme_data_utils.default_rhyme_config in

  time_function "文件路径构建 (1000次)" (fun () ->
      for _i = 1 to 1000 do
        List.iter
          (fun cat ->
            List.iter
              (fun group -> ignore (Rhyme_data_utils.build_rhyme_file_path config cat group))
              test_groups)
          test_categories
      done)

let benchmark_data_creation () =
  printf "\n=== 数据创建性能测试 ===\n";

  let test_chars = [ "诗"; "韵"; "律"; "歌" ] in

  time_function "韵律条目创建 (1000次)" (fun () ->
      for _i = 1 to 1000 do
        List.iter
          (fun cat ->
            List.iter
              (fun group -> ignore (Rhyme_data_utils.create_rhyme_entries test_chars cat group))
              test_groups)
          test_categories
      done)

let run_all_benchmarks () =
  printf "韵律数据工具性能基准测试\n";
  printf "================================\n";
  printf "测试时间: %s\n" (string_of_float (Sys.time ()));

  benchmark_string_conversion ();
  benchmark_file_operations ();
  benchmark_data_creation ();

  printf "\n=== 性能基准测试完成 ===\n";
  printf "注：这些数据提供了重构后的性能基线\n";
  printf "可用于对比未来的优化效果\n"

(* 运行基准测试 *)
let () = run_all_benchmarks ()
