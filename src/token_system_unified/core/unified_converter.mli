(** 统一Token转换器接口 - Issue #1410核心模块
 *
 * 这个接口定义了统一的Token转换系统，替代分散的转换逻辑。
 * 提供类型安全的转换接口、错误处理和性能优化。
 *
 * @author Charlie, 规划Agent - Issue #1410
 * @version 1.0 - 初始统一转换系统接口
 * @since 2025-07-26 *)

(* 重新导出核心类型 *)
include module type of Token_types

type conversion_error = {
  source_text : string;  (** 源文本 *)
  error_message : string;  (** 错误消息 *)
  position : position option;  (** 错误位置 *)
  conversion_type : string;  (** 转换类型 *)
  timestamp : float;  (** 时间戳 *)
}
(** 转换错误信息 *)

(** 转换结果 *)
type conversion_result =
  | Success of positioned_token  (** 转换成功 *)
  | Failure of conversion_error  (** 转换失败 *)

type converter_function = string -> position -> conversion_result
(** 转换器函数类型 *)

(** 转换器类型分类 *)
type converter_type =
  | LiteralConverter  (** 字面量转换器 *)
  | IdentifierConverter  (** 标识符转换器 *)
  | KeywordConverter  (** 关键字转换器 *)
  | OperatorConverter  (** 运算符转换器 *)
  | DelimiterConverter  (** 分隔符转换器 *)
  | SpecialConverter  (** 特殊Token转换器 *)
  | CompositeConverter  (** 复合转换器 *)

type converter_entry = {
  converter_type : converter_type;  (** 转换器类型 *)
  name : string;  (** 转换器名称 *)
  priority : int;  (** 优先级 (越小越高) *)
  converter_func : converter_function;  (** 转换函数 *)
  enabled : bool;  (** 是否启用 *)
}
(** 转换器注册条目 *)

(** 转换器注册表管理 *)
module ConverterRegistry : sig
  val register_converter : converter_entry -> unit
  (** 注册转换器 *)

  val get_converters : converter_type -> converter_entry list
  (** 获取指定类型的转换器列表 *)

  val get_all_converters : unit -> (converter_type * converter_entry list) list
  (** 获取所有转换器 *)

  val clear : unit -> unit
  (** 清空注册表 *)

  val get_stats : unit -> int * int
  (** 获取统计信息 *)
end

(** 内置字面量转换器 *)
module LiteralConverters : sig
  val convert_int_literal : converter_function
  val convert_float_literal : converter_function
  val convert_string_literal : converter_function
  val convert_bool_literal : converter_function
  val convert_chinese_number : converter_function
end

(** 内置关键字转换器 *)
module KeywordConverters : sig
  val convert_keyword : converter_function
end

(** 内置运算符转换器 *)
module OperatorConverters : sig
  val convert_operator : converter_function
end

(** 内置标识符转换器 *)
module IdentifierConverters : sig
  val convert_identifier : converter_function
end

(** 内置分隔符转换器 *)
module DelimiterConverters : sig
  val convert_delimiter : converter_function
end

(** 智能转换器 - 自动类型检测 *)
module SmartConverter : sig
  val convert_smart : converter_function
  (** 智能转换 - 自动检测Token类型并转换 *)
end

(** 主要转换接口 *)

val convert : string -> position -> conversion_result
(** 智能转换单个Token *)

val batch_convert : (string * position) list -> (string * conversion_result) list
(** 批量转换Token列表 *)

val convert_with_type : converter_type -> string -> position -> conversion_result
(** 使用指定类型转换器转换 *)

(** 工具函数 *)

val get_conversion_stats : unit -> string
(** 获取转换器统计信息 *)

val validate_conversion_result : conversion_result -> unit
(** 验证转换结果并打印状态 *)

val initialize : unit -> unit
(** 初始化转换器系统 *)
