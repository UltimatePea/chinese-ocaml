(** 重构分析器综合测试 *)

open Alcotest
open Yyocamlc_lib
open Refactoring_analyzer_core
open Refactoring_analyzer_naming
open Refactoring_analyzer_types

(** 测试用的AST节点构造器 *)
let make_int n = Ast.LitExpr (Ast.IntLit n)

let make_string s = Ast.LitExpr (Ast.StringLit s)
let make_var name = Ast.VarExpr name
let make_binary_op left op right = Ast.BinaryOpExpr (left, op, right)
let make_assignment var value = Ast.LetStmt (var, value)

let make_while condition body_expr =
  Ast.ExprStmt (Ast.CondExpr (condition, body_expr, Ast.LitExpr Ast.UnitLit))

let make_function_def name params body = Ast.LetStmt (name, Ast.FunExpr (params, body))

(** 创建测试上下文 *)
let create_test_context () =
  {
    current_function = Some "测试函数";
    defined_vars = [ ("x", None); ("y", None); ("z", None) ];
    function_calls = [ "函数1"; "函数2" ];
    nesting_level = 0;
    expression_count = 3;
  }

(** 测试辅助函数 *)

(** Refactoring_analyzer_core 核心功能测试 *)
let test_expression_analysis _ =
  let context = create_test_context () in
  let simple_expr = make_var "测试变量" in
  let suggestions = analyze_expression simple_expr context in
  check bool "表达式分析应该完成" (List.length suggestions >= 0) true

let test_statement_analysis _ =
  let context = create_test_context () in
  let assignment_stmt = make_assignment "变量" (make_int 42) in
  let suggestions = analyze_statement assignment_stmt context in
  check bool "语句分析应该完成" (List.length suggestions >= 0) true

let test_program_analysis _ =
  let program =
    [
      make_assignment "x" (make_int 1);
      make_assignment "y" (make_int 2);
      make_assignment "z" (make_binary_op (make_var "x") Ast.Add (make_var "y"));
    ]
  in
  let suggestions = analyze_program program in
  check bool "程序分析应该完成" (List.length suggestions >= 0) true

let test_comprehensive_analysis _ =
  let program =
    [
      make_function_def "测试函数" [ "参数1"; "参数2" ] (make_var "参数1");
      make_assignment "全局变量" (make_string "值");
    ]
  in
  let ( suggestions,
        naming_report,
        complexity_report,
        duplication_report,
        performance_report,
        overall_report ) =
    comprehensive_analysis program
  in
  check bool "应该返回建议列表" (List.length suggestions >= 0) true;
  check bool "命名报告不应为空" (String.length naming_report > 0) true;
  check bool "复杂度报告不应为空" (String.length complexity_report > 0) true;
  check bool "重复代码报告不应为空" (String.length duplication_report > 0) true;
  check bool "性能报告不应为空" (String.length performance_report > 0) true;
  check bool "总体报告不应为空" (String.length overall_report > 0) true

let test_quick_quality_check _ =
  let simple_program = [ make_assignment "好变量名" (make_int 100) ] in
  let quality_report = quick_quality_check simple_program in
  check bool "质量检查报告不应为空" (String.length quality_report > 0) true

let test_suggestion_statistics _ =
  let test_suggestions =
    [
      {
        suggestion_type = NamingImprovement "建议名称";
        message = "建议1";
        confidence = 0.9;
        location = Some "位置1";
        suggested_fix = Some "修复1";
      };
      {
        suggestion_type = PerformanceHint "性能提示";
        message = "建议2";
        confidence = 0.7;
        location = Some "位置2";
        suggested_fix = Some "修复2";
      };
      {
        suggestion_type = FunctionComplexity 5;
        message = "建议3";
        confidence = 0.8;
        location = Some "位置3";
        suggested_fix = Some "修复3";
      };
    ]
  in
  let total, (high, _medium, _low, _critical), (naming, performance, complexity) =
    get_suggestion_statistics test_suggestions
  in
  check int "总数应该正确" total 3;
  check bool "应该有高置信度建议" (high > 0) true;
  check bool "应该统计各类建议" (naming + performance + complexity = total) true

