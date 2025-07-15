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
  | ArrayValue of runtime_value array
  | FunctionValue of
      { 
        params : (identifier * typo) list; 
        body : expr; 
        closure_env : (string * runtime_value) list 
      }
  | RecursiveFunctionValue of
      { 
        func_name : identifier; 
        params : (identifier * typo) list; 
        body : expr; 
        closure_env : (string * runtime_value) list 
      }
  | VariantValue of 
      { 
        tag : identifier; 
        arg : runtime_value option 
      }

(** 环境类型 *)
type env = (string * runtime_value) list

(** 空环境 *)
val empty_env : env

(** 变量绑定 *)
val bind_var : env -> string -> runtime_value -> env

(** 变量查找 *)
val lookup_var : env -> string -> runtime_value

(** 值转换为字符串表示 *)
val value_to_string : runtime_value -> string

(** 类型定义注册 *)
val register_constructors : env -> type_def -> env