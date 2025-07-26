(** Token转换 - 类型关键字专门模块接口 *)

exception Unknown_type_keyword_token of string
(** 异常定义 *)

val convert_type_keyword_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换类型关键字tokens *)

val is_type_keyword_token : Token_mapping.Token_definitions_unified.token -> bool
(** 检查是否为类型关键字token *)

val convert_type_keyword_token_safe :
  Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token option
(** 安全转换类型关键字token（返回Option类型） *)
