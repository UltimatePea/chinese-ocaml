(** 词法器Token转换模块接口 - Phase 6.2 重构
    
    整合所有词法器专用的Token转换接口，包括：
    - 标识符词法转换
    - 字面量词法转换  
    - 基础关键字词法转换
    - 类型关键字词法转换
    - 古典语言词法转换
    
    设计目标：
    - 提供词法分析阶段的转换支持
    - 优化词法器性能
    - 统一词法转换接口
    - 支持分阶段token处理
    
    @author Alpha, 主工作代理 - Phase 6.2 Implementation
    @version 2.0 - 词法器转换统一
    @since 2025-07-25
    @fixes Issue #1340 *)

open Lexer_tokens

(** {1 异常定义} *)

exception Lexer_conversion_failed of string
(** 词法器转换异常 *)

(** {1 类型定义} *)

(** 词法器转换类型 *)
type lexer_conversion_type =
  | LexerIdentifier  (** 词法器标识符转换 *)
  | LexerLiteral  (** 词法器字面量转换 *)
  | LexerBasicKeyword  (** 词法器基础关键字转换 *)
  | LexerTypeKeyword  (** 词法器类型关键字转换 *)
  | LexerClassical  (** 词法器古典语言转换 *)

(** 词法器转换策略 *)
type lexer_conversion_strategy =
  | LexerFast  (** 词法器性能优先 *)
  | LexerPrecise  (** 词法器精确转换 *)
  | LexerIncrmental  (** 增量词法转换 *)

(** {1 模块接口} *)

(** 词法器标识符转换模块 *)
module LexerIdentifiers : sig
  val convert_identifier_token : Token_mapping.Token_definitions_unified.token -> token option
  (** 转换标识符token *)

  val is_lexer_identifier_token : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为词法器标识符token *)
end

(** 词法器字面量转换模块 *)
module LexerLiterals : sig
  val convert_literal_token : Token_mapping.Token_definitions_unified.token -> token option
  (** 转换字面量token *)

  val is_lexer_literal_token : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为词法器字面量token *)
end

(** 词法器基础关键字转换模块 *)
module LexerBasicKeywords : sig
  val convert_basic_keyword_token : Token_mapping.Token_definitions_unified.token -> token option
  (** 转换基础关键字token *)

  val is_lexer_basic_keyword : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为词法器基础关键字 *)
end

(** 词法器类型关键字转换模块 *)
module LexerTypeKeywords : sig
  val convert_type_keyword_token : Token_mapping.Token_definitions_unified.token -> token option
  (** 转换类型关键字token *)

  val is_lexer_type_keyword : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为词法器类型关键字 *)
end

(** 词法器古典语言转换模块 *)
module LexerClassical : sig
  val convert_classical_token : Token_mapping.Token_definitions_unified.token -> token option
  (** 转换古典语言token *)

  val is_lexer_classical_token : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为词法器古典语言token *)
end

(** {1 转换函数} *)

val convert_wenyan_keywords : Token_mapping.Token_definitions_unified.token -> token option
(** 文言文关键字转换 *)

val convert_natural_keywords : Token_mapping.Token_definitions_unified.token -> token option
(** 自然语言关键字转换 *)

val convert_ancient_keywords : Token_mapping.Token_definitions_unified.token -> token option
(** 古雅体关键字转换 *)

(** {1 主要接口} *)

val convert_lexer_token :
  ?strategy:lexer_conversion_strategy ->
  Token_mapping.Token_definitions_unified.token ->
  token option
(** 统一的词法器转换接口 *)

val is_lexer_supported_token : Token_mapping.Token_definitions_unified.token -> bool
(** 检查是否为词法器支持的token *)

val get_lexer_conversion_type :
  Token_mapping.Token_definitions_unified.token -> lexer_conversion_type option
(** 获取词法器token转换类型 *)

val convert_lexer_token_list :
  ?strategy:lexer_conversion_strategy ->
  Token_mapping.Token_definitions_unified.token list ->
  token list
(** 批量词法器转换 *)

val get_lexer_conversion_stats : Token_mapping.Token_definitions_unified.token list -> string
(** 词法器转换统计 *)

(** {1 向后兼容性模块} *)

(** 向后兼容性接口 *)
module BackwardCompatibility : sig
  val convert_identifier_token : Token_mapping.Token_definitions_unified.token -> token
  (** 转换标识符token（抛出异常版本） *)

  val convert_literal_token : Token_mapping.Token_definitions_unified.token -> token
  (** 转换字面量token（抛出异常版本） *)

  val convert_basic_keyword_token : Token_mapping.Token_definitions_unified.token -> token
  (** 转换基础关键字token（抛出异常版本） *)

  val convert_type_keyword_token : Token_mapping.Token_definitions_unified.token -> token
  (** 转换类型关键字token（抛出异常版本） *)

  val convert_classical_token : Token_mapping.Token_definitions_unified.token -> token
  (** 转换古典语言token（抛出异常版本） *)

  val convert_lexer_token_exn : Token_mapping.Token_definitions_unified.token -> token
  (** 主转换函数（抛出异常版本） *)
end

(** {1 性能统计模块} *)

(** 词法器性能统计模块 *)
module LexerStatistics : sig
  val get_lexer_performance_stats : unit -> string
  (** 获取词法器性能统计信息 *)
end
