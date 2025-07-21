(** 模式匹配性能分析器模块

    专门分析模式匹配的性能问题
    重构版本：使用公共基础模块消除代码重复
    创建时间：技术债务清理 Fix #794 *)

open Ast
open Performance_analyzer_base

(** 模式匹配特定的性能分析逻辑 *)
let match_specific_analysis expr =
  match expr with
  | MatchExpr (_, branches) when List.length branches > 20 ->
      [SuggestionBuilder.pattern_matching_suggestion (List.length branches) "严重"]
  | MatchExpr (_, branches) when List.length branches > 10 ->
      [SuggestionBuilder.pattern_matching_suggestion (List.length branches) "轻微"]
  | _ -> []

(** 分析模式匹配性能 *)
let analyze_match_performance expr =
  create_performance_analyzer match_specific_analysis expr