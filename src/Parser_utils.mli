(** 骆言语法分析器基础工具模块 - Chinese Programming Language Parser Utilities *)

open Ast
open Lexer

(** 解析器状态类型 *)
type parser_state = { 
  token_array : positioned_token array; 
  array_length : int; 
  current_pos : int 
}

(** 语法错误异常 *)
exception SyntaxError of string * position

(** 基础解析器状态操作 *)

(** 创建解析状态 *)
val create_parser_state : positioned_token list -> parser_state

(** 获取当前词元 *)
val current_token : parser_state -> positioned_token

(** 查看下一个词元（不消费） *)
val peek_token : parser_state -> positioned_token

(** 向前移动 *)
val advance_parser : parser_state -> parser_state

(** 期望特定词元 *)
val expect_token : parser_state -> token -> parser_state

(** 检查是否为特定词元 *)
val is_token : parser_state -> token -> bool

(** 标识符解析 *)

(** 解析标识符（严格引用模式）*)
val parse_identifier : parser_state -> string * parser_state

(** 解析标识符（允许关键字）*)
val parse_identifier_allow_keywords : parser_state -> string * parser_state

(** 解析wenyan风格的复合标识符 *)
val parse_wenyan_compound_identifier : parser_state -> string * parser_state

(** 中文标点符号辅助函数 *)

(** 检查右括号 *)
val is_right_paren : token -> bool

(** 检查左方括号 *)
val is_left_bracket : token -> bool

(** 检查右方括号 *)
val is_right_bracket : token -> bool

(** 检查左大括号 *)
val is_left_brace : token -> bool

(** 检查分号 *)
val is_semicolon : token -> bool

(** 检查冒号 *)
val is_colon : token -> bool

(** 检查双冒号 *)
val is_double_colon : token -> bool

(** 检查管道符号 *)
val is_pipe : token -> bool

(** 检查箭头 *)
val is_arrow : token -> bool

(** 检查左数组括号 *)
val is_left_array : token -> bool

(** Token分类辅助函数 *)

(** 检查是否是标识符类型的token *)
val is_identifier_like : token -> bool

(** 检查是否是字面量token *)
val is_literal_token : token -> bool

(** 检查是否是类型注解的双冒号 *)
val is_type_colon : token -> bool

(** 检查当前token是否为指定的标点符号 *)
val is_punctuation : parser_state -> (token -> bool) -> bool

(** 期望指定的标点符号 *)
val expect_token_punctuation : parser_state -> (token -> bool) -> string -> parser_state

(** 数字和字面量解析 *)

(** 中文数字转换为整数 *)
val chinese_digit_to_int : string -> int

(** 将中文数字字符串转换为整数 *)
val chinese_number_to_int : string -> int

(** 解析字面量 *)
val parse_literal : parser_state -> literal * parser_state

(** 运算符解析 *)

(** 将token转换为二元运算符 *)
val token_to_binary_op : token -> binary_op option