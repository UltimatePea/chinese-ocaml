(** 骆言词法分析器 - 基础关键字转换模块 *)

open Lexer_tokens
open Compiler_errors

(** 基础关键字转换 *)
let convert_basic_keywords pos = function
  | `LetKeyword -> Ok LetKeyword
  | `RecKeyword -> Ok RecKeyword
  | `InKeyword -> Ok InKeyword
  | `FunKeyword -> Ok FunKeyword
  | `IfKeyword -> Ok IfKeyword
  | `ThenKeyword -> Ok ThenKeyword
  | `ElseKeyword -> Ok ElseKeyword
  | `MatchKeyword -> Ok MatchKeyword
  | `WithKeyword -> Ok WithKeyword
  | `OtherKeyword -> Ok OtherKeyword
  | `TypeKeyword -> Ok TypeKeyword
  | `PrivateKeyword -> Ok PrivateKeyword
  | `TrueKeyword -> Ok TrueKeyword
  | `FalseKeyword -> Ok FalseKeyword
  | `AndKeyword -> Ok AndKeyword
  | `OrKeyword -> Ok OrKeyword
  | `NotKeyword -> Ok NotKeyword
  | `OfKeyword -> Ok OfKeyword
  | _ -> unsupported_keyword_error "未知的基础关键字" pos

(** 语义关键字转换 *)
let convert_semantic_keywords pos = function
  | `AsKeyword -> Ok AsKeyword
  | `CombineKeyword -> Ok CombineKeyword
  | `WithOpKeyword -> Ok WithOpKeyword
  | `WhenKeyword -> Ok WhenKeyword
  | `WithDefaultKeyword -> Ok WithDefaultKeyword
  | _ -> unsupported_keyword_error "未知的语义关键字" pos
