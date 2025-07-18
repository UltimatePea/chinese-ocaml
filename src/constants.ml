(** 骆言编译器常量定义模块 *)

(** UTF-8字符检测常量 *)
module UTF8 = struct
  (** 中文字符范围检测 *)
  let chinese_char_start = 0xE4
  let chinese_char_mid_start = 0xE5
  let chinese_char_mid_end = 0xE9
  let chinese_char_threshold = 128

  (** 常用UTF-8字符码点前缀 *)
  let chinese_punctuation_prefix = 0xE3  (* 中文标点符号 *)
  let chinese_operator_prefix = 0xE8     (* 中文操作符 *)
  let arrow_symbol_prefix = 0xE2         (* 箭头符号 *)
  let fullwidth_prefix = 0xEF            (* 全角符号 *)

  (** 特定UTF-8字符码点 - 引用标识符 *)
  let left_quote_byte1 = 0xE3 (* 「 *)
  let left_quote_byte2 = 0x80
  let left_quote_byte3 = 0x8C
  let right_quote_byte1 = 0xE3 (* 」 *)
  let right_quote_byte2 = 0x80
  let right_quote_byte3 = 0x8D

  (** 特定UTF-8字符码点 - 字符串字面量 *)
  let string_start_byte1 = 0xE3 (* 『 *)
  let string_start_byte2 = 0x80
  let string_start_byte3 = 0x8E
  let string_end_byte1 = 0xE3 (* 』 *)
  let string_end_byte2 = 0x80
  let string_end_byte3 = 0x8F

  (** 全角符号范围 *)
  let fullwidth_start_byte1 = 0xEF
  let fullwidth_start_byte2 = 0xBC

  (** 全角符号具体码点 *)
  let fullwidth_left_paren_byte3 = 0x88  (* （ *)
  let fullwidth_right_paren_byte3 = 0x89 (* ） *)
  let fullwidth_comma_byte3 = 0x8C       (* ， *)
  let fullwidth_colon_byte3 = 0x9A       (* ： *)
  let fullwidth_semicolon_byte3 = 0x9B   (* ； *)
  let fullwidth_pipe_byte1 = 0xEF        (* ｜ *)
  let fullwidth_pipe_byte2 = 0xBD
  let fullwidth_pipe_byte3 = 0x9C
  let fullwidth_period_byte3 = 0x8E      (* ． *)

  (** 全角数字范围 *)
  let fullwidth_digit_start = 0x90       (* ０ *)
  let fullwidth_digit_end = 0x99         (* ９ *)

  (** 中文标点符号 *)
  let chinese_period_byte1 = 0xE3 (* 。 *)
  let chinese_period_byte2 = 0x80
  let chinese_period_byte3 = 0x82

  (** 中文操作符 *)
  let chinese_minus_byte1 = 0xE8 (* 负 *)
  let chinese_minus_byte2 = 0xB4
  let chinese_minus_byte3 = 0x9F

  (** 字符常量 - 用于代替硬编码字符 *)
  let char_xe3 = '\xe3'
  let char_x80 = '\x80'
  let char_x8e = '\x8e'
  let char_x8f = '\x8f'
  let char_xef = '\xef'
  let char_xbc = '\xbc'
  let char_xbd = '\xbd'
  let char_x9c = '\x9c'
  let char_xe8 = '\xe8'
  let char_xb4 = '\xb4'
  let char_x9f = '\x9f'
  let char_xe2 = '\xe2'

  (** 便捷检查函数 *)
  let is_chinese_punctuation_prefix byte = byte = chinese_punctuation_prefix
  let is_chinese_operator_prefix byte = byte = chinese_operator_prefix
  let is_arrow_symbol_prefix byte = byte = arrow_symbol_prefix
  let is_fullwidth_prefix byte = byte = fullwidth_prefix
end

(** 缓冲区大小常量 - 现在从配置系统获取 *)
module BufferSizes = struct
  let default_buffer () = Config.Get.buffer_size ()
  let large_buffer () = Config.Get.large_buffer_size ()
  let report_buffer () = Config.Get.large_buffer_size () * 4
  let utf8_char_buffer () = 8 (* UTF-8字符固定大小 *)
end

(** 百分比和置信度常量 *)
module Metrics = struct
  let confidence_multiplier = 100.0
  let full_confidence = 1.0
  let zero_confidence = 0.0

  let confidence_threshold () =
    let cfg = Config.get_compiler_config () in
    cfg.confidence_threshold

  (** 统计计算常量 *)
  let zero_division_fallback = 0.0
  let percentage_multiplier = 100.0
  let precision_decimal_places = 2
