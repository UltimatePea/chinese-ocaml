(** 骆言词法分析器ASCII关键字表模块接口 *)

open Token_types

val ascii_keywords : (string * Keywords.keyword_token) list
(** ASCII关键字映射表 *)

val get_ascii_keywords : unit -> (string * Keywords.keyword_token) list
(** 获取ASCII关键字列表 *)
