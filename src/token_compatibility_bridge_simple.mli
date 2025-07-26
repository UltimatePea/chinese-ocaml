(** 简化的Token兼容性桥接接口 - 技术债务清理 Issue #1375 *)

open Token_unified

exception Incompatible_token of string
(** 转换异常 *)

exception Legacy_conversion_failed of string

val safe_to_legacy_string : unified_token -> string
(** 安全转换：统一Token -> 字符串表示 *)

val safe_from_legacy_string : string -> unified_token
(** 安全转换：从字符串创建统一Token *)

val is_compatible_with_legacy : unified_token -> bool
(** 检查Token是否可以安全转换 *)

val get_compatibility_info :
  unified_token ->
  [ `Literal | `Identifier | `Keyword | `Operator | `Delimiter | `Special ] * string * bool
(** 获取Token的兼容性信息 *)

val tokens_to_strings : unified_token list -> string list
(** 批量转换：统一Token列表 -> 字符串列表 *)

val strings_to_tokens : string list -> unified_token list
(** 批量转换：字符串列表 -> 统一Token列表 *)
