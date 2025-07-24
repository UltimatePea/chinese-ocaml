(** 骆言语法分析器字面量解析专用模块
    
    从parser_expressions_primary_consolidated.ml中提取字面量解析功能
    目标：提高代码可维护性，减少大型模块复杂度
    
    技术债务重构 - Fix #1034 Phase 1
    @author 骆言AI代理
    @version 1.0 (分离版)
    @since 2025-07-24 *)

open Ast
open Lexer
open Parser_utils

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

(** 检查token是否为字面量token *)
let is_literal_token = function
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ 
  | BoolToken _ | TrueKeyword | FalseKeyword | OneKeyword -> true
  | _ -> false

(** 获取字面量类型描述（用于错误消息） *)
let get_literal_type_name = function
  | IntToken _ | ChineseNumberToken _ -> "整数"
  | FloatToken _ -> "浮点数" 
  | StringToken _ -> "字符串"
  | BoolToken _ | TrueKeyword | FalseKeyword -> "布尔值"
  | OneKeyword -> "数字关键字"
  | _ -> "未知字面量"