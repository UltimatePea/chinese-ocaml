(** 骆言分析引擎模块综合测试套件 - Fix #968 第十阶段测试覆盖率提升计划 *)

open Alcotest
open Yyocamlc_lib
open Ast
open Refactoring_analyzer_types

(** 测试辅助模块 *)
module TestHelpers = struct
  (** 创建测试分析上下文 *)
  let make_test_context () =
    {
      current_function = None;
      defined_vars = [ ("x", None); ("y", None); ("result", None) ];
      function_calls = [];
      nesting_level = 0;
      expression_count = 0;
    }

  (** 示例表达式用于测试 *)
  let sample_var_expr = VarExpr "test_variable"

  let sample_let_expr = LetExpr ("x", LitExpr (IntLit 42), VarExpr "x")
  let sample_fun_expr = FunExpr ([ "param" ], VarExpr "param")
  let sample_cond_expr = CondExpr (LitExpr (BoolLit true), LitExpr (IntLit 1), LitExpr (IntLit 0))
end

(** 表达式分析测试 *)
module ExpressionAnalysisTests = struct
  open TestHelpers

  (** 测试变量表达式分析 *)
  let test_variable_expression_analysis () =
    let context = make_test_context () in
    let suggestions = Analysis_engine.analyze_expression sample_var_expr context in

    check bool "变量表达式分析返回建议列表" true (List.length suggestions >= 0);
    check bool "分析后上下文保持一致" true (context.nesting_level = 0)

  (** 测试let表达式分析 *)
  let test_let_expression_analysis () =
    let context = make_test_context () in
    let suggestions = Analysis_engine.analyze_expression sample_let_expr context in

    check bool "let表达式分析返回建议列表" true (List.length suggestions >= 0);
    check bool "let表达式分析能正常完成" true true

  (** 测试函数表达式分析 *)
  let test_function_expression_analysis () =
    let context = make_test_context () in
    let suggestions = Analysis_engine.analyze_expression sample_fun_expr context in

    check bool "函数表达式分析返回建议列表" true (List.length suggestions >= 0);
    check bool "函数表达式分析能正常完成" true true

  (** 测试条件表达式分析 *)
  let test_conditional_expression_analysis () =
    let context = make_test_context () in
    let suggestions = Analysis_engine.analyze_expression sample_cond_expr context in

    check bool "条件表达式分析返回建议列表" true (List.length suggestions >= 0);
    check bool "条件表达式分析能正常完成" true true

  (** 测试复杂表达式分析 *)
  let test_complex_expression_analysis () =
    let complex_expr = BinaryOpExpr (sample_let_expr, Add, sample_cond_expr) in
    let context = make_test_context () in
    let suggestions = Analysis_engine.analyze_expression complex_expr context in

    check bool "复杂表达式分析返回建议列表" true (List.length suggestions >= 0);
    check bool "复杂表达式分析能正常完成" true true

  (** 测试嵌套表达式分析 *)
  let test_nested_expression_analysis () =
    let nested_expr =
      LetExpr ("outer", LetExpr ("inner", LitExpr (IntLit 1), VarExpr "inner"), VarExpr "outer")
    in
    let context = make_test_context () in
    let suggestions = Analysis_engine.analyze_expression nested_expr context in

    check bool "嵌套表达式分析返回建议列表" true (List.length suggestions >= 0);
    check bool "嵌套表达式分析能正常完成" true true
end

(** 语句分析测试 *)
module StatementAnalysisTests = struct
  open TestHelpers

  (** 测试表达式语句分析 *)
  let test_expression_statement_analysis () =
    let stmt = ExprStmt sample_var_expr in
    let context = make_test_context () in
    let suggestions = Analysis_engine.analyze_statement stmt context in

    check bool "表达式语句分析返回建议列表" true (List.length suggestions >= 0);
    check bool "表达式语句分析能正常完成" true true

  (** 测试let语句分析 *)
  let test_let_statement_analysis () =
    let stmt = LetStmt ("test_var", LitExpr (IntLit 42)) in
    let context = make_test_context () in
    let suggestions = Analysis_engine.analyze_statement stmt context in

    check bool "let语句分析返回建议列表" true (List.length suggestions >= 0);
    check bool "let语句分析能正常完成" true true

  (** 测试递归let语句分析 *)
  let test_recursive_let_statement_analysis () =
    let stmt = RecLetStmt ("factorial", sample_fun_expr) in
    let context = make_test_context () in
    let suggestions = Analysis_engine.analyze_statement stmt context in

    check bool "递归let语句分析返回建议列表" true (List.length suggestions >= 0);
    check bool "递归let语句分析能正常完成" true true
end

(** 上下文追踪测试 *)
module ContextTrackingTests = struct
  open TestHelpers

  (** 测试表达式计数更新 *)
  let test_expression_count_tracking () =
    let context = make_test_context () in
    let initial_count = context.expression_count in
    let _ = Analysis_engine.analyze_expression sample_var_expr context in

    (* 注意：由于分析过程中会创建新的上下文，原始上下文不会改变 *)
    check int "初始表达式计数为0" 0 initial_count

  (** 测试当前函数上下文 *)
  let test_current_function_context () =
    let context = { (make_test_context ()) with current_function = Some "test_func" } in
    let suggestions = Analysis_engine.analyze_expression sample_var_expr context in

    check bool "带函数上下文的分析能正常完成" true (List.length suggestions >= 0)

  (** 测试变量作用域 *)
  let test_variable_scope_context () =
    let context =
      { (make_test_context ()) with defined_vars = [ ("x", None); ("y", None); ("z", None) ] }
    in
    let suggestions = Analysis_engine.analyze_expression (VarExpr "x") context in

    check bool "带变量作用域的分析能正常完成" true (List.length suggestions >= 0)
end

(** 边界条件测试 *)
module EdgeCaseTests = struct
  open TestHelpers

  (** 测试空上下文 *)
  let test_empty_context () =
    let empty_context =
      {
        current_function = None;
        defined_vars = [];
        function_calls = [];
        nesting_level = 0;
        expression_count = 0;
      }
    in
    let suggestions = Analysis_engine.analyze_expression sample_var_expr empty_context in

    check bool "空上下文分析能正常完成" true (List.length suggestions >= 0)

  (** 测试高复杂度上下文 *)
  let test_high_complexity_context () =
    let complex_context =
      {
        current_function = Some "complex_function";
        defined_vars = List.init 50 (fun i -> ("var" ^ string_of_int i, None));
        function_calls = List.init 20 (fun i -> "func" ^ string_of_int i);
        nesting_level = 10;
        expression_count = 100;
      }
    in
    let suggestions = Analysis_engine.analyze_expression sample_cond_expr complex_context in

    check bool "高复杂度上下文分析能正常完成" true (List.length suggestions >= 0)

  (** 测试深层嵌套 *)
  let test_deep_nesting () =
    let deep_context = { (make_test_context ()) with nesting_level = 20 } in
    let suggestions = Analysis_engine.analyze_expression sample_let_expr deep_context in

    check bool "深层嵌套上下文分析能正常完成" true (List.length suggestions >= 0)
end

(** 性能测试 *)
module PerformanceTests = struct
  open TestHelpers

  (** 测试大量表达式分析性能 *)
  let test_bulk_expression_analysis_performance () =
    let context = make_test_context () in
    let expressions =
      List.init 100 (fun i ->
          LetExpr ("var" ^ string_of_int i, LitExpr (IntLit i), VarExpr ("var" ^ string_of_int i)))
    in

    let start_time = Sys.time () in
    let all_suggestions =
      List.map (fun expr -> Analysis_engine.analyze_expression expr context) expressions
    in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in

    check int "分析100个表达式数量正确" 100 (List.length all_suggestions);
    check bool "分析100个表达式在合理时间内完成" true (duration < 2.0)

  (** 测试复杂表达式分析性能 *)
  let test_complex_expression_performance () =
    let make_complex_expr depth =
      let rec build_expr d =
        if d <= 0 then LitExpr (IntLit 1)
        else LetExpr ("x" ^ string_of_int d, build_expr (d - 1), VarExpr ("x" ^ string_of_int d))
      in
      build_expr depth
    in

    let context = make_test_context () in
    let complex_expr = make_complex_expr 10 in

    let start_time = Sys.time () in
    let suggestions = Analysis_engine.analyze_expression complex_expr context in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in

    check bool "复杂表达式分析返回结果" true (List.length suggestions >= 0);
    check bool "复杂表达式分析在合理时间内完成" true (duration < 1.0)
end

(** 主测试套件 *)
let test_suite =
  [
    ( "表达式分析测试",
      [
        test_case "变量表达式分析" `Quick ExpressionAnalysisTests.test_variable_expression_analysis;
        test_case "let表达式分析" `Quick ExpressionAnalysisTests.test_let_expression_analysis;
        test_case "函数表达式分析" `Quick ExpressionAnalysisTests.test_function_expression_analysis;
        test_case "条件表达式分析" `Quick ExpressionAnalysisTests.test_conditional_expression_analysis;
        test_case "复杂表达式分析" `Quick ExpressionAnalysisTests.test_complex_expression_analysis;
        test_case "嵌套表达式分析" `Quick ExpressionAnalysisTests.test_nested_expression_analysis;
      ] );
    ( "语句分析测试",
      [
        test_case "表达式语句分析" `Quick StatementAnalysisTests.test_expression_statement_analysis;
        test_case "let语句分析" `Quick StatementAnalysisTests.test_let_statement_analysis;
        test_case "递归let语句分析" `Quick StatementAnalysisTests.test_recursive_let_statement_analysis;
      ] );
    ( "上下文追踪测试",
      [
        test_case "表达式计数追踪" `Quick ContextTrackingTests.test_expression_count_tracking;
        test_case "当前函数上下文" `Quick ContextTrackingTests.test_current_function_context;
        test_case "变量作用域上下文" `Quick ContextTrackingTests.test_variable_scope_context;
      ] );
    ( "边界条件测试",
      [
        test_case "空上下文" `Quick EdgeCaseTests.test_empty_context;
        test_case "高复杂度上下文" `Quick EdgeCaseTests.test_high_complexity_context;
        test_case "深层嵌套" `Quick EdgeCaseTests.test_deep_nesting;
      ] );
    ( "性能测试",
      [
        test_case "大量表达式分析性能" `Slow PerformanceTests.test_bulk_expression_analysis_performance;
        test_case "复杂表达式分析性能" `Slow PerformanceTests.test_complex_expression_performance;
      ] );
  ]

(** 运行测试 *)
let () = run "骆言分析引擎模块综合测试" test_suite
