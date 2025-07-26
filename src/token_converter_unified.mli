(** 统一Token转换器接口 - 技术债务清理 Issue #1375 *)

open Token_unified

(** 转换策略类型 *)
type converter_strategy = [
  | `Direct        (** 直接转换策略 *)
  | `Classical     (** 古典语言转换策略 *)
  | `Natural       (** 自然语言转换策略 *)
]

(** 转换上下文 *)
type conversion_context = {
  strategy : converter_strategy;
  allow_deprecated : bool;
  fallback_enabled : bool;
  strict_mode : bool;
}

(** 转换异常 *)
exception Unknown_token of string
exception Conversion_failed of string * string

(** 默认转换上下文 *)
val default_context : conversion_context

(** 字面量转换模块 *)
module Literal : sig
  (** 转换中文数字到Token *)
  val convert_chinese_number : string -> unified_token option
  
  (** 转换字面量 *)
  val convert : string -> unified_token option
end

(** 标识符转换模块 *)
module Identifier : sig
  (** 检查是否为引用标识符 *)
  val is_quoted_identifier : string -> bool
  
  (** 检查是否为构造器 *)
  val is_constructor : string -> bool
  
  (** 转换标识符 *)
  val convert : string -> unified_token option
end

(** 关键字转换模块 *)
module Keyword : sig
  (** 基础关键字转换 *)
  val convert_basic : string -> basic_keyword option
  
  (** 类型关键字转换 *)
  val convert_type : string -> type_keyword option
  
  (** 控制流关键字转换 *)
  val convert_control : string -> control_keyword option
  
  (** 古典语言关键字转换 *)
  val convert_classical : string -> classical_keyword option
  
  (** 统一关键字转换 *)
  val convert : string -> unified_token option
end

(** 操作符转换模块 *)
module Operator : sig
  (** 转换操作符 *)
  val convert : string -> operator option
end

(** 分隔符转换模块 *)
module Delimiter : sig
  (** 转换分隔符 *)
  val convert : string -> delimiter option
end

(** 主转换函数 *)
val convert_token : string -> conversion_context -> unified_token option

(** 便利函数：使用默认上下文转换 *)
val convert : string -> unified_token option

(** 严格模式转换：失败时抛出异常 *)
val convert_strict : string -> unified_token

(** 批量转换函数 *)
val convert_tokens : string list -> conversion_context -> unified_token list