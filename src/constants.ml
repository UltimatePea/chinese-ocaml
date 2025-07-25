(** 骆言编译器常量定义模块 重构后的主协调器模块，具体常量已拆分到专门子模块 *)

module UTF8 = Unicode_constants.Compatibility
(** UTF-8字符检测常量 - 重定向到Unicode_constants模块 *)

(* 为了避免循环依赖，直接定义最少的适配器函数 *)

(** 缓冲区大小常量 *)
module BufferSizes = struct
  let default_buffer () = 1024
  let large_buffer () = 4096
  let report_buffer () = 16384
  let utf8_char_buffer () = 8
end

(** 百分比和置信度常量 *)
module Metrics = struct
  let confidence_multiplier = 100.0
  let full_confidence = 1.0
  let zero_confidence = 0.0
  let confidence_threshold () = 0.5
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

(** 编译器配置常量 *)
module Compiler = struct
  let default_c_output () = "output.c"
  let temp_file_prefix () = "luoyan_tmp"
  let default_position = 0
  let output_directory () = "./"
  let temp_directory () = "/tmp"
  let runtime_directory () = "./runtime"
end

(** ANSI颜色代码常量 *)
module Colors = struct
  let red = "\027[31m"
  let green = "\027[32m"
  let yellow = "\027[33m"
  let blue = "\027[34m"
  let magenta = "\027[35m"
  let cyan = "\027[36m"
  let white = "\027[37m"
  let bright_red = "\027[91m"
  let bright_green = "\027[92m"
  let bright_yellow = "\027[93m"
  let bright_blue = "\027[94m"
  let bright_magenta = "\027[95m"
  let bright_cyan = "\027[96m"
  let bright_white = "\027[97m"
  let bold = "\027[1m"
  let dim = "\027[2m"
  let italic = "\027[3m"
  let underline = "\027[4m"
  let blink = "\027[5m"
  let reverse = "\027[7m"
  let strikethrough = "\027[9m"
  let reset = "\027[0m"
  let with_color color_code message = color_code ^ message ^ reset
  let red_text message = with_color red message
  let green_text message = with_color green message
  let yellow_text message = with_color yellow message
  let blue_text message = with_color blue message
  let cyan_text message = with_color cyan message
  let bold_text message = with_color bold message
  let bright_red_text message = with_color bright_red message
  let debug_color = cyan
  let info_color = green
  let warn_color = yellow
  let error_color = red
  let fatal_color = bright_red
end

(** 错误消息模板 *)
module ErrorMessages = struct
  let undefined_variable var_name = "未定义的变量: " ^ var_name
  let module_not_found mod_name = "未找到模块: " ^ mod_name

  let member_not_found mod_name member_name = "模块 " ^ mod_name ^ " 中未找到成员: " ^ member_name

  let empty_scope_stack = "尝试退出空作用域栈"
  let empty_variable_name = "空变量名"
  let unterminated_comment = "Unterminated comment"
  let unterminated_chinese_comment = "Unterminated Chinese comment"
  let unterminated_string = "Unterminated string"
  let unterminated_quoted_identifier = "未闭合的引用标识符"
  let invalid_char_in_quoted_identifier = "引用标识符中的无效字符"
  let ascii_symbols_disabled = "ASCII符号已禁用，请使用中文标点符号"
  let fullwidth_numbers_disabled = "只允许半角阿拉伯数字，请勿使用全角数字"
  let arabic_numbers_disabled = "阿拉伯数字已禁用"

  let unsupported_chinese_symbol = "非支持的中文符号已禁用，只支持「」『』：，。（）"

  let identifiers_must_be_quoted = "标识符必须使用「」引用"
  let ascii_letters_as_keywords_only = "ASCII字母已禁用，只允许作为关键字使用"
  let type_mismatch expected actual = "类型不匹配: 期望 " ^ expected ^ "，实际 " ^ actual
  let unknown_type type_name = "未知类型: " ^ type_name
  let invalid_type_operation op_name = "无效的类型操作: " ^ op_name
  let function_not_found func_name = "未找到函数: " ^ func_name

  let invalid_argument_count expected actual =
    Printf.sprintf "参数个数不匹配: 期望 %d，实际 %d" expected actual

  let invalid_argument_type expected actual = "参数类型不匹配: 期望 " ^ expected ^ "，实际 " ^ actual

  let unexpected_token token = "意外的token: " ^ token
  let expected_token expected actual = "期望token " ^ expected ^ "，实际 " ^ actual
  let syntax_error message = "语法错误: " ^ message
  let division_by_zero = "除零错误"
  let stack_overflow = "栈溢出"
  let out_of_memory = "内存不足"
  let invalid_operation operation = "无效操作: " ^ operation
  let file_not_found filename = "文件未找到: " ^ filename
  let file_read_error filename = "文件读取错误: " ^ filename
  let file_write_error filename = "文件写入错误: " ^ filename
  let config_parse_error message = "配置解析错误: " ^ message
  let invalid_config_value key value = "无效配置值 " ^ key ^ ": " ^ value
  let unsupported_char_error char_bytes = "不支持的字符: " ^ char_bytes
