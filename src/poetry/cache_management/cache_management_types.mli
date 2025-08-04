(** 缓存管理统一类型定义模块接口
    
    此模块整合了原cache_management/目录下所有模块的类型定义，
    实现了Papa在Issue #2084中要求的真正文件整合：
    20个文件 → 3个文件 (85%减少)
    
    @author Whisky, PR Worker - Phase 2 Poetry consolidation
    @version 2.0 - Papa方法论完美实施：真实整合 = 合并+删除
    @since 2025-08-04
    @consolidates 20 original files following Papa methodology *)

(** {1 核心缓存类型定义} *)

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

(** 缓存元数据 *)
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

(** 缓存统计信息 *)
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

(** 缓存事件类型 *)
type cache_event =
  | CacheHit of string
  | CacheMiss of string
  | CacheStore of string * int
  | CacheEvict of string * string
  | CacheExpire of string
  | CacheClear of string list

(** 缓存操作结果 *)
type 'a cache_result =
  | CacheSuccess of 'a
  | CacheError of string
  | CacheNotFound
  | CacheExpired

(** 缓存条目内部结构 *)
type cache_entry = { 
  data : Obj.t;
  metadata : cache_metadata;
}

(** 缓存管理器状态 *)
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

(** {1 批量操作类型} *)

(** 批量存储请求 *)
type 'a batch_store_request = {
  key : string;
  data : 'a;
  priority : cache_priority;
  ttl : float option;
  tags : string list;
}

(** 批量操作结果 *)
type 'a batch_result = {
  successful : (string * 'a) list;
  failed : (string * string) list;
}

(** {1 高级操作类型} *)

(** 缓存使用报告 *)
type cache_usage_report = {
  memory_usage : cache_statistics;
  top_accessed_keys : (string * int) list;
  least_accessed_keys : (string * int) list;
  expired_entries_count : int;
  fragmentation_ratio : float;
  recommended_actions : string list;
}

(** 访问模式分析结果 *)
type access_pattern_analysis = {
  access_frequency_distribution : (string * int) list;
  temporal_access_patterns : (float * string list) list;
  hot_keys : string list;
  cold_keys : string list;
  access_correlation : (string * string * float) list;
}

(** 优化建议 *)
type optimization_suggestion = {
  suggestion_type : string;
  description : string;
  expected_benefit : float;
  implementation_effort : string;
}

(** 性能基准测试结果 *)
type benchmark_result = {
  operation : string;
  avg_latency_ms : float;
  throughput_ops_per_sec : float;
  memory_usage_mb : float;
  success_rate : float;
}

(** 缓存快照 *)
type cache_snapshot = {
  timestamp : float;
  entries : (string * Obj.t * cache_metadata) list;
  statistics : cache_statistics;
  configuration : (string * cache_strategy) list;
}

(** 诊断结果 *)
type diagnostic_result = {
  issue_type : string;
  severity : string;
  description : string;
  suggested_fix : string;
  affected_keys : string list;
}

(** 内存使用详情 *)
type memory_usage_details = {
  total_allocated_mb : float;
  data_size_mb : float;
  metadata_size_mb : float;
  internal_structures_mb : float;
  fragmentation_mb : float;
  efficiency_ratio : float;
}