(** 骆言语法分析器函数表达式解析模块 - Function Expression Parser *)

open Ast
open Parser_utils

val parse_function_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析函数表达式 *)

val parse_labeled_function_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析标签函数表达式 *)

val parse_label_param : parser_state -> label_param * parser_state
(** 解析单个标签参数 *)