end

(** 测试数据常量 *)
module TestData = struct
  let small_test_number = 100
  let large_test_number = 999999
  let factorial_test_input = 5
  let factorial_expected_result = 120
  let sum_1_to_100 = 5050
end

(** 编译器配置常量 - 现在从配置系统获取 *)
module Compiler = struct
  (** 默认输出文件名 *)
  let default_c_output () =
    let cfg = Config.get_compiler_config () in
    cfg.default_c_output

  (** 临时文件前缀 *)
  let temp_file_prefix () =
    let cfg = Config.get_compiler_config () in
    cfg.temp_file_prefix

  (** 位置信息默认值 *)
  let default_position = 0

  (** 输出目录 *)
  let output_directory () = Config.Get.output_directory ()

  (** 临时目录 *)
  let temp_directory () = Config.Get.temp_directory ()

  (** 运行时目录 *)
  let runtime_directory () =
    let cfg = Config.get_compiler_config () in
    cfg.runtime_directory
end

(** ANSI颜色代码常量 *)
module Colors = struct
  (** 基础颜色 *)
  let red = "\027[31m"
  let green = "\027[32m"
  let yellow = "\027[33m"
  let blue = "\027[34m"
  let magenta = "\027[35m"
  let cyan = "\027[36m"
  let white = "\027[37m"
  
  (** 亮色 *)
  let bright_red = "\027[91m"
  let bright_green = "\027[92m"
  let bright_yellow = "\027[93m"
  let bright_blue = "\027[94m"
  let bright_magenta = "\027[95m"
  let bright_cyan = "\027[96m"
  let bright_white = "\027[97m"
  
  (** 样式 *)
  let bold = "\027[1m"
  let dim = "\027[2m"
  let italic = "\027[3m"
  let underline = "\027[4m"
  let blink = "\027[5m"
  let reverse = "\027[7m"
  let strikethrough = "\027[9m"
  
  (** 重置 *)
  let reset = "\027[0m"
  
  (** 便捷函数 *)
  let with_color color_code message = 
    if Config.Get.colored_output () then
      color_code ^ message ^ reset
    else
      message
  
  (** 预定义颜色函数 *)
  let red_text message = with_color red message
  let green_text message = with_color green message
  let yellow_text message = with_color yellow message
  let blue_text message = with_color blue message
  let cyan_text message = with_color cyan message
  let bold_text message = with_color bold message
  let bright_red_text message = with_color bright_red message
  
  (** 日志级别颜色 *)
  let debug_color = cyan
  let info_color = green
  let warn_color = yellow
  let error_color = red
  let fatal_color = bright_red
end

(** 错误消息模板 *)
module ErrorMessages = struct
  (** 变量和模块相关错误 *)
  let undefined_variable var_name = Printf.sprintf "未定义的变量: %s" var_name
  let module_not_found mod_name = Printf.sprintf "未定义的模块: %s" mod_name
  let member_not_found mod_name member_name = Printf.sprintf "模块 %s 中未找到成员: %s" mod_name member_name
  let empty_scope_stack = "尝试退出空作用域栈"
  let empty_variable_name = "空变量名"
  
  (** 词法分析器错误 *)
  let unterminated_comment = "Unterminated comment"
  let unterminated_chinese_comment = "Unterminated Chinese comment"
  let unterminated_string = "Unterminated string"
  let unterminated_quoted_identifier = "未闭合的引用标识符"
  let invalid_char_in_quoted_identifier = "引用标识符中的无效字符"
  
  (** 符号和数字相关错误 *)
  let ascii_symbols_disabled = "ASCII符号已禁用，请使用中文标点符号"
  let fullwidth_numbers_disabled = "只允许半角阿拉伯数字，请勿使用全角数字"
  let arabic_numbers_disabled = "阿拉伯数字已禁用"
  let unsupported_chinese_symbol = "非支持的中文符号已禁用，只支持「」『』：，。（）"
  let identifiers_must_be_quoted = "标识符必须使用「」引用"
  let ascii_letters_as_keywords_only = "ASCII字母已禁用，只允许作为关键字使用"
  
  (** 类型相关错误 *)
  let type_mismatch expected actual = Printf.sprintf "类型不匹配，期望 %s，得到 %s" expected actual
  let unknown_type type_name = Printf.sprintf "未知类型: %s" type_name
  let invalid_type_operation op_name = Printf.sprintf "无效的类型操作: %s" op_name
  
  (** 函数相关错误 *)
  let function_not_found func_name = Printf.sprintf "函数未找到: %s" func_name
  let invalid_argument_count expected actual = Printf.sprintf "参数数量错误，期望 %d，得到 %d" expected actual
  let invalid_argument_type expected actual = Printf.sprintf "参数类型错误，期望 %s，得到 %s" expected actual
  
  (** 解析器错误 *)
  let unexpected_token token = Printf.sprintf "意外的Token: %s" token
  let expected_token expected actual = Printf.sprintf "期望Token %s，得到 %s" expected actual
  let syntax_error message = Printf.sprintf "语法错误: %s" message
  
  (** 运行时错误 *)
  let division_by_zero = "除零错误"
  let stack_overflow = "栈溢出"
  let out_of_memory = "内存不足"
  let invalid_operation operation = Printf.sprintf "无效操作: %s" operation
  
  (** 文件I/O错误 *)
  let file_not_found filename = Printf.sprintf "文件未找到: %s" filename
  let file_read_error filename = Printf.sprintf "文件读取错误: %s" filename
  let file_write_error filename = Printf.sprintf "文件写入错误: %s" filename
  
  (** 配置错误 *)
  let config_parse_error message = Printf.sprintf "配置解析错误: %s" message
  let invalid_config_value key value = Printf.sprintf "配置值无效: %s = %s" key value
  
  (** 通用错误模板 *)
  let unsupported_char_error char_bytes = Printf.sprintf "非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: %s" char_bytes
