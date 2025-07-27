(** 骆言词法分析器关键字匹配核心模块接口 *)

open Lexer_tokens

(** 关键字查找表模块 *)
module KeywordTable : sig
  val find_chinese_keyword : string -> token option
  (** 查找中文关键字 *)

  val find_ascii_keyword : string -> token option
  (** 查找ASCII关键字 *)

  val find_keyword : string -> token option
  (** 检查是否为关键字（优先中文） *)

  val get_all_chinese_keywords : unit -> (string * token) list
  (** 获取所有关键字列表（用于调试和测试） *)

  val get_all_ascii_keywords : unit -> (string * token) list
  val get_all_keywords : unit -> (string * token) list
end
