(** 分析器模块基础存在性测试 - 简化版 *)

open Alcotest
open Yyocamlc_lib

(** 测试性能分析器模块是否存在并可加载 *)
let test_performance_modules_loaded () =
  (* 测试模块函数引用是否存在 *)
  let test_function_exists f =
    try
      let _ = f in
      true
    with _ -> false
  in

  let performance_base_exists =
    test_function_exists Performance_analyzer_base.make_performance_suggestion
  in
  let performance_lists_exists =
    test_function_exists Performance_analyzer_lists.analyze_list_performance
  in
  let performance_matching_exists =
    test_function_exists Performance_analyzer_matching.analyze_match_performance
  in
  let performance_recursion_exists =
    test_function_exists Performance_analyzer_recursion.analyze_recursion_performance
  in
  let performance_complexity_exists =
    test_function_exists Performance_analyzer_complexity.analyze_computational_complexity
  in
  let performance_data_exists =
    test_function_exists Performance_analyzer_data_structures.analyze_data_structure_efficiency
  in

  check bool "性能分析器基础模块应存在" true performance_base_exists;
  check bool "性能分析器列表模块应存在" true performance_lists_exists;
  check bool "性能分析器匹配模块应存在" true performance_matching_exists;
  check bool "性能分析器递归模块应存在" true performance_recursion_exists;
  check bool "性能分析器复杂度模块应存在" true performance_complexity_exists;
  check bool "性能分析器数据结构模块应存在" true performance_data_exists

(** 测试重构分析器模块是否存在并可加载 *)
let test_refactoring_modules_loaded () =
  (* 测试模块函数引用是否存在 *)
  let test_function_exists f =
    try
      let _ = f in
      true
    with _ -> false
  in

  let refactoring_core_exists = test_function_exists Refactoring_analyzer_core.analyze_program in
  let refactoring_types_context_exists =
    test_function_exists Refactoring_analyzer_types.empty_context
  in

  check bool "重构分析器核心模块应存在" true refactoring_core_exists;
  check bool "重构分析器类型模块应存在" true refactoring_types_context_exists

(** 测试分析器类型创建功能 *)
let test_analyzer_types_creation () =
  (* 测试创建空上下文 *)
  let context = Refactoring_analyzer_types.empty_context in
  check int "初始嵌套层级应为0" 0 context.nesting_level;
  check int "初始表达式计数应为0" 0 context.expression_count

(** 测试套件 *)
let () =
  run "分析器模块基础存在性测试"
    [
      ( "模块加载测试",
        [
          test_case "性能分析器模块" `Quick test_performance_modules_loaded;
          test_case "重构分析器模块" `Quick test_refactoring_modules_loaded;
        ] );
      ("基础功能测试", [ test_case "分析器类型创建" `Quick test_analyzer_types_creation ]);
    ]
