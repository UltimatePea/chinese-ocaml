(** 骆言编译器常量定义模块接口 *)

(** UTF-8字符检测常量 *)
module UTF8 : sig
  (** 中文字符范围检测 *)
  val chinese_char_start : int
  val chinese_char_mid_start : int
  val chinese_char_mid_end : int
  val chinese_char_threshold : int
  
  (** 特定UTF-8字符码点 *)
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
  
  (** 全角符号范围 *)
  val fullwidth_start_byte1 : int
  val fullwidth_start_byte2 : int
  
  (** 中文标点符号 *)
  val chinese_period_byte1 : int
  val chinese_period_byte2 : int
  val chinese_period_byte3 : int
  val chinese_left_paren_byte3 : int
  val chinese_right_paren_byte3 : int
  val chinese_comma_byte3 : int
  val chinese_colon_byte3 : int
end

(** 缓冲区大小常量 *)
module BufferSizes : sig
  val default_buffer : unit -> int
  val large_buffer : unit -> int
  val report_buffer : unit -> int
  val utf8_char_buffer : unit -> int
end

(** 百分比和置信度常量 *)
module Metrics : sig
  val confidence_multiplier : float
  val full_confidence : float
  val zero_confidence : float
  val confidence_threshold : unit -> float
end

(** 测试数据常量 *)
module TestData : sig
  val small_test_number : int
  val large_test_number : int
  val factorial_test_input : int
  val factorial_expected_result : int
  val sum_1_to_100 : int
end

(** 编译器配置常量 *)
module Compiler : sig
  val default_c_output : unit -> string
  val temp_file_prefix : unit -> string
  val default_position : int
  val output_directory : unit -> string
  val temp_directory : unit -> string
  val runtime_directory : unit -> string
end

(** ANSI颜色代码常量 *)
module Colors : sig
  (** 基础颜色 *)
  val red : string
  val green : string
  val yellow : string
  val blue : string
  val magenta : string
  val cyan : string
  val white : string
  
  (** 亮色 *)
  val bright_red : string
  val bright_green : string
  val bright_yellow : string
  val bright_blue : string
  val bright_magenta : string
  val bright_cyan : string
  val bright_white : string
  
  (** 样式 *)
  val bold : string
  val dim : string
  val italic : string
  val underline : string
  val blink : string
  val reverse : string
  val strikethrough : string
  
  (** 重置 *)
  val reset : string
  
  (** 便捷函数 *)
  val with_color : string -> string -> string
  
  (** 预定义颜色函数 *)
  val red_text : string -> string
  val green_text : string -> string
  val yellow_text : string -> string
  val blue_text : string -> string
  val cyan_text : string -> string
  val bold_text : string -> string
  val bright_red_text : string -> string
  
  (** 日志级别颜色 *)
  val debug_color : string
  val info_color : string
  val warn_color : string
  val error_color : string
  val fatal_color : string
end

(** 错误消息模板 *)
module ErrorMessages : sig
  val undefined_variable : string -> string
  val module_not_found : string -> string
  val member_not_found : string -> string -> string
  val empty_scope_stack : string
  val empty_variable_name : string
  val unterminated_comment : string
  val unterminated_chinese_comment : string
  val unterminated_string : string
  val unterminated_quoted_identifier : string
  val invalid_char_in_quoted_identifier : string
  val ascii_symbols_disabled : string
  val fullwidth_numbers_disabled : string
  val arabic_numbers_disabled : string
  val unsupported_chinese_symbol : string
  val identifiers_must_be_quoted : string
  val ascii_letters_as_keywords_only : string
end