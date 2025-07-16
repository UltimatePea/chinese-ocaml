(** 骆言词法分析器关键字匹配优化模块接口 *)

open Token_types

type lexer_state = {
  input : string;
  position : int;
  length : int;
  current_line : int;
  current_column : int;
  filename : string;
}
(** 关键字匹配状态 *)

(** 关键字查找表模块 *)
module KeywordTable : sig
  val find_chinese_keyword : string -> Keywords.keyword_token option
  val find_ascii_keyword : string -> Keywords.keyword_token option
  val find_keyword : string -> Keywords.keyword_token option
  val get_all_chinese_keywords : unit -> (string * Keywords.keyword_token) list
  val get_all_ascii_keywords : unit -> (string * Keywords.keyword_token) list
  val get_all_keywords : unit -> (string * Keywords.keyword_token) list
end

(** 优化的关键字匹配算法模块 *)
module OptimizedMatcher : sig
  val try_match_keyword : lexer_state -> (Keywords.keyword_token * int) option
  val match_by_prefix : lexer_state -> (Keywords.keyword_token * int) option
end

(** 关键字统计和分析工具模块 *)
module KeywordAnalytics : sig
  type keyword_stats = {
    total_keywords : int;
    chinese_keywords : int;
    ascii_keywords : int;
    avg_chinese_length : float;
    avg_ascii_length : float;
    max_length : int;
    min_length : int;
  }

  val analyze_keywords : unit -> keyword_stats
  val print_keyword_stats : keyword_stats -> unit
end

val match_keyword : lexer_state -> (Keywords.keyword_token * int) option
(** 主要匹配函数 *)

val lookup_keyword : string -> Keywords.keyword_token option
(** 快速关键字查找 *)

val is_keyword : string -> bool
(** 检查字符串是否为关键字 *)
