(** 缓存操作模块接口
    
    整合了缓存的高级操作、批量操作和工具函数，
    将分散的操作模块合并到统一的操作接口中。
    
    Author: Whisky, PR Worker
    Mission: 缓存操作系统真实整合，消除重复代码
    Date: 2025-08-04
    Consolidates: cache_advanced_ops.ml + cache_batch_ops.ml + cache_utils.ml *)

open Cache_engine

(** {1 工具函数} *)

(** 模式匹配函数 *)
val matches_pattern : string -> string -> bool

(** 计算缓存命中率 *)
val calculate_hit_rate : int -> int -> float

(** 比较缓存优先级 *)
val compare_priority : cache_priority -> cache_priority -> int

(** 检查标签匹配 *)
val has_matching_tags : string list -> string list -> bool

(** {1 高级操作} *)

(** 清空所有缓存 *)
val clear_all : unit -> int

(** 按模式清理缓存 *)
val clear_by_pattern : string -> int

(** 按标签清理缓存 *)
val clear_by_tags : string list -> int

(** 按优先级清理缓存 *)
val clear_by_priority : cache_priority -> int

(** 获取缓存使用报告 *)
val get_cache_usage_report : unit -> (string * int * float * float) list

(** 缓存优化建议 *)
val suggest_cache_optimizations : unit -> (string * string) list

(** {1 批量操作} *)

(** 批量存储数据 *)
val store_batch : (string * 'a * cache_priority option * float option) list -> (string * bool) list

(** 批量检索数据 *)
val retrieve_batch : string list -> (string * 'a cache_result) list

(** 批量删除数据 *)
val delete_batch : string list -> (string * bool) list

(** 批量检查存在性 *)
val exists_batch : string list -> (string * bool) list

(** 批量更新TTL *)
val update_ttl_batch : (string * float) list -> (string * bool) list

(** {1 其他高级功能} *)

(** 预加载数据源 *)
val preload_data_sources : string list -> int

(** 按模式预热缓存 *)
val warm_cache_with_pattern : string -> int

(** 优化缓存 *)
val optimize_cache : unit -> (string * int * int) list

(** 碎片整理 *)
val defragment_cache : unit -> int * int

(** 分析访问模式 *)
val analyze_access_patterns : unit -> 'a list

(** 基准测试 *)
val benchmark_cache_performance : 'a -> (string * float) list

(** 导出缓存到文件 *)
val export_cache_to_file : 'a -> bool

(** 从文件导入缓存 *)
val import_cache_from_file : 'a -> int

(** 创建缓存快照 *)
val create_cache_snapshot : 'a -> bool

(** 从快照恢复 *)
val restore_from_snapshot : 'a -> bool

(** 验证缓存完整性 *)
val validate_cache_integrity : unit -> bool * 'a list

(** 诊断缓存问题 *)
val diagnose_cache_issues : unit -> string

(** 获取内存使用详情 *)
val get_memory_usage_details : unit -> (string * int * float) list