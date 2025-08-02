(** Poetry Performance Consolidated Module - Issue #1999
 * 
 * 性能监控和优化统一模块  
 * Author: Whisky, PR Worker
 * 
 * 整合以下模块的功能：
 * - parallelism_analysis.ml
 * - benchmark相关文件
 * - performance/目录下文件
 * 
 * 目标：提供全面的性能监控、分析和优化功能
 *)

(** {1 性能监控类型定义} *)

(** 性能指标类型 *)
type performance_metric = 
  | QueryTime      (** 查询时间 *)
  | CacheHitRate   (** 缓存命中率 *)
  | MemoryUsage    (** 内存使用 *)
  | DataLoadTime   (** 数据加载时间 *)
  | EvaluationTime (** 评价时间 *)

(** 性能基准结果 *)
type benchmark_result = {
  metric: performance_metric;
  value: float;
  unit: string;
  baseline: float option;
  improvement: float option;  (* 相对于基准的改进百分比 *)
}

(** 性能测试配置 *)
type benchmark_config = {
  test_iterations: int;
  warmup_iterations: int;
  test_data_size: int;
  enable_cache: bool;
}

(** 性能分析报告 *)
type performance_report = {
  timestamp: float;
  total_runtime: float;
  benchmark_results: benchmark_result list;
  bottlenecks: string list;
  recommendations: string list;
}

(** {1 性能基准数据} *)

(** 预期性能基准值 *)
let performance_baselines = [
  (QueryTime, 0.001);      (* 1ms per query *)
  (CacheHitRate, 0.80);    (* 80% cache hit rate *)
  (MemoryUsage, 1048576.0); (* 1MB memory usage *)
  (DataLoadTime, 0.1);     (* 100ms data load time *)
  (EvaluationTime, 0.01);  (* 10ms evaluation time *)
]

(** 当前性能统计 *)
let current_stats = ref {
  timestamp = 0.0;
  total_runtime = 0.0;
  benchmark_results = [];
  bottlenecks = [];
  recommendations = [];
}

(** 性能历史记录 *)
let performance_history = ref []

(** {1 性能测试工具} *)

