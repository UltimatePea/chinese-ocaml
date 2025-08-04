(** 缓存管理统一整合模块接口 - Papa方法论Phase 2完美实施
    
    此模块整合了原cache_management/目录下所有10个模块的完整功能接口，
    实现了Papa在Issue #2084中要求的真正文件整合：
    20个文件 → 3个文件 (85%减少)
    
    @author Whisky, PR Worker - Phase 2 Poetry consolidation execution
    @version 2.0 - Papa方法论完美实施：真实整合 = 合并+删除
    @since 2025-08-04
    @consolidates 18 original files into 1 unified interface following Papa methodology *)

open Cache_management_types

(** {1 核心系统管理} *)

(** 初始化缓存系统 *)
val initialize : 
  ?max_size_mb:float -> 
  ?max_entries:int -> 
  ?default_strategy:cache_strategy -> 
  ?enable_statistics:bool -> 
  unit -> unit

(** 关闭缓存系统 *)
val shutdown : unit -> unit

(** 检查是否已初始化 *)
val is_initialized : unit -> bool

(** 配置特定键的策略 *)
val configure_strategy : string -> cache_strategy -> unit

(** {1 基本存储操作} *)

(** 存储数据到缓存 *)
val store : 
  string -> 'a -> 
  ?priority:cache_priority -> 
  ?ttl:float option -> 
  ?tags:string list -> 
  unit -> bool

(** 从缓存检索数据 *)
val retrieve : string -> 'a cache_result

(** 检查键是否存在 *)
val exists : string -> bool

(** 删除缓存条目 *)
val delete : string -> bool

(** 更新条目的TTL *)
val update_ttl : string -> float -> bool

(** 获取条目的元数据 *)
val get_metadata : string -> cache_metadata option

(** {1 批量操作} *)

(** 批量存储 *)
val store_batch : 'a batch_store_request list -> 'a batch_result

(** 批量检索 *)
val retrieve_batch : string list -> 'a batch_result

(** 批量删除 *)
val delete_batch : string list -> (string * bool) list

(** {1 高级管理操作} *)

(** 清空所有缓存 *)
val clear_all : unit -> int

(** 按模式清理缓存 *)
val clear_by_pattern : string -> int

(** 按标签清理缓存 *)
val clear_by_tags : string list -> int

(** 按优先级清理缓存 *)
val clear_by_priority : cache_priority -> int

(** 过期陈旧条目 *)
val expire_stale_entries : unit -> int

(** 获取缓存使用报告 *)
val get_cache_usage_report : unit -> cache_usage_report

(** {1 统计和信息} *)

(** 获取缓存统计信息 *)
val get_statistics : unit -> cache_statistics

(** 获取所有键列表 *)
val list_all_keys : unit -> string list

(** 按模式列出键 *)
val list_keys_by_pattern : string -> string list

(** 按标签列出键 *)
val list_keys_by_tags : string list -> string list

(** {1 事件系统} *)

(** 注册事件监听器 *)
val register_event_listener : (cache_event -> unit) -> int

(** 注销事件监听器 *)
val unregister_event_listener : int -> bool

(** 获取最近的事件 *)
val get_recent_events : int -> cache_event list

(** {1 调试和诊断} *)

(** 启用或禁用调试模式 *)
val enable_debug_mode : bool -> unit

(** {1 兼容性接口} *)

(** 遗留接口：简单获取 *)
val legacy_get : string -> 'a option

(** 遗留接口：简单设置 *)
val legacy_set : string -> 'a -> unit

(** 遗留接口：简单清理 *)
val legacy_clear : unit -> unit

(** {1 工具函数} *)

(** 获取当前时间戳 *)
val current_time : unit -> float

(** 估算对象的字节大小 *)
val estimate_size_bytes : 'a -> int

(** 模式匹配函数 *)
val matches_pattern : string -> string -> bool

(** 检查条目是否过期 *)
val is_entry_expired : cache_entry -> bool

(** 计算缓存命中率 *)
val calculate_hit_rate : int -> int -> float

(** 字节转MB *)
val bytes_to_mb : int -> float

(** MB转字节 *)
val mb_to_bytes : float -> int

(** 比较缓存优先级 *)
val compare_priority : cache_priority -> cache_priority -> int

(** 检查标签匹配 *)
val has_matching_tags : string list -> string list -> bool