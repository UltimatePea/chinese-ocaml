(** 骆言语法分析器 - Chinese Programming Language Parser *)

open Ast
open Lexer

(** 语法错误 *)
exception SyntaxError of string * position

(** 解析器状态 *)
type parser_state = {
  token_list: positioned_token list;
  current_pos: int;
}

(** 创建解析状态 *)
let create_parser_state token_list = {
  token_list;
  current_pos = 0;
}

(** 获取当前词元 *)
let current_token state =
  if state.current_pos >= List.length state.token_list then
    (EOF, { line = 0; column = 0; filename = "" })
  else
    List.nth state.token_list state.current_pos

(** 向前移动 *)
let advance_parser state =
  if state.current_pos >= List.length state.token_list then state
  else { state with current_pos = state.current_pos + 1 }

(** 期望特定词元 *)
let expect_token state expected_token =
  let (token, pos) = current_token state in
  if token = expected_token then
    advance_parser state
  else
    raise (SyntaxError ("期望 " ^ show_token expected_token ^ "，但遇到 " ^ show_token token, pos))

(** 检查是否为特定词元 *)
let is_token state target_token =
  let (token, _) = current_token state in
  token = target_token

(** 解析标识符 *)
let parse_identifier state =
  let (token, pos) = current_token state in
  match token with
  | IdentifierToken name -> (name, advance_parser state)
  | _ -> raise (SyntaxError ("期望标识符，但遇到 " ^ show_token token, pos))

(** 解析字面量 *)
let parse_literal state =
  let (token, pos) = current_token state in
  match token with
  | IntToken n -> (IntLit n, advance_parser state)
  | FloatToken f -> (FloatLit f, advance_parser state)
  | StringToken s -> (StringLit s, advance_parser state)
  | BoolToken b -> (BoolLit b, advance_parser state)
  | _ -> raise (SyntaxError ("期望字面量，但遇到 " ^ show_token token, pos))

(** 解析二元运算符 *)
let token_to_binary_op token =
  match token with
  | Plus -> Some Add
  | Minus -> Some Sub
  | Star -> Some Mul
  | Multiply -> Some Mul
  | Slash -> Some Div
  | Divide -> Some Div
  | Modulo -> Some Mod
  | Equal -> Some Eq
  | NotEqual -> Some Neq
  | Less -> Some Lt
  | LessEqual -> Some Le
  | Greater -> Some Gt
  | GreaterEqual -> Some Ge
  | AndKeyword -> Some And
  | OrKeyword -> Some Or
  | _ -> None

(** 运算符优先级 *)
let operator_precedence op =
  match op with
  | Or -> 1
  | And -> 2
  | Eq | Neq | Lt | Le | Gt | Ge -> 3
  | Add | Sub -> 4
  | Mul | Div -> 5

(** 前向声明 *)
let rec parse_expression state = parse_or_expression state

(** 解析逻辑或表达式 *)
and parse_or_expression state =
  let rec parse_tail left_expr state =
    let (token, _) = current_token state in
    match token_to_binary_op token with
    | Some Or ->
      let state1 = advance_parser state in
      let (right_expr, state2) = parse_and_expression state1 in
             let new_expr = BinaryOpExpr (left_expr, Or, right_expr) in
      parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let (expr, state1) = parse_and_expression state in
  parse_tail expr state1

(** 解析逻辑与表达式 *)
and parse_and_expression state =
  let rec parse_tail left_expr state =
    let (token, _) = current_token state in
    match token_to_binary_op token with
    | Some And ->
      let state1 = advance_parser state in
      let (right_expr, state2) = parse_comparison_expression state1 in
             let new_expr = BinaryOpExpr (left_expr, And, right_expr) in
      parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let (expr, state1) = parse_comparison_expression state in
  parse_tail expr state1

(** 解析比较表达式 *)
and parse_comparison_expression state =
  let rec parse_tail left_expr state =
    let (token, _) = current_token state in
    match token_to_binary_op token with
                   | Some (Eq | Neq | Lt | Le | Gt | Ge as op) ->
       let state1 = advance_parser state in
       let (right_expr, state2) = parse_arithmetic_expression state1 in
       let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
       parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let (expr, state1) = parse_arithmetic_expression state in
  parse_tail expr state1

(** 解析算术表达式 *)
and parse_arithmetic_expression state =
  let rec parse_tail left_expr state =
    let (token, _) = current_token state in
    match token_to_binary_op token with
         | Some (Add | Sub as op) ->
       let state1 = advance_parser state in
       let (right_expr, state2) = parse_multiplicative_expression state1 in
       let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
       parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let (expr, state1) = parse_multiplicative_expression state in
  parse_tail expr state1

(** 解析乘除表达式 *)
and parse_multiplicative_expression state =
  let rec parse_tail left_expr state =
    let (token, _) = current_token state in
    match token_to_binary_op token with
         | Some (Mul | Div as op) ->
       let state1 = advance_parser state in
       let (right_expr, state2) = parse_unary_expression state1 in
       let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
       parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  let (expr, state1) = parse_unary_expression state in
  parse_tail expr state1

(** 解析一元表达式 *)
and parse_unary_expression state =
  let (token, _pos) = current_token state in
  match token with
  | Minus ->
    let state1 = advance_parser state in
    let (expr, state2) = parse_unary_expression state1 in
    (UnaryOpExpr (Neg, expr), state2)
  | NotKeyword ->
    let state1 = advance_parser state in
    let (expr, state2) = parse_unary_expression state1 in
    (UnaryOpExpr (Not, expr), state2)
  | _ -> parse_primary_expression state

