(** 骆言词法分析器关键字匹配核心模块接口 *)

open Token_types

(** 关键字查找表模块 *)
module KeywordTable : sig
  (** 查找中文关键字 *)
  val find_chinese_keyword : string -> Keywords.keyword_token option

  (** 查找ASCII关键字 *)
  val find_ascii_keyword : string -> Keywords.keyword_token option

  (** 检查是否为关键字（优先中文） *)
  val find_keyword : string -> Keywords.keyword_token option

  (** 获取所有关键字列表（用于调试和测试） *)
  val get_all_chinese_keywords : unit -> (string * Keywords.keyword_token) list

  val get_all_ascii_keywords : unit -> (string * Keywords.keyword_token) list
  val get_all_keywords : unit -> (string * Keywords.keyword_token) list
end