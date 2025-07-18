(** 骆言语法分析器核心表达式解析模块接口 *)

open Ast
open Parser_utils

val parse_or_else_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析否则返回表达式 *)

val parse_or_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析逻辑或表达式 *)

val parse_and_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析逻辑与表达式 *)

val parse_comparison_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析比较表达式 *)
