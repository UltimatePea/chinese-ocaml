(** Token注册器 - 关键字Token注册功能接口 *)

open Token_definitions_unified

val register_basic_keywords : unit -> unit
(** 注册基础关键字Token映射 *)

val register_type_keywords : unit -> unit
(** 注册类型关键字Token映射 *)

val generate_basic_keyword_code : token -> string
(** 基础关键字Token的代码生成 *)

val generate_type_keyword_code : token -> string
(** 类型关键字Token的代码生成 *)