(** 缓存状态管理模块接口
    
    此模块管理全局缓存状态，包括状态初始化、
    配置管理和状态查询。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @extracted_from data_cache_manager.ml *)

open Cache_core_types

(** {1 全局缓存状态} *)

(** 全局缓存状态变量 *)
val cache_state : cache_manager_state

(** {1 缓存系统生命周期管理} *)

(** 初始化缓存系统
    @param max_size_mb 最大缓存大小（MB）
    @param max_entries 最大缓存条目数
    @param default_strategy 默认缓存策略
    @param enable_statistics 是否启用统计功能 *)
val initialize : ?max_size_mb:float -> ?max_entries:int -> 
  ?default_strategy:cache_strategy -> ?enable_statistics:bool -> unit -> unit

(** 关闭缓存系统 *)
val shutdown : unit -> unit

(** 检查是否已初始化 *)
val is_initialized : unit -> bool

(** {1 配置管理} *)

(** 配置特定键的策略
    @param key_pattern 键模式
    @param strategy 缓存策略 *)
val configure_strategy : string -> cache_strategy -> unit

(** 启用或禁用调试模式
    @param enable 是否启用调试模式 *)
val enable_debug_mode : bool -> unit

(** {1 状态查询和统计} *)

(** 获取缓存统计信息 *)
val get_statistics : unit -> cache_statistics

(** 获取所有键列表 *)
val list_all_keys : unit -> string list

(** 按模式列出键
    @param pattern 匹配模式
    @return 匹配的键列表 *)
val list_keys_by_pattern : string -> string list

(** 按标签列出键
    @param tags 标签列表
    @return 匹配的键列表 *)
val list_keys_by_tags : string list -> string list