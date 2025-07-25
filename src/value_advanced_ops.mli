(** 骆言高级值操作模块接口 - Chinese Programming Language Advanced Value Operations Module Interface *)

open Value_types
open Ast

val list_value_to_string : (runtime_value -> string) -> runtime_value list -> string
(** 列表值转换为字符串的辅助函数 *)

val array_value_to_string : (runtime_value -> string) -> runtime_value array -> string
(** 数组值转换为字符串的辅助函数 *)

val tuple_value_to_string : (runtime_value -> string) -> runtime_value list -> string
(** 元组值转换为字符串的辅助函数 *)

val record_value_to_string : (runtime_value -> string) -> (string * runtime_value) list -> string
(** 记录值转换为字符串的辅助函数 *)

val ref_value_to_string : (runtime_value -> string) -> runtime_value ref -> string
(** 引用值转换为字符串的辅助函数 *)

val container_value_to_string : (runtime_value -> string) -> runtime_value -> string
(** 容器类型值转换为字符串 - 重构版本，使用分派函数 *)

val function_value_to_string : runtime_value -> string
(** 函数类型值转换为字符串 *)

val constructor_value_to_string : (runtime_value -> string) -> runtime_value -> string
(** 构造器和异常类型值转换为字符串 *)

val module_value_to_string : runtime_value -> string
(** 模块类型值转换为字符串 *)

val value_to_string : runtime_value -> string
(** 值转换为字符串 - 重构后的主函数 *)

val register_constructors : env -> type_def -> env
(** 注册构造器函数 *)

(** 基础类型值相等性比较的辅助函数 *)

(** 基础值比较函数现在从 Value_operations_basic 模块提供 *)

(** 容器类型、构造器类型、模块类型和函数类型值比较函数 *)

(** 以及运行时值相等性比较函数现在统一从 Value_operations_basic 模块提供 *)

val runtime_value_pp : Format.formatter -> runtime_value -> unit
(** 运行时值打印函数 *)

(** Alcotest ValueModule - 用于测试 *)
module ValueModule : sig
  type t = runtime_value

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
end