end

(** 统计信息显示消息 *)
module Messages = struct
  (** 性能统计消息 *)
  let performance_stats_header = "类型推断性能统计:"
  let infer_calls_format = "  推断调用: %d\n"
  let unify_calls_format = "  合一调用: %d\n"
  let subst_apps_format = "  替换应用: %d\n"
  let cache_hits_format = "  缓存命中: %d\n"
  let cache_misses_format = "  缓存未命中: %d\n"
  let hit_rate_format = "  命中率: %.2f%%\n"
  let cache_size_format = "  缓存大小: %d\n"
  
  (** 通用消息模板 *)
  let debug_prefix = "[DEBUG] "
  let info_prefix = "[INFO] "
  let warning_prefix = "[WARNING] "
  let error_prefix = "[ERROR] "
  let fatal_prefix = "[FATAL] "
  
  (** 编译过程消息 *)
  let compiling_file filename = Printf.sprintf "正在编译文件: %s" filename
  let compilation_complete = "编译完成"
  let compilation_failed = "编译失败"
  let parsing_started = "开始解析"
  let parsing_complete = "解析完成"
  let type_checking_started = "开始类型检查"
  let type_checking_complete = "类型检查完成"
end

(** 系统配置常量 *)
module SystemConfig = struct
  (** 哈希表大小 *)
  let default_hash_table_size = 256
  let large_hash_table_size = 1024
  
  (** 缓存大小 *)
  let default_cache_size = 128
  let large_cache_size = 512
  
  (** 字符串处理 *)
  let utf8_char_max_bytes = 4
  let utf8_char_buffer_size = 8
  let string_slice_length = 3
  
  (** 数值常量 *)
  let percentage_multiplier = 100.0
  let max_recursion_depth = 1000
  let default_timeout_ms = 5000
  
  (** 文件处理 *)
  let file_chunk_size = 8192
  let max_file_size = 1048576  (* 1MB *)
  let temp_file_suffix = ".tmp"
  
  (** 诗词相关配置 *)
  let max_verse_length = 32
  let max_poem_lines = 100
  let default_rhyme_scheme_length = 8
end

(** 数值常量 *)
module Numbers = struct
  (** 常用数值 *)
  let zero = 0
  let one = 1
  let two = 2
  let three = 3
  let four = 4
  let five = 5
  let ten = 10
  let hundred = 100
  let thousand = 1000
  
  (** 浮点数 *)
  let zero_float = 0.0
  let one_float = 1.0
  let half_float = 0.5
  let pi = 3.14159265359
  
  (** 比例和百分比 *)
  let full_percentage = 100.0
  let half_percentage = 50.0
  let quarter_percentage = 25.0
  
  (** 类型复杂度常量 *)
  let type_complexity_basic = 1
  let type_complexity_composite = 2
end
