(** 分析报告模块 - 生成综合的代码质量评估报告和质量摘要 *)

open Refactoring_analyzer_types
open Analysis_engine
open Analysis_statistics
open Utils.Base_formatter

(** 综合代码质量分析 *)
let comprehensive_analysis program =
  let suggestions = analyze_program program in

  (* 生成各种专门的报告 *)
  let naming_report = Refactoring_analyzer_naming.generate_naming_report suggestions in
  let complexity_report = Refactoring_analyzer_complexity.generate_complexity_report suggestions in
  let duplication_report =
    Refactoring_analyzer_duplication.generate_duplication_report suggestions
  in
  let performance_report =
    Refactoring_analyzer_performance.generate_performance_report suggestions
  in
  let main_report = generate_refactoring_report suggestions in

  ( suggestions,
    naming_report,
    complexity_report,
    duplication_report,
    performance_report,
    main_report )

(** 生成详细的质量评估报告 *)
let generate_quality_assessment program =
  let ( suggestions,
        naming_report,
        complexity_report,
        duplication_report,
        performance_report,
        main_report ) =
    comprehensive_analysis program
  in

  let total, (naming, complexity, duplication, performance), (high, medium, low) =
    get_suggestion_statistics suggestions
  in

  let report = Buffer.create (Constants.BufferSizes.large_buffer ()) in

  Buffer.add_string report "📋 代码质量综合评估报告\n";
  Buffer.add_string report "================================\n\n";

  Buffer.add_string report "🎯 执行概要:\n";
  Buffer.add_string report (concat_strings [ "   • 总计发现 "; int_to_string total; " 个改进机会\n" ]);
  Buffer.add_string report
    (concat_strings
       [
         "   • 高优先级: ";
         int_to_string high;
         " 个 | 中优先级: ";
         int_to_string medium;
         " 个 | 低优先级: ";
         int_to_string low;
         " 个\n\n";
       ]);

  Buffer.add_string report "📊 问题分类统计:\n";
  Buffer.add_string report (concat_strings [ "   📝 命名规范: "; int_to_string naming; " 个\n" ]);
  Buffer.add_string report (concat_strings [ "   ⚡ 代码复杂度: "; int_to_string complexity; " 个\n" ]);
  Buffer.add_string report (concat_strings [ "   🔄 重复代码: "; int_to_string duplication; " 个\n" ]);
  Buffer.add_string report (concat_strings [ "   🚀 性能优化: "; int_to_string performance; " 个\n\n" ]);

  (* 添加各专项报告 *)
  if naming > 0 then (
    Buffer.add_string report naming_report;
    Buffer.add_string report "\n");

  if complexity > 0 then (
    Buffer.add_string report complexity_report;
    Buffer.add_string report "\n");

  if duplication > 0 then (
    Buffer.add_string report duplication_report;
    Buffer.add_string report "\n");

  if performance > 0 then (
    Buffer.add_string report performance_report;
    Buffer.add_string report "\n");

  Buffer.add_string report main_report;

  Buffer.contents report
