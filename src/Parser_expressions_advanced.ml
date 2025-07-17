(** 骆言语法分析器高级表达式解析模块 - Advanced Expression Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils
open Parser_patterns

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

(** 解析函数表达式 *)
let rec parse_function_expression parse_expr state =
  let state1 = expect_token state FunKeyword in
  let token, _ = current_token state1 in
  (* 检查是否有标签参数 *)
  if token = Tilde then parse_labeled_function_expression parse_expr state1
  else
    (* 普通函数表达式 *)
    let rec parse_param_list param_list state =
      let token, _ = current_token state in
      match token with
      | QuotedIdentifierToken name ->
          let state1 = advance_parser state in
          parse_param_list (name :: param_list) state1
      | Arrow | ChineseArrow | ShouldGetKeyword | AncientArrowKeyword ->
          let state1 = advance_parser state in
          (List.rev param_list, state1)
      | _ -> raise (SyntaxError ("期望参数或箭头", snd (current_token state)))
    in
    let param_list, state2 = parse_param_list [] state1 in
    let state2_clean = skip_newlines state2 in
    let expr, state3 = parse_expr state2_clean in
    (FunExpr (param_list, expr), state3)

(** 解析标签函数表达式 *)
and parse_labeled_function_expression parse_expr state =
  let rec parse_labeled_param_list param_list state =
    let token, pos = current_token state in
    match token with
    | Tilde ->
        let state1 = advance_parser state in
        let label_param, state2 = parse_label_param state1 in
        parse_labeled_param_list (label_param :: param_list) state2
    | Arrow | ChineseArrow ->
        let state1 = advance_parser state in
        (List.rev param_list, state1)
    | _ -> raise (SyntaxError ("期望标签参数或箭头", pos))
  in
  let label_params, state1 = parse_labeled_param_list [] state in
  let state1_clean = skip_newlines state1 in
  let expr, state2 = parse_expr state1_clean in
  (LabeledFunExpr (label_params, expr), state2)

(** 解析单个标签参数 *)
and parse_label_param state =
  let label_name, state1 = parse_identifier state in
  let token, _ = current_token state1 in
  match token with
  | QuestionMark ->
      (* 可选参数 *)
      let state2 = advance_parser state1 in
      let token2, _ = current_token state2 in
      if token2 = Colon then
        (* 有默认值的可选参数: ~label?: default_value *)
        let state3 = advance_parser state2 in
        let default_expr, state4 =
          let token, _ = current_token state3 in
          match token with
          | IntToken i -> (LitExpr (IntLit i), advance_parser state3)
          | QuotedIdentifierToken name -> (VarExpr name, advance_parser state3)
          | _ -> (LitExpr UnitLit, state3)
        in
        ( {
            label_name;
            param_name = label_name;
            param_type = None;
            is_optional = true;
            default_value = Some default_expr;
          },
          state4 )
      else
        (* 无默认值的可选参数: ~label? *)
        ( {
            label_name;
            param_name = label_name;
            param_type = None;
            is_optional = true;
            default_value = None;
          },
          state2 )
  | Colon ->
      (* 带类型注解的参数: ~label: type *)
      let state2 = advance_parser state1 in
      let type_expr, state3 =
        let name, state = parse_identifier state2 in
        (TypeVar name, state)
      in
      ( {
          label_name;
          param_name = label_name;
          param_type = Some type_expr;
          is_optional = false;
          default_value = None;
        },
        state3 )
  | _ ->
      (* 普通标签参数: ~label *)
      ( {
          label_name;
          param_name = label_name;
          param_type = None;
          is_optional = false;
          default_value = None;
        },
        state1 )

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
      let rec parse_fields fields state =
        let state = skip_newlines state in
        let token, pos = current_token state in
        match token with
        | AncientRecordEndKeyword ->
            let state1 = advance_parser state in
            (RecordExpr (List.rev fields), state1)
        | QuotedIdentifierToken field_name ->
            let state1 = advance_parser state in
            let state2 = expect_token state1 AsForKeyword in
            let value, state3 = parse_expr state2 in
            (* 解析序号（其一、其二、其三等） *)
            let state4 = 
              let token, _ = current_token state3 in
              match token with
              | AncientItsFirstKeyword | AncientItsSecondKeyword | AncientItsThirdKeyword ->
                  advance_parser state3
              | _ -> state3
            in
            parse_fields ((field_name, value) :: fields) state4
        | _ ->
            raise (SyntaxError ("期望字段名或「据结束」", pos))
      in
      parse_fields [] state1
  | AncientRecordUpdateKeyword ->
      (* 据更新 ... 据毕 - 记录更新 *)
      let state1 = advance_parser state in
      (* 解析记录表达式 - 只解析简单的变量引用，不解析函数调用 *)
      let expr, state2 = 
        let token, _ = current_token state1 in
        match token with
        | QuotedIdentifierToken name ->
            let state_after_name = advance_parser state1 in
            (VarExpr name, state_after_name)
        | _ ->
            (* 对于其他复杂表达式，使用完整的表达式解析器 *)
            parse_expr state1
      in
      let rec parse_updates updates state =
        let state = skip_newlines state in
        let token, pos = current_token state in
        match token with
        | AncientRecordFinishKeyword ->
            let state1 = advance_parser state in
            (RecordUpdateExpr (expr, List.rev updates), state1)
        | QuotedIdentifierToken field_name ->
            let state1 = advance_parser state in
            let state2 = expect_token state1 AsForKeyword in
            let value, state3 = parse_expr state2 in
            (* 解析序号（其一、其二、其三等） *)
            let state4 = 
              let token, _ = current_token state3 in
              match token with
              | AncientItsFirstKeyword | AncientItsSecondKeyword | AncientItsThirdKeyword ->
                  advance_parser state3
              | _ -> state3
            in
            parse_updates ((field_name, value) :: updates) state4
        | _ ->
            raise (SyntaxError ("期望字段名或「据毕」", pos))
      in
      parse_updates [] state2
  | _ ->
      raise (SyntaxError ("期望古雅体记录关键词", pos))

(** 解析try表达式 *)
let parse_try_expression parse_expr state =
  let state1 = expect_token state TryKeyword in
  let state1 = skip_newlines state1 in
  let try_expr, state2 = parse_expr state1 in
  let state2 = skip_newlines state2 in
  let state3 = expect_token state2 CatchKeyword in
  let state3 = skip_newlines state3 in

  (* 解析catch分支 *)
  let rec parse_catch_branches branches state =
    let state = skip_newlines state in
    let token, _ = current_token state in
    match token with
    | Pipe ->
        let state1 = advance_parser state in
        let pattern, state2 = parse_pattern state1 in
        (* Exception handling typically doesn't use guards, but we support it *)
        let guard, state3 =
          if is_token state2 WhenKeyword then
            let state2_1 = advance_parser state2 in
            let guard_expr, state2_2 = parse_expr state2_1 in
            (Some guard_expr, state2_2)
          else (None, state2)
        in
        let state4 = expect_token state3 Arrow in
        let state4 = skip_newlines state4 in
        let expr, state5 = parse_expr state4 in
        let state5 = skip_newlines state5 in
        let branch = { pattern; guard; expr } in
        parse_catch_branches (branch :: branches) state5
    | _ -> (List.rev branches, state)
  in

  let catch_branches, state4 = parse_catch_branches [] state3 in

  (* 检查是否有finally块 *)
  let state4 = skip_newlines state4 in
  let token, _ = current_token state4 in
  match token with
  | FinallyKeyword ->
      let state5 = advance_parser state4 in
      let state5 = skip_newlines state5 in
      let finally_expr, state6 = parse_expr state5 in
      (TryExpr (try_expr, catch_branches, Some finally_expr), state6)
  | _ -> (TryExpr (try_expr, catch_branches, None), state4)

(** 解析raise表达式 *)
let parse_raise_expression parse_expr state =
  let state1 = expect_token state RaiseKeyword in
  let expr, state2 = parse_expr state1 in
  (RaiseExpr expr, state2)

(** 解析ref表达式 *)
let parse_ref_expression parse_expr state =
  let state1 = expect_token state RefKeyword in
  let expr, state2 = parse_expr state1 in
  (RefExpr expr, state2)

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
