(** 骆言词法分析器 - 字符处理工具模块 *)

open Lexer_state

(** 导入统一的UTF-8字符处理函数 *)
let is_chinese_char = Utf8_utils.is_chinese_char

let is_letter_or_chinese = Utf8_utils.is_letter_or_chinese
let is_digit = Utf8_utils.is_digit
let is_whitespace = Utf8_utils.is_whitespace
let is_separator_char = Utf8_utils.is_separator_char

(** 使用统一的UTF-8字符串处理函数 *)
let is_chinese_utf8 = Utf8_utils.is_chinese_utf8

let next_utf8_char = Utf8_utils.next_utf8_char_uutf (* 使用Uutf兼容版本 *)
let is_chinese_digit_char = Utf8_utils.is_chinese_digit_char

(** 使用统一的字符串验证函数 *)
let is_all_digits = Utf8_utils.is_all_digits

let is_valid_identifier = Utf8_utils.is_valid_identifier

(** 获取当前字符 *)
let get_current_char state =
  if state.position >= state.length then None else Some state.input.[state.position]

(** 检查UTF-8字符 *)
let check_utf8_char state _byte1 byte2 byte3 =
  state.position + 2 < state.length
  && Char.code state.input.[state.position + 1] = byte2
  && Char.code state.input.[state.position + 2] = byte3

(** 创建新状态 *)
let make_new_state state =
  { state with position = state.position + 3; current_column = state.current_column + 1 }

(** 创建不支持字符错误 *)
let create_unsupported_char_error state pos =
  let char_bytes =
    String.sub state.input state.position Constants.SystemConfig.string_slice_length
  in
  raise (Lexer_tokens.LexError (Constants.ErrorMessages.unsupported_char_error char_bytes, pos))
