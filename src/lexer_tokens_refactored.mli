(** 骆言词法分析器 - 重构后的令牌类型定义接口 *)

(** 导入统一令牌模块 *)
module UnifiedTokens = Tokens.Unified_tokens
module LiteralTokens = Tokens.Literal_tokens
module KeywordTokens = Tokens.Keyword_tokens
module OperatorTokens = Tokens.Operator_tokens
module DelimiterTokens = Tokens.Delimiter_tokens
module WenyanTokens = Tokens.Wenyan_tokens
module NaturalLanguageTokens = Tokens.Natural_language_tokens
module PoetryTokens = Tokens.Poetry_tokens
module IdentifierTokens = Tokens.Identifier_tokens

(** 为了向后兼容，重新导出原始的token类型 *)
type token = UnifiedTokens.token =
  | Literal of LiteralTokens.literal_token
  | Keyword of KeywordTokens.keyword_token
  | Operator of OperatorTokens.operator_token
  | Delimiter of DelimiterTokens.delimiter_token
  | Wenyan of WenyanTokens.wenyan_token
  | NaturalLanguage of NaturalLanguageTokens.natural_language_token
  | Poetry of PoetryTokens.poetry_token
  | Identifier of IdentifierTokens.identifier_token
[@@deriving show, eq]

(** 便利构造函数 *)
val int_token : int -> token
val float_token : float -> token
val string_token : string -> token
val bool_token : bool -> token
val chinese_number_token : string -> token
val let_keyword : unit -> token
val if_keyword : unit -> token
val then_keyword : unit -> token
val else_keyword : unit -> token
val plus_op : unit -> token
val minus_op : unit -> token
val left_paren : unit -> token
val right_paren : unit -> token
val quoted_identifier : string -> token

(** 重新导出类型定义 *)
type position = UnifiedTokens.position = { line : int; column : int; filename : string } [@@deriving show, eq]
type positioned_token = UnifiedTokens.positioned_token [@@deriving show, eq]
exception LexError = UnifiedTokens.LexError

(** 重新导出工具函数 *)
val token_to_string : token -> string
val is_literal : token -> bool
val is_keyword : token -> bool
val is_operator : token -> bool
val is_delimiter : token -> bool
val is_numeric_token : token -> bool
val is_string_token : token -> bool
val is_control_flow_token : token -> bool
val is_binary_op_token : token -> bool
val is_unary_op_token : token -> bool
val get_token_precedence : token -> int
val make_position : int -> int -> string -> position
val make_positioned_token : token -> position -> positioned_token

(** 性能优化：预定义常用令牌 *)
module CommonTokens : sig
  val let_kw : token
  val if_kw : token
  val then_kw : token
  val else_kw : token
  val plus : token
  val minus : token
  val left_paren : token
  val right_paren : token
  val newline : token
  val eof : token
end

(** 快速访问常用令牌 *)
val get_common_token : string -> token option