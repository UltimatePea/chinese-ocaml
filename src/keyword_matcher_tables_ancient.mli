(** 骆言词法分析器古雅体和诗词关键字表模块接口 *)

open Token_types

val ancient_keywords : (string * Keywords.keyword_token) list
(** 古雅体增强关键字组 *)

val get_all_ancient_keywords : unit -> (string * Keywords.keyword_token) list
(** 获取所有古雅体和诗词关键字组合 *)
