(** 骆言解释器状态管理模块接口 - Chinese Programming Language Interpreter State Management Interface *)

open Value_operations

type interpreter_state = {
  macro_table : (string, Ast.macro_def) Hashtbl.t;
  module_table : (string, (string * runtime_value) list) Hashtbl.t;
  recursive_functions : (string, runtime_value) Hashtbl.t;
  functor_table : (string, Ast.identifier * Ast.module_type * Ast.expr) Hashtbl.t;
}
(** 解释器状态记录类型 *)

val create_state : unit -> interpreter_state
(** 创建新的解释器状态 *)

val get_macro_table : unit -> (string, Ast.macro_def) Hashtbl.t
(** 访问宏表 *)

val get_module_table : unit -> (string, (string * runtime_value) list) Hashtbl.t
(** 访问模块表 *)

val get_recursive_functions : unit -> (string, runtime_value) Hashtbl.t
(** 访问递归函数表 *)

val get_functor_table : unit -> (string, Ast.identifier * Ast.module_type * Ast.expr) Hashtbl.t
(** 访问函子表 *)

val add_macro : string -> Ast.macro_def -> unit
(** 宏操作 *)

val find_macro : string -> Ast.macro_def option

val add_module : string -> (string * runtime_value) list -> unit
(** 模块操作 *)

val find_module : string -> (string * runtime_value) list option

val add_recursive_function : string -> runtime_value -> unit
(** 递归函数操作 *)

val find_recursive_function : string -> runtime_value option

val add_functor : string -> Ast.identifier -> Ast.module_type -> Ast.expr -> unit
(** 函子操作 *)

val find_functor : string -> (Ast.identifier * Ast.module_type * Ast.expr) option

val reset_state : unit -> unit
(** 重置状态 *)

val get_available_vars : runtime_env -> string list
(** 获取可用变量列表 *)
