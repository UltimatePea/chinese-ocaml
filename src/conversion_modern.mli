(** 现代中文Token转换模块接口 - Phase 6.2 重构
    
    整合现代中文编程语法的Token转换，包括：
    - 关键字转换
    - 标识符转换
    - 字面量转换
    - 类型转换
    
    设计目标：
    - 统一现代中文编程语法转换
    - 支持多种现代中文编程语法
    - 提供高性能转换实现
    - 保持向后兼容性
    
    @author Alpha, 主工作代理 - Phase 6.2 Implementation
    @version 2.0 - 现代语言转换统一
    @since 2025-07-25
    @fixes Issue #1340 *)

open Lexer_tokens

(** {1 异常定义} *)

exception Unknown_modern_token of string
(** 现代语言Token转换异常 *)

(** {1 类型定义} *)

(** 现代语言转换子类型 *)
type modern_token_category =
  | Identifier  (** 标识符 *)
  | Literal  (** 字面量 *)
  | BasicKeyword  (** 基础关键字 *)
  | TypeKeyword  (** 类型关键字 *)
  | Semantic  (** 语义关键字 *)
  | ModuleSystem  (** 模块系统关键字 *)
  | ErrorRecovery  (** 错误恢复关键字 *)

(** 现代语言转换策略 *)
type modern_conversion_strategy =
  | Fast  (** 性能优先：使用直接模式匹配 *)
  | Readable  (** 可读性优先：使用分类函数 *)
  | Balanced  (** 平衡模式：结合性能和可读性 *)

(** {1 模块接口} *)

(** 标识符转换器模块 *)
module Identifiers : sig
  val convert_identifier_token : Token_mapping.Token_definitions_unified.token -> token option
  (** 转换标识符token *)

  val is_identifier_token : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为标识符token *)
end

(** 字面量转换器模块 *)
module Literals : sig
  val convert_literal_token : Token_mapping.Token_definitions_unified.token -> token option
  (** 转换字面量token *)

  val is_literal_token : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为字面量token *)
end

(** 类型关键字转换器模块 *)
module TypeKeywords : sig
  val convert_type_keyword_token : Token_mapping.Token_definitions_unified.token -> token option
  (** 转换类型关键字token *)

  val is_type_keyword_token : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为类型关键字token *)
end

(** 基础语言关键字转换器模块 *)
module BasicKeywords : sig
  val convert_basic_language_keywords :
    Token_mapping.Token_definitions_unified.token -> token option
  (** 转换基础语言关键字 *)

  val is_basic_language_keyword : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为基础语言关键字 *)

  val convert_basic_keyword_token : Token_mapping.Token_definitions_unified.token -> token option
  (** 转换基础关键字token（兼容性接口） *)

  val is_basic_keyword_token : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为基础关键字token（兼容性接口） *)
end

(** 语义关键字转换器模块 *)
module SemanticKeywords : sig
  val convert_semantic_keywords : Token_mapping.Token_definitions_unified.token -> token option
  (** 转换语义关键字 *)

  val is_semantic_keyword : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为语义关键字 *)
end

(** 错误恢复关键字转换器模块 *)
module ErrorRecoveryKeywords : sig
  val convert_error_recovery_keywords :
    Token_mapping.Token_definitions_unified.token -> token option
  (** 转换错误恢复关键字 *)

  val is_error_recovery_keyword : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为错误恢复关键字 *)
end

(** 模块系统关键字转换器模块 *)
module ModuleKeywords : sig
  val convert_module_keywords : Token_mapping.Token_definitions_unified.token -> token option
  (** 转换模块关键字 *)

  val is_module_keyword : Token_mapping.Token_definitions_unified.token -> bool
  (** 检查是否为模块关键字 *)
end

(** {1 主要接口} *)

val convert_common_tokens : Token_mapping.Token_definitions_unified.token -> token option
(** 快速路径转换 - 消除重复代码的公共函数 *)

val convert_modern_token :
  ?strategy:modern_conversion_strategy ->
  Token_mapping.Token_definitions_unified.token ->
  token option
(** 统一的现代语言转换接口 *)

val is_modern_token : Token_mapping.Token_definitions_unified.token -> bool
(** 检查是否为现代语言token *)

val get_modern_token_category :
  Token_mapping.Token_definitions_unified.token -> modern_token_category option
(** 获取现代语言token类别 *)

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

  val convert_modern_token_exn : Token_mapping.Token_definitions_unified.token -> token
  (** 主转换函数（抛出异常版本） *)
end

(** {1 性能统计模块} *)

(** 性能统计模块 *)
module Statistics : sig
  val get_modern_stats : unit -> string
  (** 获取现代语言转换统计信息 *)
end
