(** 骆言语法分析器自然语言表达式解析模块 - Natural Language Expression Parser *)

open Ast
open Parser_utils

val parse_natural_arithmetic_continuation : expr -> string -> parser_state -> expr * parser_state
(** 解析自然语言算术延续表达式 *)

val parse_natural_function_definition :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析自然语言函数定义 *)

val parse_natural_function_body :
  (parser_state -> expr * parser_state) -> string -> parser_state -> expr * parser_state
(** 解析自然语言函数体 *)

val parse_natural_conditional :
  (parser_state -> expr * parser_state) -> string -> parser_state -> expr * parser_state
(** 解析自然语言条件表达式 *)

val parse_natural_expression :
  (parser_state -> expr * parser_state) -> string -> parser_state -> expr * parser_state
(** 解析自然语言表达式 *)

val parse_natural_arithmetic_expression :
  (parser_state -> expr * parser_state) -> string -> parser_state -> expr * parser_state
(** 解析自然语言算术表达式 *)

val parse_natural_arithmetic_tail :
  (parser_state -> expr * parser_state) -> expr -> string -> parser_state -> expr * parser_state
(** 解析自然语言算术表达式尾部 *)

val parse_natural_primary :
  (parser_state -> expr * parser_state) -> string -> parser_state -> expr * parser_state
(** 解析自然语言基础表达式 *)

val parse_natural_identifier_patterns :
  (parser_state -> expr * parser_state) -> string -> string -> parser_state -> expr * parser_state
(** 解析自然语言标识符模式 *)

val parse_natural_input_patterns :
  (parser_state -> expr * parser_state) -> string -> parser_state -> expr * parser_state
(** 解析自然语言输入模式 *)

val parse_natural_comparison_patterns :
  (parser_state -> expr * parser_state) -> string -> parser_state -> expr * parser_state
(** 解析自然语言比较模式 *)
