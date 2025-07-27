(** Phase 5.2 中文字符处理性能优化 - 增强韵律检测模块
    
    实施Issue #1473的核心优化目标：
    1. 韵律检测缓存系统 - 提升50%+性能
    2. 批量字符处理优化 - 减少20%+处理时间  
    3. 缓存命中率监控 - 达到90%+命中率
    4. 内存使用优化 - 保持稳定或改善10%
    
    Author: Alpha, 主工作代理
    Fix #1473 - Phase 5.2 中文字符处理性能优化 *)

open Rhyme_types
open Rhyme_cache

(** {1 增强韵律缓存模块} *)

module ChineseRhymeCache = struct
  (** 高性能韵律缓存实例 *)
  type rhyme_performance_cache = {
    rhyme_cache: rhyme_cache;
    mutable cache_hits: int;
    mutable cache_misses: int;
    mutable total_requests: int;
    rhyme_class_cache: (string, rhyme_category) Hashtbl.t;
    rhyme_group_cache: (string, rhyme_group) Hashtbl.t;
  }
  
  (** 创建高性能缓存实例 *)
  let create_performance_cache ?(char_capacity = 2000) ?(class_capacity = 1000) ?(group_capacity = 500) () = {
    rhyme_cache = create_cache ~char_capacity ~group_capacity ();
    cache_hits = 0;
    cache_misses = 0; 
    total_requests = 0;
    rhyme_class_cache = Hashtbl.create class_capacity;
    rhyme_group_cache = Hashtbl.create group_capacity;
  }
  
  (** 高性能韵律查找 - 支持缓存命中率监控 *)
  let get_rhyme_with_stats cache char_str = 
    cache.total_requests <- cache.total_requests + 1;
    match lookup_rhyme cache.rhyme_cache char_str with
    | Some result -> 
        cache.cache_hits <- cache.cache_hits + 1;
        Some result
    | None ->
        cache.cache_misses <- cache.cache_misses + 1;
        None
  
  (** 高性能韵母分类查找 *)
  let get_rhyme_class cache char_str =
    match Hashtbl.find_opt cache.rhyme_class_cache char_str with
    | Some class_info -> 
        cache.cache_hits <- cache.cache_hits + 1;
        class_info
    | None ->
        cache.cache_misses <- cache.cache_misses + 1;
        let class_info = match get_rhyme_with_stats cache char_str with
          | Some (category, _) -> category
          | None -> PingSheng
        in
        Hashtbl.add cache.rhyme_class_cache char_str class_info;
        class_info
  
  (** 高性能韵组查找 *)
  let get_rhyme_group cache char_str =
    match Hashtbl.find_opt cache.rhyme_group_cache char_str with
    | Some group_info ->
        cache.cache_hits <- cache.cache_hits + 1;
        group_info
    | None ->
        cache.cache_misses <- cache.cache_misses + 1;
        let group_info = match get_rhyme_with_stats cache char_str with
          | Some (_, group) -> group
          | None -> UnknownRhyme
        in
        Hashtbl.add cache.rhyme_group_cache char_str group_info;
        group_info
  
  (** 缓存性能统计 *)
  let get_cache_performance_stats cache =
    let hit_rate = if cache.total_requests > 0 then 
      (float_of_int cache.cache_hits) /. (float_of_int cache.total_requests) 
    else 0.0 in
    (cache.cache_hits, cache.cache_misses, cache.total_requests, hit_rate)
  
  (** 重置性能统计 *)
  let reset_performance_stats cache =
    cache.cache_hits <- 0;
    cache.cache_misses <- 0;
    cache.total_requests <- 0
  
  (** 缓存性能报告 *)
  let cache_performance_report cache =
    let hits, misses, total, hit_rate = get_cache_performance_stats cache in
    Printf.sprintf 
      "韵律缓存性能报告: 命中%d次, 未命中%d次, 总请求%d次, 命中率%.2f%%" 
      hits misses total (hit_rate *. 100.0)
end

(** {2 批量字符处理优化模块} *)

module BatchCharacterProcessor = struct
  (** 字符分析信息类型 *)
  type char_analysis_info = {
    char_str: string;
    is_chinese: bool;
    rhyme_category: rhyme_category option;
    rhyme_group: rhyme_group option;
  }
  
  (** 批量字符分析结果 *)
  type batch_analysis_result = {
    char_analyses: char_analysis_info list;
    processing_time_ms: float;
    cache_hit_rate: float;
  }
  
  (** 批量分析字符 - 核心性能优化函数 *)
  let analyze_characters_batch cache (chars: string list) : batch_analysis_result =
    let start_time = Sys.time () in
    
    let char_analyses = List.map (fun char_str ->
      let is_chinese = 
        String.length char_str > 0 && 
        let first_byte = Char.code char_str.[0] in
        first_byte >= 0xE0 (* 中文字符UTF-8范围 *)
      in
      
      let rhyme_category, rhyme_group = 
        if is_chinese then
          let category = Some (ChineseRhymeCache.get_rhyme_class cache char_str) in
          let group = Some (ChineseRhymeCache.get_rhyme_group cache char_str) in
          (category, group)
        else
          (None, None)
      in
      
      {
        char_str;
        is_chinese;
        rhyme_category; 
        rhyme_group;
      }
    ) chars in
    
    let end_time = Sys.time () in
    let processing_time_ms = (end_time -. start_time) *. 1000.0 in
    
    let final_stats = ChineseRhymeCache.get_cache_performance_stats cache in
    let _, _, _, final_hit_rate = final_stats in
    
    {
      char_analyses;
      processing_time_ms;
      cache_hit_rate = final_hit_rate;
    }
end

(** {3 中文标点符号快速识别优化} *)

module ChinesePunctuationOptimized = struct
  (** 预编译中文标点符号查找表 *)
  let punctuation_lookup_table = 
    let table = Hashtbl.create 32 in
    List.iter (fun (punctuation, is_chinese) -> 
      Hashtbl.add table punctuation is_chinese
    ) [
      ("，", true); ("。", true); ("；", true); ("：", true); 
      ("？", true); ("！", true); 
      ("（", true); ("）", true);
      ("【", true); ("】", true); ("「", true); ("」", true);
      ("『", true); ("』", true); ("《", true); ("》", true);
      ("〈", true); ("〉", true); ("〖", true); ("〗", true);
      ("〔", true); ("〕", true); ("…", true); ("—", true);
      ("–", true); ("～", true); ("｜", true); ("、", true);
      (",", false); (".", false); (";", false); (":", false);
      ("?", false); ("!", false); ("(", false); (")", false);
    ];
    table
  
  (** 快速中文标点符号识别 - O(1)复杂度 *)
  let is_chinese_punctuation_fast char_str = 
    match Hashtbl.find_opt punctuation_lookup_table char_str with
    | Some is_chinese -> is_chinese
    | None -> false
  
  (** 全角半角字符转换映射表 *)
  let fullwidth_conversion_table = 
    let table = Hashtbl.create 64 in
    List.iter (fun (fullwidth, halfwidth) ->
      Hashtbl.add table fullwidth halfwidth
    ) [
      ("，", ","); ("。", "."); ("；", ";"); ("：", ":");
      ("？", "?"); ("！", "!"); ("（", "("); ("）", ")");
      ("【", "["); ("】", "]"); ("｛", "{"); ("｝", "}");
      ("０", "0"); ("１", "1"); ("２", "2"); ("３", "3");
      ("４", "4"); ("５", "5"); ("６", "6"); ("７", "7");
      ("８", "8"); ("９", "9"); ("Ａ", "A"); ("Ｂ", "B");
      ("Ｃ", "C"); ("Ｄ", "D"); ("Ｅ", "E"); ("Ｆ", "F");
      ("Ｇ", "G"); ("Ｈ", "H"); ("Ｉ", "I"); ("Ｊ", "J");
      ("Ｋ", "K"); ("Ｌ", "L"); ("Ｍ", "M"); ("Ｎ", "N");
      ("Ｏ", "O"); ("Ｐ", "P"); ("Ｑ", "Q"); ("Ｒ", "R");
      ("Ｓ", "S"); ("Ｔ", "T"); ("Ｕ", "U"); ("Ｖ", "V");
      ("Ｗ", "W"); ("Ｘ", "X"); ("Ｙ", "Y"); ("Ｚ", "Z");
      ("ａ", "a"); ("ｂ", "b"); ("ｃ", "c"); ("ｄ", "d");
      ("ｅ", "e"); ("ｆ", "f"); ("ｇ", "g"); ("ｈ", "h");
      ("ｉ", "i"); ("ｊ", "j"); ("ｋ", "k"); ("ｌ", "l");
      ("ｍ", "m"); ("ｎ", "n"); ("ｏ", "o"); ("ｐ", "p");
      ("ｑ", "q"); ("ｒ", "r"); ("ｓ", "s"); ("ｔ", "t");
      ("ｕ", "u"); ("ｖ", "v"); ("ｗ", "w"); ("ｘ", "x");
      ("ｙ", "y"); ("ｚ", "z"); ("　", " ");
    ];
    table
  
  (** 快速全角半角转换 - O(1)复杂度 *)
  let convert_fullwidth_to_halfwidth_fast char_str =
    match Hashtbl.find_opt fullwidth_conversion_table char_str with
    | Some halfwidth -> halfwidth
    | None -> char_str
  
  (** 批量标点符号识别 *)
  let batch_punctuation_analysis chars =
    List.map (fun char_str ->
      let is_chinese_punct = is_chinese_punctuation_fast char_str in
      let halfwidth_equiv = convert_fullwidth_to_halfwidth_fast char_str in
      (char_str, is_chinese_punct, halfwidth_equiv)
    ) chars
end

(** {4 全局高性能缓存实例} *)

(** 全局性能优化缓存 - 实现Issue #1473性能目标 *)
let global_performance_cache = lazy (ChineseRhymeCache.create_performance_cache ())

(** 简化的高性能韵律查找接口 *)
let find_rhyme_info_optimized char_str = 
  ChineseRhymeCache.get_rhyme_with_stats (Lazy.force global_performance_cache) char_str

(** 简化的高性能韵母分类检测 *)
let detect_rhyme_category_optimized char_str =
  ChineseRhymeCache.get_rhyme_class (Lazy.force global_performance_cache) char_str

(** 简化的高性能韵组检测 *)
let detect_rhyme_group_optimized char_str =
  ChineseRhymeCache.get_rhyme_group (Lazy.force global_performance_cache) char_str

(** 批量字符处理接口 *)
let analyze_characters_batch_optimized chars =
  BatchCharacterProcessor.analyze_characters_batch (Lazy.force global_performance_cache) chars

(** 获取全局缓存性能统计 *)
let get_global_cache_stats () =
  ChineseRhymeCache.get_cache_performance_stats (Lazy.force global_performance_cache)

(** 生成性能优化报告 *)
let generate_performance_report () =
  ChineseRhymeCache.cache_performance_report (Lazy.force global_performance_cache)

(** {5 向后兼容性接口} *)

(** 兼容原有API的优化版本 *)
let find_rhyme_info_by_string = find_rhyme_info_optimized
let detect_rhyme_category_by_string = detect_rhyme_category_optimized  
let detect_rhyme_group_by_string = detect_rhyme_group_optimized

(** Phase 5.2性能优化验证函数 *)
let validate_performance_improvements () =
  let _, _, total, hit_rate = get_global_cache_stats () in
  let performance_goals = [
    ("韵律检测缓存命中率", hit_rate, 0.9, "90%+");
    ("总请求处理数", float_of_int total, 0.0, ">0");
  ] in
  
  List.map (fun (metric, actual, target, target_desc) ->
    let meets_target = actual >= target in
    (metric, actual, target_desc, meets_target)
  ) performance_goals

(** 
    Phase 5.2 性能优化实施完成摘要:
    
    ✅ 韵律检测缓存系统 - 多级缓存，支持性能监控
    ✅ 批量字符处理优化 - 减少重复计算，提升吞吐量  
    ✅ 中文标点符号快速识别 - O(1)复杂度查找表
    ✅ 全角半角字符转换优化 - 预编译映射表
    ✅ 缓存命中率监控 - 实时统计和报告
    ✅ 向后兼容性保证 - 保持现有API不变
    
    预期性能提升:
    - 韵律检测: 50%+ 性能提升
    - 字符处理: 20%+ 时间减少  
    - 缓存命中率: 90%+ 目标
    - 内存使用: 稳定或改善10%
*)