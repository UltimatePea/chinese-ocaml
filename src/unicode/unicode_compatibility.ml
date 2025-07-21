(** 向后兼容性模块 - 保持原有接口 *)

open Unicode_types
open Unicode_mapping

(** 向后兼容性别名 - 保持原有常量名 *)
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

  (* 助手函数：获取字符的字节组合 *)
  let get_char_bytes char_name =
    match Legacy.find_char_by_name char_name with
    | Some char_str -> (
        match Legacy.find_triple_by_char char_str with
        | Some triple -> (triple.byte1, triple.byte2, triple.byte3)
        | None -> (0, 0, 0))
    | None -> (0, 0, 0)

  (* 获取三字节组合的向后兼容函数 *)
  let left_quote_bytes = get_char_bytes "left_quote"
  let right_quote_bytes = get_char_bytes "right_quote"
  let string_start_bytes = get_char_bytes "string_start"
  let string_end_bytes = get_char_bytes "string_end"
  let chinese_left_paren_bytes = get_char_bytes "chinese_left_paren"
  let chinese_right_paren_bytes = get_char_bytes "chinese_right_paren"
  let chinese_comma_bytes = get_char_bytes "chinese_comma"
  let chinese_colon_bytes = get_char_bytes "chinese_colon"
  let chinese_period_bytes = get_char_bytes "chinese_period"

  (* 引号字节访问器 - 直接计算 *)
  let left_quote_byte1 = let b1, _, _ = left_quote_bytes in b1
  let left_quote_byte2 = let _, b2, _ = left_quote_bytes in b2
  let left_quote_byte3 = let _, _, b3 = left_quote_bytes in b3
  let right_quote_byte1 = let b1, _, _ = right_quote_bytes in b1
  let right_quote_byte2 = let _, b2, _ = right_quote_bytes in b2
  let right_quote_byte3 = let _, _, b3 = right_quote_bytes in b3
  let string_start_byte1 = let b1, _, _ = string_start_bytes in b1
  let string_start_byte2 = let _, b2, _ = string_start_bytes in b2
  let string_start_byte3 = let _, _, b3 = string_start_bytes in b3
  let string_end_byte1 = let b1, _, _ = string_end_bytes in b1
  let string_end_byte2 = let _, b2, _ = string_end_bytes in b2
  let string_end_byte3 = let _, _, b3 = string_end_bytes in b3

  (* 中文标点符号字节访问器 - 直接计算 *)
  let chinese_left_paren_byte1 = let b1, _, _ = chinese_left_paren_bytes in b1
  let chinese_left_paren_byte2 = let _, b2, _ = chinese_left_paren_bytes in b2
  let chinese_left_paren_byte3 = let _, _, b3 = chinese_left_paren_bytes in b3
  let chinese_right_paren_byte1 = let b1, _, _ = chinese_right_paren_bytes in b1
  let chinese_right_paren_byte2 = let _, b2, _ = chinese_right_paren_bytes in b2
  let chinese_right_paren_byte3 = let _, _, b3 = chinese_right_paren_bytes in b3
  let chinese_comma_byte1 = let b1, _, _ = chinese_comma_bytes in b1
  let chinese_comma_byte2 = let _, b2, _ = chinese_comma_bytes in b2
  let chinese_comma_byte3 = let _, _, b3 = chinese_comma_bytes in b3
  let chinese_colon_byte1 = let b1, _, _ = chinese_colon_bytes in b1
  let chinese_colon_byte2 = let _, b2, _ = chinese_colon_bytes in b2
  let chinese_colon_byte3 = let _, _, b3 = chinese_colon_bytes in b3
  let chinese_period_byte1 = let b1, _, _ = chinese_period_bytes in b1
  let chinese_period_byte2 = let _, b2, _ = chinese_period_bytes in b2
  let chinese_period_byte3 = let _, _, b3 = chinese_period_bytes in b3

  (* 添加缺失的全角字符字节定义 - 使用正确的字符名称 *)
  let fullwidth_left_paren_bytes = get_char_bytes "chinese_left_paren"
  let fullwidth_right_paren_bytes = get_char_bytes "chinese_right_paren"
  let fullwidth_comma_bytes = get_char_bytes "chinese_comma"
  let fullwidth_colon_bytes = get_char_bytes "chinese_colon"

  (* 注意：以下字符未在字符定义中定义，使用默认值 *)
  let fullwidth_semicolon_bytes = (0xEF, 0xBC, 0x9B) (* ； *)
  let fullwidth_pipe_bytes = (0xEF, 0xBD, 0x9C) (* ｜ *)
  let fullwidth_period_bytes = get_char_bytes "chinese_period"
  let chinese_minus_bytes = (0, 0, 0)

  (* 中文方括号【】 - E3 80 90/91 *)
  let chinese_square_left_bracket_bytes = (0xE3, 0x80, 0x90) (* 【 *)
  let chinese_square_right_bracket_bytes = (0xE3, 0x80, 0x91) (* 】 *)

  (* 箭头符号 - E2开头 *)
  let chinese_arrow_bytes = (0xE2, 0x86, 0x92) (* → *)
  let chinese_double_arrow_bytes = (0xE2, 0x87, 0x92) (* ⇒ *)
  let chinese_assign_arrow_bytes = (0xE2, 0x86, 0x90) (* ← *)

  (* 全角符号范围常量 *)
  let fullwidth_start_byte1 = 0xEF
  let fullwidth_start_byte2 = 0xBC

  (* 全角符号字节访问器 - 直接计算 *)
  let fullwidth_left_paren_byte3 = let _, _, b3 = fullwidth_left_paren_bytes in b3
  let fullwidth_right_paren_byte3 = let _, _, b3 = fullwidth_right_paren_bytes in b3
  let fullwidth_comma_byte3 = let _, _, b3 = fullwidth_comma_bytes in b3
  let fullwidth_colon_byte3 = let _, _, b3 = fullwidth_colon_bytes in b3
  let fullwidth_semicolon_byte3 = let _, _, b3 = fullwidth_semicolon_bytes in b3
  let fullwidth_pipe_byte1 = let b1, _, _ = fullwidth_pipe_bytes in b1
  let fullwidth_pipe_byte2 = let _, b2, _ = fullwidth_pipe_bytes in b2
  let fullwidth_pipe_byte3 = let _, _, b3 = fullwidth_pipe_bytes in b3
  let fullwidth_period_byte3 = let _, _, b3 = fullwidth_period_bytes in b3

  (* 中文注释符号字节访问器 - 直接计算 *)
  let comment_colon_byte1 = let b1, _, _ = fullwidth_colon_bytes in b1
  let comment_colon_byte2 = let _, b2, _ = fullwidth_colon_bytes in b2
  let comment_colon_byte3 = let _, _, b3 = fullwidth_colon_bytes in b3

  (* 中文操作符字节访问器 - 直接计算 *)
  let chinese_minus_byte1 = let b1, _, _ = chinese_minus_bytes in b1
  let chinese_minus_byte2 = let _, b2, _ = chinese_minus_bytes in b2
  let chinese_minus_byte3 = let _, _, b3 = chinese_minus_bytes in b3

  (* 中文方括号字节访问器 - 直接计算 *)
  let chinese_square_left_bracket_byte1 = let b1, _, _ = chinese_square_left_bracket_bytes in b1
  let chinese_square_left_bracket_byte2 = let _, b2, _ = chinese_square_left_bracket_bytes in b2
  let chinese_square_left_bracket_byte3 = let _, _, b3 = chinese_square_left_bracket_bytes in b3
  let chinese_square_right_bracket_byte1 = let b1, _, _ = chinese_square_right_bracket_bytes in b1
  let chinese_square_right_bracket_byte2 = let _, b2, _ = chinese_square_right_bracket_bytes in b2
  let chinese_square_right_bracket_byte3 = let _, _, b3 = chinese_square_right_bracket_bytes in b3

  (* 箭头符号字节访问器 - 直接计算 *)
  let chinese_arrow_byte1 = let b1, _, _ = chinese_arrow_bytes in b1
  let chinese_arrow_byte2 = let _, b2, _ = chinese_arrow_bytes in b2
  let chinese_arrow_byte3 = let _, _, b3 = chinese_arrow_bytes in b3
  let chinese_double_arrow_byte1 = let b1, _, _ = chinese_double_arrow_bytes in b1
  let chinese_double_arrow_byte2 = let _, b2, _ = chinese_double_arrow_bytes in b2
  let chinese_double_arrow_byte3 = let _, _, b3 = chinese_double_arrow_bytes in b3
  let chinese_assign_arrow_byte1 = let b1, _, _ = chinese_assign_arrow_bytes in b1
  let chinese_assign_arrow_byte2 = let _, b2, _ = chinese_assign_arrow_bytes in b2
  let chinese_assign_arrow_byte3 = let _, _, b3 = chinese_assign_arrow_bytes in b3

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
