(** 性能分析器模块 - 专门检测潜在的性能问题和优化机会 *)

open Ast
open Refactoring_analyzer_types

(** 性能问题类型 *)
type performance_issue =
  | ListConcatenation
  | LargeMatchExpression of int
  | DeepRecursion of int
  | IneffientIteration
  | UnoptimizedDataStructure

(** 分析列表操作性能 *)
let analyze_list_performance expr =
  let rec analyze_expr expr =
    match expr with
    | FunCallExpr (VarExpr "连接", [ ListExpr _; ListExpr _ ]) ->
        [{
          suggestion_type = PerformanceHint "列表连接优化";
          message = "检测到列表连接操作，对于大量数据建议使用更高效的方法";
          confidence = 0.65;
          location = Some "列表连接操作";
          suggested_fix = Some "考虑使用累加器模式或专用的列表连接函数";
        }]
    | FunCallExpr (VarExpr "追加", args) when List.length args >= 2 ->
        [{
          suggestion_type = PerformanceHint "列表追加优化";
          message = "频繁的列表追加操作可能影响性能";
          confidence = 0.60;
          location = Some "列表追加操作";
          suggested_fix = Some "考虑使用可变数据结构或反向构建再反转";
        }]
    | CondExpr (_, then_expr, else_expr) ->
        (analyze_expr then_expr) @ (analyze_expr else_expr)
    | BinaryOpExpr (left, _, right) ->
        (analyze_expr left) @ (analyze_expr right)
    | FunCallExpr (func, args) ->
        let func_suggestions = analyze_expr func in
        let args_suggestions = List.concat_map analyze_expr args in
        func_suggestions @ args_suggestions
    | MatchExpr (matched_expr, branches) ->
        let matched_suggestions = analyze_expr matched_expr in
        let branches_suggestions = List.concat_map (fun branch -> analyze_expr branch.expr) branches in
        matched_suggestions @ branches_suggestions
    | LetExpr (_, val_expr, in_expr) ->
        (analyze_expr val_expr) @ (analyze_expr in_expr)
    | _ -> []
  in
  
  analyze_expr expr

(** 分析模式匹配性能 *)
let analyze_match_performance expr =
  let rec analyze_expr expr =
    match expr with
    | MatchExpr (_, branches) when List.length branches > 20 ->
        let branch_suggestions = List.concat_map (fun branch -> analyze_expr branch.expr) branches in
        {
          suggestion_type = PerformanceHint "过多分支警告";
          message = Unified_logger.Legacy.sprintf "匹配表达式包含%d个分支，严重影响性能和可读性" (List.length branches);
          confidence = 0.85;
          location = Some "模式匹配";
          suggested_fix = Some "强烈建议重构为多个函数或使用映射表";
        } :: branch_suggestions
    | MatchExpr (_, branches) when List.length branches > 10 ->
        let branch_suggestions = List.concat_map (fun branch -> analyze_expr branch.expr) branches in
        {
          suggestion_type = PerformanceHint "大量分支优化";
          message = Unified_logger.Legacy.sprintf "匹配表达式包含%d个分支，可能影响性能" (List.length branches);
          confidence = 0.70;
          location = Some "模式匹配";
          suggested_fix = Some "考虑使用哈希表或重构为更少的分支";
        } :: branch_suggestions
    | MatchExpr (matched_expr, branches) ->
        let matched_suggestions = analyze_expr matched_expr in
        let branch_suggestions = List.concat_map (fun branch -> analyze_expr branch.expr) branches in
        matched_suggestions @ branch_suggestions
    | CondExpr (_, then_expr, else_expr) ->
        (analyze_expr then_expr) @ (analyze_expr else_expr)
    | BinaryOpExpr (left, _, right) ->
        (analyze_expr left) @ (analyze_expr right)
    | FunCallExpr (func, args) ->
        let func_suggestions = analyze_expr func in
        let args_suggestions = List.concat_map analyze_expr args in
        func_suggestions @ args_suggestions
    | LetExpr (_, val_expr, in_expr) ->
        (analyze_expr val_expr) @ (analyze_expr in_expr)
    | _ -> []
  in

  analyze_expr expr

