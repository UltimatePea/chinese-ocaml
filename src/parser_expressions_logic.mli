(** 骆言语法分析器逻辑表达式解析模块接口 *)

open Ast
open Lexer
open Parser_utils

(** 解析否则返回表达式 *)
val parse_or_else_expression : parser_state -> Ast.expression * parser_state

(** 解析逻辑或表达式 *)
val parse_or_expression : parser_state -> Ast.expression * parser_state

(** 解析逻辑与表达式 *)
val parse_and_expression : parser_state -> Ast.expression * parser_state