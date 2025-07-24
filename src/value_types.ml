(** 骆言运行时值类型定义模块 - Runtime Value Types Module
    
    技术债务改进：大型模块重构优化 Phase 2.1 - value_operations.ml 模块化拆分
    本模块包含所有运行时值类型的核心定义，从 value_operations.ml 中提取
    
    重构目标：
    1. 将复杂的运行时值类型系统从单个大文件中分离
    2. 提供清晰的类型定义和基础操作接口
    3. 为其他值操作模块提供统一的类型基础
    
    @author 骆言AI代理
    @version 2.1 - 模块化拆分第一阶段  
    @since 2025-07-24 Fix #1046
*)

open Ast

(** 运行时值类型 - 核心类型系统 *)
type runtime_value =
  (* 基础值类型 *)
  | IntValue of int
  | FloatValue of float  
  | StringValue of string
  | BoolValue of bool
  | UnitValue
  
  (* 集合类型 *)
  | ListValue of runtime_value list
  | ArrayValue of runtime_value array
  | TupleValue of runtime_value list
  
  (* 结构化类型 *)
  | RecordValue of (string * runtime_value) list
  | ConstructorValue of string * runtime_value list
  | ModuleValue of (string * runtime_value) list
  
  (* 函数类型 *)
  | FunctionValue of string list * expr * runtime_env
  | BuiltinFunctionValue of (runtime_value list -> runtime_value)
  | LabeledFunctionValue of label_param list * expr * runtime_env
  
  (* 高级类型 *)
  | ExceptionValue of string * runtime_value option
  | RefValue of runtime_value ref
  | PolymorphicVariantValue of string * runtime_value option

and runtime_env = (string * runtime_value) list
(** 运行时环境类型 *)

(** 环境类型别名 *)
type env = runtime_env

(** 运行时错误异常 *)
exception RuntimeError of string

(** 异常抛出 *)
exception ExceptionRaised of runtime_value

(** 值类型分类 *)
type value_category =
  | BasicValue      (* 基础值：Int, Float, String, Bool, Unit *)
  | CollectionValue (* 集合值：List, Array, Tuple *)
  | StructuredValue (* 结构值：Record, Constructor, Module *)
  | FunctionCategory   (* 函数值：Function, BuiltinFunction, LabeledFunction *)
  | AdvancedValue   (* 高级值：Exception, Ref, PolymorphicVariant *)

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
let is_basic_value value = 
  categorize_value value = BasicValue

(** 检查值是否为集合类型 *)
let is_collection_value value = 
  categorize_value value = CollectionValue

(** 检查值是否为结构化类型 *)
let is_structured_value value = 
  categorize_value value = StructuredValue

(** 检查值是否为函数类型 *)
let is_function_value value = 
  categorize_value value = FunctionCategory

(** 检查值是否为高级类型 *)
let is_advanced_value value = 
  categorize_value value = AdvancedValue

(** 空环境 *)
let empty_env = []

(** 在环境中绑定变量 *)
let bind_var env var_name value = (var_name, value) :: env

(** 获取环境中的所有变量名 *)
let get_env_vars env = List.map fst env

(** 检查环境中是否存在变量 *)
let env_contains_var env var_name = List.mem_assoc var_name env