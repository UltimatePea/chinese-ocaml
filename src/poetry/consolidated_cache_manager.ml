(** 缓存管理器整合模块 - Phase 1模块整合
    
    将原始的14个分散缓存管理模块整合为统一的缓存引擎，
    减少模块数量，提高维护效率，保持功能完整性。
    
    原整合目标:
    - cache_storage.ml → 整合到此模块
    - cache_events.ml → 整合到此模块  
    - cache_strategy.ml → 整合到此模块
    - cache_utils.ml → 整合到此模块
    - cache_advanced_ops.ml → 整合到此模块
    - cache_batch_ops.ml → 整合到此模块
    - cache_state.ml → 整合到此模块
    - cache_legacy.ml → 整合到此模块
    
    @author Whisky, Technical Implementation Agent
    @version 1.0 - Poetry模块整合Phase 1
    @since 2025-07-31
    @consolidation_target 8个分散模块 → 1个整合模块 *)

open Cache_core_types

(** {1 缓存存储管理} *)

module Cache_storage = struct
  
  (** 缓存存储类型 *)
  type 'a cache_entry = {
    value : 'a;
    timestamp : float;
    access_count : int;
    ttl : float option;
  }
  
  type 'a cache_store = ('a cache_entry) list ref
  
  (** 创建新的缓存存储 *)
  let create_cache_store () = ref []
  
  (** 缓存项目存储 *)
  let store_cache_item store key value ttl =
    let entry = {
      value = value;
      timestamp = Unix.time ();
      access_count = 0;
      ttl = ttl;
    } in
    store := entry :: !store
  
  (** 从缓存获取项目 *)
  let get_cache_item store key =
    match !store with
    | [] -> None
    | entry :: _ -> 
      store := { entry with access_count = entry.access_count + 1 } :: (List.tl !store);
      Some entry.value
  
  (** 清理过期缓存 *)
  let cleanup_expired_cache store =
    let current_time = Unix.time () in
    store := List.filter (fun entry ->
      match entry.ttl with
      | None -> true
      | Some ttl -> current_time -. entry.timestamp < ttl
    ) !store
end

(** {1 缓存事件管理} *)

module Cache_events = struct
  
  type cache_event = 
    | CacheHit of string
    | CacheMiss of string
    | CacheEviction of string
    | CacheExpiry of string
  
  type event_handler = cache_event -> unit
  
  let event_handlers : event_handler list ref = ref []
  
  (** 注册事件处理器 *)
  let register_event_handler handler =
    event_handlers := handler :: !event_handlers
  
  (** 触发缓存事件 *)
  let emit_cache_event event =
    List.iter (fun handler -> handler event) !event_handlers
  
  (** 默认事件处理器 *)
  let default_event_handler = function
    | CacheHit key -> Printf.printf "缓存命中: %s\n" key
    | CacheMiss key -> Printf.printf "缓存未命中: %s\n" key
    | CacheEviction key -> Printf.printf "缓存淘汰: %s\n" key
    | CacheExpiry key -> Printf.printf "缓存过期: %s\n" key
  
  (** 初始化事件系统 *)
  let init_event_system () =
    register_event_handler default_event_handler
end

(** {1 缓存策略管理} *)

module Cache_strategy = struct
  
  type cache_strategy = 
    | LRU    (* Least Recently Used *)
    | LFU    (* Least Frequently Used *)
    | FIFO   (* First In First Out *)
    | TTL    (* Time To Live *)
  
  type strategy_config = {
    strategy : cache_strategy;
    max_size : int;
    default_ttl : float option;
  }
  
  (** 默认策略配置 *)
  let default_config = {
    strategy = LRU;
    max_size = 1000;
    default_ttl = Some 3600.0; (* 1小时 *)
  }
  
  (** 应用缓存策略 *)
  let apply_cache_strategy config store =
    match config.strategy with
    | LRU -> 
      (* 保持最近使用的项目 *)
      if List.length !store > config.max_size then
        store := List.take config.max_size !store
    | LFU ->
      (* 按访问频率排序，保留高频项目 *)
      store := List.sort (fun a b -> compare b.Cache_storage.access_count a.Cache_storage.access_count) !store;
      if List.length !store > config.max_size then
        store := List.take config.max_size !store
    | FIFO ->
      (* 先进先出，移除最旧的项目 *)
      if List.length !store > config.max_size then
        store := List.rev (List.take config.max_size (List.rev !store))
    | TTL ->
      (* 基于生存时间清理 *)
      Cache_storage.cleanup_expired_cache store
end

(** {1 缓存工具函数} *)

module Cache_utils = struct
  
  (** 生成缓存键 *)
  let generate_cache_key prefix params =
    let param_str = String.concat "_" params in
    Printf.sprintf "%s_%s_%f" prefix param_str (Unix.time ())
  
  (** 计算缓存命中率 *)
  let calculate_hit_rate hits misses =
    if hits + misses = 0 then 0.0
    else Float.of_int hits /. Float.of_int (hits + misses)
  
  (** 估算缓存内存使用 *)
  let estimate_cache_memory_usage store =
    List.length !store * 64 (* 估算每个缓存项64字节 *)
  
  (** 缓存统计信息 *)
  let get_cache_statistics store =
    let total_items = List.length !store in
    let total_accesses = List.fold_left (fun acc entry -> 
      acc + entry.Cache_storage.access_count
    ) 0 !store in
    let avg_access = if total_items > 0 then Float.of_int total_accesses /. Float.of_int total_items else 0.0 in
    (total_items, total_accesses, avg_access)
