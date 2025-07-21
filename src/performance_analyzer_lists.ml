(** 列表性能分析器模块

    专门分析列表操作的性能问题和优化机会，从refactoring_analyzer_performance.ml中提取 创建目的：减少主文件复杂度，专注于列表相关的性能优化
    创建时间：技术债务清理 Fix #654 *)

open Ast
open Refactoring_analyzer_types

(** 分析列表操作性能 *)
let analyze_list_performance expr =
  let rec analyze_expr expr =
    match expr with
    | FunCallExpr (VarExpr "连接", [ ListExpr _; ListExpr _ ]) ->
        [
          {
            suggestion_type = PerformanceHint "列表连接优化";
            message = "检测到列表连接操作，对于大量数据建议使用更高效的方法";
            confidence = 0.65;
            location = Some "列表连接操作";
            suggested_fix = Some "考虑使用累加器模式或专用的列表连接函数";
          };
        ]
    | FunCallExpr (VarExpr "追加", args) when List.length args >= 2 ->
        [
          {
            suggestion_type = PerformanceHint "列表追加优化";
            message = "频繁的列表追加操作可能影响性能";
            confidence = 0.60;
            location = Some "列表追加操作";
            suggested_fix = Some "考虑使用可变数据结构或反向构建再反转";
          };
        ]
    | CondExpr (_, then_expr, else_expr) -> analyze_expr then_expr @ analyze_expr else_expr
    | BinaryOpExpr (left, _, right) -> analyze_expr left @ analyze_expr right
    | FunCallExpr (func, args) ->
        let func_suggestions = analyze_expr func in
        let args_suggestions = List.concat_map analyze_expr args in
        func_suggestions @ args_suggestions
    | MatchExpr (matched_expr, branches) ->
        let matched_suggestions = analyze_expr matched_expr in
        let branches_suggestions =
          List.concat_map (fun branch -> analyze_expr branch.expr) branches
        in
        matched_suggestions @ branches_suggestions
    | LetExpr (_, val_expr, in_expr) -> analyze_expr val_expr @ analyze_expr in_expr
    | _ -> []
  in
  analyze_expr expr
