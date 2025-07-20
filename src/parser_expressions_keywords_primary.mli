(** 骆言语法分析器关键字表达式处理模块接口 *)

open Ast
open Parser_utils

val parse_identifier_expr : parser_state -> expr * parser_state
(** 解析标识符表达式 *)

val parse_type_keyword_expr : parser_state -> expr * parser_state
(** 解析类型关键字表达式 *)

val parse_special_keyword_expr : parser_state -> expr * parser_state
(** 解析特殊关键字表达式 *)

val parse_keyword_expressions : parser_state -> (expr * parser_state) option
(** 解析关键字表达式（重构后），返回Some结果或None *)

val parse_type_keyword_expressions : parser_state -> (expr * parser_state) option
(** 解析类型关键字表达式（重构后），返回Some结果或None *)