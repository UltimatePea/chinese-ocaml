(** 骆言词法分析器 - 重构后的令牌类型定义 
    本文件提供向后兼容性，将原始的巨型枚举类型映射到新的模块化系统 *)

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

(** 为了向后兼容，创建原始枚举到新系统的映射函数 *)

(** 从原始IntToken创建新token *)
let int_token i = UnifiedTokens.make_int_token i

(** 从原始FloatToken创建新token *)
let float_token f = UnifiedTokens.make_float_token f

(** 从原始StringToken创建新token *)
let string_token s = UnifiedTokens.make_string_token s

(** 从原始BoolToken创建新token *)
let bool_token b = UnifiedTokens.make_bool_token b

(** 从原始ChineseNumberToken创建新token *)
let chinese_number_token s = UnifiedTokens.make_chinese_number_token s

(** 从原始LetKeyword创建新token *)
let let_keyword () = UnifiedTokens.make_let_keyword ()

(** 从原始IfKeyword创建新token *)
let if_keyword () = UnifiedTokens.make_if_keyword ()

(** 从原始ThenKeyword创建新token *)
let then_keyword () = UnifiedTokens.make_then_keyword ()

(** 从原始ElseKeyword创建新token *)
let else_keyword () = UnifiedTokens.make_else_keyword ()

(** 从原始Plus创建新token *)
let plus_op () = UnifiedTokens.make_plus_op ()

(** 从原始Minus创建新token *)
let minus_op () = UnifiedTokens.make_minus_op ()

(** 从原始LeftParen创建新token *)
let left_paren () = UnifiedTokens.make_left_paren ()

(** 从原始RightParen创建新token *)
let right_paren () = UnifiedTokens.make_right_paren ()

(** 从原始QuotedIdentifierToken创建新token *)
let quoted_identifier s = UnifiedTokens.make_quoted_identifier s

(** 重新导出类型定义 *)
type position = UnifiedTokens.position = { line : int; column : int; filename : string } [@@deriving show, eq]

type positioned_token = UnifiedTokens.positioned_token [@@deriving show, eq]

exception LexError = UnifiedTokens.LexError

(** 重新导出工具函数 *)
let token_to_string = UnifiedTokens.token_to_string
let is_literal = UnifiedTokens.is_literal
let is_keyword = UnifiedTokens.is_keyword
let is_operator = UnifiedTokens.is_operator
let is_delimiter = UnifiedTokens.is_delimiter
let is_numeric_token = UnifiedTokens.is_numeric_token
let is_string_token = UnifiedTokens.is_string_token
let is_control_flow_token = UnifiedTokens.is_control_flow_token
let is_binary_op_token = UnifiedTokens.is_binary_op_token
let is_unary_op_token = UnifiedTokens.is_unary_op_token
let get_token_precedence = UnifiedTokens.get_token_precedence
let make_position = UnifiedTokens.make_position
let make_positioned_token = UnifiedTokens.make_positioned_token

(** 性能优化：预定义常用令牌的实例以避免重复创建 *)
module CommonTokens = struct
  let let_kw = let_keyword ()
  let if_kw = if_keyword ()
  let then_kw = then_keyword ()
  let else_kw = else_keyword ()
  let plus = plus_op ()
  let minus = minus_op ()
  let left_paren = left_paren ()
  let right_paren = right_paren ()
  let newline = UnifiedTokens.make_newline ()
  let eof = UnifiedTokens.make_eof ()
end

(** 快速访问常用令牌 *)
let get_common_token = function
  | "让" -> Some CommonTokens.let_kw
  | "如果" -> Some CommonTokens.if_kw
  | "那么" -> Some CommonTokens.then_kw
  | "否则" -> Some CommonTokens.else_kw
  | "+" -> Some CommonTokens.plus
  | "-" -> Some CommonTokens.minus
  | "(" -> Some CommonTokens.left_paren
  | ")" -> Some CommonTokens.right_paren
  | _ -> None