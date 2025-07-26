(** 诗词编程特色功能性能基准测试模块接口 *)

module PoetryBenchmark : sig
  (** 创建诗词测试文本 *)
  val create_poetry_text : int -> string
  
  (** 获取诗词分析器测试配置 *)
  val get_poetry_test_configs : unit -> Benchmark_core.test_config list
  
  (** 运行诗词分析基准测试 *)
  val run_poetry_benchmark : unit -> Benchmark_coordinator.performance_metric list
  
  (** 运行带内存监控的诗词分析基准测试 *)
  val run_poetry_benchmark_with_memory : unit -> Benchmark_coordinator.performance_metric list
  
  (** 运行诗词特色功能专项测试 *)
  val run_poetry_feature_benchmark : unit -> Benchmark_coordinator.performance_metric list
end

(** 公共接口函数 *)
val run_benchmark : unit -> Benchmark_coordinator.performance_metric list
val run_benchmark_with_memory : unit -> Benchmark_coordinator.performance_metric list
val run_poetry_feature_benchmark : unit -> Benchmark_coordinator.performance_metric list