(** 骆言语法分析器后缀表达式解析模块 - Postfix Expression Parser *)

open Ast
open Lexer
open Parser_utils

(** 解析后缀表达式（字段访问等） *)
let rec parse_postfix_expression parse_expr expr state =
  let token, _ = current_token state in
  match token with
  | Dot -> (
      let state1 = advance_parser state in
      let token2, _ = current_token state1 in
      match token2 with
      | LeftParen -> (
          (* 数组访问 expr.(index) *)
          let state2 = advance_parser state1 in
          let index_expr, state3 = parse_expr state2 in
          let state4 = expect_token state3 RightParen in
          (* 检查是否是数组更新 *)
          let token3, _ = current_token state4 in
          match token3 with
          | AssignArrow ->
              (* 数组更新 expr.(index) <- value *)
              let state5 = advance_parser state4 in
              let value_expr, state6 = parse_expr state5 in
              (ArrayUpdateExpr (expr, index_expr, value_expr), state6)
          | _ ->
              (* 只是数组访问 *)
              let new_expr = ArrayAccessExpr (expr, index_expr) in
              parse_postfix_expression parse_expr new_expr state4)
      | QuotedIdentifierToken field_name ->
          (* 记录字段访问 expr.field *)
          let state2 = advance_parser state1 in
          let new_expr = FieldAccessExpr (expr, field_name) in
          parse_postfix_expression parse_expr new_expr state2
      | _ -> raise (SyntaxError ("期望字段名或左括号", snd (current_token state1))))
  | _ -> (expr, state)
