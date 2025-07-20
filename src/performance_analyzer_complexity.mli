(** 计算复杂度性能分析器模块接口 *)

open Ast
open Refactoring_analyzer_types

(** 分析计算复杂度
    @param expr 要分析的表达式
    @return 复杂度优化建议列表 *)
val analyze_computational_complexity : expr -> refactoring_suggestion list