(** 骆言编译器常量定义模块接口 *)

(** UTF-8字符检测常量 *)
module UTF8 : sig
  (** 中文字符范围检测 *)
  val chinese_char_start : int
  val chinese_char_mid_start : int
  val chinese_char_mid_end : int
  val chinese_char_threshold : int
  
  (** 常用UTF-8字符码点前缀 *)
  val chinese_punctuation_prefix : int
  val chinese_operator_prefix : int
  val arrow_symbol_prefix : int
  val fullwidth_prefix : int
  
  (** 特定UTF-8字符码点 - 引用标识符 *)
  val left_quote_byte1 : int
  val left_quote_byte2 : int
  val left_quote_byte3 : int
  val right_quote_byte1 : int
  val right_quote_byte2 : int
  val right_quote_byte3 : int
  
  (** 特定UTF-8字符码点 - 字符串字面量 *)
  val string_start_byte1 : int
  val string_start_byte2 : int
  val string_start_byte3 : int
  val string_end_byte1 : int
  val string_end_byte2 : int
  val string_end_byte3 : int
  
  (** 全角符号范围 *)
  val fullwidth_start_byte1 : int
  val fullwidth_start_byte2 : int
  
  (** 全角符号具体码点 *)
  val fullwidth_left_paren_byte3 : int
  val fullwidth_right_paren_byte3 : int
  val fullwidth_comma_byte3 : int
  val fullwidth_colon_byte3 : int
  val fullwidth_semicolon_byte3 : int
  val fullwidth_pipe_byte1 : int
  val fullwidth_pipe_byte2 : int
  val fullwidth_pipe_byte3 : int
  val fullwidth_period_byte3 : int
  
  (** 中文注释符号完整码点 *)
  val comment_colon_byte1 : int
  val comment_colon_byte2 : int
  val comment_colon_byte3 : int
  
  (** 全角数字范围 *)
  val fullwidth_digit_start : int
  val fullwidth_digit_end : int
  
  (** 中文标点符号 *)
  val chinese_period_byte1 : int
  val chinese_period_byte2 : int
  val chinese_period_byte3 : int
  
  (** 中文操作符 *)
  val chinese_minus_byte1 : int
  val chinese_minus_byte2 : int
  val chinese_minus_byte3 : int
  
  (** 字符常量 - 用于代替硬编码字符 *)
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
  
  (** 便捷检查函数 *)
  val is_chinese_punctuation_prefix : int -> bool
  val is_chinese_operator_prefix : int -> bool
  val is_arrow_symbol_prefix : int -> bool
  val is_fullwidth_prefix : int -> bool
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
  
  (** 统计计算常量 *)
  val zero_division_fallback : float
  val percentage_multiplier : float
  val precision_decimal_places : int
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
  (** 变量和模块相关错误 *)
  val undefined_variable : string -> string
  val module_not_found : string -> string
  val member_not_found : string -> string -> string
  val empty_scope_stack : string
  val empty_variable_name : string
  
  (** 词法分析器错误 *)
  val unterminated_comment : string
  val unterminated_chinese_comment : string
  val unterminated_string : string
  val unterminated_quoted_identifier : string
  val invalid_char_in_quoted_identifier : string
  
  (** 符号和数字相关错误 *)
  val ascii_symbols_disabled : string
  val fullwidth_numbers_disabled : string
  val arabic_numbers_disabled : string
  val unsupported_chinese_symbol : string
  val identifiers_must_be_quoted : string
  val ascii_letters_as_keywords_only : string
  
  (** 类型相关错误 *)
  val type_mismatch : string -> string -> string
  val unknown_type : string -> string
  val invalid_type_operation : string -> string
  
  (** 函数相关错误 *)
  val function_not_found : string -> string
  val invalid_argument_count : int -> int -> string
  val invalid_argument_type : string -> string -> string
  
  (** 解析器错误 *)
  val unexpected_token : string -> string
  val expected_token : string -> string -> string
  val syntax_error : string -> string
  
  (** 运行时错误 *)
  val division_by_zero : string
  val stack_overflow : string
  val out_of_memory : string
  val invalid_operation : string -> string
  
  (** 文件I/O错误 *)
  val file_not_found : string -> string
  val file_read_error : string -> string
  val file_write_error : string -> string
  
  (** 配置错误 *)
  val config_parse_error : string -> string
  val invalid_config_value : string -> string -> string
  
  (** 通用错误模板 *)
  val unsupported_char_error : string -> string
end

(** 统计信息显示消息 *)
module Messages : sig
  (** 性能统计消息 *)
  val performance_stats_header : string
  val infer_calls_format : string
  val unify_calls_format : string
  val subst_apps_format : string
  val cache_hits_format : string
  val cache_misses_format : string
  val hit_rate_format : string
  val cache_size_format : string
  
  (** 通用消息模板 *)
  val debug_prefix : string
  val info_prefix : string
  val warning_prefix : string
  val error_prefix : string
  val fatal_prefix : string
  
  (** 编译过程消息 *)
  val compiling_file : string -> string
  val compilation_complete : string
  val compilation_failed : string
  val parsing_started : string
  val parsing_complete : string
  val type_checking_started : string
  val type_checking_complete : string
end

(** 系统配置常量 *)
module SystemConfig : sig
  (** 哈希表大小 *)
  val default_hash_table_size : int
  val large_hash_table_size : int
  
  (** 缓存大小 *)
  val default_cache_size : int
  val large_cache_size : int
  
  (** 字符串处理 *)
  val utf8_char_max_bytes : int
  val utf8_char_buffer_size : int
  val string_slice_length : int
  
  (** 数值常量 *)
  val percentage_multiplier : float
  val max_recursion_depth : int
  val default_timeout_ms : int
  
  (** 文件处理 *)
  val file_chunk_size : int
  val max_file_size : int
  
  (** 诗词相关配置 *)
  val max_verse_length : int
  val max_poem_lines : int
  val default_rhyme_scheme_length : int
end

(** 数值常量 *)
module Numbers : sig
  (** 常用数值 *)
  val zero : int
  val one : int
  val two : int
  val three : int
  val four : int
  val five : int
  val ten : int
  val hundred : int
  val thousand : int
  
  (** 浮点数 *)
  val zero_float : float
  val one_float : float
  val half_float : float
  val pi : float
  
  (** 比例和百分比 *)
  val full_percentage : float
  val half_percentage : float
  val quarter_percentage : float
  
  (** 类型复杂度常量 *)
  val type_complexity_basic : int
  val type_complexity_composite : int
end

(** C运行时函数名称常量 *)
module RuntimeFunctions : sig
  (** 二元运算函数 *)
  val add : string
  val subtract : string
  val multiply : string
  val divide : string
  val modulo : string
  val equal : string
  val not_equal : string
  val less_than : string
  val greater_than : string
  val less_equal : string
  val greater_equal : string
  val logical_and : string
  val logical_or : string
  val concat : string
  
  (** 一元运算函数 *)
  val logical_not : string
  val int_zero : string
  
  (** 内存操作函数 *)
  val ref_create : string
  val deref : string
  val assign : string
  
  (** 文件扩展名 *)
  val c_extension : string
  val ly_extension : string
  val temp_extension : string
end