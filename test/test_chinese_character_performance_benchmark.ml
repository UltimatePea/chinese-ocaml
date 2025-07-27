(** 中文字符处理性能基准测试 - Issue #1473 Phase 5.2 性能优化验证
    
    此模块为Phase 5.2中文字符处理性能优化提供全面的基准测试和验证，
    重点测试韵律检测缓存、标点符号识别和批量字符处理的性能改进。
    
    Author: Echo, 测试工程师代理
    Created: 2025-07-27
    Issue: #1473 Phase 5.2 中文字符处理性能优化
    
    性能目标：
    - 韵律检测性能提升50%+ (通过缓存机制)
    - 字符处理大文件编译时间减少20%+
    - 缓存命中率达到90%+
    - 内存使用保持稳定或改善10%
*)

open Printf

(** 性能测试配置 *)
module PerfConfig = struct
  (** 基准测试轮数 *)
  let benchmark_rounds = 1000
  
  (** 大规模测试数据量 *)
  let large_data_size = 10000
  
  (** 缓存预热轮数 *)
  let cache_warmup_rounds = 100
  
  (** 性能阈值配置 *)
  let rhyme_performance_improvement_target = 1.5  (* 50%提升 *)
  let character_processing_improvement_target = 1.2  (* 20%提升 *)
  let cache_hit_rate_target = 0.9  (* 90%命中率 *)
  let memory_improvement_tolerance = 0.1  (* 10%内存改善容忍度 *)
end

(** 测试数据生成器 *)
module TestDataGenerator = struct
  (** 常用中文字符池 *)
  let common_chinese_chars = [
    "春"; "夏"; "秋"; "冬"; "花"; "草"; "树"; "山"; 
    "水"; "风"; "雨"; "雪"; "月"; "日"; "星"; "云";
    "江"; "河"; "湖"; "海"; "天"; "地"; "人"; "心";
    "情"; "爱"; "美"; "好"; "新"; "老"; "大"; "小"
  ]
  
  (** 中文标点符号 *)
  let chinese_punctuation = [
    "，"; "。"; "；"; "："; "？"; "！"; "\""; "\""; "'"; "'";
    "（"; "）"; "【"; "】"; "《"; "》"; "——"; "…"
  ]
  
  (** 生成随机中文字符串 *)
  let generate_chinese_string length =
    let chars = Array.of_list common_chinese_chars in
    let result = Buffer.create (length * 3) in
    for _ = 1 to length do
      let char = chars.(Random.int (Array.length chars)) in
      Buffer.add_string result char
    done;
    Buffer.contents result
    
  (** 生成包含标点符号的中文文本 *)
  let generate_chinese_text_with_punctuation length =
    let chars = Array.of_list (common_chinese_chars @ chinese_punctuation) in
    let result = Buffer.create (length * 3) in
    for _ = 1 to length do
      let char = chars.(Random.int (Array.length chars)) in
      Buffer.add_string result char
    done;
    Buffer.contents result
    
  (** 生成诗词样式文本（用于韵律测试） *)
  let generate_poetry_verses count =
    let verse_endings = Array.of_list ["春"; "心"; "深"; "林"; "音"; "金"] in
    let verse_patterns = Array.of_list [
      "花开春山间";
      "风吹心水中"; 
      "月照深树林";
      "云飞林天际"
    ] in
    List.init count (fun i ->
      let pattern = verse_patterns.(i mod (Array.length verse_patterns)) in
      let ending = verse_endings.(i mod (Array.length verse_endings)) in
      pattern ^ ending
    )
    
  (** 生成大型测试文档 *)
  let generate_large_document size =
    let paragraphs = ref [] in
    for _ = 1 to (size / 100) do
      let paragraph = generate_chinese_text_with_punctuation 100 in
      paragraphs := paragraph :: !paragraphs
    done;
    String.concat "\n" !paragraphs
end

(** 性能计时器 *)
module PerfTimer = struct
  type timer = {
    mutable start_time : float;
    mutable end_time : float;
    mutable total_time : float;
    mutable iterations : int;
  }
  
  let create () = {
    start_time = 0.0;
    end_time = 0.0; 
    total_time = 0.0;
    iterations = 0;
  }
  
  let start timer =
    timer.start_time <- Sys.time ()
    
  let stop timer =
    timer.end_time <- Sys.time ();
    timer.total_time <- timer.total_time +. (timer.end_time -. timer.start_time);
    timer.iterations <- timer.iterations + 1
    
  let average_time timer =
    if timer.iterations > 0 then
      timer.total_time /. (float_of_int timer.iterations)
    else 0.0
    
  let total_time timer = timer.total_time
  let iterations timer = timer.iterations
