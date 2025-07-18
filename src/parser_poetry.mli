(** 骆言古典诗词解析器接口 - Chinese Classical Poetry Parser Interface *)

open Ast
open Parser_utils

exception PoetryParseError of string
(** 诗词解析相关异常 *)

val count_chinese_chars : string -> int
(** 中文字符计数函数 - 准确计算中文字符数（忽略标点符号和空格） *)

val validate_char_count : int -> string -> unit
(** 验证字符数是否符合诗词格式要求 *)

val parse_four_char_parallel : parser_state -> expr * parser_state
(** 解析四言骈体 - 四字节拍的骈体文 *)

val parse_five_char_verse : parser_state -> expr * parser_state
(** 解析五言律诗 - 五字节拍的律诗结构 *)

val parse_seven_char_quatrain : parser_state -> expr * parser_state
(** 解析七言绝句 - 七字节拍的绝句结构 *)

val parse_parallel_structure : parser_state -> expr * parser_state
(** 解析对偶结构 - 支持对偶结构的语法分析 *)

val parse_poetry_expression : parser_state -> expr * parser_state
(** 主要诗词解析入口函数 *)
