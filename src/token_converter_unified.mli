(** 统一Token转换器接口 - 技术债务清理 Issue #1375 *)

open Token_unified

type converter_strategy =
  [ `Direct  (** 直接转换策略 *) | `Classical  (** 古典语言转换策略 *) | `Natural  (** 自然语言转换策略 *) ]
(** 转换策略类型 *)

type conversion_context = {
  strategy : converter_strategy;
  allow_deprecated : bool;
  fallback_enabled : bool;
  strict_mode : bool;
}
(** 转换上下文 *)

exception Unknown_token of string
(** 转换异常 *)

exception Conversion_failed of string * string

val default_context : conversion_context
(** 默认转换上下文 *)

(** 字面量转换模块 *)
module Literal : sig
  val convert_chinese_number : string -> unified_token option
  (** 转换中文数字到Token *)

  val convert : string -> unified_token option
  (** 转换字面量 *)
end

(** 标识符转换模块 *)
module Identifier : sig
  val is_quoted_identifier : string -> bool
  (** 检查是否为引用标识符 *)

  val is_constructor : string -> bool
  (** 检查是否为构造器 *)

  val convert : string -> unified_token option
  (** 转换标识符 *)
end

(** 关键字转换模块 *)
module Keyword : sig
  val convert_basic : string -> basic_keyword option
  (** 基础关键字转换 *)

  val convert_type : string -> type_keyword option
  (** 类型关键字转换 *)

  val convert_control : string -> control_keyword option
  (** 控制流关键字转换 *)

  val convert_classical : string -> classical_keyword option
  (** 古典语言关键字转换 *)

  val convert : string -> unified_token option
  (** 统一关键字转换 *)
end

(** 操作符转换模块 *)
module Operator : sig
  val convert : string -> operator option
  (** 转换操作符 *)
end

(** 分隔符转换模块 *)
module Delimiter : sig
  val convert : string -> delimiter option
  (** 转换分隔符 *)
end

val convert_token : string -> conversion_context -> unified_token option
(** 主转换函数 *)

val convert : string -> unified_token option
(** 便利函数：使用默认上下文转换 *)

val convert_strict : string -> unified_token
(** 严格模式转换：失败时抛出异常 *)

val convert_tokens : string list -> conversion_context -> unified_token list
(** 批量转换函数 *)
