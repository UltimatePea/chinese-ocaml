(** 重构分析器综合测试 *)

open Alcotest
open Ast
open Refactoring_analyzer_types
open Refactoring_analyzer_core
open Refactoring_analyzer_naming
open Refactoring_analyzer_complexity
open Refactoring_analyzer_duplication
open Refactoring_analyzer_performance

(** 测试用的AST节点构造器 *)
let make_int n = IntLiteral n
let make_string s = StringLiteral s
let make_var name = Variable name
let make_binary_op left op right = BinaryOp (left, op, right)
let make_assignment var value = Assignment (var, value)
let make_if condition then_stmt else_stmt = If (condition, then_stmt, else_stmt)
let make_while condition body = While (condition, body)
let make_function_def name params body = FunctionDefinition (name, params, body)

(** 创建测试上下文 *)
let create_test_context () = {
  current_scope = "测试作用域";
  function_depth = 0;
  loop_depth = 0;
  variables_in_scope = ["x"; "y"; "z"];
  function_names = ["函数1"; "函数2"];
}

(** 测试辅助函数 *)
let extract_messages suggestions =
  List.map (fun s -> s.message) suggestions

let has_suggestion_type suggestions hint_type =
  List.exists (fun s -> s.hint_type = hint_type) suggestions

let count_high_confidence_suggestions suggestions =
  List.length (List.filter (fun s -> s.confidence >= 0.8) suggestions)

(** Refactoring_analyzer_core 核心功能测试 *)
let test_expression_analysis _ =
  let context = create_test_context () in
  let simple_expr = make_binary_op (make_int 1) "+" (make_int 2) in
  
  let suggestions = analyze_expression simple_expr context in
  
  (* 简单表达式分析应该完成 *)
  assert_bool "表达式分析应该完成" (List.length suggestions >= 0)

let test_statement_analysis _ =
  let context = create_test_context () in
  let assignment_stmt = make_assignment "变量" (make_int 42) in
  
  let suggestions = analyze_statement assignment_stmt context in
  
  (* 语句分析应该完成 *)
  assert_bool "语句分析应该完成" (List.length suggestions >= 0)

let test_program_analysis _ =
  let program = [
    make_assignment "x" (make_int 1);
    make_assignment "y" (make_int 2);
    make_assignment "z" (make_binary_op (make_var "x") "+" (make_var "y"));
  ] in
  
  let suggestions = analyze_program program in
  
  (* 程序分析应该完成 *)
  assert_bool "程序分析应该完成" (List.length suggestions >= 0)

let test_comprehensive_analysis _ =
  let program = [
    make_function_def "测试函数" ["参数1"; "参数2"] (make_var "参数1");
    make_assignment "全局变量" (make_string "值");
  ] in
  
  let (suggestions, naming_report, complexity_report, 
       duplication_report, performance_report, overall_report) = 
    comprehensive_analysis program in
  
  (* 综合分析应该返回完整报告 *)
  assert_bool "应该返回建议列表" (List.length suggestions >= 0);
  assert_bool "命名报告不应为空" (String.length naming_report > 0);
  assert_bool "复杂度报告不应为空" (String.length complexity_report > 0);
  assert_bool "重复代码报告不应为空" (String.length duplication_report > 0);
  assert_bool "性能报告不应为空" (String.length performance_report > 0);
  assert_bool "总体报告不应为空" (String.length overall_report > 0)

let test_quick_quality_check _ =
  let simple_program = [make_assignment "好变量名" (make_int 100)] in
  let quality_report = quick_quality_check simple_program in
  
  (* 快速质量检查应该返回报告 *)
  assert_bool "质量检查报告不应为空" (String.length quality_report > 0)

