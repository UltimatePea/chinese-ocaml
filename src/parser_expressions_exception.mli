(** 骆言语法分析器异常表达式解析模块 - Exception Expression Parser *)

open Ast
open Parser_utils

val parse_try_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析try表达式 *)

val parse_raise_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析raise表达式 *)

val parse_ref_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析ref表达式 *)