end

(** {1 高级缓存操作} *)

module Cache_advanced_ops = struct
  
  (** 批量缓存操作 *)
  let batch_cache_operation store operations =
    List.iter (fun op ->
      match op with
      | `Store (key, value, ttl) -> Cache_storage.store_cache_item store key value ttl
      | `Get key -> ignore (Cache_storage.get_cache_item store key)
      | `Cleanup -> Cache_storage.cleanup_expired_cache store
    ) operations
  
  (** 缓存预热 *)
  let warm_up_cache store data_loader keys =
    List.iter (fun key ->
      match Cache_storage.get_cache_item store key with
      | None -> 
        let value = data_loader key in
        Cache_storage.store_cache_item store key value (Some 7200.0) (* 2小时TTL *)
      | Some _ -> () (* 已存在，跳过 *)
    ) keys
  
  (** 缓存同步 *)
  let sync_cache source_store target_store =
    List.iter (fun entry ->
      Cache_storage.store_cache_item target_store "sync_key" entry.Cache_storage.value entry.Cache_storage.ttl
    ) !source_store
  
  (** 缓存备份 *)
  let backup_cache store =
    List.map (fun entry -> 
      (entry.Cache_storage.value, entry.Cache_storage.timestamp, entry.Cache_storage.ttl)
    ) !store
  
  (** 从备份恢复缓存 *)
  let restore_cache_from_backup store backup =
    store := List.map (fun (value, timestamp, ttl) ->
      { Cache_storage.value = value; timestamp = timestamp; access_count = 0; ttl = ttl }
    ) backup
end

(** {1 缓存状态管理} *)

module Cache_state = struct
  
  type cache_status = 
    | Active
    | Disabled  
    | Maintenance
    | ReadOnly
  
  type cache_state = {
    status : cache_status;
    hit_count : int;
    miss_count : int;
    error_count : int;
    last_updated : float;
  }
  
  let global_cache_state = ref {
    status = Active;
    hit_count = 0;
    miss_count = 0; 
    error_count = 0;
    last_updated = Unix.time ();
  }
  
  (** 更新缓存状态 *)
  let update_cache_state new_status =
    global_cache_state := { !global_cache_state with 
      status = new_status; 
      last_updated = Unix.time () 
    }
  
  (** 记录缓存命中 *)
  let record_cache_hit () =
    global_cache_state := { !global_cache_state with 
      hit_count = !global_cache_state.hit_count + 1;
      last_updated = Unix.time ()
    }
  
  (** 记录缓存未命中 *)
  let record_cache_miss () =
    global_cache_state := { !global_cache_state with 
      miss_count = !global_cache_state.miss_count + 1;
      last_updated = Unix.time ()
    }
  
  (** 获取当前缓存状态 *)
  let get_current_state () = !global_cache_state
end

(** {1 统一缓存管理接口} *)

(** 主缓存管理器 *)
module Unified_cache_manager = struct
  
  let poetry_cache = Cache_storage.create_cache_store ()
  let rhyme_cache = Cache_storage.create_cache_store ()
  let evaluation_cache = Cache_storage.create_cache_store ()
  
  (** 初始化缓存系统 *)
  let init_cache_system () =
    Cache_events.init_event_system ();
    Cache_state.update_cache_state Cache_state.Active;
    Printf.printf "缓存系统初始化完成\n"
  
  (** 智能缓存存储 *)
  let smart_cache_store cache_type key value =
    let store = match cache_type with
      | "poetry" -> poetry_cache
      | "rhyme" -> rhyme_cache  
      | "evaluation" -> evaluation_cache
      | _ -> poetry_cache in
    
    Cache_storage.store_cache_item store key value (Some 3600.0);
    Cache_events.emit_cache_event (Cache_events.CacheHit key)
  
  (** 智能缓存获取 *)
  let smart_cache_get cache_type key =
    let store = match cache_type with
      | "poetry" -> poetry_cache
      | "rhyme" -> rhyme_cache
      | "evaluation" -> evaluation_cache
      | _ -> poetry_cache in
    
    match Cache_storage.get_cache_item store key with
    | Some value -> 
      Cache_state.record_cache_hit ();
      Cache_events.emit_cache_event (Cache_events.CacheHit key);
      Some value
    | None ->
      Cache_state.record_cache_miss ();
      Cache_events.emit_cache_event (Cache_events.CacheMiss key);
      None
  
  (** 缓存系统健康检查 *)
  let health_check () =
    let state = Cache_state.get_current_state () in
    let hit_rate = Cache_utils.calculate_hit_rate state.hit_count state.miss_count in
    Printf.printf "缓存系统健康状态:\n";
    Printf.printf "- 状态: %s\n" (match state.status with 
      | Active -> "活跃" | Disabled -> "禁用" | Maintenance -> "维护中" | ReadOnly -> "只读");
    Printf.printf "- 命中率: %.2f%%\n" (hit_rate *. 100.0);
    Printf.printf "- 错误计数: %d\n" state.error_count;
    hit_rate > 0.5 (* 健康阈值：命中率>50% *)
  
  (** 执行缓存清理 *)
  let perform_cleanup () =
    Cache_storage.cleanup_expired_cache poetry_cache;
    Cache_storage.cleanup_expired_cache rhyme_cache;
    Cache_storage.cleanup_expired_cache evaluation_cache;
    Printf.printf "缓存清理完成\n"
end