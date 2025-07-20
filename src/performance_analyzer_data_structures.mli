(** 数据结构性能分析器模块接口 *)

open Ast
open Refactoring_analyzer_types

(** 分析数据结构使用效率
    @param expr 要分析的表达式
    @return 数据结构优化建议列表 *)
val analyze_data_structure_efficiency : expr -> refactoring_suggestion list