(** 骆言语法分析器模式匹配表达式解析模块 - Match Expression Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils
open Parser_patterns

(** 解析匹配表达式 *)
let parse_match_expression parse_expr state =
  let state1 = expect_token state MatchKeyword in
  let expr, state2 = parse_expr state1 in
  let state3 = expect_token state2 WithKeyword in
  let state3_clean = skip_newlines state3 in
  let rec parse_branch_list branch_list state =
    let state = skip_newlines state in
    if is_punctuation state is_pipe then
      let state1 = advance_parser state in
      let pattern, state2 = parse_pattern state1 in
      (* 检查是否有guard条件 (当 expression) *)
      let guard, state3 =
        if is_token state2 WhenKeyword then
          let state2_1 = advance_parser state2 in
          let guard_expr, state2_2 = parse_expr state2_1 in
          (Some guard_expr, state2_2)
        else (None, state2)
      in
      let state4 = expect_token_punctuation state3 is_arrow "arrow" in
      let state4_clean = skip_newlines state4 in
      let expr, state5 = parse_expr state4_clean in
      let state5_clean = skip_newlines state5 in
      let branch = { pattern; guard; expr } in
      parse_branch_list (branch :: branch_list) state5_clean
    else (List.rev branch_list, state)
  in
  let branch_list, state4 = parse_branch_list [] state3_clean in
  (MatchExpr (expr, branch_list), state4)
