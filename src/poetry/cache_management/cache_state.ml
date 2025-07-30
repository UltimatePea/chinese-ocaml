(** 缓存状态管理模块
    
    此模块管理全局缓存状态，包括状态初始化、
    配置管理和状态查询。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @extracted_from data_cache_manager.ml *)

open Cache_core_types

(** 全局缓存状态 *)
let cache_state = {
  data_map = Hashtbl.create 1000;
  strategies = Hashtbl.create 100;
  max_size_mb = 100.0;
  max_entries = 10000;
  current_size_bytes = 0;
  hit_count = 0;
  miss_count = 0;
  eviction_count = 0;
  total_access_time = 0.0;
  total_accesses = 0;
  event_listeners = [];
  next_listener_id = 1;
  recent_events = [];
  initialized = false;
  debug_mode = false;
}

(** 初始化缓存系统 *)
let initialize ?(max_size_mb = 100.0) ?(max_entries = 10000) 
                ?(default_strategy = LRU) ?(enable_statistics = true) () =
  if not cache_state.initialized then (
    cache_state.max_size_mb <- max_size_mb;
    cache_state.max_entries <- max_entries;
    cache_state.initialized <- true;
    Hashtbl.add cache_state.strategies "*" default_strategy;
    (* TODO: Use enable_statistics for future statistics configuration *)
    ignore enable_statistics
  )

(** 关闭缓存系统 *)
let shutdown () =
  Hashtbl.clear cache_state.data_map;
  Hashtbl.clear cache_state.strategies;
  cache_state.event_listeners <- [];
  cache_state.recent_events <- [];
  cache_state.initialized <- false

(** 检查是否已初始化 *)
let is_initialized () = cache_state.initialized

(** 配置特定键的策略 *)
let configure_strategy (key_pattern : string) (strategy : cache_strategy) =
  Hashtbl.replace cache_state.strategies key_pattern strategy

(** 获取缓存统计信息 *)
let get_statistics () : cache_statistics =
  let hit_rate = Cache_utils.calculate_hit_rate cache_state.hit_count cache_state.miss_count in
  let avg_access_time = 
    if cache_state.total_accesses = 0 then 0.0
    else cache_state.total_access_time /. float_of_int cache_state.total_accesses
  in
  {
    total_entries = Hashtbl.length cache_state.data_map;
    total_size_bytes = cache_state.current_size_bytes;
    hit_count = cache_state.hit_count;
    miss_count = cache_state.miss_count;
    eviction_count = cache_state.eviction_count;
    hit_rate = hit_rate;
    avg_access_time = avg_access_time;
    memory_usage_mb = Cache_utils.bytes_to_mb cache_state.current_size_bytes;
  }

(** 启用或禁用调试模式 *)
let enable_debug_mode enable = 
  cache_state.debug_mode <- enable

(** 获取所有键列表 *)
let list_all_keys () : string list =
  Hashtbl.fold (fun key _ acc -> key :: acc) cache_state.data_map []

(** 按模式列出键 *)
let list_keys_by_pattern (pattern : string) : string list =
  Hashtbl.fold (fun key _ acc ->
    if Cache_utils.matches_pattern pattern key then key :: acc else acc
  ) cache_state.data_map []

(** 按标签列出键 *)
let list_keys_by_tags (tags : string list) : string list =
  Hashtbl.fold (fun key entry acc ->
    if Cache_utils.has_matching_tags entry.metadata.tags tags then 
      key :: acc 
    else acc
  ) cache_state.data_map []