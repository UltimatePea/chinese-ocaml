(** 骆言词法分析器基础关键字表模块接口 *)

open Token_types

(** 基础关键字组 *)
val basic_keywords : (string * Keywords.keyword_token) list

(** 语义类型系统关键字组 *)
val semantic_keywords : (string * Keywords.keyword_token) list

(** 错误恢复关键字组 *)
val error_recovery_keywords : (string * Keywords.keyword_token) list

(** 异常处理关键字组 *)
val exception_keywords : (string * Keywords.keyword_token) list

(** 模块系统关键字组 *)
val module_keywords : (string * Keywords.keyword_token) list

(** 获取所有基础关键字组合 *)
val get_all_basic_keywords : unit -> (string * Keywords.keyword_token) list