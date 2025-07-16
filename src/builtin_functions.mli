(** 骆言内置函数模块接口 - Chinese Programming Language Builtin Functions Module Interface *)

open Value_operations

type builtin_function_table = (string * runtime_value) list
(** 内置函数表类型 *)

val builtin_functions : builtin_function_table
(** 获取内置函数表 *)

val call_builtin_function : string -> runtime_value list -> runtime_value
(** 调用内置函数 *)

val is_builtin_function : string -> bool
(** 检查是否为内置函数 *)

val get_builtin_function_names : unit -> string list
(** 获取所有内置函数名称列表 *)
