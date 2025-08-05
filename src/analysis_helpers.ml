(** 分析辅助函数模块 - 提供表达式和语句分析的基础工具函数 *)

open Ast
open Refactoring_analyzer_types
open Utils.Base_formatter

(** 统一的建议添加函数，消除代码重复 *)
let add_suggestions_to_ref new_suggestions suggestions_ref =
  suggestions_ref := List.rev_append new_suggestions !suggestions_ref

(** 创建带有增加嵌套层级的上下文 *)
let create_nested_context ctx = { ctx with nesting_level = ctx.nesting_level + 1 }

(** 分析变量表达式 *)
let analyze_variable_expression name suggestions =
  add_suggestions_to_ref (Refactoring_analyzer_naming.analyze_naming_quality name) suggestions

(** 分析Let表达式 *)
let analyze_let_expression name val_expr in_expr new_ctx analyze suggestions =
  add_suggestions_to_ref (Refactoring_analyzer_naming.analyze_naming_quality name) suggestions;
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

  (* 检查参数数量是否过多 - 视为复杂度问题 *)
  let param_count = List.length params in
  (if param_count > 4 then
     let complexity_suggestion =
       {
         suggestion_type = FunctionComplexity param_count;
         message = concat_strings [ "函数参数过多（"; int_to_string param_count; "个），建议减少参数数量或使用记录类型" ];
         confidence = 0.75;
         location = Some "函数参数";
         suggested_fix = Some "考虑使用记录类型封装多个参数，或将函数分解为更小的函数";
       }
     in
     add_suggestions_to_ref [ complexity_suggestion ] suggestions);

  let updated_ctx =
    {
      new_ctx with
      defined_vars = List.rev_append (List.map (fun p -> (p, None)) params) new_ctx.defined_vars;
      nesting_level = (create_nested_context new_ctx).nesting_level;
    }
  in
  (* 分析函数体 *)
  analyze body updated_ctx

(** 分析条件表达式 *)
let analyze_conditional_expression cond then_expr else_expr new_ctx analyze suggestions =
  let updated_ctx = create_nested_context new_ctx in
  analyze cond updated_ctx;
  analyze then_expr updated_ctx;
  analyze else_expr updated_ctx;

  (* 检查嵌套条件表达式的复杂度 *)
  let has_nested_conditions =
    let check_nested = function CondExpr (_, _, _) -> true | _ -> false in
    check_nested then_expr || check_nested else_expr
  in

  (* 生成嵌套条件复杂度建议，当检测到嵌套且层级大于等于1时 *)
  if has_nested_conditions && updated_ctx.nesting_level >= 1 then (
    let complexity_suggestion =
      {
        suggestion_type = FunctionComplexity updated_ctx.nesting_level;
        message =
          concat_strings [ "检测到嵌套条件表达式（"; int_to_string updated_ctx.nesting_level; "层），可能影响代码可读性" ];
        confidence = 0.75;
        location = Some "条件表达式";
        suggested_fix = Some "考虑提取复杂条件逻辑为独立函数，或使用模式匹配简化逻辑";
      }
    in
    add_suggestions_to_ref [ complexity_suggestion ] suggestions;

    (* 另外，为性能提示检查嵌套深度 *)
    if updated_ctx.nesting_level >= 2 then (
      let performance_hint =
        {
          suggestion_type = PerformanceHint "嵌套条件表达式可能影响性能和可维护性";
          message =
            concat_strings [ "条件表达式嵌套深度达到"; int_to_string updated_ctx.nesting_level; "层，建议优化" ];
          confidence = 0.70;
          location = Some "条件表达式";
          suggested_fix = Some "考虑使用策略模式或查找表简化复杂条件逻辑";
        }
      in
      add_suggestions_to_ref [ performance_hint ] suggestions;

      (* 调用通用的嵌套深度检查 *)
      Refactoring_analyzer_complexity.check_nesting_depth updated_ctx.nesting_level suggestions))

