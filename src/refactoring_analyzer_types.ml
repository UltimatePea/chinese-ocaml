(** 重构分析器核心类型定义模块 *)

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
  | DuplicatedCode of string list (* 重复代码片段，包含重复的函数名或标识符 *)
  | FunctionComplexity of int (* 函数复杂度，包含计算得出的复杂度值 *)
  | NamingImprovement of string (* 命名改进建议，包含建议的新名称 *)
  | PerformanceHint of string (* 性能优化提示，包含具体建议 *)

type analysis_context = {
  current_function : string option; (* 当前分析的函数名 *)
  defined_vars : (string * type_expr option) list; (* 已定义变量及其类型 *)
  function_calls : string list; (* 函数调用历史 *)
  nesting_level : int; (* 嵌套层级 *)
  expression_count : int; (* 表达式计数 *)
}
(** 代码分析上下文 *)

(** 初始化分析上下文 *)
let empty_context =
  {
    current_function = None;
    defined_vars = [];
    function_calls = [];
    nesting_level = 0;
    expression_count = 0;
  }

(** 分析器配置常量 *)
module Config = struct
  let max_function_complexity = 15 (* 函数最大复杂度阈值 *)
  let max_nesting_level = 5 (* 最大嵌套层级 *)
  let min_duplication_threshold = 3 (* 最小重复代码检测阈值 *)
end

(** 格式化输出建议 *)
let format_suggestion suggestion =
  let type_prefix =
    match suggestion.suggestion_type with
    | DuplicatedCode _ -> "🔄 [重复代码]"
    | FunctionComplexity _ -> "⚡ [复杂度]"
    | NamingImprovement _ -> "📝 [命名]"
    | PerformanceHint _ -> "🚀 [性能]"
  in

  let confidence_text =
    Printf.sprintf "置信度: %.0f%%" (suggestion.confidence *. 100.0)
  in
  let location_text =
    match suggestion.location with Some loc -> " [位置: " ^ loc ^ "]" | None -> ""
  in
  let fix_text =
    match suggestion.suggested_fix with Some fix -> "\n   💡 建议: " ^ fix | None -> ""
  in

  Printf.sprintf "%s %s (%s)%s%s" type_prefix suggestion.message confidence_text
    location_text fix_text

(** 生成重构报告 *)
let generate_refactoring_report suggestions =
  let total_count = List.length suggestions in
  let high_confidence = List.filter (fun s -> s.confidence >= 0.8) suggestions in
  let medium_confidence =
    List.filter (fun s -> s.confidence >= 0.6 && s.confidence < 0.8) suggestions
  in
  let low_confidence = List.filter (fun s -> s.confidence < 0.6) suggestions in

  let report = Buffer.create (Constants.BufferSizes.large_buffer ()) in

  Buffer.add_string report "📋 智能代码重构建议报告\n";
  Buffer.add_string report "========================================\n\n";

  Buffer.add_string report (Printf.sprintf "📊 建议统计:\n");
  Buffer.add_string report
    (Printf.sprintf "   🚨 高置信度: %d 个\n" (List.length high_confidence));
  Buffer.add_string report
    (Printf.sprintf "   ⚠️ 中置信度: %d 个\n" (List.length medium_confidence));
  Buffer.add_string report
    (Printf.sprintf "   💡 低置信度: %d 个\n" (List.length low_confidence));
  Buffer.add_string report (Printf.sprintf "   📈 总计: %d 个建议\n\n" total_count);

  if total_count > 0 then (
    Buffer.add_string report "📝 详细建议:\n\n";
    List.iteri
      (fun i suggestion ->
        Buffer.add_string report
          (Printf.sprintf "%d. %s\n\n" (i + 1) (format_suggestion suggestion)))
      suggestions;

    Buffer.add_string report "🛠️ 优先级建议:\n";
    if List.length high_confidence > 0 then
      Buffer.add_string report "   1. 优先处理高置信度建议，这些对代码质量影响最大\n";
    if List.length medium_confidence > 0 then
      Buffer.add_string report "   2. 考虑中置信度建议，可以进一步提升代码质量\n";
    if List.length low_confidence > 0 then Buffer.add_string report "   3. 评估低置信度建议，根据实际情况选择性应用\n")
  else Buffer.add_string report "✅ 恭喜！您的代码质量很好，没有发现需要重构的问题。\n";

  Buffer.add_string report "\n---\n";
  Buffer.add_string report "🤖 Generated with 智能代码重构建议系统\n";

  Buffer.contents report
