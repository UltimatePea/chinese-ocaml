(** 分析统计模块 - 提供代码质量分析的统计功能和质量指标计算 *)

open Refactoring_analyzer_types

(** 获取建议统计信息 *)
let get_suggestion_statistics suggestions =
  let total = List.length suggestions in
  let by_type =
    List.fold_left
      (fun acc suggestion ->
        match suggestion.suggestion_type with
        | NamingImprovement _ ->
            let n, c, d, p = acc in
            (n + 1, c, d, p)
        | FunctionComplexity _ ->
            let n, c, d, p = acc in
            (n, c + 1, d, p)
        | DuplicatedCode _ ->
            let n, c, d, p = acc in
            (n, c, d + 1, p)
        | PerformanceHint _ ->
            let n, c, d, p = acc in
            (n, c, d, p + 1))
      (0, 0, 0, 0) suggestions
  in

  let by_priority =
    List.fold_left
      (fun acc suggestion ->
        let high, medium, low = acc in
        if suggestion.confidence >= 0.8 then (high + 1, medium, low)
        else if suggestion.confidence >= 0.6 then (high, medium + 1, low)
        else (high, medium, low + 1))
      (0, 0, 0) suggestions
  in

  (total, by_type, by_priority)

(** 快速质量检查 - 返回关键质量指标 *)
let quick_quality_check program =
  let suggestions = Analysis_engine.analyze_program program in

  let total_issues = List.length suggestions in
  let high_priority = List.length (List.filter (fun s -> s.confidence >= 0.8) suggestions) in
  let naming_issues =
    List.length
      (List.filter
         (function { suggestion_type = NamingImprovement _; _ } -> true | _ -> false)
         suggestions)
  in
  let complexity_issues =
    List.length
      (List.filter
         (function { suggestion_type = FunctionComplexity _; _ } -> true | _ -> false)
         suggestions)
  in
  let duplication_issues =
    List.length
      (List.filter
         (function { suggestion_type = DuplicatedCode _; _ } -> true | _ -> false)
         suggestions)
  in
  let performance_issues =
    List.length
      (List.filter
         (function { suggestion_type = PerformanceHint _; _ } -> true | _ -> false)
         suggestions)
  in

  {|
  📊 代码质量快速检查
  ====================
  |}
  ^ Unified_logger.Legacy.sprintf "总问题数: %d 个\n" total_issues
  ^ Unified_logger.Legacy.sprintf "高优先级: %d 个\n" high_priority
  ^ Unified_logger.Legacy.sprintf "命名问题: %d 个\n" naming_issues
  ^ Unified_logger.Legacy.sprintf "复杂度问题: %d 个\n" complexity_issues
  ^ Unified_logger.Legacy.sprintf "重复代码: %d 个\n" duplication_issues
  ^ Unified_logger.Legacy.sprintf "性能问题: %d 个\n" performance_issues
