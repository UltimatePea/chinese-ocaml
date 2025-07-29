(** 思韵组数据模块接口 - 骆言诗词编程特性

    思韵组包含"时、诗、知"等字，情思绵绵。 重构自 rhyme_core_data_original.ml 的思韵组部分。

    @author Beta, 代码审查代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

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
(** 思韵组平声字符列表 *)

val ze_sheng_chars : string list
(** 思韵组仄声字符列表 *)

(** {3 数据条目} *)

val ping_sheng_data : rhyme_data_entry list
(** 思韵组平声数据条目 *)

val ze_sheng_data : rhyme_data_entry list
(** 思韵组仄声数据条目 *)

val all_data : rhyme_data_entry list
(** 思韵组所有数据 *)

(** {4 统计信息} *)

val char_count : int
(** 思韵组字符总数 *)

val stats_by_category : (rhyme_category * int) list
(** 按声韵类别统计字符数 *)