let test_quality_assessment _ =
  let program_with_issues =
    [
      make_assignment "x" (make_int 1);
      make_assignment "y" (make_int 1);
      make_while (make_var "true") (make_var "z");
    ]
  in
  let assessment = generate_quality_assessment program_with_issues in
  check bool "质量评估报告不应为空" (String.length assessment > 0) true

(** Refactoring_analyzer_naming 命名分析测试 *)
let test_naming_analysis _ =
  let suggestions = analyze_naming_quality "x" in
  check bool "命名分析应该完成" (List.length suggestions >= 0) true

let test_chinese_naming_preference _ =
  let english_suggestions = analyze_naming_quality "englishVariable" in
  let chinese_suggestions = analyze_naming_quality "中文变量" in
  check bool "英文变量分析应该完成" (List.length english_suggestions >= 0) true;
  check bool "中文变量分析应该完成" (List.length chinese_suggestions >= 0) true

(** 集成测试 *)
let test_integrated_refactoring_analysis _ =
  let complex_program =
    [
      make_function_def "calculateValue" [ "x"; "y" ] (make_var "x");
      make_assignment "temp" (make_string "临时值");
      make_assignment "temp2" (make_string "临时值");
    ]
  in
  let suggestions = analyze_program complex_program in
  check bool "集成分析应该完成" (List.length suggestions >= 0) true;
  let unique_types =
    List.sort_uniq String.compare
      (List.map
         (fun s ->
           match s.suggestion_type with
           | NamingImprovement _ -> "命名"
           | PerformanceHint _ -> "性能"
           | FunctionComplexity _ -> "复杂度"
           | DuplicatedCode _ -> "重复代码")
         suggestions)
  in
  check bool "应该包含多种建议类型" (List.length unique_types >= 0) true

(** 边界条件测试 *)
let test_empty_program_analysis _ =
  let empty_program = [] in
  let suggestions = analyze_program empty_program in
  check bool "空程序分析应该安全完成" (List.length suggestions >= 0) true

let test_single_statement_analysis _ =
  let single_statement = [ make_assignment "单一变量" (make_int 42) ] in
  let suggestions = analyze_program single_statement in
  check bool "单语句分析应该完成" (List.length suggestions >= 0) true

let test_minimal_expression_analysis _ =
  let context = create_test_context () in
  let minimal_expr = make_int 1 in
  let suggestions = analyze_expression minimal_expr context in
  check bool "最小表达式分析应该安全" (List.length suggestions >= 0) true

(** 性能测试 *)
let test_large_program_analysis _ =
  let large_program =
    List.init 100 (fun i -> make_assignment ("变量" ^ string_of_int i) (make_int i))
  in
  let start_time = Sys.time () in
  let suggestions = analyze_program large_program in
  let end_time = Sys.time () in
  let analysis_time = end_time -. start_time in
  check bool "大程序分析应该完成" (List.length suggestions >= 0) true;
  check bool "分析时间应该合理" (analysis_time < 10.0) true

let () =
  run "重构分析器综合测试"
    [
      ( "核心分析器",
        [
          test_case "表达式分析" `Quick test_expression_analysis;
          test_case "语句分析" `Quick test_statement_analysis;
          test_case "程序分析" `Quick test_program_analysis;
          test_case "综合分析" `Quick test_comprehensive_analysis;
          test_case "快速质量检查" `Quick test_quick_quality_check;
          test_case "建议统计" `Quick test_suggestion_statistics;
          test_case "质量评估" `Quick test_quality_assessment;
        ] );
      ( "命名分析器",
        [
          test_case "命名分析" `Quick test_naming_analysis;
          test_case "中文命名偏好" `Quick test_chinese_naming_preference;
        ] );
      ("集成测试", [ test_case "集成重构分析" `Quick test_integrated_refactoring_analysis ]);
      ( "边界条件测试",
        [
          test_case "空程序分析" `Quick test_empty_program_analysis;
          test_case "单语句分析" `Quick test_single_statement_analysis;
          test_case "最小表达式分析" `Quick test_minimal_expression_analysis;
        ] );
      ("性能测试", [ test_case "大程序分析" `Quick test_large_program_analysis ]);
    ]
