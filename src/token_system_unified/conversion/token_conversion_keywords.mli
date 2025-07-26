(** Token转换 - 关键字专门模块接口 *)

exception Unknown_keyword_token of string
(** 异常定义 *)

val convert_basic_keyword_token :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换基础关键字tokens - 使用统一模式匹配优化性能 *)

val is_basic_keyword_token : Token_mapping.Token_definitions_unified.token -> bool
(** 检查是否为基础关键字token *)

val convert_basic_keyword_token_safe :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token option
(** 安全转换基础关键字token（返回Option类型） *)
