(** 韵律数据缓存模块 - 从 rhyme_data_utils.ml 提取并优化
    
    专门处理韵律数据缓存、性能优化和内存管理，
    使用哈希表和LRU策略优化缓存性能。
    
    Author: Alpha, 主工作代理
    Fix #1460 Phase 2.1 - 缓存模块优化 *)

open Printf
open Rhyme_file_config

(** 韵律数据条目 *)
type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  tone_info : string option;
  usage_notes : string option;
}

(** 缓存条目结构 - 增强版本 *)
type cache_entry = {
  data : rhyme_entry list;
  timestamp : float;
  file_path : string;
  access_count : int ref;
  last_access : float ref;
}

(** 缓存统计信息 *)
type cache_stats = {
  total_entries : int;
  cache_hits : int;
  cache_misses : int;
  memory_usage_bytes : int;
}

(** 韵律数据缓存模块 - 性能优化版本 *)
module RhymeCache = struct
  let cache = Hashtbl.create 64
  let max_cache_size = ref 100  (* 改为可配置 *)
  let cache_hits = ref 0
  let cache_misses = ref 0
  let memory_limit_bytes = ref (50 * 1024 * 1024)  (* 50MB内存限制 *)
  
  (** 生成缓存键 *)
  let make_cache_key category group =
    (category, group)
  
  (** 检查缓存是否已满 *)
  let is_cache_full () =
    Hashtbl.length cache >= !max_cache_size
  
  (** 估算当前内存使用 *)
  let estimate_memory_usage () =
    let entry_count = Hashtbl.length cache in
    entry_count * 2048  (* 每个条目估算2KB *)
  
  (** 检查内存限制 *)
  let is_memory_limit_exceeded () =
    estimate_memory_usage () > !memory_limit_bytes
  
  (** LRU策略：清理最少使用的缓存项 *)
  let evict_lru_entry () =
    let oldest_key = ref None in
    let oldest_time = ref (Unix.time () +. 1.0) in (* 初始化为未来时间 *)
    Hashtbl.iter (fun key entry ->
      if !(entry.last_access) < !oldest_time then (
        oldest_time := !(entry.last_access);
        oldest_key := Some key
      )
    ) cache;
    match !oldest_key with
    | Some key -> Hashtbl.remove cache key
    | None -> ()
  
  (** 获取缓存数据 *)
  let get_cached category group =
    let key = make_cache_key category group in
    match Hashtbl.find_opt cache key with
    | Some entry -> 
        incr cache_hits;
        incr entry.access_count;
        entry.last_access := Unix.time ();
        Some entry.data
    | None -> 
        incr cache_misses;
        None
  
  (** 存储缓存数据 - 增强内存安全 *)
  let store_cached category group data file_path =
    try
      let key = make_cache_key category group in
      let key_exists = Hashtbl.mem cache key in
      
      (* 如果要添加新条目且缓存已满，需要先淘汰 *)
      if not key_exists && is_cache_full () then (
        evict_lru_entry ()
      );
      
      (* 检查内存限制 *)
      if is_memory_limit_exceeded () then (
        let current_size = Hashtbl.length cache in
        let target_size = current_size / 2 in
        for _i = 1 to (current_size - target_size) do
          evict_lru_entry ()
        done
      );
      
      let entry = {
        data = data;
        timestamp = Unix.time ();
        file_path = file_path;
        access_count = ref 1;
        last_access = ref (Unix.time ());
      } in
      Hashtbl.replace cache key entry
    with
    | Out_of_memory -> 
        (* 内存不足时清空缓存 *)
        Hashtbl.clear cache;
        cache_hits := 0;
        cache_misses := 0
    | e -> 
        Printf.eprintf "缓存存储错误: %s\n" (Printexc.to_string e)
  
  (** 清理缓存 *)
  let clear_cache () = 
    Hashtbl.clear cache;
    cache_hits := 0;
    cache_misses := 0
  
  (** 缓存统计信息 *)
  let get_cache_stats () =
    let total_entries = Hashtbl.length cache in
    let memory_usage = total_entries * 1024 in (* 估算内存使用 *)
    {
      total_entries = total_entries;
      cache_hits = !cache_hits;
      cache_misses = !cache_misses;
      memory_usage_bytes = memory_usage;
    }
  
  (** 缓存信息摘要 *)
  let cache_info () =
    let stats = get_cache_stats () in
    let hit_rate = if stats.cache_hits + stats.cache_misses > 0 then
      float_of_int stats.cache_hits /. float_of_int (stats.cache_hits + stats.cache_misses) *. 100.0
    else 0.0 in
    sprintf "韵律缓存: %d个条目, 命中率%.1f%%, 内存使用%dKB" 
      stats.total_entries hit_rate (stats.memory_usage_bytes / 1024)
  
  (** 预热缓存 - 批量加载常用数据 *)
  let warm_up_cache _config common_pairs =
    List.iter (fun (category, group) ->
      if get_cached category group = None then (
        (* 预热缓存：为常用组合创建空缓存条目 *)
        store_cached category group [] ""
      )
    ) common_pairs
  
  (** 配置缓存参数 *)
  let configure_cache ?(max_size=100) ?(memory_limit_mb=50) () =
    max_cache_size := max_size;
    memory_limit_bytes := memory_limit_mb * 1024 * 1024;
    Printf.printf "缓存配置已更新: 最大条目 %d, 内存限制 %dMB\n" max_size memory_limit_mb
  
  (** 获取缓存健康状态 *)
  let get_cache_health () =
    let stats = get_cache_stats () in
    let memory_usage_mb = stats.memory_usage_bytes / (1024 * 1024) in
    let memory_limit_mb = !memory_limit_bytes / (1024 * 1024) in
    let health_score = if memory_usage_mb = 0 then 100 
                      else min 100 (100 - (memory_usage_mb * 100 / memory_limit_mb)) in
    sprintf "缓存健康度: %d%% (内存使用: %dMB/%dMB)" 
      health_score memory_usage_mb memory_limit_mb
