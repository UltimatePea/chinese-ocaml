(** 重构分析器核心协调器 - 整合所有分析器模块的主入口 *)

open Ast
open Refactoring_analyzer_types

(** 统一的建议添加函数，消除代码重复 *)
let add_suggestions_to_ref new_suggestions suggestions_ref =
  suggestions_ref := List.rev_append new_suggestions !suggestions_ref

(** 创建带有增加嵌套层级的上下文 *)
let create_nested_context ctx =
  { ctx with nesting_level = ctx.nesting_level + 1 }

(** 分析变量表达式 *)
let analyze_variable_expression name suggestions =
  add_suggestions_to_ref
    (Refactoring_analyzer_naming.analyze_naming_quality name)
    suggestions

(** 分析Let表达式 *)
let analyze_let_expression name val_expr in_expr new_ctx analyze suggestions =
  add_suggestions_to_ref
    (Refactoring_analyzer_naming.analyze_naming_quality name)
    suggestions;
  let updated_ctx = { new_ctx with defined_vars = (name, None) :: new_ctx.defined_vars } in
  analyze val_expr updated_ctx;
  analyze in_expr updated_ctx

(** 分析函数表达式 *)
let analyze_function_expression params body new_ctx analyze suggestions =
  let param_suggestions =
    List.fold_left
      (fun acc param ->
        List.rev_append (Refactoring_analyzer_naming.analyze_naming_quality param) acc)
      [] params
  in
  add_suggestions_to_ref param_suggestions suggestions;
  let updated_ctx =
    {
      new_ctx with
      defined_vars = List.rev_append (List.map (fun p -> (p, None)) params) new_ctx.defined_vars;
      nesting_level = (create_nested_context new_ctx).nesting_level;
    }
  in
  analyze body updated_ctx

(** 分析条件表达式 *)
let analyze_conditional_expression cond then_expr else_expr new_ctx analyze suggestions =
  let updated_ctx = create_nested_context new_ctx in
  analyze cond updated_ctx;
  analyze then_expr updated_ctx;
  analyze else_expr updated_ctx;
  Refactoring_analyzer_complexity.check_nesting_depth updated_ctx.nesting_level suggestions

(** 分析函数调用表达式 *)
let analyze_function_call_expression func args new_ctx analyze =
  analyze func new_ctx;
  List.iter (fun arg -> analyze arg new_ctx) args

(** 分析模式匹配表达式 *)
let analyze_match_expression matched_expr branches new_ctx analyze =
  analyze matched_expr new_ctx;
  let updated_ctx = create_nested_context new_ctx in
  List.iter (fun branch -> analyze branch.expr updated_ctx) branches

(** 分析二元运算表达式 *)
let analyze_binary_operation_expression left right new_ctx analyze =
  analyze left new_ctx;
  analyze right new_ctx

(** 分析一元运算表达式 *)
let analyze_unary_operation_expression expr new_ctx analyze = analyze expr new_ctx

(** 分析表达式的主入口函数 *)
let analyze_expression expr context =
  let suggestions = ref [] in

  let rec analyze expr ctx =
    let new_ctx = { ctx with expression_count = ctx.expression_count + 1 } in
    match expr with
    | VarExpr name -> analyze_variable_expression name suggestions
    | LetExpr (name, val_expr, in_expr) ->
        analyze_let_expression name val_expr in_expr new_ctx analyze suggestions
    | FunExpr (params, body) -> analyze_function_expression params body new_ctx analyze suggestions
    | CondExpr (cond, then_expr, else_expr) ->
        analyze_conditional_expression cond then_expr else_expr new_ctx analyze suggestions
    | FunCallExpr (func, args) -> analyze_function_call_expression func args new_ctx analyze
    | MatchExpr (matched_expr, branches) ->
        analyze_match_expression matched_expr branches new_ctx analyze
    | BinaryOpExpr (left, _, right) ->
        analyze_binary_operation_expression left right new_ctx analyze
    | UnaryOpExpr (_, expr) -> analyze_unary_operation_expression expr new_ctx analyze
    | _ -> ()
  in

  analyze expr context;

  (* 添加性能分析建议 *)
  let performance_suggestions =
    Refactoring_analyzer_performance.analyze_performance_hints expr context
  in
  add_suggestions_to_ref performance_suggestions suggestions;

  !suggestions

(** 分析语句 *)
let analyze_statement stmt context =
  match stmt with
  | ExprStmt expr -> analyze_expression expr context
  | LetStmt (name, expr) ->
      let naming_suggestions = Refactoring_analyzer_naming.analyze_naming_quality name in
      let expr_suggestions = analyze_expression expr context in
      List.rev_append naming_suggestions expr_suggestions
  | RecLetStmt (name, expr) ->
      let naming_suggestions = Refactoring_analyzer_naming.analyze_naming_quality name in
      let new_context = { context with current_function = Some name } in
      let complexity_suggestion =
        match Refactoring_analyzer_complexity.analyze_function_complexity name expr new_context with
        | Some s -> [ s ]
        | None -> []
      in
      let expr_suggestions = analyze_expression expr new_context in
      naming_suggestions @ complexity_suggestion @ expr_suggestions
  | _ -> []

(** 分析整个程序 *)
let analyze_program program =
  let all_suggestions = ref [] in
  let context = ref empty_context in

  (* 收集所有表达式用于重复代码检测 *)
  let all_expressions = ref [] in

  let collect_expressions = function
    | ExprStmt expr -> all_expressions := expr :: !all_expressions
    | LetStmt (_, expr) -> all_expressions := expr :: !all_expressions
    | RecLetStmt (_, expr) -> all_expressions := expr :: !all_expressions
    | _ -> ()
  in

  (* 分析每个语句 *)
  List.iter
    (fun stmt ->
      collect_expressions stmt;
      let stmt_suggestions = analyze_statement stmt !context in
      add_suggestions_to_ref stmt_suggestions all_suggestions)
    program;

  (* 进行重复代码检测 *)
  let duplication_suggestions =
    Refactoring_analyzer_duplication.detect_code_duplication !all_expressions
  in
  add_suggestions_to_ref duplication_suggestions all_suggestions;

  (* 按置信度排序建议 *)
  List.sort (fun a b -> compare b.confidence a.confidence) !all_suggestions

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

(** 快速质量检查 - 返回关键质量指标 *)
let quick_quality_check program =
  let suggestions = analyze_program program in

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
  Buffer.add_string report (Unified_logger.Legacy.sprintf "   • 总计发现 %d 个改进机会\n" total);
  Buffer.add_string report
    (Unified_logger.Legacy.sprintf "   • 高优先级: %d 个 | 中优先级: %d 个 | 低优先级: %d 个\n\n" high medium low);

  Buffer.add_string report "📊 问题分类统计:\n";
  Buffer.add_string report (Unified_logger.Legacy.sprintf "   📝 命名规范: %d 个\n" naming);
  Buffer.add_string report (Unified_logger.Legacy.sprintf "   ⚡ 代码复杂度: %d 个\n" complexity);
  Buffer.add_string report (Unified_logger.Legacy.sprintf "   🔄 重复代码: %d 个\n" duplication);
  Buffer.add_string report (Unified_logger.Legacy.sprintf "   🚀 性能优化: %d 个\n\n" performance);

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
