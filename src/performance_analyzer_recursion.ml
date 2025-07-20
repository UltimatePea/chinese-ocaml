(** 递归性能分析器模块
    
    专门分析递归深度和优化建议，从refactoring_analyzer_performance.ml中提取
    创建目的：减少主文件复杂度，专注于递归相关的性能优化
    创建时间：技术债务清理 Fix #654 *)

open Ast
open Refactoring_analyzer_types

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