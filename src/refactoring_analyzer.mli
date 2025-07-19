(** 智能代码重构建议模块 - 重构为模块化架构的主入口 *)

(** 重构建议类型 - 重新导出 *)
type refactoring_suggestion = Refactoring_analyzer_types.refactoring_suggestion

(** 建议类型分类 - 重新导出 *)
type suggestion_type = Refactoring_analyzer_types.suggestion_type =
  | DuplicatedCode of string list
  | FunctionComplexity of int
  | NamingImprovement of string
  | PerformanceHint of string

(** 代码分析上下文 - 重新导出 *)
type analysis_context = Refactoring_analyzer_types.analysis_context

(** {1 配置和常量} *)

val empty_context : analysis_context
(** 初始化的空分析上下文 *)

val max_function_complexity : int
(** 函数最大复杂度阈值常量 *)

val max_nesting_level : int
(** 最大嵌套层级常量 *)

val min_duplication_threshold : int
(** 最小重复代码检测阈值常量 *)

(** {1 主要分析函数} *)

val analyze_expression : Ast.expr -> analysis_context -> refactoring_suggestion list
(** 分析单个表达式 *)

val analyze_statement : Ast.stmt -> analysis_context -> refactoring_suggestion list
(** 分析语句 *)

val analyze_program : Ast.stmt list -> refactoring_suggestion list
(** 分析整个程序 *)

(** {1 综合分析函数} *)

val comprehensive_analysis : Ast.stmt list -> 
  refactoring_suggestion list * string * string * string * string * string
(** 综合代码质量分析，返回建议列表和各类专门报告 *)

val quick_quality_check : Ast.stmt list -> string
(** 快速质量检查 *)

val generate_quality_assessment : Ast.stmt list -> string
(** 生成详细的质量评估报告 *)

val run_comprehensive_analysis : Ast.stmt list -> string
(** 运行所有分析器并生成综合报告 *)

(** {1 报告函数} *)

val format_suggestion : refactoring_suggestion -> string
(** 格式化输出建议 *)

val generate_refactoring_report : refactoring_suggestion list -> string
(** 生成重构报告 *)

val get_analyzer_info : unit -> string
(** 获取模块化分析器信息 *)

(** {1 专门的分析器模块} *)

module Naming : sig
  val is_english_naming : string -> bool
  val is_mixed_naming : string -> bool
  val analyze_naming_quality : string -> refactoring_suggestion list
  val generate_naming_report : refactoring_suggestion list -> string
end

module Complexity : sig
  val calculate_expression_complexity : Ast.expr -> analysis_context -> int
  val analyze_function_complexity : string -> Ast.expr -> analysis_context -> refactoring_suggestion option
  val comprehensive_complexity_analysis : string -> Ast.expr -> analysis_context -> refactoring_suggestion list
  val generate_complexity_report : refactoring_suggestion list -> string
end

module Duplication : sig
  val detect_code_duplication : Ast.expr list -> refactoring_suggestion list
  val detect_function_duplication : (string * Ast.expr) list -> refactoring_suggestion list
  val generate_duplication_report : refactoring_suggestion list -> string
end

module Performance : sig
  val analyze_performance_hints : Ast.expr -> analysis_context -> refactoring_suggestion list
  val analyze_list_performance : Ast.expr -> refactoring_suggestion list
  val analyze_match_performance : Ast.expr -> refactoring_suggestion list
  val generate_performance_report : refactoring_suggestion list -> string
end