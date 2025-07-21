(** 骆言词法分析器 - 中文数字处理模块接口 *)

(** 中文数字转换器模块 *)
module ChineseNumberConverter : sig
  val char_to_digit : string -> int
  val char_to_unit : string -> int
  val utf8_to_char_list : string -> int -> string list -> string list
  val parse_with_units : string list -> int -> int -> int
  val parse_simple_digits : string list -> int -> int
  val parse_chinese_number : string list -> int
  val construct_float_value : int -> int -> int -> float
end

val read_chinese_number_sequence : Lexer_state.lexer_state -> string * Lexer_state.lexer_state
(** 读取中文数字序列 *)

val convert_chinese_number_sequence : string -> Lexer_tokens.token
(** 转换中文数字序列为数值 *)
