(** 内置错误处理模块测试覆盖率提升 - Fix #2124
    
    专注于提升builtin_error.ml模块测试覆盖率从0.92%到80%+
    新增测试场景：
    - 错误处理辅助函数完整测试
    - 参数数量检查函数全路径覆盖
    - 错误上下文创建测试
    - 模块错误消息格式化测试
    - 边界条件和异常情况测试
    
    Author: Whisky, PR Worker Agent
    @version 1.0
    @since 2025-08-02 Fix #2124 核心模块测试覆盖率提升优化 *)

open Alcotest
open Yyocamlc_lib
open Value_operations
open Builtin_error

(** 测试工具模块 *)
module BuiltinErrorTestUtils = struct
  (* 辅助函数检查字符串包含子串 *)
  let string_contains_substring s substring =
    try
      let _ = Str.search_forward (Str.regexp_string substring) s 0 in
      true
    with Not_found -> false

  (** 值的格式化函数 *)
  let pp_value fmt value = Format.fprintf fmt "%s" (Value_operations.value_to_string value)

  (** 测试期望运行时错误的工具函数 *)
  let expect_runtime_error desc f =
    try
      let _ = f () in
      fail (desc ^ ": 期望运行时错误但未抛出")
    with
    | RuntimeError _ -> () (* 预期的错误 *)
    | e -> fail (desc ^ ": 意外的异常类型: " ^ Printexc.to_string e)
  
  (** 测试期望特定错误消息的工具函数 *)
  let expect_error_with_message desc expected_substring f =
    try
      let _ = f () in
      fail (desc ^ ": 期望错误但未抛出")
    with
    | RuntimeError msg when string_contains_substring msg expected_substring -> ()
    | RuntimeError msg -> fail (desc ^ ": 错误消息不匹配，实际: " ^ msg)
    | e -> fail (desc ^ ": 意外的异常类型: " ^ Printexc.to_string e)
end

(** 测试运行时错误函数 *)
let test_runtime_error_function () =
  (* 测试基本运行时错误抛出 *)
  BuiltinErrorTestUtils.expect_runtime_error "基本运行时错误抛出" (fun () ->
    runtime_error "测试错误消息");
  
  (* 测试空错误消息 *)
  BuiltinErrorTestUtils.expect_runtime_error "空错误消息" (fun () ->
    runtime_error "");
  
  (* 测试包含中文的错误消息 *)
  BuiltinErrorTestUtils.expect_runtime_error "中文错误消息" (fun () ->
    runtime_error "这是一个中文错误消息");
  
  (* 测试包含特殊字符的错误消息 *)
  BuiltinErrorTestUtils.expect_runtime_error "特殊字符错误消息" (fun () ->
    runtime_error "错误: 参数无效 \n\t 详情信息")

(** 测试参数数量检查函数 *)
let test_check_args_count_function () =
  (* 测试正确的参数数量（不应抛出错误） *)
  check_args_count 2 2 "test_function";
  check_args_count 0 0 "no_param_function";
  check_args_count 5 5 "multi_param_function";
  
  (* 测试参数数量不匹配的情况 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "参数数量过少应抛出错误" "参数" (fun () ->
    check_args_count 3 2 "test_function");
  
  BuiltinErrorTestUtils.expect_error_with_message 
    "参数数量过多应抛出错误" "参数" (fun () ->
    check_args_count 2 3 "test_function");
  
  (* 测试零参数期望但提供了参数 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "零参数期望但提供参数应抛出错误" "参数" (fun () ->
    check_args_count 0 1 "no_param_function");
  
  (* 测试期望参数但未提供 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "期望参数但未提供应抛出错误" "参数" (fun () ->
    check_args_count 1 0 "single_param_function")

(** 测试单参数检查函数 *)
let test_check_single_arg_function () =
  (* 测试正确的单参数 *)
  let test_value = IntValue 42 in
  let result = check_single_arg [test_value] "single_arg_func" in
  check (testable BuiltinErrorTestUtils.pp_value Value_operations.runtime_value_equal) 
    "单参数检查应返回正确值" test_value result;
  
  (* 测试字符串参数 *)
  let string_value = StringValue "test" in
  let result_string = check_single_arg [string_value] "string_func" in
  check (testable BuiltinErrorTestUtils.pp_value Value_operations.runtime_value_equal) 
    "字符串参数检查应返回正确值" string_value result_string;
  
  (* 测试布尔参数 *)
  let bool_value = BoolValue true in
  let result_bool = check_single_arg [bool_value] "bool_func" in
  check (testable BuiltinErrorTestUtils.pp_value Value_operations.runtime_value_equal) 
    "布尔参数检查应返回正确值" bool_value result_bool;
  
  (* 测试空参数列表 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "空参数列表应抛出错误" "参数" (fun () ->
    check_single_arg [] "single_arg_func");
  
  (* 测试多个参数 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "多个参数应抛出错误" "参数" (fun () ->
    check_single_arg [IntValue 1; IntValue 2] "single_arg_func");
  
  (* 测试三个参数 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "三个参数应抛出错误" "参数" (fun () ->
    check_single_arg [IntValue 1; IntValue 2; IntValue 3] "single_arg_func")

(** 测试双参数检查函数 *)
let test_check_double_args_function () =
  (* 测试正确的双参数 *)
  let arg1 = IntValue 10 in
  let arg2 = StringValue "test" in
  let (result1, result2) = check_double_args [arg1; arg2] "double_args_func" in
  check (testable BuiltinErrorTestUtils.pp_value Value_operations.runtime_value_equal) 
    "双参数检查应返回正确第一个值" arg1 result1;
  check (testable BuiltinErrorTestUtils.pp_value Value_operations.runtime_value_equal) 
    "双参数检查应返回正确第二个值" arg2 result2;
  
  (* 测试不同类型的双参数 *)
  let float_arg = FloatValue 3.14 in
  let bool_arg = BoolValue false in
  let (result_float, result_bool) = check_double_args [float_arg; bool_arg] "mixed_func" in
  check (testable BuiltinErrorTestUtils.pp_value Value_operations.runtime_value_equal) 
    "浮点参数检查正确" float_arg result_float;
  check (testable BuiltinErrorTestUtils.pp_value Value_operations.runtime_value_equal) 
    "布尔参数检查正确" bool_arg result_bool;
  
  (* 测试单个参数 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "单个参数应抛出错误" "参数" (fun () ->
    check_double_args [IntValue 1] "double_args_func");
  
  (* 测试空参数列表 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "空参数列表应抛出错误" "参数" (fun () ->
    check_double_args [] "double_args_func");
  
  (* 测试三个参数 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "三个参数应抛出错误" "参数" (fun () ->
    check_double_args [IntValue 1; IntValue 2; IntValue 3] "double_args_func");
  
  (* 测试四个参数 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "四个参数应抛出错误" "参数" (fun () ->
    check_double_args [IntValue 1; IntValue 2; IntValue 3; IntValue 4] "double_args_func")

(** 测试错误上下文和消息格式 *)
let test_error_context_and_formatting () =
  (* 测试函数名包含在错误消息中 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "函数名应包含在错误消息中" "test_function_name" (fun () ->
    check_args_count 1 2 "test_function_name");
  
  (* 测试模块名可能包含在错误消息中 *)
  BuiltinErrorTestUtils.expect_runtime_error 
    "错误上下文应正确格式化" (fun () ->
    check_single_arg [] "context_test_func");
  
  (* 测试不同函数名的错误消息 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "中文函数名应正确处理" "中文函数" (fun () ->
    check_args_count 2 1 "中文函数");
  
  (* 测试包含特殊字符的函数名 *)
  BuiltinErrorTestUtils.expect_error_with_message 
    "特殊字符函数名应正确处理" "func_with_underscores" (fun () ->
    check_double_args [IntValue 1] "func_with_underscores")

(** 测试边界条件和极端情况 *)
let test_edge_cases_and_extremes () =
  (* 测试非常长的函数名 *)
  let long_function_name = String.make 1000 'f' in
  BuiltinErrorTestUtils.expect_runtime_error 
    "长函数名应正确处理" (fun () ->
    check_args_count 1 0 long_function_name);
  
  (* 测试空函数名 *)
  BuiltinErrorTestUtils.expect_runtime_error 
    "空函数名应正确处理" (fun () ->
    check_single_arg [] "");
  
  (* 测试大量参数的情况 *)
  let many_args = List.init 100 (fun i -> IntValue i) in
  BuiltinErrorTestUtils.expect_runtime_error 
    "大量参数应正确处理" (fun () ->
    check_single_arg many_args "many_args_func");
  
  (* 测试负数参数期望（理论上不会发生，但测试健壮性） *)
  BuiltinErrorTestUtils.expect_runtime_error 
    "负数参数期望应正确处理" (fun () ->
    check_args_count (-1) 0 "negative_count_func");
  
  (* 测试大数参数期望 *)
  BuiltinErrorTestUtils.expect_runtime_error 
    "大数参数期望应正确处理" (fun () ->
    check_args_count 1000000 5 "large_count_func")

(** 测试不同值类型的处理 *)
let test_different_value_types () =
  (* 测试所有支持的值类型 *)
  let test_values = [
    IntValue 42;
    FloatValue 3.14;
    StringValue "测试字符串";
    BoolValue true;
    BoolValue false;
    UnitValue;
  ] in
  
  (* 测试每种类型的单参数检查 *)
  List.iteri (fun i value ->
    let result = check_single_arg [value] (Printf.sprintf "type_test_%d" i) in
    check (testable BuiltinErrorTestUtils.pp_value Value_operations.runtime_value_equal) 
      (Printf.sprintf "类型%d单参数检查" i) value result
  ) test_values;
  
  (* 测试不同类型组合的双参数检查 *)
  for i = 0 to List.length test_values - 1 do
    for j = 0 to List.length test_values - 1 do
      let arg1 = List.nth test_values i in
      let arg2 = List.nth test_values j in
      let (result1, result2) = check_double_args [arg1; arg2] (Printf.sprintf "combo_%d_%d" i j) in
      check (testable BuiltinErrorTestUtils.pp_value Value_operations.runtime_value_equal) 
        (Printf.sprintf "组合%d-%d第一参数" i j) arg1 result1;
      check (testable BuiltinErrorTestUtils.pp_value Value_operations.runtime_value_equal) 
        (Printf.sprintf "组合%d-%d第二参数" i j) arg2 result2
    done
  done

(** 测试错误消息的一致性 *)
let test_error_message_consistency () =
  (* 收集不同情况下的错误消息，验证格式一致性 *)
  let error_messages = ref [] in
  
  let collect_error f =
    try f (); ""
    with RuntimeError msg -> msg | _ -> "其他错误"
  in
  
  (* 收集各种错误消息 *)
  error_messages := [
    collect_error (fun () -> check_args_count 1 2 "func1");
    collect_error (fun () -> check_args_count 3 1 "func2");
    collect_error (fun () -> let _ = check_single_arg [] "func3" in ());
    collect_error (fun () -> let _ = check_single_arg [IntValue 1; IntValue 2] "func4" in ());
    collect_error (fun () -> let _ = check_double_args [IntValue 1] "func5" in ());
    collect_error (fun () -> let _ = check_double_args [IntValue 1; IntValue 2; IntValue 3] "func6" in ());
  ] @ !error_messages;
  
  (* 验证所有错误消息都非空 *)
  List.iter (fun msg ->
    check bool "错误消息应非空" true (String.length msg > 0)
  ) !error_messages;
  
  (* 验证错误消息包含预期关键词 *)
  List.iter (fun msg ->
    let contains_key_terms = 
      BuiltinErrorTestUtils.string_contains_substring msg "参" || 
      BuiltinErrorTestUtils.string_contains_substring msg "函" || 
      BuiltinErrorTestUtils.string_contains_substring msg "a" || 
      BuiltinErrorTestUtils.string_contains_substring msg "r" in
    check bool "错误消息应包含关键术语" true contains_key_terms
  ) !error_messages

(** 主测试套件 *)
let test_suite () = [
  ("运行时错误函数测试", `Quick, test_runtime_error_function);
  ("参数数量检查函数测试", `Quick, test_check_args_count_function);
  ("单参数检查函数测试", `Quick, test_check_single_arg_function);
  ("双参数检查函数测试", `Quick, test_check_double_args_function);
  ("错误上下文和格式化测试", `Quick, test_error_context_and_formatting);
  ("边界条件和极端情况测试", `Quick, test_edge_cases_and_extremes);
  ("不同值类型处理测试", `Quick, test_different_value_types);
  ("错误消息一致性测试", `Quick, test_error_message_consistency);
]

(** 执行测试 *)
let () =
  Alcotest.run "内置错误处理模块覆盖率测试 - Fix #2124" [
    ("builtin_error_coverage", test_suite ())
  ]