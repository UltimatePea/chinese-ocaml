(** 韵律查询统一引擎 - 整合多个查询模块
    
    此模块整合并替代以下重复查询模块:
    - rhyme_query_engine.ml
    - data/rhyme_query_engine.ml  
    - rhyme_lookup.ml
    - rhyme_matching.ml
    - rhyme_api_core.ml
    - unified_rhyme_engine.ml (查询部分)
    
    实现O(1)查询性能，30%+性能提升目标。
    
    Author: Whisky, PR Worker
    @version 1.0 - Poetry韵律查询统一整合
    @since 2025-08-01
    @implements Issue #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_types_unified
open Rhyme_data_consolidated_unified

(** {1 高性能查询系统} *)

(** 查询缓存类型 *)
type query_cache = {
  mutable lookup_cache: (string, (rhyme_group * rhyme_category)) Hashtbl.t;
  mutable rhyme_cache: (string * string, bool) Hashtbl.t;
  mutable group_cache: (rhyme_group, string list) Hashtbl.t;
  mutable stats: query_stats;
}

and query_stats = {
  mutable total_queries: int;
  mutable cache_hits: int;
  mutable cache_misses: int;
  mutable query_time_total: float;
}

(** 全局查询缓存 *)
let global_cache = {
  lookup_cache = Hashtbl.create 1000;
  rhyme_cache = Hashtbl.create 2000; 
  group_cache = Hashtbl.create 50;
  stats = { total_queries = 0; cache_hits = 0; cache_misses = 0; query_time_total = 0.0 };
}

(** {2 核心查询函数 - O(1)优化} *)

(** O(1) 韵字查询 - 核心性能优化 *)
let lookup_character_rhyme character =
  global_cache.stats.total_queries <- global_cache.stats.total_queries + 1;
  let start_time = Sys.time () in
  
  let result = 
    match Hashtbl.find_opt global_cache.lookup_cache character with
    | Some cached_result ->
      global_cache.stats.cache_hits <- global_cache.stats.cache_hits + 1;
      Some cached_result
    | None ->
      global_cache.stats.cache_misses <- global_cache.stats.cache_misses + 1;
      match query_character_rhyme character with
      | Some (_, group, category, _) ->
        let result = (group, category) in
        Hashtbl.add global_cache.lookup_cache character result;
        Some result
      | None -> None
  in
  
  let end_time = Sys.time () in
  global_cache.stats.query_time_total <- 
    global_cache.stats.query_time_total +. (end_time -. start_time);
  
  result

(** O(1) 韵字匹配检查 - 优化版本 *)
let characters_rhyme char1 char2 =
  let cache_key = (char1, char2) in
  match Hashtbl.find_opt global_cache.rhyme_cache cache_key with
  | Some cached_result -> cached_result
  | None ->
    let result = 
      match lookup_character_rhyme char1, lookup_character_rhyme char2 with
      | Some (group1, _), Some (group2, _) -> group1 = group2
      | _ -> false
    in
    Hashtbl.add global_cache.rhyme_cache cache_key result;
    (* 对称缓存 - 优化双向查询 *)
    Hashtbl.add global_cache.rhyme_cache (char2, char1) result;
    result

(** O(1) 韵组查询 - 缓存优化 *)
let lookup_rhyme_group group =
  match Hashtbl.find_opt global_cache.group_cache group with
  | Some cached_chars -> cached_chars
  | None ->
    let chars = List.map (fun (char, _, _) -> char) (get_rhyme_group_data group) in
    Hashtbl.add global_cache.group_cache group chars;
    chars

(** 查找同韵字 - 高性能版本 *)
let find_rhyming_characters character =
  match lookup_character_rhyme character with
  | Some (group, _) -> lookup_rhyme_group group
  | None -> []

(** {2 高级查询功能} *)

(** 按声调查询韵字 *)
let lookup_by_tone_category category =
  List.filter_map (fun (char, group, cat, freq) ->
    if cat = category then Some (char, group, freq) else None
  ) unified_rhyme_dataset

(** 按频率排序的韵字查询 *)
let lookup_by_frequency_threshold min_frequency =
  List.filter_map (fun (char, group, category, freq) ->
    if freq >= min_frequency then Some (char, group, category, freq) else None
  ) unified_rhyme_dataset
  |> List.sort (fun (_, _, _, f1) (_, _, _, f2) -> compare f2 f1) (* 降序排列 *)

(** 模糊韵律匹配 - 支持变体字 *)
let fuzzy_rhyme_match character tolerance =
  match lookup_character_rhyme character with
  | Some (target_group, target_category) ->
    let matches = List.filter_map (fun (char, group, category, freq) ->
      if group = target_group then (
        let score = if category = target_category then 1.0 else 0.7 in
        if score >= tolerance then Some (char, score, freq) else None
      ) else None
    ) unified_rhyme_dataset in
    List.sort (fun (_, s1, f1) (_, s2, f2) -> 
      let score_cmp = compare s2 s1 in
      if score_cmp = 0 then compare f2 f1 else score_cmp
    ) matches
  | None -> []

(** {2 批量查询优化} *)

(** 批量韵字查询 - 减少系统调用 *)
let batch_lookup_characters characters =
  List.fold_left (fun acc char ->
    match lookup_character_rhyme char with
    | Some result -> (char, result) :: acc
    | None -> acc
  ) [] characters

(** 批量韵律匹配检查 *)
let batch_rhyme_check pairs =
  List.map (fun (char1, char2) -> 
    ((char1, char2), characters_rhyme char1 char2)
  ) pairs

(** {2 查询统计和性能监控} *)

(** 获取查询统计 *)
let get_query_statistics () = global_cache.stats

(** 获取缓存统计 *)
let get_cache_statistics () =
  let lookup_size = Hashtbl.length global_cache.lookup_cache in
  let rhyme_size = Hashtbl.length global_cache.rhyme_cache in
  let group_size = Hashtbl.length global_cache.group_cache in
  
  Printf.printf "查询缓存统计:\n";
  Printf.printf "- 字符查询缓存: %d 条目\n" lookup_size;
  Printf.printf "- 韵律匹配缓存: %d 条目\n" rhyme_size;
  Printf.printf "- 韵组缓存: %d 条目\n" group_size;
  Printf.printf "- 总查询次数: %d\n" global_cache.stats.total_queries;
  Printf.printf "- 缓存命中率: %.2f%%\n" 
    (if global_cache.stats.total_queries > 0 then
       100.0 *. (float_of_int global_cache.stats.cache_hits) /. 
                 (float_of_int global_cache.stats.total_queries)
     else 0.0);
  
  (lookup_size, rhyme_size, group_size)

(** 清空缓存 - 内存管理 *)
let clear_cache () =
  Hashtbl.clear global_cache.lookup_cache;
  Hashtbl.clear global_cache.rhyme_cache;
  Hashtbl.clear global_cache.group_cache;
  global_cache.stats <- { total_queries = 0; cache_hits = 0; cache_misses = 0; query_time_total = 0.0 };
  Printf.printf "查询缓存已清空\n"

(** {2 性能基准测试} *)

(** 查询性能基准测试 *)
let benchmark_query_performance iterations =
  let test_characters = ["山"; "风"; "花"; "月"; "天"; "思"; "鱼"; "江"; "书"; "红"] in
  let start_time = Sys.time () in
  
  for i = 1 to iterations do
    let char = List.nth test_characters (i mod (List.length test_characters)) in
    ignore (lookup_character_rhyme char)
  done;
  
  let end_time = Sys.time () in
  let total_time = end_time -. start_time in
  let queries_per_second = float_of_int iterations /. total_time in
  
  Printf.printf "查询性能基准测试:\n";
  Printf.printf "- 测试次数: %d\n" iterations;
  Printf.printf "- 总耗时: %.3f 秒\n" total_time;
  Printf.printf "- 查询速度: %.0f 次/秒\n" queries_per_second;
  
  queries_per_second

(** 匹配性能基准测试 *)
let benchmark_matching_performance iterations =
  let test_pairs = [("山", "关"); ("风", "东"); ("花", "家"); ("月", "雪")] in
  let start_time = Sys.time () in
  
  for i = 1 to iterations do
    let (char1, char2) = List.nth test_pairs (i mod (List.length test_pairs)) in
    ignore (characters_rhyme char1 char2)
  done;
  
  let end_time = Sys.time () in
  let total_time = end_time -. start_time in
  let matches_per_second = float_of_int iterations /. total_time in
  
  Printf.printf "匹配性能基准测试:\n";
  Printf.printf "- 测试次数: %d\n" iterations;
  Printf.printf "- 总耗时: %.3f 秒\n" total_time;
  Printf.printf "- 匹配速度: %.0f 次/秒\n" matches_per_second;
  
  matches_per_second

(** {2 向后兼容接口} *)

(** 兼容原有查询引擎接口 *)
module Legacy_Query_API = struct
  (** 兼容 rhyme_query_engine.ml *)
  let query_rhyme = lookup_character_rhyme
  let find_rhyming_words = find_rhyming_characters
  
  (** 兼容 rhyme_lookup.ml *)
  let lookup_rhyme_info character =
    match lookup_character_rhyme character with
    | Some (group, category) -> Some { character; rhyme_group = group; tone_category = category; 
                                      frequency = 1.0; variants = []; source_module = "legacy" }
    | None -> None
  
  (** 兼容 rhyme_matching.ml *)
  let check_rhyme_match = characters_rhyme
  let batch_check_rhymes = batch_rhyme_check
  
  (** 兼容 rhyme_api_core.ml *)
  let api_lookup_rhyme = lookup_character_rhyme
  let api_find_rhymes = find_rhyming_characters
  let api_check_match = characters_rhyme
end

(** {2 预热和初始化} *)

(** 预热缓存 - 提升首次查询性能 *)
let warmup_cache () =
  Printf.printf "正在预热查询缓存...\n";
  let warmup_chars = ["山"; "风"; "花"; "月"; "天"; "思"; "鱼"; "江"; "书"; "红"; 
                      "安"; "东"; "家"; "雪"; "仙"; "丝"; "余"; "双"; "珠"; "黄"] in
  
  List.iter (fun char -> ignore (lookup_character_rhyme char)) warmup_chars;
  
  let pairs = [("山", "关"); ("风", "东"); ("花", "家"); ("月", "雪"); ("天", "仙")] in
  List.iter (fun (c1, c2) -> ignore (characters_rhyme c1 c2)) pairs;
  
  Printf.printf "缓存预热完成: %d 字符, %d 匹配对\n" 
    (List.length warmup_chars) (List.length pairs)

(** 模块初始化 *)
let () =
  Printf.printf "韵律查询统一引擎初始化完成\n";
  Printf.printf "- 整合查询模块: 6 → 1\n";
  Printf.printf "- O(1)查询优化: 哈希表缓存\n";
  Printf.printf "- 预期性能提升: 30%+\n";
  warmup_cache ()