(** 分析递归深度和优化 *)
let analyze_recursion_performance expr =
  let rec count_recursive_calls func_name expr depth =
    match expr with
    | FunCallExpr (VarExpr name, args) when name = func_name ->
        let args_depth =
          List.fold_left
            (fun acc arg -> max acc (count_recursive_calls func_name arg (depth + 1)))
            depth args
        in
        args_depth + 1
    | CondExpr (cond, then_expr, else_expr) ->
        let cond_depth = count_recursive_calls func_name cond depth in
        let then_depth = count_recursive_calls func_name then_expr depth in
        let else_depth = count_recursive_calls func_name else_expr depth in
        max cond_depth (max then_depth else_depth)
    | MatchExpr (matched_expr, branches) ->
        let matched_depth = count_recursive_calls func_name matched_expr depth in
        let branches_depth =
          List.fold_left
            (fun acc branch -> max acc (count_recursive_calls func_name branch.expr depth))
            0 branches
        in
        max matched_depth branches_depth
    | BinaryOpExpr (left, _, right) ->
        let left_depth = count_recursive_calls func_name left depth in
        let right_depth = count_recursive_calls func_name right depth in
        max left_depth right_depth
    | FunCallExpr (func, args) ->
        let func_depth = count_recursive_calls func_name func depth in
        let args_depth =
          List.fold_left (fun acc arg -> max acc (count_recursive_calls func_name arg depth)) 0 args
        in
        max func_depth args_depth
    | LetExpr (_, val_expr, in_expr) ->
        let val_depth = count_recursive_calls func_name val_expr depth in
        let in_depth = count_recursive_calls func_name in_expr depth in
        max val_depth in_depth
    | _ -> depth
  in

  (* 这里需要函数名，实际使用时会从上下文获取 *)
  let estimated_depth = count_recursive_calls "unknown" expr 0 in

  if estimated_depth > 5 then
    [{
      suggestion_type = PerformanceHint "深度递归优化";
      message = Unified_logger.Legacy.sprintf "检测到可能的深度递归（估计深度: %d），可能导致栈溢出" estimated_depth;
      confidence = 0.75;
      location = Some "递归函数";
      suggested_fix = Some "考虑使用尾递归优化、累加器模式或迭代实现";
    }]
  else
    []

(** 分析数据结构使用效率 *)
let analyze_data_structure_efficiency expr =
  let rec analyze_expr expr =
    match expr with
    | ListExpr exprs when List.length exprs > 1000 ->
        [{
          suggestion_type = PerformanceHint "大型列表优化";
          message = Unified_logger.Legacy.sprintf "创建了包含%d个元素的大型列表" (List.length exprs);
          confidence = 0.70;
          location = Some "列表创建";
          suggested_fix = Some "考虑使用数组或其他更高效的数据结构";
        }]
    | RecordExpr fields when List.length fields > 50 ->
        [{
          suggestion_type = PerformanceHint "大型记录优化";
          message = Unified_logger.Legacy.sprintf "创建了包含%d个字段的大型记录" (List.length fields);
          confidence = 0.65;
          location = Some "记录创建";
          suggested_fix = Some "考虑拆分为多个小记录或使用其他数据结构";
        }]
    | FunCallExpr (VarExpr "查找", [ ListExpr _; _ ]) ->
        [{
          suggestion_type = PerformanceHint "线性查找优化";
          message = "在列表中进行线性查找，对于大型数据集效率较低";
          confidence = 0.60;
          location = Some "列表查找";
          suggested_fix = Some "考虑使用映射表、集合或其他支持快速查找的数据结构";
        }]
    | CondExpr (_, then_expr, else_expr) ->
        (analyze_expr then_expr) @ (analyze_expr else_expr)
    | BinaryOpExpr (left, _, right) ->
        (analyze_expr left) @ (analyze_expr right)
    | FunCallExpr (func, args) ->
        let func_suggestions = analyze_expr func in
        let args_suggestions = List.concat_map analyze_expr args in
        func_suggestions @ args_suggestions
    | MatchExpr (matched_expr, branches) ->
        let matched_suggestions = analyze_expr matched_expr in
        let branches_suggestions = List.concat_map (fun branch -> analyze_expr branch.expr) branches in
        matched_suggestions @ branches_suggestions
    | LetExpr (_, val_expr, in_expr) ->
        (analyze_expr val_expr) @ (analyze_expr in_expr)
    | _ -> []
  in

  analyze_expr expr

