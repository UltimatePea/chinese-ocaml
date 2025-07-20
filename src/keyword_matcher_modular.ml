(** 骆言词法分析器关键字匹配优化模块 - 模块化重构版本 *)

open Token_types
open Keyword_matcher.Keyword_lookup
open Keyword_matcher.Keyword_matching_algorithms
open Keyword_matcher.Keyword_analytics

(** 重新导出词法分析器状态类型 *)
type lexer_state = Keyword_matching_algorithms.lexer_state = {
  input : string;
  position : int;
  length : int;
  current_line : int;
  current_column : int;
  filename : string;
}

(** 主要匹配函数 - 对外接口 *)
let match_keyword state = OptimizedMatcher.match_by_prefix state

(** 快速关键字查找 - 用于其他模块 *)
let lookup_keyword keyword_string = KeywordTable.find_keyword keyword_string

(** 检查字符串是否为关键字 *)
let is_keyword keyword_string =
  match lookup_keyword keyword_string with Some _ -> true | None -> false

(** 获取关键字统计信息 *)
let get_keyword_analytics () = KeywordAnalytics.analyze_keywords ()

(** 打印关键字统计信息 *)
let print_keyword_analytics () = 
  let stats = get_keyword_analytics () in
  KeywordAnalytics.print_keyword_stats stats

(** 重新导出关键字表接口 *)
module KeywordTable = KeywordTable
module OptimizedMatcher = OptimizedMatcher  
module KeywordAnalytics = KeywordAnalytics