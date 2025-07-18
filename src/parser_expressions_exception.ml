(** 骆言语法分析器异常表达式解析模块 - Exception Expression Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils
open Parser_patterns

(** 解析try表达式 *)
let parse_try_expression parse_expr state =
  let state1 = expect_token state TryKeyword in
  let state1 = skip_newlines state1 in
  let try_expr, state2 = parse_expr state1 in
  let state2 = skip_newlines state2 in
  let state3 = expect_token state2 CatchKeyword in
  let state3 = skip_newlines state3 in

  (* 解析catch分支 *)
  let rec parse_catch_branches branches state =
    let state = skip_newlines state in
    let token, _ = current_token state in
    match token with
    | Pipe ->
        let state1 = advance_parser state in
        let pattern, state2 = parse_pattern state1 in
        (* Exception handling typically doesn't use guards, but we support it *)
        let guard, state3 =
          if is_token state2 WhenKeyword then
            let state2_1 = advance_parser state2 in
            let guard_expr, state2_2 = parse_expr state2_1 in
            (Some guard_expr, state2_2)
          else (None, state2)
        in
        let state4 = expect_token state3 Arrow in
        let state4 = skip_newlines state4 in
        let expr, state5 = parse_expr state4 in
        let state5 = skip_newlines state5 in
        let branch = { pattern; guard; expr } in
        parse_catch_branches (branch :: branches) state5
    | _ -> (List.rev branches, state)
  in

  let catch_branches, state4 = parse_catch_branches [] state3 in

  (* 检查是否有finally块 *)
  let state4 = skip_newlines state4 in
  let token, _ = current_token state4 in
  match token with
  | FinallyKeyword ->
      let state5 = advance_parser state4 in
      let state5 = skip_newlines state5 in
      let finally_expr, state6 = parse_expr state5 in
      (TryExpr (try_expr, catch_branches, Some finally_expr), state6)
  | _ -> (TryExpr (try_expr, catch_branches, None), state4)

(** 解析raise表达式 *)
let parse_raise_expression parse_expr state =
  let state1 = expect_token state RaiseKeyword in
  let expr, state2 = parse_expr state1 in
  (RaiseExpr expr, state2)

(** 解析ref表达式 *)
let parse_ref_expression parse_expr state =
  let state1 = expect_token state RefKeyword in
  let expr, state2 = parse_expr state1 in
  (RefExpr expr, state2)