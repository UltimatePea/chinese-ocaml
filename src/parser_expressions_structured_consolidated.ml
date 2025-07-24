(** 骆言语法分析器结构化表达式解析模块 - 整合版

    本模块整合了原有的多个结构化表达式解析模块：
    - parser_exprs_arrays.ml
    - parser_exprs_record.ml
    - parser_exprs_match.ml
    - parser_exprs_calls.ml
    - parser_exprs_function.ml
    - parser_exprs_conditional.ml
    - parser_exprs_assignment.ml (部分功能)

    整合目的： 1. 将相关的结构化数据处理逻辑集中 2. 减少模块间的重复代码 3. 统一结构化表达式的解析风格 4. 简化模块依赖关系

    技术债务重构 - Fix #796
    @author 骆言AI代理
    @version 3.0 (整合版)
    @since 2025-07-21 *)

open Ast
open Lexer
open Parser_utils

(** ==================== 数组表达式解析 ==================== *)

(** 解析数组表达式 *)
let parse_array_expr parse_expr state =
  let state1 = expect_token_punctuation state is_left_array "left array bracket" in
  let rec parse_elements elements state =
    let state = skip_newlines state in
    let token, _ = current_token state in
    if token = RightArray || token = ChineseRightArray then
      (ArrayExpr (List.rev elements), advance_parser state)
    else
      let element, state1 = parse_expr state in
      let state2 =
        let token, _ = current_token state1 in
        if is_semicolon token then advance_parser state1 else state1
      in
      parse_elements (element :: elements) state2
  in
  parse_elements [] state1

(** ==================== 记录表达式解析 ==================== *)

(** 解析记录字段 *)
let rec parse_record_fields parse_expr fields state =
  let state = skip_newlines state in
  let token, _ = current_token state in
  match token with
  | RightBrace -> (List.rev fields, advance_parser state)
  | QuotedIdentifierToken field_name ->
      let state1 = advance_parser state in
      let state2 = expect_token state1 AsForKeyword in
      let value, state3 = parse_expr state2 in
      let state4 =
        let token, _ = current_token state3 in
        if is_semicolon token then advance_parser state3 else state3
      in
      parse_record_fields parse_expr ((field_name, value) :: fields) state4
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_record_fields: 期望字段名，得到 " ^ show_token token)
           (snd (current_token state)))

(** 解析记录更新表达式 *)
let rec parse_record_updates parse_expr state =
  let field_name, state1 = parse_identifier state in
  let state2 = expect_token state1 AsForKeyword in
  let value, state3 = parse_expr state2 in
  let token, _ = current_token state3 in
  if is_semicolon token then
    let state4 = advance_parser state3 in
    let rest_updates, state5 = parse_record_updates parse_expr state4 in
    ((field_name, value) :: rest_updates, state5)
  else ([ (field_name, value) ], state3)

(** 解析记录表达式 *)
let parse_record_expr parse_expr state =
  let state1 = expect_token_punctuation state is_left_brace "left brace" in
  let state2 = skip_newlines state1 in
  let token, _ = current_token state2 in
  match token with
  | RightBrace -> (RecordExpr [], advance_parser state2)
  | QuotedIdentifierToken field_name ->
      let state3 = advance_parser state2 in
      (* 检查是否是记录更新表达式 *)
      let token_after, _ = current_token state3 in
      if token_after = WithKeyword then
        (* 这是 { expr 与 field = value } 语法 *)
        let expr = VarExpr field_name in
        let state4 = advance_parser state3 in
        let updates, state5 = parse_record_updates parse_expr state4 in
        let state6 = expect_token_punctuation state5 is_right_brace "right brace" in
        (RecordUpdateExpr (expr, updates), state6)
      else
        (* 常规字段 *)
        let fields, state_final = parse_record_fields parse_expr [] state2 in
        (RecordExpr fields, state_final)
  | _ ->
      (* 可能是 { expr 与 ... } 其中 expr 不只是标识符 *)
      let expr, state3 = parse_expr state2 in
      let state4 = expect_token state3 WithKeyword in
      let updates, state5 = parse_record_updates parse_expr state4 in
      let state6 = expect_token_punctuation state5 is_right_brace "right brace" in
      (RecordUpdateExpr (expr, updates), state6)

(** ==================== 函数调用表达式解析 ==================== *)

(** 解析函数参数列表 *)
let rec parse_function_arguments parse_expr args state =
  let token, _ = current_token state in
  if token = RightParen || token = ChineseRightParen then (List.rev args, advance_parser state)
  else
    let arg, state1 = parse_expr state in
    let state2 =
      let token, _ = current_token state1 in
      if is_comma token then advance_parser state1 else state1
    in
    parse_function_arguments parse_expr (arg :: args) state2

