(** 韵律数据辅助函数模块接口

    提供创建韵律数据条目的通用辅助函数，避免在各个韵组模块中重复定义。 *)

open Rhyme_core_types

val make_entry :
  string ->
  rhyme_category ->
  rhyme_group ->
  ?variants:string list ->
  ?frequency:float ->
  unit ->
  rhyme_data_entry
(** 创建韵律数据条目的辅助函数 *)

val make_group_entries : rhyme_category -> rhyme_group -> string list -> rhyme_data_entry list
(** 创建某个韵组字符列表的辅助函数 *)

val combine_data : rhyme_data_entry list -> rhyme_data_entry list -> rhyme_data_entry list
(** 合并平声和仄声数据的辅助函数 *)

val get_rhyme_stats : rhyme_data_entry list -> int
(** 获取韵组数据统计信息 *)
