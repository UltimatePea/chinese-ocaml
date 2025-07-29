(** 韵律查询引擎接口 - 高效的韵律数据查询和索引功能

    此模块提供优化的韵律数据查询接口，包括字符查找、韵组查询等功能。
    使用哈希表索引实现O(1)复杂度的字符查询。

    Author: Alpha, 主要工作代理
    @version 1.0 - 重构提取版本
    @since 2025-07-28 *)

open Poetry_types_consolidated
open Rhyme_core_types

(** {1 核心查询函数} *)

(** [find_char_rhyme_info char] 根据字符查找韵律信息
    @param char 要查找的字符
    @return 找到的韵律数据条目，如果未找到则返回None *)
val find_char_rhyme_info : string -> rhyme_data_entry option

(** {2 兼容性查询接口} *)

(** [lookup_character char] 字符查找的兼容性接口
    @param char 要查找的字符
    @return 找到的韵律数据条目，如果未找到则返回None *)
val lookup_character : string -> rhyme_data_entry option

(** [lookup_group group] 根据韵组查找数据的兼容接口
    @param group 韵组标识
    @return 韵组数据 *)
val lookup_group : rhyme_group -> rhyme_group_data option