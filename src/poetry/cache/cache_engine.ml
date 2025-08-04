(** 缓存引擎核心模块
    
    整合了缓存的核心类型、状态管理和存储操作，
    将分散的缓存模块合并到统一的核心引擎中。
    
    Author: Whisky, PR Worker  
    Mission: 缓存管理系统真实整合，消除重复代码
    Date: 2025-08-04
    Consolidates: cache_core_types.ml + cache_state.ml + cache_storage.ml *)

(** {1 缓存核心类型定义} *)

(* 来源: cache_core_types.ml *)

(** 缓存策略类型 *)
type cache_strategy =
  | LRU  (** 最近最少使用 *)
  | LFU  (** 最少使用频率 *)
  | FIFO  (** 先进先出 *)
  | TTL of float  (** 生存时间 *)
  | Custom of (string -> bool)  (** 自定义策略 *)

(** 缓存优先级 *)
type cache_priority =
  | Critical  (** 关键数据，不可轻易删除 *)
  | High  (** 高优先级 *)
  | Normal  (** 普通优先级 *)
  | Low  (** 低优先级 *)
  | Disposable  (** 可丢弃数据 *)

type cache_metadata = {
  key : string;  (** 缓存键 *)
  size_bytes : int;  (** 数据大小(字节) *)
  created_time : float;  (** 创建时间 *)
  last_accessed : float;  (** 最后访问时间 *)
  access_count : int;  (** 访问次数 *)
  priority : cache_priority;  (** 优先级 *)
  ttl : float option;  (** 生存时间 *)
  tags : string list;  (** 标签列表 *)
}

type cache_statistics = {
  total_entries : int;  (** 总条目数 *)
  total_size_bytes : int;  (** 总大小(字节) *)
  hit_count : int;  (** 命中次数 *)
  miss_count : int;  (** 未命中次数 *)
  eviction_count : int;  (** 驱逐次数 *)
  hit_rate : float;  (** 命中率 *)
  avg_access_time : float;  (** 平均访问时间 *)
  memory_usage_mb : float;  (** 内存使用量(MB) *)
}

(** 缓存事件类型 *)
type cache_event =
  | CacheHit of string  (** 缓存命中 *)
  | CacheMiss of string  (** 缓存未命中 *)
  | CacheStore of string * int  (** 缓存存储 *)
  | CacheEvict of string * string  (** 缓存驱逐 *)
  | CacheExpire of string  (** 缓存过期 *)
  | CacheClear of string list  (** 缓存清理 *)

(** 缓存操作结果 *)
type 'a cache_result =
  | CacheSuccess of 'a  (** 成功 *)
  | CacheError of string  (** 错误 *)
  | CacheNotFound  (** 未找到 *)
  | CacheExpired  (** 已过期 *)

type cache_entry = { 
  data : Obj.t;  (** 数据对象 *) 
  metadata : cache_metadata  (** 元数据 *) 
}

type cache_manager_state = {
  mutable data_map : (string, cache_entry) Hashtbl.t;  (** 数据映射 *)
  mutable strategies : (string, cache_strategy) Hashtbl.t;  (** 策略映射 *)
  mutable max_size_mb : float;  (** 最大大小(MB) *)
  mutable max_entries : int;  (** 最大条目数 *)
  mutable current_size_bytes : int;  (** 当前大小 *)
  mutable hit_count : int;  (** 命中计数 *)
  mutable miss_count : int;  (** 未命中计数 *)
  mutable eviction_count : int;  (** 驱逐计数 *)
  mutable total_access_time : float;  (** 总访问时间 *)
  mutable total_accesses : int;  (** 总访问次数 *)
  mutable event_listeners : (int * (cache_event -> unit)) list;  (** 事件监听器 *)
  mutable next_listener_id : int;  (** 下一个监听器ID *)
  mutable recent_events : cache_event list;  (** 最近事件 *)
  mutable initialized : bool;  (** 初始化状态 *)
  mutable debug_mode : bool;  (** 调试模式 *)
}

(** {1 缓存状态管理} *)

(* 来源: cache_state.ml *)

