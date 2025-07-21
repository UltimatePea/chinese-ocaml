(** 类型关键字表达式解析模块接口 *)

open Ast
open Lexer
open Parser_utils

val type_keyword_to_string : token -> (string, Unified_errors.unified_error) result
(** 类型关键字到字符串的映射 *)

val parse_type_keyword_expressions :
  (string -> parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 解析类型关键字表达式（在表达式上下文中作为标识符处理） *)
