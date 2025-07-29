(** 鱼韵组数据模块接口 - 骆言诗词编程特性 *)

open Poetry_core.Poetry_types

(** {1 辅助函数} *)

val make_entry :
  string ->
  rhyme_category ->
  rhyme_group ->
  ?variants:string list ->
  ?frequency:float ->
  unit ->
  rhyme_data_entry
(** [make_entry char category group ?variants ?frequency ()] 创建韵律数据条目 *)

val make_group_entries : rhyme_category -> rhyme_group -> string list -> rhyme_data_entry list
(** [make_group_entries category group chars] 为字符列表创建韵组数据条目 *)

(** {2 字符数据} *)

val ping_sheng_chars : string list
(** 鱼韵组平声字符列表 *)

(** {3 数据条目} *)

val ping_sheng_data : rhyme_data_entry list
(** 鱼韵组平声数据条目 *)

val all_data : rhyme_data_entry list
(** 鱼韵组所有数据 *)

(** {4 统计信息} *)

val char_count : int
(** 鱼韵组字符总数 *)

val stats_by_category : (rhyme_category * int) list
(** 按声韵类别统计字符数 *)
