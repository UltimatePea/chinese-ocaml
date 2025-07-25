(** 韵律核心数据模块接口 - 骆言诗词编程特性

    此模块统一管理所有韵律数据，消除项目中30+文件的数据重复问题。

    @author 骆言诗词编程团队
    @version 3.0 - 核心重构版本
    @since 2025-07-25 *)

open Rhyme_core_types

(** {1 数据创建辅助函数} *)

val make_entry :
  string ->
  rhyme_category ->
  rhyme_group ->
  ?variants:string list ->
  ?frequency:float ->
  unit ->
  rhyme_data_entry
(** 创建韵律数据条目 *)

val make_group_entries : rhyme_category -> rhyme_group -> string list -> rhyme_data_entry list
(** 为某个韵组创建字符列表对应的数据条目 *)

(** {2 基础韵律数据集} *)

val all_rhyme_data : rhyme_data_entry list
(** 所有韵律数据的统一集合 *)

val data_by_group : (rhyme_group * rhyme_data_entry list) list
(** 按韵组分类的数据 *)

val data_by_category : (rhyme_category * rhyme_data_entry list) list
(** 按声韵类别分类的数据 *)

(** {3 韵组描述和示例} *)

val rhyme_group_descriptions : (rhyme_group * string) list
(** 韵组描述信息 *)

val example_poems_by_group : (rhyme_group * string list) list
(** 按韵组分类的典型诗句示例 *)

(** {4 性能优化查找} *)

val find_character_rhyme_fast : string -> rhyme_data_entry option
(** 优化的字符快速查找函数 - 使用 Map 实现 O(log n) 查找 *)

(** {5 统计信息} *)

val total_characters : int
(** 总字符数量 *)

val groups_count : int
(** 韵组数量 *)

val categories_count : int
(** 声韵类别数量 *)

val character_count_by_group : (rhyme_group * int) list
(** 按韵组统计字符数量 *)

val character_count_by_category : (rhyme_category * int) list
(** 按声韵类别统计字符数量 *)
