(** 骆言编译器Unicode字符处理常量模块 - 重构版本 *)

(* 重新导出核心类型和模块 *)
include Unicode.Unicode_types

(* 重新导出所有子模块 *)
module CharMap = Unicode.Unicode_mapping.CharMap
module Legacy = Unicode.Unicode_mapping.Legacy
module FullwidthDigit = Unicode.Unicode_utils.FullwidthDigit
module Checks = Unicode.Unicode_utils.Checks
module CharConstants = Unicode.Unicode_chars.CharConstants
module Compatibility = Unicode.Unicode_compatibility.Compatibility

(* 向后兼容性：直接导出常用函数和常量 *)
let chinese_char_start = Range.chinese_char_start
let chinese_char_mid_start = Range.chinese_char_mid_start
let chinese_char_mid_end = Range.chinese_char_mid_end
let chinese_char_threshold = Range.chinese_char_threshold

let chinese_punctuation_prefix = Prefix.chinese_punctuation
let chinese_operator_prefix = Prefix.chinese_operator
let arrow_symbol_prefix = Prefix.arrow_symbol
let fullwidth_prefix = Prefix.fullwidth

let is_chinese_punctuation_prefix = Checks.is_chinese_punctuation_prefix
let is_chinese_operator_prefix = Checks.is_chinese_operator_prefix
let is_arrow_symbol_prefix = Checks.is_arrow_symbol_prefix
let is_fullwidth_prefix = Checks.is_fullwidth_prefix

let is_fullwidth_digit = FullwidthDigit.is_fullwidth_digit