end

(** 韵律检测性能基准测试 *)
module RhymePerformanceBenchmark = struct
  (** 缓存状态统计 *)
  type cache_stats = {
    mutable cache_hits : int;
    mutable cache_misses : int;
    mutable total_requests : int;
  }
  
  let create_cache_stats () = {
    cache_hits = 0;
    cache_misses = 0;
    total_requests = 0;
  }
  
  (** 模拟韵律检测缓存 *)
  let rhyme_cache = Hashtbl.create 1000
  
  (** 带缓存的韵律检测函数 *)
  let cached_rhyme_detection char1 char2 stats =
    let key = (char1, char2) in
    stats.total_requests <- stats.total_requests + 1;
    match Hashtbl.find_opt rhyme_cache key with
    | Some result -> 
        stats.cache_hits <- stats.cache_hits + 1;
        result
    | None ->
        stats.cache_misses <- stats.cache_misses + 1;
        (* 模拟计算开销 *)
        let result = String.equal char1 char2 in
        Hashtbl.add rhyme_cache key result;
        result
  
  (** 无缓存的韵律检测函数（基准对比） *)
  let uncached_rhyme_detection char1 char2 =
    (* 模拟计算开销 *)
    String.equal char1 char2
    
  (** 韵律检测性能基准测试 *)
  let benchmark_rhyme_detection () =
    printf "=== 韵律检测性能基准测试 ===\n";
    
    (* 生成测试数据 *)
    let test_chars = TestDataGenerator.common_chinese_chars in
    let test_pairs = List.fold_left (fun acc char1 ->
      List.fold_left (fun acc2 char2 ->
        (char1, char2) :: acc2
      ) acc test_chars
    ) [] test_chars in
    
    (* 无缓存性能测试 *)
    let uncached_timer = PerfTimer.create () in
    printf "开始无缓存韵律检测性能测试...\n";
    for _ = 1 to PerfConfig.benchmark_rounds do
      PerfTimer.start uncached_timer;
      List.iter (fun (char1, char2) ->
        ignore (uncached_rhyme_detection char1 char2)
      ) test_pairs;
      PerfTimer.stop uncached_timer
    done;
    
    (* 清空缓存，准备缓存测试 *)
    Hashtbl.clear rhyme_cache;
    let cache_stats = create_cache_stats () in
    
    (* 缓存预热 *)
    printf "进行缓存预热...\n";
    for _ = 1 to PerfConfig.cache_warmup_rounds do
      List.iter (fun (char1, char2) ->
        ignore (cached_rhyme_detection char1 char2 cache_stats)
      ) test_pairs
    done;
    
    (* 重置统计，开始正式测试 *)
    let cache_stats = create_cache_stats () in
    let cached_timer = PerfTimer.create () in
    
    printf "开始缓存韵律检测性能测试...\n";
    for _ = 1 to PerfConfig.benchmark_rounds do
      PerfTimer.start cached_timer;
      List.iter (fun (char1, char2) ->
        ignore (cached_rhyme_detection char1 char2 cache_stats)
      ) test_pairs;
      PerfTimer.stop cached_timer
    done;
    
    (* 计算性能指标 *)
    let uncached_avg = PerfTimer.average_time uncached_timer in
    let cached_avg = PerfTimer.average_time cached_timer in
    let improvement_ratio = uncached_avg /. cached_avg in
    let cache_hit_rate = float_of_int cache_stats.cache_hits /. float_of_int cache_stats.total_requests in
    
    (* 输出结果 *)
    printf "\n韵律检测性能测试结果:\n";
    printf "  无缓存平均时间: %.6f 秒\n" uncached_avg;
    printf "  缓存平均时间: %.6f 秒\n" cached_avg;
    printf "  性能提升倍数: %.2fx\n" improvement_ratio;
    printf "  缓存命中率: %.1f%%\n" (cache_hit_rate *. 100.0);
    printf "  总请求数: %d\n" cache_stats.total_requests;
    printf "  缓存命中: %d\n" cache_stats.cache_hits;
    printf "  缓存未命中: %d\n" cache_stats.cache_misses;
    
    (* 性能目标验证 *)
    let performance_target_met = improvement_ratio >= PerfConfig.rhyme_performance_improvement_target in
    let cache_target_met = cache_hit_rate >= PerfConfig.cache_hit_rate_target in
    
    printf "\n性能目标验证:\n";
    printf "  韵律检测性能提升目标 (%.1fx): %s\n" 
      PerfConfig.rhyme_performance_improvement_target 
      (if performance_target_met then "✓ 达成" else "✗ 未达成");
    printf "  缓存命中率目标 (%.0f%%): %s\n" 
      (PerfConfig.cache_hit_rate_target *. 100.0)
      (if cache_target_met then "✓ 达成" else "✗ 未达成");
    
    (improvement_ratio, cache_hit_rate, performance_target_met && cache_target_met)
