(** 艺术评估结果缓存模块
 *
 * 提供高效的评估结果缓存和管理功能，提升评估性能。
 * 此模块整合了缓存相关的功能。
 *
 * @author Whisky, PR Worker - 诗词艺术评估模块整合实施
 * @version 1.0 - 模块整合版本
 * @since 2025-08-03
 * @fix_issue #2000 Poetry艺术评估模块整合实施
 *)

open Artistic_engine_unified

(** {1 缓存类型定义} *)

(** 缓存键类型 *)
type cache_key = {
  content_hash : string;      (* 内容哈希 *)
  config_hash : string;       (* 配置哈希 *)
  evaluation_type : string;   (* 评估类型 *)
}

(** 缓存条目 *)
type cache_entry = {
  key : cache_key;
  result : evaluation_result;
  created_at : float;
  last_accessed : float;
  access_count : int;
  expires_at : float;
}

(** 缓存统计信息 *)
type cache_statistics = {
  total_entries : int;
  hit_count : int;
  miss_count : int;
  hit_ratio : float;
  memory_usage : int;
  oldest_entry : float option;
  newest_entry : float option;
}

(** 缓存配置 *)
type cache_config = {
  max_size : int;           (* 最大缓存条目数 *)
  ttl_seconds : float;      (* 生存时间(秒) *)
  enable_lru : bool;        (* 是否启用LRU淘汰 *)
  auto_cleanup : bool;      (* 是否自动清理过期条目 *)
  persistence : bool;       (* 是否持久化 *)
}

(** {1 缓存状态管理} *)

module CacheState = struct
  type t = {
    mutable entries : cache_entry list;
    mutable config : cache_config;
    mutable statistics : cache_statistics;
  }

  let default_config = {
    max_size = 1000;
    ttl_seconds = 3600.0;  (* 1小时 *)
    enable_lru = true;
    auto_cleanup = true;
    persistence = false;
  }

  let default_statistics = {
    total_entries = 0;
    hit_count = 0;
    miss_count = 0;
    hit_ratio = 0.0;
    memory_usage = 0;
    oldest_entry = None;
    newest_entry = None;
  }

  let create_state config = {
    entries = [];
    config = config;
    statistics = default_statistics;
  }

  let global_cache = create_state default_config
end

(** {1 缓存键生成} *)

(** 生成内容哈希 *)
let generate_content_hash (content : string) : string =
  let hash = ref 0 in
  String.iter (fun c -> 
    hash := (!hash * 31 + Char.code c) land 0x3FFFFFFF
  ) content;
  Printf.sprintf "%08x" !hash

(** 生成配置哈希 *)
let generate_config_hash (config : evaluation_config) : string =
  let weights_str = String.concat "," (List.map (fun (_, w) -> string_of_float w) config.weights) in
  let config_str = Printf.sprintf "%s_%b_%b" weights_str config.enable_cache config.detailed_analysis in
  generate_content_hash config_str

(** 创建缓存键 *)
let create_cache_key (content : string) (config : evaluation_config) (eval_type : string) : cache_key =
  {
    content_hash = generate_content_hash content;
    config_hash = generate_config_hash config;
    evaluation_type = eval_type;
  }

(** 缓存键转字符串 *)
let cache_key_to_string (key : cache_key) : string =
  Printf.sprintf "%s_%s_%s" key.content_hash key.config_hash key.evaluation_type

(** {1 缓存操作} *)

(** 检查缓存条目是否有效 *)
let is_cache_entry_valid (entry : cache_entry) : bool =
  let current_time = Unix.gettimeofday () in
  entry.expires_at > current_time

(** 更新访问信息 *)
let update_access_info (entry : cache_entry) : cache_entry =
  {
    entry with
    last_accessed = Unix.gettimeofday ();
    access_count = entry.access_count + 1;
  }

