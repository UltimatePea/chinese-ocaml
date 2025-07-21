(** 骆言语法分析器标识符和函数调用处理模块接口 *)

open Ast
open Parser_utils

val handle_compound_identifier : string -> parser_state -> string * parser_state
(** 处理复合标识符，如"去除空白" *)

val parse_atomic_expr : parser_state -> expr * parser_state
(** 解析原子表达式（函数参数） *)

val collect_function_args : expr list -> parser_state -> expr list * parser_state
(** 收集函数调用参数 *)

val parse_labeled_function_call : string -> parser_state -> expr * parser_state
(** 处理标签函数调用 *)

val parse_regular_function_call : string -> parser_state -> expr * parser_state
(** 处理普通函数调用 *)

val parse_function_call_or_variable : string -> parser_state -> expr * parser_state
(** 解析函数调用或变量（主函数） *)

val parse_label_arg_list : label_arg list -> parser_state -> label_arg list * parser_state
(** 解析标签参数列表 *)

val parse_label_arg : parser_state -> label_arg * parser_state
(** 解析单个标签参数 *)
