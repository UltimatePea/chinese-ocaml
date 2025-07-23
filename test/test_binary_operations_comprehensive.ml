(** 骆言二元运算模块综合测试套件 - Issue #948 第三阶段执行引擎核心测试补强 *)

open Alcotest
open Yyocamlc_lib
open Ast
open Value_operations
open Binary_operations

(** 测试辅助函数模块 *)
module TestUtils = struct
  (** 检查二元运算结果 *)
  let check_binary_op_result desc op left_val right_val expected =
    let actual = execute_binary_op op left_val right_val in
    check string desc (value_to_string expected) (value_to_string actual)

  (** 检查二元运算是否抛出异常 *)
  let check_binary_op_error desc op left_val right_val expected_error =
    try
      ignore (execute_binary_op op left_val right_val);
      failwith ("Expected exception was not raised: " ^ expected_error)
    with
    | RuntimeError msg -> check string desc expected_error msg
    | Yyocamlc_lib.Compiler_errors_types.CompilerError _ ->
        (* 通过CompilerError，接受这种异常类型 *)
        ()
    | e -> failwith ("Unexpected exception type: " ^ Printexc.to_string e)

  (** 检查一元运算结果 *)
  let check_unary_op_result desc op value expected =
    let actual = execute_unary_op op value in
    check string desc (value_to_string expected) (value_to_string actual)

  (** 检查一元运算是否抛出异常 *)
  let check_unary_op_error desc op value expected_error =
    try
      ignore (execute_unary_op op value);
      failwith ("Expected exception was not raised: " ^ expected_error)
    with
    | RuntimeError msg -> check string desc expected_error msg
    | Yyocamlc_lib.Compiler_errors_types.CompilerError _ ->
        (* 通过CompilerError，接受这种异常类型 *)
        ()
    | e -> failwith ("Unexpected exception type: " ^ Printexc.to_string e)
end

(** 整数算术运算测试模块 *)
module IntegerArithmeticTests = struct
  (** 测试整数基础算术运算 *)
  let test_basic_integer_arithmetic () =
    (* 整数加法运算 *)
    TestUtils.check_binary_op_result "整数加法：10 + 5" Add (IntValue 10) (IntValue 5) (IntValue 15);
    TestUtils.check_binary_op_result "整数加法：负数相加" Add (IntValue (-5)) (IntValue (-3)) (IntValue (-8));
    TestUtils.check_binary_op_result "整数加法：正负数相加" Add (IntValue 7) (IntValue (-3)) (IntValue 4);
    TestUtils.check_binary_op_result "整数加法：零值相加" Add (IntValue 0) (IntValue 42) (IntValue 42);

    (* 整数减法运算 *)
    TestUtils.check_binary_op_result "整数减法：15 - 7" Sub (IntValue 15) (IntValue 7) (IntValue 8);
    TestUtils.check_binary_op_result "整数减法：负数相减" Sub (IntValue (-10)) (IntValue (-3))
      (IntValue (-7));
    TestUtils.check_binary_op_result "整数减法：正数减负数" Sub (IntValue 5) (IntValue (-3)) (IntValue 8);
    TestUtils.check_binary_op_result "整数减法：减去零" Sub (IntValue 42) (IntValue 0) (IntValue 42);

    (* 整数乘法运算 *)
    TestUtils.check_binary_op_result "整数乘法：6 * 7" Mul (IntValue 6) (IntValue 7) (IntValue 42);
    TestUtils.check_binary_op_result "整数乘法：负数相乘" Mul (IntValue (-4)) (IntValue (-3)) (IntValue 12);
    TestUtils.check_binary_op_result "整数乘法：正负数相乘" Mul (IntValue 5) (IntValue (-2)) (IntValue (-10));
    TestUtils.check_binary_op_result "整数乘法：乘以零" Mul (IntValue 42) (IntValue 0) (IntValue 0);
    TestUtils.check_binary_op_result "整数乘法：乘以一" Mul (IntValue 42) (IntValue 1) (IntValue 42)

  (** 测试整数除法和取模运算 *)
  let test_integer_division_modulo () =
    (* 整数除法运算 *)
    TestUtils.check_binary_op_result "整数除法：20 / 4" Div (IntValue 20) (IntValue 4) (IntValue 5);
    TestUtils.check_binary_op_result "整数除法：15 / 3" Div (IntValue 15) (IntValue 3) (IntValue 5);
    TestUtils.check_binary_op_result "整数除法：负数除法" Div (IntValue (-12)) (IntValue 3) (IntValue (-4));
    TestUtils.check_binary_op_result "整数除法：负数除负数" Div (IntValue (-15)) (IntValue (-3)) (IntValue 5);

    (* 整数取模运算 *)
    TestUtils.check_binary_op_result "整数取模：17 % 5" Mod (IntValue 17) (IntValue 5) (IntValue 2);
    TestUtils.check_binary_op_result "整数取模：10 % 3" Mod (IntValue 10) (IntValue 3) (IntValue 1);
    TestUtils.check_binary_op_result "整数取模：整除情况" Mod (IntValue 15) (IntValue 5) (IntValue 0);
    TestUtils.check_binary_op_result "整数取模：负数取模" Mod (IntValue (-17)) (IntValue 5) (IntValue (-2));

    (* 除零和取模零错误 *)
    TestUtils.check_binary_op_error "整数除零错误" Div (IntValue 10) (IntValue 0) "除零";
    TestUtils.check_binary_op_error "整数取模零错误" Mod (IntValue 10) (IntValue 0) "取模零"

  (** 测试整数边界条件 *)
  let test_integer_boundary_conditions () =
    (* 大数运算 *)
    TestUtils.check_binary_op_result "大整数加法" Add (IntValue 1000000) (IntValue 999999)
      (IntValue 1999999);
    TestUtils.check_binary_op_result "大整数乘法" Mul (IntValue 1000) (IntValue 1000) (IntValue 1000000);

    (* 最小值运算 *)
    TestUtils.check_binary_op_result "最小整数加一" Add (IntValue min_int) (IntValue 1)
      (IntValue (min_int + 1));
    TestUtils.check_binary_op_result "最大整数减一" Sub (IntValue max_int) (IntValue 1)
      (IntValue (max_int - 1))
end

(** 浮点数算术运算测试模块 *)
module FloatArithmeticTests = struct
  (** 测试浮点数基础算术运算 *)
  let test_basic_float_arithmetic () =
    (* 浮点数加法运算 *)
    TestUtils.check_binary_op_result "浮点数加法：3.5 + 2.1" Add (FloatValue 3.5) (FloatValue 2.1)
      (FloatValue 5.6);
    TestUtils.check_binary_op_result "浮点数加法：负数相加" Add (FloatValue (-2.5)) (FloatValue (-1.5))
      (FloatValue (-4.0));
    TestUtils.check_binary_op_result "浮点数加法：正负数相加" Add (FloatValue 7.5) (FloatValue (-2.5))
      (FloatValue 5.0);

    (* 浮点数减法运算 *)
    TestUtils.check_binary_op_result "浮点数减法：10.5 - 3.2" Sub (FloatValue 10.5) (FloatValue 3.2)
      (FloatValue 7.3);
    TestUtils.check_binary_op_result "浮点数减法：负数相减" Sub (FloatValue (-5.5)) (FloatValue (-2.2))
      (FloatValue (-3.3));

    (* 浮点数乘法运算 *)
    TestUtils.check_binary_op_result "浮点数乘法：2.5 * 4.0" Mul (FloatValue 2.5) (FloatValue 4.0)
      (FloatValue 10.0);
    TestUtils.check_binary_op_result "浮点数乘法：负数相乘" Mul (FloatValue (-2.5)) (FloatValue (-2.0))
      (FloatValue 5.0);

    (* 浮点数除法运算 *)
    TestUtils.check_binary_op_result "浮点数除法：15.0 / 3.0" Div (FloatValue 15.0) (FloatValue 3.0)
      (FloatValue 5.0);
    TestUtils.check_binary_op_result "浮点数除法：负数除法" Div (FloatValue (-12.0)) (FloatValue 4.0)
      (FloatValue (-3.0))

  (** 测试浮点数特殊值 *)
  let test_float_special_values () =
    (* 零值运算 *)
    TestUtils.check_binary_op_result "浮点数加零" Add (FloatValue 3.14) (FloatValue 0.0)
      (FloatValue 3.14);
    TestUtils.check_binary_op_result "浮点数乘零" Mul (FloatValue 3.14) (FloatValue 0.0) (FloatValue 0.0);

    (* 一值运算 *)
    TestUtils.check_binary_op_result "浮点数乘一" Mul (FloatValue 3.14) (FloatValue 1.0)
      (FloatValue 3.14);
    TestUtils.check_binary_op_result "浮点数除一" Div (FloatValue 3.14) (FloatValue 1.0)
      (FloatValue 3.14);

    (* 小数精度测试 *)
    TestUtils.check_binary_op_result "小数精度加法" Add (FloatValue 0.1) (FloatValue 0.2) (FloatValue 0.3);
    TestUtils.check_binary_op_result "小数精度乘法" Mul (FloatValue 0.1) (FloatValue 0.1)
      (FloatValue 0.01)
end

(** 字符串运算测试模块 *)
module StringOperationTests = struct
  (** 测试字符串连接运算 *)
  let test_string_concatenation () =
    (* 基础字符串连接 *)
    TestUtils.check_binary_op_result "中文字符串连接" Add (StringValue "你好") (StringValue "世界")
      (StringValue "你好世界");
    TestUtils.check_binary_op_result "英文字符串连接" Add (StringValue "Hello") (StringValue "World")
      (StringValue "HelloWorld");
    TestUtils.check_binary_op_result "中英文字符串连接" Add (StringValue "骆言") (StringValue "Language")
      (StringValue "骆言Language");

    (* 空字符串连接 *)
    TestUtils.check_binary_op_result "空字符串与非空字符串连接" Add (StringValue "") (StringValue "测试")
      (StringValue "测试");
    TestUtils.check_binary_op_result "非空字符串与空字符串连接" Add (StringValue "测试") (StringValue "")
      (StringValue "测试");
    TestUtils.check_binary_op_result "两个空字符串连接" Add (StringValue "") (StringValue "")
      (StringValue "");

    (* 特殊字符串连接 *)
    TestUtils.check_binary_op_result "包含数字的字符串连接" Add (StringValue "版本") (StringValue "1.0")
      (StringValue "版本1.0");
    TestUtils.check_binary_op_result "包含符号的字符串连接" Add (StringValue "错误：") (StringValue "找不到文件")
      (StringValue "错误：找不到文件");

    (* 显式Concat运算符测试 *)
    TestUtils.check_binary_op_result "Concat运算符字符串连接" Concat (StringValue "前缀") (StringValue "后缀")
      (StringValue "前缀后缀")

  (** 测试字符串运算错误情况 *)
  let test_string_operation_errors () =
    (* 字符串不支持的运算 *)
    TestUtils.check_binary_op_error "字符串减法错误" Sub (StringValue "你好") (StringValue "世界") "非字符串运算";
    TestUtils.check_binary_op_error "字符串乘法错误" Mul (StringValue "测试") (StringValue "文本") "非字符串运算";
    TestUtils.check_binary_op_error "字符串除法错误" Div (StringValue "测试") (StringValue "文本") "非字符串运算";
    TestUtils.check_binary_op_error "字符串取模错误" Mod (StringValue "测试") (StringValue "文本") "非字符串运算"
end

(** 比较运算测试模块 *)
module ComparisonOperationTests = struct
  (** 测试相等性比较运算 *)
  let test_equality_comparisons () =
    (* 整数相等性比较 *)
    TestUtils.check_binary_op_result "整数相等比较" Eq (IntValue 42) (IntValue 42) (BoolValue true);
    TestUtils.check_binary_op_result "整数不相等比较" Eq (IntValue 42) (IntValue 24) (BoolValue false);
    TestUtils.check_binary_op_result "整数不等于比较" Neq (IntValue 42) (IntValue 24) (BoolValue true);
    TestUtils.check_binary_op_result "整数不等于相等值" Neq (IntValue 42) (IntValue 42) (BoolValue false);

    (* 浮点数相等性比较 *)
    TestUtils.check_binary_op_result "浮点数相等比较" Eq (FloatValue 3.14) (FloatValue 3.14)
      (BoolValue true);
    TestUtils.check_binary_op_result "浮点数不相等比较" Eq (FloatValue 3.14) (FloatValue 2.71)
      (BoolValue false);

    (* 字符串相等性比较 *)
    TestUtils.check_binary_op_result "字符串相等比较" Eq (StringValue "你好") (StringValue "你好")
      (BoolValue true);
    TestUtils.check_binary_op_result "字符串不相等比较" Eq (StringValue "你好") (StringValue "再见")
      (BoolValue false);

    (* 布尔值相等性比较 *)
    TestUtils.check_binary_op_result "布尔值相等比较" Eq (BoolValue true) (BoolValue true) (BoolValue true);
    TestUtils.check_binary_op_result "布尔值不相等比较" Eq (BoolValue true) (BoolValue false)
      (BoolValue false);

    (* 单元值相等性比较 *)
    TestUtils.check_binary_op_result "单元值相等比较" Eq UnitValue UnitValue (BoolValue true)

  (** 测试数值顺序比较运算 *)
  let test_ordering_comparisons () =
    (* 整数顺序比较 *)
    TestUtils.check_binary_op_result "整数小于比较" Lt (IntValue 5) (IntValue 10) (BoolValue true);
    TestUtils.check_binary_op_result "整数小于等于比较" Le (IntValue 5) (IntValue 5) (BoolValue true);
    TestUtils.check_binary_op_result "整数大于比较" Gt (IntValue 10) (IntValue 5) (BoolValue true);
    TestUtils.check_binary_op_result "整数大于等于比较" Ge (IntValue 10) (IntValue 10) (BoolValue true);

    (* 浮点数顺序比较 *)
    TestUtils.check_binary_op_result "浮点数小于比较" Lt (FloatValue 2.5) (FloatValue 3.0) (BoolValue true);
    TestUtils.check_binary_op_result "浮点数小于等于比较" Le (FloatValue 3.0) (FloatValue 3.0)
      (BoolValue true);
    TestUtils.check_binary_op_result "浮点数大于比较" Gt (FloatValue 5.5) (FloatValue 3.2) (BoolValue true);
    TestUtils.check_binary_op_result "浮点数大于等于比较" Ge (FloatValue 5.5) (FloatValue 5.5)
      (BoolValue true);

    (* 边界条件测试 *)
    TestUtils.check_binary_op_result "相等值小于比较" Lt (IntValue 5) (IntValue 5) (BoolValue false);
    TestUtils.check_binary_op_result "相等值大于比较" Gt (IntValue 5) (IntValue 5) (BoolValue false);
    TestUtils.check_binary_op_result "负数比较" Lt (IntValue (-5)) (IntValue 0) (BoolValue true);
    TestUtils.check_binary_op_result "负数与负数比较" Gt (IntValue (-2)) (IntValue (-5)) (BoolValue true)

  (** 测试类型不匹配的比较错误 *)
  let test_comparison_type_errors () =
    (* 不同类型比较错误 *)
    TestUtils.check_binary_op_error "字符串与整数小于比较错误" Lt (StringValue "你好") (IntValue 5) "不支持的比较类型";
    TestUtils.check_binary_op_error "布尔值与浮点数大于比较错误" Gt (BoolValue true) (FloatValue 3.14) "不支持的比较类型";
    TestUtils.check_binary_op_error "单元值与整数小于等于比较错误" Le UnitValue (IntValue 10) "不支持的比较类型"
end

(** 逻辑运算测试模块 *)
module LogicalOperationTests = struct
  (** 测试逻辑与运算 *)
  let test_logical_and_operations () =
    (* 布尔值逻辑与 *)
    TestUtils.check_binary_op_result "真与真" And (BoolValue true) (BoolValue true) (BoolValue true);
    TestUtils.check_binary_op_result "真与假" And (BoolValue true) (BoolValue false) (BoolValue false);
    TestUtils.check_binary_op_result "假与真" And (BoolValue false) (BoolValue true) (BoolValue false);
    TestUtils.check_binary_op_result "假与假" And (BoolValue false) (BoolValue false) (BoolValue false);

    (* 其他类型的逻辑与（转换为布尔值） *)
    TestUtils.check_binary_op_result "非零整数与真" And (IntValue 42) (BoolValue true) (BoolValue true);
    TestUtils.check_binary_op_result "零整数与真" And (IntValue 0) (BoolValue true) (BoolValue false);
    TestUtils.check_binary_op_result "非空字符串与真" And (StringValue "测试") (BoolValue true)
      (BoolValue true);
    TestUtils.check_binary_op_result "空字符串与真" And (StringValue "") (BoolValue true)
      (BoolValue false)

  (** 测试逻辑或运算 *)
  let test_logical_or_operations () =
    (* 布尔值逻辑或 *)
    TestUtils.check_binary_op_result "真或真" Or (BoolValue true) (BoolValue true) (BoolValue true);
    TestUtils.check_binary_op_result "真或假" Or (BoolValue true) (BoolValue false) (BoolValue true);
    TestUtils.check_binary_op_result "假或真" Or (BoolValue false) (BoolValue true) (BoolValue true);
    TestUtils.check_binary_op_result "假或假" Or (BoolValue false) (BoolValue false) (BoolValue false);

    (* 其他类型的逻辑或（转换为布尔值） *)
    TestUtils.check_binary_op_result "非零整数或假" Or (IntValue 42) (BoolValue false) (BoolValue true);
    TestUtils.check_binary_op_result "零整数或假" Or (IntValue 0) (BoolValue false) (BoolValue false);
    TestUtils.check_binary_op_result "非空字符串或假" Or (StringValue "测试") (BoolValue false)
      (BoolValue true);
    TestUtils.check_binary_op_result "空字符串或假" Or (StringValue "") (BoolValue false)
      (BoolValue false)
end

(** 一元运算测试模块 *)
module UnaryOperationTests = struct
  (** 测试数值取反运算 *)
  let test_numeric_negation () =
    (* 整数取反 *)
    TestUtils.check_unary_op_result "正整数取反" Neg (IntValue 42) (IntValue (-42));
    TestUtils.check_unary_op_result "负整数取反" Neg (IntValue (-15)) (IntValue 15);
    TestUtils.check_unary_op_result "零取反" Neg (IntValue 0) (IntValue 0);

    (* 浮点数取反 *)
    TestUtils.check_unary_op_result "正浮点数取反" Neg (FloatValue 3.14) (FloatValue (-3.14));
    TestUtils.check_unary_op_result "负浮点数取反" Neg (FloatValue (-2.71)) (FloatValue 2.71);
    TestUtils.check_unary_op_result "零浮点数取反" Neg (FloatValue 0.0) (FloatValue (-0.0))

  (** 测试逻辑取反运算 *)
  let test_logical_negation () =
    (* 布尔值逻辑取反 *)
    TestUtils.check_unary_op_result "真值逻辑取反" Not (BoolValue true) (BoolValue false);
    TestUtils.check_unary_op_result "假值逻辑取反" Not (BoolValue false) (BoolValue true);

    (* 其他类型的逻辑取反（转换为布尔值后取反） *)
    TestUtils.check_unary_op_result "非零整数逻辑取反" Not (IntValue 42) (BoolValue false);
    TestUtils.check_unary_op_result "零整数逻辑取反" Not (IntValue 0) (BoolValue true);
    TestUtils.check_unary_op_result "非空字符串逻辑取反" Not (StringValue "测试") (BoolValue false);
    TestUtils.check_unary_op_result "空字符串逻辑取反" Not (StringValue "") (BoolValue true);
    TestUtils.check_unary_op_result "单元值逻辑取反" Not UnitValue (BoolValue true)

  (** 测试一元运算错误情况 *)
  let test_unary_operation_errors () =
    (* 字符串数值取反错误 *)
    TestUtils.check_unary_op_error "字符串数值取反错误" Neg (StringValue "你好") "不支持的一元运算";

    (* 布尔值数值取反错误 *)
    TestUtils.check_unary_op_error "布尔值数值取反错误" Neg (BoolValue true) "不支持的一元运算"
end

(** 主测试套件 *)
let () =
  run "骆言二元运算模块综合测试"
    [
      ( "整数算术运算测试",
        [
          test_case "整数基础算术运算" `Quick IntegerArithmeticTests.test_basic_integer_arithmetic;
          test_case "整数除法和取模运算" `Quick IntegerArithmeticTests.test_integer_division_modulo;
          test_case "整数边界条件" `Quick IntegerArithmeticTests.test_integer_boundary_conditions;
        ] );
      ( "浮点数算术运算测试",
        [
          test_case "浮点数基础算术运算" `Quick FloatArithmeticTests.test_basic_float_arithmetic;
          test_case "浮点数特殊值" `Quick FloatArithmeticTests.test_float_special_values;
        ] );
      ( "字符串运算测试",
        [
          test_case "字符串连接运算" `Quick StringOperationTests.test_string_concatenation;
          test_case "字符串运算错误情况" `Quick StringOperationTests.test_string_operation_errors;
        ] );
      ( "比较运算测试",
        [
          test_case "相等性比较运算" `Quick ComparisonOperationTests.test_equality_comparisons;
          test_case "数值顺序比较运算" `Quick ComparisonOperationTests.test_ordering_comparisons;
          test_case "比较类型错误" `Quick ComparisonOperationTests.test_comparison_type_errors;
        ] );
      ( "逻辑运算测试",
        [
          test_case "逻辑与运算" `Quick LogicalOperationTests.test_logical_and_operations;
          test_case "逻辑或运算" `Quick LogicalOperationTests.test_logical_or_operations;
        ] );
      ( "一元运算测试",
        [
          test_case "数值取反运算" `Quick UnaryOperationTests.test_numeric_negation;
          test_case "逻辑取反运算" `Quick UnaryOperationTests.test_logical_negation;
          test_case "一元运算错误情况" `Quick UnaryOperationTests.test_unary_operation_errors;
        ] );
    ]
