(** 骆言基础值操作模块接口 - Chinese Programming Language Basic Value Operations Module Interface *)

open Value_types

val lookup_var : env -> string -> runtime_value
(** 在环境中查找变量 *)

val get_available_vars : env -> string list
(** 获取环境中的所有可用变量名 - 用于拼写纠正 *)

val basic_value_to_string : runtime_value -> string
(** 基础类型值转换为字符串 *)

val value_to_bool : runtime_value -> bool
(** 值转换为布尔值 *)

val try_to_int : runtime_value -> int option
(** 尝试将值转换为整数 *)

val try_to_float : runtime_value -> float option
(** 尝试将值转换为浮点数 *)

val try_to_string : runtime_value -> string option
(** 尝试将值转换为字符串 *)
