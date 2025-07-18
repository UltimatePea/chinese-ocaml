(** 骆言语法分析器记录表达式解析模块 - Record Expression Parser *)

open Ast
open Parser_utils

val parse_record_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析记录表达式 *)

val parse_record_updates :
  (parser_state -> expr * parser_state) -> parser_state -> (string * expr) list * parser_state
(** 解析记录更新字段 *)

val parse_ancient_record_expression :
  (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析古雅体记录表达式 *)
