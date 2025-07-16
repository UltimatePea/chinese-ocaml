(** 骆言语法分析器算术表达式解析模块 - Arithmetic Expression Parser *)

open Ast
open Parser_utils

(** 解析算术表达式 *)
val parse_arithmetic_expression : (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state

(** 解析乘除表达式 *)
val parse_multiplicative_expression : (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state

(** 解析一元表达式 *)
val parse_unary_expression : (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state

(** 解析基础表达式 *)
val parse_primary_expression : (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state

(** 解析加法表达式 *)
val parse_addition_expression : (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state

(** 解析减法表达式 *)
val parse_subtraction_expression : (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state

(** 解析乘法表达式 *)
val parse_multiplication_expression : (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state