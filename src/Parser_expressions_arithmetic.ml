(** 骆言语法分析器算术表达式解析模块 - Arithmetic Expression Parser *)

open Ast
open Lexer
open Parser_utils

(** 解析算术表达式 *)
let rec parse_arithmetic_expression parse_expr state =
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
  | _ -> parse_primary_expression parse_expr state

(** 解析基础表达式 - 扩展版本支持函数调用 *)
and parse_primary_expression parse_expr state =
  let token, pos = current_token state in
  match token with
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ ->
      let literal, state1 = parse_literal state in
      (LitExpr literal, state1)
  | QuotedIdentifierToken name ->
      (* 检查是否是函数调用 *)
      let state1 = advance_parser state in
      (* 普通函数调用检查 *)
      let rec collect_args arg_list state =
        let token, _ = current_token state in
        match token with
        | LeftParen | ChineseLeftParen | QuotedIdentifierToken _ | IntToken _ | ChineseNumberToken _
        | FloatToken _ | StringToken _ | BoolToken _ | OneKeyword ->
            let arg, state1 = parse_expr state in
            collect_args (arg :: arg_list) state1
        | _ -> (List.rev arg_list, state)
      in
      let arg_list, state2 = collect_args [] state1 in
      let expr = if arg_list = [] then VarExpr name else FunCallExpr (VarExpr name, arg_list) in
      (expr, state2)
  | LeftParen | ChineseLeftParen ->
      let state1 = advance_parser state in
      let expr, state2 = parse_expr state1 in
      let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
      (expr, state3)
  | OneKeyword ->
      (* 将"一"关键字转换为数字字面量1 *)
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  | _ -> raise (SyntaxError ("意外的词元: " ^ show_token token, pos))

(** 解析加法表达式 *)
let parse_addition_expression parse_expr state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some Add ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_multiplicative_expression parse_expr state1 in
        let new_expr = BinaryOpExpr (left_expr, Add, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_multiplicative_expression parse_expr state in
  parse_tail expr state1

(** 解析减法表达式 *)
let parse_subtraction_expression parse_expr state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some Sub ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_multiplicative_expression parse_expr state1 in
        let new_expr = BinaryOpExpr (left_expr, Sub, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_multiplicative_expression parse_expr state in
  parse_tail expr state1

(** 解析乘法表达式 *)
let parse_multiplication_expression parse_expr state =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some Mul ->
        let state1 = advance_parser state in
        let right_expr, state2 = parse_unary_expression parse_expr state1 in
        let new_expr = BinaryOpExpr (left_expr, Mul, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let expr, state1 = parse_unary_expression parse_expr state in
  parse_tail expr state1
