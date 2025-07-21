(** Unicode字符字节定义模块接口
    
    包含各种Unicode字符的字节组合常量定义，用于高效的字符识别和处理。
*)

(** 获取字符的字节组合
    
    @param char_name 字符名称
    @return 字符的三字节组合 (byte1, byte2, byte3)，无法找到时返回 (0, 0, 0)
*)
val get_char_bytes : string -> int * int * int

(** 引号字符字节定义模块 *)
module Quote : sig
  val left_quote_bytes : int * int * int
  val right_quote_bytes : int * int * int
  val string_start_bytes : int * int * int
  val string_end_bytes : int * int * int
end

(** 中文标点符号字节定义模块 *)
module ChinesePunctuation : sig
  val chinese_left_paren_bytes : int * int * int
  val chinese_right_paren_bytes : int * int * int
  val chinese_comma_bytes : int * int * int
  val chinese_colon_bytes : int * int * int
  val chinese_period_bytes : int * int * int
end