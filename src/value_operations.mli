(** 骆言值操作模块接口 - Chinese Programming Language Value Operations Module Interface *)

open Ast

(** 运行时值类型 *)
type runtime_value =
  | IntValue of int
  | FloatValue of float
  | StringValue of string
  | BoolValue of bool
  | UnitValue
  | ListValue of runtime_value list
  | RecordValue of (string * runtime_value) list
  | ArrayValue of runtime_value array
  | FunctionValue of string list * expr * runtime_env
  | BuiltinFunctionValue of (runtime_value list -> runtime_value)
  | LabeledFunctionValue of label_param list * expr * runtime_env
  | ExceptionValue of string * runtime_value option
  | RefValue of runtime_value ref
  | ConstructorValue of string * runtime_value list
  | ModuleValue of (string * runtime_value) list
  | PolymorphicVariantValue of string * runtime_value option
  | TupleValue of runtime_value list

and runtime_env = (string * runtime_value) list

exception RuntimeError of string
(** 运行时异常 *)

exception ExceptionRaised of runtime_value
(** 异常抛出 *)

type env = (string * runtime_value) list
(** 环境类型 *)

val empty_env : env
(** 空环境 *)

val bind_var : env -> string -> runtime_value -> env
(** 变量绑定 *)

val lookup_var : env -> string -> runtime_value
(** 变量查找 *)

val value_to_string : runtime_value -> string
(** 值转换为字符串表示 *)

val value_to_bool : runtime_value -> bool
(** 值转换为布尔值 *)

val try_to_int : runtime_value -> int option
(** 尝试将值转换为整数 *)

val try_to_float : runtime_value -> float option
(** 尝试将值转换为浮点数 *)

val try_to_string : runtime_value -> string option
(** 尝试将值转换为字符串 *)

val register_constructors : env -> type_def -> env
(** 类型定义注册 *)

val runtime_value_equal : runtime_value -> runtime_value -> bool
(** 运行时值相等性比较 *)

val runtime_value_pp : Format.formatter -> runtime_value -> unit
(** 运行时值打印函数 *)

module ValueModule : sig
  type t = runtime_value
  val equal : runtime_value -> runtime_value -> bool
  val pp : Format.formatter -> runtime_value -> unit
end
(** Alcotest ValueModule - 用于测试 *)
