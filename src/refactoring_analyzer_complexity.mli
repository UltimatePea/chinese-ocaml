(** 代码复杂度分析器模块接口 *)

open Ast
open Refactoring_analyzer_types

(** 计算表达式复杂度 *)
val calculate_expression_complexity : expr -> analysis_context -> int

(** 分析函数复杂度 *)
val analyze_function_complexity : string -> expr -> analysis_context -> refactoring_suggestion option

(** 检查嵌套深度并生成建议 *)
val check_nesting_depth : int -> refactoring_suggestion list ref -> unit

(** 计算圈复杂度 *)
val calculate_cyclomatic_complexity : expr -> int

(** 分析表达式嵌套深度 *)
val analyze_nesting_depth : expr -> int

(** 计算认知复杂度 *)
val calculate_cognitive_complexity : expr -> int

(** 综合复杂度分析 *)
val comprehensive_complexity_analysis : string -> expr -> analysis_context -> refactoring_suggestion list

(** 生成复杂度分析报告 *)
val generate_complexity_report : refactoring_suggestion list -> string