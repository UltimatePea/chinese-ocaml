(** Token转换 - 古典语言专门模块接口 (Phase 4.2重构版)

    支持策略模式的古典语言转换，消除代码重复。 Issue #1336 - 古典语言转换系统重构

    @author Alpha, 主工作代理 - Issue #1336
    @version 2.0 - Phase 4.2重构版 *)

exception Unknown_classical_token of string
(** 异常定义 *)

(** 古典语言转换策略类型 *)
type classical_conversion_strategy =
  | Wenyan  (** 文言文转换策略 *)
  | Natural_Language  (** 自然语言转换策略 *)
  | Ancient_Style  (** 古雅体转换策略 *)

val convert_with_classical_strategy :
  classical_conversion_strategy ->
  Token_mapping.Token_definitions_unified.token ->
  Lexer_tokens.token
(** 统一古典语言转换策略接口 - 核心重构实现 *)

val convert_classical_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 转换古典语言tokens - 使用统一模式匹配优化性能 (向后兼容) *)

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