(** 全局缓存状态 *)
let cache_state = {
  data_map = Hashtbl.create 256;
  strategies = Hashtbl.create 32;
  max_size_mb = 100.0;
  max_entries = 1000;
  current_size_bytes = 0;
  hit_count = 0;
  miss_count = 0;
  eviction_count = 0;
  total_access_time = 0.0;
  total_accesses = 0;
  event_listeners = [];
  next_listener_id = 0;
  recent_events = [];
  initialized = false;
  debug_mode = false;
}

(** 初始化缓存系统 *)
let initialize ?(max_size_mb = 100.0) ?(max_entries = 1000) ?(debug = false) () : unit =
  cache_state.max_size_mb <- max_size_mb;
  cache_state.max_entries <- max_entries;
  cache_state.debug_mode <- debug;
  cache_state.initialized <- true;
  if debug then Printf.printf "[缓存] 初始化完成，最大大小: %.1fMB, 最大条目数: %d\n" max_size_mb max_entries

(** 获取统计信息 *)
let get_statistics () : cache_statistics =
  let total_entries = Hashtbl.length cache_state.data_map in
  let hit_rate = 
    if cache_state.hit_count + cache_state.miss_count = 0 then 0.0
    else float_of_int cache_state.hit_count /. float_of_int (cache_state.hit_count + cache_state.miss_count)
  in
  let avg_access_time =
    if cache_state.total_accesses = 0 then 0.0
    else cache_state.total_access_time /. float_of_int cache_state.total_accesses
  in
  let memory_usage_mb = float_of_int cache_state.current_size_bytes /. (1024.0 *. 1024.0) in
  {
    total_entries;
    total_size_bytes = cache_state.current_size_bytes;
    hit_count = cache_state.hit_count;
    miss_count = cache_state.miss_count;
    eviction_count = cache_state.eviction_count;
    hit_rate;
    avg_access_time;
    memory_usage_mb;
  }

(** 重置统计信息 *)
let reset_statistics () : unit =
  cache_state.hit_count <- 0;
  cache_state.miss_count <- 0;
  cache_state.eviction_count <- 0;
  cache_state.total_access_time <- 0.0;
  cache_state.total_accesses <- 0

(** {1 工具函数} *)

(** 获取当前时间戳 *)
let current_time () = Unix.time ()

