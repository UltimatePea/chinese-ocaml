(** Token注册器 - 字面量Token注册功能接口 *)

open Token_definitions_unified

val register_literal_tokens : unit -> unit
(** 注册字面量Token映射 *)

val generate_literal_token_code : token -> string
(** 字面量Token的代码生成 *)
