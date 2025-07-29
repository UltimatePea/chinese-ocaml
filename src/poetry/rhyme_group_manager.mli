(** 韵组管理器接口 - 韵组数据处理、统计分析和管理功能

    此模块提供优化的韵组数据处理接口，包括数据查询、统计分析等功能。 使用哈希表索引实现高效的韵组查找。

    Author: Alpha, 主要工作代理
    @version 1.0 - 重构提取版本
    @since 2025-07-28 *)

open Poetry_types_consolidated
open Rhyme_core_types

(** {1 数据访问接口} *)

val all_rhyme_entries : rhyme_data_entry list
(** 所有韵律数据条目的扁平化列表 *)

(** {2 韵组查询接口} *)

val get_rhyme_group_data : rhyme_group -> rhyme_group_data option
(** [get_rhyme_group_data group] 根据韵组获取所有数据
    @param group 韵组标识
    @return 找到的韵组数据，如果未找到则返回None *)

val get_chars_by_category : rhyme_category -> string list
(** [get_chars_by_category category] 根据韵类获取所有字符
    @param category 韵律类别
    @return 属于该类别的字符列表 *)

val get_chars_by_group : rhyme_group -> string list
(** [get_chars_by_group group] 根据韵组获取所有字符
    @param group 韵组标识
    @return 属于该韵组的字符列表 *)

(** {3 统计分析接口} *)

val get_statistics : unit -> string
(** [get_statistics ()] 获取韵律数据统计信息
    @return 包含总字符数、韵组数等统计信息的结构 *)

(** {4 兼容性接口} *)

val get_legacy_rhyme_data : unit -> rhyme_data_entry list
(** [get_legacy_rhyme_data ()] 获取遗留格式的韵律数据
    @return 旧格式的韵律数据 *)

val get_all_groups : unit -> rhyme_group_data list
(** [get_all_groups ()] 获取所有韵组列表
    @return 所有韵组的列表 *)

val get_all_entries : unit -> rhyme_data_entry list
(** [get_all_entries ()] 获取所有韵律条目
    @return 所有韵律数据条目的列表 *)

val get_all_rhyme_groups : unit -> rhyme_group list
(** [get_all_rhyme_groups ()] 获取所有韵组数据
    @return 所有韵组数据的列表 *)
