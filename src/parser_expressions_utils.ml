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

(** 解析函数调用参数列表的辅助函数 *)
let rec parse_argument_list parse_expr acc state =
  let token, _ = current_token state in
  if token = RightParen || token = ChineseRightParen then (acc, state)
  else
    let arg, state1 = parse_expr state in
    let new_acc = arg :: acc in
    let token1, _ = current_token state1 in
    if token1 = RightParen || token1 = ChineseRightParen then (new_acc, state1)
    else if token1 = Comma then
      (* 跳过逗号，继续解析下一个参数 *)
      let state2 = advance_parser state1 in
      parse_argument_list parse_expr new_acc state2
    else
      (* 其他情况，可能是错误或者结束 *)
      (new_acc, state1)

(** 解析后缀表达式（函数调用、字段访问、数组索引、模块访问等） *)
let rec parse_postfix_expr parse_expr expr state =
  let token, _ = current_token state in
  match token with
  (* 函数调用 *)
  | LeftParen | ChineseLeftParen ->
      let state1 = advance_parser state in
      let args, state2 = parse_argument_list parse_expr [] state1 in
      let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
      let new_expr = FunCallExpr (expr, List.rev args) in
      parse_postfix_expr parse_expr new_expr state3
  (* 字段访问 *)
  | Dot -> (
      let state1 = advance_parser state in
      let token2, _ = current_token state1 in
      match token2 with
      | QuotedIdentifierToken field_name ->
          let state2 = advance_parser state1 in
          (* 判断是模块访问还是字段访问 *)
          let new_expr =
            match expr with
            | VarExpr module_name
              when String.length module_name > 0
                   && Char.uppercase_ascii module_name.[0] = module_name.[0] ->
                (* 如果左侧是以大写字母开头的变量，视为模块访问 *)
                ModuleAccessExpr (expr, field_name)
            | _ ->
                (* 否则视为字段访问 *)
                FieldAccessExpr (expr, field_name)
          in
          parse_postfix_expr parse_expr new_expr state2
      | _ -> (expr, state))
  (* 数组索引 *)
  | LeftBracket | ChineseLeftBracket ->
      let state1 = advance_parser state in
      let index_expr, state2 = parse_expr state1 in
      let state3 = expect_token_punctuation state2 is_right_bracket "right bracket" in
      let new_expr = ArrayAccessExpr (expr, index_expr) in
      parse_postfix_expr parse_expr new_expr state3
  | _ -> (expr, state)
