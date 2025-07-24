(** 骆言语法分析器标识符表达式解析模块

    本模块专门处理各种类型标识符表达式的解析，包括：
    - 普通标识符表达式（变量引用和函数调用）
    - 带引号的标识符
    - 特殊标识符
    - 数值关键字复合标识符
    - 其他关键字复合标识符
    - 类型关键字表达式

    此模块从 parser_expressions_primary_consolidated.ml 中提取而来，
    作为技术债务改进的一部分，用于优化代码组织结构。

    技术债务改进：大型模块重构优化 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

open Ast
open Lexer
open Parser_utils

(** ==================== 核心解析辅助函数 ==================== *)

(** 统一的错误处理辅助函数 *)
let raise_parse_error expr_type token exn state =
  let error_msg =
    Unified_formatter.ErrorHandling.parse_failure_with_token expr_type (show_token token)
      (Printexc.to_string exn)
  in
  let _, pos = current_token state in
  raise (Parser_utils.make_unexpected_token_error error_msg pos)

(** ==================== 函数参数解析辅助函数 ==================== *)

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

(** ==================== 标识符表达式解析函数 ==================== *)

(** 处理带引号的标识符 *)
let parse_quoted_identifier parse_expr name state =
  let state1 = advance_parser state in
  (* 检查是否看起来像字符串字面量而非变量名 *)
  if Parser_expressions_utils.looks_like_string_literal name then (LitExpr (StringLit name), state1)
  else parse_function_call_or_variable parse_expr name state1

(** 处理特殊标识符 *)
let parse_special_identifier parse_expr name state =
  let state1 = advance_parser state in
  parse_function_call_or_variable parse_expr name state1

(** 处理数值关键字复合标识符 *)
let parse_number_keyword_identifier parse_expr state =
  let name, state1 = parse_wenyan_compound_identifier state in
  parse_function_call_or_variable parse_expr name state1

(** 处理其他关键字复合标识符 *)
let parse_keyword_compound_identifier parse_expr state =
  let name, state1 = parse_identifier_allow_keywords state in
  parse_function_call_or_variable parse_expr name state1

(** 解析标识符表达式（变量引用和函数调用）- 重构版本 *)
let parse_identifier_expr parse_expr state =
  let token, _ = current_token state in
  match token with
  | QuotedIdentifierToken name -> parse_quoted_identifier parse_expr name state
  | IdentifierTokenSpecial name -> parse_special_identifier parse_expr name state
  | NumberKeyword -> parse_number_keyword_identifier parse_expr state
  | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword | WithKeyword | WithOpKeyword | AsKeyword
  | WhenKeyword | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      parse_keyword_compound_identifier parse_expr state
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_identifier_expr: " ^ show_token token)
           (snd (current_token state)))

(** ==================== 类型关键字表达式解析 ==================== *)

(** 解析类型关键字表达式 *)
let parse_type_keyword_expr state =
  let token, _ = current_token state in
  match token with
  | IntTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
      (VarExpr "整数", state1)
  | FloatTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
      (VarExpr "浮点数", state1)
  | StringTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
      (VarExpr "字符串", state1)
  | BoolTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
      (VarExpr "布尔值", state1)
  | ListTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
      (VarExpr "列表", state1)
  | ArrayTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
      (VarExpr "数组", state1)
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_type_keyword_expr: " ^ show_token token)
           (snd (current_token state)))

(** ==================== 辅助解析函数 ==================== *)

(** 解析标识符表达式辅助函数 *)
let parse_identifier_exprs parse_expr state =
  parse_identifier_expr parse_expr state

(** 解析类型关键字表达式辅助函数 *)
let parse_type_keyword_exprs state = parse_type_keyword_expr state

(** ==================== 标识符和类型关键字token检查函数 ==================== *)

(** 匹配标识符类型tokens *)
let is_identifier_token = function
  | QuotedIdentifierToken _ | IdentifierTokenSpecial _ | NumberKeyword | EmptyKeyword | TypeKeyword
  | ThenKeyword | ElseKeyword | WithKeyword | WithOpKeyword | AsKeyword | WhenKeyword | TrueKeyword
  | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      true
  | _ -> false

(** 匹配类型关键字tokens *)
let is_type_keyword_token = function
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword | ListTypeKeyword
  | ArrayTypeKeyword ->
      true
  | _ -> false

(** ==================== 安全解析函数 ==================== *)

(** 解析单个表达式类型 - 标识符 *)
let parse_identifier_expr_safe parse_expr token state =
  try parse_identifier_exprs parse_expr state
  with exn -> raise_parse_error "标识符表达式" token exn state

(** 解析单个表达式类型 - 类型关键字 *)
let parse_type_keyword_expr_safe token state =
  try parse_type_keyword_exprs state
  with exn -> raise_parse_error "类型关键字表达式" token exn state