end

(** 创建韵律条目 *)
let create_rhyme_entries characters category group =
  List.map (fun char -> {
    character = char;
    category = category;
    group = group;
    tone_info = None;
    usage_notes = None;
  }) characters

(** 验证韵律条目 *)
let validate_rhyme_entry entry =
  let character_valid = String.length entry.character > 0 in
  let category_valid = match entry.category with
    | PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng -> true
  in
  character_valid && category_valid

(** 清理重复的韵律条目 - 使用哈希表优化 *)
let deduplicate_rhyme_entries entries =
  let seen = Hashtbl.create (List.length entries) in
  List.filter (fun entry ->
    let key = (entry.character, entry.category, entry.group) in
    if Hashtbl.mem seen key then false
    else (Hashtbl.add seen key true; true)
  ) entries

(** 韵律数据统计 *)
let analyze_rhyme_data entries =
  let total_count = List.length entries in
  let category_counts = Hashtbl.create 8 in
  List.iter (fun entry ->
    let category_str = string_of_rhyme_category entry.category in
    let current = match Hashtbl.find_opt category_counts category_str with
      | Some count -> count | None -> 0 in
    Hashtbl.replace category_counts category_str (current + 1)
  ) entries;
  sprintf "韵律数据分析: 总计%d个条目" total_count

(** 韵律匹配器 - 性能优化版本 *)
let create_rhyme_matcher entries =
  let char_to_group = Hashtbl.create (List.length entries) in
  List.iter (fun entry ->
    Hashtbl.replace char_to_group entry.character entry.group
  ) entries;
  fun character ->
    Hashtbl.find_opt char_to_group character

(** 韵律验证器 - 性能优化版本 *)
let create_rhyme_validator entries =
  let valid_chars = Hashtbl.create (List.length entries) in
  List.iter (fun entry ->
    Hashtbl.replace valid_chars entry.character true
  ) entries;
  fun character ->
    Hashtbl.mem valid_chars character

(** 韵律分析报告 *)
let generate_rhyme_report entries =
  let analysis = analyze_rhyme_data entries in
  let validation_results = List.map validate_rhyme_entry entries in
  let valid_count = List.length (List.filter (fun x -> x) validation_results) in
  let invalid_count = List.length entries - valid_count in
  let cache_info = RhymeCache.cache_info () in
  
  sprintf "%s\n验证结果: %d个有效条目，%d个无效条目\n%s" 
    analysis valid_count invalid_count cache_info