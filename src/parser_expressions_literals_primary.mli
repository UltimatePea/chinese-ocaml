(** 骆言语法分析器字面量表达式处理模块（Primary层）接口 *)

open Ast
open Parser_utils

val parse_literal_expr : parser_state -> expr * parser_state
(** 解析字面量表达式 *)

val parse_literal_expressions : parser_state -> (expr * parser_state) option
(** 解析字面量表达式（重构后），返回Some结果或None *)