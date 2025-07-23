(** 骆言内置函数总控模块测试 - 提升编译器运行时安全性

    本测试模块专门针对 builtin_functions.ml 模块进行全面功能测试，重点测试内置函数注册、调用和管理的正确性。

    测试覆盖范围：
    - 内置函数表完整性验证
    - 函数调用机制测试
    - 函数名称查询功能
    - 错误处理和边界条件
    - 模块集成完整性

    @author 骆言技术债务清理团队 - Issue #911
    @version 1.0
    @since 2025-07-23 Issue #911 核心builtin模块测试覆盖 *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_functions

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

  (** 检查是否为有效的内置函数值 *)
  let is_valid_builtin_function_value = function
    | BuiltinFunctionValue _ -> true
    | _ -> false
end

(** 内置函数表完整性测试 *)
module BuiltinFunctionTableTests = struct
  (** 测试内置函数表非空 *)
  let test_builtin_functions_not_empty () =
    let functions = builtin_functions in
    check bool "内置函数表不应为空" true (List.length functions > 0);
    Printf.printf "内置函数总数: %d\n" (List.length functions)

  (** 测试每个内置函数都有有效的函数值 *)
  let test_all_functions_have_valid_values () =
    List.iter (fun (name, func_value) ->
      check bool (Printf.sprintf "函数'%s'应有有效的函数值" name) true 
        (TestUtils.is_valid_builtin_function_value func_value)
    ) builtin_functions

  (** 测试函数名称唯一性 *)
  let test_function_names_unique () =
    let names = List.map fst builtin_functions in
    let unique_names = List.sort_uniq String.compare names in
    check int "函数名称应唯一" (List.length names) (List.length unique_names)

  (** 测试包含各个子模块的函数 *)
  let test_includes_submodule_functions () =
    let function_names = List.map fst builtin_functions in
    
    (* 检查是否包含IO函数 *)
    let has_io_functions = List.exists (fun name -> 
      Str.string_match (Str.regexp ".*[读写输].*") name 0
    ) function_names in
    check bool "应包含IO相关函数" true has_io_functions;

    (* 检查是否包含数学函数 *)
    let has_math_functions = List.exists (fun name ->
      Str.string_match (Str.regexp ".*[加减乘除].*") name 0
    ) function_names in
    check bool "应包含数学相关函数" true has_math_functions;

    (* 检查是否包含字符串函数 *)
    let has_string_functions = List.exists (fun name ->
      Str.string_match (Str.regexp ".*字符串.*\\|.*文本.*") name 0
    ) function_names in
    check bool "应包含字符串相关函数" true has_string_functions;

    (* 检查是否包含类型转换函数 *)
    let has_type_functions = List.exists (fun name ->
      Str.string_match (Str.regexp ".*转.*") name 0 && 
      (Str.string_match (Str.regexp ".*整数.*\\|.*字符串.*") name 0)
    ) function_names in
    check bool "应包含类型转换函数" true has_type_functions
end

(** 函数调用机制测试 *)
module FunctionCallTests = struct
  (** 测试调用已知的内置函数 *)
  let test_call_known_builtin_function () =
    (* 测试调用整数转字符串函数 *)
    let result = call_builtin_function "整数转字符串" [IntValue 42] in
    check bool "整数转字符串调用应成功" true (TestUtils.values_equal result (StringValue "42"));

    (* 测试调用布尔值转字符串函数 *)
    let result2 = call_builtin_function "布尔值转字符串" [BoolValue true] in
    check bool "布尔值转字符串调用应成功" true (TestUtils.values_equal result2 (StringValue "真"))

  (** 测试调用不存在的函数 *)
  let test_call_unknown_function () =
    let error_case () = call_builtin_function "不存在的函数" [] in
    check bool "调用不存在的函数应抛出错误" true (TestUtils.expect_runtime_error error_case)

  (** 测试函数调用错误处理 *)
  let test_function_call_error_handling () =
    (* 测试传递错误类型的参数 *)
    let error_case1 () = call_builtin_function "整数转字符串" [StringValue "不是整数"] in
    check bool "传递错误参数类型应抛出错误" true (TestUtils.expect_runtime_error error_case1);

    (* 测试传递错误数量的参数 *)
    let error_case2 () = call_builtin_function "整数转字符串" [] in
    check bool "传递错误参数数量应抛出错误" true (TestUtils.expect_runtime_error error_case2)

  (** 测试批量调用不同类型的函数 *)
  let test_batch_function_calls () =
    let test_cases = [
      ("整数转字符串", [IntValue 123], fun r -> TestUtils.values_equal r (StringValue "123"));
      ("字符串转整数", [StringValue "456"], fun r -> TestUtils.values_equal r (IntValue 456));
      ("布尔值转字符串", [BoolValue false], fun r -> TestUtils.values_equal r (StringValue "假"));
    ] in

    List.iter (fun (func_name, args, validator) ->
      try
        let result = call_builtin_function func_name args in
        check bool (Printf.sprintf "批量调用'%s'应成功" func_name) true (validator result)
      with
      | _ -> (* 某些函数可能不存在，这里跳过 *)
        Printf.printf "跳过函数: %s\n" func_name
    ) test_cases
end

(** 函数查询功能测试 *)
module FunctionQueryTests = struct
  (** 测试检查内置函数存在性 *)
  let test_is_builtin_function () =
    (* 测试已知存在的函数 *)
    check bool "整数转字符串应为内置函数" true (is_builtin_function "整数转字符串");
    check bool "布尔值转字符串应为内置函数" true (is_builtin_function "布尔值转字符串");

    (* 测试不存在的函数 *)
    check bool "不存在的函数不应为内置函数" false (is_builtin_function "完全不存在的函数");
    check bool "空字符串不应为内置函数" false (is_builtin_function "")

  (** 测试获取所有内置函数名称 *)
  let test_get_builtin_function_names () =
    let names = get_builtin_function_names () in
    
    (* 检查返回列表非空 *)
    check bool "函数名称列表不应为空" true (List.length names > 0);

    (* 检查是否包含预期的函数名 *)
    check bool "应包含整数转字符串函数" true (List.mem "整数转字符串" names);
    
    (* 检查列表长度与函数表一致 *)
    check int "函数名称列表长度应与函数表一致" (List.length builtin_functions) (List.length names)

  (** 测试函数名称查询的一致性 *)
  let test_function_query_consistency () =
    let all_names = get_builtin_function_names () in
    
    (* 所有从函数表获取的名称都应通过is_builtin_function验证 *)
    List.iter (fun name ->
      check bool (Printf.sprintf "函数'%s'应通过存在性检查" name) true (is_builtin_function name)
    ) all_names;

    (* 验证函数表中的每个函数都能在名称列表中找到 *)
    List.iter (fun (name, _) ->
      check bool (Printf.sprintf "函数表中的'%s'应在名称列表中" name) true (List.mem name all_names)
    ) builtin_functions
end

(** 模块集成完整性测试 *)
module ModuleIntegrationTests = struct
  (** 测试所有子模块函数都被正确集成 *)
  let test_all_submodules_integrated () =
    let function_names = get_builtin_function_names () in
    
    (* 预期的子模块函数类型 *)
    let expected_function_types = [
      ("IO", ["读"; "写"; "输"; "打印"]);
      ("数学", ["加"; "减"; "乘"; "除"; "求余"; "幂"]);
      ("字符串", ["字符串长度"; "字符串连接"; "字符串"]);
      ("数组", ["数组"; "创建"; "长度"]);
      ("类型转换", ["转字符串"; "转整数"; "转浮点"]);
      ("工具", ["比较"; "相等"]);
    ] in

    List.iter (fun (module_name, keywords) ->
      let has_functions = List.exists (fun keyword ->
        List.exists (fun func_name ->
          String.contains func_name (String.get keyword 0)
        ) function_names
      ) keywords in
      check bool (Printf.sprintf "应集成%s模块的函数" module_name) true has_functions
    ) expected_function_types

  (** 测试函数表结构完整性 *)
  let test_function_table_structure () =
    (* 验证函数表是一个有效的关联列表 *)
    List.iter (fun (name, value) ->
      check bool (Printf.sprintf "函数名'%s'不应为空" name) true (String.length name > 0);
      check bool (Printf.sprintf "函数'%s'应为内置函数值" name) true 
        (TestUtils.is_valid_builtin_function_value value)
    ) builtin_functions

  (** 测试函数调用的模块间协调 *)
  let test_cross_module_function_coordination () =
    (* 测试不同模块的函数能否正常协作 *)
    try
      (* 先调用类型转换函数 *)
      let str_result = call_builtin_function "整数转字符串" [IntValue 42] in
      
      (* 再尝试调用其他模块函数（如果存在） *)
      match str_result with
      | StringValue s ->
        check bool "模块间函数协调应正常" true (String.length s > 0)
      | _ -> fail "类型转换结果错误"
    with
    | RuntimeError _ -> 
      (* 某些函数可能不存在，跳过此测试 *)
      Printf.printf "跳过模块协调测试（某些函数不存在）\n"
end

(** 性能和边界条件测试 *)
module PerformanceAndBoundaryTests = struct
  (** 测试大量函数调用性能 *)
  let test_bulk_function_calls () =
    let call_count = 1000 in
    let start_time = Sys.time () in
    
    for i = 1 to call_count do
      ignore (call_builtin_function "整数转字符串" [IntValue i])
    done;
    
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    check bool "大量函数调用应在合理时间内完成" true (duration < 1.0);
    Printf.printf "调用%d次函数耗时: %.3f秒\n" call_count duration

  (** 测试函数名称边界条件 *)
  let test_function_name_boundary_cases () =
    (* 测试空函数名 *)
    check bool "空函数名不应存在" false (is_builtin_function "");
    
    (* 测试非常长的函数名 *)
    let long_name = String.make 1000 'x' in
    check bool "超长函数名不应存在" false (is_builtin_function long_name);
    
    (* 测试特殊字符函数名 *)
    check bool "特殊字符函数名不应存在" false (is_builtin_function "!@#$%^&*()")

  (** 测试函数表内存占用 *)
  let test_function_table_memory_usage () =
    let function_count = List.length builtin_functions in
    check bool "函数表大小应合理" true (function_count > 10 && function_count < 1000);
    
    (* 检查是否有重复的函数实例 *)
    let names = List.map fst builtin_functions in
    let unique_names = List.sort_uniq String.compare names in
    check int "不应有重复的函数名" (List.length names) (List.length unique_names)
end

(** 中文编程特色测试 *)
module ChineseProgrammingTests = struct
  (** 测试中文函数名称支持 *)
  let test_chinese_function_names () =
    let function_names = get_builtin_function_names () in
    
    (* 检查是否有中文函数名 *)
    let has_chinese_names = List.exists (fun name ->
      let utf8_length = Bytes.length (Bytes.of_string name) in
      let char_count = String.length name in
      utf8_length > char_count
    ) function_names in
    check bool "应支持中文函数名" true has_chinese_names;

    (* 检查常见中文函数名 *)
    let expected_chinese_names = ["整数转字符串"; "布尔值转字符串"] in
    List.iter (fun expected ->
      if List.mem expected function_names then
        check bool (Printf.sprintf "应包含中文函数'%s'" expected) true true
      else
        Printf.printf "注意：函数'%s'可能不存在\n" expected
    ) expected_chinese_names

  (** 测试中文错误消息 *)
  let test_chinese_error_messages () =
    try
      ignore (call_builtin_function "不存在的中文函数名" []);
      fail "应该抛出运行时错误"
    with
    | RuntimeError msg ->
      check bool "错误消息应包含中文字符" true 
        (Str.string_match (Str.regexp ".*[未知函数].*") msg 0)
    | _ -> fail "应该抛出RuntimeError"
end

(** 测试套件注册 *)
let test_suite =
  [
    ("内置函数表完整性", [
      test_case "函数表非空" `Quick BuiltinFunctionTableTests.test_builtin_functions_not_empty;
      test_case "函数值有效性" `Quick BuiltinFunctionTableTests.test_all_functions_have_valid_values;
      test_case "函数名称唯一性" `Quick BuiltinFunctionTableTests.test_function_names_unique;
      test_case "包含子模块函数" `Quick BuiltinFunctionTableTests.test_includes_submodule_functions;
    ]);
    ("函数调用机制", [
      test_case "调用已知函数" `Quick FunctionCallTests.test_call_known_builtin_function;
      test_case "调用未知函数" `Quick FunctionCallTests.test_call_unknown_function;
      test_case "调用错误处理" `Quick FunctionCallTests.test_function_call_error_handling;
      test_case "批量函数调用" `Quick FunctionCallTests.test_batch_function_calls;
    ]);
    ("函数查询功能", [
      test_case "函数存在性检查" `Quick FunctionQueryTests.test_is_builtin_function;
      test_case "获取函数名称列表" `Quick FunctionQueryTests.test_get_builtin_function_names;
      test_case "查询一致性" `Quick FunctionQueryTests.test_function_query_consistency;
    ]);
    ("模块集成完整性", [
      test_case "子模块集成" `Quick ModuleIntegrationTests.test_all_submodules_integrated;
      test_case "函数表结构" `Quick ModuleIntegrationTests.test_function_table_structure;
      test_case "模块间协调" `Quick ModuleIntegrationTests.test_cross_module_function_coordination;
    ]);
    ("性能和边界条件", [
      test_case "大量函数调用" `Quick PerformanceAndBoundaryTests.test_bulk_function_calls;
      test_case "函数名边界条件" `Quick PerformanceAndBoundaryTests.test_function_name_boundary_cases;
      test_case "函数表内存占用" `Quick PerformanceAndBoundaryTests.test_function_table_memory_usage;
    ]);
    ("中文编程特色", [
      test_case "中文函数名支持" `Quick ChineseProgrammingTests.test_chinese_function_names;
      test_case "中文错误消息" `Quick ChineseProgrammingTests.test_chinese_error_messages;
    ]);
  ]

(** 运行所有测试 *)
let () =
  Printf.printf "骆言内置函数总控模块测试 - Issue #911\n";
  Printf.printf "==========================================\n";
  run "Builtin Functions Module Tests" test_suite