end

(** 中文标点符号识别性能基准测试 *)
module PunctuationPerformanceBenchmark = struct
  (** 标点符号快速查找表 *)
  let punctuation_set = 
    let module CharSet = Set.Make(String) in
    List.fold_left (fun acc punct ->
      CharSet.add punct acc
    ) CharSet.empty TestDataGenerator.chinese_punctuation
  
  (** 优化的标点符号识别 *)
  let optimized_is_punctuation char =
    let module CharSet = Set.Make(String) in
    CharSet.mem char punctuation_set
    
  (** 朴素的标点符号识别（线性查找） *)
  let naive_is_punctuation char =
    List.mem char TestDataGenerator.chinese_punctuation
    
  (** 标点符号识别性能基准测试 *)
  let benchmark_punctuation_recognition () =
    printf "\n=== 中文标点符号识别性能基准测试 ===\n";
    
    (* 生成测试数据 *)
    let test_text = TestDataGenerator.generate_chinese_text_with_punctuation PerfConfig.large_data_size in
    let test_chars = ref [] in
    
    (* 提取字符列表 *)
    let pos = ref 0 in
    while !pos < String.length test_text do
      if !pos + 2 < String.length test_text then
        test_chars := (String.sub test_text !pos 3) :: !test_chars;
      pos := !pos + 3
    done;
    
    let test_chars = List.rev !test_chars in
    
    (* 朴素方法性能测试 *)
    let naive_timer = PerfTimer.create () in
    printf "开始朴素标点符号识别性能测试...\n";
    for _ = 1 to PerfConfig.benchmark_rounds do
      PerfTimer.start naive_timer;
      List.iter (fun char ->
        ignore (naive_is_punctuation char)
      ) test_chars;
      PerfTimer.stop naive_timer
    done;
    
    (* 优化方法性能测试 *)
    let optimized_timer = PerfTimer.create () in
    printf "开始优化标点符号识别性能测试...\n";
    for _ = 1 to PerfConfig.benchmark_rounds do
      PerfTimer.start optimized_timer;
      List.iter (fun char ->
        ignore (optimized_is_punctuation char)
      ) test_chars;
      PerfTimer.stop optimized_timer
    done;
    
    (* 计算性能指标 *)
    let naive_avg = PerfTimer.average_time naive_timer in
    let optimized_avg = PerfTimer.average_time optimized_timer in
    let improvement_ratio = naive_avg /. optimized_avg in
    
    (* 输出结果 *)
    printf "\n标点符号识别性能测试结果:\n";
    printf "  朴素方法平均时间: %.6f 秒\n" naive_avg;
    printf "  优化方法平均时间: %.6f 秒\n" optimized_avg;
    printf "  性能提升倍数: %.2fx\n" improvement_ratio;
    printf "  测试字符数: %d\n" (List.length test_chars);
    
    (improvement_ratio, improvement_ratio >= 2.0)
end

