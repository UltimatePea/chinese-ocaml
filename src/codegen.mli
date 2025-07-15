(** 骆言代码生成器/解释器接口 - Chinese Programming Language Code Generator/Interpreter Interface *)

open Ast

type error_recovery_config = {
  enabled : bool;
  type_conversion : bool;
  spell_correction : bool;
  parameter_adaptation : bool;
  log_level : string;
  collect_statistics : bool;
}
(** 错误恢复配置类型 *)

type recovery_statistics = {
  mutable total_errors : int;
  mutable type_conversions : int;
  mutable spell_corrections : int;
  mutable parameter_adaptations : int;
  mutable variable_suggestions : int;
  mutable or_else_fallbacks : int;
}
(** 错误恢复统计类型 *)

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
  | ExceptionValue of string * runtime_value option
  | RefValue of runtime_value ref
  | ConstructorValue of string * runtime_value list
  | ModuleValue of (string * runtime_value) list

and runtime_env = (string * runtime_value) list
(** 运行时环境类型 *)

type macro_env = (string * macro_def) list
(** 宏环境类型 *)

exception RuntimeError of string
(** 运行时错误异常 *)

exception ExceptionRaised of runtime_value
(** 抛出的异常 *)

val default_recovery_config : error_recovery_config
(** 默认错误恢复配置 *)

val recovery_stats : recovery_statistics
(** 全局错误恢复统计 *)

val macro_table : (string, macro_def) Hashtbl.t
(** 全局宏表 *)

val module_table : (string, (string * runtime_value) list) Hashtbl.t
(** 全局模块表 *)

val recursive_functions : (string, runtime_value) Hashtbl.t
(** 全局递归函数表 *)

val functor_table : (string, identifier * module_type * expr) Hashtbl.t
(** 全局函子表 *)

val empty_env : runtime_env
(** 创建空环境 *)

val levenshtein_distance : string -> string -> int
(** 计算两个字符串的编辑距离 *)

val get_available_vars : runtime_env -> string list
(** 获取环境中的可用变量 *)

val find_closest_var : string -> string list -> string option
(** 查找最接近的变量名 *)

val log_recovery : string -> unit
(** 记录恢复日志 *)

val log_recovery_type : string -> string -> unit
(** 记录特定类型的恢复日志 *)

val show_recovery_statistics : unit -> unit
(** 显示错误恢复统计 *)

val reset_recovery_statistics : unit -> unit
(** 重置错误恢复统计 *)

val set_recovery_config : error_recovery_config -> unit
(** 设置错误恢复配置 *)

val get_recovery_config : unit -> error_recovery_config
(** 获取当前错误恢复配置 *)

val set_log_level : string -> unit
(** 设置日志级别 *)

val lookup_var : runtime_env -> string -> runtime_value
(** 在环境中查找变量 *)

val bind_var : runtime_env -> string -> runtime_value -> runtime_env
(** 绑定变量到环境 *)

val eval_expr : runtime_env -> expr -> runtime_value
(** 评估表达式
    @param env 运行时环境
    @param expr 要评估的表达式
    @return 表达式的值 *)

val value_to_string : runtime_value -> string
(** 将运行时值转换为字符串表示 *)

val register_constructors : runtime_env -> type_def -> runtime_env
(** 为类型定义注册构造器 *)

val execute_stmt : runtime_env -> stmt -> runtime_env * runtime_value
(** 执行语句 *)

val builtin_functions : (string * runtime_value) list
(** 内置函数列表 *)

val execute_program : program -> (runtime_value, string) result
(** 执行程序
    @param program 要执行的程序（语句列表）
    @return 执行结果或错误信息 *)

val interpret : program -> bool
(** 解释执行程序（带输出）
    @param program 要解释执行的程序
    @return 执行是否成功 *)

val interpret_quiet : program -> bool
(** 安静模式解释执行程序（用于测试）
    @param program 要解释执行的程序
    @return 执行是否成功 *)

val interactive_eval : expr -> runtime_env -> runtime_env
(** 交互式表达式求值
    @param expr 要求值的表达式
    @param env 运行时环境
    @return 更新后的环境 *)
