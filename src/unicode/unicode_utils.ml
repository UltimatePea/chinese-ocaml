(** Unicode字符检查和工具函数 *)

open Unicode_types

(** 全角数字范围处理 *)
module FullwidthDigit = struct
  let start_byte3 = 0x90 (* ０ *)
  let end_byte3 = 0x99 (* ９ *)
  let is_fullwidth_digit byte3 = byte3 >= start_byte3 && byte3 <= end_byte3
end

(** 便捷检查函数 *)
module Checks = struct
  let is_chinese_punctuation_prefix byte = byte = Prefix.chinese_punctuation
  let is_chinese_operator_prefix byte = byte = Prefix.chinese_operator
  let is_arrow_symbol_prefix byte = byte = Prefix.arrow_symbol
  let is_fullwidth_prefix byte = byte = Prefix.fullwidth
end
