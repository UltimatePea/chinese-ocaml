(** 简化的Token兼容性桥接模块 - 技术债务清理 Issue #1375
    
    提供基本的兼容性支持，允许渐进式迁移。
    这是一个简化版本，避免复杂的构造器映射问题。
    
    Author: Beta, 代码审查专员
    Date: 2025-07-26 *)

open Token_unified

(** 转换异常 *)
exception Incompatible_token of string
exception Legacy_conversion_failed of string

(** 安全转换：统一Token -> 字符串 -> 旧Token系统 *)
let safe_to_legacy_string token =
  Utils.token_to_string token

(** 安全转换：从字符串创建统一Token *)
let safe_from_legacy_string str =
  match Token_converter_unified.convert str with
  | Some token -> token
  | None -> Error ("Failed to convert: " ^ str)

(** 检查Token是否可以安全转换 *)
let is_compatible_with_legacy = function
  | Error _ -> false
  | _ -> true

(** 获取Token的兼容性信息 *)
let get_compatibility_info token =
  let category = Utils.get_category token in
  let str_repr = Utils.token_to_string token in
  let compatible = is_compatible_with_legacy token in
  (category, str_repr, compatible)

(** 批量转换：统一Token列表 -> 字符串列表 *)
let tokens_to_strings tokens =
  List.map Utils.token_to_string tokens

(** 批量转换：字符串列表 -> 统一Token列表 *)
let strings_to_tokens strings =
  List.map safe_from_legacy_string strings