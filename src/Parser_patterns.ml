(** 骆言语法分析器模式匹配解析模块 - Chinese Programming Language Parser Patterns *)

open Ast
open Lexer
open Parser_utils

(** 解析模式匹配 *)
let rec parse_pattern state =
  let token, pos = current_token state in
  match token with
  | Underscore ->
      let new_state = advance_parser state in
      (WildcardPattern, new_state)
  | TagKeyword ->
      (* 多态变体模式: 标签 「标签名」 [模式] *)
      let state = advance_parser state in
      let tag_name, state = parse_identifier state in
      let token, _ = current_token state in
      if is_identifier_like token || is_literal_token token then
        (* 有模式的多态变体: 标签 「标签名」 模式 *)
        let pattern, state = parse_pattern state in
        (PolymorphicVariantPattern (tag_name, Some pattern), state)
      else
        (* 无模式的多态变体: 标签 「标签名」 *)
        (PolymorphicVariantPattern (tag_name, None), state)
  | QuotedIdentifierToken id ->
      let state = advance_parser state in
      if current_token state |> fst = LeftParen then
        let state = advance_parser state in
        let parse_expression_fn = fun _s -> 
          raise (Types.ParseError ("构造器模式解析需要表达式解析器支持", pos.line, pos.column)) in
        let args, state = parse_constructor_args state parse_expression_fn in
        let state = expect_token state RightParen in
        (ConstructorPattern (id, args), state)
      else (VarPattern id, state)
  | _ ->
      if is_literal_token token then
        let state = advance_parser state in
        match token with
        | IntToken i -> (LitPattern (IntLit i), state)
        | FloatToken f -> (LitPattern (FloatLit f), state)
        | StringToken s -> (LitPattern (StringLit s), state)
        | BoolToken b -> (LitPattern (BoolLit b), state)
        | _ -> raise (SyntaxError ("未支持的字面量类型", pos))
      else if is_left_bracket token then parse_list_pattern state
      else raise (SyntaxError ("期望模式", pos))

(** 解析构造器参数 *)
and parse_constructor_args state parse_expression_fn =
  let rec loop acc state =
    if is_right_paren (current_token state |> fst) then (List.rev acc, state)
    else
      let expr, state = parse_expression_fn state in
      let acc = expr :: acc in
      if current_token state |> fst = Comma then
        let state = advance_parser state in
        loop acc state
      else (List.rev acc, state)
  in
  loop [] state

(** 解析列表模式 *)
and parse_list_pattern state =
  let state = expect_token state LeftBracket in
  if is_right_bracket (current_token state |> fst) then
    let state = advance_parser state in
    (EmptyListPattern, state)
  else
    let patterns, state = parse_remaining_patterns state in
    let state = expect_token state RightBracket in
    match patterns with
    | [] -> (EmptyListPattern, state)
    | [ single ] -> (single, state)
    | multiple -> (build_cons_pattern multiple, state)

(** 解析剩余模式列表 *)
and parse_remaining_patterns state =
  let first_pattern, state = parse_pattern state in
  if current_token state |> fst = Comma then
    let state = advance_parser state in
    if current_token state |> fst = TripleDot then
      let state = advance_parser state in
      let tail_pattern, state = parse_pattern state in
      ([ ConsPattern (first_pattern, tail_pattern) ], state)
    else
      let rest_patterns, state = parse_remaining_patterns state in
      (first_pattern :: rest_patterns, state)
  else ([ first_pattern ], state)

(** 构建cons模式 *)
and build_cons_pattern = function
  | [] -> EmptyListPattern
  | [ single ] -> single
  | head :: tail -> ConsPattern (head, build_cons_pattern tail)

(** 解析匹配表达式 *)
let rec parse_match_expression state parse_expression_fn =
  let state = expect_token state MatchKeyword in
  let expr, state = parse_expression_fn state in
  let state = expect_token state WithKeyword in
  let cases, state = parse_match_cases state parse_expression_fn in
  (MatchExpr (expr, cases), state)

(** 解析匹配分支 *)
and parse_match_cases state parse_expression_fn =
  let rec loop acc state =
    if not (is_pipe (current_token state |> fst)) then (List.rev acc, state)
    else
      let state = advance_parser state in
      let pattern, state = parse_pattern state in
      let guard, state =
        if current_token state |> fst = WhenKeyword then
          let state = advance_parser state in
          let guard_expr, state = parse_expression_fn state in
          (Some guard_expr, state)
        else (None, state)
      in
      let state = expect_token state Arrow in
      let expr, state = parse_expression_fn state in
      let branch = { pattern; guard; expr } in
      loop (branch :: acc) state
  in
  if is_pipe (current_token state |> fst) then loop [] state
  else raise (SyntaxError ("期望 | 开始匹配分支", current_token state |> snd))

(** 解析古雅体匹配表达式 *)
let rec parse_ancient_match_expression state parse_expression_fn =
  let state = expect_token state AncientObserveKeyword in
  let var_name =
    match current_token state with
    | QuotedIdentifierToken id, _ -> id
    | token, pos -> raise (SyntaxError ("期望变量名，但遇到 " ^ show_token token, pos))
  in
  let state = advance_parser state in
  let state = expect_token state AncientParticleOf in
  let state = expect_token state AncientNatureKeyword in
  let cases, state = parse_ancient_match_cases state parse_expression_fn in
  let match_expr = MatchExpr (VarExpr var_name, cases) in
  (match_expr, state)

(** 解析古雅体匹配分支 *)
and parse_ancient_match_cases state parse_expression_fn =
  let rec loop acc state =
    let token, _pos = current_token state in
    match token with
    | AncientIfKeyword ->
        let state = advance_parser state in
        let pattern, state = parse_pattern state in
        let state = expect_token state AncientThenKeyword in
        let expr, state = parse_expression_fn state in
        let branch = { pattern; guard = None; expr } in
        loop (branch :: acc) state
    | AncientOtherwiseKeyword ->
        let state = advance_parser state in
        let state = expect_token state AncientThenKeyword in
        let expr, state = parse_expression_fn state in
        let wildcard_branch = { pattern = WildcardPattern; guard = None; expr } in
        (List.rev (wildcard_branch :: acc), state)
    | _ -> (List.rev acc, state)
  in
  loop [] state
