(** 骆言语法分析器复合表达式处理模块（Primary层）

    本模块专门处理复合表达式的解析，包括括号表达式、控制流、古雅体表达式、数据结构等。
    从parser_expressions_primary.ml中拆分出来，专注于Primary层级的复合表达式处理。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #644 重构 *)

open Ast
open Lexer
open Parser_utils

(** 解析括号表达式 (带类型注解支持) *)
let parse_parentheses_expr state =
  let state1 = advance_parser state in
  let expr, state2 = Parser_expressions.parse_expression state1 in
  (* 检查是否有类型注解 *)
  let token, _ = current_token state2 in
  if is_double_colon token then
    (* 类型注解表达式 (expr :: type) *)
    let state3 = advance_parser state2 in
    let type_expr, state4 = Parser_types.parse_type_expression state3 in
    let state5 = expect_token_punctuation state4 is_right_paren "right parenthesis" in
    let annotated_expr = TypeAnnotationExpr (expr, type_expr) in
    (annotated_expr, state5) (* Temporarily remove circular dependency *)
  else
    (* 普通括号表达式 *)
    let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
    (expr, state3)
(* Temporarily remove circular dependency *)

(** 解析控制流关键字表达式 *)
let parse_control_flow_expr state token =
  match token with
  | IfKeyword -> Parser_expressions.parse_conditional_expression state
  | MatchKeyword -> Parser_expressions.parse_match_expression state
  | FunKeyword -> Parser_expressions.parse_function_expression state
  | LetKeyword -> Parser_expressions.parse_let_expression state
  | TryKeyword -> Parser_expressions.parse_try_expression state
  | RaiseKeyword -> Parser_expressions.parse_raise_expression state
  | CombineKeyword -> Parser_expressions.parse_combine_expression state
  | _ -> invalid_arg "parse_control_flow_expr: 不是控制流关键字"

(** 解析文言/古雅体关键字表达式 *)
let parse_ancient_expr state token =
  match token with
  | IfWenyanKeyword ->
      Parser_ancient.parse_ancient_conditional_expression Parser_expressions.parse_expression state
  | HaveKeyword ->
      Parser_ancient.parse_wenyan_let_expression Parser_expressions.parse_expression state
  | SetKeyword ->
      Parser_ancient.parse_wenyan_simple_let_expression Parser_expressions.parse_expression state
  | AncientDefineKeyword ->
      Parser_ancient.parse_ancient_function_definition Parser_expressions.parse_expression state
  | AncientObserveKeyword ->
      Parser_ancient.parse_ancient_match_expression Parser_expressions.parse_expression
        Parser_patterns.parse_pattern state
  | AncientListStartKeyword ->
      Parser_ancient.parse_ancient_list_expression Parser_expressions.parse_expression state
  | AncientRecordStartKeyword | AncientRecordEmptyKeyword | AncientRecordUpdateKeyword ->
      let record_expr, state1 = Parser_expressions.parse_ancient_record_expression state in
      (record_expr, state1)
      (* Temporarily remove circular dependency *)
  | _ -> invalid_arg "parse_ancient_expr: 不是古雅体关键字"

(** 解析数据结构表达式 *)
let parse_data_structure_expr state token =
  match token with
  | LeftArray | ChineseLeftArray -> Parser_expressions.parse_array_expression state
  | LeftBrace ->
      let record_expr, state1 = Parser_expressions.parse_record_expression state in
      (record_expr, state1)
      (* Temporarily remove circular dependency *)
  | RefKeyword -> Parser_expressions.parse_ref_expression state
  | ModuleKeyword -> Parser_expressions.parse_module_expression state
  | _ -> invalid_arg "parse_data_structure_expr: 不是数据结构关键字"

(** 解析复合表达式 - 重构后的主函数 *)
let parse_compound_expr state =
  let token, _ = current_token state in
  match token with
  (* 括号表达式 *)
  | LeftParen | ChineseLeftParen -> parse_parentheses_expr state
  (* 控制流关键字 *)
  | IfKeyword | MatchKeyword | FunKeyword | LetKeyword | TryKeyword | RaiseKeyword | CombineKeyword
    ->
      parse_control_flow_expr state token
  (* 古雅体/文言关键字 *)
  | IfWenyanKeyword | HaveKeyword | SetKeyword | AncientDefineKeyword | AncientObserveKeyword
  | AncientListStartKeyword | AncientRecordStartKeyword | AncientRecordEmptyKeyword
  | AncientRecordUpdateKeyword ->
      parse_ancient_expr state token
  (* 数据结构关键字 *)
  | LeftArray | ChineseLeftArray | LeftBrace | RefKeyword | ModuleKeyword ->
      parse_data_structure_expr state token
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_compound_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析复合表达式（重构后） *)
let parse_compound_expressions state =
  let token, _ = current_token state in
  match token with
  | LeftParen | ChineseLeftParen | IfKeyword | MatchKeyword | FunKeyword | LetKeyword | TryKeyword
  | RaiseKeyword | CombineKeyword | IfWenyanKeyword | HaveKeyword | SetKeyword
  | AncientDefineKeyword | AncientObserveKeyword | AncientListStartKeyword
  | AncientRecordStartKeyword | AncientRecordEmptyKeyword | AncientRecordUpdateKeyword | LeftArray
  | ChineseLeftArray | LeftBrace | RefKeyword | ModuleKeyword ->
      Some (parse_compound_expr state)
  | _ -> None
