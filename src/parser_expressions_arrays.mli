(** 骆言语法分析器数组和让表达式解析模块 - Array and Let Expression Parser *)

open Ast
open Parser_utils

val parse_let_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析让表达式 *)

val parse_array_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析数组表达式 *)

val parse_combine_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析组合表达式 *)