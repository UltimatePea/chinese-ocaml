(** 二元运算模块简化测试覆盖率提升 - Fix #2124

    专注于提升binary_operations.ml模块测试覆盖率从61.68%到80%+ 通过公共API测试关键路径，避免复杂的内部函数测试

    Author: Whisky, PR Worker Agent
    @version 1.0
    @since 2025-08-02 Fix #2124 核心模块测试覆盖率提升优化 *)

open Alcotest
open Yyocamlc_lib
open Ast
open Binary_operations
open Value_operations

(** 值的格式化函数 *)
let pp_value fmt value = Format.fprintf fmt "%s" (Value_operations.value_to_string value)

(** 期望运行时错误的工具函数 *)
let expect_runtime_error desc f =
  try
    let _ = f () in
    fail (desc ^ ": 期望运行时错误但未抛出")
  with
  | RuntimeError _ -> () (* 预期的错误 *)
  | Yyocamlc_lib.Compiler_errors_types.CompilerError _ -> () (* 编译器错误也接受 *)
  | e -> fail (desc ^ ": 意外的异常类型: " ^ Printexc.to_string e)

(** 测试除零错误处理 *)
let test_division_by_zero () =
  (* 整数除零 *)
  expect_runtime_error "整数除零应抛出错误" (fun () -> execute_binary_op Div (IntValue 5) (IntValue 0));

  (* 取模零 *)
  expect_runtime_error "取模零应抛出错误" (fun () -> execute_binary_op Mod (IntValue 5) (IntValue 0))

(** 测试特殊数值运算 *)
let test_special_numeric_values () =
  (* 大数运算 *)
  let large_int = IntValue 1000000 in
  let result_large = execute_binary_op Add large_int (IntValue 1) in
  check (testable pp_value runtime_value_equal) "大数加法" (IntValue 1000001) result_large;

  (* 负数运算 *)
  let negative_result = execute_binary_op Sub (IntValue 0) (IntValue 5) in
  check (testable pp_value runtime_value_equal) "负数减法" (IntValue (-5)) negative_result;

  (* 浮点数精度运算 *)
  let float_result = execute_binary_op Mul (FloatValue 0.1) (FloatValue 3.0) in
  check bool "浮点数乘法结果应接近0.3" true
    (match float_result with FloatValue f -> abs_float (f -. 0.3) < 0.0001 | _ -> false)

(** 测试字符串运算边界情况 *)
let test_string_operations_edge_cases () =
  (* 空字符串运算 *)
  let empty_concat = execute_binary_op Add (StringValue "") (StringValue "test") in
  check (testable pp_value runtime_value_equal) "空字符串连接" (StringValue "test") empty_concat;

  (* 长字符串运算 *)
  let long_str = String.make 100 'x' in
  let long_result = execute_binary_op Concat (StringValue long_str) (StringValue "end") in
  check
    (testable pp_value runtime_value_equal)
    "长字符串连接"
    (StringValue (long_str ^ "end"))
    long_result;

  (* 特殊字符运算 *)
  let special_result = execute_binary_op Add (StringValue "测试") (StringValue "中文") in
  check (testable pp_value runtime_value_equal) "中文字符串连接" (StringValue "测试中文") special_result

(** 测试类型不匹配错误 *)
let test_type_mismatch_errors () =
  (* 布尔值与字符串的不支持运算 *)
  expect_runtime_error "布尔值与字符串除法应失败" (fun () ->
      execute_binary_op Div (BoolValue true) (StringValue "test"));

  (* 单元值运算 *)
  expect_runtime_error "单元值乘法应失败" (fun () -> execute_binary_op Mul UnitValue (IntValue 5));

  (* 列表值运算 *)
  expect_runtime_error "列表值减法应失败" (fun () ->
      execute_binary_op Sub (ListValue [ IntValue 1 ]) (IntValue 2))

(** 测试一元运算的完整覆盖 *)
let test_unary_operations_comprehensive () =
  (* 整数取负 *)
  let neg_int = execute_unary_op Neg (IntValue 42) in
  check (testable pp_value runtime_value_equal) "整数取负" (IntValue (-42)) neg_int;

  (* 零取负 *)
  let neg_zero = execute_unary_op Neg (IntValue 0) in
  check (testable pp_value runtime_value_equal) "零取负" (IntValue 0) neg_zero;

  (* 负数取负 *)
  let neg_negative = execute_unary_op Neg (IntValue (-10)) in
  check (testable pp_value runtime_value_equal) "负数取负" (IntValue 10) neg_negative;

  (* 浮点数取负 *)
  let neg_float = execute_unary_op Neg (FloatValue 3.14) in
  check (testable pp_value runtime_value_equal) "浮点数取负" (FloatValue (-3.14)) neg_float;

  (* 布尔值逻辑非 *)
  let not_true = execute_unary_op Not (BoolValue true) in
  check (testable pp_value runtime_value_equal) "真值逻辑非" (BoolValue false) not_true;

  let not_false = execute_unary_op Not (BoolValue false) in
  check (testable pp_value runtime_value_equal) "假值逻辑非" (BoolValue true) not_false;

  (* 非布尔值的逻辑非（通过value_to_bool转换） *)
  let not_zero = execute_unary_op Not (IntValue 0) in
  check (testable pp_value runtime_value_equal) "零值逻辑非" (BoolValue true) not_zero;

  let not_nonzero = execute_unary_op Not (IntValue 5) in
  check (testable pp_value runtime_value_equal) "非零值逻辑非" (BoolValue false) not_nonzero;

  (* 字符串逻辑非 *)
  let not_empty_str = execute_unary_op Not (StringValue "") in
  check (testable pp_value runtime_value_equal) "空字符串逻辑非" (BoolValue true) not_empty_str;

  let not_nonempty_str = execute_unary_op Not (StringValue "test") in
  check (testable pp_value runtime_value_equal) "非空字符串逻辑非" (BoolValue false) not_nonempty_str

(** 测试不支持的一元运算 *)
let test_unsupported_unary_operations () =
  (* 字符串取负 *)
  expect_runtime_error "字符串取负应失败" (fun () -> execute_unary_op Neg (StringValue "test"));

  (* 列表取负 *)
  expect_runtime_error "列表取负应失败" (fun () -> execute_unary_op Neg (ListValue [ IntValue 1 ]))

(** 测试比较运算的边界情况 *)
let test_comparison_edge_cases () =
  (* 相等性测试 *)
  let eq_same = execute_binary_op Eq (IntValue 5) (IntValue 5) in
  check (testable pp_value runtime_value_equal) "相同整数相等" (BoolValue true) eq_same;

  let eq_different = execute_binary_op Eq (IntValue 5) (IntValue 3) in
  check (testable pp_value runtime_value_equal) "不同整数不相等" (BoolValue false) eq_different;

  (* 不等性测试 *)
  let neq_same = execute_binary_op Neq (StringValue "test") (StringValue "test") in
  check (testable pp_value runtime_value_equal) "相同字符串不等性" (BoolValue false) neq_same;

  let neq_different = execute_binary_op Neq (StringValue "test") (StringValue "other") in
  check (testable pp_value runtime_value_equal) "不同字符串不等性" (BoolValue true) neq_different;

  (* 类型间比较 *)
  let eq_different_types = execute_binary_op Eq (IntValue 5) (StringValue "5") in
  check (testable pp_value runtime_value_equal) "不同类型相等性" (BoolValue false) eq_different_types

(** 测试逻辑运算的特殊情况 *)
let test_logical_operations_special_cases () =
  (* 不同类型的逻辑运算（通过value_to_bool转换） *)
  let and_int_bool = execute_binary_op And (IntValue 1) (BoolValue true) in
  check (testable pp_value runtime_value_equal) "整数与布尔值逻辑与" (BoolValue true) and_int_bool;

  let or_zero_false = execute_binary_op Or (IntValue 0) (BoolValue false) in
  check (testable pp_value runtime_value_equal) "零与假值逻辑或" (BoolValue false) or_zero_false;

  let and_string_unit = execute_binary_op And (StringValue "test") UnitValue in
  check (testable pp_value runtime_value_equal) "字符串与单元值逻辑与" (BoolValue false) and_string_unit

(** 测试算术运算的边界值 *)
let test_arithmetic_boundary_values () =
  (* 最大整数运算（在OCaml范围内） *)
  let max_int_sub = execute_binary_op Sub (IntValue max_int) (IntValue 1) in
  check (testable pp_value runtime_value_equal) "最大整数减一" (IntValue (max_int - 1)) max_int_sub;

  (* 最小整数运算 *)
  let min_int_add = execute_binary_op Add (IntValue min_int) (IntValue 1) in
  check (testable pp_value runtime_value_equal) "最小整数加一" (IntValue (min_int + 1)) min_int_add;

  (* 浮点数零运算 *)
  let float_zero_mul = execute_binary_op Mul (FloatValue 0.0) (FloatValue 100.0) in
  check (testable pp_value runtime_value_equal) "零乘以浮点数" (FloatValue 0.0) float_zero_mul

(** 主测试套件 *)
let test_suite () =
  [
    ("除零错误处理测试", `Quick, test_division_by_zero);
    ("特殊数值运算测试", `Quick, test_special_numeric_values);
    ("字符串运算边界情况测试", `Quick, test_string_operations_edge_cases);
    ("类型不匹配错误测试", `Quick, test_type_mismatch_errors);
    ("一元运算完整覆盖测试", `Quick, test_unary_operations_comprehensive);
    ("不支持的一元运算测试", `Quick, test_unsupported_unary_operations);
    ("比较运算边界情况测试", `Quick, test_comparison_edge_cases);
    ("逻辑运算特殊情况测试", `Quick, test_logical_operations_special_cases);
    ("算术运算边界值测试", `Quick, test_arithmetic_boundary_values);
  ]

(** 执行测试 *)
let () =
  Alcotest.run "二元运算简化覆盖率测试 - Fix #2124" [ ("binary_operations_simple_coverage", test_suite ()) ]
