(** 骆言语法分析器标识符和函数调用处理模块

    本模块专门处理标识符解析和函数调用相关的功能，从parser_expressions_primary.ml中拆分出来。 负责处理复合标识符、函数调用参数收集、标签函数调用等功能。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #644 重构 *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils

(** 处理复合标识符，如"去除空白" *)
let rec handle_compound_identifier name state =
  let token, _ = current_token state in
  match (name, token) with
  | "去除", EmptyKeyword -> (
      (* Handle "去除空白" specifically *)
      let state1 = advance_parser state in
      let token2, _ = current_token state1 in
      match token2 with
      | QuotedIdentifierToken "白" ->
          let state2 = advance_parser state1 in
          ("去除空白", state2)
      | _ -> (name, state))
  | _ -> (name, state)

(** 解析原子表达式（函数参数） *)
and parse_atomic_expr state =
  let token, pos = current_token state in
  match token with
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ ->
      let literal, state1 = parse_literal state in
      (LitExpr literal, state1)
  | BoolToken _ ->
      let literal, state1 = parse_literal state in
      (LitExpr literal, state1)
  | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      if looks_like_string_literal name then (LitExpr (StringLit name), state1)
      else (VarExpr name, state1)
  | OneKeyword ->
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  | LeftParen | ChineseLeftParen ->
      let state1 = advance_parser state in
      let expr, state2 = Parser_expressions.parse_expression state1 in
      let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
      (expr, state3)
  | _ -> raise (SyntaxError ("期待参数表达式: " ^ show_token token, pos))

(** 收集函数调用参数 *)
and collect_function_args arg_list state =
  let rec collect_args arg_list state =
    let token, _ = current_token state in
    match token with
    | LeftParen | ChineseLeftParen | QuotedIdentifierToken _ | IntToken _ | ChineseNumberToken _
    | FloatToken _ | StringToken _ | BoolToken _ | OneKeyword ->
        let arg, state1 = parse_atomic_expr state in
        collect_args (arg :: arg_list) state1
    | _ -> (List.rev arg_list, state)
  in
  collect_args arg_list state

(** 处理标签函数调用 *)
and parse_labeled_function_call name state =
  let label_args, state1 = parse_label_arg_list [] state in
  let expr = LabeledFunCallExpr (VarExpr name, label_args) in
  (expr, state1)
(* Temporarily remove circular dependency *)

(** 处理普通函数调用 *)
and parse_regular_function_call name state =
  let arg_list, state1 = collect_function_args [] state in
  let expr = if arg_list = [] then VarExpr name else FunCallExpr (VarExpr name, arg_list) in
  (expr, state1)
(* Temporarily remove circular dependency *)

(** 解析函数调用或变量（重构后的主函数） *)
and parse_function_call_or_variable name state =
  (* 处理复合标识符 *)
  let final_name, state_after_name = handle_compound_identifier name state in

  let token, _ = current_token state_after_name in
  if token = Tilde then
    (* 标签函数调用 *)
    parse_labeled_function_call final_name state_after_name
  else
    (* 普通函数调用 *)
    parse_regular_function_call final_name state_after_name

(** 解析标签参数列表 *)
and parse_label_arg_list arg_list state =
  let token, _ = current_token state in
  match token with
  | Tilde ->
      let state1 = advance_parser state in
      let label_arg, state2 = parse_label_arg state1 in
      parse_label_arg_list (label_arg :: arg_list) state2
  | _ -> (List.rev arg_list, state)

(** 解析单个标签参数 *)
and parse_label_arg state =
  let label_name, state1 = parse_identifier state in
  let state2 = expect_token state1 Colon in
  let arg_expr, state3 = Parser_expressions.parse_expression state2 in
  ({ arg_label = label_name; arg_value = arg_expr }, state3)
