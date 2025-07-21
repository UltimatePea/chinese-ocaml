(** 向后兼容性核心模块 - 保持原有接口并整合各子模块 *)

open Unicode_types

(** 向后兼容性别名 - 保持原有常量名和接口 *)
module Compatibility = struct
  (* 原UTF8模块的向后兼容别名 *)
  let chinese_char_start = Range.chinese_char_start
  let chinese_char_mid_start = Range.chinese_char_mid_start
  let chinese_char_mid_end = Range.chinese_char_mid_end
  let chinese_char_threshold = Range.chinese_char_threshold
  let chinese_punctuation_prefix = Prefix.chinese_punctuation
  let chinese_operator_prefix = Prefix.chinese_operator
  let arrow_symbol_prefix = Prefix.arrow_symbol
  let fullwidth_prefix = Prefix.fullwidth

  (* 助手函数：获取字符的字节组合 - 保持原有接口 *)
  let get_char_bytes = Char_byte_definitions.get_char_bytes

  (* 获取三字节组合的向后兼容函数 *)
  let left_quote_bytes = Char_byte_definitions.Quote.left_quote_bytes
  let right_quote_bytes = Char_byte_definitions.Quote.right_quote_bytes
  let string_start_bytes = Char_byte_definitions.Quote.string_start_bytes
  let string_end_bytes = Char_byte_definitions.Quote.string_end_bytes
  let chinese_left_paren_bytes = Char_byte_definitions.ChinesePunctuation.chinese_left_paren_bytes
  let chinese_right_paren_bytes = Char_byte_definitions.ChinesePunctuation.chinese_right_paren_bytes
  let chinese_comma_bytes = Char_byte_definitions.ChinesePunctuation.chinese_comma_bytes
  let chinese_colon_bytes = Char_byte_definitions.ChinesePunctuation.chinese_colon_bytes
  let chinese_period_bytes = Char_byte_definitions.ChinesePunctuation.chinese_period_bytes

  (* 引号字节访问器 *)
  let left_quote_byte1 = Char_byte_accessors.Quote.left_quote_byte1
  let left_quote_byte2 = Char_byte_accessors.Quote.left_quote_byte2
  let left_quote_byte3 = Char_byte_accessors.Quote.left_quote_byte3
  let right_quote_byte1 = Char_byte_accessors.Quote.right_quote_byte1
  let right_quote_byte2 = Char_byte_accessors.Quote.right_quote_byte2
  let right_quote_byte3 = Char_byte_accessors.Quote.right_quote_byte3
  let string_start_byte1 = Char_byte_accessors.Quote.string_start_byte1
  let string_start_byte2 = Char_byte_accessors.Quote.string_start_byte2
  let string_start_byte3 = Char_byte_accessors.Quote.string_start_byte3
  let string_end_byte1 = Char_byte_accessors.Quote.string_end_byte1
  let string_end_byte2 = Char_byte_accessors.Quote.string_end_byte2
  let string_end_byte3 = Char_byte_accessors.Quote.string_end_byte3

  (* 中文标点符号字节访问器 *)
  let chinese_left_paren_byte1 = Char_byte_accessors.ChinesePunctuation.chinese_left_paren_byte1
  let chinese_left_paren_byte2 = Char_byte_accessors.ChinesePunctuation.chinese_left_paren_byte2
  let chinese_left_paren_byte3 = Char_byte_accessors.ChinesePunctuation.chinese_left_paren_byte3
  let chinese_right_paren_byte1 = Char_byte_accessors.ChinesePunctuation.chinese_right_paren_byte1
  let chinese_right_paren_byte2 = Char_byte_accessors.ChinesePunctuation.chinese_right_paren_byte2
  let chinese_right_paren_byte3 = Char_byte_accessors.ChinesePunctuation.chinese_right_paren_byte3
  let chinese_comma_byte1 = Char_byte_accessors.ChinesePunctuation.chinese_comma_byte1
  let chinese_comma_byte2 = Char_byte_accessors.ChinesePunctuation.chinese_comma_byte2
  let chinese_comma_byte3 = Char_byte_accessors.ChinesePunctuation.chinese_comma_byte3
  let chinese_colon_byte1 = Char_byte_accessors.ChinesePunctuation.chinese_colon_byte1
  let chinese_colon_byte2 = Char_byte_accessors.ChinesePunctuation.chinese_colon_byte2
  let chinese_colon_byte3 = Char_byte_accessors.ChinesePunctuation.chinese_colon_byte3
  let chinese_period_byte1 = Char_byte_accessors.ChinesePunctuation.chinese_period_byte1
  let chinese_period_byte2 = Char_byte_accessors.ChinesePunctuation.chinese_period_byte2
  let chinese_period_byte3 = Char_byte_accessors.ChinesePunctuation.chinese_period_byte3

  (* 添加缺失的全角字符字节定义 *)
  let fullwidth_left_paren_bytes = Char_byte_definitions.Fullwidth.fullwidth_left_paren_bytes
  let fullwidth_right_paren_bytes = Char_byte_definitions.Fullwidth.fullwidth_right_paren_bytes
  let fullwidth_comma_bytes = Char_byte_definitions.Fullwidth.fullwidth_comma_bytes
  let fullwidth_colon_bytes = Char_byte_definitions.Fullwidth.fullwidth_colon_bytes
  let fullwidth_semicolon_bytes = Char_byte_definitions.Fullwidth.fullwidth_semicolon_bytes
  let fullwidth_pipe_bytes = Char_byte_definitions.Fullwidth.fullwidth_pipe_bytes
  let fullwidth_period_bytes = Char_byte_definitions.Fullwidth.fullwidth_period_bytes
  let chinese_minus_bytes = Char_byte_definitions.OtherSymbols.chinese_minus_bytes

  (* 中文方括号【】 *)
  let chinese_square_left_bracket_bytes = Char_byte_definitions.OtherSymbols.chinese_square_left_bracket_bytes
  let chinese_square_right_bracket_bytes = Char_byte_definitions.OtherSymbols.chinese_square_right_bracket_bytes

  (* 箭头符号 *)
  let chinese_arrow_bytes = Char_byte_definitions.OtherSymbols.chinese_arrow_bytes
  let chinese_double_arrow_bytes = Char_byte_definitions.OtherSymbols.chinese_double_arrow_bytes
  let chinese_assign_arrow_bytes = Char_byte_definitions.OtherSymbols.chinese_assign_arrow_bytes

  (* 全角符号范围常量 *)
  let fullwidth_start_byte1 = Char_byte_definitions.FullwidthRanges.fullwidth_start_byte1
  let fullwidth_start_byte2 = Char_byte_definitions.FullwidthRanges.fullwidth_start_byte2

  (* 全角符号字节访问器 *)
  let fullwidth_left_paren_byte3 = Char_byte_accessors.Fullwidth.fullwidth_left_paren_byte3
  let fullwidth_right_paren_byte3 = Char_byte_accessors.Fullwidth.fullwidth_right_paren_byte3
  let fullwidth_comma_byte3 = Char_byte_accessors.Fullwidth.fullwidth_comma_byte3
  let fullwidth_colon_byte3 = Char_byte_accessors.Fullwidth.fullwidth_colon_byte3
  let fullwidth_semicolon_byte3 = Char_byte_accessors.Fullwidth.fullwidth_semicolon_byte3
  let fullwidth_pipe_byte1 = Char_byte_accessors.Fullwidth.fullwidth_pipe_byte1
  let fullwidth_pipe_byte2 = Char_byte_accessors.Fullwidth.fullwidth_pipe_byte2
  let fullwidth_pipe_byte3 = Char_byte_accessors.Fullwidth.fullwidth_pipe_byte3
  let fullwidth_period_byte3 = Char_byte_accessors.Fullwidth.fullwidth_period_byte3

  (* 中文注释符号字节访问器 *)
  let comment_colon_byte1 = Char_byte_accessors.Fullwidth.comment_colon_byte1
  let comment_colon_byte2 = Char_byte_accessors.Fullwidth.comment_colon_byte2
  let comment_colon_byte3 = Char_byte_accessors.Fullwidth.comment_colon_byte3

  (* 中文操作符字节访问器 *)
  let chinese_minus_byte1 = Char_byte_accessors.OtherSymbols.chinese_minus_byte1
  let chinese_minus_byte2 = Char_byte_accessors.OtherSymbols.chinese_minus_byte2
  let chinese_minus_byte3 = Char_byte_accessors.OtherSymbols.chinese_minus_byte3

  (* 中文方括号字节访问器 *)
  let chinese_square_left_bracket_byte1 = Char_byte_accessors.OtherSymbols.chinese_square_left_bracket_byte1
  let chinese_square_left_bracket_byte2 = Char_byte_accessors.OtherSymbols.chinese_square_left_bracket_byte2
  let chinese_square_left_bracket_byte3 = Char_byte_accessors.OtherSymbols.chinese_square_left_bracket_byte3
  let chinese_square_right_bracket_byte1 = Char_byte_accessors.OtherSymbols.chinese_square_right_bracket_byte1
  let chinese_square_right_bracket_byte2 = Char_byte_accessors.OtherSymbols.chinese_square_right_bracket_byte2
  let chinese_square_right_bracket_byte3 = Char_byte_accessors.OtherSymbols.chinese_square_right_bracket_byte3

  (* 箭头符号字节访问器 *)
  let chinese_arrow_byte1 = Char_byte_accessors.OtherSymbols.chinese_arrow_byte1
  let chinese_arrow_byte2 = Char_byte_accessors.OtherSymbols.chinese_arrow_byte2
  let chinese_arrow_byte3 = Char_byte_accessors.OtherSymbols.chinese_arrow_byte3
  let chinese_double_arrow_byte1 = Char_byte_accessors.OtherSymbols.chinese_double_arrow_byte1
  let chinese_double_arrow_byte2 = Char_byte_accessors.OtherSymbols.chinese_double_arrow_byte2
  let chinese_double_arrow_byte3 = Char_byte_accessors.OtherSymbols.chinese_double_arrow_byte3
  let chinese_assign_arrow_byte1 = Char_byte_accessors.OtherSymbols.chinese_assign_arrow_byte1
  let chinese_assign_arrow_byte2 = Char_byte_accessors.OtherSymbols.chinese_assign_arrow_byte2
  let chinese_assign_arrow_byte3 = Char_byte_accessors.OtherSymbols.chinese_assign_arrow_byte3

  (* 全角数字范围 *)
  let fullwidth_digit_start = Unicode_utils.FullwidthDigit.start_byte3
  let fullwidth_digit_end = Unicode_utils.FullwidthDigit.end_byte3

  (* 字符常量的重新导出 *)
  let char_xe3 = Unicode_chars.CharConstants.char_xe3
  let char_x80 = Unicode_chars.CharConstants.char_x80
  let char_x8e = Unicode_chars.CharConstants.char_x8e
  let char_x8f = Unicode_chars.CharConstants.char_x8f
  let char_xef = Unicode_chars.CharConstants.char_xef
  let char_xbc = Unicode_chars.CharConstants.char_xbc
  let char_xbd = Unicode_chars.CharConstants.char_xbd
  let char_x9c = Unicode_chars.CharConstants.char_x9c
  let char_xe8 = Unicode_chars.CharConstants.char_xe8
  let char_xb4 = Unicode_chars.CharConstants.char_xb4
  let char_x9f = Unicode_chars.CharConstants.char_x9f
  let char_xe2 = Unicode_chars.CharConstants.char_xe2

  (* 检查函数的重新导出 *)
  let is_chinese_punctuation_prefix = Unicode_utils.Checks.is_chinese_punctuation_prefix
  let is_chinese_operator_prefix = Unicode_utils.Checks.is_chinese_operator_prefix
  let is_arrow_symbol_prefix = Unicode_utils.Checks.is_arrow_symbol_prefix
  let is_fullwidth_prefix = Unicode_utils.Checks.is_fullwidth_prefix

  (* 全角数字检查的重新导出 *)
  let is_fullwidth_digit = Unicode_utils.FullwidthDigit.is_fullwidth_digit
end