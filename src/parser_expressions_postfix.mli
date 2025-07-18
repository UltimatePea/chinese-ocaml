(** 骆言语法分析器后缀表达式解析模块 - Postfix Expression Parser *)

open Ast
open Parser_utils

val parse_postfix_expression :
  (parser_state -> expr * parser_state) -> expr -> parser_state -> expr * parser_state
(** 解析后缀表达式 *)