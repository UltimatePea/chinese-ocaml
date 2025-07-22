(** 分析辅助函数模块 - 提供表达式和语句分析的基础工具函数 *)

open Ast
open Refactoring_analyzer_types

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
  let updated_ctx =
    {
      new_ctx with
      defined_vars = List.rev_append (List.map (fun p -> (p, None)) params) new_ctx.defined_vars;
      nesting_level = (create_nested_context new_ctx).nesting_level;
    }
  in
  analyze body updated_ctx

(** 分析条件表达式 *)
let analyze_conditional_expression cond then_expr else_expr new_ctx analyze suggestions =
  let updated_ctx = create_nested_context new_ctx in
  analyze cond updated_ctx;
  analyze then_expr updated_ctx;
  analyze else_expr updated_ctx;
  Refactoring_analyzer_complexity.check_nesting_depth updated_ctx.nesting_level suggestions

(** 分析函数调用表达式 *)
let analyze_function_call_expression func args new_ctx analyze =
  analyze func new_ctx;
  List.iter (fun arg -> analyze arg new_ctx) args

(** 分析模式匹配表达式 *)
let analyze_match_expression matched_expr branches new_ctx analyze =
  analyze matched_expr new_ctx;
  let updated_ctx = create_nested_context new_ctx in
  List.iter (fun branch -> analyze branch.expr updated_ctx) branches

(** 分析二元运算表达式 *)
let analyze_binary_operation_expression left right new_ctx analyze =
  analyze left new_ctx;
  analyze right new_ctx

(** 分析一元运算表达式 *)
let analyze_unary_operation_expression expr new_ctx analyze = analyze expr new_ctx
