(** 骆言C代码生成器控制流模块 - C Code Generator Control Flow Module *)

open Ast
open C_codegen_context
open Error_utils

(** 安全的格式化字符串生成函数 *)
let safe_sprintf fmt =
  try Printf.sprintf fmt
  with
  | Invalid_argument msg -> failwith (Printf.sprintf "格式化字符串错误: %s" msg)
  | Failure msg -> failwith (Printf.sprintf "字符串生成失败: %s" msg)

(** 生成函数调用表达式代码 *)
let gen_func_call_expr gen_expr_fn ctx func_expr args =
  try
    let func_code = gen_expr_fn ctx func_expr in
    let arg_codes = List.map (gen_expr_fn ctx) args in
    let args_code = String.concat ", " arg_codes in
    let arg_count = List.length args in
    safe_sprintf "luoyan_call(%s, %d, %s)" func_code arg_count args_code
  with
  | Failure msg -> failwith (Printf.sprintf "gen_func_call_expr: %s" msg)
  | ex -> failwith (Printf.sprintf "gen_func_call_expr: 未预期错误 - %s" (Printexc.to_string ex))

(** 生成函数定义表达式代码 *)
let gen_func_def_expr gen_expr_fn ctx params body =
  try
    let func_name = gen_var_name ctx "func" in
    let _body_code = gen_expr_fn ctx body in
    match params with
    | [] -> "luoyan_unit()"
    | first_param :: _ ->
        (* 验证参数名称有效性 *)
        if String.length first_param = 0 then
          failwith "函数参数名不能为空";
        safe_sprintf "luoyan_function_create(%s_impl_%s, env, \"%s\")" func_name first_param func_name
  with
  | Failure msg -> failwith (Printf.sprintf "gen_func_def_expr: %s" msg)
  | ex -> failwith (Printf.sprintf "gen_func_def_expr: 未预期错误 - %s" (Printexc.to_string ex))

(** 生成条件表达式代码 *)
let gen_if_expr gen_expr_fn ctx cond_expr then_expr else_expr =
  try
    let cond_var = gen_var_name ctx "cond" in
    let cond_code = gen_expr_fn ctx cond_expr in
    let then_code = gen_expr_fn ctx then_expr in
    let else_code = gen_expr_fn ctx else_expr in
    safe_sprintf
      "({ luoyan_value_t* %s = %s; ((%s->type == LUOYAN_BOOL && %s->data.bool_val)) ? (%s) : (%s); })"
      cond_var cond_code cond_var cond_var then_code else_code
  with
  | Failure msg -> failwith (Printf.sprintf "gen_if_expr: %s" msg)
  | ex -> failwith (Printf.sprintf "gen_if_expr: 未预期错误 - %s" (Printexc.to_string ex))

(** 生成let表达式代码 *)
let gen_let_expr gen_expr_fn ctx var_name value_expr body_expr =
  try
    (* 验证变量名有效性 *)
    if String.length var_name = 0 then
      failwith "let表达式的变量名不能为空";
    let value_code = gen_expr_fn ctx value_expr in
    let escaped_var = escape_identifier var_name in
    let body_code = gen_expr_fn ctx body_expr in
    safe_sprintf "luoyan_let(\"%s\", %s, %s)" escaped_var value_code body_code
  with
  | Failure msg -> failwith (Printf.sprintf "gen_let_expr: %s" msg)
  | ex -> failwith (Printf.sprintf "gen_let_expr: 未预期错误 - %s" (Printexc.to_string ex))

(** 生成控制流表达式代码 *)
let gen_control_flow gen_expr_fn _gen_pattern_check_fn ctx expr =
  try
    match expr with
    | FunCallExpr (func_expr, args) -> gen_func_call_expr gen_expr_fn ctx func_expr args
    | FunExpr (params, body) -> gen_func_def_expr gen_expr_fn ctx params body
    | CondExpr (cond_expr, then_expr, else_expr) ->
        gen_if_expr gen_expr_fn ctx cond_expr then_expr else_expr
    | LetExpr (var_name, value_expr, body_expr) ->
        gen_let_expr gen_expr_fn ctx var_name value_expr body_expr
    | MatchExpr (expr, _patterns) ->
        (* Simplified match implementation - full implementation would need pattern generation *)
        (try
          let expr_var = gen_var_name ctx "match_expr" in
          let expr_code = gen_expr_fn ctx expr in
          safe_sprintf "({ luoyan_value_t* %s = %s; luoyan_match(%s); })" expr_var expr_code expr_var
        with
        | Failure msg -> failwith (Printf.sprintf "MatchExpr代码生成失败: %s" msg))
    | _ -> fail_unsupported_expression_with_function "gen_control_flow" ControlFlow
  with
  | Failure msg -> failwith (Printf.sprintf "gen_control_flow: %s" msg)
  | ex -> failwith (Printf.sprintf "gen_control_flow: 未预期错误 - %s" (Printexc.to_string ex))