(** 测量函数执行时间 *)
let measure_time (f: unit -> 'a) : 'a * float =
  let start_time = Sys.time () in
  let result = f () in
  let end_time = Sys.time () in
  (result, end_time -. start_time)

(** 重复执行性能测试 *)
let run_repeated_test (iterations: int) (f: unit -> 'a) : float =
  let times = ref [] in
  for _ = 1 to iterations do
    let _, time = measure_time f in
    times := time :: !times
  done;
  let total_time = List.fold_left (+.) 0.0 !times in
  total_time /. float_of_int iterations

(** 预热测试 - 消除冷启动影响 *)
let warmup_test (iterations: int) (f: unit -> 'a) : unit =
  for _ = 1 to iterations do
    ignore (f ())
  done

(** {1 韵律查询性能测试} *)

(** 生成测试数据 *)
let generate_test_chars (count: int) : string list =
  let base_chars = ["风"; "花"; "雪"; "月"; "江"; "山"; "水"; "云"; "日"; "光"] in
  let rec generate acc remaining =
    if remaining = 0 then acc
    else
      let char = List.nth base_chars (Random.int (List.length base_chars)) in
      generate (char :: acc) (remaining - 1)
  in
  generate [] count

(** 韵律查询性能测试 *)
let benchmark_rhyme_query (config: benchmark_config) : benchmark_result list =
  let test_chars = generate_test_chars config.test_data_size in
  
  (* 预热 *)
  warmup_test config.warmup_iterations (fun () ->
    List.iter (fun char -> 
      ignore (Poetry_core_consolidated.find_rhyme_info char)
    ) (List.take 10 test_chars)
  );
  
  (* 测试查询时间 *)
  let query_time = run_repeated_test config.test_iterations (fun () ->
    List.iter (fun char ->
      ignore (Poetry_core_consolidated.find_rhyme_info char)
    ) test_chars
  ) in
  
  let avg_query_time = query_time /. float_of_int config.test_data_size in
  
  let baseline = List.assoc_opt QueryTime performance_baselines in
  let improvement = 
    match baseline with
    | Some base -> Some ((base -. avg_query_time) /. base *. 100.0)
    | None -> None
  in
  
  [{
    metric = QueryTime;
    value = avg_query_time;
    unit = "seconds";
    baseline = baseline;
    improvement = improvement;
  }]

(** {1 缓存性能测试} *)

(** 缓存命中率测试 *)
let benchmark_cache_performance (config: benchmark_config) : benchmark_result list =
  let test_chars = generate_test_chars config.test_data_size in
  
  (* 重置统计 *)
  Poetry_rhyme_engine_consolidated.reset_stats ();
  
  (* 第一轮查询 - 缓存未命中 *)
  List.iter (fun char ->
    ignore (Poetry_rhyme_engine_consolidated.find_rhyme_info_fast char)
  ) test_chars;
  
  (* 第二轮查询 - 应该命中缓存 *)
  List.iter (fun char ->
    ignore (Poetry_rhyme_engine_consolidated.find_rhyme_info_fast char)
  ) test_chars;
  
  let stats = Poetry_rhyme_engine_consolidated.get_query_stats () in
  let hit_rate = 
    if stats.total_queries > 0 then
      float_of_int stats.cache_hits /. float_of_int stats.total_queries
    else 0.0
  in
  
  let baseline = List.assoc_opt CacheHitRate performance_baselines in
  let improvement = 
    match baseline with
    | Some base -> Some ((hit_rate -. base) /. base *. 100.0)
    | None -> None
  in
  
  [{
    metric = CacheHitRate;
    value = hit_rate;
    unit = "ratio";
    baseline = baseline;
    improvement = improvement;
  }]

(** {1 内存使用测试} *)

(** 估算内存使用 *)
let benchmark_memory_usage () : benchmark_result list =
  let stats = Poetry_data_unified_consolidated.get_data_statistics () in
  let memory_bytes = float_of_int stats.memory_usage in
  
  let baseline = List.assoc_opt MemoryUsage performance_baselines in
  let improvement = 
    match baseline with
    | Some base -> Some ((base -. memory_bytes) /. base *. 100.0)
    | None -> None
  in
  
  [{
    metric = MemoryUsage;
    value = memory_bytes;
    unit = "bytes";
    baseline = baseline;
    improvement = improvement;
  }]

(** {1 数据加载性能测试} *)

(** 数据加载时间测试 *)
let benchmark_data_loading () : benchmark_result list =
  (* 清理缓存 *)
  Poetry_data_unified_consolidated.clear_data_cache ();
  
  (* 测量加载时间 *)
  let _, load_time = measure_time (fun () ->
    Poetry_data_unified_consolidated.load_data_to_cache ()
  ) in
  
  let baseline = List.assoc_opt DataLoadTime performance_baselines in
  let improvement = 
    match baseline with
    | Some base -> Some ((base -. load_time) /. base *. 100.0)
    | None -> None
  in
  
  [{
    metric = DataLoadTime;
    value = load_time;
    unit = "seconds"; 
    baseline = baseline;
    improvement = improvement;
  }]

(** {1 诗词评价性能测试} *)

(** 评价性能测试 *)
let benchmark_evaluation_performance (config: benchmark_config) : benchmark_result list =
  let test_poems = [
    ["春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"];
    ["床前明月光"; "疑是地上霜"; "举头望明月"; "低头思故乡"];
    ["白日依山尽"; "黄河入海流"; "欲穷千里目"; "更上一层楼"];
  ] in
  
  (* 预热 *)
  warmup_test config.warmup_iterations (fun () ->
    ignore (Poetry_unified_api_consolidated.evaluate_poem (List.hd test_poems))
  );
  
  (* 测试评价时间 *)
  let eval_time = run_repeated_test config.test_iterations (fun () ->
    List.iter (fun poem ->
      ignore (Poetry_unified_api_consolidated.evaluate_poem poem)
    ) test_poems
  ) in
  
  let avg_eval_time = eval_time /. float_of_int (List.length test_poems) in
  
  let baseline = List.assoc_opt EvaluationTime performance_baselines in
  let improvement = 
    match baseline with
    | Some base -> Some ((base -. avg_eval_time) /. base *. 100.0)
    | None -> None
  in
  
  [{
    metric = EvaluationTime;
    value = avg_eval_time;
    unit = "seconds";
    baseline = baseline;
    improvement = improvement;
  }]

(** {1 综合性能测试} *)

(** 运行完整的性能基准测试 *)
let run_comprehensive_benchmark ?(config = {
  test_iterations = 100;
  warmup_iterations = 10;
  test_data_size = 100;
  enable_cache = true;
}) () : performance_report =
  
  let start_time = Sys.time () in
  Printf.printf "Starting comprehensive performance benchmark...\\n";
  
  (* 确保系统已初始化 *)
  if not (Poetry_unified_api_consolidated.is_system_ready ()) then
    Poetry_unified_api_consolidated.initialize_poetry_system ();
  
  (* 运行各项性能测试 *)
  let query_results = benchmark_rhyme_query config in
  let cache_results = if config.enable_cache then benchmark_cache_performance config else [] in
  let memory_results = benchmark_memory_usage () in
  let loading_results = benchmark_data_loading () in
  let eval_results = benchmark_evaluation_performance config in
  
  let all_results = query_results @ cache_results @ memory_results @ loading_results @ eval_results in
  
  (* 分析瓶颈 *)
  let bottlenecks = List.filter_map (fun result ->
    match result.improvement with
    | Some improvement when improvement < 0.0 -> 
      Some (Printf.sprintf "%s performance is %.1f%% below baseline" 
        (match result.metric with
        | QueryTime -> "Query time"
        | CacheHitRate -> "Cache hit rate"
        | MemoryUsage -> "Memory usage"
        | DataLoadTime -> "Data loading"
        | EvaluationTime -> "Evaluation time")
        (abs_float improvement))
    | _ -> None
  ) all_results in
  
  (* 生成建议 *)
  let recommendations = 
    let slow_queries = List.exists (fun r -> r.metric = QueryTime && r.value > 0.005) all_results in
    let low_cache = List.exists (fun r -> r.metric = CacheHitRate && r.value < 0.7) all_results in
    let high_memory = List.exists (fun r -> r.metric = MemoryUsage && r.value > 2097152.0) all_results in
    
    let build_recommendations acc = function
      | [] -> acc
      | _ when slow_queries -> "优化韵律查询算法，考虑使用更高效的数据结构" :: acc
      | _ when low_cache -> "调整缓存策略，增加缓存容量或改进缓存算法" :: acc
      | _ when high_memory -> "优化内存使用，考虑延迟加载或数据压缩" :: acc
      | _ -> "性能表现良好，可考虑进一步优化细节" :: acc
    in
    build_recommendations [] [slow_queries; low_cache; high_memory]
  in
  
  let total_time = Sys.time () -. start_time in
  
  let report = {
    timestamp = start_time;
    total_runtime = total_time;
    benchmark_results = all_results;
    bottlenecks = bottlenecks;
    recommendations = recommendations;
  } in
  
  (* 保存到历史记录 *)
  performance_history := report :: !performance_history;
  current_stats := report;
  
  Printf.printf "Benchmark completed in %.3f seconds\\n" total_time;
  report

(** {1 性能分析工具} *)

(** 格式化基准测试结果 *)
let format_benchmark_result (result: benchmark_result) : string =
  let improvement_str = 
    match result.improvement with
    | Some imp when imp > 0.0 -> Printf.sprintf " (↑%.1f%%)" imp
    | Some imp when imp < 0.0 -> Printf.sprintf " (↓%.1f%%)" (abs_float imp)
    | _ -> ""
  in
  
  let baseline_str = 
    match result.baseline with
    | Some base -> Printf.sprintf " [baseline: %.6f]" base
    | None -> ""
  in
  
  Printf.sprintf "%s: %.6f %s%s%s"
    (match result.metric with
    | QueryTime -> "平均查询时间"
    | CacheHitRate -> "缓存命中率"
    | MemoryUsage -> "内存使用"
    | DataLoadTime -> "数据加载时间"
    | EvaluationTime -> "评价时间")
    result.value
    result.unit
    improvement_str
    baseline_str

(** 生成性能报告 *)
let generate_performance_report (report: performance_report) : string =
  let results_str = List.map format_benchmark_result report.benchmark_results in
  let bottlenecks_str = 
    if List.length report.bottlenecks > 0 then
      "\\n🚨 发现的性能瓶颈:\\n" ^ String.concat "\\n" (List.map (fun s -> "- " ^ s) report.bottlenecks)
    else "\\n✅ 未发现明显性能瓶颈"
  in
  let recommendations_str = 
    if List.length report.recommendations > 0 then
      "\\n💡 优化建议:\\n" ^ String.concat "\\n" (List.map (fun s -> "- " ^ s) report.recommendations)
    else ""
  in
  
  Printf.sprintf 
    "=== Poetry Performance Report ===\\n\
     测试时间: %.3f秒\\n\
     测试结果:\\n%s%s%s\\n\
     =================================="
    report.total_runtime
    (String.concat "\\n" results_str)
    bottlenecks_str
    recommendations_str

(** 打印当前性能报告 *)
let print_current_performance_report () : unit =
  let report = generate_performance_report !current_stats in
  print_endline report

(** {1 性能对比分析} *)

(** 比较两个性能报告 *)
let compare_performance_reports (old_report: performance_report) (new_report: performance_report) : string =
  let comparisons = List.map2 (fun old_result new_result ->
    let change = new_result.value -. old_result.value in
    let change_percent = 
      if old_result.value <> 0.0 then
        change /. old_result.value *. 100.0
      else 0.0
    in
    
    let trend = 
      if abs_float change_percent < 1.0 then "→"
      else if change_percent > 0.0 then "↑"
      else "↓"
    in
    
    Printf.sprintf "%s: %s %.1f%%"
      (format_benchmark_result new_result)
      trend
      (abs_float change_percent)
  ) old_report.benchmark_results new_report.benchmark_results in
  
  String.concat "\\n" comparisons

(** {1 导出接口} *)

(** 获取当前性能统计 *)
let get_current_performance_stats () = !current_stats

(** 获取性能历史记录 *)
let get_performance_history () = !performance_history

(** 清理性能历史 *)
let clear_performance_history () = 
  performance_history := []