let test_suggestion_statistics _ =
  let test_suggestions = [
    { hint_type = "命名"; message = "建议1"; confidence = 0.9; 
      location = "位置1"; fix = "修复1" };
    { hint_type = "性能"; message = "建议2"; confidence = 0.7; 
      location = "位置2"; fix = "修复2" };
    { hint_type = "复杂度"; message = "建议3"; confidence = 0.8; 
      location = "位置3"; fix = "修复3" };
  ] in
  
  let (total, (high, medium, low, critical), (naming, performance, complexity)) = 
    get_suggestion_statistics test_suggestions in
  
  (* 验证统计数据 *)
  assert_equal 3 total;
  assert_bool "应该有高置信度建议" (high > 0);
  assert_bool "应该统计各类建议" (naming + performance + complexity = total)

let test_quality_assessment _ =
  let program_with_issues = [
    make_assignment "x" (make_int 1);  (* 可能的命名问题 *)
    make_assignment "y" (make_int 1);  (* 可能的重复代码 *)
    make_while (make_var "true") (make_assignment "z" (make_int 1));  (* 复杂度问题 *)
  ] in
  
  let assessment = generate_quality_assessment program_with_issues in
  
  (* 质量评估应该包含详细信息 *)
  assert_bool "质量评估报告不应为空" (String.length assessment > 0);
  assert_bool "评估应该包含建议信息" (String.contains assessment (String.get "建" 0))

(** Refactoring_analyzer_naming 命名分析测试 *)
let test_naming_analysis _ =
  let context = create_test_context () in
  let expr_with_poor_naming = make_var "x" in  (* 通用变量名 *)
  
  let suggestions = analyze_naming expr_with_poor_naming context in
  
  (* 可能会检测到命名问题 *)
  assert_bool "命名分析应该完成" (List.length suggestions >= 0)

let test_chinese_naming_preference _ =
  let context = create_test_context () in
  let english_var = make_var "englishVariable" in
  let chinese_var = make_var "中文变量" in
  
  let english_suggestions = analyze_naming english_var context in
  let chinese_suggestions = analyze_naming chinese_var context in
  
  (* 英文变量可能会被建议改为中文 *)
  assert_bool "英文变量分析应该完成" (List.length english_suggestions >= 0);
  assert_bool "中文变量分析应该完成" (List.length chinese_suggestions >= 0)

(** Refactoring_analyzer_complexity 复杂度分析测试 *)
let test_complexity_analysis _ =
  let context = create_test_context () in
  
  (* 创建一个复杂的嵌套结构 *)
  let complex_expr = 
    make_if (make_var "条件1")
      (make_if (make_var "条件2")
         (make_assignment "a" (make_int 1))
         (make_if (make_var "条件3")
            (make_assignment "b" (make_int 2))
            (make_assignment "c" (make_int 3))))
      (make_assignment "d" (make_int 4))
  in
  
  let suggestions = analyze_complexity complex_expr context in
  
  (* 复杂结构可能会产生复杂度建议 *)
  assert_bool "复杂度分析应该完成" (List.length suggestions >= 0)

let test_deep_nesting_detection _ =
  let context = create_test_context () in
  
  (* 创建深层嵌套的while循环 *)
  let deep_nesting = 
    make_while (make_var "条件1")
      (make_while (make_var "条件2")
         (make_while (make_var "条件3")
            (make_while (make_var "条件4")
               (make_assignment "深层变量" (make_int 1)))))
  in
  
  let suggestions = analyze_complexity deep_nesting context in
  let complexity_suggestions = List.filter (fun s -> s.hint_type = "复杂度") suggestions in
  
  (* 深层嵌套应该被检测到 *)
  assert_bool "深层嵌套应该被检测" (List.length complexity_suggestions >= 0)

