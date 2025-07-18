(** 骆言语法分析器数组和让表达式解析模块 - Array and Let Expression Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils

(** 解析让表达式 *)
let parse_let_expression parse_expr state =
  let state1 = expect_token state LetKeyword in
  let name, state2 = parse_identifier_allow_keywords state1 in
  (* Check for semantic type annotation *)
  let semantic_label_opt, state_after_name =
    let token, _ = current_token state2 in
    if token = AsKeyword then
      let state3 = advance_parser state2 in
      let label, state4 = parse_identifier state3 in
      (Some label, state4)
    else (None, state2)
  in
  (* 检查是否有类型注解 *)
  let type_annotation_opt, state_before_assign =
    let token, _ = current_token state_after_name in
    if is_double_colon token then
      (* 类型注解 *)
      let state_after_colon = advance_parser state_after_name in
      let type_expr, state_after_type =
        let name, state = parse_identifier state_after_colon in
        (TypeVar name, state)
      in
      (Some type_expr, state_after_type)
    else (None, state_after_name)
  in
  let state3 = expect_token state_before_assign AsForKeyword in
  let val_expr, state4 = parse_expr state3 in
  let state4_clean = skip_newlines state4 in
  let token, _ = current_token state4_clean in
  let state5 = if token = InKeyword then advance_parser state4_clean else state4_clean in
  let state5_clean = skip_newlines state5 in
  let body_expr, state6 = parse_expr state5_clean in
  match (semantic_label_opt, type_annotation_opt) with
  | Some label, None -> (SemanticLetExpr (name, label, val_expr, body_expr), state6)
  | None, Some type_expr -> (LetExprWithType (name, type_expr, val_expr, body_expr), state6)
  | None, None -> (LetExpr (name, val_expr, body_expr), state6)
  | Some _, Some _ ->
      (* 目前不支持同时有语义标签和类型注解 *)
      raise (SyntaxError ("不支持同时使用语义标签和类型注解", snd (current_token state6)))

(** 解析数组表达式 *)
let parse_array_expression parse_expr state =
  let state1 = expect_token_punctuation state is_left_array "left array bracket" in
  let rec parse_array_elements elements state =
    let state = skip_newlines state in
    let token, _ = current_token state in
    match token with
    | RightArray | ChineseRightArray -> (ArrayExpr (List.rev elements), advance_parser state)
    | _ -> (
        let expr, state1 = parse_expr state in
        let token, _ = current_token state1 in
        match token with
        | Semicolon | ChineseSemicolon | AfterThatKeyword ->
            let state2 = advance_parser state1 in
            parse_array_elements (expr :: elements) state2
        | RightArray | ChineseRightArray ->
            (ArrayExpr (List.rev (expr :: elements)), advance_parser state1)
        | _ -> raise (SyntaxError ("期望分号或右数组括号", snd (current_token state1))))
  in
  let array_expr, state2 = parse_array_elements [] state1 in
  (array_expr, state2)

(** 解析组合表达式 *)
let parse_combine_expression parse_expr state =
  let state1 = expect_token state CombineKeyword in
  (* Parse first expression *)
  let first_expr, state2 = parse_expr state1 in
  (* Parse remaining expressions with 以及 separator *)
  let rec parse_combine_list expr_list state =
    let token, _ = current_token state in
    if token = WithOpKeyword then
      let state1 = advance_parser state in
      let expr, state2 = parse_expr state1 in
      parse_combine_list (expr :: expr_list) state2
    else (List.rev expr_list, state)
  in
  let rest_exprs, final_state = parse_combine_list [ first_expr ] state2 in
  (CombineExpr rest_exprs, final_state)