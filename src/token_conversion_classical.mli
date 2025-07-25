(** Token转换 - 古典语言专门模块接口 *)

exception Unknown_classical_token of string
(** 异常定义 *)

val convert_classical_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换古典语言tokens - 使用统一模式匹配优化性能 *)

val is_classical_token : Token_mapping.Token_definitions_unified.token -> bool
(** 检查是否为古典语言token *)

val convert_classical_token_safe :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token option
(** 安全转换古典语言token（返回Option类型） *)

(** 为向后兼容保留的分类模块 *)
module Wenyan : sig
  val convert_wenyan_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
end

module Natural : sig
  val convert_natural_language_token :
    Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
end

module Ancient : sig
  val convert_ancient_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
end
