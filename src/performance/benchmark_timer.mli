(** 性能基准测试计时器模块接口 *)

open Benchmark_core

(** 计时器模块 *)
module Timer : sig
  val time_function : ('a -> 'b) -> 'a -> 'b * float
  val time_function_with_iterations : ('a -> 'b) -> 'a -> int -> float * float
  val time_with_warmup : ('a -> 'b) -> 'a -> int -> int -> float * float
  val high_precision_timer : ('a -> 'b) -> 'a -> 'b * float
  val batch_timing_test : ('a -> 'b) -> 'a list -> int -> performance_metric list

  val regression_timing_test :
    ('a -> 'b) -> 'a -> float -> int -> float -> performance_metric * bool * float
end

(** 高级计时分析 *)
module AdvancedTiming : sig
  type timing_analysis = {
    mean_time : float;
    median_time : float;
    min_time : float;
    max_time : float;
    std_deviation : float;
    percentile_95 : float;
    percentile_99 : float;
  }

  val analyze_timing_results : float list -> timing_analysis
  val format_timing_analysis : timing_analysis -> string list
  val deep_timing_analysis : ('a -> 'b) -> 'a -> int -> timing_analysis
end

(** 计时器配置 *)
module TimerConfig : sig
  val default_config : test_config
  val quick_config : test_config
  val detailed_config : test_config
  val create_config : string -> int -> int -> string -> test_config
end
