(** 骆言词法分析器关键字匹配优化模块 - 模块化重构版本接口 *)

(** 词法分析器状态类型 *)
type lexer_state = {
  input : string;
  position : int;
  length : int;
  current_line : int;
  current_column : int;
  filename : string;
}

(** 主要匹配函数 - 对外接口 *)
val match_keyword : lexer_state -> (Token_types.token * int) option

(** 快速关键字查找 - 用于其他模块 *)
val lookup_keyword : string -> Token_types.token option

(** 检查字符串是否为关键字 *)
val is_keyword : string -> bool

(** 获取关键字统计信息 *)
val get_keyword_analytics : unit -> Keyword_matcher.Keyword_analytics.KeywordAnalytics.keyword_stats

(** 打印关键字统计信息 *)
val print_keyword_analytics : unit -> unit

(** 重新导出关键字表接口 *)
module KeywordTable : module type of Keyword_matcher.Keyword_lookup.KeywordTable
module OptimizedMatcher : module type of Keyword_matcher.Keyword_matching_algorithms.OptimizedMatcher
module KeywordAnalytics : module type of Keyword_matcher.Keyword_analytics.KeywordAnalytics