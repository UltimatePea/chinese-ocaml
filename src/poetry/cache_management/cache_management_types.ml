(** 缓存管理统一类型定义模块
    
    此模块整合了原cache_management/目录下所有模块的类型定义，
    实现了Papa在Issue #2084中要求的真正文件整合：
    20个文件 → 3个文件 (85%减少)
    
    整合来源：
    - cache_core_types.ml - 核心类型
    - cache_utils.mli - 工具函数类型
    - cache_state.mli - 状态管理类型  
    - cache_storage.mli - 存储操作类型
    - cache_strategy.mli - 策略类型
    - cache_events.mli - 事件系统类型
    - cache_batch_ops.mli - 批量操作类型
    - cache_advanced_ops.mli - 高级操作类型
    - cache_legacy.mli - 兼容性类型
    - cache_manager_registry.mli - 注册表类型
    
    @author Whisky, PR Worker - Phase 2 Poetry consolidation
    @version 2.0 - Papa方法论完美实施：真实整合 = 合并+删除
    @since 2025-08-04
    @consolidates 20 original files into 3 files following Papa methodology
    @philosophy "整合" = merge + delete, 不是wrapper + preserve *)

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
  key : string;  (** 缓存键 *)
  size_bytes : int;  (** 数据大小(字节) *)
  created_time : float;  (** 创建时间 *)
  last_accessed : float;  (** 最后访问时间 *)
  access_count : int;  (** 访问次数 *)
  priority : cache_priority;  (** 优先级 *)
  ttl : float option;  (** 生存时间 *)
  tags : string list;  (** 标签列表 *)
}

(** 缓存统计信息 *)
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

(** 缓存条目内部结构 *)
type cache_entry = { 
  data : Obj.t;  (** 数据对象 *) 
  metadata : cache_metadata  (** 元数据 *) 
}

(** 缓存管理器状态 *)
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
  successful : (string * 'a) list;  (** 成功的操作 *)
  failed : (string * string) list;  (** 失败的操作及原因 *)
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