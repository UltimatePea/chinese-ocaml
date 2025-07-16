(** 骆言解释器模块接口 - Chinese Programming Language Interpreter Module Interface *)

open Ast
open Value_operations

val macro_table : (string, Ast.macro_def) Hashtbl.t
(** 全局宏表 *)

val module_table : (string, (string * runtime_value) list) Hashtbl.t
(** 全局模块表 *)

val recursive_functions : (string, runtime_value) Hashtbl.t
(** 全局递归函数表 *)

val functor_table : (string, identifier * module_type * expr) Hashtbl.t
(** 全局函子表 *)

val expand_macro : Ast.macro_def -> expr list -> expr
(** 宏展开 *)

val execute_stmt : env -> stmt -> env * runtime_value
(** 执行语句 *)

val execute_program : program -> (runtime_value, string) result
(** 执行程序 *)

val interpret : program -> bool
(** 解释程序（带输出） *)

val interpret_quiet : program -> bool
(** 静默解释程序 *)

val interactive_eval : expr -> env -> runtime_value * env
(** 交互式表达式求值 *)