(** 估算对象的字节大小 *)
let estimate_size_bytes (obj : 'a) : int =
  try
    let size = Obj.size (Obj.repr obj) in
    if size > 0 then size * 8 else 64
  with _ -> 64

(** 检查条目是否过期 *)
let is_entry_expired (entry : cache_entry) : bool =
  match entry.metadata.ttl with
  | None -> false
  | Some ttl ->
      let current = current_time () in
      current -. entry.metadata.created_time > ttl

(** 字节转MB *)
let bytes_to_mb (bytes : int) : float = 
  float_of_int bytes /. (1024.0 *. 1024.0)

(** MB转字节 *)
let mb_to_bytes (mb : float) : int = 
  int_of_float (mb *. 1024.0 *. 1024.0)

(** {1 事件处理} *)

(** 触发缓存事件 *)
let fire_event (event : cache_event) : unit =
  cache_state.recent_events <- event :: (List.take 100 cache_state.recent_events);
  List.iter (fun (_, handler) -> 
    try handler event with _ -> ()
  ) cache_state.event_listeners;
  if cache_state.debug_mode then (
    match event with
    | CacheHit key -> Printf.printf "[缓存] 命中: %s\n" key
    | CacheMiss key -> Printf.printf "[缓存] 未命中: %s\n" key
    | CacheStore (key, size) -> Printf.printf "[缓存] 存储: %s (%d字节)\n" key size
    | CacheEvict (key, reason) -> Printf.printf "[缓存] 驱逐: %s (原因: %s)\n" key reason
    | CacheExpire key -> Printf.printf "[缓存] 过期: %s\n" key
    | CacheClear keys -> Printf.printf "[缓存] 清理: %d个条目\n" (List.length keys)
  )

(** 列表截取函数 *)
and take n lst =
  let rec aux acc count = function
    | [] -> List.rev acc
    | _ when count <= 0 -> List.rev acc
    | x :: xs -> aux (x :: acc) (count - 1) xs
  in
  aux [] n lst

(** {1 缓存存储操作} *)

(* 来源: cache_storage.ml *)

(** 存储数据到缓存 *)
let store (key : string) (data : 'a) ?(priority = Normal) ?ttl () : bool =
  try
    let start_time = current_time () in
    let size = estimate_size_bytes data in
    
    (* 检查是否超过大小限制 *)
    let projected_size = cache_state.current_size_bytes + size in
    if bytes_to_mb projected_size > cache_state.max_size_mb then (
      if cache_state.debug_mode then 
        Printf.printf "[缓存] 存储失败: %s，大小超限\n" key;
      false
    ) else (
      let metadata = {
        key;
        size_bytes = size;
        created_time = start_time;
        last_accessed = start_time;
        access_count = 0;
        priority;
        ttl;
        tags = [];
      } in
      let entry = { data = Obj.repr data; metadata } in
      
      (* 如果key已存在，先移除旧数据 *)
      (match Hashtbl.find_opt cache_state.data_map key with
       | Some old_entry -> 
           cache_state.current_size_bytes <- cache_state.current_size_bytes - old_entry.metadata.size_bytes
       | None -> ());
      
      Hashtbl.replace cache_state.data_map key entry;
      cache_state.current_size_bytes <- cache_state.current_size_bytes + size;
      
      fire_event (CacheStore (key, size));
      true
    )
  with _ -> false

(** 从缓存检索数据 *)
let retrieve (key : string) : 'a cache_result =
  let start_time = current_time () in
  match Hashtbl.find_opt cache_state.data_map key with
  | None ->
      cache_state.miss_count <- cache_state.miss_count + 1;
      fire_event (CacheMiss key);
      CacheNotFound
  | Some entry ->
      if is_entry_expired entry then (
        Hashtbl.remove cache_state.data_map key;
        cache_state.current_size_bytes <- cache_state.current_size_bytes - entry.metadata.size_bytes;
        fire_event (CacheExpire key);
        CacheExpired
      ) else (
        (* 更新访问统计 *)
        let updated_metadata = {
          entry.metadata with
          last_accessed = start_time;
          access_count = entry.metadata.access_count + 1;
        } in
        let updated_entry = { entry with metadata = updated_metadata } in
        Hashtbl.replace cache_state.data_map key updated_entry;
        
        cache_state.hit_count <- cache_state.hit_count + 1;
        cache_state.total_accesses <- cache_state.total_accesses + 1;
        cache_state.total_access_time <- cache_state.total_access_time +. (current_time () -. start_time);
        
        fire_event (CacheHit key);
        CacheSuccess (Obj.obj entry.data)
      )

(** 删除缓存条目 *)
let delete (key : string) : bool =
  match Hashtbl.find_opt cache_state.data_map key with
  | None -> false
  | Some entry ->
      Hashtbl.remove cache_state.data_map key;
      cache_state.current_size_bytes <- cache_state.current_size_bytes - entry.metadata.size_bytes;
      fire_event (CacheEvict (key, "手动删除"));
      true

(** 检查条目是否存在 *)
let exists (key : string) : bool =
  match Hashtbl.find_opt cache_state.data_map key with
  | None -> false
  | Some entry -> not (is_entry_expired entry)

(** 更新TTL *)
let update_ttl (key : string) (ttl : float) : bool =
  match Hashtbl.find_opt cache_state.data_map key with
  | None -> false
  | Some entry ->
      let updated_metadata = { entry.metadata with ttl = Some ttl } in
      let updated_entry = { entry with metadata = updated_metadata } in
      Hashtbl.replace cache_state.data_map key updated_entry;
      true

(** 获取条目元数据 *)
let get_metadata (key : string) : cache_metadata option =
  match Hashtbl.find_opt cache_state.data_map key with
  | None -> None
  | Some entry -> Some entry.metadata

(** 列出所有缓存键 *)
let list_keys () : string list =
  Hashtbl.fold (fun key _ acc -> key :: acc) cache_state.data_map []

(** 获取缓存大小信息 *)
let get_size_info () : int * float * int * int =
  let total_entries = Hashtbl.length cache_state.data_map in
  let memory_usage_mb = bytes_to_mb cache_state.current_size_bytes in
  (total_entries, memory_usage_mb, cache_state.current_size_bytes, cache_state.max_entries)