(** Token注册器 - 标识符Token注册功能接口 *)

open Token_definitions_unified

val register_identifier_tokens : unit -> unit
(** 注册标识符Token映射 *)

val generate_identifier_token_code : token -> string
(** 标识符Token的代码生成 *)