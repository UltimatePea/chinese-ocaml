(** 骆言语法分析器逻辑运算表达式解析模块 - Logical Expression Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils

(** 解析逻辑或表达式 *)
let rec parse_logical_or_expression parse_expr state =
  create_binary_parser [ Or ] (parse_logical_and_expression parse_expr) state

(** 解析逻辑与表达式 *)
and parse_logical_and_expression parse_expr state =
  create_binary_parser [ And ] (parse_comparison_expression parse_expr) state

(** 解析比较表达式 *)
and parse_comparison_expression parse_expr state =
  create_binary_parser [ Eq; Neq; Lt; Le; Gt; Ge ] (parse_arithmetic_expression parse_expr) state

(** 解析算术表达式 - 使用通用binary parser *)
and parse_arithmetic_expression parse_expr state =
  create_binary_parser [ Add; Sub ] (parse_multiplicative_expression parse_expr) state

(** 解析乘除表达式 *)
and parse_multiplicative_expression parse_expr state =
  create_binary_parser [ Mul; Div; Mod ] (parse_unary_expression parse_expr) state

(** 解析一元表达式 - 使用通用解析器减少重复 *)
and parse_unary_expression parse_expr state =
  create_unary_parser parse_primary_expression parse_expr state

(** 解析基础表达式 *)
and parse_primary_expression parse_expr state =
  let token, pos = current_token state in
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
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  | _ -> raise (SyntaxError ("意外的词元: " ^ show_token token, pos))
