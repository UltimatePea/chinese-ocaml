(** Unicode字符字节访问器模块接口
    
    提供各个字节位的便捷访问函数，简化字符字节的获取操作。
*)

(** 三元组字节访问器助手函数 *)

(** 获取三元组的第一个字节 *)
val get_byte1 : int * int * int -> int

(** 获取三元组的第二个字节 *)
val get_byte2 : int * int * int -> int

(** 获取三元组的第三个字节 *)
val get_byte3 : int * int * int -> int

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