(** 骆言语法分析器运算符和特殊表达式解析模块
    
    本模块从 parser_expressions_primary_consolidated.ml 中提取了
    运算符和特殊表达式的解析功能，包括：
    - 标签表达式（多态变体）
    - 括号表达式
    - 模块表达式
    - 诗词表达式
    - 古雅体表达式
    - 容器表达式（数组、记录、括号）
    - 特殊关键字表达式
    
    提取目的：
    1. 将基础表达式解析器中的运算符相关功能分离
    2. 简化 parser_expressions_primary_consolidated.ml 的复杂度
    3. 提高代码的模块化程度
    4. 便于维护和扩展运算符相关功能
    
    技术债务重构 - Issue #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

open Ast
open Lexer
open Parser_utils

(** ==================== 标签表达式解析 ==================== *)

(** 解析标签表达式（多态变体） *)
let parse_tag_expr parse_primary_expr state =
  (* 多态变体表达式: 标签 「标签名」 [值] *)
  let state1 = advance_parser state in
  let tag_name, state2 = parse_identifier state1 in
  let token, _ = current_token state2 in
  if is_identifier_like token then
    (* 有值的多态变体: 标签 「标签名」 值 *)
    let value_expr, state3 = parse_primary_expr state2 in
    (PolymorphicVariantExpr (tag_name, Some value_expr), state3)
  else
    (* 无值的多态变体: 标签 「标签名」 *)
    (PolymorphicVariantExpr (tag_name, None), state2)

(** ==================== 括号表达式解析 ==================== *)

(** 解析括号表达式 *)
let parse_parenthesized_expr parse_expr state =
  let state1 = advance_parser state in
  let token, _ = current_token state1 in
  if is_right_paren token then
    (* 处理单元字面量 () *)
    let state2 = advance_parser state1 in
    Parser_expressions_utils.parse_postfix_expr parse_expr (LitExpr UnitLit) state2
  else
    (* 处理括号表达式 (expr) *)
    let expr, state2 = parse_expr state1 in
    let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
    Parser_expressions_utils.parse_postfix_expr parse_expr expr state3

(** ==================== 模块表达式解析 ==================== *)

(** 解析模块表达式 *)
let parse_module_expr state = 
  (* 简单实现：假设模块表达式是一个标识符 *)
  let module_name, state1 = parse_identifier state in
  (VarExpr module_name, state1)

(** ==================== 诗词表达式解析 ==================== *)

(** 解析古典诗词表达式 *)
let parse_poetry_expr state =
  let token, _ = current_token state in
  match token with
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      Parser_poetry.parse_poetry_expression state
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_poetry_expr: " ^ show_token token)
           (snd (current_token state)))

(** ==================== 古雅体表达式解析 ==================== *)

(** 解析古雅体表达式 *)
let parse_ancient_expr parse_expr state =
  let token, _ = current_token state in
  match token with
  | AncientDefineKeyword -> Parser_ancient.parse_ancient_function_definition parse_expr state
  | AncientObserveKeyword ->
      Parser_ancient.parse_ancient_match_expression parse_expr Parser_patterns.parse_pattern
        state
  | AncientListStartKeyword -> Parser_ancient.parse_ancient_list_expression parse_expr state
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_ancient_expr: " ^ show_token token)
           (snd (current_token state)))

(** ==================== 容器表达式解析 ==================== *)

(** 解析容器表达式（数组、记录、括号） *)
let parse_container_exprs parse_expr parse_array_expr parse_record_expr state =
  let token, pos = current_token state in
  match token with
  (* 括号表达式 *)
  | LeftParen | ChineseLeftParen ->
      parse_parenthesized_expr parse_expr state
  (* 数组表达式 *)
  | LeftArray | ChineseLeftArray ->
      let array_expr, state1 = parse_array_expr state in
      Parser_expressions_utils.parse_postfix_expr parse_expr array_expr state1
  (* 记录表达式 *)
  | LeftBrace ->
      let record_expr, state1 = parse_record_expr state in
      Parser_expressions_utils.parse_postfix_expr parse_expr record_expr state1
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_container_exprs: 不支持的容器token " ^ show_token token)
           pos)

(** ==================== 特殊关键字表达式解析 ==================== *)

(** 解析特殊关键字表达式 *)
let parse_special_keyword_exprs parse_expr _parse_array_expr _parse_record_expr state =
  let token, pos = current_token state in
  match token with
  (* 标签表达式 - 需要特殊处理递归调用 *)
  | TagKeyword ->
      (* 暂时跳过标签表达式的递归调用，留待后续处理 *)
      raise (Parser_utils.make_unexpected_token_error "TagKeyword递归调用需要在主函数中处理" pos)
  (* 模块表达式 *)
  | ModuleKeyword -> parse_module_expr state
  (* 组合表达式 - 委派给结构化表达式模块 *)
  | CombineKeyword ->
      raise (Parser_utils.make_unexpected_token_error "CombineKeyword应由主表达式解析器处理" pos)
  (* 诗词表达式 *)
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword -> parse_poetry_expr state
  (* 古雅体表达式 *)
  | AncientDefineKeyword | AncientObserveKeyword | AncientListStartKeyword ->
      parse_ancient_expr parse_expr state
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_special_keyword_exprs: 不支持的特殊token " ^ show_token token)
           pos)

(** ==================== Token识别函数 ==================== *)

(** 匹配容器类型tokens *)
let is_container_token = function
  | LeftParen | ChineseLeftParen | LeftArray | ChineseLeftArray | LeftBrace -> true
  | _ -> false

(** 匹配特殊关键字tokens *)
let is_special_keyword_token = function
  | ModuleKeyword | CombineKeyword | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword
  | AncientDefineKeyword | AncientObserveKeyword | AncientListStartKeyword ->
      true
  | _ -> false