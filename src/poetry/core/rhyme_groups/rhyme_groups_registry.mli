(** 韵律组注册中心接口 - 骆言诗词编程特性

    该模块整合所有韵律组数据，提供统一的访问接口。 替代 rhyme_core_data_original.ml 的大文件结构。

    @author Beta, 代码审查代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Poetry_core.Poetry_types

(** {1 韵律组模块集成} *)

val all_rhyme_data : rhyme_data_entry list
(** 所有韵律数据的统一集合 *)

val data_by_group : (rhyme_group * rhyme_data_entry list) list
(** 按韵组分类的数据 *)

val data_by_category : (rhyme_category * rhyme_data_entry list) list
(** 按声韵类别分类的数据 *)

(** {2 韵组描述数据} *)

val rhyme_group_descriptions : (rhyme_group * string) list
(** 韵组描述信息 *)

(** {3 统计分析} *)

val char_count_by_group : (rhyme_group * int) list
(** 按韵组统计字符数量 *)

val char_count_by_category : (rhyme_category * int) list
(** 按声韵类别统计字符数量 *)

val total_char_count : int
(** 总字符数 *)

val total_group_count : int
(** 韵组总数 *)
