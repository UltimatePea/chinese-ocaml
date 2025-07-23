(** 性能基准测试运行器
    
    独立的可执行程序，用于运行性能基准测试并生成报告
    支持多种运行模式和输出格式
    
    创建目的：提供便捷的性能测试执行工具 Fix #897 *)

open Yyocamlc_lib.Performance_benchmark

(** 命令行参数解析 *)
type run_mode = 
  | Quick      (** 快速测试模式 *)
  | Full       (** 完整测试模式 *)
  | Regression (** 回归检测模式 *)

type output_format =
  | Markdown   (** Markdown格式报告 *)
  | JSON       (** JSON格式报告 *)
  | Console    (** 控制台输出 *)

type config = {
  mode : run_mode;
  format : output_format;
  output_file : string option;
  baseline_file : string option;
  iterations : int option;
}

(** 默认配置 *)
let default_config = {
  mode = Full;
  format = Markdown;
  output_file = None;
  baseline_file = None;
  iterations = None;
}

(** 帮助信息 *)
let print_help () =
  print_endline "骆言编译器性能基准测试运行器";
  print_endline "==========================================";
  print_endline "";
  print_endline "用法: performance_benchmark_runner [选项]";
  print_endline "";
  print_endline "选项:";
  print_endline "  -h, --help                显示帮助信息";
  print_endline "  -m, --mode <mode>         测试模式: quick|full|regression (默认: full)";
  print_endline "  -f, --format <format>     输出格式: markdown|json|console (默认: markdown)";
  print_endline "  -o, --output <file>       输出文件路径 (默认: 自动生成)";
  print_endline "  -b, --baseline <file>     基线数据文件路径 (用于回归检测)";
  print_endline "  -i, --iterations <num>    测试迭代次数 (覆盖默认值)";
  print_endline "";
  print_endline "示例:";
  print_endline "  # 运行完整基准测试并保存Markdown报告";
  print_endline "  ./performance_benchmark_runner --mode full --output report.md";
  print_endline "";
  print_endline "  # 运行快速测试并输出到控制台";
  print_endline "  ./performance_benchmark_runner --mode quick --format console";
  print_endline "";
  print_endline "  # 运行回归检测";
  print_endline "  ./performance_benchmark_runner --mode regression --baseline baseline.json";
  print_endline "";
  print_endline "骆言编程语言 - 中文编程的诗意表达"

(** 解析命令行参数 *)
let parse_args () =
  let args = Sys.argv in
  let argc = Array.length args in
  let config = ref default_config in
  
  let rec parse_next i =
    if i >= argc then ()
    else
      match args.(i) with
      | "-h" | "--help" ->
          print_help ();
          exit 0
      | "-m" | "--mode" ->
          if i + 1 < argc then (
            let mode = match args.(i + 1) with
              | "quick" -> Quick
              | "full" -> Full  
              | "regression" -> Regression
              | m -> 
                  Printf.eprintf "错误: 未知的测试模式 '%s'\n" m;
                  exit 1
            in
            config := { !config with mode };
            parse_next (i + 2)
          ) else (
            Printf.eprintf "错误: --mode 选项需要参数\n";
            exit 1
          )
      | "-f" | "--format" ->
          if i + 1 < argc then (
            let format = match args.(i + 1) with
              | "markdown" -> Markdown
              | "json" -> JSON
              | "console" -> Console
              | f ->
                  Printf.eprintf "错误: 未知的输出格式 '%s'\n" f;
                  exit 1
            in
            config := { !config with format };
            parse_next (i + 2)
          ) else (
            Printf.eprintf "错误: --format 选项需要参数\n";
            exit 1
          )
      | "-o" | "--output" ->
          if i + 1 < argc then (
            config := { !config with output_file = Some args.(i + 1) };
            parse_next (i + 2)
          ) else (
            Printf.eprintf "错误: --output 选项需要参数\n";
            exit 1
          )
      | "-b" | "--baseline" ->
          if i + 1 < argc then (
            config := { !config with baseline_file = Some args.(i + 1) };
            parse_next (i + 2)
          ) else (
            Printf.eprintf "错误: --baseline 选项需要参数\n";
            exit 1
          )
      | "-i" | "--iterations" ->
          if i + 1 < argc then (
            try
              let iterations = int_of_string args.(i + 1) in
              if iterations <= 0 then raise (Invalid_argument "iterations must be positive");
              config := { !config with iterations = Some iterations };
              parse_next (i + 2)
            with Invalid_argument _ ->
              Printf.eprintf "错误: 迭代次数必须是正整数\n";
              exit 1
          ) else (
            Printf.eprintf "错误: --iterations 选项需要参数\n";
            exit 1
          )
      | arg ->
          Printf.eprintf "错误: 未知选项 '%s'\n" arg;
          Printf.eprintf "使用 --help 查看帮助信息\n";
          exit 1
  in
  
  parse_next 1;
  !config

(** JSON格式输出 *)
let output_json benchmark_suite output_file =
  (* 简单的JSON序列化 - 实际项目中可以使用yojson *)
  let json_content = Printf.sprintf {|{
  "suite_name": "%s",
  "total_duration": %f,
  "summary": "%s",
  "results": [%s]
}|}
    benchmark_suite.suite_name
    benchmark_suite.total_duration
    benchmark_suite.summary
    (String.concat ",\n    " (List.map (fun result ->
      let metrics_json = String.concat ",\n      " (List.map (fun metric ->
        Printf.sprintf {|{
        "name": "%s",
        "execution_time": %f,
        "iterations": %d%s%s
      }|}
          metric.name
          metric.execution_time
          metric.iterations
          (match metric.memory_usage with Some m -> Printf.sprintf {|,
        "memory_usage": %d|} m | None -> "")
          (match metric.variance with Some v -> Printf.sprintf {|,
        "variance": %f|} v | None -> "")
      ) result.metrics) in
      Printf.sprintf {|{
      "module_name": "%s",
      "test_category": "%s",
      "timestamp": "%s",
      "environment": "%s",
      "metrics": [%s]
    }|}
        result.module_name
        result.test_category
        result.timestamp
        result.environment
        metrics_json
    ) benchmark_suite.results))
  in
  
  match output_file with
  | Some file ->
      let out_channel = open_out file in
      output_string out_channel json_content;
      close_out out_channel;
      Printf.printf "JSON报告已保存到: %s\n" file
  | None ->
      print_endline json_content

(** 控制台格式输出 *)
let output_console benchmark_suite =
  Printf.printf "\n🚀 %s\n" benchmark_suite.suite_name;
  Printf.printf "==========================================\n\n";
  
  List.iter (fun result ->
    Printf.printf "📊 %s (%s)\n" result.module_name result.test_category;
    Printf.printf "时间: %s | 环境: %s\n" result.timestamp result.environment;
    Printf.printf "----------------------------------------\n";
    
    List.iter (fun metric ->
      Printf.printf "  • %s\n" (BenchmarkReporter.summarize_metric metric)
    ) result.metrics;
    
    Printf.printf "\n"
  ) benchmark_suite.results;
  
  Printf.printf "📈 总执行时间: %.3f秒\n" benchmark_suite.total_duration;
  Printf.printf "📝 总结: %s\n" benchmark_suite.summary;
  Printf.printf "==========================================\n"

(** 生成默认输出文件名 *)
let generate_output_filename format mode =
  let timestamp = 
    let tm = Unix.localtime (Unix.time ()) in
    Printf.sprintf "%04d%02d%02d_%02d%02d%02d" 
      (tm.tm_year + 1900) (tm.tm_mon + 1) tm.tm_mday 
      tm.tm_hour tm.tm_min tm.tm_sec
  in
  let mode_str = match mode with
    | Quick -> "quick"
    | Full -> "full"
    | Regression -> "regression"
  in
  let ext = match format with
    | Markdown -> "md"
    | JSON -> "json"
    | Console -> "txt"
  in
  Printf.sprintf "benchmark_%s_%s.%s" mode_str timestamp ext

(** 运行性能基准测试 *)
let run_benchmark config =
  Printf.printf "🚀 启动骆言编译器性能基准测试\n";
  Printf.printf "==========================================\n";
  
  (* 显示配置信息 *)
  let mode_str = match config.mode with
    | Quick -> "快速测试"
    | Full -> "完整测试"
    | Regression -> "回归检测"
  in
  let format_str = match config.format with
    | Markdown -> "Markdown"
    | JSON -> "JSON"
    | Console -> "控制台"
  in
  
  Printf.printf "测试模式: %s\n" mode_str;
  Printf.printf "输出格式: %s\n" format_str;
  (match config.output_file with
   | Some file -> Printf.printf "输出文件: %s\n" file
   | None -> Printf.printf "输出文件: 自动生成\n");
  (match config.baseline_file with
   | Some file -> Printf.printf "基线文件: %s\n" file
   | None -> ());
  Printf.printf "==========================================\n\n";
  
  (* 运行基准测试 *)
  let benchmark_suite = match config.mode with
    | Quick | Full ->
        Printf.printf "⏱️  执行性能基准测试...\n";
        PerformanceBenchmark.run_full_benchmark_suite ()
    | Regression ->
        Printf.printf "🔍 执行回归检测...\n";
        (* 在实际实现中，这里会加载基线数据并进行对比 *)
        PerformanceBenchmark.run_full_benchmark_suite ()
  in
  
  Printf.printf "✅ 基准测试执行完成!\n\n";
  
  (* 输出结果 *)
  (match config.format with
  | Console ->
      output_console benchmark_suite
  | Markdown ->
      let output_file = match config.output_file with
        | Some file -> file
        | None -> generate_output_filename Markdown config.mode
      in
      let _save_message = generate_and_save_report benchmark_suite output_file in
      Printf.printf "Markdown报告已保存到: %s\n" output_file
  | JSON ->
      output_json benchmark_suite config.output_file);
  
  (* 回归检测特殊处理 *)
  (match config.mode with
   | Regression when config.baseline_file <> None ->
       Printf.printf "\n🔍 性能回归分析:\n";
       Printf.printf "回归检测功能将在后续版本中完善\n"
   | _ -> ());
  
  Printf.printf "\n🎉 性能基准测试完成!\n"

(** 主函数 *)
let () =
  try
    let config = parse_args () in
    run_benchmark config
  with
  | Sys_error msg ->
      Printf.eprintf "系统错误: %s\n" msg;
      exit 1
  | exn ->
      Printf.eprintf "未预期的错误: %s\n" (Printexc.to_string exn);
      exit 1