(** 解析函数调用表达式 *)
let parse_function_call_expr parse_expr func_expr state =
  let state1 = expect_token_punctuation state is_left_paren "left parenthesis" in
  let args, state2 = parse_function_arguments parse_expr [] state1 in
  (FunCallExpr (func_expr, args), state2)

(** ==================== 匹配表达式解析 ==================== *)

(** 解析匹配分支 *)
let rec parse_match_cases parse_expr cases state =
  let state = skip_newlines state in
  let token, _ = current_token state in
  if token = EndKeyword then (List.rev cases, advance_parser state)
  else
    let pattern, state1 = Parser_patterns.parse_pattern state in
    let state2 = expect_token state1 Arrow in
    let expr, state3 = parse_expr state2 in
    let state4 = skip_newlines state3 in
    let branch = { pattern; guard = None; expr } in
    parse_match_cases parse_expr (branch :: cases) state4

(** 解析匹配表达式 *)
let parse_match_expr parse_expr state =
  let state1 = expect_token state MatchKeyword in
  let matched_expr, state2 = parse_expr state1 in
  let state3 = expect_token state2 WithKeyword in
  let cases, state4 = parse_match_cases parse_expr [] state3 in
  (MatchExpr (matched_expr, cases), state4)

(** ==================== 条件表达式解析 ==================== *)

(** 解析条件表达式 *)
let parse_conditional_expr parse_expr state =
  let state1 = expect_token state IfKeyword in
  let condition, state2 = parse_expr state1 in
  let state3 = expect_token state2 ThenKeyword in
  let state3_clean = skip_newlines state3 in
  let then_expr, state4 = parse_expr state3_clean in
  (* 更积极地跳过所有可能的换行符 *)
  let rec skip_all_newlines_and_whitespace st =
    let token, _ = current_token st in
    if token = Newline then skip_all_newlines_and_whitespace (advance_parser st) else st
  in
  let state4_clean = skip_all_newlines_and_whitespace state4 in
  let state5 = expect_token state4_clean ElseKeyword in
  let state5_clean = skip_newlines state5 in
  let else_expr, state6 = parse_expr state5_clean in
  (CondExpr (condition, then_expr, else_expr), state6)

(** ==================== 函数定义表达式解析 ==================== *)

(** 解析函数参数 *)
let rec parse_function_params params state =
  let token, _ = current_token state in
  if token = Arrow || token = ShouldGetKeyword || token = AncientArrowKeyword then
    (List.rev params, state)
  else
    let param, state1 = parse_identifier state in
    parse_function_params (param :: params) state1

(** 解析函数表达式 *)
let parse_function_expr parse_expr state =
  let state1 = expect_token state FunKeyword in
  let params, state2 = parse_function_params [] state1 in
  (* Accept either Arrow (->) or ShouldGetKeyword (应得) or AncientArrowKeyword (故) *)
  let token, _ = current_token state2 in
  let state3 =
    if token = Arrow then expect_token state2 Arrow
    else if token = ShouldGetKeyword then expect_token state2 ShouldGetKeyword
    else if token = AncientArrowKeyword then expect_token state2 AncientArrowKeyword
    else expect_token state2 Arrow
  in
  (* Default error case *)
  let body, state4 = parse_expr state3 in
  (FunExpr (params, body), state4)

(** ==================== Let表达式解析 ==================== *)

(** 解析let表达式 *)
let parse_let_expr parse_expr state =
  let state1 = expect_token state LetKeyword in
  let name, state2 = parse_identifier_allow_keywords state1 in

  (* 检查语义类型标注 *)
  let _semantic_label_opt, state_after_name =
    let token, _ = current_token state2 in
    if token = AsKeyword then
      let state3 = advance_parser state2 in
      let label, state4 = parse_identifier state3 in
      (Some label, state4)
    else (None, state2)
  in

  (* 检查类型注解 *)
  let _type_annotation_opt, state_before_assign =
    let token, _ = current_token state_after_name in
    if is_double_colon token then
      let state_after_colon = advance_parser state_after_name in
      let name, state = parse_identifier state_after_colon in
      (Some (TypeVar name), state)
    else (None, state_after_name)
  in

  let state3 = expect_token state_before_assign AsForKeyword in
  let val_expr, state4 = parse_expr state3 in
  let state4_clean = skip_newlines state4 in
  let token, _ = current_token state4_clean in
  let state5 = if token = InKeyword then advance_parser state4_clean else state4_clean in
  let state5_clean = skip_newlines state5 in
  let body_expr, state6 = parse_expr state5_clean in

  (* 暂时使用简化的LetExpr，忽略类型注解和语义标签 *)
  (LetExpr (name, val_expr, body_expr), state6)

(** ==================== Try-Catch表达式解析 ==================== *)

