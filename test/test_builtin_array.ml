(** 骆言内置数组模块测试 - Phase 26 内置模块测试覆盖率提升

    本测试模块专门针对 builtin_array.ml 模块进行全面功能测试， 重点测试数组操作的正确性、边界条件和错误处理。

    测试覆盖范围：
    - 数组创建和初始化
    - 数组元素访问和修改
    - 数组转换操作
    - 边界条件处理
    - 错误情况处理

    @author 骆言技术债务清理团队 - Phase 26
    @version 1.0
    @since 2025-07-20 Issue #680 内置模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_array

(** 测试工具函数 *)
module TestUtils = struct
  (** 创建测试用的数组值 *)
  let make_test_array elements = ArrayValue (Array.of_list elements)

  (** 创建测试用的列表值 *)
  let make_test_list elements = ListValue elements

  (** 验证运行时错误 *)
  let expect_runtime_error f =
    try
      ignore (f ());
      false
    with
    | RuntimeError _ -> true
    | _ -> false

  (** 验证两个值相等 *)
  let values_equal v1 v2 =
    match (v1, v2) with
    | IntValue a, IntValue b -> a = b
    | StringValue a, StringValue b -> a = b
    | BoolValue a, BoolValue b -> a = b
    | UnitValue, UnitValue -> true
    | ArrayValue a, ArrayValue b ->
        Array.length a = Array.length b
        &&
        let rec compare_arrays i =
          if i >= Array.length a then true else a.(i) = b.(i) && compare_arrays (i + 1)
        in
        compare_arrays 0
    | ListValue a, ListValue b -> List.length a = List.length b && List.for_all2 ( = ) a b
    | _ -> false
end

(** 数组创建和初始化测试 *)
module ArrayCreationTests = struct
  (** 测试创建数组功能 *)
  let test_create_array () =
    (* 测试创建整数数组 *)
    let result1 = create_array_function [ IntValue 3; IntValue 42 ] in
    (match result1 with
    | ArrayValue arr ->
        check int "数组长度应为3" 3 (Array.length arr);
        check bool "所有元素应为42" true (Array.for_all (fun x -> x = IntValue 42) arr)
    | _ -> fail "应返回数组值");

    (* 测试创建字符串数组 *)
    let result2 = create_array_function [ IntValue 2; StringValue "测试" ] in
    (match result2 with
    | ArrayValue arr ->
        check int "数组长度应为2" 2 (Array.length arr);
        check bool "所有元素应为'测试'" true (Array.for_all (fun x -> x = StringValue "测试") arr)
    | _ -> fail "应返回数组值");

    (* 测试创建空数组 *)
    let result3 = create_array_function [ IntValue 0; IntValue 1 ] in
    match result3 with
    | ArrayValue arr -> check int "空数组长度应为0" 0 (Array.length arr)
    | _ -> fail "应返回数组值"

  (** 测试创建数组的边界条件 *)
  let test_create_array_boundary_cases () =
    (* 测试大数组创建 *)
    let result1 = create_array_function [ IntValue 1000; StringValue "大数组" ] in
    (match result1 with
    | ArrayValue arr -> check int "大数组长度应为1000" 1000 (Array.length arr)
    | _ -> fail "应返回数组值");

    (* 测试单元素数组 *)
    let result2 = create_array_function [ IntValue 1; BoolValue true ] in
    match result2 with
    | ArrayValue arr ->
        check int "单元素数组长度应为1" 1 (Array.length arr);
        check bool "元素应为true" true (arr.(0) = BoolValue true)
    | _ -> fail "应返回数组值"

  (** 测试创建数组的错误处理 *)
  let test_create_array_error_handling () =
    (* 测试负数长度 *)
    let error_case1 () = create_array_function [ IntValue (-1); IntValue 1 ] in
    check bool "负数长度应抛出错误" true (TestUtils.expect_runtime_error error_case1);

    (* 测试参数数量错误 *)
    let error_case2 () = create_array_function [ IntValue 5 ] in
    check bool "参数不足应抛出错误" true (TestUtils.expect_runtime_error error_case2);

    (* 测试参数类型错误 *)
    let error_case3 () = create_array_function [ StringValue "错误"; IntValue 1 ] in
    check bool "参数类型错误应抛出错误" true (TestUtils.expect_runtime_error error_case3)
end

(** 数组访问和修改测试 *)
module ArrayAccessTests = struct
  (** 测试数组长度功能 *)
  let test_array_length () =
    let test_array = TestUtils.make_test_array [ IntValue 1; IntValue 2; IntValue 3 ] in
    let result = array_length_function [ test_array ] in
    check bool "数组长度应为3" true (TestUtils.values_equal result (IntValue 3));

    (* 测试空数组长度 *)
    let empty_array = TestUtils.make_test_array [] in
    let result2 = array_length_function [ empty_array ] in
    check bool "空数组长度应为0" true (TestUtils.values_equal result2 (IntValue 0))

  (** 测试数组元素获取 *)
  let test_array_get () =
    let test_array =
      TestUtils.make_test_array [ StringValue "第一"; StringValue "第二"; StringValue "第三" ]
    in

    (* 测试正常索引 *)
    let result1 = array_get_function [ test_array; IntValue 0 ] in
    check bool "索引0应为'第一'" true (TestUtils.values_equal result1 (StringValue "第一"));

    let result2 = array_get_function [ test_array; IntValue 2 ] in
    check bool "索引2应为'第三'" true (TestUtils.values_equal result2 (StringValue "第三"));

    (* 测试中间索引 *)
    let result3 = array_get_function [ test_array; IntValue 1 ] in
    check bool "索引1应为'第二'" true (TestUtils.values_equal result3 (StringValue "第二"))

  (** 测试数组元素获取的边界条件 *)
  let test_array_get_boundary_cases () =
    let test_array = TestUtils.make_test_array [ IntValue 100; IntValue 200 ] in

    (* 测试越界访问 - 负索引 *)
    let error_case1 () = array_get_function [ test_array; IntValue (-1) ] in
    check bool "负索引应抛出错误" true (TestUtils.expect_runtime_error error_case1);

    (* 测试越界访问 - 超出范围 *)
    let error_case2 () = array_get_function [ test_array; IntValue 2 ] in
    check bool "超出范围索引应抛出错误" true (TestUtils.expect_runtime_error error_case2);

    (* 测试空数组访问 *)
    let empty_array = TestUtils.make_test_array [] in
    let error_case3 () = array_get_function [ empty_array; IntValue 0 ] in
    check bool "空数组访问应抛出错误" true (TestUtils.expect_runtime_error error_case3)

  (** 测试数组元素设置 *)
  let test_array_set () =
    let test_array = TestUtils.make_test_array [ IntValue 1; IntValue 2; IntValue 3 ] in

    (* 测试设置元素 *)
    let result1 = array_set_function [ test_array; IntValue 1; StringValue "修改值" ] in
    check bool "设置应返回unit" true (TestUtils.values_equal result1 UnitValue);

    (* 验证元素确实被修改 *)
    let get_result = array_get_function [ test_array; IntValue 1 ] in
    check bool "元素应被修改为'修改值'" true (TestUtils.values_equal get_result (StringValue "修改值"));

    (* 验证其他元素未被影响 *)
    let get_result2 = array_get_function [ test_array; IntValue 0 ] in
    check bool "其他元素不应被影响" true (TestUtils.values_equal get_result2 (IntValue 1))

  (** 测试数组元素设置的错误处理 *)
  let test_array_set_error_handling () =
    let test_array = TestUtils.make_test_array [ IntValue 1; IntValue 2 ] in

    (* 测试越界设置 *)
    let error_case1 () = array_set_function [ test_array; IntValue 5; IntValue 100 ] in
    check bool "越界设置应抛出错误" true (TestUtils.expect_runtime_error error_case1);

    (* 测试参数数量错误 *)
    let error_case2 () = array_set_function [ test_array; IntValue 0 ] in
    check bool "参数不足应抛出错误" true (TestUtils.expect_runtime_error error_case2)
end

(** 数组转换操作测试 *)
module ArrayConversionTests = struct
  (** 测试数组复制功能 *)
  let test_copy_array () =
    let original_array = TestUtils.make_test_array [ IntValue 1; IntValue 2; IntValue 3 ] in
    let result = copy_array_function [ original_array ] in

    (* 验证返回数组值 *)
    match (original_array, result) with
    | ArrayValue orig, ArrayValue copy ->
        check bool "复制数组内容应相同" true (TestUtils.values_equal (ArrayValue orig) (ArrayValue copy));
        (* 验证是独立副本 - 修改原数组不影响副本 *)
        orig.(0) <- StringValue "修改";
        check bool "副本应独立于原数组" true (copy.(0) = IntValue 1)
    | _ -> fail "应返回数组值"

  (** 测试数组转列表功能 *)
  let test_array_to_list () =
    let test_array =
      TestUtils.make_test_array [ StringValue "一"; StringValue "二"; StringValue "三" ]
    in
    let result = array_to_list_function [ test_array ] in

    let expected_list =
      TestUtils.make_test_list [ StringValue "一"; StringValue "二"; StringValue "三" ]
    in
    check bool "数组转列表结果应正确" true (TestUtils.values_equal result expected_list);

    (* 测试空数组转列表 *)
    let empty_array = TestUtils.make_test_array [] in
    let result2 = array_to_list_function [ empty_array ] in
    let expected_empty_list = TestUtils.make_test_list [] in
    check bool "空数组转列表应为空列表" true (TestUtils.values_equal result2 expected_empty_list)

  (** 测试列表转数组功能 *)
  let test_list_to_array () =
    let test_list = TestUtils.make_test_list [ IntValue 10; IntValue 20; IntValue 30 ] in
    let result = list_to_array_function [ test_list ] in

    (match result with
    | ArrayValue arr ->
        check int "转换后数组长度应为3" 3 (Array.length arr);
        check bool "数组元素应正确" true
          (arr.(0) = IntValue 10 && arr.(1) = IntValue 20 && arr.(2) = IntValue 30)
    | _ -> fail "应返回数组值");

    (* 测试空列表转数组 *)
    let empty_list = TestUtils.make_test_list [] in
    let result2 = list_to_array_function [ empty_list ] in
    match result2 with
    | ArrayValue arr -> check int "空列表转数组长度应为0" 0 (Array.length arr)
    | _ -> fail "应返回数组值"

  (** 测试转换操作的往返一致性 *)
  let test_conversion_round_trip () =
    (* 数组 -> 列表 -> 数组 *)
    let original_array =
      TestUtils.make_test_array [ BoolValue true; BoolValue false; BoolValue true ]
    in
    let list_result = array_to_list_function [ original_array ] in
    let array_result = list_to_array_function [ list_result ] in

    match (original_array, array_result) with
    | ArrayValue orig, ArrayValue final ->
        check bool "往返转换应保持一致" true (TestUtils.values_equal (ArrayValue orig) (ArrayValue final))
    | _ -> fail "转换结果类型错误"
end

(** 复杂场景和集成测试 *)
module ArrayIntegrationTests = struct
  (** 测试混合类型数组 *)
  let test_mixed_type_array () =
    let mixed_elements = [ IntValue 42; StringValue "混合"; BoolValue true; FloatValue 3.14 ] in
    let mixed_array = TestUtils.make_test_array mixed_elements in

    (* 测试访问不同类型元素 *)
    let int_elem = array_get_function [ mixed_array; IntValue 0 ] in
    check bool "整数元素应正确" true (TestUtils.values_equal int_elem (IntValue 42));

    let str_elem = array_get_function [ mixed_array; IntValue 1 ] in
    check bool "字符串元素应正确" true (TestUtils.values_equal str_elem (StringValue "混合"));

    let bool_elem = array_get_function [ mixed_array; IntValue 2 ] in
    check bool "布尔元素应正确" true (TestUtils.values_equal bool_elem (BoolValue true))

  (** 测试嵌套数组结构 *)
  let test_nested_arrays () =
    let inner_array1 = TestUtils.make_test_array [ IntValue 1; IntValue 2 ] in
    let inner_array2 = TestUtils.make_test_array [ IntValue 3; IntValue 4 ] in
    let outer_array = TestUtils.make_test_array [ inner_array1; inner_array2 ] in

    (* 测试访问嵌套结构 *)
    let first_inner = array_get_function [ outer_array; IntValue 0 ] in
    check bool "应能访问嵌套数组" true (match first_inner with ArrayValue _ -> true | _ -> false);

    (* 测试深度访问 *)
    let deep_elem = array_get_function [ first_inner; IntValue 1 ] in
    check bool "深度访问应正确" true (TestUtils.values_equal deep_elem (IntValue 2))

  (** 测试数组函数表完整性 *)
  let test_array_functions_table () =
    let expected_functions = [ "创建数组"; "数组长度"; "复制数组"; "数组获取"; "数组设置"; "数组转列表"; "列表转数组" ] in

    let actual_functions = List.map fst array_functions in
    List.iter
      (fun expected ->
        check bool (Printf.sprintf "函数表应包含'%s'" expected) true (List.mem expected actual_functions))
      expected_functions;

    check int "函数表大小应正确" (List.length expected_functions) (List.length actual_functions)

  (** 测试数组性能边界 *)
  let test_array_performance_boundary () =
    (* 测试较大数组的创建和访问 *)
    let large_array = create_array_function [ IntValue 10000; IntValue 0 ] in
    match large_array with
    | ArrayValue arr ->
        check int "大数组长度应正确" 10000 (Array.length arr);
        (* 测试随机访问 *)
        let mid_elem = array_get_function [ large_array; IntValue 5000 ] in
        check bool "大数组中间元素访问应正确" true (TestUtils.values_equal mid_elem (IntValue 0))
    | _ -> fail "大数组创建失败"
end

(** 中文编程特色测试 *)
module ChineseProgrammingTests = struct
  (** 测试中文字符串数组处理 *)
  let test_chinese_string_arrays () =
    let chinese_elements =
      [ StringValue "春眠不觉晓"; StringValue "处处闻啼鸟"; StringValue "夜来风雨声"; StringValue "花落知多少" ]
    in

    let poem_array = TestUtils.make_test_array chinese_elements in

    (* 测试中文字符串访问 *)
    let first_line = array_get_function [ poem_array; IntValue 0 ] in
    check bool "中文字符串访问应正确" true (TestUtils.values_equal first_line (StringValue "春眠不觉晓"));

    (* 测试中文字符串修改 *)
    let _ = array_set_function [ poem_array; IntValue 1; StringValue "处处闻啼鸟（修改版）" ] in
    let modified_line = array_get_function [ poem_array; IntValue 1 ] in
    check bool "中文字符串修改应正确" true (TestUtils.values_equal modified_line (StringValue "处处闻啼鸟（修改版）"))

  (** 测试Unicode字符和表情符号数组 *)
  let test_unicode_emoji_arrays () =
    let unicode_elements =
      [ StringValue "🌸春天"; StringValue "🌙月亮"; StringValue "🔥火焰"; StringValue "💻代码" ]
    in

    let emoji_array = TestUtils.make_test_array unicode_elements in

    let spring_elem = array_get_function [ emoji_array; IntValue 0 ] in
    check bool "Unicode表情符号处理应正确" true (TestUtils.values_equal spring_elem (StringValue "🌸春天"))

  (** 测试中文数字和计算数组 *)
  let test_chinese_numeric_arrays () =
    let chinese_numbers = [ IntValue 1; IntValue 2; IntValue 3; IntValue 4; IntValue 5 ] in
    let number_array = TestUtils.make_test_array chinese_numbers in

    (* 测试数组长度（使用中文函数名） *)
    let length_result = array_length_function [ number_array ] in
    check bool "中文数字数组长度应为5" true (TestUtils.values_equal length_result (IntValue 5));

    (* 测试数组转列表（保持中文编程风格） *)
    let list_result = array_to_list_function [ number_array ] in
    let expected_list = TestUtils.make_test_list chinese_numbers in
    check bool "中文数字数组转列表应正确" true (TestUtils.values_equal list_result expected_list)
end

(** 测试套件注册 *)
let test_suite =
  [
    ( "数组创建和初始化",
      [
        test_case "创建数组功能" `Quick ArrayCreationTests.test_create_array;
        test_case "创建数组边界条件" `Quick ArrayCreationTests.test_create_array_boundary_cases;
        test_case "创建数组错误处理" `Quick ArrayCreationTests.test_create_array_error_handling;
      ] );
    ( "数组访问和修改",
      [
        test_case "数组长度功能" `Quick ArrayAccessTests.test_array_length;
        test_case "数组元素获取" `Quick ArrayAccessTests.test_array_get;
        test_case "数组获取边界条件" `Quick ArrayAccessTests.test_array_get_boundary_cases;
        test_case "数组元素设置" `Quick ArrayAccessTests.test_array_set;
        test_case "数组设置错误处理" `Quick ArrayAccessTests.test_array_set_error_handling;
      ] );
    ( "数组转换操作",
      [
        test_case "数组复制功能" `Quick ArrayConversionTests.test_copy_array;
        test_case "数组转列表" `Quick ArrayConversionTests.test_array_to_list;
        test_case "列表转数组" `Quick ArrayConversionTests.test_list_to_array;
        test_case "转换往返一致性" `Quick ArrayConversionTests.test_conversion_round_trip;
      ] );
    ( "复杂场景集成",
      [
        test_case "混合类型数组" `Quick ArrayIntegrationTests.test_mixed_type_array;
        test_case "嵌套数组结构" `Quick ArrayIntegrationTests.test_nested_arrays;
        test_case "函数表完整性" `Quick ArrayIntegrationTests.test_array_functions_table;
        test_case "性能边界测试" `Quick ArrayIntegrationTests.test_array_performance_boundary;
      ] );
    ( "中文编程特色",
      [
        test_case "中文字符串数组" `Quick ChineseProgrammingTests.test_chinese_string_arrays;
        test_case "Unicode表情符号" `Quick ChineseProgrammingTests.test_unicode_emoji_arrays;
        test_case "中文数字数组" `Quick ChineseProgrammingTests.test_chinese_numeric_arrays;
      ] );
  ]

(** 运行所有测试 *)
let () =
  Printf.printf "骆言内置数组模块测试 - Phase 26\n";
  Printf.printf "==========================================\n";
  run "Builtin Array Module Tests" test_suite
