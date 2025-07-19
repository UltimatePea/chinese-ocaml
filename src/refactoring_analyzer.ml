(** 智能代码重构建议模块 - 重构为模块化架构的主入口 *)

(* 使用模块限定访问而非open以避免警告 *)

(* 为了保持向后兼容性，重新导出核心类型和函数 *)

type refactoring_suggestion = Refactoring_analyzer_types.refactoring_suggestion
(** 重构建议类型 - 重新导出 *)

(** 建议类型分类 - 重新导出 *)
type suggestion_type = Refactoring_analyzer_types.suggestion_type =
  | DuplicatedCode of string list
  | FunctionComplexity of int
  | NamingImprovement of string
  | PerformanceHint of string

type analysis_context = Refactoring_analyzer_types.analysis_context
(** 代码分析上下文 - 重新导出 *)

(** 初始化分析上下文 - 重新导出 *)
let empty_context = Refactoring_analyzer_types.empty_context

(** 配置常量 - 重新导出 *)
let max_function_complexity = Refactoring_analyzer_types.Config.max_function_complexity

let max_nesting_level = Refactoring_analyzer_types.Config.max_nesting_level
let min_duplication_threshold = Refactoring_analyzer_types.Config.min_duplication_threshold

(** 主要分析函数 - 委托给核心协调器 *)

(** 分析表达式 *)
let analyze_expression = Refactoring_analyzer_core.analyze_expression

(** 分析语句 *)
let analyze_statement = Refactoring_analyzer_core.analyze_statement

(** 分析整个程序 *)
let analyze_program = Refactoring_analyzer_core.analyze_program

(** 格式化输出建议 *)
let format_suggestion = Refactoring_analyzer_types.format_suggestion

(** 生成重构报告 *)
let generate_refactoring_report = Refactoring_analyzer_types.generate_refactoring_report

(** 综合代码质量分析 *)
let comprehensive_analysis = Refactoring_analyzer_core.comprehensive_analysis

(** 快速质量检查 *)
let quick_quality_check = Refactoring_analyzer_core.quick_quality_check

(** 生成详细的质量评估报告 *)
let generate_quality_assessment = Refactoring_analyzer_core.generate_quality_assessment

module Naming = Refactoring_analyzer_naming
(** 专门的分析器模块访问 *)

module Complexity = Refactoring_analyzer_complexity
module Duplication = Refactoring_analyzer_duplication
module Performance = Refactoring_analyzer_performance

(** 获取模块化分析器信息 *)
let get_analyzer_info () =
  {|
📋 重构分析器模块化架构
=========================

🎯 核心模块:
   • Refactoring_analyzer_types - 核心类型定义
   • Refactoring_analyzer_core - 主协调器

🔧 专业分析器:
   • Refactoring_analyzer_naming - 命名质量分析
   • Refactoring_analyzer_complexity - 代码复杂度分析
   • Refactoring_analyzer_duplication - 重复代码检测
   • Refactoring_analyzer_performance - 性能分析

✅ 架构优势:
   • 单一职责原则 - 每个模块专注特定分析
   • 易于扩展 - 可独立添加新的分析器
   • 高内聚低耦合 - 模块间接口清晰
   • 可测试性 - 每个分析器可独立测试

🤖 Generated with Phase25 模块化重构
  |}

(** 运行所有分析器并生成综合报告 *)
let run_comprehensive_analysis program =
  let _, naming_report, complexity_report, duplication_report, performance_report, main_report =
    comprehensive_analysis program
  in

  let analysis_info = get_analyzer_info () in

  (* 组合所有报告 *)
  analysis_info ^ "\n\n" ^ naming_report ^ "\n" ^ complexity_report ^ "\n" ^ duplication_report
  ^ "\n" ^ performance_report ^ "\n" ^ main_report
