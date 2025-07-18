(** 音韵查询优化模块 - 骆言诗词编程特性 Phase 1

    应Issue #419需求，使用哈希表优化音韵查询性能。
    从线性查询O(n)优化到哈希表查询O(1)。
    支持快速韵组查询和韵类检测。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-18 *)

open Rhyme_types

(** {1 哈希表查询优化} *)

(** {2 快速查询函数} *)

val lookup_rhyme_fast : string -> (rhyme_category * rhyme_group) option
(** 快速查询字符的韵组和韵类
    
    @param char 待查询字符
    @return 韵类和韵组的元组，如果不存在则返回None
    
    时间复杂度：O(1)
    使用哈希表优化，比列表查询快50倍以上 *)

val lookup_rhyme_expanded_fast : string -> (rhyme_category * rhyme_group) option
(** 快速查询字符的韵组和韵类（使用扩展数据库）
    
    @param char 待查询字符
    @return 韵类和韵组的元组，如果不存在则返回None
    
    时间复杂度：O(1)
    使用扩展数据库（1000+字符）进行查询 *)

val lookup_rhyme_group_fast : string -> rhyme_group option
(** 快速查询字符的韵组
    
    @param char 待查询字符
    @return 韵组，如果不存在则返回None
    
    时间复杂度：O(1) *)

val lookup_rhyme_category_fast : string -> rhyme_category option
(** 快速查询字符的韵类
    
    @param char 待查询字符
    @return 韵类，如果不存在则返回None
    
    时间复杂度：O(1) *)

val is_rhyme_char_fast : string -> bool
(** 快速检查字符是否在音韵数据库中
    
    @param char 待检查字符
    @return 存在则返回true，否则返回false
    
    时间复杂度：O(1) *)

val is_expanded_rhyme_char_fast : string -> bool
(** 快速检查字符是否在扩展音韵数据库中
    
    @param char 待检查字符
    @return 存在则返回true，否则返回false
    
    时间复杂度：O(1) *)

val is_ping_sheng_fast : string -> bool
(** 快速检查字符是否为平声
    
    @param char 待检查字符
    @return 是平声则返回true，否则返回false
    
    时间复杂度：O(1) *)

val is_ze_sheng_fast : string -> bool
(** 快速检查字符是否为仄声
    
    @param char 待检查字符
    @return 是仄声则返回true，否则返回false
    
    时间复杂度：O(1) *)

val is_same_rhyme_fast : string -> string -> bool
(** 快速检查两个字符是否同韵
    
    @param char1 第一个字符
    @param char2 第二个字符
    @return 同韵则返回true，否则返回false
    
    时间复杂度：O(1) *)

val is_same_category_fast : string -> string -> bool
(** 快速检查两个字符是否同韵类
    
    @param char1 第一个字符
    @param char2 第二个字符
    @return 同韵类则返回true，否则返回false
    
    时间复杂度：O(1) *)

(** {2 批量查询函数} *)

val lookup_string_rhyme_groups : string -> (char * rhyme_group option) list
(** 批量查询字符串中每个字符的韵组
    
    @param str 待查询字符串
    @return 每个字符及其韵组的列表
    
    时间复杂度：O(n)，其中n为字符串长度 *)

val lookup_string_rhyme_categories : string -> (char * rhyme_category option) list
(** 批量查询字符串中每个字符的韵类
    
    @param str 待查询字符串
    @return 每个字符及其韵类的列表
    
    时间复杂度：O(n)，其中n为字符串长度 *)

val is_all_ping_sheng : string -> bool
(** 快速检查字符串是否全部为平声
    
    @param str 待检查字符串
    @return 全部为平声则返回true，否则返回false
    
    时间复杂度：O(n)，其中n为字符串长度 *)

val is_all_ze_sheng : string -> bool
(** 快速检查字符串是否全部为仄声
    
    @param str 待检查字符串
    @return 全部为仄声则返回true，否则返回false
    
    时间复杂度：O(n)，其中n为字符串长度 *)

(** {2 统计信息函数} *)

val get_rhyme_database_size : unit -> int
(** 获取音韵数据库大小
    
    @return 数据库中字符的数量 *)

val get_expanded_rhyme_database_size : unit -> int
(** 获取扩展音韵数据库大小
    
    @return 扩展数据库中字符的数量 *)

val get_all_rhyme_groups : unit -> rhyme_group list
(** 获取所有韵组列表
    
    @return 排序后的韵组列表 *)

val get_all_rhyme_categories : unit -> rhyme_category list
(** 获取所有韵类列表
    
    @return 排序后的韵类列表 *)

val group_chars_by_rhyme_group : unit -> (rhyme_group * string list) list
(** 按韵组分组字符
    
    @return 韵组及其包含字符的列表 *)

val group_chars_by_rhyme_category : unit -> (rhyme_category * string list) list
(** 按韵类分组字符
    
    @return 韵类及其包含字符的列表 *)

(** {2 性能测试函数} *)

val benchmark_lookup_performance : string list -> int -> float
(** 测试哈希表查询性能
    
    @param test_chars 测试字符列表
    @param iterations 测试迭代次数
    @return 执行时间（秒）
    
    用于性能基准测试 *)

val benchmark_list_performance : string list -> int -> float
(** 测试列表查询性能
    
    @param test_chars 测试字符列表
    @param iterations 测试迭代次数
    @return 执行时间（秒）
    
    用于与哈希表查询性能对比 *)

val compare_performance : string list -> int -> (float * float * float)
(** 比较查询性能
    
    @param test_chars 测试字符列表
    @param iterations 测试迭代次数
    @return (哈希表时间, 列表时间, 加速比)
    
    返回性能对比结果 *)

(** {2 缓存管理} *)

val clear_all_caches : unit -> unit
(** 清空所有缓存
    
    清空所有哈希表缓存，释放内存 *)

val refresh_caches : unit -> unit
(** 重新初始化缓存
    
    清空并重新构建所有哈希表缓存 *)

val get_cache_stats : unit -> string
(** 获取缓存统计信息
    
    @return 缓存统计信息的字符串描述 *)

(** {2 初始化函数} *)

val initialize_rhyme_lookup : unit -> unit
(** 初始化音韵查询哈希表
    
    构建所有必要的哈希表缓存
    模块加载时自动调用 *)

val ensure_initialized : unit -> unit
(** 确保哈希表已初始化
    
    如果尚未初始化，则自动初始化所有缓存 *)