(** 解析基础表达式 *)
and parse_primary_expression state =
  let (token, pos) = current_token state in
  match token with
  | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ ->
    let (literal, state1) = parse_literal state in
    (LitExpr literal, state1)
  | IdentifierToken name ->
    let state1 = advance_parser state in
    parse_function_call_or_variable name state1
  | LeftParen ->
    let state1 = advance_parser state in
    let (expr, state2) = parse_expression state1 in
    let state3 = expect_token state2 RightParen in
    (expr, state3)
  | IfKeyword -> parse_conditional_expression state
  | MatchKeyword -> parse_match_expression state
  | FunKeyword -> parse_function_expression state
  | LetKeyword -> parse_let_expression state
  | _ -> raise (SyntaxError ("意外的词元: " ^ show_token token, pos))

(** 解析函数调用或变量 *)
and parse_function_call_or_variable name state =
  let rec collect_args arg_list state =
    let (token, _) = current_token state in
    match token with
    | LeftParen | IdentifierToken _ | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ ->
      let (arg, state1) = parse_primary_expression state in
      collect_args (arg :: arg_list) state1
    | _ -> (List.rev arg_list, state)
  in
  let (arg_list, state1) = collect_args [] state in
  if arg_list = [] then
    (VarExpr name, state1)
  else
    (FunCallExpr (VarExpr name, arg_list), state1)

(** 解析条件表达式 *)
and parse_conditional_expression state =
  let state1 = expect_token state IfKeyword in
  let (cond, state2) = parse_expression state1 in
  let state3 = expect_token state2 ThenKeyword in
  let (then_branch, state4) = parse_expression state3 in
  let state5 = expect_token state4 ElseKeyword in
  let (else_branch, state6) = parse_expression state5 in
  (CondExpr (cond, then_branch, else_branch), state6)

(** 解析匹配表达式 *)
and parse_match_expression state =
  let state1 = expect_token state MatchKeyword in
  let (expr, state2) = parse_expression state1 in
  let state3 = expect_token state2 WithKeyword in
  let rec parse_branch_list branch_list state =
    if is_token state Pipe then
      let state1 = advance_parser state in
      let (pattern, state2) = parse_pattern state1 in
      let state3 = expect_token state2 Arrow in
      let (expr, state4) = parse_expression state3 in
      parse_branch_list ((pattern, expr) :: branch_list) state4
    else
      (List.rev branch_list, state)
  in
  let (branch_list, state4) = parse_branch_list [] state3 in
  (MatchExpr (expr, branch_list), state4)

(** 解析模式 *)
and parse_pattern state =
  let (token, pos) = current_token state in
  match token with
  | Underscore -> (WildcardPattern, advance_parser state)
  | IdentifierToken name -> (VarPattern name, advance_parser state)
  | IntToken n -> (LitPattern (IntLit n), advance_parser state)
  | FloatToken f -> (LitPattern (FloatLit f), advance_parser state)
  | StringToken s -> (LitPattern (StringLit s), advance_parser state)
  | BoolToken b -> (LitPattern (BoolLit b), advance_parser state)
  | _ -> raise (SyntaxError ("意外的模式: " ^ show_token token, pos))

(** 解析函数表达式 *)
and parse_function_expression state =
  let state1 = expect_token state FunKeyword in
  let rec parse_param_list param_list state =
    let (token, _) = current_token state in
    match token with
    | IdentifierToken name ->
      let state1 = advance_parser state in
      parse_param_list (name :: param_list) state1
    | Arrow ->
      let state1 = advance_parser state in
      (List.rev param_list, state1)
    | _ -> raise (SyntaxError ("期望参数或箭头", snd (current_token state)))
  in
  let (param_list, state2) = parse_param_list [] state1 in
  let (expr, state3) = parse_expression state2 in
  (FunExpr (param_list, expr), state3)

(** 解析让表达式 *)
and parse_let_expression state =
  let state1 = expect_token state LetKeyword in
  let (name, state2) = parse_identifier state1 in
  let state3 = expect_token state2 Assign in
  let (val_expr, state4) = parse_expression state3 in
  let state5 = expect_token state4 InKeyword in
  let (body_expr, state6) = parse_expression state5 in
  (LetExpr (name, val_expr, body_expr), state6)

(** 解析语句 *)
let parse_statement state =
  let (token, _pos) = current_token state in
  match token with
  | LetKeyword ->
    let state1 = advance_parser state in
    let (name, state2) = parse_identifier state1 in
    let state3 = expect_token state2 Assign in
    let (expr, state4) = parse_expression state3 in
    (LetStmt (name, expr), state4)
  | RecKeyword ->
    let state1 = advance_parser state in
    let state2 = expect_token state1 LetKeyword in
    let (name, state3) = parse_identifier state2 in
    let state4 = expect_token state3 Assign in
    let (expr, state5) = parse_expression state4 in
    (RecLetStmt (name, expr), state5)
  | _ ->
    let (expr, state1) = parse_expression state in
    (ExprStmt expr, state1)

(** 解析程序 *)
let parse_program token_list =
  let rec parse_statement_list stmt_list state =
    let (token, _) = current_token state in
    if token = EOF then
      List.rev stmt_list
    else
      let (stmt, state1) = parse_statement state in
      parse_statement_list (stmt :: stmt_list) state1
  in
  let initial_state = create_parser_state token_list in
  parse_statement_list [] initial_state