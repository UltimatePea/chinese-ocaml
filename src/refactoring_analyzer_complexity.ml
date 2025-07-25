(** 代码复杂度分析器模块 - 专门处理函数复杂度和嵌套深度分析 *)

open Ast
open Refactoring_analyzer_types
open Utils.Base_formatter

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
        message =
          concat_strings [ "函数「"; name; "」复杂度过高（"; int_to_string complexity; "），建议分解为更小的函数" ];
        confidence = 0.85;
        location = Some ("函数 " ^ name);
        suggested_fix =
          Some
            (concat_strings
               [
                 "考虑将「";
                 name;
                 "」分解为";
                 int_to_string ((complexity / Config.max_function_complexity) + 1);
                 "个更简单的子函数";
               ]);
      }
  else None

(** 检查嵌套深度并生成建议 *)
let check_nesting_depth nesting_level suggestions =
  if nesting_level > Config.max_nesting_level then
    suggestions :=
      {
        suggestion_type = FunctionComplexity nesting_level;
        message = concat_strings [ "嵌套层级过深（"; int_to_string nesting_level; "层），建议重构以提高可读性" ];
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

type complexity_check = {
  threshold : int;
  metric_name : string;
  message_generator : string -> int -> string;
  confidence : float;
  suggested_fix : string;
}
(** 复杂度检查配置 *)

(** 复杂度检查定义 *)
let complexity_checks =
  [
    {
      threshold = Config.max_function_complexity;
      metric_name = "表达式复杂度";
      message_generator =
        (fun name value ->
          concat_strings [ "函数「"; name; "」表达式复杂度过高（"; int_to_string value; "），建议分解" ]);
      confidence = 0.85;
      suggested_fix = "将复杂逻辑分解为多个简单函数";
    };
    {
      threshold = 10;
      metric_name = "圈复杂度";
      message_generator =
        (fun name value ->
          concat_strings [ "函数「"; name; "」圈复杂度过高（"; int_to_string value; "），建议减少条件分支" ]);
      confidence = 0.80;
      suggested_fix = "简化条件逻辑，考虑使用策略模式或查找表";
    };
    {
      threshold = Config.max_nesting_level;
      metric_name = "嵌套深度";
      message_generator =
        (fun name value ->
          concat_strings [ "函数「"; name; "」嵌套层级过深（"; int_to_string value; "层），影响可读性" ]);
      confidence = 0.75;
      suggested_fix = "提取嵌套逻辑为独立函数，使用早期返回模式";
    };
    {
      threshold = 15;
      metric_name = "认知复杂度";
      message_generator =
        (fun name value ->
          concat_strings [ "函数「"; name; "」认知复杂度过高（"; int_to_string value; "），难以理解" ]);
      confidence = 0.70;
      suggested_fix = "重构复杂逻辑，添加中间变量和辅助函数";
    };
  ]

(** 创建复杂度建议 *)
let create_complexity_suggestion name value check =
  {
    suggestion_type = FunctionComplexity value;
    message = check.message_generator name value;
    confidence = check.confidence;
    location = Some ("函数 " ^ name);
    suggested_fix = Some check.suggested_fix;
  }

(** 综合复杂度分析 *)
let comprehensive_complexity_analysis name expr context =
  (* 计算各种复杂度指标 *)
  let metrics =
    [
      calculate_expression_complexity expr context;
      calculate_cyclomatic_complexity expr;
      analyze_nesting_depth expr;
      calculate_cognitive_complexity expr;
    ]
  in

  (* 检查每个复杂度指标并生成建议 *)
  List.fold_left2
    (fun acc metric check ->
      if metric > check.threshold then create_complexity_suggestion name metric check :: acc
      else acc)
    [] metrics complexity_checks

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
    (concat_strings [ "📊 复杂度问题统计: "; int_to_string (List.length complexity_suggestions); " 个\n\n" ]);

  (match complexity_suggestions with
  | [] -> Buffer.add_string report "✅ 恭喜！您的代码复杂度控制良好。\n"
  | _ ->
      Buffer.add_string report "🔧 复杂度优化建议:\n";
      List.iteri
        (fun i suggestion ->
          Buffer.add_string report
            (concat_strings [ int_to_string (i + 1); ". "; suggestion.message; "\n" ]);
          match suggestion.suggested_fix with
          | Some fix -> Buffer.add_string report (concat_strings [ "   💡 "; fix; "\n\n" ])
          | None -> Buffer.add_string report "\n")
        complexity_suggestions);

  Buffer.contents report
