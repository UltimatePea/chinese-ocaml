(** 骆言C代码生成器控制流模块 - C Code Generator Control Flow Module 重构说明：统一错误处理模式，消除重复代码，提升代码质量 *)

open Ast
open C_codegen_context
open Error_utils

(** {1 统一错误处理模块} *)

(** 统一错误处理包装器 - 消除重复的try-catch模式 *)
let with_error_handling ~func_name f =
  try f () with
  | Failure msg -> invalid_arg (Printf.sprintf "%s: %s" func_name msg)
  | ex -> invalid_arg (Printf.sprintf "%s: 未预期错误 - %s" func_name (Printexc.to_string ex))

(** 安全的格式化字符串生成函数 - 使用统一错误处理 *)
let safe_sprintf fmt = with_error_handling ~func_name:"safe_sprintf" (fun () -> Printf.sprintf fmt)

(** 生成函数调用表达式代码 - 使用统一错误处理 *)
let gen_func_call_expr gen_expr_fn ctx func_expr args =
  with_error_handling ~func_name:"gen_func_call_expr" (fun () ->
      let func_code = gen_expr_fn ctx func_expr in
      let arg_codes = List.map (gen_expr_fn ctx) args in
      let args_code = String.concat ", " arg_codes in
      let arg_count = List.length args in
      safe_sprintf "luoyan_call(%s, %d, %s)" func_code arg_count args_code)

(** 生成函数定义表达式代码 - 使用统一错误处理 *)
let gen_func_def_expr gen_expr_fn ctx params body =
  with_error_handling ~func_name:"gen_func_def_expr" (fun () ->
      let func_name = gen_var_name ctx "func" in
      let _body_code = gen_expr_fn ctx body in
      match params with
      | [] -> "luoyan_unit()"
      | first_param :: _ ->
          (* 验证参数名称有效性 *)
          if String.length first_param = 0 then invalid_arg "gen_func_def_expr: 函数参数名不能为空";
          safe_sprintf "luoyan_function_create(%s_impl_%s, env, \"%s\")" func_name first_param
            func_name)

(** 生成条件表达式代码 - 使用统一错误处理 *)
let gen_if_expr gen_expr_fn ctx cond_expr then_expr else_expr =
  with_error_handling ~func_name:"gen_if_expr" (fun () ->
      let cond_var = gen_var_name ctx "cond" in
      let cond_code = gen_expr_fn ctx cond_expr in
      let then_code = gen_expr_fn ctx then_expr in
      let else_code = gen_expr_fn ctx else_expr in
      safe_sprintf
        "({ luoyan_value_t* %s = %s; ((%s->type == LUOYAN_BOOL && %s->data.bool_val)) ? (%s) : \
         (%s); })"
        cond_var cond_code cond_var cond_var then_code else_code)

(** 生成let表达式代码 - 使用统一错误处理 *)
let gen_let_expr gen_expr_fn ctx var_name value_expr body_expr =
  with_error_handling ~func_name:"gen_let_expr" (fun () ->
      (* 验证变量名有效性 *)
      if String.length var_name = 0 then invalid_arg "gen_let_expr: let表达式的变量名不能为空";
      let value_code = gen_expr_fn ctx value_expr in
      let escaped_var = escape_identifier var_name in
      let body_code = gen_expr_fn ctx body_expr in
      safe_sprintf "luoyan_let(\"%s\", %s, %s)" escaped_var value_code body_code)

(** 生成控制流表达式代码 - 使用统一错误处理 *)
let gen_control_flow gen_expr_fn _gen_pattern_check_fn ctx expr =
  with_error_handling ~func_name:"gen_control_flow" (fun () ->
      match expr with
      | FunCallExpr (func_expr, args) -> gen_func_call_expr gen_expr_fn ctx func_expr args
      | FunExpr (params, body) -> gen_func_def_expr gen_expr_fn ctx params body
      | CondExpr (cond_expr, then_expr, else_expr) ->
          gen_if_expr gen_expr_fn ctx cond_expr then_expr else_expr
      | LetExpr (var_name, value_expr, body_expr) ->
          gen_let_expr gen_expr_fn ctx var_name value_expr body_expr
      | MatchExpr (expr, patterns) ->
          (* 完整的匹配实现 - 处理模式匹配分支 *)
          with_error_handling ~func_name:"gen_control_flow.MatchExpr" (fun () ->
              let expr_var = gen_var_name ctx "match_expr" in
              let expr_code = gen_expr_fn ctx expr in
              let gen_branch branch =
                let pattern_check = _gen_pattern_check_fn ctx expr_var branch.pattern in
                let branch_code = gen_expr_fn ctx branch.expr in
                safe_sprintf "if (%s) { return %s; }" pattern_check branch_code
              in
              let branch_codes = List.map gen_branch patterns in
              let branches_code = String.concat " " branch_codes in
              safe_sprintf "({ luoyan_value_t* %s = %s; %s return luoyan_unit(); })" expr_var
                expr_code branches_code)
      | _ -> fail_unsupported_expression_with_function "gen_control_flow" ControlFlow)
