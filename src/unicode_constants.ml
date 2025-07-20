(** 骆言编译器Unicode字符处理常量模块 - 向后兼容性包装器 *)

(** 类型定义重新导出 *)
include Unicode.Unicode_types

(** 模块重新导出 *)
module Range = Unicode.Unicode_types.Range
module Prefix = Unicode.Unicode_types.Prefix

(** 字符定义数据重新导出 *)
let char_definitions = Unicode.Unicode_types.char_definitions

(** 模块重新导出 *)
module CharMap = Unicode.Unicode_mapping.CharMap
module FullwidthDigit = Unicode.Unicode_utils.FullwidthDigit
module CharConstants = Unicode.Unicode_chars.CharConstants

(** 模块重新导出 *)
module Checks = Unicode.Unicode_utils.Checks
module Legacy = Unicode.Unicode_mapping.Legacy

(** 向后兼容性别名模块重新导出 *)
module Compatibility = Unicode.Unicode_compatibility.Compatibility
