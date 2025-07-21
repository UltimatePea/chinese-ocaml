(** 类型关键字表达式解析模块 *)

open Lexer
open Parser_utils
open Unified_errors

(** 类型关键字到字符串的映射 *)
let type_keyword_to_string = function
  | IntTypeKeyword -> Ok "整数"
  | FloatTypeKeyword -> Ok "浮点数"
  | StringTypeKeyword -> Ok "字符串"
  | BoolTypeKeyword -> Ok "布尔"
  | UnitTypeKeyword -> Ok "单元"
  | ListTypeKeyword -> Ok "列表"
  | ArrayTypeKeyword -> Ok "数组"
  | _ -> Error (invalid_type_keyword_error "不是类型关键字标记")

(** 解析类型关键字表达式（在表达式上下文中作为标识符处理） *)
let parse_type_keyword_expressions parse_function_call_or_variable state =
  let token, _ = current_token state in
  match type_keyword_to_string token with
  | Ok type_name ->
      let state1 = advance_parser state in
      parse_function_call_or_variable type_name state1
  | Error _ ->
      (* This should not happen in normal parsing, but we handle it gracefully *)
      let state1 = advance_parser state in
      parse_function_call_or_variable "unknown" state1
