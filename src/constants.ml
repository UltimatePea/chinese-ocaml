(** 骆言编译器常量定义模块 *)

(** UTF-8字符检测常量 *)
module UTF8 = struct
  (** 中文字符范围检测 *)
  let chinese_char_start = 0xE4
  let chinese_char_mid_start = 0xE5  
  let chinese_char_mid_end = 0xE9
  let chinese_char_threshold = 128
  
  (** 特定UTF-8字符码点 *)
  let left_quote_byte1 = 0xE3   (* 「 *)
  let left_quote_byte2 = 0x80
  let left_quote_byte3 = 0x8C
  
  let right_quote_byte1 = 0xE3  (* 」 *)
  let right_quote_byte2 = 0x80
  let right_quote_byte3 = 0x8D
  
  let string_start_byte1 = 0xE3  (* 『 *)
  let string_start_byte2 = 0x80
  let string_start_byte3 = 0x8E
  
  let string_end_byte1 = 0xE3    (* 』 *)
  let string_end_byte2 = 0x80
  let string_end_byte3 = 0x8F
  
  (** 全角符号范围 *)
  let fullwidth_start_byte1 = 0xEF
  let fullwidth_start_byte2 = 0xBC
  
  (** 中文标点符号 *)
  let chinese_period_byte1 = 0xE3   (* 。 *)
  let chinese_period_byte2 = 0x80
  let chinese_period_byte3 = 0x82
  
  let chinese_left_paren_byte3 = 0x88   (* （ *)
  let chinese_right_paren_byte3 = 0x89  (* ） *)
  let chinese_comma_byte3 = 0x8C        (* ， *)
  let chinese_colon_byte3 = 0x9A        (* ： *)
end

(** 缓冲区大小常量 *)
module BufferSizes = struct
  let default_buffer = 256
  let large_buffer = 512
  let report_buffer = 1024
  let utf8_char_buffer = 8
end

(** 百分比和置信度常量 *)
module Metrics = struct
  let confidence_multiplier = 100.0
  let full_confidence = 1.0
  let zero_confidence = 0.0
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
  (** 默认输出文件名 *)
  let default_c_output = "output.c"
  
  (** 临时文件前缀 *)
  let temp_file_prefix = "yyocamlc_test"
  
  (** 位置信息默认值 *)
  let default_position = 0
end

(** 错误消息模板 *)
module ErrorMessages = struct
  let undefined_variable var_name = 
    Printf.sprintf "未定义的变量: %s" var_name
    
  let module_not_found mod_name =
    Printf.sprintf "未定义的模块: %s" mod_name
    
  let member_not_found mod_name member_name =
    Printf.sprintf "模块 %s 中未找到成员: %s" mod_name member_name
    
  let empty_scope_stack = "尝试退出空作用域栈"
  
  let empty_variable_name = "空变量名"
  
  let unterminated_comment = "Unterminated comment"
  
  let unterminated_chinese_comment = "Unterminated Chinese comment"
  
  let unterminated_string = "Unterminated string"
  
  let unterminated_quoted_identifier = "未闭合的引用标识符"
  
  let invalid_char_in_quoted_identifier = "引用标识符中的无效字符"
  
  let ascii_symbols_disabled = "ASCII符号已禁用，请使用中文标点符号"
  
  let fullwidth_numbers_disabled = "只允许半角阿拉伯数字，请勿使用全角数字"
  
  let unsupported_chinese_symbol = "非支持的中文符号已禁用，只支持「」『』：，。（）"
  
  let identifiers_must_be_quoted = "标识符必须使用「」引用"
  
  let ascii_letters_as_keywords_only = "ASCII字母已禁用，只允许作为关键字使用"
end