(** 分析报告模块 - 生成综合的代码质量评估报告和质量摘要 *)

open Refactoring_analyzer_types
open Analysis_engine
open Analysis_statistics

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
  Buffer.add_string report (Printf.sprintf "   • 总计发现 %d 个改进机会\n" total);
  Buffer.add_string report
    (Printf.sprintf "   • 高优先级: %d 个 | 中优先级: %d 个 | 低优先级: %d 个\n\n" high medium low);

  Buffer.add_string report "📊 问题分类统计:\n";
  Buffer.add_string report (Printf.sprintf "   📝 命名规范: %d 个\n" naming);
  Buffer.add_string report (Printf.sprintf "   ⚡ 代码复杂度: %d 个\n" complexity);
  Buffer.add_string report (Printf.sprintf "   🔄 重复代码: %d 个\n" duplication);
  Buffer.add_string report (Printf.sprintf "   🚀 性能优化: %d 个\n\n" performance);

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
