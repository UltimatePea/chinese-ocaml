(** 骆言语法分析器记录表达式解析模块 - Record Expression Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils

(** 解析记录表达式 *)
let rec parse_record_expression parse_expr state =
  let state1 = expect_token_punctuation state is_left_brace "left brace" in
  let rec parse_fields fields state =
    let state = skip_newlines state in
    let token, pos = current_token state in
    match token with
    | RightBrace -> (RecordExpr (List.rev fields), advance_parser state)
    | QuotedIdentifierToken field_name ->
        let state1 = advance_parser state in
        (* Check if this is a record update expression *)
        if fields = [] && is_token state1 WithKeyword then
          (* This is { expr 与 field = value } syntax *)
          let expr = VarExpr field_name in
          let state2 = expect_token state1 WithKeyword in
          let updates, state3 = parse_record_updates parse_expr state2 in
          (RecordUpdateExpr (expr, updates), state3)
        else
          (* Regular field *)
          let state2 = expect_token state1 AsForKeyword in
          let value, state3 = parse_expr state2 in
          let state4 =
            let token, _ = current_token state3 in
            if is_semicolon token then advance_parser state3 else state3
          in
          parse_fields ((field_name, value) :: fields) state4
    | _ ->
        (* Could be { expr 与 ... } where expr is not just an identifier *)
        if fields = [] then
          let expr, state1 = parse_expr state in
          let state2 = expect_token state1 WithKeyword in
          let updates, state3 = parse_record_updates parse_expr state2 in
          (RecordUpdateExpr (expr, updates), state3)
        else raise (SyntaxError ("期望字段名或右花括号", pos))
  in
  let fields_or_expr, state2 = parse_fields [] state1 in
  (fields_or_expr, state2)

(** 解析记录更新字段 *)
and parse_record_updates parse_expr state =
  let rec parse_updates updates state =
    let state = skip_newlines state in
    let token, _ = current_token state in
    match token with
    | RightBrace -> (List.rev updates, advance_parser state)
    | QuotedIdentifierToken field_name ->
        let state1 = advance_parser state in
        let state2 = expect_token state1 AsForKeyword in
        let value, state3 = parse_expr state2 in
        let state4 =
          let token, _ = current_token state3 in
          if is_semicolon token then advance_parser state3 else state3
        in
        parse_updates ((field_name, value) :: updates) state4
    | _ -> raise (SyntaxError ("期望字段名", snd (current_token state)))
  in
  parse_updates [] state

(** 解析古雅体序号标识符 *)
let parse_ancient_sequence_marker state =
  let token, _ = current_token state in
  match token with
  | AncientItsFirstKeyword | AncientItsSecondKeyword | AncientItsThirdKeyword ->
      advance_parser state
  | _ -> state

(** 解析古雅体记录字段 *)
let parse_ancient_record_field parse_expr field_name state1 =
  let state2 = expect_token state1 AsForKeyword in
  let value, state3 = parse_expr state2 in
  let state4 = parse_ancient_sequence_marker state3 in
  ((field_name, value), state4)

(** 解析古雅体记录创建 *)
let parse_ancient_record_creation parse_expr state1 =
  let rec parse_fields fields state =
    let state = skip_newlines state in
    let token, pos = current_token state in
    match token with
    | AncientRecordEndKeyword ->
        let state1 = advance_parser state in
        (RecordExpr (List.rev fields), state1)
    | QuotedIdentifierToken field_name ->
        let state1 = advance_parser state in
        let field, state_after_field = parse_ancient_record_field parse_expr field_name state1 in
        parse_fields (field :: fields) state_after_field
    | _ ->
        raise (SyntaxError ("期望字段名或「据结束」", pos))
  in
  parse_fields [] state1

(** 解析记录表达式（用于古雅体记录更新） *)
let parse_record_expr_for_update parse_expr state1 =
  let token, _ = current_token state1 in
  match token with
  | QuotedIdentifierToken name ->
      let state_after_name = advance_parser state1 in
      (VarExpr name, state_after_name)
  | _ ->
      (* 对于其他复杂表达式，使用完整的表达式解析器 *)
      parse_expr state1

(** 解析古雅体记录更新 *)
let parse_ancient_record_update parse_expr state1 =
  let expr, state2 = parse_record_expr_for_update parse_expr state1 in
  let rec parse_updates updates state =
    let state = skip_newlines state in
    let token, pos = current_token state in
    match token with
    | AncientRecordFinishKeyword ->
        let state1 = advance_parser state in
        (RecordUpdateExpr (expr, List.rev updates), state1)
    | QuotedIdentifierToken field_name ->
        let state1 = advance_parser state in
        let update, state_after_update = parse_ancient_record_field parse_expr field_name state1 in
        parse_updates (update :: updates) state_after_update
    | _ ->
        raise (SyntaxError ("期望字段名或「据毕」", pos))
  in
  parse_updates [] state2

(** 解析古雅体记录表达式 *)
let parse_ancient_record_expression parse_expr state =
  let token, pos = current_token state in
  match token with
  | AncientRecordEmptyKeyword ->
      (* 据空 - 空记录 *)
      let state1 = advance_parser state in
      (RecordExpr [], state1)
  | AncientRecordStartKeyword ->
      (* 据开始 ... 据结束 - 记录创建 *)
      let state1 = advance_parser state in
      parse_ancient_record_creation parse_expr state1
  | AncientRecordUpdateKeyword ->
      (* 据更新 ... 据毕 - 记录更新 *)
      let state1 = advance_parser state in
      parse_ancient_record_update parse_expr state1
  | _ ->
      raise (SyntaxError ("期望古雅体记录关键词", pos))