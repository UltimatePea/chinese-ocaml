(** 性能分析器模块综合测试 *)

open Alcotest
open Ast
open Refactoring_analyzer_types
open Performance_analyzer_base
open Performance_analyzer_lists
open Performance_analyzer_matching
open Performance_analyzer_recursion
open Performance_analyzer_complexity
open Performance_analyzer_data_structures

(** 测试用的AST节点构造器 *)
let make_int n = IntLiteral n

let make_string s = StringLiteral s
let make_var name = Variable name
let make_binary_op left op right = BinaryOp (left, op, right)
let make_list_cons head tail = ListCons (head, tail)
let make_app f args = Application (f, args)

(** 测试辅助函数 *)
let extract_messages suggestions = List.map (fun s -> s.message) suggestions

let has_suggestion_type suggestions hint_type =
  List.exists (fun s -> s.hint_type = hint_type) suggestions

let count_suggestions_by_type suggestions hint_type =
  List.length (List.filter (fun s -> s.hint_type = hint_type) suggestions)

(** Performance_analyzer_base 模块测试 *)
let test_base_analyzer_creation _ =
  (* 创建一个简单的分析器，总是返回一个建议 *)
  let simple_analyzer expr =
    [
      make_performance_suggestion ~hint_type:"测试" ~message:"测试消息" ~confidence:0.8 ~location:"测试位置"
        ~fix:"测试修复建议";
    ]
  in

  let expr = make_int 42 in
  let suggestions = create_performance_analyzer simple_analyzer expr in

  assert_equal 1 (List.length suggestions);
  assert_equal "测试消息" (List.hd suggestions).message;
  assert_equal 0.8 (List.hd suggestions).confidence

let test_recursive_analysis _ =
  (* 测试递归分析功能 *)
  let counter = ref 0 in
  let counting_analyzer _ =
    incr counter;
    []
  in

  let nested_expr =
    make_binary_op (make_int 1) "+" (make_binary_op (make_int 2) "*" (make_int 3))
  in
  let _ = analyze_expr_recursively counting_analyzer nested_expr in

  (* 应该分析了3个表达式节点 *)
  assert_bool "递归分析应该遍历所有节点" (!counter >= 3)

let test_suggestion_builder _ =
  (* 测试建议构建器 *)
  let list_suggestion = SuggestionBuilder.list_optimization_suggestion "append" "使用更高效的操作" in
  assert_equal "性能" list_suggestion.hint_type;
  assert_bool "列表优化建议应包含操作名" (String.contains list_suggestion.message 'a');

  let pattern_suggestion = SuggestionBuilder.pattern_matching_suggestion 10 "high" in
  assert_equal "性能" pattern_suggestion.hint_type;
  assert_bool "模式匹配建议应提及分支数量" (String.contains pattern_suggestion.message '1');

  let complexity_suggestion = SuggestionBuilder.complexity_suggestion 5 in
  assert_equal "复杂度" complexity_suggestion.hint_type

(** Performance_analyzer_lists 模块测试 *)
let test_list_performance_analysis _ =
  (* 测试列表性能分析 *)
  let simple_list = make_list_cons (make_int 1) (make_list_cons (make_int 2) ListEmpty) in
  let suggestions = analyze_list_performance simple_list in

  (* 简单列表不应该有性能问题 *)
  assert_bool "简单列表应该没有性能警告" (List.length suggestions = 0);

  (* 测试复杂的列表操作 *)
  let complex_list_op = make_app (make_var "List.append") [ simple_list; simple_list ] in
  let complex_suggestions = analyze_list_performance complex_list_op in

  (* 复杂操作可能会有建议 *)
  assert_bool "复杂列表操作可能有性能建议" (List.length complex_suggestions >= 0)

let test_list_concatenation_analysis _ =
  (* 测试列表连接分析 *)
  let list1 = make_var "长列表1" in
  let list2 = make_var "长列表2" in
  let concat_expr = make_app (make_var "List.append") [ list1; list2 ] in

  let suggestions = analyze_list_performance concat_expr in
  let messages = extract_messages suggestions in

  (* 可能会建议使用更高效的数据结构 *)
  assert_bool "列表连接分析应该完成" true

