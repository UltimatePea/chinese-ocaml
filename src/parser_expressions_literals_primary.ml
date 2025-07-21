(** 骆言语法分析器字面量表达式处理模块（Primary层）

    本模块专门处理字面量表达式的解析，包括整数、浮点数、字符串、布尔值等。 从parser_expressions_primary.ml中拆分出来，专注于字面量相关的解析功能。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #644 重构 *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_identifiers

(** 解析字面量表达式 *)
let parse_literal_expr state =
  let token, _ = current_token state in
  match token with
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ ->
      let literal, state1 = parse_literal state in
      (LitExpr literal, state1)
  | BoolToken _ -> (
      (* 检查是否是复合标识符的开始（如"真值"、"假值"） *)
      let token_after, _ = peek_token state in
      match token_after with
      | QuotedIdentifierToken _ ->
          (* 可能是复合标识符，使用parse_identifier_allow_keywords解析 *)
          let name, state1 = parse_identifier_allow_keywords state in
          parse_function_call_or_variable name state1
      | _ ->
          (* 解析为布尔字面量 *)
          let literal, state1 = parse_literal state in
          (LitExpr literal, state1))
  | OneKeyword ->
      (* 将"一"关键字转换为数字字面量1 *)
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_literal_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析字面量表达式（重构后） *)
let parse_literal_expressions state =
  let token, _ = current_token state in
  match token with
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ | BoolToken _ | OneKeyword ->
      Some (parse_literal_expr state)
  | _ -> None
