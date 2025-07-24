(** 骆言语法分析器标识符和函数调用解析模块
    
    本模块专门处理标识符表达式和函数调用的解析：
    - 带引号标识符解析
    - 特殊标识符处理
    - 复合标识符解析
    - 函数调用检测和参数收集
    - 变量引用处理
    
    技术债务重构 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

open Ast
open Lexer
open Parser_utils

(** 判断token是否为标识符类型 *)
let is_identifier_token = function
  | QuotedIdentifierToken _ | IdentifierTokenSpecial _ | NumberKeyword | EmptyKeyword | TypeKeyword
  | ThenKeyword | ElseKeyword | WithKeyword | WithOpKeyword | AsKeyword | WhenKeyword | TrueKeyword
  | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      true
  | _ -> false

(** 解析单个参数表达式的辅助函数 *)
let parse_single_argument parse_expression token current_state =
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
      let inner_expr, st2 = parse_expression st1 in
      let st3 = expect_token_punctuation st2 is_right_paren "right parenthesis" in
      (inner_expr, st3)
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("Expected basic argument expression in function call, got: " ^ show_token token)
           (snd (current_token current_state)))

(** 递归收集参数的辅助函数 *)
let rec collect_function_arguments parse_expression args current_state =
  let token, _ = current_token current_state in
  if Parser_expressions_utils.is_argument_token token then
    let arg_expr, next_state = parse_single_argument parse_expression token current_state in
    collect_function_arguments parse_expression (arg_expr :: args) next_state
  else (List.rev args, current_state)

(** 解析函数参数列表 *)
let parse_function_arguments parse_expression state =
  collect_function_arguments parse_expression [] state

(** 决定是函数调用还是变量引用的辅助函数 *)
let parse_function_call_or_variable parse_expression name state =
  let next_token, _ = current_token state in
  if Parser_expressions_utils.is_argument_token next_token then
    (* 函数调用：收集参数 *)
    let args, final_state = parse_function_arguments parse_expression state in
    (FunCallExpr (VarExpr name, args), final_state)
  else
    (* 变量引用 *)
    (VarExpr name, state)

(** 处理带引号的标识符 *)
let parse_quoted_identifier parse_expression name state =
  let state1 = advance_parser state in
  (* 检查是否看起来像字符串字面量而非变量名 *)
  if Parser_expressions_utils.looks_like_string_literal name then (LitExpr (StringLit name), state1)
  else parse_function_call_or_variable parse_expression name state1

(** 处理特殊标识符 *)
let parse_special_identifier parse_expression name state =
  let state1 = advance_parser state in
  parse_function_call_or_variable parse_expression name state1

(** 处理数值关键字复合标识符 *)
let parse_number_keyword_identifier parse_expression state =
  let name, state1 = parse_wenyan_compound_identifier state in
  parse_function_call_or_variable parse_expression name state1

(** 处理其他关键字复合标识符 *)
let parse_keyword_compound_identifier parse_expression state =
  let name, state1 = parse_identifier_allow_keywords state in
  parse_function_call_or_variable parse_expression name state1

(** 解析标识符表达式（变量引用和函数调用） *)
let parse_identifier_expr parse_expression state =
  let token, _ = current_token state in
  match token with
  | QuotedIdentifierToken name -> parse_quoted_identifier parse_expression name state
  | IdentifierTokenSpecial name -> parse_special_identifier parse_expression name state
  | NumberKeyword -> parse_number_keyword_identifier parse_expression state
  | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword | WithKeyword | WithOpKeyword | AsKeyword
  | WhenKeyword | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      parse_keyword_compound_identifier parse_expression state
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_identifier_expr: " ^ show_token token)
           (snd (current_token state)))

(** 向后兼容：解析函数调用或变量（使用基础参数解析器） *)
let parse_function_call_or_variable_basic name state =
  let next_token, _ = current_token state in
  if Parser_expressions_utils.is_argument_token next_token then
    let args, final_state = parse_function_arguments Parser_expressions_literals.parse_basic_literal_argument state in
    (FunCallExpr (VarExpr name, args), final_state)
  else (VarExpr name, state)