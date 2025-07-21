(** 骆言语法分析器表达式解析工具模块接口 *)

open Ast
open Lexer_tokens
open Parser_utils

val looks_like_string_literal : string -> bool
(** 检查标识符是否应该被视为字符串字面量 *)

val skip_newlines : parser_state -> parser_state
(** 跳过换行符辅助函数 *)

val create_binary_parser :
  binary_op list -> (parser_state -> expr * parser_state) -> parser_state -> expr * parser_state
(** 通用二元运算符解析器生成函数 *)

val create_unary_parser :
  ((parser_state -> expr * parser_state) -> parser_state -> expr * parser_state) ->
  (parser_state -> expr * parser_state) ->
  parser_state ->
  expr * parser_state
(** 通用一元运算符解析器生成函数 *)

val is_type_keyword : token -> bool
(** 检查是否为类型关键字 *)

val type_keyword_to_string : token -> (string, Unified_errors.unified_error) result
(** 类型关键字转字符串 *)

val parse_module_expression : parser_state -> expr * parser_state
(** 解析模块表达式 *)

val parse_natural_arithmetic_continuation : expr -> string -> parser_state -> expr * parser_state
(** 解析自然语言算术延续表达式 *)

val is_argument_token : token -> bool
(** 判断token是否可以作为函数参数的开始 *)