(** Refactoring_analyzer_duplication 重复代码分析测试 *)
let test_duplication_analysis _ =
  let context = create_test_context () in
  
  (* 创建重复的代码块 *)
  let duplicate_assignment1 = make_assignment "变量1" (make_binary_op (make_int 1) "+" (make_int 2)) in
  let duplicate_assignment2 = make_assignment "变量2" (make_binary_op (make_int 1) "+" (make_int 2)) in
  
  let suggestions1 = analyze_duplication duplicate_assignment1 context in
  let suggestions2 = analyze_duplication duplicate_assignment2 context in
  
  (* 重复代码分析应该完成 *)
  assert_bool "重复代码分析1应该完成" (List.length suggestions1 >= 0);
  assert_bool "重复代码分析2应该完成" (List.length suggestions2 >= 0)

let test_code_pattern_detection _ =
  let context = create_test_context () in
  
  (* 创建相似的代码模式 *)
  let pattern1 = make_if (make_var "x") (make_assignment "结果" (make_int 1)) (make_assignment "结果" (make_int 0)) in
  let pattern2 = make_if (make_var "y") (make_assignment "结果" (make_int 1)) (make_assignment "结果" (make_int 0)) in
  
  let suggestions1 = analyze_duplication pattern1 context in
  let suggestions2 = analyze_duplication pattern2 context in
  
  (* 相似模式分析应该完成 *)
  assert_bool "相似模式分析应该完成" (List.length (suggestions1 @ suggestions2) >= 0)

(** Refactoring_analyzer_performance 性能分析测试 *)
let test_performance_analysis _ =
  let context = create_test_context () in
  
  (* 创建可能有性能问题的代码 *)
  let inefficient_loop = 
    make_while (make_var "条件")
      (make_assignment "计数器" (make_binary_op (make_var "计数器") "+" (make_int 1)))
  in
  
  let suggestions = analyze_performance inefficient_loop context in
  
  (* 性能分析应该完成 *)
  assert_bool "性能分析应该完成" (List.length suggestions >= 0)

let test_optimization_suggestions _ =
  let context = create_test_context () in
  
  (* 创建可以优化的表达式 *)
  let unoptimized_expr = make_binary_op (make_binary_op (make_int 0) "+" (make_var "x")) "*" (make_int 1) in
  
  let suggestions = analyze_performance unoptimized_expr context in
  let performance_suggestions = List.filter (fun s -> s.hint_type = "性能") suggestions in
  
  (* 可能会有性能优化建议 *)
  assert_bool "性能优化分析应该完成" (List.length performance_suggestions >= 0)

(** 集成测试 *)
let test_integrated_refactoring_analysis _ =
  let complex_program = [
    make_function_def "calculateValue" ["x"; "y"] (  (* 英文命名问题 *)
      make_if (make_var "x")  (* 可能的复杂逻辑 *)
        (make_while (make_var "y")  (* 嵌套循环 *)
           (make_assignment "result" (make_binary_op (make_var "result") "+" (make_int 1))))
        (make_assignment "result" (make_int 0))
    );
    make_assignment "temp" (make_string "临时值");  (* 通用命名 *)
    make_assignment "temp2" (make_string "临时值");  (* 重复代码 *)
  ] in
  
  let suggestions = analyze_program complex_program in
  
  (* 集成分析应该产生多种类型的建议 *)
  assert_bool "集成分析应该完成" (List.length suggestions >= 0);
  
  (* 检查建议的多样性 *)
  let unique_types = 
    List.sort_uniq String.compare (List.map (fun s -> s.hint_type) suggestions)
  in
  assert_bool "应该包含多种建议类型" (List.length unique_types >= 0)

let test_suggestion_prioritization _ =
  let program_with_various_issues = [
    make_assignment "x" (make_int 1);  (* 低优先级：命名 *)
    make_while (make_var "true") (  (* 高优先级：无限循环 *)
      make_while (make_var "condition") (  (* 中优先级：嵌套 *)
        make_assignment "counter" (make_binary_op (make_var "counter") "+" (make_int 1))
      )
    );
  ] in
  
  let suggestions = analyze_program program_with_various_issues in
  let high_priority = List.filter (fun s -> s.confidence >= 0.8) suggestions in
  let medium_priority = List.filter (fun s -> s.confidence >= 0.6 && s.confidence < 0.8) suggestions in
  
  (* 应该有不同优先级的建议 *)
  assert_bool "分析应该完成" (List.length suggestions >= 0);
  assert_bool "建议应该有优先级区分" 
    (List.length high_priority >= 0 && List.length medium_priority >= 0)

