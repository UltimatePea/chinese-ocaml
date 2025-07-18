(** 骆言语法分析器条件表达式解析模块 - Conditional Expression Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils

(** 解析条件表达式 *)
let parse_conditional_expression parse_expr state =
  let state1 = expect_token state IfKeyword in
  let cond, state2 = parse_expr state1 in
  let state3 = expect_token state2 ThenKeyword in
  let state3_clean = skip_newlines state3 in
  let then_branch, state4 = parse_expr state3_clean in
  let state4_clean = skip_newlines state4 in
  let state5 = expect_token state4_clean ElseKeyword in
  let state5_clean = skip_newlines state5 in
  let else_branch, state6 = parse_expr state5_clean in
  (CondExpr (cond, then_branch, else_branch), state6)
