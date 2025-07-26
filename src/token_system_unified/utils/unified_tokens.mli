(** 骆言词法分析器 - 统一令牌类型定义接口 *)

open Literal_tokens
open Keyword_tokens
open Operator_tokens
open Delimiter_tokens
open Wenyan_tokens
open Natural_language_tokens
open Poetry_tokens
open Identifier_tokens

(** 统一词元类型 *)
type token =
  | Literal of literal_token
  | Keyword of keyword_token
  | Operator of operator_token
  | Delimiter of delimiter_token
  | Wenyan of wenyan_token
  | NaturalLanguage of natural_language_token
  | Poetry of poetry_token
  | Identifier of identifier_token
[@@deriving show, eq]

type position = { line : int; column : int; filename : string } [@@deriving show, eq]
(** 位置信息 *)

type positioned_token = token * position [@@deriving show, eq]
(** 带位置的词元 *)

exception LexError of string * position
(** 词法错误 *)

val token_to_string : token -> string
(** 令牌转换为字符串 *)

val make_int_token : int -> token
(** 创建字面量令牌 *)

val make_float_token : float -> token
val make_string_token : string -> token
val make_bool_token : bool -> token
val make_chinese_number_token : string -> token

val make_let_keyword : unit -> token
(** 创建基础关键字令牌 *)

val make_if_keyword : unit -> token
val make_then_keyword : unit -> token
val make_else_keyword : unit -> token

val make_plus_op : unit -> token
(** 创建操作符令牌 *)

val make_minus_op : unit -> token
val make_multiply_op : unit -> token
val make_divide_op : unit -> token
val make_assign_op : unit -> token
val make_equal_op : unit -> token

val make_left_paren : unit -> token
(** 创建分隔符令牌 *)

val make_right_paren : unit -> token
val make_left_bracket : unit -> token
val make_right_bracket : unit -> token
val make_comma : unit -> token
val make_semicolon : unit -> token
val make_newline : unit -> token
val make_eof : unit -> token

val make_quoted_identifier : string -> token
(** 创建标识符令牌 *)

val make_special_identifier : string -> token

val is_literal : token -> bool
(** 类型判断函数 *)

val is_keyword : token -> bool
val is_operator : token -> bool
val is_delimiter : token -> bool
val is_wenyan : token -> bool
val is_natural_language : token -> bool
val is_poetry : token -> bool
val is_identifier : token -> bool

val is_numeric_token : token -> bool
(** 特定类型判断函数 *)

val is_string_token : token -> bool
val is_control_flow_token : token -> bool
val is_binary_op_token : token -> bool
val is_unary_op_token : token -> bool
val is_left_delimiter_token : token -> bool
val is_right_delimiter_token : token -> bool

val get_token_precedence : token -> int
(** 获取操作符优先级 *)

val make_position : int -> int -> string -> position
(** 创建位置信息 *)

val make_positioned_token : token -> position -> positioned_token
(** 创建带位置的令牌 *)