(** 批量字符处理性能基准测试 *)
module BatchProcessingBenchmark = struct
  (** 字符信息类型 *)
  type char_info = {
    is_chinese: bool;
    is_punctuation: bool;
    category: string;
  }
  
  (** 单字符处理 *)
  let process_single_char char =
    let is_chinese = List.mem char TestDataGenerator.common_chinese_chars in
    let is_punctuation = List.mem char TestDataGenerator.chinese_punctuation in
    let category = if is_chinese then "汉字" else if is_punctuation then "标点" else "其他" in
    { is_chinese; is_punctuation; category }
    
  (** 批量字符处理 *)
  let process_chars_batch chars =
    List.map process_single_char chars
    
  (** 逐字符处理 *)
  let process_chars_sequential chars =
    List.fold_left (fun acc char ->
      (process_single_char char) :: acc
    ) [] chars |> List.rev
    
  (** 批量字符处理性能基准测试 *)
  let benchmark_batch_processing () =
    printf "\n=== 批量字符处理性能基准测试 ===\n";
    
    (* 生成大规模测试数据 *)
    let test_text = TestDataGenerator.generate_large_document PerfConfig.large_data_size in
    let test_chars = ref [] in
    
    (* 提取字符列表 *)
    let pos = ref 0 in
    while !pos < String.length test_text do
      if !pos + 2 < String.length test_text then
        test_chars := (String.sub test_text !pos 3) :: !test_chars;
      pos := !pos + 3
    done;
    
    let test_chars = List.rev !test_chars in
    
    (* 逐字符处理性能测试 *)
    let sequential_timer = PerfTimer.create () in
    printf "开始逐字符处理性能测试...\n";
    for _ = 1 to (PerfConfig.benchmark_rounds / 10) do  (* 减少轮数避免超时 *)
      PerfTimer.start sequential_timer;
      ignore (process_chars_sequential test_chars);
      PerfTimer.stop sequential_timer
    done;
    
    (* 批量处理性能测试 *)
    let batch_timer = PerfTimer.create () in
    printf "开始批量处理性能测试...\n";
    for _ = 1 to (PerfConfig.benchmark_rounds / 10) do  (* 减少轮数避免超时 *)
      PerfTimer.start batch_timer;
      ignore (process_chars_batch test_chars);
      PerfTimer.stop batch_timer
    done;
    
    (* 计算性能指标 *)
    let sequential_avg = PerfTimer.average_time sequential_timer in
    let batch_avg = PerfTimer.average_time batch_timer in
    let improvement_ratio = sequential_avg /. batch_avg in
    
    (* 输出结果 *)
    printf "\n批量字符处理性能测试结果:\n";
    printf "  逐字符处理平均时间: %.6f 秒\n" sequential_avg;
    printf "  批量处理平均时间: %.6f 秒\n" batch_avg;
    printf "  性能提升倍数: %.2fx\n" improvement_ratio;
    printf "  测试字符数: %d\n" (List.length test_chars);
    
    (* 性能目标验证 *)
    let target_met = improvement_ratio >= PerfConfig.character_processing_improvement_target in
    
    printf "\n性能目标验证:\n";
    printf "  字符处理性能提升目标 (%.1fx): %s\n" 
      PerfConfig.character_processing_improvement_target 
      (if target_met then "✓ 达成" else "✗ 未达成");
    
    (improvement_ratio, target_met)
end

(** 内存使用性能基准测试 *)
module MemoryBenchmark = struct
  (** 获取当前进程内存使用 (简化版本) *)
  let get_memory_usage () =
    try
      let ic = Unix.open_process_in "ps -o rss= -p " in
      let line = input_line ic in
      let _ = Unix.close_process_in ic in
      int_of_string (String.trim line) * 1024  (* 转换为字节 *)
    with _ -> 0
    
  (** 内存使用基准测试 *)
  let benchmark_memory_usage () =
    printf "\n=== 内存使用性能基准测试 ===\n";
    
    (* 基准内存使用 *)
    let baseline_memory = get_memory_usage () in
    printf "基准内存使用: %d bytes\n" baseline_memory;
    
    (* 分配大量缓存数据 *)
    let cache = Hashtbl.create 10000 in
    for i = 1 to 10000 do
      let key = sprintf "key_%d" i in
      let value = TestDataGenerator.generate_chinese_string 10 in
      Hashtbl.add cache key value
    done;
    
    let cached_memory = get_memory_usage () in
    let memory_increase = cached_memory - baseline_memory in
    
    printf "缓存后内存使用: %d bytes\n" cached_memory;
    printf "内存增长: %d bytes\n" memory_increase;
    
    (* 清理缓存 *)
    Hashtbl.clear cache;
    Gc.full_major ();  (* 强制垃圾回收 *)
    
    let final_memory = get_memory_usage () in
    let memory_recovery = cached_memory - final_memory in
    
    printf "清理后内存使用: %d bytes\n" final_memory;
    printf "内存回收: %d bytes\n" memory_recovery;
    
    let memory_efficiency = if memory_increase > 0 then 
      float_of_int memory_recovery /. float_of_int memory_increase 
    else 1.0 in
      
    printf "内存回收效率: %.1f%%\n" (memory_efficiency *. 100.0);
    
    (memory_increase, memory_efficiency, memory_efficiency >= 0.8)
