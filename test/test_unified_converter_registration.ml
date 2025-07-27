(** 统一转换器注册功能测试 - Issue #1490
 *
 * 此测试模块专门验证重构后的转换器注册功能，确保：
 * 1. 配置驱动的注册方式正常工作
 * 2. 错误处理机制有效
 * 3. 所有默认转换器正确注册
 * 4. 注册统计功能准确
 *
 * @author Echo, 测试工程师
 * @version 1.0
 * @since 2025-07-27
 * @related-issue #1490, #1491 *)

open Alcotest

module UC = Token_system_unified_core.Unified_converter
(** 测试模块路径别名 *)

(** 测试转换器注册和初始化 *)
let test_converter_initialization () =
  (* 清空注册表，确保测试独立性 *)
  UC.ConverterRegistry.clear ();
  let initial_stats = UC.ConverterRegistry.get_stats () in
  check (pair int int) "初始注册表应为空" (0, 0) initial_stats;

  (* 执行初始化，它会注册默认转换器 *)
  UC.initialize ();

  (* 验证注册后的统计信息 *)
  let final_stats = UC.ConverterRegistry.get_stats () in
  check bool "注册后转换器数量增加" (fst final_stats > 0) true;
  check bool "注册后启用转换器数量增加" (snd final_stats > 0) true

(** 测试转换器配置表的正确性 *)
let test_converter_config_completeness () =
  (* 清空并重新初始化 *)
  UC.ConverterRegistry.clear ();
  UC.initialize ();

  (* 验证所有预期的转换器类型都被注册 *)
  let expected_types =
    [
      UC.LiteralConverter;
      UC.KeywordConverter;
      UC.OperatorConverter;
      UC.IdentifierConverter;
      UC.DelimiterConverter;
    ]
  in

  List.iter
    (fun converter_type ->
      let converters = UC.ConverterRegistry.get_converters converter_type in
      let type_name =
        match converter_type with
        | UC.LiteralConverter -> "LiteralConverter"
        | UC.KeywordConverter -> "KeywordConverter"
        | UC.OperatorConverter -> "OperatorConverter"
        | UC.IdentifierConverter -> "IdentifierConverter"
        | UC.DelimiterConverter -> "DelimiterConverter"
        | _ -> "OtherConverter"
      in
      check bool (Printf.sprintf "%s类型应有转换器注册" type_name) (List.length converters > 0) true)
    expected_types

(** 测试字面量转换器注册详情 *)
let test_literal_converters_registration () =
  UC.ConverterRegistry.clear ();
  UC.initialize ();

  (* 获取字面量转换器 *)
  let literal_converters = UC.ConverterRegistry.get_converters UC.LiteralConverter in

  (* 验证字面量转换器数量（应该有4个：int, float, string, bool） *)
  check int "字面量转换器数量" 4 (List.length literal_converters);

  (* 验证所有字面量转换器都启用 *)
  let all_enabled = List.for_all (fun entry -> entry.UC.enabled) literal_converters in
  check bool "所有字面量转换器都启用" true all_enabled;

  (* 验证优先级设置正确 *)
  let priorities = List.map (fun entry -> entry.UC.priority) literal_converters in
  let sorted_priorities = List.sort compare priorities in
  check (list int) "字面量转换器优先级" [ 1; 2; 3; 4 ] sorted_priorities

(** 测试转换器名称的唯一性 *)
let test_converter_name_uniqueness () =
  UC.ConverterRegistry.clear ();
  UC.initialize ();

  (* 获取所有转换器 *)
  let all_converters_by_type = UC.ConverterRegistry.get_all_converters () in
  let all_converters = List.concat_map snd all_converters_by_type in

  (* 提取所有名称 *)
  let names = List.map (fun entry -> entry.UC.name) all_converters in
  let unique_names = List.sort_uniq String.compare names in

  (* 验证名称唯一性 *)
  check int "转换器名称应唯一" (List.length names) (List.length unique_names)

(** 测试注册统计功能 *)
let test_registration_statistics () =
  UC.ConverterRegistry.clear ();
  let before_stats = UC.ConverterRegistry.get_stats () in

  UC.initialize ();
  let after_stats = UC.ConverterRegistry.get_stats () in

  (* 验证统计数据变化 *)
  check bool "注册前后统计数据变化" (fst after_stats > fst before_stats) true;

  (* 验证统计信息字符串格式 *)
  let stats_string = UC.get_conversion_stats () in
  check bool "统计信息非空" (String.length stats_string > 0) true;
  check bool "统计信息包含有意义内容" (String.length stats_string > 10) true

(** 测试转换器功能保持不变 *)
let test_converter_functionality_preserved () =
  UC.ConverterRegistry.clear ();
  UC.initialize ();

  (* 测试基本转换功能 *)
  let test_pos = UC.{ line = 1; column = 1; filename = "test" } in

  (* 测试整数字面量转换 *)
  let int_result = UC.convert "42" test_pos in
  check bool "整数转换功能保持" (match int_result with UC.Success _ -> true | UC.Failure _ -> false) true;

  (* 测试字符串字面量转换 *)
  let string_result = UC.convert "\"hello\"" test_pos in
  check bool "字符串转换功能保持"
    (match string_result with UC.Success _ -> true | UC.Failure _ -> false)
    true

(** 测试批量转换功能 *)
let test_batch_conversion_functionality () =
  UC.ConverterRegistry.clear ();
  UC.initialize ();

  let test_pos = UC.{ line = 1; column = 1; filename = "test" } in
  let test_inputs = [ ("42", test_pos); ("3.14", test_pos); ("\"hello\"", test_pos) ] in

  let results = UC.batch_convert test_inputs in
  check int "批量转换结果数量" 3 (List.length results);

  (* 验证所有转换都有结果 *)
  let all_processed =
    List.for_all
      (fun (_, result) -> match result with UC.Success _ | UC.Failure _ -> true)
      results
  in
  check bool "批量转换全部处理" true all_processed

(** 测试模块初始化的幂等性 *)
let test_initialization_idempotency () =
  (* 多次初始化应该是安全的 *)
  UC.initialize ();
  let stats1 = UC.get_conversion_stats () in

  UC.initialize ();
  let stats2 = UC.get_conversion_stats () in

  (* 多次初始化后统计应该一致 *)
  check string "多次初始化幂等性" stats1 stats2

(** 测试套件定义 *)
let registration_core_tests =
  [
    test_case "转换器初始化" `Quick test_converter_initialization;
    test_case "转换器配置完整性" `Quick test_converter_config_completeness;
    test_case "字面量转换器注册" `Quick test_literal_converters_registration;
    test_case "转换器名称唯一性" `Quick test_converter_name_uniqueness;
  ]

let statistics_tests = [ test_case "注册统计功能" `Quick test_registration_statistics ]

let functionality_preservation_tests =
  [
    test_case "转换功能保持" `Quick test_converter_functionality_preserved;
    test_case "批量转换功能" `Quick test_batch_conversion_functionality;
    test_case "初始化幂等性" `Quick test_initialization_idempotency;
  ]

(** 运行所有测试 *)
let () =
  run "Unified Converter Registration Tests - Issue #1490"
    [
      ("注册核心功能", registration_core_tests);
      ("统计功能验证", statistics_tests);
      ("功能保持验证", functionality_preservation_tests);
    ]
