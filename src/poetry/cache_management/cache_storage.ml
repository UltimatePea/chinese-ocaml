(** 缓存存储操作模块
    
    此模块实现缓存的基本存储操作，包括存储、检索、
    删除和存在性检查等核心功能。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @extracted_from data_cache_manager.ml *)

open Cache_core_types
open Cache_state

(** 存储数据到缓存 *)
let store (key : string) (data : 'a) ?(priority = Normal) ?(ttl = None) ?(tags = []) () : bool =
  if not (is_initialized ()) then false
  else
    let current_time = Cache_utils.current_time () in
    let size_bytes = Cache_utils.estimate_size_bytes data in
    let strategy = Cache_strategy.get_strategy_for_key key in
    
    (* 如果需要，执行驱逐 *)
    if Cache_strategy.need_eviction () then (
      match Cache_strategy.find_victim_for_eviction strategy with
      | Some victim_key ->
          (match Hashtbl.find_opt cache_state.data_map victim_key with
          | Some entry ->
              Hashtbl.remove cache_state.data_map victim_key;
              cache_state.current_size_bytes <- 
                cache_state.current_size_bytes - entry.metadata.size_bytes;
              cache_state.eviction_count <- cache_state.eviction_count + 1;
              let strategy_name = match strategy with
                | LRU -> "LRU" | LFU -> "LFU" | FIFO -> "FIFO"
                | TTL _ -> "TTL" | Custom _ -> "Custom"
              in
              Cache_events.fire_event (CacheEvict (victim_key, strategy_name))
          | None -> ())
      | None -> ()
    );
    
    (* 创建缓存条目 *)
    let metadata = {
      key = key;
      size_bytes = size_bytes;
      created_time = current_time;
      last_accessed = current_time;
      access_count = 0;
      priority = priority;
      ttl = ttl;
      tags = tags;
    } in
    
    let entry = {
      data = Obj.repr data;
      metadata = metadata;
    } in
    
    (* 如果键已存在，先移除旧的大小 *)
    (match Hashtbl.find_opt cache_state.data_map key with
    | Some old_entry ->
        cache_state.current_size_bytes <- 
          cache_state.current_size_bytes - old_entry.metadata.size_bytes
    | None -> ());
    
    (* 存储新条目 *)
    Hashtbl.replace cache_state.data_map key entry;
    cache_state.current_size_bytes <- cache_state.current_size_bytes + size_bytes;
    
    (* 触发存储事件 *)
    Cache_events.fire_event (CacheStore (key, size_bytes));
    true

(** 从缓存检索数据 *)
let retrieve (key : string) : 'a cache_result =
  if not (is_initialized ()) then CacheError "Cache not initialized"
  else
    let start_time = Cache_utils.current_time () in
    match Hashtbl.find_opt cache_state.data_map key with
    | None ->
        Cache_events.update_statistics false (Some (Cache_utils.current_time () -. start_time));
        Cache_events.fire_event (CacheMiss key);
        CacheNotFound
    | Some entry ->
        (* 检查是否过期 *)
        if Cache_utils.is_entry_expired entry then (
          Hashtbl.remove cache_state.data_map key;
          cache_state.current_size_bytes <- 
            cache_state.current_size_bytes - entry.metadata.size_bytes;
          Cache_events.fire_event (CacheExpire key);
          Cache_events.update_statistics false (Some (Cache_utils.current_time () -. start_time));
          CacheExpired
        ) else (
          (* 更新访問统计 *)
          let current_time = Cache_utils.current_time () in
          let updated_metadata = {
            entry.metadata with
            last_accessed = current_time;
            access_count = entry.metadata.access_count + 1;
          } in
          let updated_entry = { entry with metadata = updated_metadata } in
          Hashtbl.replace cache_state.data_map key updated_entry;
          
          Cache_events.update_statistics true (Some (current_time -. start_time));
          Cache_events.fire_event (CacheHit key);
          CacheSuccess (Obj.obj entry.data : 'a)
        )

(** 检查键是否存在 *)
let exists (key : string) : bool =
  if not (is_initialized ()) then false
  else
    match Hashtbl.find_opt cache_state.data_map key with
    | None -> false
    | Some entry -> not (Cache_utils.is_entry_expired entry)

(** 删除缓存条目 *)
let delete (key : string) : bool =
  if not (is_initialized ()) then false
  else
    match Hashtbl.find_opt cache_state.data_map key with
    | None -> false
    | Some entry ->
        Hashtbl.remove cache_state.data_map key;
        cache_state.current_size_bytes <- 
          cache_state.current_size_bytes - entry.metadata.size_bytes;
        true

(** 更新条目的TTL *)
let update_ttl (key : string) (new_ttl : float) : bool =
  if not (is_initialized ()) then false
  else
    match Hashtbl.find_opt cache_state.data_map key with
    | None -> false
    | Some entry ->
        let updated_metadata = {
          entry.metadata with ttl = Some new_ttl
        } in
        let updated_entry = { entry with metadata = updated_metadata } in
        Hashtbl.replace cache_state.data_map key updated_entry;
        true

(** 获取条目的元数据 *)
let get_metadata (key : string) : cache_metadata option =
  match Hashtbl.find_opt cache_state.data_map key with
  | None -> None
  | Some entry -> Some entry.metadata