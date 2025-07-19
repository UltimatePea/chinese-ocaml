(** 代码复杂度分析器模块 - 专门处理函数复杂度和嵌套深度分析 *)

open Ast
open Refactoring_analyzer_types

(** 计算表达式复杂度 *)
let rec calculate_expression_complexity expr context =
  let base_complexity = 1 in
  let nested_complexity = context.nesting_level * 2 in

  match expr with
  | LitExpr _ | VarExpr _ -> base_complexity
  | BinaryOpExpr (left, _, right) ->
      base_complexity
      + calculate_expression_complexity left context
      + calculate_expression_complexity right context
  | UnaryOpExpr (_, expr) -> base_complexity + calculate_expression_complexity expr context
  | FunCallExpr (func, args) ->
      base_complexity + 2
      +
      (* 函数调用额外复杂度 *)
      calculate_expression_complexity func context
      + List.fold_left (fun acc arg -> acc + calculate_expression_complexity arg context) 0 args
  | CondExpr (cond, then_expr, else_expr) ->
      let new_context = { context with nesting_level = context.nesting_level + 1 } in
      base_complexity + 3
      +
      (* 条件表达式额外复杂度 *)
      calculate_expression_complexity cond context
      + calculate_expression_complexity then_expr new_context
      + calculate_expression_complexity else_expr new_context
  | MatchExpr (expr, branches) ->
      let new_context = { context with nesting_level = context.nesting_level + 1 } in
      base_complexity + List.length branches
      +
      (* 每个分支增加复杂度 *)
      calculate_expression_complexity expr context
      + List.fold_left
          (fun acc branch -> acc + calculate_expression_complexity branch.expr new_context)
          0 branches
  | LetExpr (_, val_expr, in_expr) ->
      base_complexity
      + calculate_expression_complexity val_expr context
      + calculate_expression_complexity in_expr context
  | _ -> base_complexity + nested_complexity

(** 分析函数复杂度 *)
let analyze_function_complexity name expr context =
  let complexity = calculate_expression_complexity expr context in
  if complexity > Config.max_function_complexity then
    Some
      {
        suggestion_type = FunctionComplexity complexity;
        message = Unified_logger.Legacy.sprintf "函数「%s」复杂度过高（%d），建议分解为更小的函数" name complexity;
        confidence = 0.85;
        location = Some ("函数 " ^ name);
        suggested_fix =
          Some
            (Unified_logger.Legacy.sprintf "考虑将「%s」分解为%d个更简单的子函数" name
               ((complexity / Config.max_function_complexity) + 1));
      }
  else None

(** 检查嵌套深度并生成建议 *)
let check_nesting_depth nesting_level suggestions =
  if nesting_level > Config.max_nesting_level then
    suggestions :=
      {
        suggestion_type = FunctionComplexity nesting_level;
        message = Unified_logger.Legacy.sprintf "嵌套层级过深（%d层），建议重构以提高可读性" nesting_level;
        confidence = 0.80;
        location = Some "条件表达式";
        suggested_fix = Some "考虑提取嵌套逻辑为独立函数";
      }
      :: !suggestions

(** 计算圈复杂度（Cyclomatic Complexity） *)
let rec calculate_cyclomatic_complexity expr =
  let base_complexity = 1 in
  match expr with
  | LitExpr _ | VarExpr _ -> 0
  | BinaryOpExpr (left, _, right) ->
      calculate_cyclomatic_complexity left + calculate_cyclomatic_complexity right
  | UnaryOpExpr (_, expr) -> calculate_cyclomatic_complexity expr
  | FunCallExpr (func, args) ->
      calculate_cyclomatic_complexity func
      + List.fold_left (fun acc arg -> acc + calculate_cyclomatic_complexity arg) 0 args
  | CondExpr (cond, then_expr, else_expr) ->
      base_complexity
      + calculate_cyclomatic_complexity cond
      + calculate_cyclomatic_complexity then_expr
      + calculate_cyclomatic_complexity else_expr
  | MatchExpr (expr, branches) ->
      List.length branches
      + calculate_cyclomatic_complexity expr
      + List.fold_left
          (fun acc branch -> acc + calculate_cyclomatic_complexity branch.expr)
          0 branches
  | LetExpr (_, val_expr, in_expr) ->
      calculate_cyclomatic_complexity val_expr + calculate_cyclomatic_complexity in_expr
  | _ -> 0

(** 分析表达式嵌套深度 *)
let analyze_nesting_depth expr =
  let rec count_depth expr current_depth =
    let new_depth = current_depth + 1 in
    match expr with
    | LitExpr _ | VarExpr _ -> current_depth
    | BinaryOpExpr (left, _, right) ->
        max (count_depth left new_depth) (count_depth right new_depth)
    | UnaryOpExpr (_, expr) -> count_depth expr new_depth
    | FunCallExpr (func, args) ->
        let func_depth = count_depth func new_depth in
        let args_depth =
          List.fold_left (fun acc arg -> max acc (count_depth arg new_depth)) 0 args
        in
        max func_depth args_depth
    | CondExpr (cond, then_expr, else_expr) ->
        let cond_depth = count_depth cond new_depth in
        let then_depth = count_depth then_expr new_depth in
        let else_depth = count_depth else_expr new_depth in
        max cond_depth (max then_depth else_depth)
    | MatchExpr (matched_expr, branches) ->
        let matched_depth = count_depth matched_expr new_depth in
        let branches_depth =
          List.fold_left (fun acc branch -> max acc (count_depth branch.expr new_depth)) 0 branches
        in
        max matched_depth branches_depth
    | LetExpr (_, val_expr, in_expr) ->
        max (count_depth val_expr new_depth) (count_depth in_expr new_depth)
    | _ -> current_depth
  in
  count_depth expr 0

