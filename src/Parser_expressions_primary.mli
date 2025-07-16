(** 骆言语法分析器基础表达式解析模块接口 *)

open Ast
open Parser_utils

(** 解析函数调用或变量 *)
val parse_function_call_or_variable : string -> parser_state -> expr * parser_state

(** 解析后缀表达式（字段访问等） *)
val parse_postfix_expr : expr -> parser_state -> expr * parser_state

(** 解析基础表达式 *)
val parse_primary_expr : parser_state -> expr * parser_state