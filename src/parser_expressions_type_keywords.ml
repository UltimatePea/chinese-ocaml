(** 类型关键字表达式解析模块 *)

open Lexer
open Parser_utils

(** 类型关键字到字符串的映射 *)
let type_keyword_to_string = function
  | IntTypeKeyword -> "整数"
  | FloatTypeKeyword -> "浮点数"
  | StringTypeKeyword -> "字符串"
  | BoolTypeKeyword -> "布尔"
  | UnitTypeKeyword -> "单元"
  | ListTypeKeyword -> "列表"
  | ArrayTypeKeyword -> "数组"
  | _ -> failwith "类型错误：不是类型关键字标记"

(** 解析类型关键字表达式（在表达式上下文中作为标识符处理） *)
let parse_type_keyword_expressions parse_function_call_or_variable state =
  let token, _ = current_token state in
  let type_name = type_keyword_to_string token in
  let state1 = advance_parser state in
  parse_function_call_or_variable type_name state1
