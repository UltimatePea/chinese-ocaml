(** Token转换 - 类型关键字专门模块接口 *)

open Lexer_tokens

(** 异常定义 *)
exception Unknown_type_keyword_token of string

(** 转换类型关键字tokens *)
val convert_type_keyword_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token

(** 检查是否为类型关键字token *)
val is_type_keyword_token : Token_mapping.Token_definitions_unified.token -> bool

(** 安全转换类型关键字token（返回Option类型） *)
val convert_type_keyword_token_safe : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token option