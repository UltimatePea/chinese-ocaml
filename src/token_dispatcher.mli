(** Token调度核心模块接口
 *
 *  统一Token转换系统的向后兼容接口层
 *  为现有代码提供稳定的API，同时委托给重构后的转换器
 *  
 *  ## 模块组织
 *  - Identifiers: 标识符转换接口
 *  - Literals: 字面量转换接口  
 *  - BasicKeywords: 基础关键字转换接口
 *  - TypeKeywords: 类型关键字转换接口
 *  - Classical: 古典语言转换接口
 *  
 *  @author 骆言技术债务清理团队
 *  @version 2.0 - 基于统一转换系统重构
 *  @since 2025-07-25 *)

(** 标识符转换模块向后兼容接口 *)
module Identifiers : sig
  val convert_identifier_token : Token_unified.token -> Token_unified.token
  (** 转换标识符Token *)
end

(** 字面量转换模块向后兼容接口 *)  
module Literals : sig
  val convert_literal_token : Token_unified.token -> Token_unified.token
  (** 转换字面量Token *)
end

(** 基础关键字转换模块向后兼容接口 *)
module BasicKeywords : sig
  val convert_basic_keyword_token : Token_unified.token -> Token_unified.token
  (** 转换基础关键字Token *)
end

(** 类型关键字转换模块向后兼容接口 *)
module TypeKeywords : sig
  val convert_type_keyword_token : Token_unified.token -> Token_unified.token
  (** 转换类型关键字Token *)
end

(** 古典语言转换模块向后兼容接口 *)
module Classical : sig
  val convert_wenyan_token : Token_unified.token -> Token_unified.token
  (** 转换文言文Token *)
  
  val convert_natural_language_token : Token_unified.token -> Token_unified.token  
  (** 转换自然语言Token *)
  
  val convert_ancient_token : Token_unified.token -> Token_unified.token
  (** 转换古典语言Token *)
  
  val convert_classical_token : Token_unified.token -> Token_unified.token
  (** 转换古典风格Token *)
end

val convert_token : Token_unified.token -> Token_unified.token
(** 主要Token转换接口
    @param token 待转换的Token
    @return 转换后的Token *)

val convert_token_list : Token_unified.token list -> Token_unified.token list
(** 批量Token转换接口  
    @param tokens 待转换的Token列表
    @return 转换后的Token列表 *)

val get_conversion_stats : unit -> Token_conversion_unified.conversion_stats
(** 获取转换统计信息 *)

(** 向后兼容的异常定义 *)
exception Unknown_identifier_token of string
exception Unknown_literal_token of string  
exception Unknown_basic_keyword_token of string
exception Unknown_type_keyword_token of string
exception Unknown_classical_token of string