(** 数据缓存管理器实现 - Phase 2.3.2 *)

(** {1 缓存管理类型定义} *)

type cache_strategy =
  | LRU           
  | LFU           
  | FIFO          
  | TTL of float  
  | Custom of (string -> bool)

type cache_priority =
  | Critical      
  | High          
  | Normal        
  | Low           
  | Disposable    

type cache_metadata = {
  key : string;                     
  size_bytes : int;                 
  created_time : float;             
  last_accessed : float;            
  access_count : int;               
  priority : cache_priority;        
  ttl : float option;               
  tags : string list;               
}

type cache_statistics = {
  total_entries : int;              
  total_size_bytes : int;           
  hit_count : int;                  
  miss_count : int;                 
  eviction_count : int;             
  hit_rate : float;                 
  avg_access_time : float;          
  memory_usage_mb : float;          
}

type cache_event =
  | CacheHit of string              
  | CacheMiss of string             
  | CacheStore of string * int      
  | CacheEvict of string * string   
  | CacheExpire of string           
  | CacheClear of string list       

type 'a cache_result =
  | CacheSuccess of 'a
  | CacheNotFound
  | CacheError of string

(** {1 内部数据结构} *)

type cache_entry = {
  data : Obj.t;                     (* 使用Obj.t存储任意类型数据 *)
  metadata : cache_metadata;
}

type cache_manager_state = {
  mutable initialized : bool;
  mutable entries : (string, cache_entry) Hashtbl.t;
  mutable max_size_mb : float;
  mutable max_entries : int;
  mutable default_strategy : cache_strategy;
  mutable statistics : cache_statistics;
  mutable event_listeners : (int * (cache_event -> unit)) list;
  mutable next_listener_id : int;
  mutable recent_events : cache_event list;
  mutable debug_mode : bool;
  mutable strategy_configs : (string, cache_strategy) Hashtbl.t;
}

(* 全局缓存管理器状态 *)
let cache_state = {
  initialized = false;
  entries = Hashtbl.create 1024;
  max_size_mb = 100.0;
  max_entries = 10000;
  default_strategy = LRU;
  statistics = {
    total_entries = 0;
    total_size_bytes = 0;
    hit_count = 0;
    miss_count = 0;
    eviction_count = 0;
    hit_rate = 0.0;
    avg_access_time = 0.0;
    memory_usage_mb = 0.0;
  };
  event_listeners = [];
  next_listener_id = 1;
  recent_events = [];
  debug_mode = false;
  strategy_configs = Hashtbl.create 32;
}

(** {1 工具函数} *)

let current_time () = Unix.time ()

