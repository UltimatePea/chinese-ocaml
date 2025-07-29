(** 韵律数据组辅助函数模块接口 *)

open Poetry_core.Poetry_types
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
