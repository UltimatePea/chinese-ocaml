(** Token转换 - 字面量专门模块接口 *)

open Lexer_tokens

(** 异常定义 *)
exception Unknown_literal_token of string

(** 转换字面量tokens *)
val convert_literal_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token

(** 检查是否为字面量token *)
val is_literal_token : Token_mapping.Token_definitions_unified.token -> bool

(** 安全转换字面量token（返回Option类型） *)
val convert_literal_token_safe : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token option