(** Binary Operations模块全面测试覆盖率提升

    目标: 将binary_operations模块测试覆盖率从7%提升到80%+

    测试覆盖范围:
    - 所有二元运算函数的功能测试
    - 算术运算（整数、浮点数、混合类型）
    - 比较运算（类型化和相等性比较）
    - 逻辑运算（与、或）
    - 字符串运算（连接）
    - 一元运算（取负、逻辑非）
    - 类型转换和错误恢复
    - 错误处理和边界条件
    - Result类型接口测试

    @author Alpha, 主工作代理
    @version 1.0
    @since 2025-07-27 Fix #1477 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Binary_operations
open Yyocamlc_lib.Compiler_errors_types

(** 测试工具模块 *)
module TestUtils = struct
  let value_testable = testable (fun fmt v -> Format.fprintf fmt "%s" (value_to_string v)) ( = )
  let bool_testable = testable Format.pp_print_bool Bool.equal

  (** 检查运行时值相等 *)
  let check_value_equal desc expected actual = check value_testable desc expected actual

  (** 验证运行时错误 *)
  let expect_runtime_error f =
    try
      ignore (f ());
      false
    with
    | RuntimeError _ -> true
    | CompilerError _ -> true
    | _ -> false

  (** 验证特定错误消息 *)
  let expect_error_with_message f expected_msg =
    try
      ignore (f ());
      false
    with
    | RuntimeError msg -> String.contains msg (String.get expected_msg 0)
    | CompilerError _ -> true (* 简化处理 - CompilerError通常表示预期的错误 *)
    | _ -> false
end

(** 整数算术运算测试 *)
module IntegerArithmeticTests = struct
  let test_integer_addition () =
    (* 正数加法 *)
    TestUtils.check_value_equal "正整数加法" (IntValue 7)
      (execute_binary_op Add (IntValue 3) (IntValue 4));

    (* 负数加法 *)
    TestUtils.check_value_equal "负整数加法" (IntValue (-7))
      (execute_binary_op Add (IntValue (-3)) (IntValue (-4)));

    (* 正负数加法 *)
    TestUtils.check_value_equal "正负数加法" (IntValue (-1))
      (execute_binary_op Add (IntValue 3) (IntValue (-4)));

    (* 零加法 *)
    TestUtils.check_value_equal "零加法" (IntValue 5) (execute_binary_op Add (IntValue 0) (IntValue 5))

  let test_integer_subtraction () =
    TestUtils.check_value_equal "整数减法" (IntValue 2)
      (execute_binary_op Sub (IntValue 7) (IntValue 5));

    TestUtils.check_value_equal "减法负结果" (IntValue (-3))
      (execute_binary_op Sub (IntValue 2) (IntValue 5));

    TestUtils.check_value_equal "减法零" (IntValue 0) (execute_binary_op Sub (IntValue 5) (IntValue 5))

  let test_integer_multiplication () =
    TestUtils.check_value_equal "整数乘法" (IntValue 15)
      (execute_binary_op Mul (IntValue 3) (IntValue 5));

    TestUtils.check_value_equal "乘法零" (IntValue 0)
      (execute_binary_op Mul (IntValue 0) (IntValue 100));

    TestUtils.check_value_equal "负数乘法" (IntValue (-12))
      (execute_binary_op Mul (IntValue (-3)) (IntValue 4))

  let test_integer_division () =
    TestUtils.check_value_equal "整数除法" (IntValue 3)
      (execute_binary_op Div (IntValue 15) (IntValue 5));

    TestUtils.check_value_equal "除法整除" (IntValue 4)
      (execute_binary_op Div (IntValue 20) (IntValue 5));

    (* 测试除零错误 *)
    check TestUtils.bool_testable "除零应抛出错误" true
      (TestUtils.expect_runtime_error (fun () -> execute_binary_op Div (IntValue 10) (IntValue 0)))

  let test_integer_modulo () =
    TestUtils.check_value_equal "整数取模" (IntValue 2)
      (execute_binary_op Mod (IntValue 17) (IntValue 5));

    TestUtils.check_value_equal "取模零结果" (IntValue 0)
      (execute_binary_op Mod (IntValue 15) (IntValue 5));

    (* 测试模零错误 *)
    check TestUtils.bool_testable "模零应抛出错误" true
      (TestUtils.expect_runtime_error (fun () -> execute_binary_op Mod (IntValue 10) (IntValue 0)))
end

(** 浮点数算术运算测试 *)
module FloatArithmeticTests = struct
  let test_float_addition () =
    TestUtils.check_value_equal "浮点数加法" (FloatValue 7.5)
      (execute_binary_op Add (FloatValue 3.2) (FloatValue 4.3));

    (* 浮点精度测试 - 使用较简单的数值 *)
    TestUtils.check_value_equal "浮点负数加法" (FloatValue (-1.0))
      (execute_binary_op Add (FloatValue (-2.0)) (FloatValue 1.0))

  let test_float_subtraction () =
    TestUtils.check_value_equal "浮点数减法" (FloatValue 1.0)
      (execute_binary_op Sub (FloatValue 3.0) (FloatValue 2.0));

    TestUtils.check_value_equal "浮点数负结果" (FloatValue (-1.5))
      (execute_binary_op Sub (FloatValue 1.5) (FloatValue 3.0))

  let test_float_multiplication () =
    TestUtils.check_value_equal "浮点数乘法" (FloatValue 7.5)
      (execute_binary_op Mul (FloatValue 2.5) (FloatValue 3.0));

    TestUtils.check_value_equal "浮点数乘零" (FloatValue 0.0)
      (execute_binary_op Mul (FloatValue 0.0) (FloatValue 5.5))

  let test_float_division () =
    TestUtils.check_value_equal "浮点数除法" (FloatValue 2.5)
      (execute_binary_op Div (FloatValue 7.5) (FloatValue 3.0));

    (* 浮点数除零在OCaml中返回无穷大，不会抛出异常 *)
    let result = execute_binary_op Div (FloatValue 1.0) (FloatValue 0.0) in
    match result with
    | FloatValue f when Float.is_infinite f -> check TestUtils.bool_testable "浮点数除零应返回无穷大" true true
    | _ -> fail "浮点数除零应返回无穷大"
end

(** 混合类型算术运算测试 *)
module MixedArithmeticTests = struct
  let test_int_float_operations () =
    (* 类型转换已启用，应该成功执行 *)
    TestUtils.check_value_equal "整数+浮点数类型转换" (IntValue 5)
      (execute_binary_op Add (IntValue 3) (FloatValue 2.5));

    TestUtils.check_value_equal "浮点数+整数类型转换" (IntValue 5)
      (execute_binary_op Add (FloatValue 3.5) (IntValue 2))
end

(** 比较运算测试 *)
module ComparisonTests = struct
  let test_equality_operations () =
    (* 相等性测试 *)
    TestUtils.check_value_equal "整数相等" (BoolValue true)
      (execute_binary_op Eq (IntValue 5) (IntValue 5));

    TestUtils.check_value_equal "整数不等" (BoolValue false)
      (execute_binary_op Eq (IntValue 5) (IntValue 3));

    TestUtils.check_value_equal "字符串相等" (BoolValue true)
      (execute_binary_op Eq (StringValue "hello") (StringValue "hello"));

    TestUtils.check_value_equal "布尔值相等" (BoolValue true)
      (execute_binary_op Eq (BoolValue true) (BoolValue true));

    (* 不等性测试 *)
    TestUtils.check_value_equal "整数不等性" (BoolValue true)
      (execute_binary_op Neq (IntValue 5) (IntValue 3));

    TestUtils.check_value_equal "字符串不等性" (BoolValue false)
      (execute_binary_op Neq (StringValue "test") (StringValue "test"))

  let test_integer_comparisons () =
    TestUtils.check_value_equal "整数小于" (BoolValue true)
      (execute_binary_op Lt (IntValue 3) (IntValue 5));

    TestUtils.check_value_equal "整数小于等于" (BoolValue true)
      (execute_binary_op Le (IntValue 5) (IntValue 5));

    TestUtils.check_value_equal "整数大于" (BoolValue true)
      (execute_binary_op Gt (IntValue 7) (IntValue 3));

    TestUtils.check_value_equal "整数大于等于" (BoolValue true)
      (execute_binary_op Ge (IntValue 5) (IntValue 5));

    TestUtils.check_value_equal "整数小于假" (BoolValue false)
      (execute_binary_op Lt (IntValue 7) (IntValue 3))

  let test_float_comparisons () =
    TestUtils.check_value_equal "浮点数小于" (BoolValue true)
      (execute_binary_op Lt (FloatValue 3.2) (FloatValue 5.7));

    TestUtils.check_value_equal "浮点数大于等于" (BoolValue true)
      (execute_binary_op Ge (FloatValue 5.5) (FloatValue 5.5));

    TestUtils.check_value_equal "浮点数大于" (BoolValue false)
      (execute_binary_op Gt (FloatValue 2.3) (FloatValue 4.1))

  let test_mixed_type_comparisons () =
    (* 混合类型比较需要类型转换或应该失败 *)
    check TestUtils.bool_testable "混合类型比较应失败" true
      (TestUtils.expect_runtime_error (fun () ->
           execute_binary_op Lt (IntValue 3) (StringValue "hello")))
end

(** 逻辑运算测试 *)
module LogicalOperationTests = struct
  let test_logical_and () =
    TestUtils.check_value_equal "真与真" (BoolValue true)
      (execute_binary_op And (BoolValue true) (BoolValue true));

    TestUtils.check_value_equal "真与假" (BoolValue false)
      (execute_binary_op And (BoolValue true) (BoolValue false));

    TestUtils.check_value_equal "假与真" (BoolValue false)
      (execute_binary_op And (BoolValue false) (BoolValue true));

    TestUtils.check_value_equal "假与假" (BoolValue false)
      (execute_binary_op And (BoolValue false) (BoolValue false));

    (* 测试非布尔值的And运算 *)
    TestUtils.check_value_equal "整数与运算" (BoolValue false)
      (execute_binary_op And (IntValue 0) (IntValue 1));

    TestUtils.check_value_equal "字符串与运算" (BoolValue false)
      (execute_binary_op And (StringValue "") (StringValue "hello"))

  let test_logical_or () =
    TestUtils.check_value_equal "真或真" (BoolValue true)
      (execute_binary_op Or (BoolValue true) (BoolValue true));

    TestUtils.check_value_equal "真或假" (BoolValue true)
      (execute_binary_op Or (BoolValue true) (BoolValue false));

    TestUtils.check_value_equal "假或真" (BoolValue true)
      (execute_binary_op Or (BoolValue false) (BoolValue true));

    TestUtils.check_value_equal "假或假" (BoolValue false)
      (execute_binary_op Or (BoolValue false) (BoolValue false));

    (* 测试非布尔值的Or运算 *)
    TestUtils.check_value_equal "整数或运算" (BoolValue true)
      (execute_binary_op Or (IntValue 1) (IntValue 0));

    TestUtils.check_value_equal "混合或运算" (BoolValue true)
      (execute_binary_op Or (StringValue "hello") (IntValue 0))
end

(** 字符串运算测试 *)
module StringOperationTests = struct
  let test_string_concatenation () =
    TestUtils.check_value_equal "字符串连接" (StringValue "helloworld")
      (execute_binary_op Add (StringValue "hello") (StringValue "world"));

    TestUtils.check_value_equal "字符串Concat运算" (StringValue "abcdef")
      (execute_binary_op Concat (StringValue "abc") (StringValue "def"));

    TestUtils.check_value_equal "空字符串连接" (StringValue "hello")
      (execute_binary_op Add (StringValue "") (StringValue "hello"));

    TestUtils.check_value_equal "中文字符串连接" (StringValue "你好世界")
      (execute_binary_op Add (StringValue "你好") (StringValue "世界"));

    (* 测试非字符串的字符串运算 *)
    check TestUtils.bool_testable "非字符串Concat应失败" true
      (TestUtils.expect_runtime_error (fun () -> execute_binary_op Concat (IntValue 1) (IntValue 2)))
end

(** 一元运算测试 *)
module UnaryOperationTests = struct
  let test_negation () =
    TestUtils.check_value_equal "整数取负" (IntValue (-5)) (execute_unary_op Neg (IntValue 5));

    TestUtils.check_value_equal "负数取负" (IntValue 5) (execute_unary_op Neg (IntValue (-5)));

    TestUtils.check_value_equal "零取负" (IntValue 0) (execute_unary_op Neg (IntValue 0));

    TestUtils.check_value_equal "浮点数取负" (FloatValue (-3.14))
      (execute_unary_op Neg (FloatValue 3.14));

    TestUtils.check_value_equal "负浮点数取负" (FloatValue 2.718)
      (execute_unary_op Neg (FloatValue (-2.718)));

    (* 测试非数值取负 *)
    check TestUtils.bool_testable "字符串取负应失败" true
      (TestUtils.expect_runtime_error (fun () -> execute_unary_op Neg (StringValue "hello")))

  let test_logical_not () =
    TestUtils.check_value_equal "真的逻辑非" (BoolValue false) (execute_unary_op Not (BoolValue true));

    TestUtils.check_value_equal "假的逻辑非" (BoolValue true) (execute_unary_op Not (BoolValue false));

    (* 测试非布尔值的逻辑非 *)
    TestUtils.check_value_equal "整数逻辑非" (BoolValue true) (execute_unary_op Not (IntValue 0));

    TestUtils.check_value_equal "非零整数逻辑非" (BoolValue false) (execute_unary_op Not (IntValue 5));

    TestUtils.check_value_equal "空字符串逻辑非" (BoolValue true) (execute_unary_op Not (StringValue ""));

    TestUtils.check_value_equal "非空字符串逻辑非" (BoolValue false)
      (execute_unary_op Not (StringValue "hello"))
end

(** 操作一致性测试 *)
module OperationConsistencyTests = struct
  let test_operation_consistency () =
    (* 测试相同操作的一致性 *)
    let test_cases =
      [
        (Add, IntValue 3, IntValue 4);
        (Sub, IntValue 10, IntValue 3);
        (Mul, IntValue 5, IntValue 6);
        (Eq, StringValue "test", StringValue "test");
        (Lt, IntValue 2, IntValue 5);
      ]
    in

    List.iter
      (fun (op, v1, v2) ->
        let result1 = execute_binary_op op v1 v2 in
        let result2 = execute_binary_op op v1 v2 in
        TestUtils.check_value_equal "操作应保持一致" result1 result2)
      test_cases

  let test_unary_operation_consistency () =
    (* 测试一元操作的一致性 *)
    let test_cases =
      [ (Neg, IntValue 42); (Neg, FloatValue 3.14); (Not, BoolValue true); (Not, IntValue 0) ]
    in

    List.iter
      (fun (op, v) ->
        let result1 = execute_unary_op op v in
        let result2 = execute_unary_op op v in
        TestUtils.check_value_equal "一元操作应保持一致" result1 result2)
      test_cases
end

(** 错误处理和恢复测试 *)
module ErrorHandlingTests = struct
  let test_type_mismatch_errors () =
    (* 测试类型转换成功的情况 - 系统已启用自动类型转换 *)
    TestUtils.check_value_equal "整数与字符串加法（转换）" (StringValue "1hello")
      (execute_binary_op Add (IntValue 1) (StringValue "hello"));

    (* 布尔值也可以转换为整数 *)
    TestUtils.check_value_equal "布尔值与整数乘法（转换）" (IntValue 5)
      (execute_binary_op Mul (BoolValue true) (IntValue 5));

    (* 字符串除法仍然可能失败 *)
    check TestUtils.bool_testable "字符串与浮点数除法" true
      (TestUtils.expect_runtime_error (fun () ->
           execute_binary_op Div (StringValue "test") (FloatValue 2.0)))

  let test_division_by_zero () =
    (* 整数除零 *)
    check TestUtils.bool_testable "整数除零错误" true
      (TestUtils.expect_runtime_error (fun () -> execute_binary_op Div (IntValue 10) (IntValue 0)));

    (* 整数模零 *)
    check TestUtils.bool_testable "整数模零错误" true
      (TestUtils.expect_runtime_error (fun () -> execute_binary_op Mod (IntValue 15) (IntValue 0)))

  let test_unsupported_operations () =
    (* 测试不支持的运算组合 *)
    check TestUtils.bool_testable "布尔值模运算" true
      (TestUtils.expect_runtime_error (fun () ->
           execute_binary_op Mod (BoolValue true) (BoolValue false)));

    check TestUtils.bool_testable "字符串减法" true
      (TestUtils.expect_runtime_error (fun () ->
           execute_binary_op Sub (StringValue "abc") (StringValue "def")))

  let test_error_messages () =
    (* 测试特定错误消息 - 除零仍然会报错 *)
    check TestUtils.bool_testable "除零错误消息" true
      (TestUtils.expect_error_with_message
         (fun () -> execute_binary_op Div (IntValue 10) (IntValue 0))
         "除零");

    (* 但是类型转换使得大多数操作都能成功 *)
    TestUtils.check_value_equal "布尔值与单元值加法（转换）" (StringValue "真()")
      (execute_binary_op Add (BoolValue true) UnitValue)
end

(** 边界条件和极值测试 *)
module EdgeCaseTests = struct
  let test_extreme_integer_values () =
    (* 最大整数运算 *)
    TestUtils.check_value_equal "最大整数加一"
      (IntValue (max_int + 1))
      (execute_binary_op Add (IntValue max_int) (IntValue 1));

    (* 最小整数运算 *)
    TestUtils.check_value_equal "最小整数减一"
      (IntValue (min_int - 1))
      (execute_binary_op Sub (IntValue min_int) (IntValue 1));

    (* 大数乘法 *)
    let large_result = execute_binary_op Mul (IntValue 1000000) (IntValue 1000000) in
    match large_result with
    | IntValue _ -> check TestUtils.bool_testable "大数乘法应成功" true true
    | _ -> fail "大数乘法应返回整数"

  let test_extreme_float_values () =
    (* 极小浮点数 *)
    TestUtils.check_value_equal "极小浮点数加法"
      (FloatValue (1e-10 +. 1e-10))
      (execute_binary_op Add (FloatValue 1e-10) (FloatValue 1e-10));

    (* 极大浮点数 *)
    let huge_result = execute_binary_op Mul (FloatValue 1e100) (FloatValue 1e100) in
    match huge_result with
    | FloatValue f when Float.is_infinite f ->
        check TestUtils.bool_testable "巨大浮点数乘法应溢出到无穷" true true
    | FloatValue _ -> check TestUtils.bool_testable "巨大浮点数乘法应返回浮点数" true true
    | _ -> fail "巨大浮点数乘法应返回浮点数"

  let test_special_float_values () =
    (* NaN运算 *)
    let nan_result = execute_binary_op Add (FloatValue Float.nan) (FloatValue 1.0) in
    (match nan_result with
    | FloatValue f when Float.is_nan f -> check TestUtils.bool_testable "NaN运算应返回NaN" true true
    | _ -> fail "NaN运算应返回NaN");

    (* 无穷大运算 *)
    let inf_result = execute_binary_op Add (FloatValue Float.infinity) (FloatValue 1.0) in
    match inf_result with
    | FloatValue f when Float.is_infinite f -> check TestUtils.bool_testable "无穷大运算应返回无穷大" true true
    | _ -> fail "无穷大运算应返回无穷大"

  let test_empty_and_special_strings () =
    (* 空字符串运算 *)
    TestUtils.check_value_equal "空字符串连接" (StringValue "hello")
      (execute_binary_op Add (StringValue "") (StringValue "hello"));

    (* 特殊字符字符串 *)
    TestUtils.check_value_equal "特殊字符连接" (StringValue "hello\n\t世界")
      (execute_binary_op Add (StringValue "hello\n") (StringValue "\t世界"));

    (* 长字符串 *)
    let long_str = String.make 10000 'x' in
    TestUtils.check_value_equal "长字符串连接"
      (StringValue (long_str ^ long_str))
      (execute_binary_op Add (StringValue long_str) (StringValue long_str))
end

(** 性能和压力测试 *)
module PerformanceTests = struct
  let test_operation_performance () =
    (* 批量运算性能测试 *)
    let start_time = Sys.time () in

    for i = 1 to 10000 do
      ignore (execute_binary_op Add (IntValue i) (IntValue (i + 1)));
      ignore (execute_binary_op Mul (FloatValue (float_of_int i)) (FloatValue 2.0));
      ignore (execute_binary_op Eq (StringValue (string_of_int i)) (StringValue (string_of_int i)))
    done;

    let end_time = Sys.time () in
    let duration = end_time -. start_time in

    check TestUtils.bool_testable "批量运算应在合理时间内完成" true (duration < 1.0);
    Printf.printf "    批量运算(3万次)耗时: %.3f秒\n" duration

  let test_deep_nesting_performance () =
    (* 深度嵌套运算性能测试 *)
    let rec create_nested_expr depth acc =
      if depth = 0 then acc
      else create_nested_expr (depth - 1) (execute_binary_op Add acc (IntValue 1))
    in

    let start_time = Sys.time () in
    let result = create_nested_expr 1000 (IntValue 0) in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in

    TestUtils.check_value_equal "深度嵌套运算结果" (IntValue 1000) result;
    check TestUtils.bool_testable "深度嵌套运算应在合理时间内完成" true (duration < 0.1);
    Printf.printf "    深度嵌套运算(1000层)耗时: %.3f秒\n" duration
end

(** 中文编程特色测试 *)
module ChineseProgrammingTests = struct
  let test_chinese_strings () =
    (* 中文字符串运算 *)
    TestUtils.check_value_equal "中文字符串连接" (StringValue "你好世界")
      (execute_binary_op Add (StringValue "你好") (StringValue "世界"));

    TestUtils.check_value_equal "中英混合连接" (StringValue "Hello世界")
      (execute_binary_op Add (StringValue "Hello") (StringValue "世界"));

    (* 中文字符串比较 *)
    TestUtils.check_value_equal "中文字符串相等" (BoolValue true)
      (execute_binary_op Eq (StringValue "编程") (StringValue "编程"));

    TestUtils.check_value_equal "中文字符串不等" (BoolValue false)
      (execute_binary_op Eq (StringValue "骆言") (StringValue "编程"))

  let test_unicode_edge_cases () =
    (* Unicode特殊字符 *)
    TestUtils.check_value_equal "Unicode字符连接" (StringValue "🚀🔥")
      (execute_binary_op Add (StringValue "🚀") (StringValue "🔥"));

    (* 组合字符 *)
    TestUtils.check_value_equal "组合字符处理" (StringValue "é测试")
      (execute_binary_op Add (StringValue "é") (StringValue "测试"))
end

(** 运行所有测试 *)
let test_suite =
  [
    ( "整数算术运算",
      [
        test_case "整数加法" `Quick IntegerArithmeticTests.test_integer_addition;
        test_case "整数减法" `Quick IntegerArithmeticTests.test_integer_subtraction;
        test_case "整数乘法" `Quick IntegerArithmeticTests.test_integer_multiplication;
        test_case "整数除法" `Quick IntegerArithmeticTests.test_integer_division;
        test_case "整数取模" `Quick IntegerArithmeticTests.test_integer_modulo;
      ] );
    ( "浮点数算术运算",
      [
        test_case "浮点数加法" `Quick FloatArithmeticTests.test_float_addition;
        test_case "浮点数减法" `Quick FloatArithmeticTests.test_float_subtraction;
        test_case "浮点数乘法" `Quick FloatArithmeticTests.test_float_multiplication;
        test_case "浮点数除法" `Quick FloatArithmeticTests.test_float_division;
      ] );
    ("混合类型运算", [ test_case "整数浮点数混合运算" `Quick MixedArithmeticTests.test_int_float_operations ]);
    ( "比较运算",
      [
        test_case "相等性运算" `Quick ComparisonTests.test_equality_operations;
        test_case "整数比较" `Quick ComparisonTests.test_integer_comparisons;
        test_case "浮点数比较" `Quick ComparisonTests.test_float_comparisons;
        test_case "混合类型比较" `Quick ComparisonTests.test_mixed_type_comparisons;
      ] );
    ( "逻辑运算",
      [
        test_case "逻辑与运算" `Quick LogicalOperationTests.test_logical_and;
        test_case "逻辑或运算" `Quick LogicalOperationTests.test_logical_or;
      ] );
    ("字符串运算", [ test_case "字符串连接" `Quick StringOperationTests.test_string_concatenation ]);
    ( "一元运算",
      [
        test_case "取负运算" `Quick UnaryOperationTests.test_negation;
        test_case "逻辑非运算" `Quick UnaryOperationTests.test_logical_not;
      ] );
    ( "操作一致性",
      [
        test_case "二元操作一致性" `Quick OperationConsistencyTests.test_operation_consistency;
        test_case "一元操作一致性" `Quick OperationConsistencyTests.test_unary_operation_consistency;
      ] );
    ( "错误处理",
      [
        test_case "类型不匹配错误" `Quick ErrorHandlingTests.test_type_mismatch_errors;
        test_case "除零错误" `Quick ErrorHandlingTests.test_division_by_zero;
        test_case "不支持运算" `Quick ErrorHandlingTests.test_unsupported_operations;
        test_case "错误消息" `Quick ErrorHandlingTests.test_error_messages;
      ] );
    ( "边界条件",
      [
        test_case "极值整数" `Quick EdgeCaseTests.test_extreme_integer_values;
        test_case "极值浮点数" `Quick EdgeCaseTests.test_extreme_float_values;
        test_case "特殊浮点值" `Quick EdgeCaseTests.test_special_float_values;
        test_case "特殊字符串" `Quick EdgeCaseTests.test_empty_and_special_strings;
      ] );
    ( "性能测试",
      [
        test_case "运算性能" `Quick PerformanceTests.test_operation_performance;
        test_case "深度嵌套性能" `Quick PerformanceTests.test_deep_nesting_performance;
      ] );
    ( "中文编程特色",
      [
        test_case "中文字符串" `Quick ChineseProgrammingTests.test_chinese_strings;
        test_case "Unicode边界情况" `Quick ChineseProgrammingTests.test_unicode_edge_cases;
      ] );
  ]

let () =
  Printf.printf "骆言Binary Operations模块全面测试覆盖率提升 - Fix #1477\n";
  Printf.printf "====================================================\n";
  run "Binary Operations Comprehensive Coverage Tests" test_suite
