(** Unicode字符字节访问器模块接口

    提供各个字节位的便捷访问函数，简化字符字节的获取操作。 *)

(** 三元组字节访问器助手函数 *)

val get_byte1 : int * int * int -> int
(** 获取三元组的第一个字节 *)

val get_byte2 : int * int * int -> int
(** 获取三元组的第二个字节 *)

val get_byte3 : int * int * int -> int
(** 获取三元组的第三个字节 *)

(** 引号字符字节访问器模块 *)
module Quote : sig
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
end

(** 中文标点符号字节访问器模块 *)
module ChinesePunctuation : sig
  val chinese_left_paren_byte1 : int
  val chinese_left_paren_byte2 : int
  val chinese_left_paren_byte3 : int
  val chinese_right_paren_byte1 : int
  val chinese_right_paren_byte2 : int
  val chinese_right_paren_byte3 : int
  val chinese_comma_byte1 : int
  val chinese_comma_byte2 : int
  val chinese_comma_byte3 : int
  val chinese_colon_byte1 : int
  val chinese_colon_byte2 : int
  val chinese_colon_byte3 : int
  val chinese_period_byte1 : int
  val chinese_period_byte2 : int
  val chinese_period_byte3 : int
end

(** 全角字符字节访问器模块 *)
module Fullwidth : sig
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
end

(** 其他中文符号字节访问器模块 *)
module OtherSymbols : sig
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
end
