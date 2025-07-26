(** 性能基准测试系统接口

    提供系统化的性能基准测试、监控、分析和回归检测功能 支持编译器各模块的性能分析、内存使用监控和CI集成 *)

type performance_metric = {
  name : string;  (** 测试名称 *)
  execution_time : float;  (** 执行时间（秒） *)
  memory_usage : int option;  (** 内存使用（字节），可选 *)
  cpu_usage : float option;  (** CPU使用率（百分比），可选 *)
  iterations : int;  (** 测试迭代次数 *)
  variance : float option;  (** 执行时间方差，可选 *)
}
(** 性能测试结果数据结构 *)

type benchmark_result = {
  module_name : string;  (** 被测模块名称 *)
  test_category : string;  (** 测试类别（词法/语法/语义等） *)
  metrics : performance_metric list;  (** 性能指标列表 *)
  baseline : performance_metric option;  (** 基线性能，用于对比 *)
  timestamp : string;  (** 测试时间戳 *)
  environment : string;  (** 测试环境信息 *)
}

type benchmark_suite = {
  suite_name : string;  (** 测试套件名称 *)
  results : benchmark_result list;  (** 测试结果列表 *)
  summary : string;  (** 测试总结 *)
  total_duration : float;  (** 总测试时间 *)
}

(** 性能基准测试器模块 *)
module PerformanceBenchmark : sig
  (** 计时器模块 *)
  module Timer : sig
    val time_function : ('a -> 'b) -> 'a -> 'b * float
    (** 测量单次函数执行时间 *)

    val time_function_with_iterations : ('a -> 'b) -> 'a -> int -> float * float
    (** 测量多次迭代的平均执行时间和方差 *)
  end

  (** 内存监控模块 *)
  module MemoryMonitor : sig
    val get_memory_info : unit -> int option
    (** 获取当前内存使用信息 *)

    val measure_memory_usage : ('a -> 'b) -> 'a -> 'b * int option
    (** 测量函数执行的内存使用变化 *)
  end

  (** 词法分析器性能测试 *)
  module LexerBenchmark : sig
    val create_test_data : int -> string
    (** 创建指定大小的测试数据 *)

    val run_lexer_benchmark : unit -> performance_metric list
    (** 运行词法分析器基准测试 *)
  end

  (** 语法分析器性能测试 *)
  module ParserBenchmark : sig
    val create_complex_expression : int -> string
    (** 创建指定深度的复杂表达式 *)

    val run_parser_benchmark : unit -> performance_metric list
    (** 运行语法分析器基准测试 *)
  end

  (** 诗词编程特色功能性能测试 *)
  module PoetryBenchmark : sig
    val create_poetry_text : int -> string
    (** 创建指定行数的诗词文本 *)

    val run_poetry_benchmark : unit -> performance_metric list
    (** 运行诗词分析基准测试 *)
  end

  val run_full_benchmark_suite : unit -> benchmark_suite
  (** 运行完整的基准测试套件 *)
end

(** 基准测试结果分析和报告生成 *)
module BenchmarkReporter : sig
  val summarize_metric : performance_metric -> string
  (** 生成性能指标摘要字符串 *)

  val generate_simple_report : benchmark_suite -> string
  (** 生成基本报告 *)

  val generate_detailed_metrics_report : benchmark_suite -> string
  (** 生成详细的性能指标报告 *)

  val generate_markdown_report : benchmark_suite -> string
  (** 生成Markdown格式的详细报告 *)

  val generate_performance_statistics : benchmark_suite -> string
  (** 生成性能统计摘要 *)

  val save_report_to_file : benchmark_suite -> string -> string
  (** 保存报告到指定文件 *)

  val save_detailed_report_to_file : benchmark_suite -> string -> string
  (** 保存详细报告到文件 *)

  val save_markdown_report_to_file : benchmark_suite -> string -> string
  (** 保存Markdown报告到文件 *)
end

(** 性能回归检测 *)
module RegressionDetector : sig
  type regression_threshold = {
    performance_degradation : float;
    memory_increase : float;
    variance_increase : float;
  }

  type regression_result = {
    test_name : string;
    regression_type : string;
    current_value : float;
    baseline_value : float;
    change_percentage : float;
    severity : string;
    description : string;
  }

  val default_threshold : regression_threshold

  val detect_regression :
    ?threshold:regression_threshold ->
    performance_metric ->
    performance_metric ->
    regression_result list
  (** 检测单个指标的性能回归 *)

  val generate_regression_report :
    ?threshold:regression_threshold ->
    performance_metric list ->
    performance_metric list ->
    string list
  (** 生成完整的回归检测报告 *)

  val analyze_performance_regression :
    ?threshold:regression_threshold -> benchmark_suite -> benchmark_suite -> benchmark_suite
  (** 执行完整的回归检测分析 *)
end

(** 公共接口函数 *)

val run_benchmark_suite : unit -> benchmark_suite
(** 运行完整的性能基准测试 *)

val generate_and_save_report : benchmark_suite -> string -> string
(** 生成并保存性能测试报告 *)

val run_and_report : string -> benchmark_suite * string
(** 运行基准测试并保存报告的便捷函数 *)
