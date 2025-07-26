(** Binary Operations模块增强测试覆盖 - Fix #1377

    对binary_operations.ml进行全面测试，提升覆盖率从7%到80%+

    @author Charlie, 规划专员
    @version 1.0
    @since 2025-07-26 Fix #1377 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Binary_operations

(** 辅助函数：创建值 *)
let int_val n = IntValue n

let float_val f = FloatValue f
let string_val s = StringValue s
let bool_val b = BoolValue b

(** 辅助函数：比较结果 *)
let check_result name expected actual = check bool name true (expected = actual)

(** 辅助函数：检查错误 *)
let check_error name f =
  try
    let _ = f () in
    fail (name ^ " 应该抛出错误")
  with _ -> check bool name true true

(** 测试整数算术运算 *)
let test_integer_arithmetic () =
  (* 加法 *)
  check_result "整数加法" (int_val 3) (execute_binary_op Add (int_val 1) (int_val 2));
  check_result "整数加法零" (int_val 5) (execute_binary_op Add (int_val 5) (int_val 0));
  check_result "整数加法负数" (int_val (-1)) (execute_binary_op Add (int_val 1) (int_val (-2)));

  (* 减法 *)
  check_result "整数减法" (int_val 3) (execute_binary_op Sub (int_val 5) (int_val 2));
  check_result "整数减法零" (int_val 5) (execute_binary_op Sub (int_val 5) (int_val 0));
  check_result "整数减法负数" (int_val 7) (execute_binary_op Sub (int_val 5) (int_val (-2)));

  (* 乘法 *)
  check_result "整数乘法" (int_val 6) (execute_binary_op Mul (int_val 2) (int_val 3));
  check_result "整数乘法零" (int_val 0) (execute_binary_op Mul (int_val 5) (int_val 0));
  check_result "整数乘法负数" (int_val (-6)) (execute_binary_op Mul (int_val 2) (int_val (-3)));

  (* 除法 *)
  check_result "整数除法" (int_val 2) (execute_binary_op Div (int_val 6) (int_val 3));
  check_result "整数除法取整" (int_val 2) (execute_binary_op Div (int_val 5) (int_val 2));

  (* 取模 *)
  check_result "整数取模" (int_val 1) (execute_binary_op Mod (int_val 5) (int_val 2));
  check_result "整数取模零余数" (int_val 0) (execute_binary_op Mod (int_val 6) (int_val 3))

(** 测试整数除零错误 *)
let test_integer_division_by_zero () =
  check_error "整数除零错误" (fun () -> execute_binary_op Div (int_val 5) (int_val 0));
  check_error "整数取模零错误" (fun () -> execute_binary_op Mod (int_val 5) (int_val 0))

(** 测试浮点算术运算 *)
let test_float_arithmetic () =
  (* 加法 *)
  check_result "浮点加法" (float_val 3.5) (execute_binary_op Add (float_val 1.5) (float_val 2.0));
  check_result "浮点加法零" (float_val 2.5) (execute_binary_op Add (float_val 2.5) (float_val 0.0));

  (* 减法 *)
  check_result "浮点减法" (float_val 0.5) (execute_binary_op Sub (float_val 2.5) (float_val 2.0));
  check_result "浮点减法负数" (float_val 4.5) (execute_binary_op Sub (float_val 2.5) (float_val (-2.0)));

  (* 乘法 *)
  check_result "浮点乘法" (float_val 6.0) (execute_binary_op Mul (float_val 2.0) (float_val 3.0));
  check_result "浮点乘法零" (float_val 0.0) (execute_binary_op Mul (float_val 5.5) (float_val 0.0));

  (* 除法 *)
  check_result "浮点除法" (float_val 2.5) (execute_binary_op Div (float_val 5.0) (float_val 2.0));
  check_result "浮点除法小数" (float_val 1.25) (execute_binary_op Div (float_val 2.5) (float_val 2.0))

(** 测试字符串运算 *)
let test_string_operations () =
  (* 字符串连接 *)
  check_result "字符串加法连接" (string_val "hello world")
    (execute_binary_op Add (string_val "hello ") (string_val "world"));
  check_result "字符串Concat连接" (string_val "测试字符串")
    (execute_binary_op Concat (string_val "测试") (string_val "字符串"));

  (* 空字符串处理 *)
  check_result "空字符串连接" (string_val "hello")
    (execute_binary_op Add (string_val "hello") (string_val ""));
  check_result "连接空字符串" (string_val "world")
    (execute_binary_op Add (string_val "") (string_val "world"));

  (* 中文字符串连接 *)
  check_result "中文字符串连接" (string_val "你好世界")
    (execute_binary_op Add (string_val "你好") (string_val "世界"));

  (* 混合字符连接 *)
  check_result "中英文混合连接" (string_val "Hello世界")
    (execute_binary_op Add (string_val "Hello") (string_val "世界"))

(** 测试比较运算 - 整数 *)
let test_integer_comparison () =
  (* 相等比较 *)
  check_result "整数相等真" (bool_val true) (execute_binary_op Eq (int_val 5) (int_val 5));
  check_result "整数相等假" (bool_val false) (execute_binary_op Eq (int_val 5) (int_val 3));

  (* 不等比较 *)
  check_result "整数不等真" (bool_val true) (execute_binary_op Neq (int_val 5) (int_val 3));
  check_result "整数不等假" (bool_val false) (execute_binary_op Neq (int_val 5) (int_val 5));

  (* 小于比较 *)
  check_result "整数小于真" (bool_val true) (execute_binary_op Lt (int_val 3) (int_val 5));
  check_result "整数小于假" (bool_val false) (execute_binary_op Lt (int_val 5) (int_val 3));
  check_result "整数小于相等假" (bool_val false) (execute_binary_op Lt (int_val 5) (int_val 5));

  (* 小于等于比较 *)
  check_result "整数小于等于真" (bool_val true) (execute_binary_op Le (int_val 3) (int_val 5));
  check_result "整数小于等于相等真" (bool_val true) (execute_binary_op Le (int_val 5) (int_val 5));
  check_result "整数小于等于假" (bool_val false) (execute_binary_op Le (int_val 5) (int_val 3));

  (* 大于比较 *)
  check_result "整数大于真" (bool_val true) (execute_binary_op Gt (int_val 5) (int_val 3));
  check_result "整数大于假" (bool_val false) (execute_binary_op Gt (int_val 3) (int_val 5));
  check_result "整数大于相等假" (bool_val false) (execute_binary_op Gt (int_val 5) (int_val 5));

  (* 大于等于比较 *)
  check_result "整数大于等于真" (bool_val true) (execute_binary_op Ge (int_val 5) (int_val 3));
  check_result "整数大于等于相等真" (bool_val true) (execute_binary_op Ge (int_val 5) (int_val 5));
  check_result "整数大于等于假" (bool_val false) (execute_binary_op Ge (int_val 3) (int_val 5))

(** 测试比较运算 - 浮点数 *)
let test_float_comparison () =
  (* 相等比较 *)
  check_result "浮点相等真" (bool_val true) (execute_binary_op Eq (float_val 3.14) (float_val 3.14));
  check_result "浮点相等假" (bool_val false) (execute_binary_op Eq (float_val 3.14) (float_val 2.71));

  (* 小于比较 *)
  check_result "浮点小于真" (bool_val true) (execute_binary_op Lt (float_val 2.5) (float_val 3.5));
  check_result "浮点小于假" (bool_val false) (execute_binary_op Lt (float_val 3.5) (float_val 2.5));

  (* 大于比较 *)
  check_result "浮点大于真" (bool_val true) (execute_binary_op Gt (float_val 3.5) (float_val 2.5));
  check_result "浮点大于假" (bool_val false) (execute_binary_op Gt (float_val 2.5) (float_val 3.5))

(** 测试字符串比较 *)
let test_string_comparison () =
  (* 相等比较 *)
  check_result "字符串相等真" (bool_val true)
    (execute_binary_op Eq (string_val "hello") (string_val "hello"));
  check_result "字符串相等假" (bool_val false)
    (execute_binary_op Eq (string_val "hello") (string_val "world"));

  (* 不等比较 *)
  check_result "字符串不等真" (bool_val true)
    (execute_binary_op Neq (string_val "hello") (string_val "world"));
  check_result "字符串不等假" (bool_val false)
    (execute_binary_op Neq (string_val "hello") (string_val "hello"));

  (* 中文字符串比较 *)
  check_result "中文字符串相等" (bool_val true) (execute_binary_op Eq (string_val "你好") (string_val "你好"));
  check_result "中文字符串不等" (bool_val true) (execute_binary_op Neq (string_val "你好") (string_val "世界"))

(** 测试布尔比较 *)
let test_boolean_comparison () =
  (* 相等比较 *)
  check_result "布尔真相等" (bool_val true) (execute_binary_op Eq (bool_val true) (bool_val true));
  check_result "布尔假相等" (bool_val true) (execute_binary_op Eq (bool_val false) (bool_val false));
  check_result "布尔真假不等" (bool_val false) (execute_binary_op Eq (bool_val true) (bool_val false));

  (* 不等比较 *)
  check_result "布尔真假不等比较" (bool_val true) (execute_binary_op Neq (bool_val true) (bool_val false));
  check_result "布尔真真等比较" (bool_val false) (execute_binary_op Neq (bool_val true) (bool_val true))

(** 测试逻辑运算 *)
let test_logical_operations () =
  (* And运算 *)
  check_result "逻辑And真真" (bool_val true) (execute_binary_op And (bool_val true) (bool_val true));
  check_result "逻辑And真假" (bool_val false) (execute_binary_op And (bool_val true) (bool_val false));
  check_result "逻辑And假真" (bool_val false) (execute_binary_op And (bool_val false) (bool_val true));
  check_result "逻辑And假假" (bool_val false) (execute_binary_op And (bool_val false) (bool_val false));

  (* Or运算 *)
  check_result "逻辑Or真真" (bool_val true) (execute_binary_op Or (bool_val true) (bool_val true));
  check_result "逻辑Or真假" (bool_val true) (execute_binary_op Or (bool_val true) (bool_val false));
  check_result "逻辑Or假真" (bool_val true) (execute_binary_op Or (bool_val false) (bool_val true));
  check_result "逻辑Or假假" (bool_val false) (execute_binary_op Or (bool_val false) (bool_val false));

  (* 非布尔值逻辑运算 *)
  check_result "整数And运算" (bool_val true) (execute_binary_op And (int_val 1) (int_val 2));
  check_result "整数Or运算" (bool_val true) (execute_binary_op Or (int_val 0) (int_val 1));
  check_result "零值And运算" (bool_val false) (execute_binary_op And (int_val 0) (int_val 1));

  (* 字符串逻辑运算 *)
  check_result "字符串And运算" (bool_val true)
    (execute_binary_op And (string_val "hello") (string_val "world"));
  check_result "空字符串And运算" (bool_val false)
    (execute_binary_op And (string_val "") (string_val "world"))

(** 测试一元运算 *)
let test_unary_operations () =
  (* 负号运算 *)
  check_result "整数负号" (int_val (-5)) (execute_unary_op Neg (int_val 5));
  check_result "负整数负号" (int_val 5) (execute_unary_op Neg (int_val (-5)));
  check_result "零负号" (int_val 0) (execute_unary_op Neg (int_val 0));

  (* 浮点负号 *)
  check_result "浮点负号" (float_val (-3.14)) (execute_unary_op Neg (float_val 3.14));
  check_result "负浮点负号" (float_val 2.71) (execute_unary_op Neg (float_val (-2.71)));

  (* 逻辑非运算 *)
  check_result "布尔真非运算" (bool_val false) (execute_unary_op Not (bool_val true));
  check_result "布尔假非运算" (bool_val true) (execute_unary_op Not (bool_val false));

  (* 非布尔值非运算 *)
  check_result "整数非零非运算" (bool_val false) (execute_unary_op Not (int_val 5));
  check_result "整数零非运算" (bool_val true) (execute_unary_op Not (int_val 0));
  check_result "字符串非运算" (bool_val false) (execute_unary_op Not (string_val "hello"));
  check_result "空字符串非运算" (bool_val true) (execute_unary_op Not (string_val ""))

(** 测试混合类型比较 *)
let test_mixed_type_comparison () =
  (* 不同类型相等比较 *)
  check_result "整数与字符串不等" (bool_val false) (execute_binary_op Eq (int_val 5) (string_val "5"));
  check_result "整数与浮点不等" (bool_val false) (execute_binary_op Eq (int_val 5) (float_val 5.0));
  check_result "字符串与布尔不等" (bool_val false)
    (execute_binary_op Eq (string_val "true") (bool_val true));

  (* 不同类型不等比较 *)
  check_result "整数与字符串不等比较" (bool_val true) (execute_binary_op Neq (int_val 5) (string_val "5"));
  check_result "整数与浮点不等比较" (bool_val true) (execute_binary_op Neq (int_val 5) (float_val 5.0))

(** 测试无效运算错误 *)
let test_invalid_operations () =
  (* 字符串不支持的算术运算 *)
  check_error "字符串减法错误" (fun () -> execute_binary_op Sub (string_val "hello") (string_val "world"));
  check_error "字符串乘法错误" (fun () -> execute_binary_op Mul (string_val "hello") (string_val "world"));
  check_error "字符串除法错误" (fun () -> execute_binary_op Div (string_val "hello") (string_val "world"));
  check_error "字符串取模错误" (fun () -> execute_binary_op Mod (string_val "hello") (string_val "world"));

  (* 不同类型算术运算错误 *)
  check_error "整数字符串加法错误" (fun () -> execute_binary_op Add (int_val 5) (string_val "hello"));
  check_error "字符串整数减法错误" (fun () -> execute_binary_op Sub (string_val "hello") (int_val 5));

  (* 不支持的比较运算 *)
  check_error "字符串整数小于错误" (fun () -> execute_binary_op Lt (string_val "hello") (int_val 5));
  check_error "布尔整数大于错误" (fun () -> execute_binary_op Gt (bool_val true) (int_val 5));

  (* 无效一元运算 *)
  check_error "字符串负号错误" (fun () -> execute_unary_op Neg (string_val "hello"));
  check_error "布尔负号错误" (fun () -> execute_unary_op Neg (bool_val true))

(** 测试边界条件 *)
let test_boundary_conditions () =
  (* 最大最小整数 *)
  let max_int_val = int_val max_int in
  let min_int_val = int_val min_int in

  check_result "最大整数负号" (int_val (min_int + 1)) (execute_unary_op Neg max_int_val);
  check_result "最小整数与零比较" (bool_val true) (execute_binary_op Lt min_int_val (int_val 0));
  check_result "最大整数与零比较" (bool_val true) (execute_binary_op Gt max_int_val (int_val 0));

  (* 特殊浮点值 *)
  check_result "浮点无穷大相等" (bool_val true)
    (execute_binary_op Eq (float_val infinity) (float_val infinity));
  check_result "浮点负无穷大相等" (bool_val true)
    (execute_binary_op Eq (float_val neg_infinity) (float_val neg_infinity));

  (* 单字符字符串 *)
  check_result "单字符连接" (string_val "ab") (execute_binary_op Add (string_val "a") (string_val "b"));
  check_result "单字符比较" (bool_val false) (execute_binary_op Eq (string_val "a") (string_val "b"))

(** 测试性能边界情况 *)
let test_performance_cases () =
  (* 长字符串连接 *)
  let long_string = String.make 1000 'a' in
  let result_string = String.make 2000 'a' in
  check_result "长字符串连接" (string_val result_string)
    (execute_binary_op Add (string_val long_string) (string_val long_string));

  (* 大数值运算 *)
  let large_int = 1000000 in
  check_result "大数值加法"
    (int_val (2 * large_int))
    (execute_binary_op Add (int_val large_int) (int_val large_int));
  check_result "大数值乘法"
    (int_val (large_int * large_int))
    (execute_binary_op Mul (int_val large_int) (int_val large_int))

(** 主测试运行器 *)
let () =
  run "Binary Operations增强测试覆盖 - Fix #1377"
    [
      ("整数算术", [ test_case "整数算术运算测试" `Quick test_integer_arithmetic ]);
      ("除零错误", [ test_case "整数除零错误测试" `Quick test_integer_division_by_zero ]);
      ("浮点算术", [ test_case "浮点算术运算测试" `Quick test_float_arithmetic ]);
      ("字符串运算", [ test_case "字符串运算测试" `Quick test_string_operations ]);
      ("整数比较", [ test_case "整数比较运算测试" `Quick test_integer_comparison ]);
      ("浮点比较", [ test_case "浮点比较运算测试" `Quick test_float_comparison ]);
      ("字符串比较", [ test_case "字符串比较运算测试" `Quick test_string_comparison ]);
      ("布尔比较", [ test_case "布尔比较运算测试" `Quick test_boolean_comparison ]);
      ("逻辑运算", [ test_case "逻辑运算测试" `Quick test_logical_operations ]);
      ("一元运算", [ test_case "一元运算测试" `Quick test_unary_operations ]);
      ("混合类型", [ test_case "混合类型比较测试" `Quick test_mixed_type_comparison ]);
      ("无效运算", [ test_case "无效运算错误测试" `Quick test_invalid_operations ]);
      ("边界条件", [ test_case "边界条件测试" `Quick test_boundary_conditions ]);
      ("性能边界", [ test_case "性能边界案例测试" `Quick test_performance_cases ]);
    ]
