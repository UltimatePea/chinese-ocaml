(** 骆言语法分析器条件表达式解析模块 - Conditional Expression Parser *)

open Ast
open Parser_utils

val parse_conditional_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析条件表达式 *)
