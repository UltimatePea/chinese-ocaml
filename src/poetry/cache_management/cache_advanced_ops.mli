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

(** {1 缓存分析和报告} *)

(** 获取缓存使用报告
    @return (key, size_bytes, age, access_frequency) 元组列表 *)
val get_cache_usage_report : unit -> (string * int * float * float) list

(** 获取缓存优化建议
    @return (问题描述, 优化建议) 元组列表 *)
val suggest_cache_optimizations : unit -> (string * string) list

(** {1 缓存优化操作} *)

(** 预加载数据源
    @param source_names 数据源名称列表
    @return 预加载的条目数量 *)
val preload_data_sources : string list -> int

(** 按模式预热缓存
    @param pattern 模式字符串
    @return 预热的条目数量 *)
val warm_cache_with_pattern : string -> int

(** 优化缓存
    @return (优化操作, 优化前大小, 优化后大小) 元组列表 *)
val optimize_cache : unit -> (string * int * int) list

(** 整理缓存碎片
    @return (整理前碎片数, 整理后碎片数) *)
val defragment_cache : unit -> int * int

(** {1 缓存监控和维护} *)

(** 分析访问模式
    @return 访问模式分析结果 *)
val analyze_access_patterns : unit -> 'a list

(** 基准测试缓存性能
    @param test_type 测试类型
    @return (操作类型, 平均时间) 元组列表 *)
val benchmark_cache_performance : 'a -> (string * float) list

(** {1 缓存导入导出} *)

(** 导出缓存到文件
    @param filename 文件名
    @return 导出是否成功 *)
val export_cache_to_file : 'a -> bool

(** 从文件导入缓存
    @param filename 文件名
    @return 导入的条目数量 *)
val import_cache_from_file : 'a -> int

(** {1 缓存快照和恢复} *)

(** 创建缓存快照
    @param snapshot_name 快照名称
    @return 创建是否成功 *)
val create_cache_snapshot : 'a -> bool

(** 从快照恢复
    @param snapshot_name 快照名称
    @return 恢复是否成功 *)
val restore_from_snapshot : 'a -> bool

(** {1 缓存诊断} *)

(** 验证缓存完整性
    @return (完整性检查结果, 错误列表) *)
val validate_cache_integrity : unit -> bool * 'a list

(** 诊断缓存问题
    @return 诊断结果描述 *)
val diagnose_cache_issues : unit -> string

(** 获取内存使用详情
    @return (内存区域, 大小KB, 使用百分比) 元组列表 *)
val get_memory_usage_details : unit -> (string * int * float) list