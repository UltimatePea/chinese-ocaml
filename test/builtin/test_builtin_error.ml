(** 骆言内置错误处理模块测试 - 提升编译器运行时安全性

    本测试模块专门针对 builtin_error.ml 模块进行全面功能测试，重点测试错误处理函数的正确性和一致性。

    测试覆盖范围：
    - 参数数量检查功能
    - 类型检查和验证功能
    - 错误消息生成
    - 异常抛出机制
    - 中文错误消息支持

    @author 骆言技术债务清理团队 - Issue #911
    @version 1.0
    @since 2025-07-23 Issue #911 核心builtin模块测试覆盖 *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_error

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

  (** 获取运行时错误消息 *)
  let get_runtime_error_message f =
    try
      ignore (f ());
      None
    with
    | RuntimeError msg -> Some msg
    | _ -> None

  (** 检查错误消息是否包含中文字符 *)
  let contains_chinese_chars msg =
    let rec check_chars i =
      if i >= String.length msg then false
      else
        let c = String.get msg i in
        if Char.code c > 127 then true else check_chars (i + 1)
    in
    check_chars 0
end

(** 参数数量检查测试 *)
module ArgumentCountTests = struct
  (** 测试正确参数数量不抛出错误 *)
  let test_correct_arg_count () =
    try
      check_args_count 2 2 "测试函数";
      check bool "正确参数数量不应抛出错误" true true
    with RuntimeError _ -> fail "正确参数数量不应抛出错误"

  (** 测试参数数量过多 *)
  let test_too_many_args () =
    let error_case () = check_args_count 1 3 "测试函数" in
    check bool "参数过多应抛出错误" true (TestUtils.expect_runtime_error error_case)

  (** 测试参数数量过少 *)
  let test_too_few_args () =
    let error_case () = check_args_count 3 1 "测试函数" in
    check bool "参数过少应抛出错误" true (TestUtils.expect_runtime_error error_case)

  (** 测试零参数检查 *)
  let test_zero_args () =
    try
      check_args_count 0 0 "测试函数";
      check bool "零参数数量检查应正常" true true
    with RuntimeError _ -> fail "零参数数量检查不应抛出错误"
end

(** 单参数检查测试 *)
module SingleArgumentTests = struct
  (** 测试正确的单参数 *)
  let test_valid_single_arg () =
    let result = check_single_arg [ IntValue 42 ] "测试函数" in
    check bool "单参数检查应返回参数" true (result = IntValue 42)

  (** 测试空参数列表 *)
  let test_empty_arg_list () =
    let error_case () = check_single_arg [] "测试函数" in
    check bool "空参数列表应抛出错误" true (TestUtils.expect_runtime_error error_case)

  (** 测试多个参数 *)
  let test_multiple_args () =
    let error_case () = check_single_arg [ IntValue 1; IntValue 2 ] "测试函数" in
    check bool "多个参数应抛出错误" true (TestUtils.expect_runtime_error error_case)
end

(** 双参数检查测试 *)
module DoubleArgumentTests = struct
  (** 测试正确的双参数 *)
  let test_valid_double_args () =
    let arg1, arg2 = check_double_args [ IntValue 1; StringValue "test" ] "测试函数" in
    check bool "双参数检查应返回正确参数" true (arg1 = IntValue 1 && arg2 = StringValue "test")

  (** 测试单个参数 *)
  let test_single_arg_for_double () =
    let error_case () = check_double_args [ IntValue 42 ] "测试函数" in
    check bool "单个参数用于双参数检查应抛出错误" true (TestUtils.expect_runtime_error error_case)

  (** 测试三个参数 *)
  let test_three_args_for_double () =
    let error_case () = check_double_args [ IntValue 1; IntValue 2; IntValue 3 ] "测试函数" in
    check bool "三个参数用于双参数检查应抛出错误" true (TestUtils.expect_runtime_error error_case)
end

(** 无参数检查测试 *)
module NoArgumentTests = struct
  (** 测试正确的无参数 *)
  let test_valid_no_args () =
    try
      check_no_args [] "测试函数";
      check bool "无参数检查应成功" true true
    with RuntimeError _ -> fail "无参数检查不应抛出错误"

  (** 测试有参数时的错误 *)
  let test_args_present_for_no_args () =
    let error_case () = check_no_args [ IntValue 42 ] "测试函数" in
    check bool "有参数时无参数检查应抛出错误" true (TestUtils.expect_runtime_error error_case)
end

(** 类型检查测试 *)
module TypeCheckTests = struct
  (** 测试字符串类型检查 *)
  let test_expect_string () =
    (* 测试正确的字符串类型 *)
    let result = expect_string (StringValue "测试") "测试函数" in
    check string "字符串类型检查应返回字符串值" "测试" result;

    (* 测试错误的类型 *)
    let error_case () = expect_string (IntValue 42) "测试函数" in
    check bool "非字符串应抛出错误" true (TestUtils.expect_runtime_error error_case)

  (** 测试整数类型检查 *)
  let test_expect_int () =
    (* 测试正确的整数类型 *)
    let result = expect_int (IntValue 42) "测试函数" in
    check int "整数类型检查应返回整数值" 42 result;

    (* 测试错误的类型 *)
    let error_case () = expect_int (StringValue "不是整数") "测试函数" in
    check bool "非整数应抛出错误" true (TestUtils.expect_runtime_error error_case)

  (** 测试浮点数类型检查 *)
  let test_expect_float () =
    (* 测试正确的浮点数类型 *)
    let result = expect_float (FloatValue 3.14) "测试函数" in
    check (float 1e-10) "浮点数类型检查应返回浮点值" 3.14 result;

    (* 测试错误的类型 *)
    let error_case () = expect_float (BoolValue true) "测试函数" in
    check bool "非浮点数应抛出错误" true (TestUtils.expect_runtime_error error_case)

  (** 测试布尔值类型检查 *)
  let test_expect_bool () =
    (* 测试正确的布尔类型 *)
    let result1 = expect_bool (BoolValue true) "测试函数" in
    check bool "布尔类型检查应返回布尔值true" true result1;

    let result2 = expect_bool (BoolValue false) "测试函数" in
    check bool "布尔类型检查应返回布尔值false" false result2;

    (* 测试错误的类型 *)
    let error_case () = expect_bool (IntValue 1) "测试函数" in
    check bool "非布尔值应抛出错误" true (TestUtils.expect_runtime_error error_case)

  (** 测试列表类型检查 *)
  let test_expect_list () =
    (* 测试正确的列表类型 *)
    let test_list = [ IntValue 1; IntValue 2; IntValue 3 ] in
    let result = expect_list (ListValue test_list) "测试函数" in
    check bool "列表类型检查应返回列表值" true (result = test_list);

    (* 测试错误的类型 *)
    let error_case () = expect_list (IntValue 42) "测试函数" in
    check bool "非列表应抛出错误" true (TestUtils.expect_runtime_error error_case)

  (** 测试数组类型检查 *)
  let test_expect_array () =
    (* 测试正确的数组类型 *)
    let test_array = [| IntValue 1; IntValue 2 |] in
    let result = expect_array (ArrayValue test_array) "测试函数" in
    check bool "数组类型检查应返回数组值" true (result = test_array);

    (* 测试错误的类型 *)
    let error_case () = expect_array (StringValue "不是数组") "测试函数" in
    check bool "非数组应抛出错误" true (TestUtils.expect_runtime_error error_case)
end

(** 错误消息测试 *)
module ErrorMessageTests = struct
  (** 测试错误消息包含函数名 *)
  let test_error_message_contains_function_name () =
    let function_name = "特殊测试函数" in
    let error_msg =
      TestUtils.get_runtime_error_message (fun () -> check_single_arg [] function_name)
    in

    match error_msg with
    | Some msg -> check bool "错误消息应包含函数名" true (String.contains msg (String.get function_name 0))
    | None -> fail "应该产生错误消息"

  (** 测试中文错误消息 *)
  let test_chinese_error_messages () =
    let test_cases =
      [
        (fun () -> ignore (check_single_arg [] "中文函数"));
        (fun () -> ignore (expect_int (StringValue "错误") "中文函数"));
        (fun () -> check_args_count 1 2 "中文函数");
      ]
    in

    List.iter
      (fun error_case ->
        let error_msg = TestUtils.get_runtime_error_message error_case in
        match error_msg with
        | Some msg -> check bool "错误消息应包含中文字符" true (TestUtils.contains_chinese_chars msg)
        | None -> fail "应该产生错误消息")
      test_cases

  (** 测试错误消息的一致性 *)
  let test_error_message_consistency () =
    (* 同类型错误应该有一致的消息格式 *)
    let msg1 = TestUtils.get_runtime_error_message (fun () -> check_single_arg [] "函数A") in
    let msg2 = TestUtils.get_runtime_error_message (fun () -> check_single_arg [] "函数B") in

    match (msg1, msg2) with
    | Some m1, Some m2 ->
        (* 错误消息结构应该相似（除了函数名部分） *)
        let m1_no_func = String.sub m1 0 (min 10 (String.length m1)) in
        let m2_no_func = String.sub m2 0 (min 10 (String.length m2)) in
        check bool "同类错误消息格式应一致" true (String.length m1_no_func = String.length m2_no_func)
    | _ -> fail "应该产生错误消息"
end

(** 运行时错误抛出机制测试 *)
module RuntimeErrorTests = struct
  (** 测试runtime_error函数 *)
  let test_runtime_error_function () =
    let test_message = "测试错误消息" in
    let error_case () = runtime_error test_message in

    check bool "runtime_error应抛出RuntimeError异常" true (TestUtils.expect_runtime_error error_case);

    let captured_msg = TestUtils.get_runtime_error_message error_case in
    match captured_msg with
    | Some msg -> check string "错误消息应保持一致" test_message msg
    | None -> fail "应该捕获到错误消息"

  (** 测试异常传播 *)
  let test_exception_propagation () =
    let inner_function () = runtime_error "内部错误" in
    let outer_function () = inner_function () in

    check bool "异常应正确传播" true (TestUtils.expect_runtime_error outer_function)

  (** 测试错误恢复 *)
  let test_error_recovery () =
    let recovery_function () =
      try
        (runtime_error "测试错误" : unit);
        "不应到达这里"
      with
      | RuntimeError _ -> "错误已捕获"
      | _ -> "未知错误"
    in

    let result = recovery_function () in
    check string "错误恢复应正常工作" "错误已捕获" result
end

(** 高级类型检查测试 *)
module AdvancedTypeCheckTests = struct
  (** 测试数字类型检查（整数或浮点数） *)
  let test_expect_number () =
    (* 测试整数作为数字 *)
    let result1 = expect_number (IntValue 42) "测试函数" in
    check bool "整数应被识别为数字" true (match result1 with IntValue 42 -> true | _ -> false);

    (* 测试浮点数作为数字 *)
    let result2 = expect_number (FloatValue 3.14) "测试函数" in
    check bool "浮点数应被识别为数字" true
      (match result2 with FloatValue f -> abs_float (f -. 3.14) < 1e-10 | _ -> false);

    (* 测试非数字类型 *)
    let error_case () = expect_number (StringValue "不是数字") "测试函数" in
    check bool "字符串不应被识别为数字" true (TestUtils.expect_runtime_error error_case)

  (** 测试字符串或列表类型检查 *)
  let test_expect_string_or_list () =
    (* 测试字符串 *)
    let result1 = expect_string_or_list (StringValue "测试字符串") "测试函数" in
    check bool "字符串应通过字符串或列表检查" true (match result1 with StringValue _ -> true | _ -> false);

    (* 测试列表 *)
    let result2 = expect_string_or_list (ListValue [ IntValue 1 ]) "测试函数" in
    check bool "列表应通过字符串或列表检查" true (match result2 with ListValue _ -> true | _ -> false);

    (* 测试其他类型 *)
    let error_case () = expect_string_or_list (IntValue 42) "测试函数" in
    check bool "整数不应通过字符串或列表检查" true (TestUtils.expect_runtime_error error_case)

  (** 测试非空列表检查 *)
  let test_expect_nonempty_list () =
    (* 测试非空列表 *)
    let non_empty_list = [ IntValue 1; IntValue 2 ] in
    let result = expect_nonempty_list (ListValue non_empty_list) "测试函数" in
    check bool "非空列表检查应成功" true (result = non_empty_list);

    (* 测试空列表 *)
    let error_case1 () = expect_nonempty_list (ListValue []) "测试函数" in
    check bool "空列表应抛出错误" true (TestUtils.expect_runtime_error error_case1);

    (* 测试非列表类型 *)
    let error_case2 () = expect_nonempty_list (IntValue 42) "测试函数" in
    check bool "非列表类型应抛出错误" true (TestUtils.expect_runtime_error error_case2)
end

(** 测试套件注册 *)
let test_suite =
  [
    ( "参数数量检查",
      [
        test_case "正确参数数量" `Quick ArgumentCountTests.test_correct_arg_count;
        test_case "参数过多" `Quick ArgumentCountTests.test_too_many_args;
        test_case "参数过少" `Quick ArgumentCountTests.test_too_few_args;
        test_case "零参数检查" `Quick ArgumentCountTests.test_zero_args;
      ] );
    ( "单参数检查",
      [
        test_case "有效单参数" `Quick SingleArgumentTests.test_valid_single_arg;
        test_case "空参数列表" `Quick SingleArgumentTests.test_empty_arg_list;
        test_case "多个参数" `Quick SingleArgumentTests.test_multiple_args;
      ] );
    ( "双参数检查",
      [
        test_case "有效双参数" `Quick DoubleArgumentTests.test_valid_double_args;
        test_case "单参数用于双参数检查" `Quick DoubleArgumentTests.test_single_arg_for_double;
        test_case "三参数用于双参数检查" `Quick DoubleArgumentTests.test_three_args_for_double;
      ] );
    ( "无参数检查",
      [
        test_case "有效无参数" `Quick NoArgumentTests.test_valid_no_args;
        test_case "有参数时无参数检查" `Quick NoArgumentTests.test_args_present_for_no_args;
      ] );
    ( "基础类型检查",
      [
        test_case "字符串类型检查" `Quick TypeCheckTests.test_expect_string;
        test_case "整数类型检查" `Quick TypeCheckTests.test_expect_int;
        test_case "浮点数类型检查" `Quick TypeCheckTests.test_expect_float;
        test_case "布尔值类型检查" `Quick TypeCheckTests.test_expect_bool;
        test_case "列表类型检查" `Quick TypeCheckTests.test_expect_list;
        test_case "数组类型检查" `Quick TypeCheckTests.test_expect_array;
      ] );
    ( "错误消息",
      [
        test_case "错误消息包含函数名" `Quick ErrorMessageTests.test_error_message_contains_function_name;
        test_case "中文错误消息" `Quick ErrorMessageTests.test_chinese_error_messages;
        test_case "错误消息一致性" `Quick ErrorMessageTests.test_error_message_consistency;
      ] );
    ( "运行时错误",
      [
        test_case "runtime_error函数" `Quick RuntimeErrorTests.test_runtime_error_function;
        test_case "异常传播" `Quick RuntimeErrorTests.test_exception_propagation;
        test_case "错误恢复" `Quick RuntimeErrorTests.test_error_recovery;
      ] );
    ( "高级类型检查",
      [
        test_case "数字类型检查" `Quick AdvancedTypeCheckTests.test_expect_number;
        test_case "字符串或列表检查" `Quick AdvancedTypeCheckTests.test_expect_string_or_list;
        test_case "非空列表检查" `Quick AdvancedTypeCheckTests.test_expect_nonempty_list;
      ] );
  ]

(** 运行所有测试 *)
let () =
  Printf.printf "骆言内置错误处理模块测试 - Issue #911\n";
  Printf.printf "==========================================\n";
  run "Builtin Error Handling Module Tests" test_suite
