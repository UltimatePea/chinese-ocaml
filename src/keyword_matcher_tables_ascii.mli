(** 骆言词法分析器ASCII关键字表模块接口 *)

open Lexer_tokens

val ascii_keywords : (string * token) list
(** ASCII关键字映射表 *)

val get_ascii_keywords : unit -> (string * token) list
(** 获取ASCII关键字列表 *)
