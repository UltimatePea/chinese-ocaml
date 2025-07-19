(** 重构分析器核心类型定义模块接口 *)

open Ast

type refactoring_suggestion = {
  suggestion_type : suggestion_type;
  message : string;
  confidence : float; (* 置信度 0.0-1.0 *)
  location : string option; (* 代码位置 *)
  suggested_fix : string option; (* 建议的修复方案 *)
}
(** 重构建议类型 *)

(** 建议类型分类 *)
and suggestion_type =
  | DuplicatedCode of string list (* 重复代码片段 *)
  | FunctionComplexity of int (* 函数复杂度 *)
  | NamingImprovement of string (* 命名改进建议 *)
  | PerformanceHint of string (* 性能优化提示 *)

type analysis_context = {
  current_function : string option;
  defined_vars : (string * type_expr option) list;
  function_calls : string list;
  nesting_level : int;
  expression_count : int;
}
(** 代码分析上下文 *)

val empty_context : analysis_context
(** 初始化分析上下文 *)

(** 分析器配置常量 *)
module Config : sig
  val max_function_complexity : int
  val max_nesting_level : int
  val min_duplication_threshold : int
end

val format_suggestion : refactoring_suggestion -> string
(** 格式化输出建议 *)

val generate_refactoring_report : refactoring_suggestion list -> string
(** 生成重构报告 *)
