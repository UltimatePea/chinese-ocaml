(** 性能分析器模块接口 *)

open Ast
open Refactoring_analyzer_types

(** 性能问题类型 *)
type performance_issue = 
  | ListConcatenation
  | LargeMatchExpression of int
  | DeepRecursion of int
  | IneffientIteration
  | UnoptimizedDataStructure

(** 分析列表操作性能 *)
val analyze_list_performance : expr -> refactoring_suggestion list

(** 分析模式匹配性能 *)
val analyze_match_performance : expr -> refactoring_suggestion list

(** 分析递归深度和优化 *)
val analyze_recursion_performance : expr -> refactoring_suggestion list

(** 分析数据结构使用效率 *)
val analyze_data_structure_efficiency : expr -> refactoring_suggestion list

(** 分析计算复杂度 *)
val analyze_computational_complexity : expr -> refactoring_suggestion list

(** 综合性能分析 *)
val analyze_performance_hints : expr -> analysis_context -> refactoring_suggestion list

(** 生成性能分析报告 *)
val generate_performance_report : refactoring_suggestion list -> string