(** 查找缓存条目 *)
let find_cache_entry (key : cache_key) : cache_entry option =
  let key_str = cache_key_to_string key in
  let entries = CacheState.global_cache.entries in
  List.find_opt (fun entry ->
    let entry_key_str = cache_key_to_string entry.key in
    entry_key_str = key_str && is_cache_entry_valid entry
  ) entries

(** 添加缓存条目 *)
let rec add_cache_entry (key : cache_key) (result : evaluation_result) : unit =
  let current_time = Unix.gettimeofday () in
  let new_entry = {
    key = key;
    result = result;
    created_at = current_time;
    last_accessed = current_time;
    access_count = 1;
    expires_at = current_time +. CacheState.global_cache.config.ttl_seconds;
  } in
  
  (* 添加新条目 *)
  CacheState.global_cache.entries <- new_entry :: CacheState.global_cache.entries;
  
  (* 检查缓存大小限制 *)
  if List.length CacheState.global_cache.entries > CacheState.global_cache.config.max_size then
    trim_cache ();
  
  (* 更新统计信息 *)
  update_cache_statistics ()

(** 修剪缓存（LRU策略） *)
and trim_cache () : unit =
  if CacheState.global_cache.config.enable_lru then
    (* 按最后访问时间排序，保留最近访问的条目 *)
    let sorted_entries = List.sort (fun a b -> 
      compare b.last_accessed a.last_accessed
    ) CacheState.global_cache.entries in
    let rec take n lst = 
      if n <= 0 || lst = [] then []
      else match lst with
      | [] -> []
      | h :: t -> h :: take (n-1) t
    in
    CacheState.global_cache.entries <- 
      take CacheState.global_cache.config.max_size sorted_entries
  else
    (* 简单地移除最旧的条目 *)
    let sorted_entries = List.sort (fun a b -> 
      compare b.created_at a.created_at
    ) CacheState.global_cache.entries in
    let rec take n lst = 
      if n <= 0 || lst = [] then []
      else match lst with
      | [] -> []
      | h :: t -> h :: take (n-1) t
    in
    CacheState.global_cache.entries <- 
      take CacheState.global_cache.config.max_size sorted_entries

(** 更新缓存统计信息 *)
and update_cache_statistics () : unit =
  let entries = CacheState.global_cache.entries in
  let valid_entries = List.filter is_cache_entry_valid entries in
  let times = List.map (fun e -> e.created_at) valid_entries in
  let oldest = if List.length times > 0 then Some (List.fold_left min max_float times) else None in
  let newest = if List.length times > 0 then Some (List.fold_left max min_float times) else None in
  
  let stats = CacheState.global_cache.statistics in
  let total_requests = stats.hit_count + stats.miss_count in
  let hit_ratio = if total_requests > 0 then float_of_int stats.hit_count /. float_of_int total_requests else 0.0 in
  
  CacheState.global_cache.statistics <- {
    total_entries = List.length valid_entries;
    hit_count = stats.hit_count;
    miss_count = stats.miss_count;
    hit_ratio = hit_ratio;
    memory_usage = List.length valid_entries * 500;  (* 估算每条目500字节 *)
    oldest_entry = oldest;
    newest_entry = newest;
  }

(** {1 公共缓存接口} *)

(** 从缓存获取评估结果 *)
let get_cached_result (content : string) (config : evaluation_config) (eval_type : string) : evaluation_result option =
  let key = create_cache_key content config eval_type in
  match find_cache_entry key with
  | Some entry ->
      (* 更新访问信息 *)
      let updated_entry = update_access_info entry in
      CacheState.global_cache.entries <- 
        updated_entry :: (List.filter (fun e -> 
          cache_key_to_string e.key <> cache_key_to_string key
        ) CacheState.global_cache.entries);
      
      (* 更新统计 *)
      CacheState.global_cache.statistics <- {
        CacheState.global_cache.statistics with
        hit_count = CacheState.global_cache.statistics.hit_count + 1;
      };
      update_cache_statistics ();
      Some updated_entry.result
  | None ->
      (* 更新统计 *)
      CacheState.global_cache.statistics <- {
        CacheState.global_cache.statistics with
        miss_count = CacheState.global_cache.statistics.miss_count + 1;
      };
      update_cache_statistics ();
      None

