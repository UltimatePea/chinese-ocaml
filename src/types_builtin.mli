(** 骆言类型系统内置函数环境接口 - Built-in Function Type Environment Interface *)

open Core_types

val builtin_env : env
(** 内置函数类型环境 *)

val builtin_overload_env : overload_env
(** 内置函数重载环境 *)

val get_builtin_functions : unit -> string list
(** 获取内置函数列表 *)

val is_builtin_function : string -> bool
(** 检查是否是内置函数 *)

val get_builtin_type : string -> type_scheme option
(** 获取内置函数类型 *)

val add_builtin_function : string -> type_scheme -> env -> env
(** 添加自定义内置函数 *)

val get_math_functions : unit -> string list
(** 获取分类的内置函数 *)

val get_list_functions : unit -> string list
val get_string_functions : unit -> string list
val get_io_functions : unit -> string list
val get_conversion_functions : unit -> string list
val get_array_functions : unit -> string list
val get_reference_functions : unit -> string list
