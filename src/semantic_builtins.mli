(** 骆言语义分析内置函数 - Chinese Programming Language Semantic Builtins *)

open Semantic_context

val add_io_functions : symbol_table_t -> symbol_table_t
(** 添加基础I/O函数 *)

val add_list_functions : symbol_table_t -> symbol_table_t
(** 添加列表操作函数 *)

val add_array_functions : symbol_table_t -> symbol_table_t
(** 添加数组操作函数 *)

val add_math_functions : symbol_table_t -> symbol_table_t
(** 添加数学函数 *)

val add_string_functions : symbol_table_t -> symbol_table_t
(** 添加字符串函数 *)

val add_file_functions : symbol_table_t -> symbol_table_t
(** 添加文件函数 *)

val add_builtin_functions : semantic_context -> semantic_context
(** 添加所有内置函数 *)