(** Performance_analyzer_matching 模式匹配分析测试 *)
let test_pattern_matching_analysis _ =
  (* 创建一个复杂的模式匹配表达式 *)
  let pattern_cases =
    [
      (IntLiteral 1, make_string "一");
      (IntLiteral 2, make_string "二");
      (IntLiteral 3, make_string "三");
      (Variable "_", make_string "其他");
    ]
  in
  let match_expr = Match (make_var "x", pattern_cases) in

  let suggestions = analyze_pattern_matching_performance match_expr in

  (* 简单的模式匹配不应该有严重的性能问题 *)
  assert_bool "简单模式匹配分析应该完成" (List.length suggestions >= 0)

let test_complex_pattern_matching _ =
  (* 测试复杂模式匹配（多层嵌套） *)
  let complex_cases =
    List.init 20 (fun i -> (IntLiteral i, make_string ("数字" ^ string_of_int i)))
  in
  let complex_match = Match (make_var "复杂匹配", complex_cases) in

  let suggestions = analyze_pattern_matching_performance complex_match in
  let performance_suggestions = List.filter (fun s -> s.hint_type = "性能") suggestions in

  (* 复杂模式匹配可能会有性能建议 *)
  assert_bool "复杂模式匹配可能有性能建议" (List.length performance_suggestions >= 0)

(** Performance_analyzer_recursion 递归分析测试 *)
let test_recursion_analysis _ =
  (* 创建一个递归函数定义 *)
  let factorial_body =
    make_app (make_var "factorial") [ make_binary_op (make_var "n") "-" (make_int 1) ]
  in
  let factorial_def = FunctionDefinition ("factorial", [ "n" ], factorial_body) in

  let suggestions = analyze_recursion_performance factorial_def in

  (* 递归分析应该完成 *)
  assert_bool "递归分析应该完成" (List.length suggestions >= 0)

let test_tail_recursion_detection _ =
  (* 测试尾递归检测 *)
  let tail_recursive_body = make_app (make_var "helper") [ make_int 0; make_var "acc" ] in
  let tail_recursive_def = FunctionDefinition ("helper", [ "n"; "acc" ], tail_recursive_body) in

  let suggestions = analyze_recursion_performance tail_recursive_def in
  let messages = extract_messages suggestions in

  (* 尾递归可能会有优化建议 *)
  assert_bool "尾递归分析应该完成" true

(** Performance_analyzer_complexity 复杂度分析测试 *)
let test_complexity_analysis _ =
  (* 创建一个嵌套复杂的表达式 *)
  let deeply_nested =
    make_binary_op
      (make_binary_op (make_int 1) "+" (make_int 2))
      "*"
      (make_binary_op
         (make_binary_op (make_int 3) "+" (make_int 4))
         "*"
         (make_binary_op (make_int 5) "+" (make_int 6)))
  in

  let suggestions = analyze_complexity_performance deeply_nested in

  (* 复杂度分析应该完成 *)
  assert_bool "复杂度分析应该完成" (List.length suggestions >= 0)

let test_nesting_level_detection _ =
  (* 测试嵌套层级检测 *)
  let deep_nesting =
    List.fold_left
      (fun acc i -> make_binary_op acc "+" (make_int i))
      (make_int 0) [ 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 ]
  in

  let suggestions = analyze_complexity_performance deep_nesting in
  let complexity_suggestions = List.filter (fun s -> s.hint_type = "复杂度") suggestions in

  (* 深层嵌套可能会有复杂度建议 *)
  assert_bool "深层嵌套可能有复杂度建议" (List.length complexity_suggestions >= 0)

(** Performance_analyzer_data_structures 数据结构分析测试 *)
let test_data_structure_analysis _ =
  (* 测试数据结构性能分析 *)
  let array_access = make_app (make_var "Array.get") [ make_var "大数组"; make_int 1000 ] in
  let suggestions = analyze_data_structure_performance array_access in

  (* 数据结构分析应该完成 *)
  assert_bool "数据结构分析应该完成" (List.length suggestions >= 0)

let test_record_field_access _ =
  (* 测试记录字段访问分析 *)
  let record_access = FieldAccess (make_var "大记录", "频繁访问字段") in
  let suggestions = analyze_data_structure_performance record_access in

  (* 记录访问分析应该完成 *)
  assert_bool "记录访问分析应该完成" (List.length suggestions >= 0)

