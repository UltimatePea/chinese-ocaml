(** 骆言语法分析器函数调用处理模块 - Chinese Programming Language Parser Function Calls *)

open Ast
open Lexer
open Parser_utils

(** 解析带标签的函数调用 *)
let rec parse_labeled_function_call _parse_expression parse_postfix_expression
    parse_primary_expression name state =
  let label_args, state1 = parse_label_arg_list parse_primary_expression [] state in
  let expr = LabeledFunCallExpr (VarExpr name, label_args) in
  parse_postfix_expression expr state1

(** 解析括号内的函数参数列表 *)
and parse_parenthesized_function_args parse_expression state =
  let parse_function_args acc state =
    let token, _ = current_token state in
    if token = RightParen || token = ChineseRightParen then
      let state_after_paren = advance_parser state in
      (List.rev acc, state_after_paren)
    else
      let arg, state_after_arg = parse_expression state in
      let rec parse_more_args acc state =
        let token, _ = current_token state in
        if token = RightParen || token = ChineseRightParen then
          let state_after_paren = advance_parser state in
          (List.rev acc, state_after_paren)
        else if token = Comma || token = ChineseComma then
          let state_after_comma = advance_parser state in
          let next_arg, state_after_next_arg = parse_expression state_after_comma in
          parse_more_args (next_arg :: acc) state_after_next_arg
        else raise (SyntaxError ("期望 ')' 或 ','", snd (current_token state)))
      in
      parse_more_args (arg :: acc) state_after_arg
  in
  parse_function_args [] state

(** 解析括号形式的函数调用 *)
and parse_parenthesized_function_call parse_expression parse_postfix_expression name state =
  let state1 = advance_parser state in
  let args, state2 = parse_parenthesized_function_args parse_expression state1 in
  let expr = FunCallExpr (VarExpr name, args) in
  parse_postfix_expression expr state2

(** 收集无括号函数调用的参数 *)
and collect_function_arguments parse_primary_expression state =
  let rec collect_args arg_list state =
    let token, _ = current_token state in
    match token with
    | QuotedIdentifierToken _ | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _
    | BoolToken _ ->
        let arg, state1 = parse_primary_expression state in
        collect_args (arg :: arg_list) state1
    | _ -> (List.rev arg_list, state)
  in
  collect_args [] state

(** 解析无括号形式的函数调用或变量引用 *)
and parse_unparenthesized_function_call_or_variable parse_primary_expression
    parse_postfix_expression name state =
  let arg_list, state1 = collect_function_arguments parse_primary_expression state in
  let expr = if arg_list = [] then VarExpr name else FunCallExpr (VarExpr name, arg_list) in
  parse_postfix_expression expr state1

(** 解析函数调用或变量引用的主入口函数 *)
and parse_function_call_or_variable parse_expression parse_primary_expression
    parse_postfix_expression name state =
  let token, _ = current_token state in
  match token with
  | Tilde ->
      parse_labeled_function_call parse_expression parse_postfix_expression parse_primary_expression
        name state
  | LeftParen | ChineseLeftParen ->
      parse_parenthesized_function_call parse_expression parse_postfix_expression name state
  | _ ->
      parse_unparenthesized_function_call_or_variable parse_primary_expression
        parse_postfix_expression name state

(** 解析标签参数列表 *)
and parse_label_arg_list parse_primary_expression arg_list state =
  let rec parse_label_arg_list_impl arg_list state =
    let token, _ = current_token state in
    match token with
    | Tilde ->
        let state1 = advance_parser state in
        let label_arg, state2 = parse_label_arg parse_primary_expression state1 in
        parse_label_arg_list_impl (label_arg :: arg_list) state2
    | _ -> (List.rev arg_list, state)
  in
  parse_label_arg_list_impl arg_list state

(** 解析单个标签参数 *)
and parse_label_arg parse_primary_expression state =
  let label_name, state1 = parse_identifier state in
  let state2 = expect_token state1 Colon in
  let arg_expr, state3 = parse_primary_expression state2 in
  ({ arg_label = label_name; arg_value = arg_expr }, state3)
