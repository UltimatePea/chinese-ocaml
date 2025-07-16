(** 骆言词法分析器UTF-8字符处理工具模块接口 *)

(** 基础字符检测函数 *)
val is_chinese_char : char -> bool
val is_letter_or_chinese : char -> bool  
val is_digit : char -> bool
val is_whitespace : char -> bool
val is_separator_char : char -> bool

(** UTF-8字符序列检测 *)
val check_utf8_char : string -> int -> int -> int -> int -> bool
val is_chinese_utf8 : string -> bool
val next_utf8_char : string -> int -> (string * int) option
val is_chinese_digit_char : string -> bool

(** 中文标点符号检测模块 *)
module ChinesePunctuation : sig
  val is_left_quote : string -> int -> bool
  val is_right_quote : string -> int -> bool
  val is_string_start : string -> int -> bool
  val is_string_end : string -> int -> bool
  val is_chinese_period : string -> int -> bool
  val is_chinese_left_paren : string -> int -> bool
  val is_chinese_right_paren : string -> int -> bool
  val is_chinese_comma : string -> int -> bool
  val is_chinese_colon : string -> int -> bool
  val is_chinese_semicolon : string -> int -> bool
  val is_chinese_pipe : string -> int -> bool
end

(** 全角字符检测模块 *)
module FullwidthDetection : sig
  val is_fullwidth_digit : char -> bool
  val is_fullwidth_letter : char -> bool
  val is_fullwidth_symbol : string -> int -> bool
end

(** UTF-8字符串处理工具模块 *)
module StringUtils : sig
  val utf8_length : string -> int
  val is_all_chinese : string -> bool
  val utf8_to_char_list : string -> string list
end

(** 关键字和标识符边界检测模块 *)
module BoundaryDetection : sig
  val is_chinese_keyword_boundary : string -> int -> string -> bool
  val is_identifier_boundary : string -> int -> bool
end