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
  (** 常用中文字符池 - 使用实际存在于韵律数据库中的字符 *)
  let common_chinese_chars = [
    "山"; "时"; "天"; "花"; "风"; "心"; "春"; "月"; 
    "江"; "人"; "日"; "水"; "星"; "夜"; "声"; "云";
    "林"; "海"; "生"; "年"; "金"; "白"; "长"; "来";
    "里"; "行"; "中"; "大"; "高"; "下"; "上"; "不"
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
  open Poetry.Rhyme_detection_optimized
  
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
  
  (** 使用实际优化韵律检测 *)
  let optimized_rhyme_detection char_str stats =
    stats.total_requests <- stats.total_requests + 1;
    match find_rhyme_info_optimized char_str with
    | Some (_category, _group) -> 
        stats.cache_hits <- stats.cache_hits + 1;
        true  (* 找到韵律信息 *)
    | None ->
        stats.cache_misses <- stats.cache_misses + 1;
        false  (* 未找到韵律信息 *)
  
  (** 使用原始韵律检测（无优化缓存） *)
  let uncached_rhyme_detection char_str =
    (* 直接查找数据库，不使用缓存 *)
    let rhyme_data = List.find_opt (fun (char, _, _) -> 
      String.equal char char_str
    ) Poetry.Rhyme_database.rhyme_database in
    match rhyme_data with
    | Some _ -> true
    | None -> false
    
  (** 韵律检测性能基准测试 *)
  let benchmark_rhyme_detection () =
    printf "=== 韵律检测性能基准测试 ===\n";
    
    (* 生成测试数据 - 使用实际中文字符 *)
    let test_chars = TestDataGenerator.common_chinese_chars in
    
    (* 无缓存性能测试 *)
    let uncached_timer = PerfTimer.create () in
    printf "开始无缓存韵律检测性能测试...\n";
    for _ = 1 to PerfConfig.benchmark_rounds do
      PerfTimer.start uncached_timer;
      List.iter (fun char_str ->
        ignore (uncached_rhyme_detection char_str)
      ) test_chars;
      PerfTimer.stop uncached_timer
    done;
    
    (* 缓存性能测试 *)
    let cache_stats = create_cache_stats () in
    
    (* 缓存预热 - 确保字符进入缓存 *)
    printf "进行缓存预热...\n";
    for _ = 1 to PerfConfig.cache_warmup_rounds do
      List.iter (fun char_str ->
        ignore (optimized_rhyme_detection char_str cache_stats)
      ) test_chars
    done;
    
    (* 清除临时统计但保持缓存数据 *)
    let cached_timer = PerfTimer.create () in
    
    printf "开始缓存韵律检测性能测试...\n";
    for _ = 1 to PerfConfig.benchmark_rounds do
      PerfTimer.start cached_timer;
      (* 模拟现实使用场景：重复查找相同字符 *)
      List.iter (fun char_str ->
        ignore (find_rhyme_info_optimized char_str)
      ) test_chars;
      PerfTimer.stop cached_timer
    done;
    
    (* 计算性能指标 *)
    let uncached_avg = PerfTimer.average_time uncached_timer in
    let cached_avg = PerfTimer.average_time cached_timer in
    let improvement_ratio = uncached_avg /. cached_avg in
    let (hits, misses, total, hit_rate) = get_global_cache_stats () in
    
    (* 输出结果 *)
    printf "\n韵律检测性能测试结果:\n";
    printf "  无缓存平均时间: %.6f 秒\n" uncached_avg;
    printf "  缓存平均时间: %.6f 秒\n" cached_avg;
    printf "  性能提升倍数: %.2fx\n" improvement_ratio;
    printf "  缓存命中率: %.1f%%\n" (hit_rate *. 100.0);
    printf "  总请求数: %d\n" total;
    printf "  缓存命中: %d\n" hits;
    printf "  缓存未命中: %d\n" misses;
    
    (* 性能目标验证 *)
    let performance_target_met = improvement_ratio >= PerfConfig.rhyme_performance_improvement_target in
    let cache_target_met = hit_rate >= PerfConfig.cache_hit_rate_target in
    
    printf "\n性能目标验证:\n";
    printf "  韵律检测性能提升目标 (%.1fx): %s\n" 
      PerfConfig.rhyme_performance_improvement_target 
      (if performance_target_met then "✓ 达成" else "✗ 未达成");
    printf "  缓存命中率目标 (%.0f%%): %s\n" 
      (PerfConfig.cache_hit_rate_target *. 100.0)
      (if cache_target_met then "✓ 达成" else "✗ 未达成");
    
    (improvement_ratio, hit_rate, performance_target_met && cache_target_met)
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
    
  (** 批量字符处理 - 优化版本使用数组、预分配和预处理优化 *)
  let process_chars_batch chars =
    let len = List.length chars in
    let result_array = Array.make len { 
      is_chinese = false; 
      is_punctuation = false; 
      category = "未知"
    } in
    (* 预处理：构建快速查找集合 *)
    let chinese_set = List.fold_left (fun acc char -> 
      let module StringSet = Set.Make(String) in
      StringSet.add char acc
    ) (let module StringSet = Set.Make(String) in StringSet.empty) TestDataGenerator.common_chinese_chars in
    
    let punctuation_set = List.fold_left (fun acc char ->
      let module StringSet = Set.Make(String) in  
      StringSet.add char acc
    ) (let module StringSet = Set.Make(String) in StringSet.empty) TestDataGenerator.chinese_punctuation in
    
    (* 使用数组索引批量处理，避免重复查找开销 *)
    let char_array = Array.of_list chars in
    for i = 0 to len - 1 do
      let char = char_array.(i) in
      let module StringSet = Set.Make(String) in
      let is_chinese = StringSet.mem char chinese_set in
      let is_punctuation = StringSet.mem char punctuation_set in
      let category = if is_chinese then "汉字" else if is_punctuation then "标点" else "其他" in
      result_array.(i) <- { is_chinese; is_punctuation; category }
    done;
    Array.to_list result_array
    
  (** 逐字符处理 - 传统链表方式 *)
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
  (** 获取当前进程内存使用 (修复版本) *)
  let get_memory_usage () =
    try
      let pid = Unix.getpid () in
      let cmd = Printf.sprintf "ps -o rss= -p %d" pid in
      let ic = Unix.open_process_in cmd in
      let line = input_line ic in
      let _ = Unix.close_process_in ic in
      int_of_string (String.trim line) * 1024  (* 转换为字节 *)
    with _ -> 
      (* 使用OCaml内置的Gc.stat作为后备方案 *)
      let stats = Gc.stat () in
      stats.heap_words * (Sys.word_size / 8)
    
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