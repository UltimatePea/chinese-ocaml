(** 重构分析器核心协调器 - 整合所有分析器模块的主入口 *)

(* 重新导出各专门模块的功能以保持向后兼容 *)

(* 导出分析引擎功能 *)
let analyze_expression = Analysis_engine.analyze_expression
let analyze_statement = Analysis_engine.analyze_statement
let analyze_program = Analysis_engine.analyze_program

(* 导出统计和质量检查功能 *)
let get_suggestion_statistics = Analysis_statistics.get_suggestion_statistics
let quick_quality_check = Analysis_statistics.quick_quality_check

(* 导出报告生成功能 *)
let comprehensive_analysis = Analysis_reporting.comprehensive_analysis
let generate_quality_assessment = Analysis_reporting.generate_quality_assessment
