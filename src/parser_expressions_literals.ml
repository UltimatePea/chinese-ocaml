(** 骆言语法分析器字面量表达式解析模块
    
    本模块专门处理各种字面量表达式的解析：
    - 整数字面量（包括中文数字）
    - 浮点数字面量
    - 字符串字面量
    - 布尔值字面量
    - 特殊字面量（如"一"关键字）
    
    技术债务重构 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

open Ast
open Lexer
open Parser_utils

(** 判断token是否为字面量类型 *)
let is_literal_token = function
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ | BoolToken _ | TrueKeyword
  | FalseKeyword | OneKeyword ->
      true
  | _ -> false

(** 解析字面量表达式（整数、浮点数、字符串、布尔值） *)
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
          (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
          (VarExpr name, state1)
      | _ ->
          (* 解析为布尔字面量 *)
          let literal, state1 = parse_literal state in
          (LitExpr literal, state1))
  | TrueKeyword ->
      (* 直接处理TrueKeyword *)
      let state1 = advance_parser state in
      (LitExpr (BoolLit true), state1)
  | FalseKeyword ->
      (* 直接处理FalseKeyword *)
      let state1 = advance_parser state in
      (LitExpr (BoolLit false), state1)
  | OneKeyword ->
      (* 将"一"关键字转换为数字字面量1 *)
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_literal_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析单个字面量参数（用于函数参数解析） *)
let parse_literal_argument token state =
  match token with
  | IntToken i ->
      let st1 = advance_parser state in
      (LitExpr (IntLit i), st1)
  | ChineseNumberToken s ->
      let st1 = advance_parser state in
      let n = Parser_utils.chinese_number_to_int s in
      (LitExpr (IntLit n), st1)
  | FloatToken f ->
      let st1 = advance_parser state in
      (LitExpr (FloatLit f), st1)
  | StringToken s ->
      let st1 = advance_parser state in
      (LitExpr (StringLit s), st1)
  | TrueKeyword ->
      let st1 = advance_parser state in
      (LitExpr (BoolLit true), st1)
  | FalseKeyword ->
      let st1 = advance_parser state in
      (LitExpr (BoolLit false), st1)
  | OneKeyword ->
      let st1 = advance_parser state in
      (LitExpr (IntLit 1), st1)
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("Expected literal argument, got: " ^ show_token token)
           (snd (current_token state)))

(** 解析基础字面量参数表达式（用于向后兼容） *)
let parse_basic_literal_argument state =
  let token, pos = current_token state in
  let advance_and_return expr st = (expr, advance_parser st) in

  match token with
  | IntToken i -> advance_and_return (LitExpr (IntLit i)) state
  | ChineseNumberToken s ->
      let n = Parser_utils.chinese_number_to_int s in
      advance_and_return (LitExpr (IntLit n)) state
  | FloatToken f -> advance_and_return (LitExpr (FloatLit f)) state
  | StringToken s -> advance_and_return (LitExpr (StringLit s)) state
  | TrueKeyword -> advance_and_return (LitExpr (BoolLit true)) state
  | FalseKeyword -> advance_and_return (LitExpr (BoolLit false)) state
  | OneKeyword -> advance_and_return (LitExpr (IntLit 1)) state
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("Expected basic literal argument expression, got: " ^ show_token token)
           pos)