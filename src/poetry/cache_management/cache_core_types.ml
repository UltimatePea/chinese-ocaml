(** 缓存管理核心类型定义
    
    此模块定义了缓存系统的核心类型和数据结构，
    为整个缓存管理系统提供统一的类型基础。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @replaces data_cache_manager.ml (types section) *)

(** 缓存策略类型 *)
type cache_strategy =
  | LRU           (** 最近最少使用 *)
  | LFU           (** 最少使用频率 *)
  | FIFO          (** 先进先出 *)
  | TTL of float  (** 生存时间 *)
  | Custom of (string -> bool) (** 自定义策略 *)

(** 缓存优先级 *)
type cache_priority =
  | Critical      (** 关键数据，不可轻易删除 *)
  | High          (** 高优先级 *)
  | Normal        (** 普通优先级 *)
  | Low           (** 低优先级 *)
  | Disposable    (** 可丢弃数据 *)

(** 缓存元数据 *)
type cache_metadata = {
  key : string;                     (** 缓存键 *)
  size_bytes : int;                 (** 数据大小(字节) *)
  created_time : float;             (** 创建时间 *)
  last_accessed : float;            (** 最后访问时间 *)
  access_count : int;               (** 访问次数 *)
  priority : cache_priority;        (** 优先级 *)
  ttl : float option;               (** 生存时间 *)
  tags : string list;               (** 标签列表 *)
}

(** 缓存统计信息 *)
type cache_statistics = {
  total_entries : int;              (** 总条目数 *)
  total_size_bytes : int;           (** 总大小(字节) *)
  hit_count : int;                  (** 命中次数 *)
  miss_count : int;                 (** 未命中次数 *)
  eviction_count : int;             (** 驱逐次数 *)
  hit_rate : float;                 (** 命中率 *)
  avg_access_time : float;          (** 平均访问时间 *)
  memory_usage_mb : float;          (** 内存使用量(MB) *)
}

(** 缓存事件类型 *)
type cache_event =
  | CacheHit of string              (** 缓存命中 *)
  | CacheMiss of string             (** 缓存未命中 *)
  | CacheStore of string * int      (** 缓存存储 *)
  | CacheEvict of string * string   (** 缓存驱逐 *)
  | CacheExpire of string           (** 缓存过期 *)
  | CacheClear of string list       (** 缓存清理 *)

(** 缓存操作结果 *)
type 'a cache_result =
  | CacheSuccess of 'a              (** 成功 *)
  | CacheError of string            (** 错误 *)
  | CacheNotFound                   (** 未找到 *)
  | CacheExpired                    (** 已过期 *)

(** 缓存条目内部结构 *)
type cache_entry = {
  data : Obj.t;                     (** 数据对象 *)
  metadata : cache_metadata;        (** 元数据 *)
}

(** 缓存管理器状态 *)
type cache_manager_state = {
  mutable data_map : (string, cache_entry) Hashtbl.t;  (** 数据映射 *)
  mutable strategies : (string, cache_strategy) Hashtbl.t; (** 策略映射 *)
  mutable max_size_mb : float;                          (** 最大大小(MB) *)
  mutable max_entries : int;                            (** 最大条目数 *)
  mutable current_size_bytes : int;                     (** 当前大小 *)
  mutable hit_count : int;                              (** 命中计数 *)
  mutable miss_count : int;                             (** 未命中计数 *)
  mutable eviction_count : int;                         (** 驱逐计数 *)
  mutable total_access_time : float;                    (** 总访问时间 *)
  mutable total_accesses : int;                         (** 总访问次数 *)
  mutable event_listeners : (int * (cache_event -> unit)) list; (** 事件监听器 *)
  mutable next_listener_id : int;                       (** 下一个监听器ID *)
  mutable recent_events : cache_event list;             (** 最近事件 *)
  mutable initialized : bool;                           (** 初始化状态 *)
  mutable debug_mode : bool;                            (** 调试模式 *)
}