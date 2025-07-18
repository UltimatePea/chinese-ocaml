(** 骆言语法分析器核心表达式解析模块 *)

open Ast
open Lexer
open Parser_utils

(** 解析否则返回表达式 *)
let parse_or_else_expression parse_or_fn state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    if token = OrElseKeyword then
      let state1 = advance_parser state in
      let right_expr, state2 = parse_or_fn state1 in
      let new_expr = OrElseExpr (left_expr, right_expr) in
      parse_tail new_expr state2
    else (left_expr, state)
  in
  let expr, state1 = parse_or_fn state in
  parse_tail expr state1

(** 解析逻辑或表达式 *)
let parse_or_expression parse_and_fn state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some Or ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_and_fn state1 in
        let new_expr = BinaryOpExpr (left_expr, Or, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_and_fn state in
  parse_tail expr state1

(** 解析逻辑与表达式 *)
let parse_and_expression parse_comparison_fn state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some And ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_comparison_fn state1 in
        let new_expr = BinaryOpExpr (left_expr, And, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_comparison_fn state in
  parse_tail expr state1

(** 解析比较表达式 *)
let parse_comparison_expression parse_arithmetic_fn state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some ((Eq | Neq | Lt | Le | Gt | Ge) as op) ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_arithmetic_fn state1 in
        let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_arithmetic_fn state in
  parse_tail expr state1