(** 骆言语法分析器关键字表达式处理模块
    
    本模块专门处理各种关键字表达式的解析，包括标识符、类型关键字、特殊关键字等。
    从parser_expressions_primary.ml中拆分出来，提高代码的模块化程度。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #644 重构 *)

open Ast
open Lexer
open Parser_utils
open Parser_expressions_utils
open Parser_expressions_identifiers

(** 解析标识符表达式 *)
let parse_identifier_expr state =
  let token, _ = current_token state in
  match token with
  | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      (* Check if this looks like a string literal rather than a variable name *)
      if looks_like_string_literal name then (LitExpr (StringLit name), state1)
      (* According to Issue #176: ALL quoted identifiers should be treated as identifiers, not as numbers *)
        else parse_function_call_or_variable name state1
  | NumberKeyword ->
      (* 尝试解析wenyan复合标识符，如"数值" *)
      let name, state1 = parse_wenyan_compound_identifier state in
      parse_function_call_or_variable name state1
  | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword | WithKeyword | TrueKeyword
  | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      (* Handle keywords that might be part of compound identifiers *)
      let name, state1 = parse_identifier_allow_keywords state in
      parse_function_call_or_variable name state1
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_identifier_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析类型关键字表达式 *)
let parse_type_keyword_expr state =
  let token, _ = current_token state in
  match token with
  | IntTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "整数" state1
  | FloatTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "浮点数" state1
  | StringTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "字符串" state1
  | BoolTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "布尔" state1
  | UnitTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "单元" state1
  | ListTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "列表" state1
  | ArrayTypeKeyword ->
      let state1 = advance_parser state in
      parse_function_call_or_variable "数组" state1
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_type_keyword_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析特殊关键字表达式 *)
let parse_special_keyword_expr state =
  let token, pos = current_token state in
  match token with
  | TagKeyword ->
      (* 多态变体表达式: 标签 「标签名」 [值] *)
      let state1 = advance_parser state in
      let tag_name, state2 = parse_identifier state1 in
      let token, _ = current_token state2 in
      if is_identifier_like token then
        (* 有值的多态变体: 标签 「标签名」 值 *)
        let value_expr, state3 = Parser_expressions.parse_expression state2 in
        (PolymorphicVariantExpr (tag_name, Some value_expr), state3)
      else
        (* 无值的多态变体: 标签 「标签名」 *)
        (PolymorphicVariantExpr (tag_name, None), state2)
  | DefineKeyword ->
      (* 调用主解析器中的自然语言函数定义解析 *)
      raise (Types.ParseError ("DefineKeyword应由主解析器处理", pos.line, pos.column))
  | LeftBracket | ChineseLeftBracket ->
      (* 禁用现代列表语法，提示使用古雅体语法 *)
      raise
        (SyntaxError
           ( "请使用古雅体列表语法替代 [...]。\n" ^ "空列表：空空如也\n" ^ "有元素的列表：列开始 元素1 其一 元素2 其二 元素3 其三 列结束\n"
             ^ "模式匹配：有首有尾 首名为「变量名」尾名为「尾部变量名」",
             snd (current_token state) ))
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_special_keyword_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析关键字表达式（重构后） *)
let parse_keyword_expressions state =
  let token, _ = current_token state in
  match token with
  | TagKeyword | DefineKeyword | LeftBracket | ChineseLeftBracket ->
      Some (parse_special_keyword_expr state)
  | QuotedIdentifierToken _ | NumberKeyword | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword
  | WithKeyword | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      Some (parse_identifier_expr state)
  | _ -> None

(** 解析类型关键字表达式（重构后） *)
let parse_type_keyword_expressions state =
  let token, _ = current_token state in
  match token with
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword | UnitTypeKeyword
  | ListTypeKeyword | ArrayTypeKeyword ->
      Some (parse_type_keyword_expr state)
  | _ -> None