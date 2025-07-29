(** 缓存管理器模块
    
    负责统一数据管理器的缓存功能，包括LRU缓存实现、
    缓存策略管理和性能统计。
                                                           
    @author Charlie, 规划代理 - 负责架构重构  
    @refactored_from data_manager.ml QueryCache module
    @fix_issue #1727 *)

open Poetry_data_core_data_types

(** {1 缓存条目类型} *)

(** 缓存条目 - 包含数据、时间戳和访问计数 *)
type cache_entry = {
  data : unified_data_item list; (** 缓存的数据 *)
  timestamp : float; (** 创建时间戳 *)
  access_count : int; (** 访问次数 *)
}

(** {1 全局状态} *)

(* 缓存配置 - 可运行时修改 *)
let cache_config = ref default_cache_strategy

(* 缓存统计 - 运行时统计信息 *)
let cache_stats = ref empty_cache_statistics

(* 查询缓存表 - 主要的缓存存储 *)
let cache_table = Hashtbl.create 1000

(* 访问顺序队列 - LRU实现的核心 *)
let access_order = Queue.create ()

(** {1 核心缓存功能} *)

(** 生成查询条件的缓存键
    @param criteria 查询条件
    @return 对应的缓存键字符串 *)
let cache_key_of_criteria criteria =
  string_of_query_criteria criteria

(** 从缓存中获取数据
    @param criteria 查询条件
    @return 缓存的数据(如果存在且未过期) *)
let get criteria =
  let key = cache_key_of_criteria criteria in
  match Hashtbl.find_opt cache_table key with
  | Some entry ->
      let now = Unix.time () in
      if now -. entry.timestamp < !cache_config.ttl_seconds then (
        (* 缓存命中且未过期 *)
        cache_stats := {
          !cache_stats with
          total_queries = !cache_stats.total_queries + 1;
          cache_hits = !cache_stats.cache_hits + 1;
          hit_rate = float_of_int !cache_stats.cache_hits /. float_of_int !cache_stats.total_queries;
        };
        Queue.push key access_order;
        Some entry.data
      ) else (
        (* 缓存过期，删除条目 *)
        Hashtbl.remove cache_table key;
        None
      )
  | None ->
      (* 缓存未命中 *)
      cache_stats := {
        !cache_stats with
        total_queries = !cache_stats.total_queries + 1;
        cache_misses = !cache_stats.cache_misses + 1;
        hit_rate = float_of_int !cache_stats.cache_hits /. float_of_int !cache_stats.total_queries;
      };
      None

(** 向缓存中存储数据
    @param criteria 查询条件
    @param data 要缓存的数据 *)
let put criteria data =
  if !cache_config.enable_cache then (
    let key = cache_key_of_criteria criteria in
    let entry = { data; timestamp = Unix.time (); access_count = 1 } in

    (* LRU淘汰：如果缓存已满，删除最久未访问的条目 *)
    if Hashtbl.length cache_table >= !cache_config.max_cache_size then (
      try
        let old_key = Queue.take access_order in
        Hashtbl.remove cache_table old_key
      with Queue.Empty -> ()
    );

    Hashtbl.replace cache_table key entry;
    cache_stats := { !cache_stats with cache_size = Hashtbl.length cache_table }
  )

(** {1 缓存管理功能} *)

(** 清理过期的缓存条目 *)
let cleanup_expired_entries () =
  let now = Unix.time () in
  let ttl = !cache_config.ttl_seconds in
  let expired_keys = ref [] in
  
  Hashtbl.iter (fun key entry ->
    if now -. entry.timestamp >= ttl then
      expired_keys := key :: !expired_keys
  ) cache_table;
  
  List.iter (Hashtbl.remove cache_table) !expired_keys;
  cache_stats := { 
    !cache_stats with 
    cache_size = Hashtbl.length cache_table;
    last_cleanup = now 
  }

(** 清空所有缓存 *)
let clear_cache () =
  Hashtbl.clear cache_table;
  Queue.clear access_order;
  cache_stats := { 
    !cache_stats with 
    cache_size = 0;
    last_cleanup = Unix.time () 
  }

(** 预热缓存 - 为常用查询预加载数据
    @param criteria_list 要预热的查询条件列表
    @param data_loader 数据加载函数 *)
let warmup_cache criteria_list data_loader =
  List.iter (fun criteria ->
    match get criteria with
    | None -> (
        match data_loader criteria with
        | Success data -> put criteria data
        | Error _ -> ()
      )
    | Some _ -> () (* 已在缓存中 *)
  ) criteria_list

(** {1 配置和统计功能} *)

(** 更新缓存配置
    @param new_config 新的缓存配置 *)
let update_cache_config new_config =
  cache_config := new_config;
  (* 如果禁用缓存，清空所有缓存 *)
  if not new_config.enable_cache then clear_cache ()

(** 获取当前缓存配置 *)
let get_cache_config () = !cache_config

(** 获取缓存统计信息 *)
let get_cache_statistics () = !cache_stats

(** 重置缓存统计 *)
let reset_cache_statistics () =
  cache_stats := { 
    empty_cache_statistics with 
    last_cleanup = Unix.time () 
  }

(** 获取详细的缓存信息用于调试 *)
let get_cache_debug_info () =
  let table_size = Hashtbl.length cache_table in
  let queue_size = Queue.length access_order in
  Printf.sprintf 
    "Cache Debug Info:\n\
     - Table size: %d\n\
     - Queue size: %d\n\
     - Config: enabled=%b, max_size=%d, ttl=%.1fs\n\
     - Stats: queries=%d, hits=%d, misses=%d, hit_rate=%.2f%%"
    table_size queue_size
    !cache_config.enable_cache !cache_config.max_cache_size !cache_config.ttl_seconds
    !cache_stats.total_queries !cache_stats.cache_hits !cache_stats.cache_misses
    (!cache_stats.hit_rate *. 100.0)