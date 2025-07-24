(** 骆言运行时值类型定义模块接口 - Runtime Value Types Module Interface *)

open Ast

(** 运行时值类型 *)
type runtime_value =
  | IntValue of int
  | FloatValue of float  
  | StringValue of string
  | BoolValue of bool
  | UnitValue
  | ListValue of runtime_value list
  | ArrayValue of runtime_value array
  | TupleValue of runtime_value list
  | RecordValue of (string * runtime_value) list
  | ConstructorValue of string * runtime_value list
  | ModuleValue of (string * runtime_value) list
  | FunctionValue of string list * expr * runtime_env
  | BuiltinFunctionValue of (runtime_value list -> runtime_value)
  | LabeledFunctionValue of label_param list * expr * runtime_env
  | ExceptionValue of string * runtime_value option
  | RefValue of runtime_value ref
  | PolymorphicVariantValue of string * runtime_value option

and runtime_env = (string * runtime_value) list

type env = runtime_env

exception RuntimeError of string
exception ExceptionRaised of runtime_value

(** 值类型分类 *)
type value_category =
  | BasicValue
  | CollectionValue
  | StructuredValue
  | FunctionCategory
  | AdvancedValue

(** 获取值的分类 *)
val categorize_value : runtime_value -> value_category

(** 获取值类型的字符串表示 *)
val string_of_value_type : runtime_value -> string

(** 类型检查函数 *)
val is_basic_value : runtime_value -> bool
val is_collection_value : runtime_value -> bool
val is_structured_value : runtime_value -> bool
val is_function_value : runtime_value -> bool
val is_advanced_value : runtime_value -> bool

(** 环境操作 *)
val empty_env : env
val bind_var : env -> string -> runtime_value -> env
val get_env_vars : env -> string list
val env_contains_var : env -> string -> bool