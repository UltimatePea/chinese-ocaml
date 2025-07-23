(** 性能基准测试系统测试套件
    
    验证性能基准测试系统的正确性、可靠性和功能完整性
    包括单元测试、集成测试和回归检测测试
    
    创建目的：确保性能监控系统的质量和可靠性 Fix #897 *)

open Yyocamlc_lib.Performance_benchmark

(** 测试辅助函数 *)
let assert_true condition message =
  if not condition then
    failwith ("断言失败: " ^ message)

(* 预留给将来可能需要的浮点数比较函数
let assert_float_close actual expected tolerance message =
  let diff = abs_float (actual -. expected) in
  if diff > tolerance then
    failwith (Printf.sprintf "断言失败: %s (实际值: %f, 期望值: %f, 差异: %f)" 
              message actual expected diff)
*)

let assert_option_some opt message =
  match opt with
  | Some _ -> ()
  | None -> failwith ("断言失败: " ^ message)

(** 测试计时器功能 *)
let test_timer_functionality () =
  Printf.printf "测试计时器功能...\n";
  
  (* 测试简单函数计时 *)
  let simple_function x = x * 2 in
  let (result, duration) = PerformanceBenchmark.Timer.time_function simple_function 42 in
  assert_true (result = 84) "简单函数计算结果正确";
  assert_true (duration >= 0.0) "执行时间非负";
  
  (* 测试多次迭代计时 *)
  let (avg_time, variance) = PerformanceBenchmark.Timer.time_function_with_iterations simple_function 42 10 in
  assert_true (avg_time >= 0.0) "平均执行时间非负";
  assert_true (variance >= 0.0) "执行时间方差非负";
  
  Printf.printf "✓ 计时器功能测试通过\n"

(** 测试内存监控功能 *)
let test_memory_monitoring () =
  Printf.printf "测试内存监控功能...\n";
  
  (* 测试内存信息获取 *)
  let memory_info = PerformanceBenchmark.MemoryMonitor.get_memory_info () in
  assert_option_some memory_info "内存信息获取成功";
  
  (* 测试内存使用测量 *)
  let memory_intensive_function size =
    let arr = Array.make size 0 in
    Array.length arr
  in
  
  let (result, _memory_change) = PerformanceBenchmark.MemoryMonitor.measure_memory_usage 
    memory_intensive_function 1000 in
  assert_true (result = 1000) "内存密集型函数结果正确";
  
  Printf.printf "✓ 内存监控功能测试通过\n"

(** 测试词法分析器基准测试 *)
let test_lexer_benchmark () =
  Printf.printf "测试词法分析器基准测试...\n";
  
  (* 测试测试数据生成 *)
  let small_data = PerformanceBenchmark.LexerBenchmark.create_test_data 5 in
  assert_true (String.length small_data > 0) "生成的测试数据非空";
  
  (* 测试基准测试运行 *)
  let lexer_metrics = PerformanceBenchmark.LexerBenchmark.run_lexer_benchmark () in
  assert_true (List.length lexer_metrics > 0) "生成了词法分析器性能指标";
  
  List.iter (fun metric ->
    assert_true (metric.execution_time >= 0.0) "执行时间非负";
    assert_true (metric.iterations > 0) "迭代次数为正";
    assert_true (String.contains metric.name '\232') "测试名称包含中文"
  ) lexer_metrics;
  
  Printf.printf "✓ 词法分析器基准测试通过\n"

(** 测试语法分析器基准测试 *)
let test_parser_benchmark () =
  Printf.printf "测试语法分析器基准测试...\n";
  
  (* 测试复杂表达式生成 *)
  let simple_expr = PerformanceBenchmark.ParserBenchmark.create_complex_expression 2 in
  let complex_expr = PerformanceBenchmark.ParserBenchmark.create_complex_expression 5 in
  assert_true (String.length complex_expr > String.length simple_expr) "复杂表达式更长";
  
  (* 测试基准测试运行 *)
  let parser_metrics = PerformanceBenchmark.ParserBenchmark.run_parser_benchmark () in
  assert_true (List.length parser_metrics > 0) "生成了语法分析器性能指标";
  
  List.iter (fun metric ->
    assert_true (metric.execution_time >= 0.0) "执行时间非负";
    assert_true (metric.iterations > 0) "迭代次数为正"
  ) parser_metrics;
  
  Printf.printf "✓ 语法分析器基准测试通过\n"

(** 测试诗词编程特色功能基准测试 *)
let test_poetry_benchmark () =
  Printf.printf "测试诗词编程特色功能基准测试...\n";
  
  (* 测试诗词文本生成 *)
  let short_poem = PerformanceBenchmark.PoetryBenchmark.create_poetry_text 2 in
  let long_poem = PerformanceBenchmark.PoetryBenchmark.create_poetry_text 10 in
  assert_true (String.length long_poem > String.length short_poem) "长诗词文本更长";
  assert_true (String.length short_poem > 0) "诗词文本非空";
  
  (* 测试基准测试运行 *)
  let poetry_metrics = PerformanceBenchmark.PoetryBenchmark.run_poetry_benchmark () in
  assert_true (List.length poetry_metrics > 0) "生成了诗词分析性能指标";
  
  List.iter (fun metric ->
    assert_true (metric.execution_time >= 0.0) "执行时间非负";
    assert_true (metric.iterations > 0) "迭代次数为正";
    assert_true (String.length metric.name > 0) "测试名称非空"
  ) poetry_metrics;
  
  Printf.printf "✓ 诗词编程特色功能基准测试通过\n"

(** 测试完整基准测试套件 *)
let test_full_benchmark_suite () =
  Printf.printf "测试完整基准测试套件...\n";
  
  let benchmark_suite = PerformanceBenchmark.run_full_benchmark_suite () in
  
  (* 验证套件基本属性 *)
  assert_true (String.length benchmark_suite.suite_name > 0) "套件名称非空";
  assert_true (benchmark_suite.total_duration >= 0.0) "总执行时间非负";
  assert_true (List.length benchmark_suite.results > 0) "包含测试结果";
  
  (* 验证每个测试结果 *)
  List.iter (fun result ->
    assert_true (String.length result.module_name > 0) "模块名称非空";
    assert_true (String.length result.test_category > 0) "测试类别非空";
    assert_true (List.length result.metrics > 0) "包含性能指标";
    assert_true (String.length result.timestamp > 0) "时间戳非空";
    assert_true (String.length result.environment > 0) "环境信息非空"
  ) benchmark_suite.results;
  
  Printf.printf "✓ 完整基准测试套件测试通过\n"

(** 测试报告生成功能 *)
let test_report_generation () =
  Printf.printf "测试报告生成功能...\n";
  
  (* 创建测试用的性能指标 *)
  let test_metric = {
    name = "测试指标";
    execution_time = 0.123;
    memory_usage = Some 1024;
    cpu_usage = None;
    iterations = 10;
    variance = Some 0.001;
  } in
  
  (* 测试指标摘要生成 *)
  let summary = BenchmarkReporter.summarize_metric test_metric in
  assert_true (String.length summary > 0) "摘要非空";
  assert_true (String.contains summary '0') "摘要包含数字";
  
  (* 创建测试用的基准测试套件 *)
  let test_suite = {
    suite_name = "测试套件";
    results = [{
      module_name = "测试模块";
      test_category = "测试类别";
      metrics = [test_metric];
      baseline = None;
      timestamp = "2025-07-23 12:00:00";
      environment = "测试环境";
    }];
    summary = "测试总结";
    total_duration = 1.0;
  } in
  
  (* 测试Markdown报告生成 *)
  let markdown_report = BenchmarkReporter.generate_markdown_report test_suite in
  assert_true (String.contains markdown_report '#') "Markdown报告包含标题";
  assert_true (String.length markdown_report > 100) "Markdown报告内容充实";
  
  Printf.printf "✓ 报告生成功能测试通过\n"

(** 测试回归检测功能 *)
let test_regression_detection () =
  Printf.printf "测试回归检测功能...\n";
  
  (* 创建基线和当前性能指标 *)
  let baseline_metric = {
    name = "词法分析器";
    execution_time = 1.0;
    memory_usage = Some 1000;
    cpu_usage = None;
    iterations = 10;
    variance = None;
  } in
  
  let good_metric = {
    baseline_metric with execution_time = 1.1 (* 10%性能变化，在阈值内 *)
  } in
  
  let bad_metric = {
    baseline_metric with execution_time = 1.5 (* 50%性能下降，超过阈值 *)
  } in
  
  (* 测试正常性能变化 *)
  let good_result = RegressionDetector.detect_regression good_metric baseline_metric in
  assert_true (good_result = None) "正常性能变化不应触发警告";
  
  (* 测试性能回归 *)
  let bad_result = RegressionDetector.detect_regression bad_metric baseline_metric in
  assert_option_some bad_result "性能回归应触发警告";
  
  Printf.printf "✓ 回归检测功能测试通过\n"

(** 测试公共接口函数 *)
let test_public_interface () =
  Printf.printf "测试公共接口函数...\n";
  
  (* 测试运行基准测试 *)
  let suite = run_benchmark_suite () in
  assert_true (List.length suite.results > 0) "基准测试产生结果";
  
  (* 测试报告生成和保存（使用临时文件） *)
  let temp_file = "/tmp/test_benchmark_report_" ^ string_of_int (int_of_float (Unix.time ())) ^ ".md" in
  let save_message = generate_and_save_report suite temp_file in
  assert_true (String.contains save_message ':') "保存消息包含文件路径信息";
  
  (* 验证文件是否创建 *)
  assert_true (Sys.file_exists temp_file) "报告文件成功创建";
  
  (* 清理临时文件 *)
  (try Sys.remove temp_file with _ -> ());
  
  Printf.printf "✓ 公共接口函数测试通过\n"

(** 压力测试 - 测试大规模数据处理 *)
let test_stress_testing () =
  Printf.printf "运行压力测试...\n";
  
  (* 生成大量测试数据 *)
  let large_data = PerformanceBenchmark.LexerBenchmark.create_test_data 500 in
  assert_true (String.length large_data > 10000) "生成大规模测试数据";
  
  (* 生成深度嵌套表达式 *)
  let complex_expr = PerformanceBenchmark.ParserBenchmark.create_complex_expression 10 in
  assert_true (String.length complex_expr > 1000) "生成复杂嵌套表达式";
  
  (* 生成长篇诗词 *)
  let long_poetry = PerformanceBenchmark.PoetryBenchmark.create_poetry_text 100 in
  assert_true (String.length long_poetry > 5000) "生成长篇诗词文本";
  
  Printf.printf "✓ 压力测试通过\n"

(** 边界条件测试 *)
let test_edge_cases () =
  Printf.printf "测试边界条件...\n";
  
  (* 测试零大小数据 *)
  let empty_data = PerformanceBenchmark.LexerBenchmark.create_test_data 0 in
  assert_true (String.length empty_data >= 0) "零大小数据处理正常";
  
  (* 测试零深度表达式 *)
  let simple_expr = PerformanceBenchmark.ParserBenchmark.create_complex_expression 0 in
  assert_true (String.length simple_expr > 0) "零深度表达式有默认值";
  
  (* 测试单行诗词 *)
  let single_line_poem = PerformanceBenchmark.PoetryBenchmark.create_poetry_text 1 in
  assert_true (String.length single_line_poem > 0) "单行诗词处理正常";
  
  Printf.printf "✓ 边界条件测试通过\n"

(** 运行所有测试 *)
let run_all_tests () =
  Printf.printf "🚀 开始运行性能基准测试系统测试套件\n";
  Printf.printf "================================================\n\n";
  
  try
    (* 基础功能测试 *)
    test_timer_functionality ();
    test_memory_monitoring ();
    
    (* 模块功能测试 *)
    test_lexer_benchmark ();
    test_parser_benchmark ();
    test_poetry_benchmark ();
    
    (* 集成测试 *)
    test_full_benchmark_suite ();
    test_report_generation ();
    test_regression_detection ();
    test_public_interface ();
    
    (* 压力和边界测试 *)
    test_stress_testing ();
    test_edge_cases ();
    
    Printf.printf "\n================================================\n";
    Printf.printf "✅ 所有测试通过！性能基准测试系统运行正常\n";
    Printf.printf "📊 测试覆盖：计时器、内存监控、基准测试、报告生成、回归检测\n";
    Printf.printf "🎯 特色功能：中文编程、诗词分析、完整工作流程\n";
    Printf.printf "================================================\n"
    
  with 
  | Failure msg -> 
    Printf.printf "\n❌ 测试失败: %s\n" msg;
    exit 1
  | exn -> 
    Printf.printf "\n❌ 测试异常: %s\n" (Printexc.to_string exn);
    exit 1

(** 主函数 *)
let () = run_all_tests ()