(** 缓存评估结果 *)
let cache_evaluation_result (content : string) (config : evaluation_config) (eval_type : string) (result : evaluation_result) : unit =
  let key = create_cache_key content config eval_type in
  add_cache_entry key result

(** 带缓存的评估函数 *)
let cached_evaluate_single_verse ?(config = default_config) (verse : string) : evaluation_result =
  match get_cached_result verse config "single_verse" with
  | Some cached_result -> cached_result
  | None ->
      let result = evaluate_single_verse ~config verse in
      cache_evaluation_result verse config "single_verse" result;
      result

(** 带缓存的对联评估函数 *)
let cached_evaluate_couplet ?(config = default_config) (left_verse : string) (right_verse : string) : evaluation_result =
  let combined_content = left_verse ^ "|" ^ right_verse in
  match get_cached_result combined_content config "couplet" with
  | Some cached_result -> cached_result
  | None ->
      let result = evaluate_couplet ~config left_verse right_verse in
      cache_evaluation_result combined_content config "couplet" result;
      result

(** {1 缓存管理} *)

(** 清理过期缓存条目 *)
let cleanup_expired_entries () : int =
  let before_count = List.length CacheState.global_cache.entries in
  CacheState.global_cache.entries <- List.filter is_cache_entry_valid CacheState.global_cache.entries;
  let after_count = List.length CacheState.global_cache.entries in
  update_cache_statistics ();
  before_count - after_count

(** 清空所有缓存 *)
let clear_all_cache () : unit =
  CacheState.global_cache.entries <- [];
  CacheState.global_cache.statistics <- CacheState.default_statistics;
  update_cache_statistics ()

(** 获取缓存统计信息 *)
let get_cache_statistics () : cache_statistics =
  if CacheState.global_cache.config.auto_cleanup then
    ignore (cleanup_expired_entries ());
  CacheState.global_cache.statistics

(** 配置缓存 *)
let configure_cache (config : cache_config) : unit =
  CacheState.global_cache.config <- config;
  (* 如果新的max_size小于当前条目数，需要修剪 *)
  if List.length CacheState.global_cache.entries > config.max_size then
    trim_cache ()

(** 获取当前缓存配置 *)
let get_cache_config () : cache_config =
  CacheState.global_cache.config

(** 预热缓存 *)
let warmup_cache (verses : string list) ?(config = default_config) () : unit =
  List.iter (fun verse ->
    ignore (cached_evaluate_single_verse ~config verse)
  ) verses

(** 缓存健康检查 *)
let cache_health_check () : bool * string list =
  let stats = get_cache_statistics () in
  let issues = ref [] in
  
  (* 检查命中率 *)
  if stats.hit_ratio < 0.5 && stats.hit_count + stats.miss_count > 100 then
    issues := "缓存命中率过低" :: !issues;
  
  (* 检查内存使用 *)
  if stats.memory_usage > 10000000 then  (* 10MB *)
    issues := "内存使用过高" :: !issues;
  
  (* 检查缓存条目数 *)
  if stats.total_entries > CacheState.global_cache.config.max_size then
    issues := "缓存条目数超过限制" :: !issues;
  
  (List.length !issues = 0, List.rev !issues)

(** 导出缓存数据（用于持久化） *)
let export_cache_data () : (string * evaluation_result * float) list =
  List.map (fun entry ->
    let key_str = cache_key_to_string entry.key in
    (key_str, entry.result, entry.expires_at)
  ) (List.filter is_cache_entry_valid CacheState.global_cache.entries)

(** 导入缓存数据（从持久化恢复） *)
let import_cache_data (data : (string * evaluation_result * float) list) : int =
  let current_time = Unix.gettimeofday () in
  let valid_data = List.filter (fun (_, _, expires) -> expires > current_time) data in
  (* 这里简化实现，实际需要重新构造cache_key *)
  List.length valid_data