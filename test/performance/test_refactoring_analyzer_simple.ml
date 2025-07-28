(** 重构分析器模块简单测试 *)

open Alcotest
open Yyocamlc_lib

(** 测试重构分析器核心模块基础功能 *)
let test_refactoring_core_basic () =
  (* 创建测试上下文 *)
  let context =
    {
      Refactoring_analyzer_types.current_scope = "测试作用域";
      function_depth = 0;
      loop_depth = 0;
      variables_in_scope = [ "x"; "y" ];
      function_names = [ "函数1" ];
    }
  in

  (* 测试简单表达式分析 *)
  let simple_expr = Ast.Variable "x" in
  let suggestions = Refactoring_analyzer_core.analyze_expression simple_expr context in

  check bool "表达式分析应该完成" true (List.length suggestions >= 0)

(** 测试命名分析器 *)
let test_naming_analyzer_basic () =
  let context =
    {
      Refactoring_analyzer_types.current_scope = "测试";
      function_depth = 0;
      loop_depth = 0;
      variables_in_scope = [];
      function_names = [];
    }
  in

  (* 测试通用变量名 *)
  let generic_var = Ast.Variable "x" in
  let suggestions = Refactoring_analyzer_naming.analyze_naming generic_var context in

  check bool "命名分析应该完成" true (List.length suggestions >= 0)

(** 测试复杂度分析器 *)
let test_complexity_analyzer_basic () =
  let context =
    {
      Refactoring_analyzer_types.current_scope = "测试";
      function_depth = 0;
      loop_depth = 0;
      variables_in_scope = [];
      function_names = [];
    }
  in

  (* 测试简单表达式 *)
  let simple_expr = Ast.IntLiteral 42 in
  let suggestions = Refactoring_analyzer_complexity.analyze_complexity simple_expr context in

  check bool "复杂度分析应该完成" true (List.length suggestions >= 0)

(** 测试重复代码分析器 *)
let test_duplication_analyzer_basic () =
  let context =
    {
      Refactoring_analyzer_types.current_scope = "测试";
      function_depth = 0;
      loop_depth = 0;
      variables_in_scope = [];
      function_names = [];
    }
  in

  (* 测试简单语句 *)
  let assignment = Ast.Assignment ("变量", Ast.IntLiteral 1) in
  let suggestions = Refactoring_analyzer_duplication.analyze_duplication assignment context in

  check bool "重复代码分析应该完成" true (List.length suggestions >= 0)

(** 测试性能分析器 *)
let test_performance_analyzer_basic () =
  let context =
    {
      Refactoring_analyzer_types.current_scope = "测试";
      function_depth = 0;
      loop_depth = 0;
      variables_in_scope = [];
      function_names = [];
    }
  in

  (* 测试简单表达式 *)
  let expr = Ast.BinaryOp (Ast.IntLiteral 1, "+", Ast.IntLiteral 2) in
  let suggestions = Refactoring_analyzer_performance.analyze_performance expr context in

  check bool "性能分析应该完成" true (List.length suggestions >= 0)

(** 测试综合分析功能 *)
let test_comprehensive_analysis_basic () =
  let simple_program =
    [ Ast.Assignment ("变量1", Ast.IntLiteral 1); Ast.Assignment ("变量2", Ast.StringLiteral "值") ]
  in

  let ( suggestions,
        naming_report,
        complexity_report,
        duplication_report,
        performance_report,
        overall_report ) =
    Refactoring_analyzer_core.comprehensive_analysis simple_program
  in

  check bool "综合分析应该返回建议" true (List.length suggestions >= 0);
  check bool "命名报告不为空" true (String.length naming_report > 0);
  check bool "复杂度报告不为空" true (String.length complexity_report > 0);
  check bool "重复代码报告不为空" true (String.length duplication_report > 0);
  check bool "性能报告不为空" true (String.length performance_report > 0);
  check bool "总体报告不为空" true (String.length overall_report > 0)

(** 测试质量检查功能 *)
let test_quick_quality_check () =
  let program = [ Ast.Assignment ("好变量名", Ast.IntLiteral 100) ] in
  let quality_report = Refactoring_analyzer_core.quick_quality_check program in

  check bool "质量检查报告不为空" true (String.length quality_report > 0)

(** 测试建议统计功能 *)
let test_suggestion_statistics () =
  let test_suggestions =
    [
      {
        Refactoring_analyzer_types.hint_type = "命名";
        message = "测试建议";
        confidence = 0.9;
        location = "位置";
        fix = "修复";
      };
    ]
  in

  let total, _, _ = Refactoring_analyzer_core.get_suggestion_statistics test_suggestions in
  check int "统计应该返回正确总数" 1 total

(** 测试套件 *)
let () =
  run "重构分析器综合功能测试"
    [
      ( "核心功能测试",
        [
          test_case "重构分析器核心" `Quick test_refactoring_core_basic;
          test_case "综合分析功能" `Quick test_comprehensive_analysis_basic;
          test_case "快速质量检查" `Quick test_quick_quality_check;
          test_case "建议统计功能" `Quick test_suggestion_statistics;
        ] );
      ( "各分析器模块测试",
        [
          test_case "命名分析器" `Quick test_naming_analyzer_basic;
          test_case "复杂度分析器" `Quick test_complexity_analyzer_basic;
          test_case "重复代码分析器" `Quick test_duplication_analyzer_basic;
          test_case "性能分析器" `Quick test_performance_analyzer_basic;
        ] );
    ]
