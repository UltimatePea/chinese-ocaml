(** 计算复杂度性能分析器模块
    
    专门分析计算复杂度和嵌套循环，从refactoring_analyzer_performance.ml中提取
    创建目的：减少主文件复杂度，专注于复杂度相关的性能优化
    创建时间：技术债务清理 Fix #654 *)

open Ast
open Refactoring_analyzer_types

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