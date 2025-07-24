(** 骆言语法分析器表达式解析工具模块 - Parser Expression Utilities *)

open Ast
open Lexer_tokens
open Parser_utils
open Utf8_utils.StringUtils
open Unified_errors

(** 检查标识符是否应该被视为字符串字面量 *)
let looks_like_string_literal name =
  (* 如果标识符包含空格或者看起来像自然语言短语，则视为字符串字面量 *)
  String.contains name ' ' || String.contains name ',' || String.contains name '.'
  || String.contains name '?' || String.contains name '!'
  || utf8_length name > 20
     && (not (String.contains name '_'))
     && not (Str.string_match (Str.regexp "^[a-zA-Z0-9_]+$") name 0)

(** 跳过换行符辅助函数 *)
let rec skip_newlines state =
  let token, _pos = current_token state in
  if token = Newline then skip_newlines (advance_parser state) else state

(** 通用二元运算符解析器生成函数 *)
let create_binary_parser allowed_ops next_level_parser =
  let rec parse_tail left_expr state =
    let token, _ = current_token state in
    match Parser_utils.token_to_binary_op token with
    | Some op when List.mem op allowed_ops ->
        let state1 = advance_parser state in
        let right_expr, state2 = next_level_parser state1 in
        let new_expr = BinaryOpExpr (left_expr, op, right_expr) in
        parse_tail new_expr state2
    | _ -> (left_expr, state)
  in
  fun state ->
    let expr, state1 = next_level_parser state in
    parse_tail expr state1

(** 检查是否为类型关键字 *)
let is_type_keyword token =
  match token with
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword | ListTypeKeyword
  | UnitTypeKeyword ->
      true
  | _ -> false

(** 类型关键字转字符串 *)
let type_keyword_to_string token =
  match token with
  | IntTypeKeyword -> Ok "int"
  | FloatTypeKeyword -> Ok "float"
  | StringTypeKeyword -> Ok "string"
  | BoolTypeKeyword -> Ok "bool"
  | ListTypeKeyword -> Ok "list"
  | UnitTypeKeyword -> Ok "unit"
  | _ -> Error (invalid_type_keyword_error "不是类型关键字")

(** 解析模块表达式 *)
let parse_module_expr state =
  (* 简单实现：假设模块表达式是一个标识符 *)
  let module_name, state1 = parse_identifier state in
  (VarExpr module_name, state1)

(** 解析模块表达式 - 接口要求的版本 *)
let parse_module_expression state = parse_module_expr state

(** 通用一元运算符解析器 - 减少代码重复 *)
let create_unary_parser primary_parser =
  let rec parse_unary_expr parse_expr state =
    let token, _pos = current_token state in
    match token with
    | Minus ->
        let state1 = advance_parser state in
        let expr, state2 = parse_unary_expr parse_expr state1 in
        (UnaryOpExpr (Neg, expr), state2)
    | NotKeyword ->
        let state1 = advance_parser state in
        let expr, state2 = parse_unary_expr parse_expr state1 in
        (UnaryOpExpr (Not, expr), state2)
    | Bang ->
        let state1 = advance_parser state in
        let expr, state2 = parse_unary_expr parse_expr state1 in
        (DerefExpr expr, state2)
    | _ -> primary_parser parse_expr state
  in
  parse_unary_expr

(** 解析自然语言算术延续表达式 *)
let parse_natural_arithmetic_continuation expr _param_name state =
  let token_after, _ = current_token state in
  match token_after with
  | OfParticle ->
      (* 「减一」之「阶乘」 *)
      let state1 = advance_parser state in
      let func_name, state2 = parse_identifier state1 in
      (FunCallExpr (VarExpr func_name, [ expr ]), state2)
  | _ -> (expr, state)

(** 判断token是否可以作为函数参数的开始 *)
let is_argument_token token =
  match token with
  | QuotedIdentifierToken _ | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _
  | TrueKeyword | FalseKeyword | LeftBracket | LeftBrace | IfKeyword | FunKeyword | LetKeyword
  | MatchKeyword | TryKeyword | RaiseKeyword | RefKeyword | OneKeyword ->
      true
  | _ -> false
