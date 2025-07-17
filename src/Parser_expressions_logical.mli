(** 骆言语法分析器逻辑运算表达式解析模块 - Logical Expression Parser *)

open Ast
open Parser_utils

val parse_logical_or_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析逻辑或表达式 *)

val parse_logical_and_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析逻辑与表达式 *)

val parse_comparison_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析比较表达式 *)

val parse_arithmetic_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析算术表达式 *)

val parse_multiplicative_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析乘除表达式 *)

val parse_unary_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析一元表达式 *)

val parse_primary_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析基础表达式 *)