(** 解析异常处理分支 *)
let rec parse_exception_cases parse_expr cases state =
  let state = skip_newlines state in
  let token, _ = current_token state in
  if token = EndKeyword then (List.rev cases, advance_parser state)
  else
    let exception_pattern, state1 = Parser_patterns.parse_pattern state in
    let state2 = expect_token state1 Arrow in
    let handler_expr, state3 = parse_expr state2 in
    let state4 = skip_newlines state3 in
    let branch = { pattern = exception_pattern; guard = None; expr = handler_expr } in
    parse_exception_cases parse_expr (branch :: cases) state4

(** 解析try表达式 *)
let parse_try_expr parse_expr state =
  let state1 = expect_token state TryKeyword in
  let try_expr, state2 = parse_expr state1 in
  let state3 = expect_token state2 WithKeyword in
  let cases, state4 = parse_exception_cases parse_expr [] state3 in
  (TryExpr (try_expr, cases, None), state4)

(** 解析raise表达式 *)
let parse_raise_expr parse_expr state =
  let state1 = expect_token state RaiseKeyword in
  let exception_expr, state2 = parse_expr state1 in
  (RaiseExpr exception_expr, state2)

(** ==================== 引用表达式解析 ==================== *)

(** 解析ref表达式 *)
let parse_ref_expr parse_expr state =
  let state1 = expect_token state RefKeyword in
  let value_expr, state2 = parse_expr state1 in
  (RefExpr value_expr, state2)

(** ==================== 组合表达式解析 ==================== *)

(** 解析组合表达式 *)
let parse_combine_expr parse_expr state =
  let state1 = expect_token state CombineKeyword in
  let first_expr, state2 = parse_expr state1 in

  (* 解析后续的 "以及" 连接的表达式 *)
  let rec parse_with_op_exprs exprs current_state =
    let token, _ = current_token current_state in
    match token with
    | WithOpKeyword ->
        let state_after_with = advance_parser current_state in
        let next_expr, state_after_expr = parse_expr state_after_with in
        (* 性能优化：使用 :: 和 List.rev 替代 @ 操作 *)
        parse_with_op_exprs (List.rev (next_expr :: List.rev exprs)) state_after_expr
    | _ -> (exprs, current_state)
  in

  let all_exprs, final_state = parse_with_op_exprs [ first_expr ] state2 in
  (CombineExpr all_exprs, final_state)

(** ==================== 统一解析接口 ==================== *)

(** 解析结构化表达式 - 统一入口函数 *)
let parse_structured_expr parse_expr token state =
  match token with
  (* 数组表达式 *)
  | LeftArray | ChineseLeftArray -> parse_array_expr parse_expr state
  (* 记录表达式 *)
  | LeftBrace -> parse_record_expr parse_expr state
  (* 匹配表达式 *)
  | MatchKeyword -> parse_match_expr parse_expr state
  (* 条件表达式 *)
  | IfKeyword -> parse_conditional_expr parse_expr state
  (* 函数表达式 *)
  | FunKeyword -> parse_function_expr parse_expr state
  (* Let表达式 *)
  | LetKeyword -> parse_let_expr parse_expr state
  (* Try表达式 *)
  | TryKeyword -> parse_try_expr parse_expr state
  (* Raise表达式 *)
  | RaiseKeyword -> parse_raise_expr parse_expr state
  (* Ref表达式 *)
  | RefKeyword -> parse_ref_expr parse_expr state
  (* 组合表达式 *)
  | CombineKeyword ->
      (* 暂时返回简单的表达式，待后续实现完整的combine逻辑 *)
      let state1 = advance_parser state in
      let expr, state2 = parse_expr state1 in
      (CombineExpr [ expr ], state2)
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_structured_expr: 不支持的结构化表达式token " ^ show_token token)
           (snd (current_token state)))

(** ==================== 接口兼容性别名 ==================== *)

(** 为接口兼容性提供的别名函数 *)
let parse_array_expression = parse_array_expr
let parse_record_expression = parse_record_expr
let parse_function_call_expression = parse_function_call_expr
let parse_match_expression = parse_match_expr
let parse_conditional_expression = parse_conditional_expr
let parse_function_expression = parse_function_expr
let parse_let_expression = parse_let_expr
let parse_try_expression = parse_try_expr
let parse_raise_expression = parse_raise_expr
let parse_ref_expression = parse_ref_expr
let parse_combine_expression = parse_combine_expr
let parse_structured_expression = parse_structured_expr

(** 记录更新解析 - 从记录表达式解析中提取 *)
let parse_record_updates parse_expr state =
  (* 简单实现：解析字段更新列表 *)
  let rec parse_updates acc state =
    let field_name, state1 = parse_identifier state in
    let state2 = expect_token state1 Equal in
    let field_value, state3 = parse_expr state2 in
    let new_acc = (field_name, field_value) :: acc in
    let token, _ = current_token state3 in
    if is_semicolon token then
      parse_updates new_acc (advance_parser state3)
    else
      (List.rev new_acc, state3)
  in
  parse_updates [] state
