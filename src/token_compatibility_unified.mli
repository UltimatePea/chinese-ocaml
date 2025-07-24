(** Token兼容性统一模块接口 - Issue #1066 技术债务改进

    此模块整合了原先分散在6个文件中的Token兼容性逻辑，提供统一的兼容性检查接口。

    @author 骆言技术债务清理团队 Issue #1066
    @version 1.0  
    @since 2025-07-24 *)

(** 分隔符映射 *)
val map_legacy_delimiter_to_unified : string -> Unified_token_core.unified_token option

(** 字面量映射 *)
val map_legacy_literal_to_unified : string -> Unified_token_core.unified_token option

(** 标识符映射 *)
val map_legacy_identifier_to_unified : string -> Unified_token_core.unified_token option

(** 特殊Token映射 *)
val map_legacy_special_to_unified : string -> Unified_token_core.unified_token option

(** 运算符映射 *)
val map_legacy_operator_to_unified : string -> Unified_token_core.unified_token option

(** 基础关键字映射 *)
val map_basic_keywords : string -> Unified_token_core.unified_token option

(** 文言文关键字映射 *)
val map_wenyan_keywords : string -> Unified_token_core.unified_token option

(** 古雅体关键字映射 *)
val map_classical_keywords : string -> Unified_token_core.unified_token option

(** 自然语言函数关键字映射 *)
val map_natural_language_keywords : string -> Unified_token_core.unified_token option

(** 类型关键字映射 *)
val map_type_keywords : string -> Unified_token_core.unified_token option

(** 诗词关键字映射 *)
val map_poetry_keywords : string -> Unified_token_core.unified_token option

(** 杂项关键字映射 *)
val map_misc_keywords : string -> Unified_token_core.unified_token option

(** 统一关键字映射接口 *)
val map_legacy_keyword_to_unified : string -> Unified_token_core.unified_token option

(** 核心转换函数 *)
val convert_legacy_token_string : string -> 'a option -> Unified_token_core.unified_token option

(** 创建兼容的带位置Token *)
val make_compatible_positioned_token : string -> 'a option -> string -> int -> int -> Unified_token_core.positioned_token option

(** 检查Token字符串是否与统一系统兼容 *)
val is_compatible_with_legacy : string -> bool

(** JSON数据加载器模块 *)
module TokenDataLoader : sig
  (** 查找数据文件 *)
  val find_data_file : unit -> string
  
  (** 加载Token类别 *)
  val load_token_category : string -> string list
  
  (** 加载所有Token *)
  val load_all_tokens : unit -> string list
end

(** 获取所有支持的遗留Token列表 *)
val get_supported_legacy_tokens : unit -> string list

(** 生成基础兼容性报告 *)
val generate_compatibility_report : unit -> string

(** 生成详细的兼容性报告 *)
val generate_detailed_compatibility_report : unit -> string

(** 向后兼容性保证 - 重新导出原有接口 *)

(** 分隔符兼容性模块 *)
module Delimiters : sig
  val map_legacy_delimiter_to_unified : string -> Unified_token_core.unified_token option
end

(** 字面量兼容性模块 *)
module Literals : sig
  val map_legacy_literal_to_unified : string -> Unified_token_core.unified_token option
  val map_legacy_identifier_to_unified : string -> Unified_token_core.unified_token option
  val map_legacy_special_to_unified : string -> Unified_token_core.unified_token option
end

(** 运算符兼容性模块 *)
module Operators : sig
  val map_legacy_operator_to_unified : string -> Unified_token_core.unified_token option
end

(** 关键字兼容性模块 *)
module Keywords : sig
  val map_basic_keywords : string -> Unified_token_core.unified_token option
  val map_wenyan_keywords : string -> Unified_token_core.unified_token option
  val map_classical_keywords : string -> Unified_token_core.unified_token option
  val map_natural_language_keywords : string -> Unified_token_core.unified_token option
  val map_type_keywords : string -> Unified_token_core.unified_token option
  val map_poetry_keywords : string -> Unified_token_core.unified_token option
  val map_misc_keywords : string -> Unified_token_core.unified_token option
  val map_legacy_keyword_to_unified : string -> Unified_token_core.unified_token option
end

(** 报告生成模块 *)
module Reports : sig
  module TokenDataLoader : sig
    val find_data_file : unit -> string
    val load_token_category : string -> string list
    val load_all_tokens : unit -> string list
  end
  
  val get_supported_legacy_tokens : unit -> string list
  val generate_compatibility_report : unit -> string
  val generate_detailed_compatibility_report : unit -> string
end

(** 核心转换模块 *)
module Core : sig
  val convert_legacy_token_string : string -> 'a option -> Unified_token_core.unified_token option
  val make_compatible_positioned_token : string -> 'a option -> string -> int -> int -> Unified_token_core.positioned_token option
  val is_compatible_with_legacy : string -> bool
end

(** 统计信息 *)
val get_compatibility_stats : unit -> string