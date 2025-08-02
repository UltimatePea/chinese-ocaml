(** 缓存工具函数模块接口
    
    此模块提供缓存系统需要的通用工具函数，
    包括时间处理、大小估算、字符串匹配等。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 数据缓存管理器模块化重构
    @since 2025-07-30
    @extracted_from data_cache_manager.ml *)

open Cache_core_types

(** {1 时间相关工具} *)

(** 获取当前时间戳 *)
val current_time : unit -> float

(** 检查条目是否过期
    @param entry 缓存条目
    @return 是否已过期 *)
val is_entry_expired : cache_entry -> bool

(** {1 大小和内存工具} *)

(** 估算对象的字节大小
    @param obj 要估算大小的对象
    @return 估算的字节大小 *)
val estimate_size_bytes : 'a -> int

(** 字节转MB
    @param bytes 字节数
    @return MB数 *)
val bytes_to_mb : int -> float

(** MB转字节
    @param mb MB数
    @return 字节数 *)
val mb_to_bytes : float -> int

(** {1 字符串和模式匹配工具} *)

(** 模式匹配函数
    @param pattern 匹配模式
    @param text 要匹配的文本
    @return 是否匹配 *)
val matches_pattern : string -> string -> bool

(** 检查标签匹配
    @param entry_tags 条目的标签列表
    @param target_tags 目标标签列表
    @return 是否有匹配的标签 *)
val has_matching_tags : string list -> string list -> bool

(** {1 列表工具} *)

(** 列表截取函数
    @param n 要截取的元素数量
    @param lst 源列表
    @return 截取后的列表 *)
val take : int -> 'a list -> 'a list

(** {1 统计和比较工具} *)

(** 计算缓存命中率
    @param hit_count 命中次数
    @param miss_count 未命中次数
    @return 命中率（0.0-1.0） *)
val calculate_hit_rate : int -> int -> float

(** 比较缓存优先级
    @param p1 优先级1
    @param p2 优先级2
    @return 比较结果（-1, 0, 1） *)
val compare_priority : cache_priority -> cache_priority -> int