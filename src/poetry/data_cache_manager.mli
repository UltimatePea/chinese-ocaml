(** 数据缓存管理器 - Phase 2.3.2 统一缓存管理模块

    本模块提供高级的缓存管理功能，包括智能缓存策略、缓存预热、缓存失效管理等。
    为统一数据引擎提供性能优化和缓存策略支持。

    @author Alpha, 主要工作代理 - Phase 2.3.2 数据加载器系统整合  
    @version 2.3.2
    @since 2025-07-30 *)

(** {1 缓存管理类型定义} *)

(** 缓存策略类型 *)
type cache_strategy =
  | LRU           (** 最近最少使用 *)
  | LFU           (** 最少使用频率 *)
  | FIFO          (** 先进先出 *)
  | TTL of float  (** 生存时间（秒） *)
  | Custom of (string -> bool)  (** 自定义策略 *)

(** 缓存优先级 *)
type cache_priority =
  | Critical      (** 关键数据，优先保留 *)
  | High          (** 高优先级 *)
  | Normal        (** 普通优先级 *)
  | Low           (** 低优先级 *)
  | Disposable    (** 可丢弃的临时数据 *)

(** 缓存项元数据 *)
type cache_metadata = {
  key : string;                     (** 缓存键 *)
  size_bytes : int;                 (** 数据大小（字节） *)
  created_time : float;             (** 创建时间 *)
  last_accessed : float;            (** 最后访问时间 *)
  access_count : int;               (** 访问次数 *)
  priority : cache_priority;        (** 优先级 *)
  ttl : float option;               (** 生存时间 *)
  tags : string list;               (** 标签 *)
}

(** 缓存统计信息 *)
type cache_statistics = {
  total_entries : int;              (** 总条目数 *)
  total_size_bytes : int;           (** 总大小（字节） *)
  hit_count : int;                  (** 命中次数 *)
  miss_count : int;                 (** 未命中次数 *)
  eviction_count : int;             (** 淘汰次数 *)
  hit_rate : float;                 (** 命中率 *)
  avg_access_time : float;          (** 平均访问时间（毫秒） *)
  memory_usage_mb : float;          (** 内存使用量（MB） *)
}

(** 缓存事件类型 *)
type cache_event =
  | CacheHit of string              (** 缓存命中 *)
  | CacheMiss of string             (** 缓存未命中 *)
  | CacheStore of string * int      (** 缓存存储 (key, size) *)
  | CacheEvict of string * string   (** 缓存淘汰 (key, reason) *)
  | CacheExpire of string           (** 缓存过期 *)
  | CacheClear of string list       (** 缓存清除 (keys) *)

(** 缓存结果类型 *)
type 'a cache_result =
  | CacheSuccess of 'a
  | CacheNotFound
  | CacheError of string

(** {1 缓存管理器初始化和配置} *)

val initialize : 
  ?max_size_mb:float -> 
  ?max_entries:int -> 
  ?default_strategy:cache_strategy -> 
  ?enable_statistics:bool -> 
  unit -> unit
(** 初始化缓存管理器

    @param max_size_mb 最大缓存大小（MB），默认100MB
    @param max_entries 最大条目数，默认10000
    @param default_strategy 默认缓存策略，默认LRU
    @param enable_statistics 是否启用统计，默认true *)

val shutdown : unit -> unit
(** 关闭缓存管理器，清理所有资源 *)

val is_initialized : unit -> bool
(** 检查是否已初始化 *)

val configure_strategy : string -> cache_strategy -> unit
(** 为特定键模式配置缓存策略

    @param key_pattern 键模式（支持通配符）
    @param strategy 缓存策略 *)

(** {1 基础缓存操作} *)

val store : 
  string -> 
  'a -> 
  ?priority:cache_priority -> 
  ?ttl:float option -> 
  ?tags:string list -> 
  unit -> bool
(** 存储数据到缓存

    @param key 缓存键
    @param data 数据
    @param priority 优先级（可选）
    @param ttl 生存时间（秒，可选）
    @param tags 标签列表（可选）
    @return 是否成功存储 *)

val retrieve : string -> 'a cache_result
(** 从缓存检索数据

    @param key 缓存键
    @return 缓存结果 *)

val exists : string -> bool
(** 检查缓存项是否存在

    @param key 缓存键 *)

val delete : string -> bool
(** 删除缓存项

    @param key 缓存键
    @return 是否成功删除 *)

val update_ttl : string -> float -> bool
(** 更新缓存项的TTL

    @param key 缓存键
    @param new_ttl 新的生存时间（秒）
    @return 是否成功更新 *)

(** {1 批量操作} *)

