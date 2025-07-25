(** 骆言集合值操作模块接口 - Collection Value Operations Module Interface *)

open Value_types

val string_of_collection_value : runtime_value -> string
(** 集合值转换为字符串 *)

val list_length : runtime_value -> runtime_value
(** 列表操作 *)

val list_head : runtime_value -> runtime_value
val list_tail : runtime_value -> runtime_value
val list_cons : runtime_value -> runtime_value -> runtime_value
val list_append : runtime_value -> runtime_value -> runtime_value
val list_reverse : runtime_value -> runtime_value
val list_map : (runtime_value -> runtime_value) -> runtime_value -> runtime_value
val list_filter : (runtime_value -> runtime_value) -> runtime_value -> runtime_value
val list_nth : runtime_value -> runtime_value -> runtime_value

val array_length : runtime_value -> runtime_value
(** 数组操作 *)

val array_get : runtime_value -> runtime_value -> runtime_value
val array_set : runtime_value -> runtime_value -> runtime_value -> runtime_value
val array_make : runtime_value -> runtime_value -> runtime_value
val array_of_list : runtime_value -> runtime_value
val array_to_list : runtime_value -> runtime_value

val tuple_length : runtime_value -> runtime_value
(** 元组操作 *)

val tuple_nth : runtime_value -> runtime_value -> runtime_value

val is_empty : runtime_value -> runtime_value
(** 集合通用操作 *)

val collection_size : runtime_value -> runtime_value
val compare_collections : runtime_value -> runtime_value -> int
