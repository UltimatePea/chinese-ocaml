(** 骆言编译器Unicode字符处理常量模块接口 *)

type utf8_triple = { byte1 : int; byte2 : int; byte3 : int }
(** UTF-8字符三字节组合类型 *)

type utf8_char_def = {
  name : string;  (** 字符名称 *)
  char : string;  (** 实际字符 *)
  triple : utf8_triple;  (** UTF-8字节组合 *)
  category : string;  (** 字符类别 *)
}
(** UTF-8字符定义记录 *)

(** 中文字符范围检测常量 *)
module Range : sig
  val chinese_char_start : int
  val chinese_char_mid_start : int
  val chinese_char_mid_end : int
  val chinese_char_threshold : int
end

(** UTF-8字符前缀常量 *)
module Prefix : sig
  val chinese_punctuation : int
  val chinese_operator : int
  val arrow_symbol : int
  val fullwidth : int
end

val char_definitions : utf8_char_def list
(** 字符定义数据表 *)

(** 字符查找映射表 *)
module CharMap : sig
  val name_to_char_map : (string * string) list
  val name_to_triple_map : (string * utf8_triple) list
  val char_to_triple_map : (string * utf8_triple) list
end

(** 全角数字范围处理 *)
module FullwidthDigit : sig
  val start_byte3 : int
  val end_byte3 : int
  val is_fullwidth_digit : int -> bool
end

(** 便捷字符常量 *)
module CharConstants : sig
  val char_xe3 : char
  val char_x80 : char
  val char_x8e : char
  val char_x8f : char
  val char_xef : char
  val char_xbc : char
  val char_xbd : char
  val char_x9c : char
  val char_xe8 : char
  val char_xb4 : char
  val char_x9f : char
  val char_xe2 : char
end

(** 便捷检查函数 *)
module Checks : sig
  val is_chinese_punctuation_prefix : int -> bool
  val is_chinese_operator_prefix : int -> bool
  val is_arrow_symbol_prefix : int -> bool
  val is_fullwidth_prefix : int -> bool
end

(** 向后兼容性函数 *)
module Legacy : sig
  val get_char_bytes : string -> int * int * int
  val get_chars_by_category : string -> string list
  val is_char_category : string -> string -> bool
end

(** 向后兼容性别名 *)
module Compatibility : sig
  val chinese_char_start : int
  val chinese_char_mid_start : int
  val chinese_char_mid_end : int
  val chinese_char_threshold : int
  val chinese_punctuation_prefix : int
  val chinese_operator_prefix : int
  val arrow_symbol_prefix : int
  val fullwidth_prefix : int
  val left_quote_byte1 : int
  val left_quote_byte2 : int
  val left_quote_byte3 : int
  val right_quote_byte1 : int
  val right_quote_byte2 : int
  val right_quote_byte3 : int
  val string_start_byte1 : int
  val string_start_byte2 : int
  val string_start_byte3 : int
  val string_end_byte1 : int
  val string_end_byte2 : int
  val string_end_byte3 : int
  val fullwidth_start_byte1 : int
  val fullwidth_start_byte2 : int
  val fullwidth_left_paren_byte3 : int
  val fullwidth_right_paren_byte3 : int
  val fullwidth_comma_byte3 : int
  val fullwidth_colon_byte3 : int
  val fullwidth_semicolon_byte3 : int
  val fullwidth_pipe_byte1 : int
  val fullwidth_pipe_byte2 : int
  val fullwidth_pipe_byte3 : int
  val fullwidth_period_byte3 : int
  val comment_colon_byte1 : int
  val comment_colon_byte2 : int
  val comment_colon_byte3 : int
  val fullwidth_digit_start : int
  val fullwidth_digit_end : int
  val chinese_period_byte1 : int
  val chinese_period_byte2 : int
  val chinese_period_byte3 : int
  val chinese_minus_byte1 : int
  val chinese_minus_byte2 : int
  val chinese_minus_byte3 : int
  val chinese_square_left_bracket_byte1 : int
  val chinese_square_left_bracket_byte2 : int
  val chinese_square_left_bracket_byte3 : int
  val chinese_square_right_bracket_byte1 : int
  val chinese_square_right_bracket_byte2 : int
  val chinese_square_right_bracket_byte3 : int
  val chinese_arrow_byte1 : int
  val chinese_arrow_byte2 : int
  val chinese_arrow_byte3 : int
  val chinese_double_arrow_byte1 : int
  val chinese_double_arrow_byte2 : int
  val chinese_double_arrow_byte3 : int
  val chinese_assign_arrow_byte1 : int
  val chinese_assign_arrow_byte2 : int
  val chinese_assign_arrow_byte3 : int
  val char_xe3 : char
  val char_x80 : char
  val char_x8e : char
  val char_x8f : char
  val char_xef : char
  val char_xbc : char
  val char_xbd : char
  val char_x9c : char
  val char_xe8 : char
  val char_xb4 : char
  val char_x9f : char
  val char_xe2 : char
  val is_chinese_punctuation_prefix : int -> bool
  val is_chinese_operator_prefix : int -> bool
  val is_arrow_symbol_prefix : int -> bool
  val is_fullwidth_prefix : int -> bool
end
