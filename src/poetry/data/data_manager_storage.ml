(** 数据存储和缓存配置管理模块
    
    负责数据源注册、缓存配置管理和统计信息维护。
    从原data_manager.ml的Cache模块和相关功能独立出来。
                                                           
    @author Alpha, 主要工作代理 - 基于Delta/Beta反馈的改进重构
    @version 2.1 - 模块化架构版本  
    @since 2025-07-30 - Phase 2A 改进重构
    @fix_issue #1791 *)

open Data_manager_types

(** {1 内部状态管理} *)

(* 缓存配置 *)
let cache_config =
  ref { enable_cache = true; max_cache_size = 10000; ttl_seconds = 3600.0; eviction_policy = `LRU }

(* 缓存统计 *)
let cache_stats =
  ref
    {
      total_queries = 0;
      cache_hits = 0;
      cache_misses = 0;
      cache_size = 0;
      hit_rate = 0.0;
      last_cleanup = Unix.time ();
    }

(* 数据源注册表 - 线程安全的哈希表 *)
let registered_sources : (data_source_id, (unit -> unified_data_item list data_result) * int * string * float) Hashtbl.t = 
  Hashtbl.create 32

(** {1 缓存配置管理} *)

let configure strategy =
  try
    cache_config := strategy;
    (* 通知查询模块更新配置 *)
    Data_manager_query.set_cache_config strategy;
    Success ()
  with exn ->
    Error
      (ValidationError ("cache_config", "Cache configuration failed: " ^ Printexc.to_string exn))

let get_cache_config () = !cache_config

let get_statistics () = !cache_stats

let get_stats_ref () = cache_stats

(** {1 数据源管理} *)

let register_data_source source_id loader ?(priority = 0) description =
  try
    let source_info = (loader, priority, description, Unix.time ()) in
    Hashtbl.replace registered_sources source_id source_info;
    Success ()
  with exn ->
    Error
      (ValidationError ("data_source", "Failed to register data source: " ^ Printexc.to_string exn))

let unregister_data_source source_id =
  try
    if Hashtbl.mem registered_sources source_id then (
      Hashtbl.remove registered_sources source_id;
      Success ())
    else Error (FileNotFound "Data source not found")
  with exn ->
    Error
      (ValidationError ("data_source", "Failed to unregister data source: " ^ Printexc.to_string exn))

let list_registered_sources () =
  Hashtbl.fold
    (fun source_id (_, priority, description, _) acc -> (source_id, description, priority) :: acc)
    registered_sources []

let get_registered_source source_id =
  Hashtbl.find_opt registered_sources source_id

(** {1 缓存操作} *)

let clear_cache ?source () =
  match source with
  | None ->
      Data_manager_query.clear cache_stats;
      Success ()
  | Some _ ->
      (* 选择性清除暂未实现，先全部清除 *)
      Data_manager_query.clear cache_stats;
      Success ()

let preload_cache source_list query_fn =
  try
    List.iter
      (fun source_id ->
        match query_fn (BySource source_id) with Success _ -> () | Error _ -> ())
      source_list;
    Success ()
  with exn ->
    Error
      (ValidationError ("cache_preload", "Cache preload failed: " ^ Printexc.to_string exn))

let get_cache_efficiency () =
  if !cache_stats.total_queries > 0 then !cache_stats.hit_rate else 0.0

(** {1 统计和监控} *)

let get_source_statistics source_id =
  match Hashtbl.find_opt registered_sources source_id with
  | Some (loader, _, _, last_loaded) -> (
      match loader () with
      | Success items ->
          let item_count = List.length items in
          Success (item_count, last_loaded)
      | Error err -> Error err)
  | None -> Error (FileNotFound "Source not found")