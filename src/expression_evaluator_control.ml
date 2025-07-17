(** 骆言控制流表达式求值模块 - Chinese Programming Language Control Flow Expression Evaluator *)

open Ast
open Value_operations
open Unified_errors
open Interpreter_state
open Pattern_matcher
open Function_caller

(** 函数调用表达式求值 *)
let eval_function_call env func_expr arg_list eval_expr_func =
  to_result (fun () ->
    let func_val = match eval_expr_func env func_expr with
      | Result.Ok v -> v
      | Result.Error e -> raise (error_to_exception e)
    in
    let arg_vals = List.map (fun arg ->
      match eval_expr_func env arg with
      | Result.Ok v -> v
      | Result.Error e -> raise (error_to_exception e)
    ) arg_list in
    call_function func_val arg_vals (fun env expr ->
      match eval_expr_func env expr with
      | Result.Ok v -> v
      | Result.Error e -> raise (error_to_exception e)
    )
  )

(** 条件表达式求值 *)
let eval_conditional env cond then_branch else_branch eval_expr_func =
  to_result (fun () ->
    let cond_val = match eval_expr_func env cond with
      | Result.Ok v -> v
      | Result.Error e -> raise (error_to_exception e)
    in
    if value_to_bool cond_val then
      match eval_expr_func env then_branch with
      | Result.Ok v -> v
      | Result.Error e -> raise (error_to_exception e)
    else
      match eval_expr_func env else_branch with
      | Result.Ok v -> v
      | Result.Error e -> raise (error_to_exception e)
  )

(** 函数表达式求值 *)
let eval_function_expr env param_list body =
  Result.Ok (FunctionValue (param_list, body, env))

(** Let表达式求值 *)
let eval_let_expr env var_name val_expr body_expr eval_expr_func =
  to_result (fun () ->
    let value = match eval_expr_func env val_expr with
      | Result.Ok v -> v
      | Result.Error e -> raise (error_to_exception e)
    in
    let new_env = bind_var env var_name value in
    match eval_expr_func new_env body_expr with
    | Result.Ok v -> v
    | Result.Error e -> raise (error_to_exception e)
  )

(** 模式匹配表达式求值 *)
let eval_match_expr env expr branch_list eval_expr_func =
  to_result (fun () ->
    let value = match eval_expr_func env expr with
      | Result.Ok v -> v
      | Result.Error e -> raise (error_to_exception e)
    in
    execute_match env value branch_list (fun env expr ->
      match eval_expr_func env expr with
      | Result.Ok v -> v
      | Result.Error e -> raise (error_to_exception e)
    )
  )

(** 语义Let表达式求值 *)
let eval_semantic_let_expr env var_name _semantic_label val_expr body_expr eval_expr_func =
  (* 语义标签当前只是元数据，按普通let表达式处理 *)
  eval_let_expr env var_name val_expr body_expr eval_expr_func

(** 控制流表达式求值 - 函数调用、条件、匹配 *)
let eval_control_flow_expr env expr eval_expr_func =
  match expr with
  | FunCallExpr (func_expr, arg_list) ->
      eval_function_call env func_expr arg_list eval_expr_func
  | CondExpr (cond, then_branch, else_branch) ->
      eval_conditional env cond then_branch else_branch eval_expr_func
  | FunExpr (param_list, body) -> 
      eval_function_expr env param_list body
  | LetExpr (var_name, val_expr, body_expr) ->
      eval_let_expr env var_name val_expr body_expr eval_expr_func
  | MatchExpr (expr, branch_list) ->
      eval_match_expr env expr branch_list eval_expr_func
  | SemanticLetExpr (var_name, semantic_label, val_expr, body_expr) ->
      eval_semantic_let_expr env var_name semantic_label val_expr body_expr eval_expr_func
  | _ -> 
      make_runtime_error "不支持的控制流表达式类型" None