(** 性能基准测试计时器模块
    
    提供精确的执行时间测量和统计分析功能
    
    创建目的：从performance_benchmark.ml中分离计时功能，提供专门的时间测量工具
    创建时间：技术债务改进 Phase 5.1 - Fix #1083 *)

open Benchmark_core
open Utils.Base_string_ops.Base_string_ops

(** 计时器模块 *)
module Timer = struct
  
  (** 测量单次函数执行时间 *)
  let time_function f input =
    let start_time = Sys.time () in
    let result = f input in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    (result, duration)
  
  (** 测量函数多次执行的平均时间和方差 *)
  let time_function_with_iterations f input iterations =
    let times = ref [] in
    let total_time = ref 0.0 in
    for _i = 1 to iterations do
      let start_time = Sys.time () in
      let _ = f input in
      let end_time = Sys.time () in
      let duration = end_time -. start_time in
      times := duration :: !times;
      total_time := !total_time +. duration
    done;
    let avg_time = !total_time /. (float_of_int iterations) in
    let variance = Statistics.calculate_variance !times in
    (avg_time, variance)
  
  (** 带预热的计时测量 *)
  let time_with_warmup f input warmup_iterations test_iterations =
    (* 预热阶段 *)
    for _i = 1 to warmup_iterations do
      let _ = f input in
      ()
    done;
    (* 正式测量阶段 *)
    time_function_with_iterations f input test_iterations
  
  (** 高精度计时器（使用Unix.gettimeofday） *)
  let high_precision_timer f input =
    let start_time = Unix.gettimeofday () in
    let result = f input in
    let end_time = Unix.gettimeofday () in
    let duration = end_time -. start_time in
    (result, duration)
  
  (** 批量计时测试 *)
  let batch_timing_test f inputs iterations =
    List.map (fun input ->
      let avg_time, variance = time_function_with_iterations f input iterations in
      let input_desc = match input with
        | str when String.length str < 20 -> str
        | str -> concat_strings [String.sub str 0 17; "..."]
      in
      BenchmarkCore.create_metric input_desc avg_time ~variance iterations
    ) inputs
  
  (** 性能回归检测计时 *)
  let regression_timing_test f input baseline_time iterations tolerance =
    let avg_time, variance = time_function_with_iterations f input iterations in
    let performance_ratio = avg_time /. baseline_time in
    let is_regression = performance_ratio > (1.0 +. tolerance) in
    
    let metric = BenchmarkCore.create_metric 
      "回归检测测试" avg_time ~variance iterations in
    (metric, is_regression, performance_ratio)
    
end

(** 高级计时分析 *)
module AdvancedTiming = struct
  
  (** 计时结果分析 *)
  type timing_analysis = {
    mean_time : float;
    median_time : float;
    min_time : float;
    max_time : float;
    std_deviation : float;
    percentile_95 : float;
    percentile_99 : float;
  }
  
  (** 计算时间序列的详细统计信息 *)
  let analyze_timing_results times =
    let sorted_times = List.sort compare times in
    let count = List.length times in
    let mean = Statistics.calculate_mean times in
    let std_dev = Statistics.calculate_std_dev times in
    
    let get_percentile p =
      let index = int_of_float (float_of_int count *. p /. 100.0) in
      let safe_index = max 0 (min (count - 1) index) in
      List.nth sorted_times safe_index
    in
    
    {
      mean_time = mean;
      median_time = get_percentile 50.0;
      min_time = List.hd sorted_times;
      max_time = List.hd (List.rev sorted_times);
      std_deviation = std_dev;
      percentile_95 = get_percentile 95.0;
      percentile_99 = get_percentile 99.0;
    }
  
  (** 格式化时间分析结果 *)
  let format_timing_analysis analysis =
    [
      concat_strings ["平均时间: "; Utils.format_execution_time analysis.mean_time];
      concat_strings ["中位数时间: "; Utils.format_execution_time analysis.median_time];
      concat_strings ["最小时间: "; Utils.format_execution_time analysis.min_time];
      concat_strings ["最大时间: "; Utils.format_execution_time analysis.max_time];
      concat_strings ["标准差: "; Utils.format_execution_time analysis.std_deviation];
      concat_strings ["95%分位数: "; Utils.format_execution_time analysis.percentile_95];
      concat_strings ["99%分位数: "; Utils.format_execution_time analysis.percentile_99];
    ]
  
  (** 执行深度计时分析 *)
  let deep_timing_analysis f input iterations =
    let times = ref [] in
    for _i = 1 to iterations do
      let _, duration = Timer.high_precision_timer f input in
      times := duration :: !times
    done;
    analyze_timing_results !times
    
end

(** 计时器配置 *)
module TimerConfig = struct
  
  (** 默认测试配置 *)
  let default_config = {
    name = "默认计时测试";
    iterations = 10;
    data_size = 100;
    description = "标准性能测试配置";
  }
  
  (** 快速测试配置 *)
  let quick_config = {
    name = "快速计时测试";
    iterations = 5;
    data_size = 50;
    description = "快速性能验证配置";
  }
  
  (** 详细测试配置 *)
  let detailed_config = {
    name = "详细计时测试";
    iterations = 50;
    data_size = 500;
    description = "详细性能分析配置";
  }
  
  (** 创建自定义配置 *)
  let create_config name iterations data_size description =
    { name; iterations; data_size; description }
    
end