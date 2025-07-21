(** 骆言统一错误处理系统 - 错误转换模块接口 *)

open Error_types

val unified_error_to_string : unified_error -> string
(** 将统一错误转换为字符串 *)

val unified_error_to_exception : unified_error -> exn
(** 将统一错误转换为传统异常（向后兼容） *)