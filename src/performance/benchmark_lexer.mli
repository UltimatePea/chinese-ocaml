(** 词法分析器性能基准测试模块接口 *)

module LexerBenchmark : sig
  val create_test_data : int -> string
  (** 创建指定大小的测试数据 *)

  val get_lexer_test_configs : unit -> Benchmark_core.test_config list
  (** 获取词法分析器测试配置 *)

  val run_lexer_benchmark : unit -> Benchmark_coordinator.performance_metric list
  (** 运行词法分析器基准测试 *)

  val run_lexer_benchmark_with_memory : unit -> Benchmark_coordinator.performance_metric list
  (** 运行带内存监控的词法分析器基准测试 *)
end

val run_benchmark : unit -> Benchmark_coordinator.performance_metric list
(** 公共接口函数 *)

val run_benchmark_with_memory : unit -> Benchmark_coordinator.performance_metric list
