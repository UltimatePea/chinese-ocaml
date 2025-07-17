(** 骆言语法分析器高级表达式解析模块 - Advanced Expression Parser *)

open Ast
open Parser_utils

val parse_conditional_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析条件表达式 *)

val parse_match_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析匹配表达式 *)

val parse_function_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析函数表达式 *)

val parse_labeled_function_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析标签函数表达式 *)

val parse_label_param : parser_state -> label_param * parser_state
(** 解析单个标签参数 *)

val parse_let_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析让表达式 *)

val parse_array_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析数组表达式 *)

val parse_combine_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析组合表达式 *)

val parse_record_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析记录表达式 *)

val parse_record_updates :
  (parser_state -> expr * parser_state) -> parser_state -> (string * expr) list * parser_state
(** 解析记录更新字段 *)

val parse_try_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析try表达式 *)

val parse_raise_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析raise表达式 *)

val parse_ref_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析ref表达式 *)

val parse_postfix_expression :
  (parser_state -> expr * parser_state) -> expr -> parser_state -> expr * parser_state
(** 解析后缀表达式 *)