(** 分析计算复杂度 *)
let analyze_computational_complexity expr =
  let rec detect_nested_loops_with_suggestions expr nesting_level =
    match expr with
    | FunCallExpr (VarExpr func_name, _) when List.mem func_name [ "映射"; "过滤"; "折叠"; "遍历" ] ->
        let suggestion = 
          if nesting_level >= 2 then
            [{
              suggestion_type = PerformanceHint "嵌套循环优化";
              message =
                Unified_logger.Legacy.sprintf "检测到%d层嵌套的循环操作，复杂度可能为O(n^%d)" nesting_level
                  nesting_level;
              confidence = 0.75;
              location = Some "嵌套循环";
              suggested_fix = Some "考虑算法优化、预计算或使用更高效的数据结构";
            }]
          else
            []
        in
        (nesting_level + 1, suggestion)
    | CondExpr (_, then_expr, else_expr) ->
        let (_, then_suggestions) = detect_nested_loops_with_suggestions then_expr nesting_level in
        let (_, else_suggestions) = detect_nested_loops_with_suggestions else_expr nesting_level in
        (nesting_level, then_suggestions @ else_suggestions)
    | BinaryOpExpr (left, _, right) ->
        let (_, left_suggestions) = detect_nested_loops_with_suggestions left nesting_level in
        let (_, right_suggestions) = detect_nested_loops_with_suggestions right nesting_level in
        (nesting_level, left_suggestions @ right_suggestions)
    | FunCallExpr (func, args) ->
        let (_, func_suggestions) = detect_nested_loops_with_suggestions func nesting_level in
        let args_suggestions = List.concat_map (fun arg -> 
          let (_, suggestions) = detect_nested_loops_with_suggestions arg nesting_level in
          suggestions
        ) args in
        (nesting_level, func_suggestions @ args_suggestions)
    | MatchExpr (matched_expr, branches) ->
        let (_, matched_suggestions) = detect_nested_loops_with_suggestions matched_expr nesting_level in
        let branches_suggestions = List.concat_map (fun branch -> 
          let (_, suggestions) = detect_nested_loops_with_suggestions branch.expr nesting_level in
          suggestions
        ) branches in
        (nesting_level, matched_suggestions @ branches_suggestions)
    | LetExpr (_, val_expr, in_expr) ->
        let (_, val_suggestions) = detect_nested_loops_with_suggestions val_expr nesting_level in
        let (_, in_suggestions) = detect_nested_loops_with_suggestions in_expr nesting_level in
        (nesting_level, val_suggestions @ in_suggestions)
    | _ -> (nesting_level, [])
  in

  let (_, suggestions) = detect_nested_loops_with_suggestions expr 0 in
  suggestions

(** 综合性能分析 *)
let analyze_performance_hints expr _context =
  let list_suggestions = analyze_list_performance expr in
  let match_suggestions = analyze_match_performance expr in
  let recursion_suggestions = analyze_recursion_performance expr in
  let data_structure_suggestions = analyze_data_structure_efficiency expr in
  let complexity_suggestions = analyze_computational_complexity expr in

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
    (Unified_logger.Legacy.sprintf "📊 性能问题统计: %d 个\n\n" (List.length performance_suggestions));

  if List.length performance_suggestions = 0 then Buffer.add_string report "✅ 恭喜！没有发现明显的性能问题。\n"
  else (
    Buffer.add_string report "⚡ 性能优化建议:\n\n";
    List.iteri
      (fun i suggestion ->
        Buffer.add_string report
          (Unified_logger.Legacy.sprintf "%d. %s\n" (i + 1) suggestion.message);
        match suggestion.suggested_fix with
        | Some fix -> Buffer.add_string report (Unified_logger.Legacy.sprintf "   💡 %s\n\n" fix)
        | None -> Buffer.add_string report "\n")
      performance_suggestions;

    Buffer.add_string report "🎯 性能优化原则:\n";
    Buffer.add_string report "   • 选择合适的数据结构\n";
    Buffer.add_string report "   • 避免不必要的计算和内存分配\n";
    Buffer.add_string report "   • 优化算法复杂度\n";
    Buffer.add_string report "   • 使用尾递归和累加器模式\n";
    Buffer.add_string report "   • 考虑惰性计算和缓存策略\n");

  Buffer.contents report
