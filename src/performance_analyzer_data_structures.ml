(** 数据结构性能分析器模块
    
    专门分析数据结构使用效率，从refactoring_analyzer_performance.ml中提取
    创建目的：减少主文件复杂度，专注于数据结构相关的性能优化
    创建时间：技术债务清理 Fix #654 *)

open Ast
open Refactoring_analyzer_types

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