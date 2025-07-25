(** 骆言编译器Unicode字符处理常量模块 - 统一版本 *)

(* 重新导出核心类型和模块 *)
include Unicode.Unicode_types

(* 重新导出所有子模块 *)
module Range = Unicode.Unicode_types.Range
module Prefix = Unicode.Unicode_types.Prefix
module CharMap = Unicode.Unicode_mapping.CharMap
module Legacy = Unicode.Unicode_mapping.Legacy
module FullwidthDigit = Unicode.Unicode_utils.FullwidthDigit
module Checks = Unicode.Unicode_utils.Checks
module CharConstants = Unicode.Unicode_chars.CharConstants
module Compatibility = Unicode.Unicode_compatibility.Compatibility

(** 字符定义数据重新导出 *)
let char_definitions = Unicode.Unicode_types.char_definitions

(* 保持向后兼容性：保留现有模块结构和导出 *)
