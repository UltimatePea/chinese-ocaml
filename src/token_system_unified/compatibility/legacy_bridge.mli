(** Token系统向后兼容桥接层接口 - Issue #1410
 *
 * 这个接口定义了与现有Token系统的向后兼容性，确保现有代码
 * 可以无缝迁移到新的统一Token系统。
 *
 * @author Charlie, 规划Agent - Issue #1410
 * @version 1.0 - 初始兼容桥接层接口
 * @since 2025-07-26 *)

(** 旧系统类型定义 *)
module LegacyTypes : sig
  type legacy_token = 
    | LegacyOperatorToken of string
    | LegacyKeywordToken of string  
    | LegacyLiteralToken of string
    | LegacyIdentifierToken of string
    | LegacyDelimiterToken of string
    | LegacySpecialToken of string

  type legacy_position = { line : int; column : int; filename : string }
  type legacy_positioned_token = legacy_token * legacy_position
end

(** 新旧系统类型转换器 *)
module TypeConverter : sig
  open LegacyTypes

  (** 将旧Token转换为新Token *)
  val legacy_to_unified : legacy_token -> Token_system_unified.Core.Token_types.token option

  (** 将新Token转换为旧Token *)
  val unified_to_legacy : Token_system_unified.Core.Token_types.token -> legacy_token

  (** 位置信息转换 *)
  val legacy_position_to_unified : legacy_position -> Token_system_unified.Core.Token_types.position
  val unified_position_to_legacy : Token_system_unified.Core.Token_types.position -> legacy_position

  (** 带位置Token转换 *)
  val legacy_positioned_to_unified : legacy_positioned_token -> Token_system_unified.Core.Token_types.positioned_token option
  val unified_positioned_to_legacy : Token_system_unified.Core.Token_types.positioned_token -> legacy_positioned_token
end

(** 兼容性API包装器 *)
module CompatibilityAPI : sig
  (** 模拟原有Token_types模块 *)
  module Token_types_compat : sig
    include module type of LegacyTypes
    
    val token_to_string : legacy_token -> string
    val make_position : int -> int -> string -> legacy_position
  end

  (** 模拟原有Token_conversion模块 *)
  module Token_conversion_compat : sig
    type conversion_error = string
    exception Conversion_failed of conversion_error
    
    val convert_token : string -> LegacyTypes.legacy_positioned_token
    val convert_token_safe : string -> LegacyTypes.legacy_positioned_token option
    val batch_convert_tokens : string list -> LegacyTypes.legacy_positioned_token option list
  end

  (** 模拟原有Token_utils模块 *)
  module Token_utils_compat : sig
    val is_keyword : LegacyTypes.legacy_token -> bool
    val is_literal : LegacyTypes.legacy_token -> bool
    val is_identifier : LegacyTypes.legacy_token -> bool
    val is_operator : LegacyTypes.legacy_token -> bool
    val get_token_text : LegacyTypes.legacy_token -> string
  end

  (** 模拟原有Token_registry模块 *)
  module Token_registry_compat : sig
    val register_mapping : string -> LegacyTypes.legacy_token -> unit
    val find_mapping : string -> LegacyTypes.legacy_positioned_token option
    val get_all_mappings : unit -> (string * LegacyTypes.legacy_token) list
  end
end

(** 迁移辅助工具 *)
module MigrationHelper : sig
  (** 检查模块兼容性 *)
  val check_compatibility : string -> bool

  (** 生成迁移报告 *)
  val generate_migration_report : int -> int -> unit

  (** 迁移单个文件 *)
  val migrate_file : string -> bool

  (** 验证批量迁移结果 *)
  val validate_migration : string list -> bool
end

(** 性能对比工具 *)
module PerformanceComparison : sig
  (** 对比单个转换的性能 *)
  val compare_conversion_performance : string -> int -> unit

  (** 运行完整的基准测试套件 *)
  val benchmark_suite : unit -> unit
end

(** 初始化兼容桥接层 *)
val initialize : unit -> unit

(** 重新导出兼容性API *)
include module type of CompatibilityAPI