val store_batch : (string * 'a * cache_priority option * float option) list -> (string * bool) list
(** 批量存储数据

    @param items (key, data, priority, ttl) 列表
    @return (key, success) 结果列表 *)

val retrieve_batch : string list -> (string * 'a cache_result) list
(** 批量检索数据

    @param keys 键列表
    @return (key, result) 结果列表 *)

val delete_batch : string list -> (string * bool) list
(** 批量删除数据

    @param keys 键列表
    @return (key, success) 结果列表 *)

(** {1 高级缓存管理} *)

val clear_all : unit -> int
(** 清除所有缓存

    @return 清除的条目数 *)

val clear_by_pattern : string -> int
(** 按模式清除缓存

    @param pattern 键模式（支持通配符）
    @return 清除的条目数 *)

val clear_by_tags : string list -> int
(** 按标签清除缓存

    @param tags 标签列表
    @return 清除的条目数 *)

val clear_by_priority : cache_priority -> int
(** 按优先级清除缓存

    @param priority 优先级
    @return 清除的条目数 *)

val expire_stale_entries : ?max_age:float option -> unit -> int
(** 清除过期条目

    @param max_age 最大年龄（秒），默认使用TTL
    @return 清除的条目数 *)

(** {1 缓存预热和优化} *)

val preload_data_sources : string list -> int
(** 预加载数据源到缓存

    @param source_names 数据源名称列表
    @return 成功预加载的数据源数量 *)

val warm_cache_with_pattern : string -> int
(** 使用模式预热缓存

    @param pattern 数据模式
    @return 预热的条目数 *)

val optimize_cache : unit -> (string * int * int) list
(** 优化缓存性能

    @return (优化类型, 处理条目数, 节省字节数) 列表 *)

val defragment_cache : unit -> (int * int)
(** 整理缓存碎片

    @return (原始条目数, 整理后条目数) *)

(** {1 缓存监控和统计} *)

val get_statistics : unit -> cache_statistics
(** 获取缓存统计信息 *)

val get_metadata : string -> cache_metadata option
(** 获取缓存项元数据

    @param key 缓存键 *)

val list_all_keys : unit -> string list
(** 列出所有缓存键 *)

val list_keys_by_pattern : string -> string list
(** 按模式列出缓存键

    @param pattern 键模式 *)

val list_keys_by_tags : string list -> string list
(** 按标签列出缓存键

    @param tags 标签列表 *)

val get_cache_usage_report : unit -> (string * int * float * float) list
(** 获取缓存使用报告

    @return (key, access_count, size_mb, hit_rate) 列表 *)

(** {1 事件监听和回调} *)

val register_event_listener : (cache_event -> unit) -> int
(** 注册缓存事件监听器

    @param listener 事件处理函数
    @return 监听器ID *)

val unregister_event_listener : int -> bool
(** 注销事件监听器

    @param listener_id 监听器ID
    @return 是否成功注销 *)

val get_recent_events : int -> cache_event list
(** 获取最近的缓存事件

    @param count 事件数量限制
    @return 事件列表 *)

(** {1 性能分析和调优} *)

val analyze_access_patterns : unit -> (string * int * float) list
(** 分析访问模式

    @return (key_pattern, access_frequency, avg_response_time) 列表 *)

val suggest_cache_optimizations : unit -> (string * string) list
(** 建议缓存优化

    @return (优化建议类型, 详细描述) 列表 *)

val benchmark_cache_performance : int -> (string * float) list
(** 基准测试缓存性能

    @param iterations 测试迭代次数
    @return (操作类型, 平均时间毫秒) 列表 *)

(** {1 持久化和备份} *)

val export_cache_to_file : string -> bool
(** 导出缓存到文件

    @param filepath 文件路径
    @return 是否成功导出 *)

val import_cache_from_file : string -> int
(** 从文件导入缓存

    @param filepath 文件路径
    @return 导入的条目数 *)

val create_cache_snapshot : string -> bool
(** 创建缓存快照

    @param snapshot_name 快照名称
    @return 是否成功创建 *)

val restore_from_snapshot : string -> bool
(** 从快照恢复缓存

    @param snapshot_name 快照名称
    @return 是否成功恢复 *)

(** {1 调试和诊断} *)

val validate_cache_integrity : unit -> (bool * string list)
(** 验证缓存完整性

    @return (是否通过验证, 错误信息列表) *)

val diagnose_cache_issues : unit -> string
(** 诊断缓存问题

    @return 诊断报告 *)

val get_memory_usage_details : unit -> (string * int * float) list
(** 获取内存使用详情

    @return (内存区域, 使用字节数, 使用百分比) 列表 *)

val enable_debug_mode : bool -> unit
(** 启用/禁用调试模式

    @param enable 是否启用 *)

(** {1 兼容性接口} *)

val legacy_get : string -> 'a option
(** 兼容性接口：简单获取缓存数据

    @deprecated 建议使用 retrieve
    @param key 缓存键 *)

val legacy_set : string -> 'a -> unit
(** 兼容性接口：简单设置缓存数据

    @deprecated 建议使用 store
    @param key 缓存键
    @param data 数据 *)

val legacy_clear : unit -> unit
(** 兼容性接口：清除所有缓存

    @deprecated 建议使用 clear_all *)