(** 向后兼容性核心模块接口
    
    保持原有接口并整合各子模块，确保现有代码的兼容性。
*)

(** 向后兼容性别名模块
    
    提供原UTF8模块和其他模块的向后兼容别名，确保现有代码能够正常工作。
*)
module Compatibility : sig
  (** {2 字符范围常量} *)
  val chinese_char_start : int
  val chinese_char_mid_start : int
  val chinese_char_mid_end : int
  val chinese_char_threshold : int
  
  (** {2 前缀字节常量} *)
  val chinese_punctuation_prefix : int
  val chinese_operator_prefix : int
  val arrow_symbol_prefix : int
  val fullwidth_prefix : int
  
  (** {2 字符字节组合查询} *)
  val get_char_bytes : string -> int * int * int
  
  (** {2 引号字符字节定义} *)
  val left_quote_bytes : int * int * int
  val right_quote_bytes : int * int * int
  val string_start_bytes : int * int * int
  val string_end_bytes : int * int * int
  
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
  
  (** {2 中文标点符号字节定义} *)
  val chinese_left_paren_bytes : int * int * int
  val chinese_right_paren_bytes : int * int * int
  val chinese_comma_bytes : int * int * int
  val chinese_colon_bytes : int * int * int
  val chinese_period_bytes : int * int * int
  
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
  
  (** {2 全角字符处理} *)
  val fullwidth_left_paren_bytes : int * int * int
  val fullwidth_right_paren_bytes : int * int * int
  val fullwidth_comma_bytes : int * int * int
  val fullwidth_colon_bytes : int * int * int
  val fullwidth_semicolon_bytes : int * int * int
  val fullwidth_pipe_bytes : int * int * int
  val fullwidth_period_bytes : int * int * int
  val chinese_minus_bytes : int * int * int
  
  val chinese_square_left_bracket_bytes : int * int * int
  val chinese_square_right_bracket_bytes : int * int * int
  
  val chinese_arrow_bytes : int * int * int
  val chinese_double_arrow_bytes : int * int * int
  val chinese_assign_arrow_bytes : int * int * int
  
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
  
  (** {2 注释符号} *)
  val comment_colon_byte1 : int
  val comment_colon_byte2 : int
  val comment_colon_byte3 : int
  
  (** {2 数字范围} *)
  val fullwidth_digit_start : int
  val fullwidth_digit_end : int
  
  (** {2 操作符} *)
  val chinese_minus_byte1 : int
  val chinese_minus_byte2 : int
  val chinese_minus_byte3 : int
  
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
  
  (** {2 检查函数重导出} *)
  val is_chinese_punctuation_prefix : int -> bool
  val is_chinese_operator_prefix : int -> bool
  val is_arrow_symbol_prefix : int -> bool
  val is_fullwidth_prefix : int -> bool
  val is_fullwidth_digit : int -> bool
end