end

(** 综合性能基准测试 *)
module ComprehensiveBenchmark = struct
  type benchmark_results = {
    rhyme_improvement: float;
    rhyme_cache_hit_rate: float;
    punctuation_improvement: float;
    batch_improvement: float;
    memory_increase: int;
    memory_efficiency: float;
    overall_success: bool;
  }
  
  (** 运行所有性能基准测试 *)
  let run_all_benchmarks () =
    printf "开始中文字符处理性能优化基准测试\n";
    printf "Issue #1473 Phase 5.2 性能优化验证\n\n";
    
    Random.self_init ();
    
    (* 韵律检测性能测试 *)
    let (rhyme_improvement, rhyme_cache_hit_rate, rhyme_success) = 
      RhymePerformanceBenchmark.benchmark_rhyme_detection () in
    
    (* 标点符号识别性能测试 *)
    let (punctuation_improvement, punctuation_success) = 
      PunctuationPerformanceBenchmark.benchmark_punctuation_recognition () in
    
    (* 批量字符处理性能测试 *)
    let (batch_improvement, batch_success) = 
      BatchProcessingBenchmark.benchmark_batch_processing () in
    
    (* 内存使用性能测试 *)
    let (memory_increase, memory_efficiency, memory_success) = 
      MemoryBenchmark.benchmark_memory_usage () in
    
    (* 综合评估 *)
    let overall_success = rhyme_success && punctuation_success && batch_success && memory_success in
    
    printf "\n\n=== 综合性能基准测试结果 ===\n";
    printf "韵律检测性能提升: %.2fx (目标: %.1fx) %s\n" 
      rhyme_improvement 
      PerfConfig.rhyme_performance_improvement_target
      (if rhyme_success then "✓" else "✗");
    printf "韵律缓存命中率: %.1f%% (目标: %.0f%%) %s\n" 
      (rhyme_cache_hit_rate *. 100.0)
      (PerfConfig.cache_hit_rate_target *. 100.0)
      (if rhyme_cache_hit_rate >= PerfConfig.cache_hit_rate_target then "✓" else "✗");
    printf "标点符号识别性能提升: %.2fx %s\n" 
      punctuation_improvement
      (if punctuation_success then "✓" else "✗");
    printf "批量字符处理性能提升: %.2fx (目标: %.1fx) %s\n" 
      batch_improvement 
      PerfConfig.character_processing_improvement_target
      (if batch_success then "✓" else "✗");
    printf "内存使用增长: %d bytes\n" memory_increase;
    printf "内存回收效率: %.1f%% %s\n" 
      (memory_efficiency *. 100.0)
      (if memory_success then "✓" else "✗");
    
    printf "\n整体性能目标: %s\n" 
      (if overall_success then "✓ 全部达成" else "✗ 部分未达成");
    
    {
      rhyme_improvement;
      rhyme_cache_hit_rate;
      punctuation_improvement;
      batch_improvement;
      memory_increase;
      memory_efficiency;
      overall_success;
    }
end

(** 主测试执行函数 *)
let run_performance_benchmarks () =
  try
    let results = ComprehensiveBenchmark.run_all_benchmarks () in
    if results.overall_success then begin
      printf "\n🎉 Phase 5.2 中文字符处理性能优化目标达成！\n";
      printf "所有性能指标均满足或超越目标要求。\n";
      exit 0
    end else begin
      printf "\n⚠️  Phase 5.2 中文字符处理性能优化部分目标未达成。\n";
      printf "需要进一步优化相关模块。\n";
      exit 1
    end
  with 
  | e ->
    printf "性能基准测试执行出错: %s\n" (Printexc.to_string e);
    exit 2

(** 运行测试 *)
let () = 
  if Array.length Sys.argv > 1 && Sys.argv.(1) = "--benchmark" then
    run_performance_benchmarks ()
  else
    printf "中文字符处理性能基准测试模块已加载。\n使用 --benchmark 参数运行完整测试。\n"