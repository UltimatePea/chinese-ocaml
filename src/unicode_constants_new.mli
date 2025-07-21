(** 骆言编译器Unicode字符处理常量模块接口 - 重构版本

    本模块重新导出Unicode处理相关的核心类型、模块和函数， 提供向后兼容性支持。是Unicode模块的新版本接口。

    @author 骆言团队
    @since 2025-07-20 *)

include module type of Unicode.Unicode_types
(** 重新导出核心类型 *)

module CharMap : module type of Unicode.Unicode_mapping.CharMap
(** 重新导出子模块 *)

module Legacy : module type of Unicode.Unicode_mapping.Legacy
module FullwidthDigit : module type of Unicode.Unicode_utils.FullwidthDigit
module Checks : module type of Unicode.Unicode_utils.Checks
module CharConstants : module type of Unicode.Unicode_chars.CharConstants
module Compatibility : module type of Unicode.Unicode_compatibility.Compatibility

(** 向后兼容性常量和函数 *)

val chinese_char_start : int
(** 中文字符范围常量 *)

val chinese_char_mid_start : int
val chinese_char_mid_end : int
val chinese_char_threshold : int

val chinese_punctuation_prefix : string
(** 中文字符前缀常量 *)

val chinese_operator_prefix : string
val arrow_symbol_prefix : string
val fullwidth_prefix : string

val is_chinese_punctuation_prefix : string -> bool
(** 中文字符检查函数 *)

val is_chinese_operator_prefix : string -> bool
val is_arrow_symbol_prefix : string -> bool
val is_fullwidth_prefix : string -> bool

val is_fullwidth_digit : string -> bool
(** 全角数字检查函数 *)
