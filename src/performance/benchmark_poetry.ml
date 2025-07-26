(** 诗词编程特色功能性能基准测试模块

    专注于诗词编程语言特色功能的性能测试，使用统一的测试执行框架 *)

open Benchmark_coordinator

module PoetryBenchmark = struct
  (** 诗词内容生成器 *)
  let create_poetry_text lines =
    let poem_lines =
      [
        "春眠不觉晓，处处闻啼鸟。";
        "夜来风雨声，花落知多少。";
        "床前明月光，疑是地上霜。";
        "举头望明月，低头思故乡。";
        "红豆生南国，春来发几枝。";
        "愿君多采撷，此物最相思。";
        "独在异乡为异客，每逢佳节倍思亲。";
        "遥知兄弟登高处，遍插茱萸少一人。";
      ]
    in
    let repeated_lines = ref [] in
    for _i = 1 to lines do
      repeated_lines := poem_lines @ !repeated_lines
    done;
    String.concat "\n" !repeated_lines

  (** 诗词分析模拟函数 *)
  let dummy_poetry_analyzer text =
    let char_count = String.length text in
    char_count * char_count / 100

  (** 诗词分析基准测试配置 *)
  let get_poetry_test_configs () =
    [
      { Benchmark_core.name = "短诗韵律分析"; iterations = 30; data_size = 2; description = "短诗测试" };
      { Benchmark_core.name = "长诗韵律分析"; iterations = 10; data_size = 10; description = "长诗测试" };
      { Benchmark_core.name = "古典诗集分析"; iterations = 5; data_size = 50; description = "大型诗集测试" };
    ]

  (** 运行诗词分析基准测试 *)
  let run_poetry_benchmark () =
    let test_configs = get_poetry_test_configs () in
    TestExecutor.execute_benchmark_tests test_configs dummy_poetry_analyzer
      Benchmark_core.Utils.poetry_content_generator

  (** 运行带内存监控的诗词分析基准测试 *)
  let run_poetry_benchmark_with_memory () =
    let test_configs = get_poetry_test_configs () in
    TestExecutor.execute_benchmark_tests_with_memory test_configs dummy_poetry_analyzer
      Benchmark_core.Utils.poetry_content_generator

  (** 运行诗词特色功能专项测试 *)
  let run_poetry_feature_benchmark () =
    let poetry_feature_configs =
      [
        { Benchmark_core.name = "诗词韵律检测"; iterations = 50; data_size = 4; description = "韵律分析测试" };
        { Benchmark_core.name = "诗词情感分析"; iterations = 30; data_size = 8; description = "情感识别测试" };
        { Benchmark_core.name = "诗词格律校验"; iterations = 20; data_size = 12; description = "格律验证测试" };
      ]
    in

    List.map
      (fun config ->
        let { Benchmark_core.name; iterations; data_size; description = _ } = config in
        let test_data = create_poetry_text data_size in
        let start_time = Sys.time () in
        let _result = dummy_poetry_analyzer test_data in
        let end_time = Sys.time () in
        let execution_time = end_time -. start_time in
        { name; execution_time; memory_usage = None; cpu_usage = None; iterations; variance = None })
      poetry_feature_configs
end

(** 公共接口函数 *)
let run_benchmark = PoetryBenchmark.run_poetry_benchmark

let run_benchmark_with_memory = PoetryBenchmark.run_poetry_benchmark_with_memory
let run_poetry_feature_benchmark = PoetryBenchmark.run_poetry_feature_benchmark
