(** 模式匹配性能分析器模块接口 *)

open Ast
open Refactoring_analyzer_types

val analyze_match_performance : expr -> refactoring_suggestion list
(** 分析模式匹配性能
    @param expr 要分析的表达式
    @return 性能改进建议列表 *)
