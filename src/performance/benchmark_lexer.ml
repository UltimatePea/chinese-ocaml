(** 词法分析器性能基准测试模块
    
    专注于词法分析器的性能测试，使用统一的测试执行框架 *)

open Utils.Base_formatter
open Benchmark_coordinator

module LexerBenchmark = struct
  (** 测试数据生成 *)
  let create_test_data size =
    let base_text = "让 变量 = 123 加 456" in
    let repeated_text = ref "" in
    for _i = 1 to size do
      repeated_text := concat_strings [ !repeated_text; "\n"; base_text ]
    done;
    !repeated_text

  (** 词法分析模拟函数 *)
  let dummy_lexer text =
    String.length text

  (** 词法分析基准测试配置 *)
  let get_lexer_test_configs () = [
    {
      Benchmark_core.name = "小型文本词法分析";
      iterations = 50;
      data_size = 10;
      description = "小规模测试";
    };
    {
      Benchmark_core.name = "中型文本词法分析";
      iterations = 20;
      data_size = 100;
      description = "中等规模测试";
    };
    {
      Benchmark_core.name = "大型文本词法分析";
      iterations = 10;
      data_size = 1000;
      description = "大规模测试";
    };
  ]

  (** 运行词法分析器基准测试 *)
  let run_lexer_benchmark () =
    let test_configs = get_lexer_test_configs () in
    TestExecutor.execute_benchmark_tests 
      test_configs 
      dummy_lexer 
      Benchmark_core.Utils.simple_content_generator

  (** 运行带内存监控的词法分析器基准测试 *)
  let run_lexer_benchmark_with_memory () =
    let test_configs = get_lexer_test_configs () in
    TestExecutor.execute_benchmark_tests_with_memory 
      test_configs 
      dummy_lexer 
      Benchmark_core.Utils.simple_content_generator
end

(** 公共接口函数 *)
let run_benchmark = LexerBenchmark.run_lexer_benchmark
let run_benchmark_with_memory = LexerBenchmark.run_lexer_benchmark_with_memory