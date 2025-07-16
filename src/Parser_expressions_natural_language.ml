(** 骆言语法分析器自然语言表达式解析模块 - Natural Language Expression Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils

(** 解析自然语言算术延续表达式 *)
let parse_natural_arithmetic_continuation expr _param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | OfParticle ->
      (* 「减一」之「阶乘」 *)
      let state1 = advance_parser state in
      let func_name, state2 = parse_identifier state1 in
      (FunCallExpr (VarExpr func_name, [ expr ]), state2)
  | _ -> (expr, state)

(** 自然语言函数定义解析 *)
let rec parse_natural_function_definition parse_expr state =
  let state1 = expect_token state DefineKeyword in
  let function_name, state2 = parse_identifier state1 in
  let state3 = expect_token state2 AcceptKeyword in
  let param_name, state4 = parse_identifier state3 in
  let state5 = Parser_utils.expect_token_punctuation state4 Parser_utils.is_colon "colon" in
  let state5_clean = skip_newlines state5 in
  let body_expr, state6 = parse_natural_function_body parse_expr param_name state5_clean in
  let fun_expr = FunExpr ([ param_name ], body_expr) in
  (LetExpr (function_name, fun_expr, VarExpr function_name), state6)

(** 自然语言函数体解析 *)
and parse_natural_function_body parse_expr param_name state =
  let token, _ = current_token state in
  match token with
  | WhenKeyword -> parse_natural_conditional parse_expr param_name state
  | ElseReturnKeyword ->
      let state1 = advance_parser state in
      parse_natural_expression parse_expr param_name state1
  | InputKeyword -> parse_natural_expression parse_expr param_name state
  | _ -> parse_natural_expression parse_expr param_name state

(** 自然语言条件表达式解析 *)
and parse_natural_conditional parse_expr param_name state =
  let state1 = expect_token state WhenKeyword in
  let param_ref, state2 = parse_identifier state1 in
  let token, _ = current_token state2 in
  let comparison_op, state3 =
    match token with
    | IsKeyword -> (Eq, advance_parser state2)
    | AsForKeyword -> (Eq, advance_parser state2)
    | QuotedIdentifierToken "为" -> (Eq, advance_parser state2)
    | EqualToKeyword -> (Eq, advance_parser state2)
    | LessThanEqualToKeyword -> (Le, advance_parser state2)
    | _ -> raise (SyntaxError ("期望条件关系词，如「为」或「等于」", snd (current_token state2)))
  in
  let condition_value, state4 = parse_expr state3 in
  let state5 = expect_token state4 ReturnWhenKeyword in
  let return_value, state6 = parse_natural_expression parse_expr param_name state5 in
  let state6_clean = skip_newlines state6 in
  let token_after, _ = current_token state6_clean in
  if token_after = ElseReturnKeyword then
    let state7 = advance_parser state6_clean in
    let else_expr, state8 = parse_natural_expression parse_expr param_name state7 in
    let condition_expr = BinaryOpExpr (VarExpr param_ref, comparison_op, condition_value) in
    (CondExpr (condition_expr, return_value, else_expr), state8)
  else
    let condition_expr = BinaryOpExpr (VarExpr param_ref, comparison_op, condition_value) in
    (CondExpr (condition_expr, return_value, LitExpr UnitLit), state6)

(** 自然语言表达式解析 *)
and parse_natural_expression parse_expr param_name state =
  let token, _ = current_token state in
  match token with
  | QuotedIdentifierToken _ ->
      let expr, state1 = parse_natural_arithmetic_expression parse_expr param_name state in
      (expr, state1)
  | InputKeyword ->
      let expr, state1 = parse_natural_arithmetic_expression parse_expr param_name state in
      (expr, state1)
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ ->
      let literal, state1 = parse_literal state in
      (LitExpr literal, state1)
  | _ -> parse_expr state

(** 自然语言算术表达式解析 *)
and parse_natural_arithmetic_expression parse_expr param_name state =
  let left_expr, state1 = parse_natural_primary parse_expr param_name state in
  parse_natural_arithmetic_tail parse_expr left_expr param_name state1

(** 自然语言算术表达式尾部解析 *)
and parse_natural_arithmetic_tail parse_expr left_expr param_name state =
  let token, _ = current_token state in
  match token with
  | MultiplyKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_natural_primary parse_expr param_name state1 in
      let new_expr = BinaryOpExpr (left_expr, Mul, right_expr) in
      parse_natural_arithmetic_tail parse_expr new_expr param_name state2
  | DivideKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_natural_primary parse_expr param_name state1 in
      let new_expr = BinaryOpExpr (left_expr, Div, right_expr) in
      parse_natural_arithmetic_tail parse_expr new_expr param_name state2
  | AddToKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_natural_primary parse_expr param_name state1 in
      let new_expr = BinaryOpExpr (left_expr, Add, right_expr) in
      parse_natural_arithmetic_tail parse_expr new_expr param_name state2
  | SubtractKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_natural_primary parse_expr param_name state1 in
      let new_expr = BinaryOpExpr (left_expr, Sub, right_expr) in
      parse_natural_arithmetic_tail parse_expr new_expr param_name state2
  | _ -> (left_expr, state)

(** 自然语言基础表达式解析 *)
and parse_natural_primary parse_expr param_name state =
  let token, _ = current_token state in
  match token with
  | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      parse_natural_identifier_patterns parse_expr name param_name state1
  | InputKeyword ->
      let state1 = advance_parser state in
      parse_natural_input_patterns parse_expr param_name state1
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ ->
      let literal, state1 = parse_literal state in
      (LitExpr literal, state1)
  | LeftParen ->
      let state1 = advance_parser state in
      let expr, state2 = parse_expr state1 in
      let state3 = expect_token state2 RightParen in
      (expr, state3)
  | _ -> parse_expr state

(** 自然语言标识符模式解析 *)
and parse_natural_identifier_patterns _parse_expr name param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | OfParticle ->
      let state2 = advance_parser state in
      let func_name, state3 = parse_identifier state2 in
      (FunCallExpr (VarExpr func_name, [ VarExpr name ]), state3)
  | MinusOneKeyword ->
      let state2 = advance_parser state in
      let minus_one_expr = BinaryOpExpr (VarExpr name, Sub, LitExpr (IntLit 1)) in
      parse_natural_arithmetic_continuation minus_one_expr param_name state2
  | _ -> (VarExpr name, state)

(** 自然语言输入模式解析 *)
and parse_natural_input_patterns parse_expr param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | MinusOneKeyword ->
      let state1 = advance_parser state in
      let minus_one_expr = BinaryOpExpr (VarExpr param_name, Sub, LitExpr (IntLit 1)) in
      parse_natural_arithmetic_continuation minus_one_expr param_name state1
  | SmallKeyword ->
      let state1 = advance_parser state in
      parse_natural_comparison_patterns parse_expr param_name state1
  | _ -> (VarExpr param_name, state)

(** 自然语言比较模式解析 *)
and parse_natural_comparison_patterns parse_expr param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | LessThanEqualToKeyword ->
      let state1 = advance_parser state in
      let right_expr, state2 = parse_expr state1 in
      (BinaryOpExpr (VarExpr param_name, Le, right_expr), state2)
  | _ -> (VarExpr param_name, state)