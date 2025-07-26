(** Token转换 - 标识符专门模块接口 *)

exception Unknown_identifier_token of string
(** 异常定义 *)

val convert_identifier_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换标识符tokens *)

val is_identifier_token : Token_mapping.Token_definitions_unified.token -> bool
(** 检查是否为标识符token *)

val convert_identifier_token_safe :
  Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token option
(** 安全转换标识符token（返回Option类型） *)
