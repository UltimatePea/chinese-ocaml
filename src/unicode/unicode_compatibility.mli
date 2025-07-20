(** Unicode向后兼容性接口模块

    本模块提供向后兼容性支持，维护原有UTF8模块的接口，
    确保现有代码能够无缝迁移到新的Unicode字符处理系统。
    
    主要功能：
    - 提供原有常量的别名
    - 字符字节组合查询
    - 全角字符范围检查
    - 中文标点符号处理
*)

(** 向后兼容性模块 *)
module Compatibility : sig
  (** {2 字符范围常量} *)
  
  val chinese_char_start : int
  (** 中文字符起始字节码 *)
  
  val chinese_char_mid_start : int
  (** 中文字符中段起始字节码 *)
  
  val chinese_char_mid_end : int
  (** 中文字符中段结束字节码 *)
  
  val chinese_char_threshold : int
  (** 中文字符判断阈值 *)
  
  (** {2 前缀字节常量} *)
  
  val chinese_punctuation_prefix : int
  (** 中文标点符号前缀字节 *)
  
  val chinese_operator_prefix : int
  (** 中文操作符前缀字节 *)
  
  val arrow_symbol_prefix : int
  (** 箭头符号前缀字节 *)
  
  val fullwidth_prefix : int
  (** 全角符号前缀字节 *)
  
  (** {2 字符字节组合查询} *)
  
  val get_char_bytes : string -> int * int * int
  (** [get_char_bytes char_name] 获取指定字符名称对应的UTF-8字节组合
      @param char_name 字符名称
      @return 字节三元组 (byte1, byte2, byte3)，失败时返回 (0, 0, 0) *)
  
  (** {2 引号字符字节定义} *)
  
  val left_quote_bytes : int * int * int
  (** 左引号「的字节组合 *)
  
  val right_quote_bytes : int * int * int
  (** 右引号」的字节组合 *)
  
  val string_start_bytes : int * int * int
  (** 字符串起始符『的字节组合 *)
  
  val string_end_bytes : int * int * int
  (** 字符串结束符』的字节组合 *)
  
  val left_quote_byte1 : int
  val left_quote_byte2 : int
  val left_quote_byte3 : int
  (** 左引号「的各个字节 *)
  
  val right_quote_byte1 : int
  val right_quote_byte2 : int
  val right_quote_byte3 : int
  (** 右引号」的各个字节 *)
  
  val string_start_byte1 : int
  val string_start_byte2 : int
  val string_start_byte3 : int
  (** 字符串起始符『的各个字节 *)
  
  val string_end_byte1 : int
  val string_end_byte2 : int
  val string_end_byte3 : int
  (** 字符串结束符』的各个字节 *)
  
  (** {2 中文标点符号字节定义} *)
  
  val chinese_left_paren_bytes : int * int * int
  val chinese_right_paren_bytes : int * int * int
  val chinese_comma_bytes : int * int * int
  val chinese_colon_bytes : int * int * int
  val chinese_period_bytes : int * int * int
  (** 中文标点符号的字节组合 *)
  
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
  (** 中文标点符号的各个字节 *)
  
  (** {2 全角字符处理} *)
  
  val fullwidth_left_paren_bytes : int * int * int
  val fullwidth_right_paren_bytes : int * int * int
  val fullwidth_comma_bytes : int * int * int
  val fullwidth_colon_bytes : int * int * int
  val fullwidth_semicolon_bytes : int * int * int
  val fullwidth_pipe_bytes : int * int * int
  val fullwidth_period_bytes : int * int * int
  val chinese_minus_bytes : int * int * int
  (** 全角字符的字节组合 *)
  
  val fullwidth_start_byte1 : int
  val fullwidth_start_byte2 : int
  (** 全角符号范围起始字节 *)
  
  val fullwidth_left_paren_byte3 : int
  val fullwidth_right_paren_byte3 : int
  val fullwidth_comma_byte3 : int
  val fullwidth_colon_byte3 : int
  val fullwidth_semicolon_byte3 : int
  val fullwidth_pipe_byte1 : int
  val fullwidth_pipe_byte2 : int
  val fullwidth_pipe_byte3 : int
  val fullwidth_period_byte3 : int
  (** 全角字符的各个字节 *)
  
  (** {2 注释符号} *)
  
  val comment_colon_byte1 : int
  val comment_colon_byte2 : int
  val comment_colon_byte3 : int
  (** 中文注释符号：的字节定义 *)
  
  (** {2 数字范围} *)
  
  val fullwidth_digit_start : int
  (** 全角数字起始字节 *)
  
  val fullwidth_digit_end : int
  (** 全角数字结束字节 *)
  
  (** {2 操作符} *)
  
  val chinese_minus_byte1 : int
  val chinese_minus_byte2 : int
  val chinese_minus_byte3 : int
  (** 中文减号的字节定义 *)
  
  (** {2 字符常量重导出} *)
  
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
  (** 常用UTF-8字节常量 *)
  
  (** {2 检查函数重导出} *)
  
  val is_chinese_punctuation_prefix : int -> bool
  (** 检查是否为中文标点符号前缀 *)
  
  val is_chinese_operator_prefix : int -> bool
  (** 检查是否为中文操作符前缀 *)
  
  val is_arrow_symbol_prefix : int -> bool
  (** 检查是否为箭头符号前缀 *)
  
  val is_fullwidth_prefix : int -> bool
  (** 检查是否为全角符号前缀 *)
  
  val is_fullwidth_digit : int -> bool
  (** 检查是否为全角数字 *)
end