(** 分析认知复杂度（Cognitive Complexity） *)
let calculate_cognitive_complexity expr =
  let rec analyze expr nesting_level =
    match expr with
    | LitExpr _ | VarExpr _ -> 0
    | BinaryOpExpr (left, _, right) -> analyze left nesting_level + analyze right nesting_level
    | UnaryOpExpr (_, expr) -> analyze expr nesting_level
    | FunCallExpr (func, args) ->
        analyze func nesting_level
        + List.fold_left (fun acc arg -> acc + analyze arg nesting_level) 0 args
    | CondExpr (cond, then_expr, else_expr) ->
        let complexity = 1 + nesting_level in
        (* +1 for the conditional, +nesting_level for nested complexity *)
        complexity + analyze cond nesting_level
        + analyze then_expr (nesting_level + 1)
        + analyze else_expr (nesting_level + 1)
    | MatchExpr (matched_expr, branches) ->
        let complexity = 1 + nesting_level in
        complexity
        + analyze matched_expr nesting_level
        + List.fold_left
            (fun acc branch -> acc + analyze branch.expr (nesting_level + 1))
            0 branches
    | LetExpr (_, val_expr, in_expr) ->
        analyze val_expr nesting_level + analyze in_expr nesting_level
    | _ -> 0
  in
  analyze expr 0

(** 综合复杂度分析 *)
let comprehensive_complexity_analysis name expr context =
  let suggestions = ref [] in

  (* 计算各种复杂度指标 *)
  let expression_complexity = calculate_expression_complexity expr context in
  let cyclomatic_complexity = calculate_cyclomatic_complexity expr in
  let nesting_depth = analyze_nesting_depth expr in
  let cognitive_complexity = calculate_cognitive_complexity expr in

  (* 检查表达式复杂度 *)
  if expression_complexity > Config.max_function_complexity then
    suggestions :=
      {
        suggestion_type = FunctionComplexity expression_complexity;
        message = Unified_logger.Legacy.sprintf "函数「%s」表达式复杂度过高（%d），建议分解" name expression_complexity;
        confidence = 0.85;
        location = Some ("函数 " ^ name);
        suggested_fix = Some "将复杂逻辑分解为多个简单函数";
      }
      :: !suggestions;

  (* 检查圈复杂度 *)
  if cyclomatic_complexity > 10 then
    suggestions :=
      {
        suggestion_type = FunctionComplexity cyclomatic_complexity;
        message =
          Unified_logger.Legacy.sprintf "函数「%s」圈复杂度过高（%d），建议减少条件分支" name cyclomatic_complexity;
        confidence = 0.80;
        location = Some ("函数 " ^ name);
        suggested_fix = Some "简化条件逻辑，考虑使用策略模式或查找表";
      }
      :: !suggestions;

  (* 检查嵌套深度 *)
  if nesting_depth > Config.max_nesting_level then
    suggestions :=
      {
        suggestion_type = FunctionComplexity nesting_depth;
        message = Unified_logger.Legacy.sprintf "函数「%s」嵌套层级过深（%d层），影响可读性" name nesting_depth;
        confidence = 0.75;
        location = Some ("函数 " ^ name);
        suggested_fix = Some "提取嵌套逻辑为独立函数，使用早期返回模式";
      }
      :: !suggestions;

  (* 检查认知复杂度 *)
  if cognitive_complexity > 15 then
    suggestions :=
      {
        suggestion_type = FunctionComplexity cognitive_complexity;
        message = Unified_logger.Legacy.sprintf "函数「%s」认知复杂度过高（%d），难以理解" name cognitive_complexity;
        confidence = 0.70;
        location = Some ("函数 " ^ name);
        suggested_fix = Some "重构复杂逻辑，添加中间变量和辅助函数";
      }
      :: !suggestions;

  !suggestions

(** 生成复杂度分析报告 *)
let generate_complexity_report suggestions =
  let complexity_suggestions =
    List.filter
      (function { suggestion_type = FunctionComplexity _; _ } -> true | _ -> false)
      suggestions
  in

  let report = Buffer.create (Constants.BufferSizes.default_buffer ()) in

  Buffer.add_string report "⚡ 代码复杂度分析报告\n";
  Buffer.add_string report "==========================\n\n";

  Buffer.add_string report
    (Unified_logger.Legacy.sprintf "📊 复杂度问题统计: %d 个\n\n" (List.length complexity_suggestions));

  if List.length complexity_suggestions = 0 then Buffer.add_string report "✅ 恭喜！您的代码复杂度控制良好。\n"
  else (
    Buffer.add_string report "🔧 复杂度优化建议:\n";
    List.iteri
      (fun i suggestion ->
        Buffer.add_string report
          (Unified_logger.Legacy.sprintf "%d. %s\n" (i + 1) suggestion.message);
        match suggestion.suggested_fix with
        | Some fix -> Buffer.add_string report (Unified_logger.Legacy.sprintf "   💡 %s\n\n" fix)
        | None -> Buffer.add_string report "\n")
      complexity_suggestions);

  Buffer.contents report
