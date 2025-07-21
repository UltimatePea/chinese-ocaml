(** 递归性能分析器模块接口 *)

open Ast
open Refactoring_analyzer_types

val analyze_recursion_performance : expr -> refactoring_suggestion list
(** 分析递归深度和优化
    @param expr 要分析的表达式
    @return 递归优化建议列表 *)
