(** 骆言解释器状态管理模块 - Chinese Programming Language Interpreter State Management *)

open Ast
open Value_operations

type interpreter_state = {
  macro_table : (string, Ast.macro_def) Hashtbl.t;
  module_table : (string, (string * runtime_value) list) Hashtbl.t;
  recursive_functions : (string, runtime_value) Hashtbl.t;
  functor_table : (string, identifier * module_type * expr) Hashtbl.t;
}
(** 解释器状态记录类型 *)

(** 创建新的解释器状态 *)
let create_state () =
  {
    macro_table = Hashtbl.create 16;
    module_table = Hashtbl.create 8;
    recursive_functions = Hashtbl.create 8;
    functor_table = Hashtbl.create 8;
  }

(** 全局解释器状态 *)
let global_state = create_state ()

(** 访问宏表 *)
let get_macro_table () = global_state.macro_table

(** 访问模块表 *)
let get_module_table () = global_state.module_table

(** 访问递归函数表 *)
let get_recursive_functions () = global_state.recursive_functions

(** 访问函子表 *)
let get_functor_table () = global_state.functor_table

(** 向宏表添加宏定义 *)
let add_macro name macro_def = Hashtbl.replace global_state.macro_table name macro_def

(** 从宏表查找宏定义 *)
let find_macro name = Hashtbl.find_opt global_state.macro_table name

(** 向模块表添加模块 *)
let add_module name bindings = Hashtbl.replace global_state.module_table name bindings

(** 从模块表查找模块 *)
let find_module name = Hashtbl.find_opt global_state.module_table name

(** 向递归函数表添加函数 *)
let add_recursive_function name func_val =
  Hashtbl.replace global_state.recursive_functions name func_val

(** 从递归函数表查找函数 *)
let find_recursive_function name = Hashtbl.find_opt global_state.recursive_functions name

(** 向函子表添加函子 *)
let add_functor name param_name module_type body =
  Hashtbl.replace global_state.functor_table name (param_name, module_type, body)

(** 从函子表查找函子 *)
let find_functor name = Hashtbl.find_opt global_state.functor_table name

(** 重置解释器状态 *)
let reset_state () =
  Hashtbl.clear global_state.macro_table;
  Hashtbl.clear global_state.module_table;
  Hashtbl.clear global_state.recursive_functions;
  Hashtbl.clear global_state.functor_table

(** 获取所有可用的变量名（包括环境变量和递归函数） *)
let get_available_vars env =
  let env_vars = List.map fst env in
  let recursive_vars = Hashtbl.fold (fun k _ acc -> k :: acc) global_state.recursive_functions [] in
  env_vars @ recursive_vars
