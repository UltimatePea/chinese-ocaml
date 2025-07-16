(** 骆言语法分析器赋值表达式解析模块 - Assignment Expression Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils

(** 解析赋值表达式 *)
let rec parse_assignment_expression parse_expr state =
  let left_expr, state1 = parse_or_else_expression parse_expr state in
  let token, _ = current_token state1 in
  if token = RefAssign then
    let state2 = advance_parser state1 in
    let right_expr, state3 = parse_expr state2 in
    (AssignExpr (left_expr, right_expr), state3)
  else (left_expr, state1)

(** 解析否则返回表达式 *)
and parse_or_else_expression parse_expr state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    if token = OrElseKeyword then
      let state1 = advance_parser state in
      let right_expr, state2 = parse_or_expression parse_expr state1 in
      let new_expr = OrElseExpr (left_expr, right_expr) in
      parse_tail new_expr state2
    else (left_expr, state)
  in
  let expr, state1 = parse_or_expression parse_expr state in
  parse_tail expr state1

(** 解析逻辑或表达式 *)
and parse_or_expression parse_expr state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some Or ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_and_expression parse_expr state1 in
        let new_expr = BinaryOpExpr (left_expr, Or, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_and_expression parse_expr state in
  parse_tail expr state1

(** 解析逻辑与表达式 *)
and parse_and_expression parse_expr state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some And ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_comparison_expression parse_expr state1 in
        let new_expr = BinaryOpExpr (left_expr, And, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_comparison_expression parse_expr state in
  parse_tail expr state1

(** 解析比较表达式 *)
and parse_comparison_expression parse_expr state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some ((Eq | Neq | Lt | Le | Gt | Ge) as op) ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_arithmetic_expression parse_expr state1 in
        let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_arithmetic_expression parse_expr state in
  parse_tail expr state1

(** 解析算术表达式 *)
and parse_arithmetic_expression parse_expr state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some ((Add | Sub) as op) ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_multiplicative_expression parse_expr state1 in
        let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_multiplicative_expression parse_expr state in
  parse_tail expr state1

(** 解析乘除表达式 *)
and parse_multiplicative_expression parse_expr state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some ((Mul | Div | Mod) as op) ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_unary_expression parse_expr state1 in
        let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_unary_expression parse_expr state in
  parse_tail expr state1

(** 解析一元表达式 *)
and parse_unary_expression parse_expr state =
  let token, _pos = current_token state in
  match token with
  | Minus ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expression parse_expr state1 in
      (UnaryOpExpr (Neg, expr), state2)
  | NotKeyword ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expression parse_expr state1 in
      (UnaryOpExpr (Not, expr), state2)
  | Bang ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expression parse_expr state1 in
      (DerefExpr expr, state2)
  | _ -> 
      (* 对于复杂表达式，委托给主解析器的primary expression处理 *)
      (* 这里我们不能直接调用parse_expr，因为那会导致循环 *)
      (* 我们需要让模块化的设计更简单 *)
      let token, pos = current_token state in
      raise (SyntaxError ("Assignment模块无法处理的表达式，需要主解析器处理: " ^ show_token token, pos))

(** 解析基础表达式 - 简化版本 *)
and parse_primary_expression parse_expr state =
  let token, _pos = current_token state in
  match token with
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ ->
      let literal, state1 = parse_literal state in
      (LitExpr literal, state1)
  | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      (VarExpr name, state1)
  | LeftParen | ChineseLeftParen ->
      let state1 = advance_parser state in
      let expr, state2 = parse_expr state1 in
      let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
      (expr, state3)
  | OneKeyword ->
      (* 将"一"关键字转换为数字字面量1 *)
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  | _ ->
      (* 对于复杂表达式，抛出错误让上层重新路由到主解析器 *)
      let token, pos = current_token state in
      raise (SyntaxError ("Assignment模块的primary expression无法处理: " ^ show_token token, pos))