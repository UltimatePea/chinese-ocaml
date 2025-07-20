(** 骆言词法分析器 - 重构后的工具函数模块 - 向后兼容性接口 *)

(** 导入所有子模块 *)
module StringParsing = String_parsing
module EscapeProcessing = Escape_processing
module ChineseNumberProcessing = Chinese_number_processing
module FullwidthNumberProcessing = Fullwidth_number_processing
module ChinesePunctuationRecognition = Chinese_punctuation_recognition

(** 导入统一的UTF-8字符处理函数 *)
let is_chinese_char = Utf8_utils.is_chinese_char
let is_letter_or_chinese = Utf8_utils.is_letter_or_chinese
let is_digit = Utf8_utils.is_digit
let is_whitespace = Utf8_utils.is_whitespace
let is_separator_char = Utf8_utils.is_separator_char
let is_chinese_utf8 = Utf8_utils.is_chinese_utf8
let next_utf8_char = Utf8_utils.next_utf8_char_uutf
let is_chinese_digit_char = Utf8_utils.is_chinese_digit_char

(** 向后兼容的函数别名 *)
let read_string_until = StringParsing.read_string_until
let parse_integer = StringParsing.parse_integer
let parse_float = StringParsing.parse_float
let parse_hex_int = StringParsing.parse_hex_int
let parse_oct_int = StringParsing.parse_oct_int
let parse_bin_int = StringParsing.parse_bin_int

let process_escape_sequences = EscapeProcessing.process_escape_sequences
let is_all_digits = EscapeProcessing.is_all_digits
let is_valid_identifier = EscapeProcessing.is_valid_identifier

let read_chinese_number_sequence = ChineseNumberProcessing.read_chinese_number_sequence
let convert_chinese_number_sequence = ChineseNumberProcessing.convert_chinese_number_sequence

let read_fullwidth_number_sequence = FullwidthNumberProcessing.read_fullwidth_number_sequence
let convert_fullwidth_number_sequence = FullwidthNumberProcessing.convert_fullwidth_number_sequence

let recognize_chinese_punctuation = ChinesePunctuationRecognition.recognize_chinese_punctuation
let recognize_pipe_right_bracket = ChinesePunctuationRecognition.recognize_pipe_right_bracket
