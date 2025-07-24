(** 骆言基础值操作模块接口 - Chinese Programming Language Basic Value Operations Module Interface *)

open Value_types

(** 在环境中查找变量 *)
val lookup_var : env -> string -> runtime_value

(** 获取环境中的所有可用变量名 - 用于拼写纠正 *)
val get_available_vars : env -> string list

(** 基础类型值转换为字符串 *)
val basic_value_to_string : runtime_value -> string

(** 值转换为布尔值 *)
val value_to_bool : runtime_value -> bool

(** 尝试将值转换为整数 *)
val try_to_int : runtime_value -> int option

(** 尝试将值转换为浮点数 *)
val try_to_float : runtime_value -> float option

(** 尝试将值转换为字符串 *)
val try_to_string : runtime_value -> string option