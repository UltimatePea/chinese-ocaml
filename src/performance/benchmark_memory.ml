(** 性能基准测试内存监控模块
    
    提供内存使用量测量和分析功能
    
    创建目的：从performance_benchmark.ml中分离内存监控功能，提供专门的内存分析工具
    创建时间：技术债务改进 Phase 5.1 - Fix #1083 *)

open Benchmark_core
open Utils.Base_string_ops.Base_string_ops

(** 内存监控模块 *)
module MemoryMonitor = struct
  
  (** 获取当前内存使用量（近似值） *)
  let get_memory_usage () =
    let gc_stats = Gc.stat () in
    (* 使用堆大小作为内存使用量的近似值 *)
    gc_stats.heap_words * (Sys.word_size / 8)
  
  (** 测量函数执行的内存使用 *)
  let measure_memory_usage f input =
    let initial_memory = get_memory_usage () in
    let result = f input in
    Gc.full_major (); (* 触发完整垃圾回收以获得更准确的测量 *)
    let final_memory = get_memory_usage () in
    let memory_diff = final_memory - initial_memory in
    (result, Some (max 0 memory_diff))
  
  (** 批量内存使用测试 *)
  let batch_memory_test f inputs =
    List.map (fun input ->
      let _, memory_usage = measure_memory_usage f input in
      let input_desc = match input with
        | str when String.length str < 20 -> str
        | str -> concat_strings [String.sub str 0 17; "..."]
      in
      BenchmarkCore.create_metric input_desc 0.0 ?memory_usage 1
    ) inputs
  
  (** 内存泄漏检测 *)
  let detect_memory_leak f input iterations =
    let initial_memory = get_memory_usage () in
    let memory_samples = ref [] in
    
    for i = 1 to iterations do
      let _ = f input in
      if i mod 10 = 0 then (
        Gc.full_major ();
        let current_memory = get_memory_usage () in
        memory_samples := current_memory :: !memory_samples
      )
    done;
    
    let final_memory = get_memory_usage () in
    let memory_growth = final_memory - initial_memory in
    let growth_per_iteration = float_of_int memory_growth /. float_of_int iterations in
    
    let has_leak = growth_per_iteration > 100.0 in (* 阈值：每次迭代增长超过100字节 *)
    (has_leak, memory_growth, List.rev !memory_samples)
  
  (** 获取详细的GC统计信息 *)
  let get_gc_statistics () =
    let stats = Gc.stat () in
    [
      concat_strings ["堆大小: "; Utils.format_memory_usage (stats.heap_words * (Sys.word_size / 8))];
      concat_strings ["存活数据: "; Utils.format_memory_usage (stats.live_words * (Sys.word_size / 8))];
      concat_strings ["主GC次数: "; int_to_string stats.major_collections];
      concat_strings ["次GC次数: "; int_to_string stats.minor_collections];
      concat_strings ["分配的字: "; int_to_string (stats.minor_words + stats.major_words)];
    ]
    
end

(** 高级内存分析 *)
module AdvancedMemory = struct
  
  (** 内存分析结果 *)
  type memory_analysis = {
    initial_memory : int;
    peak_memory : int;
    final_memory : int;
    memory_growth : int;
    gc_collections : int;
    allocation_rate : float; (* 每秒分配字节数 *)
  }
  
  (** 执行内存分析 *)
  let analyze_memory_usage f input duration =
    let initial_stats = Gc.stat () in
    let initial_memory = MemoryMonitor.get_memory_usage () in
    let start_time = Unix.gettimeofday () in
    
    let peak_memory = ref initial_memory in
    let monitoring_thread_active = ref true in
    
    (* 启动内存监控 *)
    let monitor_memory () =
      while !monitoring_thread_active do
        let current_memory = MemoryMonitor.get_memory_usage () in
        peak_memory := max !peak_memory current_memory;
        Unix.sleepf 0.01; (* 10ms 采样间隔 *)
      done
    in
    
    (* 执行测试函数 *)
    let _result = f input in
    monitoring_thread_active := false;
    
    let end_time = Unix.gettimeofday () in
    let final_stats = Gc.stat () in
    let final_memory = MemoryMonitor.get_memory_usage () in
    
    let actual_duration = end_time -. start_time in
    let allocated_words = (final_stats.minor_words + final_stats.major_words) - 
                         (initial_stats.minor_words + initial_stats.major_words) in
    let allocation_rate = float_of_int allocated_words *. float_of_int (Sys.word_size / 8) /. actual_duration in
    
    {
      initial_memory;
      peak_memory = !peak_memory;
      final_memory;
      memory_growth = final_memory - initial_memory;
      gc_collections = (final_stats.major_collections + final_stats.minor_collections) - 
                      (initial_stats.major_collections + initial_stats.minor_collections);
      allocation_rate;
    }
  
  (** 格式化内存分析结果 *)
  let format_memory_analysis analysis =
    [
      concat_strings ["初始内存: "; Utils.format_memory_usage analysis.initial_memory];
      concat_strings ["峰值内存: "; Utils.format_memory_usage analysis.peak_memory];
      concat_strings ["最终内存: "; Utils.format_memory_usage analysis.final_memory];
      concat_strings ["内存增长: "; Utils.format_memory_usage analysis.memory_growth];
      concat_strings ["GC次数: "; int_to_string analysis.gc_collections];
      concat_strings ["分配速率: "; Utils.format_memory_usage (int_of_float analysis.allocation_rate); "/秒"];
    ]
    
end

(** 内存基准测试配置 *)
module MemoryConfig = struct
  
  (** 内存测试配置 *)
  type memory_test_config = {
    enable_gc_monitoring : bool;
    sample_interval : float; (* 采样间隔（秒） *)
    memory_threshold : int; (* 内存警告阈值（字节） *)
    leak_detection : bool;
  }
  
  (** 默认内存测试配置 *)
  let default_memory_config = {
    enable_gc_monitoring = true;
    sample_interval = 0.01;
    memory_threshold = 1024 * 1024; (* 1MB *)
    leak_detection = true;
  }
  
  (** 快速内存测试配置 *)
  let quick_memory_config = {
    enable_gc_monitoring = false;
    sample_interval = 0.1;
    memory_threshold = 10 * 1024 * 1024; (* 10MB *)
    leak_detection = false;
  }
  
  (** 详细内存测试配置 *)
  let detailed_memory_config = {
    enable_gc_monitoring = true;
    sample_interval = 0.001;
    memory_threshold = 512 * 1024; (* 512KB *)
    leak_detection = true;
  }
  
end