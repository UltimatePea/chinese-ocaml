(** 骆言词法分析器基础关键字表模块接口 *)

open Lexer_tokens

val basic_keywords : (string * token) list
(** 基础关键字组 *)

val semantic_keywords : (string * token) list
(** 语义类型系统关键字组 *)

val error_recovery_keywords : (string * token) list
(** 错误恢复关键字组 *)

val exception_keywords : (string * token) list
(** 异常处理关键字组 *)

val module_keywords : (string * token) list
(** 模块系统关键字组 *)

val get_all_basic_keywords : unit -> (string * token) list
(** 获取所有基础关键字组合 *)
