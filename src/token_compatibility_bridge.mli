(** Token兼容性桥接接口 - 技术债务清理 Issue #1375 *)

open Token_unified

exception Incompatible_token of string
(** 转换异常 *)

exception Legacy_conversion_failed of string

val to_lexer_token : unified_token -> Lexer_tokens.token
(** 将统一Token转换为旧版本Token *)

val from_lexer_token : Lexer_tokens.token -> unified_token
(** 从旧版本Token转换为统一Token *)

val to_lexer_tokens : unified_token list -> Lexer_tokens.token list
(** 批量转换：统一Token列表 -> 旧Token列表 *)

val from_lexer_tokens : Lexer_tokens.token list -> unified_token list
(** 批量转换：旧Token列表 -> 统一Token列表 *)

val verify_conversion : unified_token -> bool
(** 转换验证：检查转换是否保持一致性 *)

val is_compatible_with_legacy : unified_token -> bool
(** 兼容性检查：检查Token是否可以安全转换 *)

val safe_to_lexer_token : unified_token -> Lexer_tokens.token
(** 安全转换：失败时返回默认Token *)

val safe_from_lexer_token : Lexer_tokens.token -> unified_token
(** 安全转换：失败时返回Error Token *)
