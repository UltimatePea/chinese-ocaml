(** 骆言语法分析器类型解析模块 - Chinese Programming Language Parser Types *)

open Ast
open Parser_utils

(** 类型表达式解析 *)

val parse_type_expression : parser_state -> type_expr * parser_state
(** 解析类型表达式 *)

val parse_basic_type_expression : parser_state -> type_expr * parser_state
(** 解析基本类型表达式 *)

(** 变体类型解析 *)

val parse_variant_labels :
  parser_state ->
  (string * type_expr option) list ->
  (string * type_expr option) list * parser_state
(** 解析变体标签 *)

(** 类型定义解析 *)

val parse_type_definition : parser_state -> type_def * parser_state
(** 解析类型定义 *)

val parse_variant_constructors :
  parser_state -> (string * type_expr option) list -> type_def * parser_state
(** 解析变体构造器列表 *)

(** 模块类型解析 *)

val parse_module_type : parser_state -> module_type * parser_state
(** 解析模块类型 *)

val parse_signature_items :
  signature_item list -> parser_state -> signature_item list * parser_state
(** 解析签名项列表 *)

val parse_signature_item : parser_state -> signature_item * parser_state
(** 解析单个签名项 *)

