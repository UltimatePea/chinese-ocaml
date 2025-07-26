(** 语法分析器性能基准测试模块
    
    专注于语法分析器的性能测试，使用统一的测试执行框架 *)

open Utils.Base_formatter
open Benchmark_coordinator

module ParserBenchmark = struct
  (** 复杂表达式生成器 *)
  let create_complex_expression depth =
    let rec build_expr current_depth =
      if current_depth <= 0 then "42"
      else
        concat_strings
          [ "("; build_expr (current_depth - 1); " 加 "; build_expr (current_depth - 1); ")" ]
    in
    build_expr depth

  (** 语法分析模拟函数 *)
  let dummy_parser text =
    String.length text * 2

  (** 语法分析基准测试配置 *)
  let get_parser_test_configs () = [
    {
      Benchmark_core.name = "简单表达式解析";
      iterations = 100;
      data_size = 5;
      description = "简单表达式测试";
    };
    {
      Benchmark_core.name = "复杂表达式解析";
      iterations = 50;
      data_size = 8;
      description = "复杂表达式测试";
    };
    {
      Benchmark_core.name = "深层嵌套表达式解析";
      iterations = 20;
      data_size = 12;
      description = "深层嵌套测试";
    };
  ]

  (** 运行语法分析器基准测试 *)
  let run_parser_benchmark () =
    let test_configs = get_parser_test_configs () in
    TestExecutor.execute_benchmark_tests 
      test_configs 
      dummy_parser 
      Benchmark_core.Utils.simple_content_generator

  (** 运行带内存监控的语法分析器基准测试 *)
  let run_parser_benchmark_with_memory () =
    let test_configs = get_parser_test_configs () in
    TestExecutor.execute_benchmark_tests_with_memory 
      test_configs 
      dummy_parser 
      Benchmark_core.Utils.simple_content_generator

  (** 运行复杂表达式特化测试 *)
  let run_complex_expression_benchmark () =
    let expression_configs = [
      {
        Benchmark_core.name = "表达式深度3";
        iterations = 200;
        data_size = 3;
        description = "中等深度表达式";
      };
      {
        Benchmark_core.name = "表达式深度5";
        iterations = 100;
        data_size = 5;
        description = "较深表达式";
      };
      {
        Benchmark_core.name = "表达式深度8";
        iterations = 50;
        data_size = 8;
        description = "深层表达式";
      };
    ] in
    
    List.map
      (fun config ->
        let { Benchmark_core.name; iterations; data_size; description = _ } = config in
        let test_data = create_complex_expression data_size in
        let start_time = Sys.time () in
        let _result = dummy_parser test_data in
        let end_time = Sys.time () in
        let execution_time = end_time -. start_time in
        {
          name;
          execution_time;
          memory_usage = None;
          cpu_usage = None;
          iterations;
          variance = None;
        })
      expression_configs
end

(** 公共接口函数 *)
let run_benchmark = ParserBenchmark.run_parser_benchmark
let run_benchmark_with_memory = ParserBenchmark.run_parser_benchmark_with_memory
let run_complex_expression_benchmark = ParserBenchmark.run_complex_expression_benchmark