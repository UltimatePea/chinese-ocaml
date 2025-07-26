(** 性能基准测试系统（模块化重构版本）

    主要入口点和兼容性层，重新导出所有模块化组件的功能

    重构目标：Fix #1390 - 大型文件重构第三阶段
    - 将397行文件分解为专门的功能模块
    - 利用现有的模块化框架消除代码重复
    - 保持完整的向后兼容性 *)

open Performance
(** 导入模块化性能基准测试框架 *)

open Performance.Benchmark_coordinator
(** 导入协调器模块，获取核心类型定义 *)

type performance_metric = Performance.Benchmark_coordinator.performance_metric = {
  name : string;
  execution_time : float;
  memory_usage : int option;
  cpu_usage : float option;
  iterations : int;
  variance : float option;
}
(** 重新导出核心类型，保持向后兼容性 *)

type benchmark_result = Performance.Benchmark_coordinator.benchmark_result = {
  module_name : string;
  test_category : string;
  metrics : performance_metric list;
  baseline : performance_metric option;
  timestamp : string;
  environment : string;
}

type benchmark_suite = Performance.Benchmark_coordinator.benchmark_suite = {
  suite_name : string;
  results : benchmark_result list;
  summary : string;
  total_duration : float;
}

(** 性能基准测试器 - 模块化facade，重新导出各功能模块 *)
module PerformanceBenchmark = struct
  (** 计时器模块 - 委托给模块化Timer *)
  module Timer = struct
    include Benchmark_timer.Timer

    let time_function = Benchmark_timer.Timer.time_function
    let time_function_with_iterations = Benchmark_timer.Timer.time_function_with_iterations
  end

  (** 内存监控模块 - 委托给模块化MemoryMonitor *)
  module MemoryMonitor = struct
    let get_memory_info () =
      try
        let gc_stat = Gc.stat () in
        Some (gc_stat.Gc.live_words * (Sys.word_size / 8))
      with _ -> None

    let measure_memory_usage f input =
      let initial_memory = get_memory_info () in
      let result = f input in
      let final_memory = get_memory_info () in
      match (initial_memory, final_memory) with
      | Some initial, Some final -> (result, Some (final - initial))
      | _ -> (result, None)
  end

  (** 重新导出专门模块的功能，保持向后兼容 *)
  module LexerBenchmark = struct
    include Performance.Benchmark_lexer.LexerBenchmark
  end

  module ParserBenchmark = struct
    include Performance.Benchmark_parser.ParserBenchmark
  end

  module PoetryBenchmark = struct
    include Performance.Benchmark_poetry.PoetryBenchmark
  end

  (** 委托核心框架函数 *)
  let get_current_timestamp =
    Performance.Benchmark_coordinator.SuiteCoordinator.get_current_timestamp

  let get_system_environment =
    Performance.Benchmark_coordinator.SuiteCoordinator.get_system_environment

  let create_benchmark_result =
    Performance.Benchmark_coordinator.SuiteCoordinator.create_benchmark_result

  (** 运行所有模块的基准测试 - 使用协调器 *)
  let run_all_module_benchmarks timestamp environment =
    let test_modules =
      [
        ("词法分析器", "词法分析", Performance.Benchmark_lexer.run_benchmark);
        ("语法分析器", "语法分析", Performance.Benchmark_parser.run_benchmark);
        ("诗词分析器", "诗词编程特色", Performance.Benchmark_poetry.run_benchmark);
      ]
    in
    List.map
      (fun (module_name, test_category, test_runner) ->
        let metrics = test_runner () in
        create_benchmark_result module_name test_category metrics timestamp environment)
      test_modules

  (** 运行完整的基准测试套件 - 使用协调器 *)
  let run_full_benchmark_suite () =
    let test_modules =
      [
        ("词法分析器", "词法分析", Performance.Benchmark_lexer.run_benchmark);
        ("语法分析器", "语法分析", Performance.Benchmark_parser.run_benchmark);
        ("诗词分析器", "诗词编程特色", Performance.Benchmark_poetry.run_benchmark);
      ]
    in
    Performance.Benchmark_coordinator.SuiteCoordinator.run_coordinated_benchmarks test_modules
end

(** 基准测试结果分析和报告生成 - 重新导出模块化报告器 *)
module BenchmarkReporter = struct
  include Performance.Benchmark_reporter.BenchmarkReporter
end

(** 性能回归检测 - 重新导出模块化回归检测器 *)
module RegressionDetector = struct
  include Performance.Benchmark_regression.RegressionDetector
end

(** 主要接口函数，保持向后兼容性 *)
let _run_benchmark = PerformanceBenchmark.run_full_benchmark_suite

let _generate_report = BenchmarkReporter.generate_simple_report

(** 公共接口函数实现 - 重新导出模块化功能 *)
let run_benchmark_suite = PerformanceBenchmark.run_full_benchmark_suite

let generate_and_save_report = Performance.Benchmark_reporter.save_report_to_file

let run_and_report filename =
  let suite = run_benchmark_suite () in
  let report_status = generate_and_save_report suite filename in
  (suite, report_status)

(** 扩展接口函数 - 利用新的模块化功能 *)
let run_lexer_benchmark = Performance.Benchmark_lexer.run_benchmark

let run_parser_benchmark = Performance.Benchmark_parser.run_benchmark
let run_poetry_benchmark = Performance.Benchmark_poetry.run_benchmark
let generate_detailed_report = Performance.Benchmark_reporter.generate_detailed_report
let generate_markdown_report = Performance.Benchmark_reporter.generate_markdown_report
let generate_statistics_report = Performance.Benchmark_reporter.generate_statistics
let detect_performance_regression = Performance.Benchmark_regression.detect_regression
let analyze_performance_regression = Performance.Benchmark_regression.analyze_performance_regression
