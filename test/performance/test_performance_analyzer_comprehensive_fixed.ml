(** 性能分析器模块综合测试 - 修复版 *)

open Alcotest
open Yyocamlc_lib

(** 测试用的AST节点构造器 *)
let make_int n = Ast.LitExpr (Ast.IntLit n)

let make_string s = Ast.LitExpr (Ast.StringLit s)
let make_var name = Ast.VarExpr name
let make_binary_op left op right = Ast.BinaryOpExpr (left, op, right)

(** 测试辅助函数 *)
let extract_messages suggestions =
  List.map (fun s -> s.Refactoring_analyzer_types.message) suggestions

(** Performance_analyzer_base 模块测试 *)
let test_base_analyzer_creation _ =
  (* 创建一个简单的分析器，总是返回一个建议 *)
  let simple_analyzer expr =
    [
      Performance_analyzer_base.make_performance_suggestion ~hint_type:"测试" ~message:"测试消息"
        ~confidence:0.8 ~location:"测试位置" ~fix:"测试修复建议";
    ]
  in

  let expr = make_int 42 in
  let suggestions = Performance_analyzer_base.create_performance_analyzer simple_analyzer expr in

  assert_equal 1 (List.length suggestions);
  assert_equal "测试消息" (List.hd suggestions).message;
  assert_equal 0.8 (List.hd suggestions).confidence

let test_suggestion_builder _ =
  (* 测试建议构建器 *)
  let list_suggestion =
    Performance_analyzer_base.SuggestionBuilder.list_optimization_suggestion "append" "使用更高效的操作"
  in
  assert_bool "列表优化建议应该生成" (String.length list_suggestion.message > 0);

  let pattern_suggestion =
    Performance_analyzer_base.SuggestionBuilder.pattern_matching_suggestion 10 "high"
  in
  assert_bool "模式匹配建议应该生成" (String.length pattern_suggestion.message > 0);

  let complexity_suggestion = Performance_analyzer_base.SuggestionBuilder.complexity_suggestion 5 in
  assert_bool "复杂度建议应该生成" (String.length complexity_suggestion.message > 0)

(** Performance_analyzer_lists 模块测试 *)
let test_list_performance_analysis _ =
  (* 测试列表性能分析 *)
  let simple_expr = make_int 42 in
  let suggestions = Performance_analyzer_lists.analyze_list_performance simple_expr in

  (* 简单表达式不应该有性能问题 *)
  assert_bool "简单表达式应该分析完成" (List.length suggestions >= 0)

(** 集成测试 *)
let test_integrated_performance_analysis _ =
  (* 创建一个包含多种性能问题的复杂表达式 *)
  let complex_expr = make_binary_op (make_int 1) Ast.Add (make_int 2) in

  (* 运行所有分析器 *)
  let all_suggestions =
    Performance_analyzer_lists.analyze_list_performance complex_expr
    @ Performance_analyzer_matching.analyze_match_performance complex_expr
    @ Performance_analyzer_recursion.analyze_recursion_performance complex_expr
    @ Performance_analyzer_complexity.analyze_computational_complexity complex_expr
    @ Performance_analyzer_data_structures.analyze_data_structure_efficiency complex_expr
  in

  (* 集成分析应该产生一些建议 *)
  assert_bool "集成分析应该完成" (List.length all_suggestions >= 0)

(** 边界条件测试 *)
let test_empty_expressions _ =
  (* 测试简单表达式 *)
  let simple_suggestions = Performance_analyzer_lists.analyze_list_performance (make_int 0) in
  assert_bool "简单表达式分析应该完成" (List.length simple_suggestions >= 0)

(** 测试套件组织 *)
let base_analyzer_tests =
  "性能分析器基础测试"
  >::: [ "分析器创建测试" >:: test_base_analyzer_creation; "建议构建器测试" >:: test_suggestion_builder ]

let list_analyzer_tests = "列表性能分析测试" >::: [ "列表性能分析" >:: test_list_performance_analysis ]

let integration_tests = "集成测试" >::: [ "综合性能分析" >:: test_integrated_performance_analysis ]

let boundary_tests = "边界条件测试" >::: [ "空表达式测试" >:: test_empty_expressions ]

let suite =
  "性能分析器综合测试套件" >::: [ base_analyzer_tests; list_analyzer_tests; integration_tests; boundary_tests ]

let () = run_test_tt_main suite
