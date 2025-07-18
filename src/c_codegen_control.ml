(** 骆言C代码生成器控制流模块 - C Code Generator Control Flow Module *)

open Ast
open C_codegen_context
open Error_utils

(** 初始化模块日志器 *)
let log_info = Logger_utils.init_info_logger "CCodegenControl"

(** 生成函数调用表达式代码 *)
let gen_func_call_expr gen_expr_fn ctx func_expr args =
  let func_code = gen_expr_fn ctx func_expr in
  let arg_codes = List.map (gen_expr_fn ctx) args in
  let args_code = String.concat ", " arg_codes in
  let arg_count = List.length args in
  Printf.sprintf "luoyan_call(%s, %d, %s)" func_code arg_count args_code

(** 生成函数定义表达式代码 *)
let gen_func_def_expr gen_expr_fn ctx params body =
  let param_count = List.length params in
  let param_names = String.concat ", " (List.map (fun p -> "\"" ^ escape_identifier p ^ "\"") params) in
  let body_code = gen_expr_fn ctx body in
  Printf.sprintf "luoyan_function(%d, (char*[]){%s}, %s)" param_count param_names body_code

(** 生成条件表达式代码 *)
let gen_if_expr gen_expr_fn ctx cond_expr then_expr else_expr =
  let cond_var = gen_var_name ctx "cond" in
  let cond_code = gen_expr_fn ctx cond_expr in
  let then_code = gen_expr_fn ctx then_expr in
  let else_code = gen_expr_fn ctx else_expr in
  Printf.sprintf
    "({ luoyan_value_t* %s = %s; ((%s->type == LUOYAN_BOOL && %s->data.bool_val)) ? (%s) : (%s); })"
    cond_var cond_code cond_var cond_var then_code else_code

(** 生成let表达式代码 *)
let gen_let_expr gen_expr_fn ctx var_name value_expr body_expr =
  let value_code = gen_expr_fn ctx value_expr in
  let escaped_var = escape_identifier var_name in
  let body_code = gen_expr_fn ctx body_expr in
  Printf.sprintf "luoyan_let(\"%s\", %s, %s)" escaped_var value_code body_code

(** 生成控制流表达式代码 *)
let gen_control_flow gen_expr_fn _gen_pattern_check_fn ctx expr =
  match expr with
  | FunCallExpr (func_expr, args) -> gen_func_call_expr gen_expr_fn ctx func_expr args
  | FunExpr (params, body) -> gen_func_def_expr gen_expr_fn ctx params body
  | CondExpr (cond_expr, then_expr, else_expr) -> gen_if_expr gen_expr_fn ctx cond_expr then_expr else_expr
  | LetExpr (var_name, value_expr, body_expr) -> gen_let_expr gen_expr_fn ctx var_name value_expr body_expr
  | MatchExpr (expr, _patterns) -> 
      (* Simplified match implementation - full implementation would need pattern generation *)
      let expr_code = gen_expr_fn ctx expr in
      Printf.sprintf "luoyan_match(%s)" expr_code
  | _ -> fail_unsupported_expression_with_function "gen_control_flow" ControlFlow