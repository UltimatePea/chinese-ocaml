(** 性能分析器模块接口 - 模块化重构版本

    本模块作为性能分析的主协调器，个体分析功能已迁移到专门的子模块：
    - Performance_analyzer_lists
    - Performance_analyzer_matching
    - Performance_analyzer_recursion
    - Performance_analyzer_data_structures
    - Performance_analyzer_complexity *)

open Ast
open Refactoring_analyzer_types

(** 性能问题类型 *)
type performance_issue =
  | ListConcatenation
  | LargeMatchExpression of int
  | DeepRecursion of int
  | IneffientIteration
  | UnoptimizedDataStructure

val analyze_list_performance : expr -> refactoring_suggestion list
(** 向后兼容性函数 - 委托给专门模块 *)

val analyze_match_performance : expr -> refactoring_suggestion list
val analyze_recursion_performance : expr -> refactoring_suggestion list
val analyze_data_structure_efficiency : expr -> refactoring_suggestion list
val analyze_computational_complexity : expr -> refactoring_suggestion list

val analyze_performance_hints : expr -> analysis_context -> refactoring_suggestion list
(** 综合性能分析 - 协调各个专门分析器 *)

val generate_performance_report : refactoring_suggestion list -> string
(** 生成性能分析报告 *)
