(** 性能分析器公共基础模块

    提供所有性能分析器共享的通用表达式分析逻辑和建议生成功能 创建目的：消除代码重复，提供统一的分析接口 创建时间：技术债务清理 Fix #794 *)

open Ast
open Refactoring_analyzer_types
open Utils.Base_formatter

type expression_analyzer = expr -> refactoring_suggestion list
(** 通用表达式分析器类型 *)

(** 递归表达式分析的公共实现 *)
let rec analyze_expr_recursively (specific_analyzer : expression_analyzer) expr =
  let current_suggestions = specific_analyzer expr in
  let child_suggestions =
    match expr with
    | CondExpr (_, then_expr, else_expr) ->
        analyze_expr_recursively specific_analyzer then_expr
        @ analyze_expr_recursively specific_analyzer else_expr
    | BinaryOpExpr (left, _, right) ->
        analyze_expr_recursively specific_analyzer left
        @ analyze_expr_recursively specific_analyzer right
    | FunCallExpr (func, args) ->
        let func_suggestions = analyze_expr_recursively specific_analyzer func in
        let args_suggestions = List.concat_map (analyze_expr_recursively specific_analyzer) args in
        func_suggestions @ args_suggestions
    | MatchExpr (matched_expr, branches) ->
        let matched_suggestions = analyze_expr_recursively specific_analyzer matched_expr in
        let branches_suggestions =
          List.concat_map
            (fun branch -> analyze_expr_recursively specific_analyzer branch.expr)
            branches
        in
        matched_suggestions @ branches_suggestions
    | LetExpr (_, val_expr, in_expr) ->
        analyze_expr_recursively specific_analyzer val_expr
        @ analyze_expr_recursively specific_analyzer in_expr
    | _ -> []
  in
  current_suggestions @ child_suggestions

(** 构建性能优化建议的辅助函数 *)
let make_performance_suggestion ~hint_type ~message ~confidence ~location ~fix =
  {
    suggestion_type = PerformanceHint hint_type;
    message;
    confidence;
    location = Some location;
    suggested_fix = Some fix;
  }

(** 常用的建议生成器 *)
module SuggestionBuilder = struct
  (** 列表操作优化建议 *)
  let list_optimization_suggestion operation_name specific_message =
    make_performance_suggestion ~hint_type:(operation_name ^ "优化") ~message:specific_message
      ~confidence:0.65 ~location:(operation_name ^ "操作") ~fix:"考虑使用更高效的数据结构或算法"

  (** 模式匹配优化建议 *)
  let pattern_matching_suggestion branch_count _severity =
    let hint_type, message, confidence, fix =
      if branch_count > 20 then
        ("过多分支警告", concat_strings ["匹配表达式包含"; int_to_string branch_count; "个分支，严重影响性能和可读性"], 0.85, "强烈建议重构为多个函数或使用映射表")
      else ("大量分支优化", concat_strings ["匹配表达式包含"; int_to_string branch_count; "个分支，可能影响性能"], 0.70, "考虑重构为更小的函数或使用查找表")
    in
    make_performance_suggestion ~hint_type ~message ~confidence ~location:"模式匹配" ~fix

  (** 复杂度优化建议 *)
  let complexity_suggestion nesting_level =
    make_performance_suggestion ~hint_type:"嵌套循环优化"
      ~message:(concat_strings ["检测到"; int_to_string nesting_level; "层嵌套的循环操作，复杂度可能为O(n^"; int_to_string nesting_level; ")"])
      ~confidence:0.75 ~location:"嵌套循环" ~fix:"考虑算法优化、预计算或使用更高效的数据结构"
end

(** 创建标准化的性能分析器 *)
let create_performance_analyzer (specific_analysis : expr -> refactoring_suggestion list) expr =
  analyze_expr_recursively specific_analysis expr