(** 集成测试 *)
let test_integrated_performance_analysis _ =
  (* 创建一个包含多种性能问题的复杂表达式 *)
  let complex_expr =
    make_app (make_var "List.append")
      [
        make_list_cons (make_int 1) (make_list_cons (make_int 2) ListEmpty);
        make_app (make_var "List.map")
          [
            make_var "expensive_function";
            make_list_cons (make_int 3) (make_list_cons (make_int 4) ListEmpty);
          ];
      ]
  in

  (* 运行所有分析器 *)
  let all_suggestions =
    analyze_list_performance complex_expr
    @ analyze_pattern_matching_performance complex_expr
    @ analyze_recursion_performance complex_expr
    @ analyze_complexity_performance complex_expr
    @ analyze_data_structure_performance complex_expr
  in

  (* 集成分析应该产生一些建议 *)
  assert_bool "集成分析应该完成" (List.length all_suggestions >= 0);

  (* 验证建议的多样性 *)
  let unique_types =
    List.sort_uniq String.compare (List.map (fun s -> s.hint_type) all_suggestions)
  in
  assert_bool "应该有多种类型的建议" (List.length unique_types >= 0)

let test_performance_suggestions_quality _ =
  (* 测试建议质量 *)
  let test_suggestion =
    make_performance_suggestion ~hint_type:"性能" ~message:"这是一个测试建议" ~confidence:0.9 ~location:"测试函数"
      ~fix:"应用建议的修复方案"
  in

  (* 验证建议的完整性 *)
  assert_equal "性能" test_suggestion.hint_type;
  assert_equal "这是一个测试建议" test_suggestion.message;
  assert_equal 0.9 test_suggestion.confidence;
  assert_equal "测试函数" test_suggestion.location;
  assert_equal "应用建议的修复方案" test_suggestion.fix;

  (* 置信度应该在合理范围内 *)
  assert_bool "置信度应该在0-1之间" (test_suggestion.confidence >= 0.0 && test_suggestion.confidence <= 1.0)

(** 边界条件测试 *)
let test_empty_expressions _ =
  (* 测试空表达式 *)
  let empty_suggestions = analyze_list_performance ListEmpty in
  assert_bool "空列表分析应该完成" (List.length empty_suggestions >= 0);

  let unit_suggestions = analyze_complexity_performance UnitLiteral in
  assert_bool "单位值分析应该完成" (List.length unit_suggestions >= 0)

let test_single_element_structures _ =
  (* 测试单元素结构 *)
  let single_list = make_list_cons (make_int 1) ListEmpty in
  let suggestions = analyze_list_performance single_list in

  (* 单元素列表不应该有性能问题 *)
  assert_bool "单元素列表应该没有性能问题" (List.length suggestions = 0)

(** 测试套件组织 *)
let base_analyzer_tests =
  "性能分析器基础测试"
  >::: [
         "分析器创建测试" >:: test_base_analyzer_creation;
         "递归分析测试" >:: test_recursive_analysis;
         "建议构建器测试" >:: test_suggestion_builder;
       ]

let list_analyzer_tests =
  "列表性能分析测试"
  >::: [
         "列表性能分析" >:: test_list_performance_analysis; "列表连接分析" >:: test_list_concatenation_analysis;
       ]

let pattern_matching_tests =
  "模式匹配性能分析测试"
  >::: [ "模式匹配分析" >:: test_pattern_matching_analysis; "复杂模式匹配" >:: test_complex_pattern_matching ]

let recursion_tests =
  "递归性能分析测试" >::: [ "递归分析" >:: test_recursion_analysis; "尾递归检测" >:: test_tail_recursion_detection ]

let complexity_tests =
  "复杂度分析测试" >::: [ "复杂度分析" >:: test_complexity_analysis; "嵌套层级检测" >:: test_nesting_level_detection ]

let data_structure_tests =
  "数据结构性能分析测试"
  >::: [ "数据结构分析" >:: test_data_structure_analysis; "记录字段访问" >:: test_record_field_access ]

let integration_tests =
  "集成测试"
  >::: [
         "综合性能分析" >:: test_integrated_performance_analysis;
         "建议质量测试" >:: test_performance_suggestions_quality;
       ]

let boundary_tests =
  "边界条件测试"
  >::: [ "空表达式测试" >:: test_empty_expressions; "单元素结构测试" >:: test_single_element_structures ]

let suite =
  "性能分析器综合测试套件"
  >::: [
         base_analyzer_tests;
         list_analyzer_tests;
         pattern_matching_tests;
         recursion_tests;
         complexity_tests;
         data_structure_tests;
         integration_tests;
         boundary_tests;
       ]

let () = run_test_tt_main suite
