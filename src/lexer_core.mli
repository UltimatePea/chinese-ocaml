(** 骆言词法分析器核心模块接口 *)

open Token_types

type lexer_state = {
  input : string;
  position : int;
  length : int;
  current_line : int;
  current_column : int;
  filename : string;
}
(** 词法分析器状态 *)

exception LexError of string * Token_types.position
(** 词法分析器异常 *)

val create_lexer_state : string -> string -> lexer_state
(** 创建词法分析器状态 *)

val current_char : lexer_state -> char option
(** 获取当前字符 *)

val advance : lexer_state -> lexer_state
(** 前进状态 *)

val skip_whitespace_and_comments : lexer_state -> lexer_state
(** 跳过空白字符和注释 *)

val read_string_literal : lexer_state -> token * lexer_state
(** 读取字符串字面量 *)

val read_quoted_identifier : lexer_state -> token * lexer_state
(** 读取引用标识符 *)

val read_number : lexer_state -> token * lexer_state
(** 读取数字 *)

val read_chinese_number : lexer_state -> token * lexer_state
(** 读取中文数字 *)

val recognize_chinese_punctuation :
  lexer_state -> position -> (token * position * lexer_state) option
(** 中文标点符号识别 *)

val next_token : lexer_state -> token * position * lexer_state
(** 主要的词法分析函数 *)

val tokenize : string -> string -> positioned_token list
(** 词法分析主函数 *)