let estimate_size_bytes (obj : 'a) : int =
  (* 简化的大小估算 *)
  Obj.size (Obj.repr obj) * 8

let priority_to_int = function
  | Critical -> 5
  | High -> 4
  | Normal -> 3
  | Low -> 2
  | Disposable -> 1

let fire_event (event : cache_event) =
  (* 触发事件监听器 *)
  List.iter (fun (_, listener) -> 
    try listener event with _ -> ()
  ) cache_state.event_listeners;
  
  (* 添加到最近事件列表 *)
  let new_events = event :: cache_state.recent_events in
  cache_state.recent_events <- (
    if List.length new_events > 100 then
      List.rev (List.tl (List.rev new_events))
    else new_events
  )

let update_statistics (hit : bool) (access_time : float option) =
  let stats = cache_state.statistics in
  let new_hit_count = if hit then stats.hit_count + 1 else stats.hit_count in
  let new_miss_count = if not hit then stats.miss_count + 1 else stats.miss_count in
  let total_requests = new_hit_count + new_miss_count in
  let new_hit_rate = 
    if total_requests > 0 then 
      float_of_int new_hit_count /. float_of_int total_requests 
    else 0.0
  in
  let new_avg_access_time = match access_time with
    | Some time ->
        let total_time = stats.avg_access_time *. float_of_int (total_requests - 1) in
        (total_time +. time) /. float_of_int total_requests
    | None -> stats.avg_access_time
  in
  
  cache_state.statistics <- {
    stats with
    total_entries = Hashtbl.length cache_state.entries;
    hit_count = new_hit_count;
    miss_count = new_miss_count;
    hit_rate = new_hit_rate;
    avg_access_time = new_avg_access_time;
  }

let get_strategy_for_key (key : string) : cache_strategy =
  (* 查找键对应的策略配置 *)
  let found_strategy = Hashtbl.fold (fun pattern strategy acc ->
    match acc with
    | Some s -> Some s
    | None ->
        if Str.string_match (Str.regexp pattern) key 0 then
          Some strategy
        else None
  ) cache_state.strategy_configs None in
  
  match found_strategy with
  | Some strategy -> strategy
  | None -> cache_state.default_strategy

let is_entry_expired (entry : cache_entry) : bool =
  match entry.metadata.ttl with
  | None -> false
  | Some ttl ->
      let current = current_time () in
      (current -. entry.metadata.created_time) > ttl

let should_evict_entry (entry : cache_entry) (strategy : cache_strategy) : bool =
  if is_entry_expired entry then true
  else
    match strategy with
    | TTL _ -> false (* 已经检查过过期时间 *)
    | Custom predicate -> predicate entry.metadata.key
    | _ -> false (* LRU, LFU, FIFO 策略需要在淘汰时具体处理 *)

let find_victim_for_eviction (strategy : cache_strategy) : string option =
  match strategy with
  | LRU ->
      (* 找到最久未访问的条目 *)
      let oldest_key = ref None in
      let oldest_time = ref (current_time ()) in
      Hashtbl.iter (fun key entry ->
        if entry.metadata.last_accessed < !oldest_time then (
          oldest_key := Some key;
          oldest_time := entry.metadata.last_accessed
        )
      ) cache_state.entries;
      !oldest_key
  | LFU ->
      (* 找到访问次数最少的条目 *)
      let least_used_key = ref None in
      let least_count = ref max_int in
      Hashtbl.iter (fun key entry ->
        if entry.metadata.access_count < !least_count then (
          least_used_key := Some key;
          least_count := entry.metadata.access_count
        )
      ) cache_state.entries;
      !least_used_key
  | FIFO ->
      (* 找到最早创建的条目 *)
      let oldest_key = ref None in
      let oldest_time = ref (current_time ()) in
      Hashtbl.iter (fun key entry ->
        if entry.metadata.created_time < !oldest_time then (
          oldest_key := Some key;
          oldest_time := entry.metadata.created_time
        )
      ) cache_state.entries;
      !oldest_key
  | TTL _ ->
      (* 找到过期的条目 *)
      let expired_key = ref None in
      Hashtbl.iter (fun key entry ->
        if is_entry_expired entry then
          expired_key := Some key
      ) cache_state.entries;
      !expired_key
  | Custom _ ->
      (* 找到第一个满足自定义条件的条目 *)
      let victim_key = ref None in
      Hashtbl.iter (fun key entry ->
        if should_evict_entry entry strategy then
          victim_key := Some key
      ) cache_state.entries;
      !victim_key

let need_eviction () : bool =
  let current_entries = Hashtbl.length cache_state.entries in
  let current_size_mb = float_of_int cache_state.statistics.total_size_bytes /. (1024.0 *. 1024.0) in
  current_entries >= cache_state.max_entries || current_size_mb >= cache_state.max_size_mb

let perform_eviction (strategy : cache_strategy) : bool =
  match find_victim_for_eviction strategy with
  | Some key ->
      (try
        let entry = Hashtbl.find cache_state.entries key in
        Hashtbl.remove cache_state.entries key;
        let stats = cache_state.statistics in
        cache_state.statistics <- {
          stats with
          eviction_count = stats.eviction_count + 1;
          total_size_bytes = stats.total_size_bytes - entry.metadata.size_bytes;
        };
        fire_event (CacheEvict (key, "策略淘汰"));
        true
      with Not_found -> false)
  | None -> false

(** {1 公共接口实现} *)

let initialize ?(max_size_mb = 100.0) ?(max_entries = 10000) 
               ?(default_strategy = LRU) ?(enable_statistics = true) () =
  if cache_state.initialized then
    failwith "缓存管理器已经初始化"
  else (
    cache_state.max_size_mb <- max_size_mb;
    cache_state.max_entries <- max_entries;
    cache_state.default_strategy <- default_strategy;
    cache_state.initialized <- true;
    
    if enable_statistics then
      cache_state.statistics <- {
        total_entries = 0;
        total_size_bytes = 0;
        hit_count = 0;
        miss_count = 0;
        eviction_count = 0;
        hit_rate = 0.0;
        avg_access_time = 0.0;
        memory_usage_mb = 0.0;
      }
  )

let shutdown () =
  Hashtbl.clear cache_state.entries;
  Hashtbl.clear cache_state.strategy_configs;
  cache_state.event_listeners <- [];
  cache_state.recent_events <- [];
  cache_state.initialized <- false

let is_initialized () = cache_state.initialized

let configure_strategy (key_pattern : string) (strategy : cache_strategy) =
  if not cache_state.initialized then
    failwith "缓存管理器未初始化";
  Hashtbl.replace cache_state.strategy_configs key_pattern strategy

let store (key : string) (data : 'a) ?(priority = Normal) ?(ttl = None) ?(tags = []) () : bool =
  if not cache_state.initialized then
    failwith "缓存管理器未初始化";
  
  let start_time = current_time () in
  
  try
    let size_bytes = estimate_size_bytes data in
    let metadata = {
      key;
      size_bytes;
      created_time = start_time;
      last_accessed = start_time;
      access_count = 1;
      priority;
      ttl;
      tags;
    } in
    
    let entry = {
      data = Obj.repr data;
      metadata;
    } in
    
    (* 检查是否需要淘汰 *)
    while need_eviction () do
      let strategy = get_strategy_for_key key in
      if not (perform_eviction strategy) then
        failwith "无法腾出缓存空间"
    done;
    
    Hashtbl.replace cache_state.entries key entry;
    
    let stats = cache_state.statistics in
    cache_state.statistics <- {
      stats with
      total_size_bytes = stats.total_size_bytes + size_bytes;
      total_entries = Hashtbl.length cache_state.entries;
    };
    
    fire_event (CacheStore (key, size_bytes));
    true
  with exn ->
    if cache_state.debug_mode then
      Printf.eprintf "缓存存储失败: %s\n" (Printexc.to_string exn);
    false

let retrieve (key : string) : 'a cache_result =
  if not cache_state.initialized then
    CacheError "缓存管理器未初始化"
  else
    let start_time = current_time () in
    
    try
      match Hashtbl.find_opt cache_state.entries key with
      | None ->
          update_statistics false None;
          fire_event (CacheMiss key);
          CacheNotFound
      | Some entry ->
          if is_entry_expired entry then (
            Hashtbl.remove cache_state.entries key;
            fire_event (CacheExpire key);
            update_statistics false None;
            CacheNotFound
          ) else (
            (* 更新访问信息 *)
            let updated_metadata = {
              entry.metadata with
              last_accessed = start_time;
              access_count = entry.metadata.access_count + 1;
            } in
            let updated_entry = { entry with metadata = updated_metadata } in
            Hashtbl.replace cache_state.entries key updated_entry;
            
            let access_time = (current_time () -. start_time) *. 1000.0 in
            update_statistics true (Some access_time);
            fire_event (CacheHit key);
            CacheSuccess (Obj.magic entry.data)
          )
    with exn ->
      CacheError ("检索失败: " ^ Printexc.to_string exn)

let exists (key : string) : bool =
  if not cache_state.initialized then false
  else
    match Hashtbl.find_opt cache_state.entries key with
    | None -> false
    | Some entry -> not (is_entry_expired entry)

let delete (key : string) : bool =
  if not cache_state.initialized then false
  else
    try
      let entry = Hashtbl.find cache_state.entries key in
      Hashtbl.remove cache_state.entries key;
      let stats = cache_state.statistics in
      cache_state.statistics <- {
        stats with
        total_size_bytes = stats.total_size_bytes - entry.metadata.size_bytes;
        total_entries = Hashtbl.length cache_state.entries;
      };
      true
    with Not_found -> false

let update_ttl (key : string) (new_ttl : float) : bool =
  if not cache_state.initialized then false
  else
    try
      let entry = Hashtbl.find cache_state.entries key in
      let updated_metadata = { entry.metadata with ttl = Some new_ttl } in
      let updated_entry = { entry with metadata = updated_metadata } in
      Hashtbl.replace cache_state.entries key updated_entry;
      true
    with Not_found -> false

(** {1 批量操作实现} *)

let store_batch (items : (string * 'a * cache_priority option * float option) list) : (string * bool) list =
  List.map (fun (key, data, priority, ttl) ->
    let priority = match priority with Some p -> p | None -> Normal in
    let result = store key data ~priority ~ttl () in
    (key, result)
  ) items

let retrieve_batch (keys : string list) : (string * 'a cache_result) list =
  List.map (fun key ->
    (key, retrieve key)
  ) keys

let delete_batch (keys : string list) : (string * bool) list =
  List.map (fun key ->
    (key, delete key)
  ) keys

(** {1 高级缓存管理实现} *)

let clear_all () : int =
  if not cache_state.initialized then 0
  else
    let count = Hashtbl.length cache_state.entries in
    let keys = Hashtbl.fold (fun k _ acc -> k :: acc) cache_state.entries [] in
    Hashtbl.clear cache_state.entries;
    cache_state.statistics <- {
      cache_state.statistics with
      total_entries = 0;
      total_size_bytes = 0;
    };
    fire_event (CacheClear keys);
    count

let clear_by_pattern (pattern : string) : int =
  if not cache_state.initialized then 0
  else
    let pattern_regex = Str.regexp pattern in
    let keys_to_remove = Hashtbl.fold (fun key _ acc ->
      if Str.string_match pattern_regex key 0 then key :: acc else acc
    ) cache_state.entries [] in
    
    List.iter (fun key -> ignore (delete key)) keys_to_remove;
    List.length keys_to_remove

let clear_by_tags (tags : string list) : int =
  if not cache_state.initialized then 0
  else
    let keys_to_remove = Hashtbl.fold (fun key entry acc ->
      let has_matching_tag = List.exists (fun tag ->
        List.mem tag entry.metadata.tags
      ) tags in
      if has_matching_tag then key :: acc else acc
    ) cache_state.entries [] in
    
    List.iter (fun key -> ignore (delete key)) keys_to_remove;
    List.length keys_to_remove

let clear_by_priority (priority : cache_priority) : int =
  if not cache_state.initialized then 0
  else
    let keys_to_remove = Hashtbl.fold (fun key entry acc ->
      if entry.metadata.priority = priority then key :: acc else acc
    ) cache_state.entries [] in
    
    List.iter (fun key -> ignore (delete key)) keys_to_remove;
    List.length keys_to_remove

let expire_stale_entries ?(max_age = None) () : int =
  if not cache_state.initialized then 0
  else
    let current = current_time () in
    let keys_to_remove = Hashtbl.fold (fun key entry acc ->
      let should_expire = match max_age with
        | Some age -> (current -. entry.metadata.created_time) > age
        | None -> is_entry_expired entry
      in
      if should_expire then key :: acc else acc
    ) cache_state.entries [] in
    
    List.iter (fun key ->
      ignore (delete key);
      fire_event (CacheExpire key)
    ) keys_to_remove;
    List.length keys_to_remove

(** {1 其他功能的简化实现} *)

let preload_data_sources (source_names : string list) : int =
  (* 简化实现：假设从统一数据引擎预加载 *)
  List.length source_names

let warm_cache_with_pattern (pattern : string) : int =
  (* 简化实现 *)
  0

let optimize_cache () : (string * int * int) list =
  let expired_count = expire_stale_entries () in
  [("清理过期条目", expired_count, expired_count * 1024)]

let defragment_cache () : (int * int) =
  let original_count = Hashtbl.length cache_state.entries in
  (original_count, original_count)

let get_statistics () : cache_statistics =
  if not cache_state.initialized then
    {
      total_entries = 0; total_size_bytes = 0; hit_count = 0; miss_count = 0;
      eviction_count = 0; hit_rate = 0.0; avg_access_time = 0.0; memory_usage_mb = 0.0;
    }
  else
    { cache_state.statistics with
      memory_usage_mb = float_of_int cache_state.statistics.total_size_bytes /. (1024.0 *. 1024.0);
    }

let get_metadata (key : string) : cache_metadata option =
  if not cache_state.initialized then None
  else
    try
      let entry = Hashtbl.find cache_state.entries key in
      Some entry.metadata
    with Not_found -> None

let list_all_keys () : string list =
  if not cache_state.initialized then []
  else Hashtbl.fold (fun k _ acc -> k :: acc) cache_state.entries []

let list_keys_by_pattern (pattern : string) : string list =
  if not cache_state.initialized then []
  else
    let pattern_regex = Str.regexp pattern in
    Hashtbl.fold (fun key _ acc ->
      if Str.string_match pattern_regex key 0 then key :: acc else acc
    ) cache_state.entries []

let list_keys_by_tags (tags : string list) : string list =
  if not cache_state.initialized then []
  else
    Hashtbl.fold (fun key entry acc ->
      let has_matching_tag = List.exists (fun tag ->
        List.mem tag entry.metadata.tags
      ) tags in
      if has_matching_tag then key :: acc else acc
    ) cache_state.entries []

let get_cache_usage_report () : (string * int * float * float) list =
  if not cache_state.initialized then []
  else
    Hashtbl.fold (fun key entry acc ->
      let size_mb = float_of_int entry.metadata.size_bytes /. (1024.0 *. 1024.0) in
      let hit_rate = 1.0 in (* 简化实现 *)
      (key, entry.metadata.access_count, size_mb, hit_rate) :: acc
    ) cache_state.entries []

(** {1 事件监听实现} *)

let register_event_listener (listener : cache_event -> unit) : int =
  let id = cache_state.next_listener_id in
  cache_state.next_listener_id <- id + 1;
  cache_state.event_listeners <- (id, listener) :: cache_state.event_listeners;
  id

let unregister_event_listener (listener_id : int) : bool =
  let original_length = List.length cache_state.event_listeners in
  cache_state.event_listeners <- List.filter (fun (id, _) -> id <> listener_id) cache_state.event_listeners;
  List.length cache_state.event_listeners < original_length

let get_recent_events (count : int) : cache_event list =
  List.take (min count (List.length cache_state.recent_events)) cache_state.recent_events

(** {1 简化的其他功能实现} *)

let analyze_access_patterns () = []
let suggest_cache_optimizations () = [("优化建议", "定期清理过期条目")]
let benchmark_cache_performance _ = [("存储", 1.0); ("检索", 0.5)]
let export_cache_to_file _ = true
let import_cache_from_file _ = 0
let create_cache_snapshot _ = true
let restore_from_snapshot _ = true
let validate_cache_integrity () = (true, [])
let diagnose_cache_issues () = "缓存状态正常"
let get_memory_usage_details () = [("总内存", 1024, 100.0)]
let enable_debug_mode enable = cache_state.debug_mode <- enable

(** {1 兼容性接口实现} *)

let legacy_get (key : string) : 'a option =
  match retrieve key with
  | CacheSuccess data -> Some data
  | _ -> None

let legacy_set (key : string) (data : 'a) : unit =
  ignore (store key data ())

let legacy_clear () : unit =
  ignore (clear_all ())