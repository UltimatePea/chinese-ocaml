(** 缓存高级操作模块接口
    
    此模块实现缓存的高级管理操作，包括清理、优化、
    维护等高级功能。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @extracted_from data_cache_manager.ml *)

(** {1 缓存清理操作} *)

(** 清空所有缓存
    @return 清理的缓存条目数量 *)
val clear_all : unit -> int

(** 按模式清理缓存
    @param pattern 匹配模式字符串
    @return 清理的缓存条目数量 *)
val clear_by_pattern : string -> int

(** 按标签清理缓存
    @param tags 标签列表
    @return 清理的缓存条目数量 *)
val clear_by_tags : string list -> int

(** 按优先级清理缓存
    @param priority 缓存优先级
    @return 清理的缓存条目数量 *)
val clear_by_priority : Cache_core_types.cache_priority -> int