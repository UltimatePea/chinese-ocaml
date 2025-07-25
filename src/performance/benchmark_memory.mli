(** 性能基准测试内存监控模块接口 *)

open Benchmark_core

(** 内存监控模块 *)
module MemoryMonitor : sig
  val get_memory_usage : unit -> int
  val measure_memory_usage : ('a -> 'b) -> 'a -> 'b * int option
  val batch_memory_test : ('a -> 'b) -> 'a list -> performance_metric list
  val detect_memory_leak : ('a -> 'b) -> 'a -> int -> bool * int * int list
  val get_gc_statistics : unit -> string list
end

(** 高级内存分析 *)
module AdvancedMemory : sig
  type memory_analysis = {
    initial_memory : int;
    peak_memory : int;
    final_memory : int;
    memory_growth : int;
    gc_collections : int;
    allocation_rate : float;
  }

  val analyze_memory_usage : ('a -> 'b) -> 'a -> float -> memory_analysis
  val format_memory_analysis : memory_analysis -> string list
end

(** 内存基准测试配置 *)
module MemoryConfig : sig
  type memory_test_config = {
    enable_gc_monitoring : bool;
    sample_interval : float;
    memory_threshold : int;
    leak_detection : bool;
  }

  val default_memory_config : memory_test_config
  val quick_memory_config : memory_test_config
  val detailed_memory_config : memory_test_config
end