end

(** 统计信息显示消息 *)
module Messages = struct
  let performance_stats_header = "类型推断性能统计:"
  let infer_calls_format = "  推断调用: %d\n"
  let unify_calls_format = "  合一调用: %d\n"
  let subst_apps_format = "  替换应用: %d\n"
  let cache_hits_format = "  缓存命中: %d\n"
  let cache_misses_format = "  缓存未命中: %d\n"
  let hit_rate_format = "  命中率: %.2f%%\n"
  let cache_size_format = "  缓存大小: %d\n"
  let debug_prefix = "[DEBUG] "
  let info_prefix = "[INFO] "
  let warning_prefix = "[WARNING] "
  let error_prefix = "[ERROR] "
  let fatal_prefix = "[FATAL] "
  let compiling_file filename = "正在编译文件: " ^ filename
  let compilation_complete = "编译完成"
  let compilation_failed = "编译失败"
  let parsing_started = "开始解析"
  let parsing_complete = "解析完成"
  let type_checking_started = "开始类型检查"
  let type_checking_complete = "类型检查完成"
end

(** 系统配置常量 *)
module SystemConfig = struct
  let default_hash_table_size = 256
  let large_hash_table_size = 1024
  let default_cache_size = 128
  let large_cache_size = 512
  let utf8_char_max_bytes = 4
  let utf8_char_buffer_size = 8
  let string_slice_length = 3
  let percentage_multiplier = 100.0
  let max_recursion_depth = 1000
  let default_timeout_ms = 5000
  let file_chunk_size = 8192
  let max_file_size = 1048576
  let max_verse_length = 32
  let max_poem_lines = 100
  let default_rhyme_scheme_length = 8
end

(** 数值常量 *)
module Numbers = struct
  let zero = 0
  let one = 1
  let two = 2
  let three = 3
  let four = 4
  let five = 5
  let ten = 10
  let hundred = 100
  let thousand = 1000
  let zero_float = 0.0
  let one_float = 1.0
  let half_float = 0.5
  let pi = 3.14159265359
  let full_percentage = 100.0
  let half_percentage = 50.0
  let quarter_percentage = 25.0
  let type_complexity_basic = 1
  let type_complexity_composite = 2
end

(** C运行时函数名称常量 *)
module RuntimeFunctions = struct
  let add = "luoyan_add"
  let subtract = "luoyan_subtract"
  let multiply = "luoyan_multiply"
  let divide = "luoyan_divide"
  let modulo = "luoyan_modulo"
  let equal = "luoyan_equal"
  let not_equal = "luoyan_not_equal"
  let less_than = "luoyan_less_than"
  let greater_than = "luoyan_greater_than"
  let less_equal = "luoyan_less_equal"
  let greater_equal = "luoyan_greater_equal"
  let logical_and = "luoyan_logical_and"
  let logical_or = "luoyan_logical_or"
  let concat = "luoyan_concat"
  let logical_not = "luoyan_logical_not"
  let int_zero = "luoyan_int(0)"
  let ref_create = "luoyan_ref"
  let deref = "luoyan_deref"
  let assign = "luoyan_assign"
  let c_extension = ".c"
  let ly_extension = ".ly"
  let temp_extension = ".tmp"
end
