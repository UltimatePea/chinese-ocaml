(** Token注册器 - 运算符Token注册功能接口 *)

val register_operator_tokens : unit -> unit
(** 注册运算符Token映射 *)

val generate_operator_code : string -> string
(** 运算符Token的代码生成 *)