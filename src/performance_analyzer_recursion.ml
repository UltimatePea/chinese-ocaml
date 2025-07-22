(** 递归性能分析器模块

    专门分析递归深度和优化建议 重构版本：使用公共基础模块消除代码重复 创建时间：技术债务清理 Fix #794 *)

open Ast
open Performance_analyzer_base

(** 估算表达式中的递归深度 *)
let estimate_recursion_depth expr =
  let rec count_nested_calls expr depth =
    match expr with
    | FunCallExpr (VarExpr _, args) ->
        let args_depth =
          List.fold_left (fun acc arg -> max acc (count_nested_calls arg (depth + 1))) depth args
        in
        args_depth + 1
    | CondExpr (cond, then_expr, else_expr) ->
        let cond_depth = count_nested_calls cond depth in
        let then_depth = count_nested_calls then_expr depth in
        let else_depth = count_nested_calls else_expr depth in
        max cond_depth (max then_depth else_depth)
    | MatchExpr (matched_expr, branches) ->
        let matched_depth = count_nested_calls matched_expr depth in
        let branches_depth =
          List.fold_left
            (fun acc branch -> max acc (count_nested_calls branch.expr depth))
            0 branches
        in
        max matched_depth branches_depth
    | BinaryOpExpr (left, _, right) ->
        let left_depth = count_nested_calls left depth in
        let right_depth = count_nested_calls right depth in
        max left_depth right_depth
    | LetExpr (_, val_expr, in_expr) ->
        let val_depth = count_nested_calls val_expr depth in
        let in_depth = count_nested_calls in_expr depth in
        max val_depth in_depth
    | _ -> depth
  in
  count_nested_calls expr 0

(** 递归特定的性能分析逻辑 *)
let recursion_specific_analysis expr =
  let depth = estimate_recursion_depth expr in
  if depth > 5 then
    [
      make_performance_suggestion ~hint_type:"深度递归优化"
        ~message:(Printf.sprintf "检测到可能的深度递归（估计深度: %d），可能导致栈溢出" depth)
        ~confidence:0.75 ~location:"递归函数" ~fix:"考虑使用尾递归优化、累加器模式或迭代实现";
    ]
  else []

(** 分析递归深度和优化 *)
let analyze_recursion_performance expr =
  create_performance_analyzer recursion_specific_analysis expr
