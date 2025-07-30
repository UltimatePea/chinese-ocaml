(** 缓存管理核心类型定义接口 *)

(** 缓存策略类型 *)
type cache_strategy = LRU | LFU | FIFO | TTL of float | Custom of (string -> bool)

(** 缓存优先级 *)
type cache_priority = Critical | High | Normal | Low | Disposable

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
(** 缓存元数据 *)

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
(** 缓存统计信息 *)

(** 缓存事件类型 *)
type cache_event =
  | CacheHit of string
  | CacheMiss of string
  | CacheStore of string * int
  | CacheEvict of string * string
  | CacheExpire of string
  | CacheClear of string list

(** 缓存操作结果 *)
type 'a cache_result = CacheSuccess of 'a | CacheError of string | CacheNotFound | CacheExpired

type cache_entry = { data : Obj.t; metadata : cache_metadata }
(** 缓存条目内部结构 *)

type cache_manager_state = {
  mutable data_map : (string, cache_entry) Hashtbl.t;
  mutable strategies : (string, cache_strategy) Hashtbl.t;
  mutable max_size_mb : float;
  mutable max_entries : int;
  mutable current_size_bytes : int;
  mutable hit_count : int;
  mutable miss_count : int;
  mutable eviction_count : int;
  mutable total_access_time : float;
  mutable total_accesses : int;
  mutable event_listeners : (int * (cache_event -> unit)) list;
  mutable next_listener_id : int;
  mutable recent_events : cache_event list;
  mutable initialized : bool;
  mutable debug_mode : bool;
}
(** 缓存管理器状态 *)
