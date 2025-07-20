(** 骆言自然语言函数定义解析器接口 *)

open Ast
open Parser_utils

val parse_natural_function_definition :
  expect_token:(parser_state -> Lexer.token -> parser_state) ->
  parse_identifier:(parser_state -> string * parser_state) ->
  skip_newlines:(parser_state -> parser_state) ->
  parse_expr:(parser_state -> expr * parser_state) ->
  parser_state -> expr * parser_state
(** 解析自然语言函数定义的主要入口点 *)

val parse_natural_function_body :
  expect_token:(parser_state -> Lexer.token -> parser_state) ->
  parse_identifier:(parser_state -> string * parser_state) ->
  skip_newlines:(parser_state -> parser_state) ->
  parse_expr:(parser_state -> expr * parser_state) ->
  string -> parser_state -> expr * parser_state
(** 解析自然语言函数体 *)

val parse_natural_expr :
  parse_expr:(parser_state -> expr * parser_state) ->
  string -> parser_state -> expr * parser_state
(** 解析自然语言表达式 *)

val parse_natural_conditional :
  expect_token:(parser_state -> Lexer.token -> parser_state) ->
  parse_identifier:(parser_state -> string * parser_state) ->
  skip_newlines:(parser_state -> parser_state) ->
  parse_expr:(parser_state -> expr * parser_state) ->
  string -> parser_state -> string * binary_op * expr * expr * parser_state
(** 解析自然语言条件表达式 *)

val parse_conditional_relation_word : parser_state -> binary_op * parser_state
(** 解析条件关系词 *)

val parse_natural_arithmetic_continuation :
  parse_expr:(parser_state -> expr * parser_state) ->
  expr -> string -> parser_state -> expr * parser_state
(** 解析自然语言算术运算连续表达式 *)

val parse_natural_comparison_patterns :
  parse_expr:(parser_state -> expr * parser_state) ->
  string -> parser_state -> expr * parser_state
(** 解析自然语言比较模式 *)

val parse_natural_function_header :
  expect_token:(parser_state -> Lexer.token -> parser_state) ->
  parse_identifier:(parser_state -> string * parser_state) ->
  skip_newlines:(parser_state -> parser_state) ->
  parser_state -> string * string * parser_state
(** 解析函数头部信息 *)

val perform_semantic_analysis : string -> string -> expr -> unit
(** 执行语义分析 *)
