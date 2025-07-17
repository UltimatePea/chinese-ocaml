(** 骆言控制流表达式求值模块接口 - Chinese Programming Language Control Flow Expression Evaluator Interface *)

open Ast
open Unified_errors
open Value_operations

(** 评估函数类型 *)
type eval_expr_func = (string * runtime_value) list -> expr -> runtime_value result

(** 函数调用表达式求值 *)
val eval_function_call : (string * runtime_value) list -> expr -> expr list -> eval_expr_func -> runtime_value result

(** 条件表达式求值 *)
val eval_conditional : (string * runtime_value) list -> expr -> expr -> expr -> eval_expr_func -> runtime_value result

(** 函数表达式求值 *)
val eval_function_expr : (string * runtime_value) list -> string list -> expr -> runtime_value result

(** Let表达式求值 *)
val eval_let_expr : (string * runtime_value) list -> string -> expr -> expr -> eval_expr_func -> runtime_value result

(** 模式匹配表达式求值 *)
val eval_match_expr : (string * runtime_value) list -> expr -> (pattern * expr) list -> eval_expr_func -> runtime_value result

(** 语义Let表达式求值 *)
val eval_semantic_let_expr : (string * runtime_value) list -> string -> string -> expr -> expr -> eval_expr_func -> runtime_value result

(** 控制流表达式求值 - 函数调用、条件、匹配 *)
val eval_control_flow_expr : (string * runtime_value) list -> expr -> eval_expr_func -> runtime_value result