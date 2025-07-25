(** 骆言语法分析器函数调用表达式解析模块

    本模块专门处理函数调用相关的表达式解析，包括：
    - 函数参数解析（单个参数和参数列表）
    - 函数调用表达式解析
    - 后缀表达式解析（方法调用、字段访问、数组索引）
    - 函数调用与变量引用的区分逻辑

    此模块从 parser_expressions_primary_consolidated.ml 中提取而来，
    作为技术债务改进的一部分，用于模块化函数调用解析功能。

    技术债务改进：大型模块重构优化 Phase 2.3 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils
open Utils.Base_formatter

(** ==================== 函数参数解析 ==================== *)

(** 解析单个参数表达式的辅助函数 *)
let parse_single_argument parse_expr token current_state =
  match token with
  | QuotedIdentifierToken var_name ->
      let st1 = advance_parser current_state in
      (VarExpr var_name, st1)
  | IntToken i ->
      let st1 = advance_parser current_state in
      (LitExpr (IntLit i), st1)
  | ChineseNumberToken s ->
      let st1 = advance_parser current_state in
      let n = Parser_utils.chinese_number_to_int s in
      (LitExpr (IntLit n), st1)
  | FloatToken f ->
      let st1 = advance_parser current_state in
      (LitExpr (FloatLit f), st1)
  | StringToken s ->
      let st1 = advance_parser current_state in
      (LitExpr (StringLit s), st1)
  | TrueKeyword ->
      let st1 = advance_parser current_state in
      (LitExpr (BoolLit true), st1)
  | FalseKeyword ->
      let st1 = advance_parser current_state in
      (LitExpr (BoolLit false), st1)
  | OneKeyword ->
      let st1 = advance_parser current_state in
      (LitExpr (IntLit 1), st1)
  | LeftParen | ChineseLeftParen ->
      (* 使用完整表达式解析器来处理复杂的括号表达式（如嵌套函数调用） *)
      let st1 = advance_parser current_state in
      let inner_expr, st2 = parse_expr st1 in
      let st3 = expect_token_punctuation st2 is_right_paren "right parenthesis" in
      (inner_expr, st3)
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("Expected basic argument expr in function call, got: " ^ show_token token)
           (snd (current_token current_state)))

(** 递归收集参数的辅助函数 *)
let rec collect_function_arguments parse_expr args current_state =
  let token, _ = current_token current_state in
  if Parser_expressions_utils.is_argument_token token then
    let arg_expr, next_state = parse_single_argument parse_expr token current_state in
    collect_function_arguments parse_expr (arg_expr :: args) next_state
  else (List.rev args, current_state)

(** 解析函数参数列表 *)
let parse_function_arguments parse_expr state =
  collect_function_arguments parse_expr [] state

(** ==================== 函数调用表达式解析 ==================== *)

(** 决定是函数调用还是变量引用的辅助函数 *)
let parse_function_call_or_variable parse_expr name state =
  let next_token, _ = current_token state in
  if Parser_expressions_utils.is_argument_token next_token then
    (* 函数调用：收集参数 *)
    let args, final_state = parse_function_arguments parse_expr state in
    (FunCallExpr (VarExpr name, args), final_state)
  else
    (* 变量引用 *)
    (VarExpr name, state)


(** ==================== 辅助函数 ==================== *)

(** 检查是否为函数调用的参数token *)
let is_function_argument_token token =
  Parser_expressions_utils.is_argument_token token

(** 向后兼容性：解析基本参数表达式 - 委派给字面量解析模块 *)
let parse_basic_argument_expr state = 
  Parser_expressions_literals.parse_basic_argument_expr state

(** ==================== 辅助解析函数 ==================== *)

(** 解析函数调用相关的表达式 - 用于括号表达式中的函数调用处理 *)
let parse_function_call_context parse_expr name state =
  parse_function_call_or_variable parse_expr name state

(** 安全的函数调用解析 - 带错误处理 *)
let parse_function_call_safe parse_expr name state =
  try
    parse_function_call_or_variable parse_expr name state
  with
  | Parser_utils.SyntaxError _ as e -> raise e
  | exn ->
      let _, pos = current_token state in
      let error_msg = 
        Base_formatter.concat_strings ["函数调用解析失败: "; Printexc.to_string exn; " (函数名: "; name; ")"]
      in
      raise (Parser_utils.make_unexpected_token_error error_msg pos)

(** 安全的后缀表达式解析 - 带错误处理 *)
let parse_postfix_expr_safe parse_expr expr state =
  try
    parse_postfix_expr parse_expr expr state
  with
  | Parser_utils.SyntaxError _ as e -> raise e
  | exn ->
      let _, pos = current_token state in
      let error_msg = 
        Base_formatter.concat_strings ["后缀表达式解析失败: "; Printexc.to_string exn]
      in
      raise (Parser_utils.make_unexpected_token_error error_msg pos)