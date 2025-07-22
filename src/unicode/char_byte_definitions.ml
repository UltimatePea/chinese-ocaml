(** Unicode字符字节定义模块 - 包含所有字符的字节组合常量 *)

open Unicode_mapping

(** 助手函数：获取字符的字节组合 *)
let get_char_bytes char_name =
  match Legacy.find_char_by_name char_name with
  | Some char_str -> (
      match Legacy.find_triple_by_char char_str with
      | Some triple -> (triple.byte1, triple.byte2, triple.byte3)
      | None -> (0, 0, 0))
  | None -> (0, 0, 0)

(** 引号字符字节定义 *)
module Quote = struct
  let left_quote_bytes = get_char_bytes "left_quote"
  let right_quote_bytes = get_char_bytes "right_quote"
  let string_start_bytes = get_char_bytes "string_start"
  let string_end_bytes = get_char_bytes "string_end"
end

(** 中文标点符号字节定义 *)
module ChinesePunctuation = struct
  let chinese_left_paren_bytes = get_char_bytes "chinese_left_paren"
  let chinese_right_paren_bytes = get_char_bytes "chinese_right_paren"
  let chinese_comma_bytes = get_char_bytes "chinese_comma"
  let chinese_colon_bytes = get_char_bytes "chinese_colon"
  let chinese_period_bytes = get_char_bytes "chinese_period"
end

(** 全角字符字节定义 *)
module Fullwidth = struct
  let fullwidth_left_paren_bytes = get_char_bytes "chinese_left_paren"
  let fullwidth_right_paren_bytes = get_char_bytes "chinese_right_paren"
  let fullwidth_comma_bytes = get_char_bytes "chinese_comma"
  let fullwidth_colon_bytes = get_char_bytes "chinese_colon"
  let fullwidth_period_bytes = get_char_bytes "chinese_period"

  (* 注意：以下字符未在字符定义中定义，使用硬编码值 *)
  let fullwidth_semicolon_bytes = (0xEF, 0xBC, 0x9B) (* ； *)
  let fullwidth_pipe_bytes = (0xEF, 0xBD, 0x9C) (* ｜ *)
end

(** 其他中文符号字节定义 *)
module OtherSymbols = struct
  let chinese_minus_bytes = (0, 0, 0)

  (* 中文方括号【】 - E3 80 90/91 *)
  let chinese_square_left_bracket_bytes = (0xE3, 0x80, 0x90) (* 【 *)
  let chinese_square_right_bracket_bytes = (0xE3, 0x80, 0x91) (* 】 *)

  (* 箭头符号 - E2开头 *)
  let chinese_arrow_bytes = (0xE2, 0x86, 0x92) (* → *)
  let chinese_double_arrow_bytes = (0xE2, 0x87, 0x92) (* ⇒ *)
  let chinese_assign_arrow_bytes = (0xE2, 0x86, 0x90) (* ← *)
end

(** 全角符号范围常量 *)
module FullwidthRanges = struct
  let fullwidth_start_byte1 = 0xEF
  let fullwidth_start_byte2 = 0xBC
end
