(** 骆言值类型定义模块 - Chinese Programming Language Value Types Module *)

open Ast

(** 运行时值类型 *)
type runtime_value =
  | IntValue of int
  | FloatValue of float
  | StringValue of string
  | BoolValue of bool
  | UnitValue
  | ListValue of runtime_value list
  | RecordValue of (string * runtime_value) list (* 记录值：字段名和值的列表 *)
  | ArrayValue of runtime_value array (* 可变数组 *)
  | FunctionValue of string list * expr * runtime_env (* 参数列表, 函数体, 闭包环境 *)
  | BuiltinFunctionValue of (runtime_value list -> runtime_value)
  | LabeledFunctionValue of label_param list * expr * runtime_env (* 标签函数值：标签参数列表, 函数体, 闭包环境 *)
  | ExceptionValue of string * runtime_value option (* 异常值：异常名称和可选的携带值 *)
  | RefValue of runtime_value ref (* 引用值：可变引用 *)
  | ConstructorValue of string * runtime_value list (* 构造器值：构造器名和参数列表 *)
  | ModuleValue of (string * runtime_value) list (* 模块值：导出的绑定列表 *)
  | PolymorphicVariantValue of string * runtime_value option (* 多态变体值：标签和可选值 *)
  | TupleValue of runtime_value list (* 元组值：元素列表 *)

and runtime_env = (string * runtime_value) list
(** 运行时环境 *)

type env = runtime_env
(** 环境类型 *)

exception RuntimeError of string
(** 运行时错误异常 *)

exception ExceptionRaised of runtime_value
(** 异常抛出 *)

(** 值类型分类 *)
type value_category =
  | BasicValue (* 基础值：Int, Float, String, Bool, Unit *)
  | CollectionValue (* 集合值：List, Array, Tuple *)
  | StructuredValue (* 结构值：Record, Constructor, Module *)
  | FunctionCategory (* 函数值：Function, BuiltinFunction, LabeledFunction *)
  | AdvancedValue (* 高级值：Exception, Ref, PolymorphicVariant *)

(** 获取值的分类 *)
let categorize_value = function
  | IntValue _ | FloatValue _ | StringValue _ | BoolValue _ | UnitValue -> BasicValue
  | ListValue _ | ArrayValue _ | TupleValue _ -> CollectionValue
  | RecordValue _ | ConstructorValue _ | ModuleValue _ -> StructuredValue
  | FunctionValue _ | BuiltinFunctionValue _ | LabeledFunctionValue _ -> FunctionCategory
  | ExceptionValue _ | RefValue _ | PolymorphicVariantValue _ -> AdvancedValue

(** 获取值类型的字符串表示 *)
let string_of_value_type = function
  | IntValue _ -> "整数"
  | FloatValue _ -> "浮点数"
  | StringValue _ -> "字符串"
  | BoolValue _ -> "布尔值"
  | UnitValue -> "单元值"
  | ListValue _ -> "列表"
  | ArrayValue _ -> "数组"
  | TupleValue _ -> "元组"
  | RecordValue _ -> "记录"
  | ConstructorValue (name, _) -> "构造器(" ^ name ^ ")"
  | ModuleValue _ -> "模块"
  | FunctionValue _ -> "函数"
  | BuiltinFunctionValue _ -> "内置函数"
  | LabeledFunctionValue _ -> "标签函数"
  | ExceptionValue (name, _) -> "异常(" ^ name ^ ")"
  | RefValue _ -> "引用"
  | PolymorphicVariantValue (tag, _) -> "多态变体(" ^ tag ^ ")"

(** 检查值是否为基础类型 *)
let is_basic_value value = categorize_value value = BasicValue

(** 检查值是否为集合类型 *)
let is_collection_value value = categorize_value value = CollectionValue

(** 检查值是否为结构化类型 *)
let is_structured_value value = categorize_value value = StructuredValue

(** 检查值是否为函数类型 *)
let is_function_value value = categorize_value value = FunctionCategory

(** 检查值是否为高级类型 *)
let is_advanced_value value = categorize_value value = AdvancedValue

(** 空环境 *)
let empty_env = []

(** 在环境中绑定变量 *)
let bind_var env var_name value = (var_name, value) :: env

(** 获取环境中的所有变量名 *)
let get_env_vars env = List.map fst env

(** 检查环境中是否存在变量 *)
let env_contains_var env var_name = List.mem_assoc var_name env

(** 初始化模块日志器 *)
let () = Logger_init_helpers.replace_init_no_logger "ValueTypes"
