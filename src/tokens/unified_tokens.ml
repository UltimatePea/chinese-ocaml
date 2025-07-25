(** 骆言词法分析器 - 统一令牌类型定义 *)

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

(** 位置信息 *)
type position = { line : int; column : int; filename : string } [@@deriving show, eq]

(** 带位置的词元 *)
type positioned_token = token * position [@@deriving show, eq]

(** 词法错误 *)
exception LexError of string * position

(** 令牌转换为字符串 *)
let token_to_string = function
  | Literal lt -> literal_token_to_string lt
  | Keyword kt -> keyword_token_to_string kt
  | Operator ot -> operator_token_to_string ot
  | Delimiter dt -> delimiter_token_to_string dt
  | Wenyan wt -> wenyan_token_to_string wt
  | NaturalLanguage nlt -> natural_language_token_to_string nlt
  | Poetry pt -> poetry_token_to_string pt
  | Identifier it -> identifier_token_to_string it

(** 创建便利函数 *)

(** 创建字面量令牌 *)
let make_int_token i = Literal (IntToken i)
let make_float_token f = Literal (FloatToken f)
let make_string_token s = Literal (StringToken s)
let make_bool_token b = Literal (BoolToken b)
let make_chinese_number_token s = Literal (ChineseNumberToken s)

(** 创建基础关键字令牌 *)
let make_let_keyword () = Keyword (Basic LetKeyword)
let make_if_keyword () = Keyword (Basic IfKeyword)
let make_then_keyword () = Keyword (Basic ThenKeyword)
let make_else_keyword () = Keyword (Basic ElseKeyword)

(** 创建操作符令牌 *)
let make_plus_op () = Operator (Arithmetic Plus)
let make_minus_op () = Operator (Arithmetic Minus)
let make_multiply_op () = Operator (Arithmetic Multiply)
let make_divide_op () = Operator (Arithmetic Divide)
let make_assign_op () = Operator (Assignment Assign)
let make_equal_op () = Operator (Comparison Equal)

(** 创建分隔符令牌 *)
let make_left_paren () = Delimiter (Parenthesis LeftParen)
let make_right_paren () = Delimiter (Parenthesis RightParen)
let make_left_bracket () = Delimiter (Parenthesis LeftBracket)
let make_right_bracket () = Delimiter (Parenthesis RightBracket)
let make_comma () = Delimiter (Punctuation Comma)
let make_semicolon () = Delimiter (Punctuation Semicolon)
let make_newline () = Delimiter (Special Newline)
let make_eof () = Delimiter (Special EOF)

(** 创建标识符令牌 *)
let make_quoted_identifier s = Identifier (QuotedIdentifierToken s)
let make_special_identifier s = Identifier (IdentifierTokenSpecial s)

(** 类型判断函数 *)
let is_literal = function | Literal _ -> true | _ -> false
let is_keyword = function | Keyword _ -> true | _ -> false
let is_operator = function | Operator _ -> true | _ -> false
let is_delimiter = function | Delimiter _ -> true | _ -> false
let is_wenyan = function | Wenyan _ -> true | _ -> false
let is_natural_language = function | NaturalLanguage _ -> true | _ -> false
let is_poetry = function | Poetry _ -> true | _ -> false
let is_identifier = function | Identifier _ -> true | _ -> false

(** 特定类型判断函数 *)
let is_numeric_token = function
  | Literal lt -> is_numeric_literal lt
  | _ -> false

let is_string_token = function
  | Literal lt -> is_string_literal lt
  | _ -> false

let is_control_flow_token = function
  | Keyword kt -> is_control_flow_keyword kt
  | _ -> false

let is_binary_op_token = function
  | Operator ot -> is_binary_operator ot
  | _ -> false

let is_unary_op_token = function
  | Operator ot -> is_unary_operator ot
  | _ -> false

let is_left_delimiter_token = function
  | Delimiter dt -> is_left_delimiter dt
  | _ -> false

let is_right_delimiter_token = function
  | Delimiter dt -> is_right_delimiter dt
  | _ -> false

(** 获取操作符优先级 *)
let get_token_precedence = function
  | Operator ot -> get_operator_precedence ot
  | _ -> 0

(** 创建位置信息 *)
let make_position line column filename = { line; column; filename }

(** 创建带位置的令牌 *)
let make_positioned_token token position = (token, position)