(** 分析函数调用表达式 *)
let analyze_function_call_expression func args new_ctx analyze suggestions =
  analyze func new_ctx;
  List.iter (fun arg -> analyze arg new_ctx) args;

  (* 检查链式调用复杂度 *)
  let rec count_chained_calls = function
    | FunCallExpr (inner_func, _) -> 1 + count_chained_calls inner_func
    | _ -> 0
  in
  let chain_depth = count_chained_calls func in
  (* chain_depth >= 1 表示有嵌套函数调用，即链式调用 *)
  if chain_depth >= 1 then
    let performance_hint =
      {
        suggestion_type = PerformanceHint "链式函数调用可能影响性能和可读性";
        message = "检测到链式函数调用，建议考虑使用中间变量提高可读性";
        confidence = 0.70;
        location = Some "函数调用链";
        suggested_fix = Some "将链式调用分解为多个步骤，使用有意义的中间变量名";
      }
    in
    add_suggestions_to_ref [ performance_hint ] suggestions

(** 分析模式匹配表达式 *)
let analyze_match_expression matched_expr branches new_ctx analyze suggestions =
  analyze matched_expr new_ctx;
  let updated_ctx = create_nested_context new_ctx in
  List.iter (fun branch -> analyze branch.expr updated_ctx) branches;

  (* 检查分支复杂度 *)
  let branch_count = List.length branches in
  (if branch_count = 0 then
     let warning =
       {
         suggestion_type = FunctionComplexity 0;
         message = "模式匹配缺少分支，可能导致运行时错误";
         confidence = 0.90;
         location = Some "模式匹配";
         suggested_fix = Some "添加适当的模式匹配分支以处理所有可能的情况";
       }
     in
     add_suggestions_to_ref [ warning ] suggestions
   else if branch_count > 8 then
     let complexity_suggestion =
       {
         suggestion_type = FunctionComplexity branch_count;
         message = concat_strings [ "模式匹配分支过多（"; int_to_string branch_count; "个），建议重构" ];
         confidence = 0.75;
         location = Some "模式匹配";
         suggested_fix = Some "考虑使用函数映射表或分组相关的模式匹配";
       }
     in
     add_suggestions_to_ref [ complexity_suggestion ] suggestions);

  (* 检查分支表达式的复杂度 *)
  let has_complex_branch_expressions =
    List.exists
      (fun branch ->
        match branch.expr with
        | CondExpr (_, _, _) -> true (* 条件表达式 *)
        | FunExpr (_, _) -> true (* 任何函数表达式都被认为是复杂的 *)
        | MatchExpr (_, _) -> true (* 嵌套模式匹配 *)
        | FunCallExpr (_, args) when List.length args > 2 -> true (* 多参数函数调用 *)
        | LetExpr (_, _, _) -> true (* Let表达式也算复杂 *)
        | _ -> false)
      branches
  in

  if has_complex_branch_expressions then
    let complexity_suggestion =
      {
        suggestion_type = FunctionComplexity branch_count;
        message = "模式匹配分支包含复杂表达式，可能影响代码可读性";
        confidence = 0.70;
        location = Some "模式匹配分支";
        suggested_fix = Some "考虑将复杂的分支表达式提取为独立函数";
      }
    in
    add_suggestions_to_ref [ complexity_suggestion ] suggestions

(** 分析二元运算表达式 *)
let analyze_binary_operation_expression left right new_ctx analyze suggestions =
  analyze left new_ctx;
  analyze right new_ctx;
  (* 注：二元运算本身通常不产生额外建议，主要分析操作数 *)
  ignore suggestions

(** 分析一元运算表达式 *)
let analyze_unary_operation_expression full_unary_expr operand new_ctx analyze suggestions =
  analyze operand new_ctx;

  (* 检查嵌套一元运算 *)
  let rec count_nested_unary = function
    | UnaryOpExpr (_, inner_expr) -> 1 + count_nested_unary inner_expr
    | _ -> 0
  in
  let nesting_depth = count_nested_unary full_unary_expr in
  if nesting_depth >= 2 then
    let complexity_warning =
      {
        suggestion_type = PerformanceHint "嵌套一元运算影响可读性";
        message = concat_strings [ "检测到"; int_to_string (nesting_depth + 1); "层嵌套一元运算，建议简化表达式" ];
        confidence = 0.65;
        location = Some "一元运算";
        suggested_fix = Some "使用中间变量或重新组织表达式逻辑";
      }
    in
    add_suggestions_to_ref [ complexity_warning ] suggestions
