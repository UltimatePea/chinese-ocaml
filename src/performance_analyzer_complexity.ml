(** 计算复杂度性能分析器模块

    专门分析计算复杂度和嵌套循环 重构版本：使用公共基础模块消除代码重复 创建时间：技术债务清理 Fix #794 *)

open Ast
open Performance_analyzer_base

type complexity_state = { nesting_level : int }
(** 嵌套层级跟踪的状态 *)

(** 初始状态 *)
let initial_state = { nesting_level = 0 }

(** 复杂度特定的性能分析逻辑 *)
let complexity_specific_analysis expr =
  let rec analyze_with_nesting expr state =
    match expr with
    | FunCallExpr (VarExpr func_name, args) when List.mem func_name [ "映射"; "过滤"; "折叠"; "遍历" ] ->
        let new_nesting = state.nesting_level + 1 in
        let current_suggestions =
          if new_nesting >= 1 then [ SuggestionBuilder.complexity_suggestion new_nesting ] else []
        in
        (* 递归分析参数 *)
        let arg_suggestions =
          List.fold_left
            (fun acc arg -> acc @ analyze_with_nesting arg { nesting_level = new_nesting })
            [] args
        in
        current_suggestions @ arg_suggestions
    | FunCallExpr (func, args) ->
        (* 对于其他函数调用，继续递归分析 *)
        let func_suggestions = analyze_with_nesting func state in
        let arg_suggestions =
          List.fold_left (fun acc arg -> acc @ analyze_with_nesting arg state) [] args
        in
        func_suggestions @ arg_suggestions
    | _ -> []
  in
  analyze_with_nesting expr initial_state

(** 分析计算复杂度 *)
let analyze_computational_complexity expr =
  create_performance_analyzer complexity_specific_analysis expr
