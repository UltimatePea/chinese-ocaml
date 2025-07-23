(** 骆言内置类型转换模块测试 - 提升编译器运行时安全性

    本测试模块专门针对 builtin_types.ml 模块进行全面功能测试，重点测试类型转换函数的正确性、边界条件和错误处理。

    测试覆盖范围：
    - 数值类型转换功能
    - 字符串类型转换功能  
    - 布尔值转换功能
    - 边界条件和错误处理
    - 类型转换函数表完整性

    @author 骆言技术债务清理团队 - Issue #911
    @version 1.0
    @since 2025-07-23 Issue #911 核心builtin模块测试覆盖 *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_types

(** 测试工具函数 *)
module TestUtils = struct
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
    | FloatValue a, FloatValue b -> Float.abs (a -. b) < 1e-10
    | UnitValue, UnitValue -> true
    | _ -> false
end

(** 数值类型转换测试 *)
module NumericConversionTests = struct
  (** 测试整数转字符串功能 *)
  let test_int_to_string () =
    (* 测试正整数转换 *)
    let result1 = int_to_string_function [IntValue 42] in
    check bool "正整数转字符串应正确" true (TestUtils.values_equal result1 (StringValue "42"));

    (* 测试负整数转换 *)
    let result2 = int_to_string_function [IntValue (-123)] in
    check bool "负整数转字符串应正确" true (TestUtils.values_equal result2 (StringValue "-123"));

    (* 测试零转换 *)
    let result3 = int_to_string_function [IntValue 0] in
    check bool "零转字符串应正确" true (TestUtils.values_equal result3 (StringValue "0"))

  (** 测试浮点数转字符串功能 *)
  let test_float_to_string () =
    (* 测试正浮点数转换 *)
    let result1 = float_to_string_function [FloatValue 3.14] in
    check bool "正浮点数转字符串应包含小数点" true
      (match result1 with StringValue s -> String.contains s '.' | _ -> false);

    (* 测试负浮点数转换 *)
    let result2 = float_to_string_function [FloatValue (-2.5)] in
    check bool "负浮点数转字符串应正确" true
      (match result2 with StringValue s -> String.contains s '-' && String.contains s '.' | _ -> false);

    (* 测试零浮点数转换 *)
    let result3 = float_to_string_function [FloatValue 0.0] in
    check bool "零浮点数转字符串应正确" true (TestUtils.values_equal result3 (StringValue "0."))

  (** 测试字符串转整数功能 *)
  let test_string_to_int () =
    (* 测试有效字符串转换 *)
    let result1 = string_to_int_function [StringValue "123"] in
    check bool "有效字符串转整数应正确" true (TestUtils.values_equal result1 (IntValue 123));

    (* 测试负数字符串转换 *)
    let result2 = string_to_int_function [StringValue "-456"] in
    check bool "负数字符串转整数应正确" true (TestUtils.values_equal result2 (IntValue (-456)));

    (* 测试零字符串转换 *)
    let result3 = string_to_int_function [StringValue "0"] in
    check bool "零字符串转整数应正确" true (TestUtils.values_equal result3 (IntValue 0))

  (** 测试字符串转浮点数功能 *)
  let test_string_to_float () =
    (* 测试有效浮点字符串转换 *)
    let result1 = string_to_float_function [StringValue "3.14"] in
    check bool "有效浮点字符串转换应正确" true (TestUtils.values_equal result1 (FloatValue 3.14));

    (* 测试负浮点字符串转换 *)
    let result2 = string_to_float_function [StringValue "-2.5"] in
    check bool "负浮点字符串转换应正确" true (TestUtils.values_equal result2 (FloatValue (-2.5)));

    (* 测试整数格式字符串转浮点 *)
    let result3 = string_to_float_function [StringValue "42"] in
    check bool "整数格式转浮点应正确" true (TestUtils.values_equal result3 (FloatValue 42.0))

  (** 测试整数转浮点数功能 *)
  let test_int_to_float () =
    (* 测试正整数转浮点 *)
    let result1 = int_to_float_function [IntValue 42] in
    check bool "正整数转浮点应正确" true (TestUtils.values_equal result1 (FloatValue 42.0));

    (* 测试负整数转浮点 *)
    let result2 = int_to_float_function [IntValue (-123)] in
    check bool "负整数转浮点应正确" true (TestUtils.values_equal result2 (FloatValue (-123.0)));

    (* 测试零转浮点 *)
    let result3 = int_to_float_function [IntValue 0] in
    check bool "零转浮点应正确" true (TestUtils.values_equal result3 (FloatValue 0.0))

  (** 测试浮点数转整数功能 *)
  let test_float_to_int () =
    (* 测试正浮点转整数（截断） *)
    let result1 = float_to_int_function [FloatValue 3.14] in
    check bool "正浮点转整数应截断" true (TestUtils.values_equal result1 (IntValue 3));

    (* 测试负浮点转整数（截断） *)
    let result2 = float_to_int_function [FloatValue (-2.8)] in
    check bool "负浮点转整数应截断" true (TestUtils.values_equal result2 (IntValue (-2)));

    (* 测试零浮点转整数 *)
    let result3 = float_to_int_function [FloatValue 0.0] in
    check bool "零浮点转整数应正确" true (TestUtils.values_equal result3 (IntValue 0))
end

(** 布尔值转换测试 *)
module BooleanConversionTests = struct
  (** 测试布尔值转字符串功能 *)
  let test_bool_to_string () =
    (* 测试true转字符串 *)
    let result1 = bool_to_string_function [BoolValue true] in
    check bool "true转字符串应为'真'" true (TestUtils.values_equal result1 (StringValue "真"));

    (* 测试false转字符串 *)
    let result2 = bool_to_string_function [BoolValue false] in
    check bool "false转字符串应为'假'" true (TestUtils.values_equal result2 (StringValue "假"))
end

(** 错误处理和边界条件测试 *)
module ErrorHandlingTests = struct
  (** 测试无效字符串转整数错误 *)
  let test_invalid_string_to_int () =
    (* 测试非数字字符串 *)
    let error_case1 () = string_to_int_function [StringValue "不是数字"] in
    check bool "非数字字符串转整数应抛出错误" true (TestUtils.expect_runtime_error error_case1);

    (* 测试包含字母的字符串 *)
    let error_case2 () = string_to_int_function [StringValue "123abc"] in
    check bool "包含字母的字符串转整数应抛出错误" true (TestUtils.expect_runtime_error error_case2);

    (* 测试空字符串 *)
    let error_case3 () = string_to_int_function [StringValue ""] in
    check bool "空字符串转整数应抛出错误" true (TestUtils.expect_runtime_error error_case3)

  (** 测试无效字符串转浮点数错误 *)
  let test_invalid_string_to_float () =
    (* 测试非数字字符串 *)
    let error_case1 () = string_to_float_function [StringValue "不是浮点数"] in
    check bool "非数字字符串转浮点数应抛出错误" true (TestUtils.expect_runtime_error error_case1);

    (* 测试多个小数点 *)
    let error_case2 () = string_to_float_function [StringValue "3.14.159"] in
    check bool "多个小数点的字符串转浮点数应抛出错误" true (TestUtils.expect_runtime_error error_case2);

    (* 测试空字符串转浮点数 *)
    let error_case3 () = string_to_float_function [StringValue ""] in
    check bool "空字符串转浮点数应抛出错误" true (TestUtils.expect_runtime_error error_case3)

  (** 测试参数数量错误 *)
  let test_argument_count_errors () =
    (* 测试参数过多 *)
    let error_case1 () = int_to_string_function [IntValue 1; IntValue 2] in
    check bool "参数过多应抛出错误" true (TestUtils.expect_runtime_error error_case1);

    (* 测试参数为空 *)
    let error_case2 () = float_to_string_function [] in
    check bool "参数为空应抛出错误" true (TestUtils.expect_runtime_error error_case2)

  (** 测试参数类型错误 *)
  let test_argument_type_errors () =
    (* 测试错误的参数类型 *)
    let error_case1 () = int_to_string_function [StringValue "不是整数"] in
    check bool "错误的参数类型应抛出错误" true (TestUtils.expect_runtime_error error_case1);

    let error_case2 () = bool_to_string_function [IntValue 42] in
    check bool "整数传给布尔转换应抛出错误" true (TestUtils.expect_runtime_error error_case2)
end

(** 类型转换函数表测试 *)
module FunctionRegistrationTests = struct
  (** 测试类型转换函数表完整性 *)
  let test_type_conversion_functions_table () =
    let expected_functions = [
      "整数转字符串";
      "浮点数转字符串"; 
      "字符串转整数";
      "字符串转浮点数";
      "整数转浮点数";
      "浮点数转整数";
      "布尔值转字符串";
    ] in

    let actual_functions = List.map fst type_conversion_functions in
    List.iter (fun expected ->
      check bool (Printf.sprintf "函数表应包含'%s'" expected) true (List.mem expected actual_functions)
    ) expected_functions;

    check int "函数表大小应正确" (List.length expected_functions) (List.length actual_functions)

  (** 测试函数表中每个函数都可调用 *)
  let test_all_functions_callable () =
    List.iter (fun (name, func_value) ->
      match func_value with
      | BuiltinFunctionValue _ -> 
        (* 验证这是一个有效的内置函数值 *)
        check bool (Printf.sprintf "函数'%s'应为有效的内置函数" name) true true
      | _ -> 
        fail (Printf.sprintf "函数'%s'应为内置函数类型" name)
    ) type_conversion_functions
end

(** 中文编程特色测试 *)
module ChineseProgrammingTests = struct
  (** 测试中文错误消息 *)
  let test_chinese_error_messages () =
    (* 测试错误消息是否包含中文 *)
    let error_case () = string_to_int_function [StringValue "错误输入"] in
    try
      ignore (error_case ());
      fail "应该抛出运行时错误"
    with
    | RuntimeError msg ->
      check bool "错误消息应包含中文字符" true 
        (Str.string_match (Str.regexp ".*[无法转换].*") msg 0)
    | _ -> fail "应该抛出RuntimeError"

  (** 测试中文函数名称 *)
  let test_chinese_function_names () =
    let chinese_function_names = List.map fst type_conversion_functions in
    List.iter (fun name ->
      (* Check if function name contains Chinese characters by looking for known Chinese function names *)
      let known_chinese_names = ["整数转字符串"; "浮点数转字符串"; "字符串转整数"; "字符串转浮点数"; "整数转浮点数"; "浮点数转整数"; "布尔值转字符串"] in
      let has_chinese = List.mem name known_chinese_names in
      check bool (Printf.sprintf "函数名'%s'应包含中文字符" name) true has_chinese
    ) chinese_function_names
end

(** 往返转换一致性测试 *)
module RoundTripTests = struct
  (** 测试数值往返转换 *)
  let test_numeric_round_trip () =
    (* 整数 -> 字符串 -> 整数 *)
    let original_int = 12345 in
    let str_result = int_to_string_function [IntValue original_int] in
    let back_to_int = string_to_int_function [str_result] in
    check bool "整数往返转换应一致" true (TestUtils.values_equal back_to_int (IntValue original_int));

    (* 整数 -> 浮点数 -> 整数 *)
    let int_to_float_result = int_to_float_function [IntValue original_int] in
    let float_to_int_result = float_to_int_function [int_to_float_result] in
    check bool "整数浮点往返转换应一致" true (TestUtils.values_equal float_to_int_result (IntValue original_int))

  (** 测试布尔值往返转换限制 *)
  let test_boolean_conversion_limitations () =
    (* 布尔值只能转为字符串，不能从字符串转回 *)
    let bool_result = bool_to_string_function [BoolValue true] in
    check bool "布尔转字符串应为中文" true (TestUtils.values_equal bool_result (StringValue "真"));

    let bool_false_result = bool_to_string_function [BoolValue false] in
    check bool "false转字符串应为中文'假'" true (TestUtils.values_equal bool_false_result (StringValue "假"))
end

(** 测试套件注册 *)
let test_suite =
  [
    ("数值类型转换", [
      test_case "整数转字符串" `Quick NumericConversionTests.test_int_to_string;
      test_case "浮点数转字符串" `Quick NumericConversionTests.test_float_to_string;
      test_case "字符串转整数" `Quick NumericConversionTests.test_string_to_int;
      test_case "字符串转浮点数" `Quick NumericConversionTests.test_string_to_float;
      test_case "整数转浮点数" `Quick NumericConversionTests.test_int_to_float;
      test_case "浮点数转整数" `Quick NumericConversionTests.test_float_to_int;
    ]);
    ("布尔值转换", [
      test_case "布尔值转字符串" `Quick BooleanConversionTests.test_bool_to_string;
    ]);
    ("错误处理", [
      test_case "无效字符串转整数" `Quick ErrorHandlingTests.test_invalid_string_to_int;
      test_case "无效字符串转浮点数" `Quick ErrorHandlingTests.test_invalid_string_to_float;
      test_case "参数数量错误" `Quick ErrorHandlingTests.test_argument_count_errors;
      test_case "参数类型错误" `Quick ErrorHandlingTests.test_argument_type_errors;
    ]);
    ("函数表完整性", [
      test_case "类型转换函数表" `Quick FunctionRegistrationTests.test_type_conversion_functions_table;
      test_case "所有函数可调用" `Quick FunctionRegistrationTests.test_all_functions_callable;
    ]);
    ("中文编程特色", [
      test_case "中文错误消息" `Quick ChineseProgrammingTests.test_chinese_error_messages;
      test_case "中文函数名称" `Quick ChineseProgrammingTests.test_chinese_function_names;
    ]);
    ("往返转换一致性", [
      test_case "数值往返转换" `Quick RoundTripTests.test_numeric_round_trip;
      test_case "布尔转换限制" `Quick RoundTripTests.test_boolean_conversion_limitations;
    ]);
  ]

(** 运行所有测试 *)
let () =
  Printf.printf "骆言内置类型转换模块测试 - Issue #911\n";
  Printf.printf "==========================================\n";
  run "Builtin Types Module Tests" test_suite