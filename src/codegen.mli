(** 骆言代码生成器/解释器接口 - Chinese Programming Language Code Generator/Interpreter Interface *)

open Ast
open Value_operations

(** {1 主要的程序执行接口} *)

val empty_env : env
(** 创建空环境 *)

val execute_program : program -> (runtime_value, string) result
(** 程序执行函数 - 执行一个完整的程序并返回结果 *)

val compile_and_run : program -> (runtime_value, string) result
(** 主要的编译和执行入口点 *)

(** {1 为了向后兼容，保留的函数别名} *)

val interpret : program -> bool
(** 解释程序（带输出） *)

val interpret_quiet : program -> bool
(** 静默解释程序 *)

val interactive_eval : expr -> env -> runtime_value * env
(** 交互式表达式求值 *)

val lookup_var : env -> string -> runtime_value
(** 变量查找 *)

val bind_var : env -> string -> runtime_value -> env
(** 变量绑定 *)

val value_to_string : runtime_value -> string
(** 值转换为字符串 *)

val eval_expr : env -> Ast.expr -> runtime_value
(** 表达式求值 - 为了兼容性保留 *)

val try_to_int : runtime_value -> int option
(** 类型转换函数 - 为了兼容性保留 *)

val try_to_float : runtime_value -> float option
val try_to_string : runtime_value -> string option

val value_to_bool : runtime_value -> bool
(** 值转换为布尔值 *)

val execute_stmt : env -> Ast.stmt -> env * runtime_value
(** 执行语句 - 为了兼容性保留 *)

val builtin_functions : env
(** 内置函数表 - 为了兼容性保留 *)

(** 字面量求值函数 - 为了兼容性保留 *)
val eval_literal : Ast.literal -> runtime_value
(** 求值字面量 *)

val execute_binary_op : Ast.binary_op -> runtime_value -> runtime_value -> runtime_value
(** 操作符执行函数 - 为了兼容性保留 *)

val execute_unary_op : Ast.unary_op -> runtime_value -> runtime_value
val call_function : runtime_value -> runtime_value list -> runtime_value
val match_pattern : Ast.pattern -> runtime_value -> (string * runtime_value) list option
val execute_match : runtime_value -> (Ast.pattern * Ast.expr) list -> env -> runtime_value

exception RuntimeError of string
(** 运行时错误类型别名 *)

exception ExceptionRaised of runtime_value

(** {1 错误恢复配置接口} *)

val set_recovery_config : Error_recovery.error_recovery_config -> unit
(** 设置错误恢复配置 *)

val get_recovery_config : unit -> Error_recovery.error_recovery_config
(** 获取错误恢复配置 *)

val reset_recovery_statistics : unit -> unit
(** 重置错误恢复统计 *)

val show_recovery_statistics : unit -> unit
(** 显示错误恢复统计信息 *)
