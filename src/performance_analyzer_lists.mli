(** 列表性能分析器模块接口 *)

open Ast
open Refactoring_analyzer_types

(** 分析列表操作性能
    @param expr 要分析的表达式
    @return 性能改进建议列表 *)
val analyze_list_performance : expr -> refactoring_suggestion list