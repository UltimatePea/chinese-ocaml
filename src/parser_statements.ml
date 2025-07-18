(** 骆言语法分析器语句解析模块 - Chinese Programming Language Parser Statements *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_main
open Parser_types

(** 跳过换行符辅助函数 *)
let rec skip_newlines state =
  let token, _pos = current_token state in
  if token = Newline then skip_newlines (advance_parser state) else state

(** 解析宏参数列表 *)
let rec parse_macro_params acc state =
  let token, _ = current_token state in
  match token with
  | RightParen -> (List.rev acc, state)
  | QuotedIdentifierToken param_name -> (
      let state1 = advance_parser state in
      let state2 = expect_token state1 Colon in
      let token, _ = current_token state2 in
      match token with
      | QuotedIdentifierToken "表达式" ->
          let state3 = advance_parser state2 in
          let new_param = ExprParam param_name in
          let next_token, _ = current_token state3 in
          if next_token = Comma then
            let state4 = advance_parser state3 in
            parse_macro_params (new_param :: acc) state4
          else parse_macro_params (new_param :: acc) state3
      | QuotedIdentifierToken "语句" ->
          let state3 = advance_parser state2 in
          let new_param = StmtParam param_name in
          let next_token, _ = current_token state3 in
          if next_token = Comma then
            let state4 = advance_parser state3 in
            parse_macro_params (new_param :: acc) state4
          else parse_macro_params (new_param :: acc) state3
      | QuotedIdentifierToken "类型" ->
          let state3 = advance_parser state2 in
          let new_param = TypeParam param_name in
          let next_token, _ = current_token state3 in
          if next_token = Comma then
            let state4 = advance_parser state3 in
            parse_macro_params (new_param :: acc) state4
          else parse_macro_params (new_param :: acc) state3
      | _ -> raise (SyntaxError ("期望宏参数类型：表达式、语句或类型", snd (current_token state2))))
  | _ -> raise (SyntaxError ("期望宏参数名", snd (current_token state)))

(** 解析Let语句（包括普通let和rec let） *)
let parse_let_statement state =
  let token, _ = current_token state in
  match token with
  | LetKeyword -> (
      let state1 = advance_parser state in
      let name, state2 = parse_identifier_allow_keywords state1 in
      (* 检查是否有语义类型注解 *)
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
          let state_after_colon = advance_parser state_after_name in
          let type_expr, state_after_type = parse_type_expression state_after_colon in
          (Some type_expr, state_after_type)
        else (None, state_after_name)
      in
      let state3 = expect_token state_before_assign AsForKeyword in
      let expr, state4 = parse_expression state3 in
      match (semantic_label_opt, type_annotation_opt) with
      | Some label, None -> (SemanticLetStmt (name, label, expr), state4)
      | None, Some type_expr -> (LetStmtWithType (name, type_expr, expr), state4)
      | None, None -> (LetStmt (name, expr), state4)
      | Some _, Some _ ->
          raise (SyntaxError ("不支持同时使用语义标签和类型注解", snd (current_token state4))))
  | RecKeyword -> (
      let state1 = advance_parser state in
      let state2 = expect_token state1 LetKeyword in
      let name, state3 = parse_identifier_allow_keywords state2 in
      (* 检查是否有类型注解 *)
      let type_annotation_opt, state_before_assign =
        let token, _ = current_token state3 in
        if is_double_colon token then
          let state_after_colon = advance_parser state3 in
          let type_expr, state_after_type = parse_type_expression state_after_colon in
          (Some type_expr, state_after_type)
        else (None, state3)
      in
      let state4 = expect_token state_before_assign AsForKeyword in
      let expr, state5 = parse_expression state4 in
      match type_annotation_opt with
      | Some type_expr -> (RecLetStmtWithType (name, type_expr, expr), state5)
      | None -> (RecLetStmt (name, expr), state5))
  | _ -> raise (SyntaxError ("期望let或rec关键字", snd (current_token state)))

(** 解析定义语句（define和set） *)
let parse_definition_statement state =
  let token, _ = current_token state in
  match token with
  | DefineKeyword -> (
      let expr, state1 = parse_natural_function_definition state in
      match expr with
      | LetExpr (func_name, fun_expr, _) -> (LetStmt (func_name, fun_expr), state1)
      | _ -> raise (SyntaxError ("自然语言函数定义解析错误", snd (current_token state))))
  | SetKeyword ->
      let state1 = advance_parser state in
      let name, state2 = parse_wenyan_compound_identifier state1 in
      let state3 = expect_token state2 AsForKeyword in
      let expr, state4 = parse_expression state3 in
      (LetStmt (name, expr), state4)
  | _ -> raise (SyntaxError ("期望define或set关键字", snd (current_token state)))

(** 解析类型相关语句（type, exception, module type） *)
let parse_type_statement state =
  let token, _ = current_token state in
  match token with
  | ExceptionKeyword -> (
      let state1 = advance_parser state in
      let name, state2 = parse_identifier_allow_keywords state1 in
      let token, _ = current_token state2 in
      match token with
      | OfKeyword ->
          let state3 = advance_parser state2 in
          let type_expr, state4 = parse_type_expression state3 in
          (ExceptionDefStmt (name, Some type_expr), state4)
      | _ -> (ExceptionDefStmt (name, None), state2))
  | TypeKeyword ->
      let state1 = advance_parser state in
      let name, state2 = parse_identifier_allow_keywords state1 in
      let state3 = expect_token state2 AsForKeyword in
      let type_def, state4 = parse_type_definition state3 in
      (TypeDefStmt (name, type_def), state4)
  | ModuleTypeKeyword ->
      let state1 = advance_parser state in
      let name, state2 = parse_identifier_allow_keywords state1 in
      let state3 = expect_token state2 AsForKeyword in
      let module_type, state4 = parse_module_type state3 in
      (ModuleTypeDefStmt (name, module_type), state4)
  | _ -> raise (SyntaxError ("期望type、exception或module type关键字", snd (current_token state)))

(** 解析宏定义语句 *)
let parse_macro_statement state =
  let token, _ = current_token state in
  match token with
  | MacroKeyword ->
      let state1 = advance_parser state in
      let macro_name, state2 = parse_identifier_allow_keywords state1 in
      let state3 = expect_token state2 LeftParen in
      let params, state4 = parse_macro_params [] state3 in
      let state5 = expect_token state4 RightParen in
      let state6 = expect_token state5 AsForKeyword in
      let body, state7 = parse_expression state6 in
      let macro_def = { macro_def_name = macro_name; params; body } in
      (MacroDefStmt macro_def, state7)
  | _ -> raise (SyntaxError ("期望macro关键字", snd (current_token state)))

(** 解析表达式语句 *)
let parse_expression_statement state =
  let expr, state1 = parse_expression state in
  (ExprStmt expr, state1)

(** Phase 6.3重构：模块化的语句解析主函数 *)
let parse_statement state =
  let token, _pos = current_token state in
  match token with
  | LetKeyword | RecKeyword -> parse_let_statement state
  | DefineKeyword | SetKeyword -> parse_definition_statement state
  | ExceptionKeyword | TypeKeyword | ModuleTypeKeyword -> parse_type_statement state
  | MacroKeyword -> parse_macro_statement state
  | _ -> parse_expression_statement state

(** 跳过可选的语句终结符 *)
let skip_optional_statement_terminator state =
  let token, _ = current_token state in
  if is_semicolon token || token = AlsoKeyword then advance_parser state else state

(** 解析程序 *)
let parse_program token_list =
  let rec parse_statement_list stmt_list state =
    let state = skip_newlines state in
    let token, _ = current_token state in
    if token = EOF then List.rev stmt_list
    else
      let stmt, state1 = parse_statement state in
      let state2 = skip_optional_statement_terminator state1 in
      let state3 = skip_newlines state2 in
      parse_statement_list (stmt :: stmt_list) state3
  in
  let initial_state = create_parser_state token_list in
  parse_statement_list [] initial_state
