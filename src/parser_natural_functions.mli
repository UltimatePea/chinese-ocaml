(** 骆言自然语言函数定义解析器接口 *)

open Ast
open Parser_utils

val parse_natural_function_definition : parser_state -> expr * parser_state
(** 解析自然语言函数定义的主要入口点 *)

val parse_natural_function_body : string -> parser_state -> expr * parser_state
(** 解析自然语言函数体 *)

val parse_natural_expr : string -> parser_state -> expr * parser_state
(** 解析自然语言表达式 *)

val parse_natural_conditional :
  string -> parser_state -> string * binary_op * expr * expr * parser_state
(** 解析自然语言条件表达式 *)

val parse_conditional_relation_word : parser_state -> binary_op * parser_state
(** 解析条件关系词 *)

val parse_natural_arithmetic_continuation : expr -> string -> parser_state -> expr * parser_state
(** 解析自然语言算术运算连续表达式 *)

val parse_natural_comparison_patterns : string -> parser_state -> expr * parser_state
(** 解析自然语言比较模式 *)

val parse_natural_function_header : parser_state -> string * string * parser_state
(** 解析函数头部信息 *)

val perform_semantic_analysis : string -> string -> expr -> unit
(** 执行语义分析 *)

val set_parse_expr_ref : (parser_state -> expr * parser_state) -> unit
(** 初始化parse_expr引用 *)

val set_parser_functions_ref :
  skip_newlines_f:(parser_state -> parser_state) ->
  parse_identifier_f:(parser_state -> string * parser_state) ->
  parse_literal_f:(parser_state -> Ast.literal * parser_state) ->
  expect_token_f:(parser_state -> Lexer.token -> parser_state) ->
  unit
(** 初始化所有函数引用 *)
