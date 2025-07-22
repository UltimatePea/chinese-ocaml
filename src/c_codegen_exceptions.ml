(** 骆言C代码生成器异常处理模块 - C Code Generator Exception Handling Module *)

open Ast
open Error_utils

(** 生成try-catch表达式代码 *)
let gen_try_expr gen_expr_fn ctx try_expr catch_branches finally_expr_opt =
  let try_code = gen_expr_fn ctx try_expr in
  let catch_code =
    match catch_branches with
    | [] -> "luoyan_unit()"
    | branch :: _ ->
        (* 处理第一个catch分支 *)
        let branch_code = gen_expr_fn ctx branch.expr in
        Printf.sprintf "luoyan_catch(%s)" branch_code
  in
  let finally_code =
    match finally_expr_opt with None -> "" | Some finally_expr -> gen_expr_fn ctx finally_expr
  in
  Printf.sprintf "luoyan_try_catch(%s, %s, %s)" try_code catch_code finally_code

(** 生成raise表达式代码 *)
let gen_raise_expr gen_expr_fn ctx expr =
  let expr_code = gen_expr_fn ctx expr in
  Printf.sprintf "luoyan_raise(%s)" expr_code

(** 生成异常处理表达式代码 *)
let gen_exception_handling gen_expr_fn ctx expr =
  match expr with
  | TryExpr (try_expr, catch_branches, finally_expr_opt) ->
      gen_try_expr gen_expr_fn ctx try_expr catch_branches finally_expr_opt
  | RaiseExpr expr -> gen_raise_expr gen_expr_fn ctx expr
  | _ -> fail_unsupported_expression_with_function "gen_exception_handling" ExceptionHandling

(** 生成高级控制流表达式代码 *)
let gen_advanced_control_flow gen_expr_fn ctx expr =
  match expr with
  | CombineExpr exprs ->
      let expr_codes = List.map (gen_expr_fn ctx) exprs in
      Printf.sprintf "luoyan_combine(%s)" (String.concat ", " expr_codes)
  | _ -> fail_unsupported_expression_with_function "gen_advanced_control_flow" AdvancedControlFlow
