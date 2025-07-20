(** 模式匹配性能分析器模块
    
    专门分析模式匹配的性能问题，从refactoring_analyzer_performance.ml中提取
    创建目的：减少主文件复杂度，专注于模式匹配相关的性能优化
    创建时间：技术债务清理 Fix #654 *)

open Ast
open Refactoring_analyzer_types

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