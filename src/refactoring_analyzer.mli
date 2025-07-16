(** 智能代码重构建议模块 - AI驱动的代码质量改进建议 *)

type refactoring_suggestion = {
  suggestion_type : suggestion_type;
  message : string;
  confidence : float;  (** 置信度 0.0-1.0 *)
  location : string option;  (** 代码位置 *)
  suggested_fix : string option;  (** 建议的修复方案 *)
}
(** 重构建议类型 *)

(** 建议类型分类 *)
and suggestion_type =
  | DuplicatedCode of string list  (** 重复代码片段，包含重复的函数名或标识符 *)
  | FunctionComplexity of int  (** 函数复杂度，包含计算得出的复杂度值 *)
  | NamingImprovement of string  (** 命名改进建议，包含建议的新名称 *)
  | PerformanceHint of string  (** 性能优化提示，包含具体建议 *)

type analysis_context = {
  current_function : string option;  (** 当前分析的函数名 *)
  defined_vars : (string * Ast.type_expr option) list;  (** 已定义变量及其类型 *)
  function_calls : string list;  (** 函数调用历史 *)
  nesting_level : int;  (** 嵌套层级 *)
  expression_count : int;  (** 表达式计数 *)
}
(** 代码分析上下文 *)

(** {1 上下文和常量} *)

val empty_context : analysis_context
(** 初始化的空分析上下文 *)

val max_function_complexity : int
(** 函数最大复杂度阈值常量 *)

val max_nesting_level : int
(** 最大嵌套层级常量 *)

val min_duplication_threshold : int
(** 最小重复代码检测阈值常量 *)

(** {1 命名分析} *)

val is_english_naming : string -> bool
(** 检查是否为英文命名 *)

val is_mixed_naming : string -> bool
(** 检查是否为中英文混用命名 *)

val analyze_naming_quality : string -> refactoring_suggestion list
(** 分析命名质量 *)

(** {1 复杂度分析} *)

val calculate_expression_complexity : Ast.expr -> analysis_context -> int
(** 计算表达式复杂度 *)

val analyze_function_complexity :
  string -> Ast.expr -> analysis_context -> refactoring_suggestion option
(** 分析函数复杂度 *)

(** {1 代码质量分析} *)

val detect_code_duplication : Ast.expr list -> refactoring_suggestion list
(** 检测重复代码模式 *)

val analyze_performance_hints : Ast.expr -> analysis_context -> refactoring_suggestion list
(** 性能优化建议分析 *)

(** {1 主要分析函数} *)

val analyze_expression : Ast.expr -> analysis_context -> refactoring_suggestion list
(** 分析单个表达式 *)

val analyze_statement : Ast.stmt -> analysis_context -> refactoring_suggestion list
(** 分析语句 *)

val analyze_program : Ast.stmt list -> refactoring_suggestion list
(** 分析整个程序 *)

(** {1 报告函数} *)

val format_suggestion : refactoring_suggestion -> string
(** 格式化输出建议 *)

val generate_refactoring_report : refactoring_suggestion list -> string
(** 生成重构报告 *)
