(** Token转换 - 标识符专门模块接口 *)

open Lexer_tokens

(** 异常定义 *)
exception Unknown_identifier_token of string

(** 转换标识符tokens *)
val convert_identifier_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token

(** 检查是否为标识符token *)
val is_identifier_token : Token_mapping.Token_definitions_unified.token -> bool

(** 安全转换标识符token（返回Option类型） *)
val convert_identifier_token_safe : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token option