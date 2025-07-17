(** 骆言控制流表达式求值模块 - Chinese Programming Language Control Flow Expression Evaluator *)

open Ast
open Value_operations
open Pattern_matcher
open Function_caller

(** 评估函数类型 *)
type eval_expr_func = runtime_env -> expr -> runtime_value

(** 控制流表达式求值 - 函数调用、条件、匹配 *)
let eval_control_flow_expr env eval_expr_func = function
  | FunCallExpr (func_expr, arg_list) ->
      let func_val = eval_expr_func env func_expr in
      let arg_vals = List.map (eval_expr_func env) arg_list in
      call_function func_val arg_vals eval_expr_func
  | CondExpr (cond, then_branch, else_branch) ->
      let cond_val = eval_expr_func env cond in
      if value_to_bool cond_val then eval_expr_func env then_branch 
      else eval_expr_func env else_branch
  | FunExpr (param_list, body) -> 
      FunctionValue (param_list, body, env)
  | LetExpr (var_name, val_expr, body_expr) ->
      let value = eval_expr_func env val_expr in
      let new_env = bind_var env var_name value in
      eval_expr_func new_env body_expr
  | MatchExpr (expr, branch_list) ->
      let value = eval_expr_func env expr in
      execute_match env value branch_list eval_expr_func
  | SemanticLetExpr (var_name, _semantic_label, val_expr, body_expr) ->
      (* 语义标签当前只是元数据，按普通let表达式处理 *)
      let value = eval_expr_func env val_expr in
      let new_env = bind_var env var_name value in
      eval_expr_func new_env body_expr
  | _ -> 
      raise (RuntimeError "不支持的控制流表达式类型")