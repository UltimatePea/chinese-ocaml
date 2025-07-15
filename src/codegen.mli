(** 骆言代码生成器/解释器 - Chinese Programming Language Code Generator/Interpreter *)

(** {1 错误恢复配置} *)

(** 错误恢复配置 *)
type error_recovery_config = {
  enabled : bool;
  type_conversion : bool;
  spell_correction : bool;
  parameter_adaptation : bool;
  log_level : string;
  collect_statistics : bool;
}

(** 错误恢复统计 *)
type recovery_statistics = {
  mutable total_errors : int;
  mutable type_conversions : int;
  mutable spell_corrections : int;
  mutable parameter_adaptations : int;
  mutable variable_suggestions : int;
  mutable or_else_fallbacks : int;
}

(** {1 运行时值和环境} *)

(** 运行时值 *)
type runtime_value =
  | IntValue of int
  | FloatValue of float
  | StringValue of string
  | BoolValue of bool
  | UnitValue
  | ListValue of runtime_value list
  | RecordValue of (string * runtime_value) list
  | ArrayValue of runtime_value array
  | FunctionValue of string list * Ast.expr * runtime_env
  | BuiltinFunctionValue of (runtime_value list -> runtime_value)
  | LabeledFunctionValue of Ast.label_param list * Ast.expr * runtime_env
  | ExceptionValue of string * runtime_value option
  | RefValue of runtime_value ref
  | ConstructorValue of string * runtime_value list
  | ModuleValue of (string * runtime_value) list
  | PolymorphicVariantValue of string * runtime_value option

(** 运行时环境 *)
and runtime_env = (string * runtime_value) list

(** {1 异常定义} *)

(** 运行时错误 *)
exception RuntimeError of string

(** 抛出的异常 *)
exception ExceptionRaised of runtime_value

(** {1 错误恢复配置和统计} *)

(** 默认错误恢复配置 *)
val default_recovery_config : error_recovery_config

(** 全局错误恢复统计 *)
val recovery_stats : recovery_statistics

(** 设置错误恢复配置 *)
val set_recovery_config : error_recovery_config -> unit

(** 获取错误恢复配置 *)
val get_recovery_config : unit -> error_recovery_config

(** 设置日志级别 *)
val set_log_level : string -> unit

(** 显示错误恢复统计 *)
val show_recovery_statistics : unit -> unit

(** 重置错误恢复统计 *)
val reset_recovery_statistics : unit -> unit

(** {1 环境操作} *)

(** 创建空环境 *)
val empty_env : runtime_env

(** 在环境中查找变量 *)
val lookup_var : runtime_env -> string -> runtime_value

(** 在环境中绑定变量 *)
val bind_var : runtime_env -> string -> runtime_value -> runtime_env

(** {1 值操作和转换} *)

(** 值转换为字符串 *)
val value_to_string : runtime_value -> string

(** 值转换为布尔值 *)
val value_to_bool : runtime_value -> bool

(** 尝试转换为整数 *)
val try_to_int : runtime_value -> int option

(** 尝试转换为浮点数 *)
val try_to_float : runtime_value -> float option

(** 尝试转换为字符串 *)
val try_to_string : runtime_value -> string option

(** {1 执行和求值} *)

(** 求值表达式 *)
val eval_expr : runtime_env -> Ast.expr -> runtime_value

(** 求值字面量 *)
val eval_literal : Ast.literal -> runtime_value

(** 执行语句 *)
val execute_stmt : runtime_env -> Ast.stmt -> runtime_env * runtime_value

(** 执行程序 *)
val execute_program : Ast.stmt list -> (runtime_value, string) result

(** 解释执行入口函数 *)
val interpret : Ast.stmt list -> bool

(** 安静模式解释执行 - 用于测试 *)
val interpret_quiet : Ast.stmt list -> bool

(** 交互式求值 *)
val interactive_eval : Ast.expr -> runtime_env -> runtime_env

(** {1 函数调用} *)

(** 调用函数 *)
val call_function : runtime_value -> runtime_value list -> runtime_value

(** 调用标签函数 *)
val call_labeled_function : runtime_value -> Ast.label_arg list -> runtime_env -> runtime_value

(** {1 模式匹配} *)

(** 模式匹配 *)
val match_pattern : Ast.pattern -> runtime_value -> runtime_env -> runtime_env option

(** 执行模式匹配 *)
val execute_match : runtime_env -> runtime_value -> Ast.match_branch list -> runtime_value

(** 执行异常匹配 *)
val execute_exception_match : runtime_env -> runtime_value -> Ast.match_branch list -> runtime_value

(** {1 运算实现} *)

(** 二元运算实现 *)
val execute_binary_op : Ast.binary_op -> runtime_value -> runtime_value -> runtime_value

(** 一元运算实现 *)
val execute_unary_op : Ast.unary_op -> runtime_value -> runtime_value

(** {1 类型和构造器} *)

(** 注册构造器函数 *)
val register_constructors : runtime_env -> Ast.type_def -> runtime_env

(** {1 内置函数} *)

(** 内置函数实现 *)
val builtin_functions : (string * runtime_value) list