(* 数据加载器核心模块接口 *)

open Data_loader_types

val generic_loader : ?use_cache:bool -> string -> string -> (string -> 'a) -> 'a data_result
(** 通用加载器函数 *)

val load_string_list : ?use_cache:bool -> string -> string list data_result
(** 加载字符串列表数据 *)

val load_word_class_pairs : ?use_cache:bool -> string -> (string * string) list data_result
(** 加载词性数据对 *)

val load_simple_object : ?use_cache:bool -> string -> (string * string) list data_result
(** 加载简单对象数据 *)

val load_with_fallback : (string -> 'a data_result) -> string -> 'a -> 'a
(** 提供降级机制 *)
