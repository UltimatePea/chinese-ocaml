(** 骆言语法分析器基础表达式解析模块 - Primary Expression Parser (重构后)
    
    本模块经过重构，将原有的407行代码拆分为多个专门的子模块，显著提升了代码的可维护性。
    现在主要作为各子模块的协调中心，保持API向后兼容性。
    
    重构说明：
    - 标识符和函数调用 → parser_expressions_identifiers.ml
    - 关键字表达式 → parser_expressions_keywords_primary.ml
    - 复合表达式 → parser_expressions_compound_primary.ml
    - 字面量表达式 → parser_expressions_literals_primary.ml
    - 诗词表达式 → parser_expressions_poetry_primary.ml
    
    @author 骆言技术债务清理团队
    @version 2.0 (重构版)
    @since 2025-07-20 Issue #644 重构 *)

open Ast
open Lexer
open Parser_utils

(* 导入所有子模块 *)
open Parser_expressions_keywords_primary
open Parser_expressions_compound_primary
open Parser_expressions_literals_primary
open Parser_expressions_poetry_primary

(** 解析后缀表达式（字段访问等） - 保留在主模块中作为公共功能 *)
let rec parse_postfix_expr expr state =
  let token, _ = current_token state in
  match token with
  | Dot -> (
      let state1 = advance_parser state in
      let token2, _ = current_token state1 in
      match token2 with
      | QuotedIdentifierToken field_name ->
          let state2 = advance_parser state1 in
          let new_expr = FieldAccessExpr (expr, field_name) in
          parse_postfix_expr new_expr state2
      | _ -> (expr, state))
  | LeftBracket | ChineseLeftBracket ->
      (* 数组索引 *)
      let state1 = advance_parser state in
      let index_expr, state2 = Parser_expressions.parse_expression state1 in
      let state3 = expect_token_punctuation state2 is_right_bracket "right bracket" in
      let new_expr = ArrayAccessExpr (expr, index_expr) in
      parse_postfix_expr new_expr state3
  | _ -> (expr, state)

(** 解析基础表达式（重构后的主函数） - 协调各子模块 *)
and parse_primary_expr state =
  let token, pos = current_token state in
  (* 按优先级尝试各种表达式类型，使用子模块的功能 *)
  match parse_literal_expressions state with
  | Some result -> result
  | None -> (
      match parse_type_keyword_expressions state with
      | Some result -> result
      | None -> (
          match parse_keyword_expressions state with
          | Some result -> result
          | None -> (
              match parse_compound_expressions state with
              | Some result -> result
              | None -> (
                  match parse_poetry_expressions state with
                  | Some result -> result
                  | None -> raise (Parser_utils.make_unexpected_token_error (show_token token) pos))
              )))

(* 重新导出主要的公共接口，保持向后兼容性 *)

(** 解析函数调用或变量 - 直接委托给子模块 *)
let parse_function_call_or_variable name state =
  Parser_expressions_identifiers.parse_function_call_or_variable name state