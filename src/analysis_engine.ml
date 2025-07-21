(** 分析引擎模块 - 核心分析逻辑，协调各种分析器进行代码质量分析 *)

open Ast
open Refactoring_analyzer_types
open Analysis_helpers

(** 分析表达式的主入口函数 *)
let analyze_expression expr context =
  let suggestions = ref [] in

  let rec analyze expr ctx =
    let new_ctx = { ctx with expression_count = ctx.expression_count + 1 } in
    match expr with
    | VarExpr name -> analyze_variable_expression name suggestions
    | LetExpr (name, val_expr, in_expr) ->
        analyze_let_expression name val_expr in_expr new_ctx analyze suggestions
    | FunExpr (params, body) -> analyze_function_expression params body new_ctx analyze suggestions
    | CondExpr (cond, then_expr, else_expr) ->
        analyze_conditional_expression cond then_expr else_expr new_ctx analyze suggestions
    | FunCallExpr (func, args) -> analyze_function_call_expression func args new_ctx analyze
    | MatchExpr (matched_expr, branches) ->
        analyze_match_expression matched_expr branches new_ctx analyze
    | BinaryOpExpr (left, _, right) ->
        analyze_binary_operation_expression left right new_ctx analyze
    | UnaryOpExpr (_, expr) -> analyze_unary_operation_expression expr new_ctx analyze
    | _ -> ()
  in

  analyze expr context;

  (* 添加性能分析建议 *)
  let performance_suggestions =
    Refactoring_analyzer_performance.analyze_performance_hints expr context
  in
  add_suggestions_to_ref performance_suggestions suggestions;

  !suggestions

(** 分析语句 *)
let analyze_statement stmt context =
  match stmt with
  | ExprStmt expr -> analyze_expression expr context
  | LetStmt (name, expr) ->
      let naming_suggestions = Refactoring_analyzer_naming.analyze_naming_quality name in
      let expr_suggestions = analyze_expression expr context in
      List.rev_append naming_suggestions expr_suggestions
  | RecLetStmt (name, expr) ->
      let naming_suggestions = Refactoring_analyzer_naming.analyze_naming_quality name in
      let new_context = { context with current_function = Some name } in
      let complexity_suggestion =
        match Refactoring_analyzer_complexity.analyze_function_complexity name expr new_context with
        | Some s -> [ s ]
        | None -> []
      in
      let expr_suggestions = analyze_expression expr new_context in
      naming_suggestions @ complexity_suggestion @ expr_suggestions
  | _ -> []

(** 分析整个程序 *)
let analyze_program program =
  let all_suggestions = ref [] in
  let context = ref empty_context in

  (* 收集所有表达式用于重复代码检测 *)
  let all_expressions = ref [] in

  let collect_expressions = function
    | ExprStmt expr -> all_expressions := expr :: !all_expressions
    | LetStmt (_, expr) -> all_expressions := expr :: !all_expressions
    | RecLetStmt (_, expr) -> all_expressions := expr :: !all_expressions
    | _ -> ()
  in

  (* 分析每个语句 *)
  List.iter
    (fun stmt ->
      collect_expressions stmt;
      let stmt_suggestions = analyze_statement stmt !context in
      add_suggestions_to_ref stmt_suggestions all_suggestions)
    program;

  (* 进行重复代码检测 *)
  let duplication_suggestions =
    Refactoring_analyzer_duplication.detect_code_duplication !all_expressions
  in
  add_suggestions_to_ref duplication_suggestions all_suggestions;

  (* 按置信度排序建议 *)
  List.sort (fun a b -> compare b.confidence a.confidence) !all_suggestions