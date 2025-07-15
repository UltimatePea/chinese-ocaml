(** 骆言解释器模块接口 - Chinese Programming Language Interpreter Module Interface *)

open Ast
open Value_operations

(** 宏定义类型 *)
type macro_def = { body : expr; args : string list; } [@@warning "-34"]

(** 宏环境类型 *)
type macro_env = (string * macro_def) list [@@warning "-34"]

(** 全局宏表 *)
val macro_table : (string, macro_def) Hashtbl.t

(** 全局模块表 *)
val module_table : (string, (string * runtime_value) list) Hashtbl.t

(** 全局递归函数表 *)
val recursive_functions : (string, runtime_value) Hashtbl.t

(** 全局函子表 *)
val functor_table : (string, identifier * module_type * expr) Hashtbl.t

(** 宏展开 *)
val expand_macro : macro_def -> string list -> expr

(** 执行语句 *)
val execute_stmt : env -> stmt -> env * runtime_value

(** 执行程序 *)
val execute_program : program -> (runtime_value, string) result

(** 解释程序（带输出） *)
val interpret : program -> bool

(** 静默解释程序 *)
val interpret_quiet : program -> bool

(** 交互式表达式求值 *)
val interactive_eval : expr -> env -> runtime_value * env