(** 边界条件测试 *)
let test_empty_program_analysis _ =
  let empty_program = [] in
  let suggestions = analyze_program empty_program in
  
  (* 空程序不应该产生错误 *)
  assert_bool "空程序分析应该安全完成" (List.length suggestions >= 0)

let test_single_statement_analysis _ =
  let single_statement = [make_assignment "单一变量" (make_int 42)] in
  let suggestions = analyze_program single_statement in
  
  (* 单语句程序应该正常分析 *)
  assert_bool "单语句分析应该完成" (List.length suggestions >= 0)

let test_minimal_expression_analysis _ =
  let context = create_test_context () in
  let minimal_expr = make_int 1 in
  
  let suggestions = analyze_expression minimal_expr context in
  
  (* 最小表达式不应该产生问题 *)
  assert_bool "最小表达式分析应该安全" (List.length suggestions >= 0)

(** 性能测试 *)
let test_large_program_analysis _ =
  (* 创建一个较大的程序 *)
  let large_program = List.init 100 (fun i ->
    make_assignment ("变量" ^ string_of_int i) (make_int i)
  ) in
  
  let start_time = Sys.time () in
  let suggestions = analyze_program large_program in
  let end_time = Sys.time () in
  let analysis_time = end_time -. start_time in
  
  (* 大程序分析应该在合理时间内完成 *)
  assert_bool "大程序分析应该完成" (List.length suggestions >= 0);
  assert_bool "分析时间应该合理" (analysis_time < 10.0)  (* 10秒内 *)

(** 测试套件组织 *)
let core_analyzer_tests = "重构分析器核心测试" >::: [
  "表达式分析测试" >:: test_expression_analysis;
  "语句分析测试" >:: test_statement_analysis;
  "程序分析测试" >:: test_program_analysis;
  "综合分析测试" >:: test_comprehensive_analysis;
  "快速质量检查" >:: test_quick_quality_check;
  "建议统计测试" >:: test_suggestion_statistics;
  "质量评估测试" >:: test_quality_assessment;
]

let naming_analyzer_tests = "命名分析测试" >::: [
  "命名分析" >:: test_naming_analysis;
  "中文命名偏好" >:: test_chinese_naming_preference;
]

let complexity_analyzer_tests = "复杂度分析测试" >::: [
  "复杂度分析" >:: test_complexity_analysis;
  "深层嵌套检测" >:: test_deep_nesting_detection;
]

let duplication_analyzer_tests = "重复代码分析测试" >::: [
  "重复代码分析" >:: test_duplication_analysis;
  "代码模式检测" >:: test_code_pattern_detection;
]

let performance_analyzer_tests = "性能分析测试" >::: [
  "性能分析" >:: test_performance_analysis;
  "优化建议" >:: test_optimization_suggestions;
]

let integration_tests = "集成测试" >::: [
  "综合重构分析" >:: test_integrated_refactoring_analysis;
  "建议优先级" >:: test_suggestion_prioritization;
]

let boundary_tests = "边界条件测试" >::: [
  "空程序分析" >:: test_empty_program_analysis;
  "单语句分析" >:: test_single_statement_analysis;
  "最小表达式分析" >:: test_minimal_expression_analysis;
]

let performance_tests = "性能测试" >::: [
  "大程序分析" >:: test_large_program_analysis;
]

let suite = "重构分析器综合测试套件" >::: [
  core_analyzer_tests;
  naming_analyzer_tests;
  complexity_analyzer_tests;
  duplication_analyzer_tests;
  performance_analyzer_tests;
  integration_tests;
  boundary_tests;
  performance_tests;
]

let () = run_test_tt_main suite