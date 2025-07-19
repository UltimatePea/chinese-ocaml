(** 重构分析器核心协调器接口 *)

open Ast
open Refactoring_analyzer_types

(** 分析表达式的主入口函数 *)
val analyze_expression : expr -> analysis_context -> refactoring_suggestion list

(** 分析语句 *)
val analyze_statement : stmt -> analysis_context -> refactoring_suggestion list

(** 分析整个程序 *)
val analyze_program : stmt list -> refactoring_suggestion list

(** 综合代码质量分析 *)
val comprehensive_analysis : stmt list -> 
  refactoring_suggestion list * string * string * string * string * string

(** 快速质量检查 *)
val quick_quality_check : stmt list -> string

(** 获取建议统计信息 *)
val get_suggestion_statistics : refactoring_suggestion list -> 
  int * (int * int * int * int) * (int * int * int)

(** 生成详细的质量评估报告 *)
val generate_quality_assessment : stmt list -> string