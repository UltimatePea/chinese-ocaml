(** 骆言语法分析器诗词表达式处理模块（Primary层）接口 *)

open Ast
open Lexer
open Parser_utils

val parse_poetry_expr : parser_state -> token -> expr * parser_state
(** 解析诗词表达式 *)

val parse_poetry_expressions : parser_state -> (expr * parser_state) option
(** 解析诗词表达式（重构后），返回Some结果或None *)