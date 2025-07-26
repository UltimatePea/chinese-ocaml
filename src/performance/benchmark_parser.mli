(** 语法分析器性能基准测试模块接口 *)

module ParserBenchmark : sig
  val create_complex_expression : int -> string
  (** 创建复杂表达式 *)

  val get_parser_test_configs : unit -> Benchmark_core.test_config list
  (** 获取语法分析器测试配置 *)

  val run_parser_benchmark : unit -> Benchmark_coordinator.performance_metric list
  (** 运行语法分析器基准测试 *)

  val run_parser_benchmark_with_memory : unit -> Benchmark_coordinator.performance_metric list
  (** 运行带内存监控的语法分析器基准测试 *)

  val run_complex_expression_benchmark : unit -> Benchmark_coordinator.performance_metric list
  (** 运行复杂表达式特化测试 *)
end

val run_benchmark : unit -> Benchmark_coordinator.performance_metric list
(** 公共接口函数 *)

val run_benchmark_with_memory : unit -> Benchmark_coordinator.performance_metric list
val run_complex_expression_benchmark : unit -> Benchmark_coordinator.performance_metric list
