(** 性能分析器模块 - 模块化重构版本

    本模块作为性能分析的主协调器，将具体分析工作委托给专门的子模块：
    - Performance_analyzer_lists - 列表性能分析
    - Performance_analyzer_matching - 模式匹配性能分析
    - Performance_analyzer_recursion - 递归性能分析
    - Performance_analyzer_data_structures - 数据结构性能分析
    - Performance_analyzer_complexity - 计算复杂度分析

    创建时间：技术债务清理 Fix #654 *)

open Refactoring_analyzer_types
open Utils.Base_formatter

(** 性能问题类型 *)
type performance_issue =
  | ListConcatenation
  | LargeMatchExpression of int
  | DeepRecursion of int
  | IneffientIteration
  | UnoptimizedDataStructure

(** 向后兼容性函数 - 委托给专门模块 *)
let analyze_list_performance = Performance_analyzer_lists.analyze_list_performance

let analyze_match_performance = Performance_analyzer_matching.analyze_match_performance
let analyze_recursion_performance = Performance_analyzer_recursion.analyze_recursion_performance

let analyze_data_structure_efficiency =
  Performance_analyzer_data_structures.analyze_data_structure_efficiency

let analyze_computational_complexity =
  Performance_analyzer_complexity.analyze_computational_complexity

(** 综合性能分析 - 模块化版本 *)
let analyze_performance_hints expr _context =
  let list_suggestions = Performance_analyzer_lists.analyze_list_performance expr in
  let match_suggestions = Performance_analyzer_matching.analyze_match_performance expr in
  let recursion_suggestions = Performance_analyzer_recursion.analyze_recursion_performance expr in
  let data_structure_suggestions =
    Performance_analyzer_data_structures.analyze_data_structure_efficiency expr
  in
  let complexity_suggestions =
    Performance_analyzer_complexity.analyze_computational_complexity expr
  in

  (* 合并所有建议 *)
  let all_suggestions =
    list_suggestions @ match_suggestions @ recursion_suggestions @ data_structure_suggestions
    @ complexity_suggestions
  in

  (* 按置信度排序并去重 *)
  List.sort (fun a b -> compare b.confidence a.confidence) all_suggestions

(** 生成性能分析报告 *)
let generate_performance_report suggestions =
  let performance_suggestions =
    List.filter
      (function { suggestion_type = PerformanceHint _; _ } -> true | _ -> false)
      suggestions
  in

  let report = Buffer.create (Constants.BufferSizes.default_buffer ()) in

  Buffer.add_string report "🚀 性能分析报告\n";
  Buffer.add_string report "=====================\n\n";

  Buffer.add_string report
    (concat_strings ["📊 性能问题统计: "; int_to_string (List.length performance_suggestions); " 个\n\n"]);

  (match performance_suggestions with 
   | [] -> Buffer.add_string report "✅ 恭喜！没有发现明显的性能问题。\n"
   | _ -> 
    Buffer.add_string report "⚡ 性能优化建议:\n\n";
    List.iteri
      (fun i suggestion ->
        Buffer.add_string report
          (concat_strings [int_to_string (i + 1); ". "; suggestion.message; "\n"]);
        match suggestion.suggested_fix with
        | Some fix -> Buffer.add_string report (concat_strings ["   💡 "; fix; "\n\n"])
        | None -> Buffer.add_string report "\n")
      performance_suggestions;

    Buffer.add_string report "🎯 性能优化原则:\n";
    Buffer.add_string report "   • 选择合适的数据结构\n";
    Buffer.add_string report "   • 避免不必要的计算和内存分配\n";
    Buffer.add_string report "   • 优化算法复杂度\n";
    Buffer.add_string report "   • 使用尾递归和累加器模式\n";
    Buffer.add_string report "   • 考虑惰性计算和缓存策略\n");

  Buffer.contents report
