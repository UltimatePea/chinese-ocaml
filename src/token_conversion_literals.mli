(** Token转换 - 字面量专门模块接口 *)

exception Unknown_literal_token of string
(** 异常定义 *)

val convert_literal_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换字面量tokens *)

val is_literal_token : Token_mapping.Token_definitions_unified.token -> bool
(** 检查是否为字面量token *)

val convert_literal_token_safe :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token option
(** 安全转换字面量token（返回Option类型） *)
