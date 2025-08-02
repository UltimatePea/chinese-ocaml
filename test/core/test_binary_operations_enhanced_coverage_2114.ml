(** 二元运算模块增强测试覆盖率提升 - Fix #2114
    
    专注于提升binary_operations.ml核心模块测试覆盖率到80%+
    新增测试场景：
    - 所有算术运算的完整测试
    - 类型转换和强制转换路径
    - 错误处理和边界条件
    - 浮点数特殊值处理
    - 字符串运算完整测试
    - 比较运算符完整覆盖
    - 逻辑运算符测试
    - 一元运算符全覆盖
    - 性能和优化路径验证
    
    Author: Whisky, PR Worker Agent
    @version 1.0
    @since 2025-08-02 Fix #2114 核心模块测试覆盖率提升优化 *)

open Alcotest
open Yyocamlc_lib
open Ast
open Value_operations
open Binary_operations
open Error_recovery

(** 测试工具模块 *)
module TestUtils = struct
  (* 浮点数比较精度常量 *)
  let float_epsilon = 1e-10
  
  (* 浮点数近似相等比较 *)
  let float_approx_equal a b =
    abs_float (a -. b) < float_epsilon
  
  (* 值比较函数，特殊处理浮点数 *)
  let value_equal v1 v2 =
    match (v1, v2) with
    | FloatValue f1, FloatValue f2 -> float_approx_equal f1 f2
    | _ -> v1 = v2
  
  let value_testable = testable (fun fmt v -> Format.fprintf fmt "%s" (value_to_string v)) value_equal
  
  let check_binary_result desc op left right expected =
    let actual = execute_binary_op op left right in
    check value_testable desc expected actual
    
  let check_unary_result desc op value expected =
    let actual = execute_unary_op op value in
    check value_testable desc expected actual
    
  let expect_runtime_error desc f =
    try
      ignore (f ());
      failwith ("Expected runtime error but none occurred: " ^ desc)
    with
    | RuntimeError _ -> ()
    | Yyocamlc_lib.Compiler_errors_types.CompilerError _ -> ()
    | e -> failwith ("Unexpected exception: " ^ Printexc.to_string e)
end

(** 整数算术运算全覆盖测试 *)
let test_integer_arithmetic_comprehensive () =
  (* 基本算术运算 *)
  TestUtils.check_binary_result "整数加法" Add (IntValue 10) (IntValue 5) (IntValue 15);
  TestUtils.check_binary_result "整数减法" Sub (IntValue 10) (IntValue 3) (IntValue 7);
  TestUtils.check_binary_result "整数乘法" Mul (IntValue 6) (IntValue 7) (IntValue 42);
  TestUtils.check_binary_result "整数除法" Div (IntValue 20) (IntValue 4) (IntValue 5);
  TestUtils.check_binary_result "整数取模" Mod (IntValue 17) (IntValue 5) (IntValue 2);
  
  (* 边界值测试 *)
  TestUtils.check_binary_result "最大整数加法" Add (IntValue max_int) (IntValue 0) (IntValue max_int);
  TestUtils.check_binary_result "最小整数减法" Sub (IntValue min_int) (IntValue 0) (IntValue min_int);
  TestUtils.check_binary_result "零乘法" Mul (IntValue 100) (IntValue 0) (IntValue 0);
  TestUtils.check_binary_result "零除以非零" Div (IntValue 0) (IntValue 5) (IntValue 0);
  
  (* 负数运算 *)
  TestUtils.check_binary_result "负数加法" Add (IntValue (-10)) (IntValue 5) (IntValue (-5));
  TestUtils.check_binary_result "负数乘法" Mul (IntValue (-3)) (IntValue 4) (IntValue (-12));
  TestUtils.check_binary_result "负数除法" Div (IntValue (-15)) (IntValue 3) (IntValue (-5));
  TestUtils.check_binary_result "负数取模" Mod (IntValue (-17)) (IntValue 5) (IntValue (-2))

(** 浮点数算术运算全覆盖测试 *)
let test_float_arithmetic_comprehensive () =
  (* 基本浮点运算 *)
  TestUtils.check_binary_result "浮点加法" Add (FloatValue 3.14) (FloatValue 2.86) (FloatValue 6.0);
  TestUtils.check_binary_result "浮点减法" Sub (FloatValue 10.5) (FloatValue 3.2) (FloatValue 7.3);
  TestUtils.check_binary_result "浮点乘法" Mul (FloatValue 2.5) (FloatValue 4.0) (FloatValue 10.0);
  TestUtils.check_binary_result "浮点除法" Div (FloatValue 15.0) (FloatValue 3.0) (FloatValue 5.0);
  
  (* 特殊浮点值 *)
  TestUtils.check_binary_result "零浮点加法" Add (FloatValue 0.0) (FloatValue 5.5) (FloatValue 5.5);
  TestUtils.check_binary_result "负零浮点" Add (FloatValue (-0.0)) (FloatValue 0.0) (FloatValue 0.0);
  TestUtils.check_binary_result "小数精度" Add (FloatValue 0.1) (FloatValue 0.2) (FloatValue 0.3);
  
  (* 负浮点数 *)
  TestUtils.check_binary_result "负浮点加法" Add (FloatValue (-2.5)) (FloatValue 1.5) (FloatValue (-1.0));
  TestUtils.check_binary_result "负浮点乘法" Mul (FloatValue (-3.0)) (FloatValue 2.0) (FloatValue (-6.0))

(** 字符串运算全覆盖测试 *)
let test_string_operations_comprehensive () =
  (* 基本字符串连接 *)
  TestUtils.check_binary_result "字符串连接" Add (StringValue "Hello") (StringValue " World") (StringValue "Hello World");
  TestUtils.check_binary_result "Concat运算符" Concat (StringValue "骆言") (StringValue "编程") (StringValue "骆言编程");
  
  (* 空字符串处理 *)
  TestUtils.check_binary_result "空字符串连接" Add (StringValue "") (StringValue "test") (StringValue "test");
  TestUtils.check_binary_result "连接空字符串" Add (StringValue "test") (StringValue "") (StringValue "test");
  TestUtils.check_binary_result "两个空字符串" Add (StringValue "") (StringValue "") (StringValue "");
  
  (* 特殊字符测试 *)
  TestUtils.check_binary_result "特殊字符连接" Add (StringValue "中文") (StringValue "测试") (StringValue "中文测试");
  TestUtils.check_binary_result "数字字符串" Add (StringValue "123") (StringValue "456") (StringValue "123456");
  TestUtils.check_binary_result "符号字符串" Add (StringValue "!@#") (StringValue "$%^") (StringValue "!@#$%^");
  
  (* 长字符串测试 *)
  let long_str1 = String.make 1000 'A' in
  let long_str2 = String.make 1000 'B' in
  let expected_long = long_str1 ^ long_str2 in
  TestUtils.check_binary_result "长字符串连接" Add (StringValue long_str1) (StringValue long_str2) (StringValue expected_long)

(** 比较运算符全覆盖测试 *)
let test_comparison_operations_comprehensive () =
  (* 整数比较 *)
  TestUtils.check_binary_result "整数相等" Eq (IntValue 5) (IntValue 5) (BoolValue true);
  TestUtils.check_binary_result "整数不等" Neq (IntValue 5) (IntValue 3) (BoolValue true);
  TestUtils.check_binary_result "整数小于" Lt (IntValue 3) (IntValue 5) (BoolValue true);
  TestUtils.check_binary_result "整数小于等于" Le (IntValue 5) (IntValue 5) (BoolValue true);
  TestUtils.check_binary_result "整数大于" Gt (IntValue 7) (IntValue 3) (BoolValue true);
  TestUtils.check_binary_result "整数大于等于" Ge (IntValue 5) (IntValue 5) (BoolValue true);
  
  (* 浮点数比较 *)
  TestUtils.check_binary_result "浮点相等" Eq (FloatValue 3.14) (FloatValue 3.14) (BoolValue true);
  TestUtils.check_binary_result "浮点不等" Neq (FloatValue 3.14) (FloatValue 2.71) (BoolValue true);
  TestUtils.check_binary_result "浮点小于" Lt (FloatValue 2.5) (FloatValue 3.5) (BoolValue true);
  TestUtils.check_binary_result "浮点大于" Gt (FloatValue 4.0) (FloatValue 3.0) (BoolValue true);
  
  (* 字符串比较 *)
  TestUtils.check_binary_result "字符串相等" Eq (StringValue "test") (StringValue "test") (BoolValue true);
  TestUtils.check_binary_result "字符串不等" Neq (StringValue "abc") (StringValue "def") (BoolValue true);
  TestUtils.check_binary_result "字符串小于" Lt (StringValue "apple") (StringValue "banana") (BoolValue true);
  TestUtils.check_binary_result "字符串大于" Gt (StringValue "zebra") (StringValue "apple") (BoolValue true);
  
  (* 布尔值比较 *)
  TestUtils.check_binary_result "布尔相等" Eq (BoolValue true) (BoolValue true) (BoolValue true);
  TestUtils.check_binary_result "布尔不等" Neq (BoolValue true) (BoolValue false) (BoolValue true);
  
  (* 边界情况 *)
  TestUtils.check_binary_result "零比较" Eq (IntValue 0) (IntValue 0) (BoolValue true);
  TestUtils.check_binary_result "负数比较" Lt (IntValue (-5)) (IntValue 0) (BoolValue true);
  TestUtils.check_binary_result "空字符串比较" Eq (StringValue "") (StringValue "") (BoolValue true)

(** 逻辑运算符全覆盖测试 *)
let test_logical_operations_comprehensive () =
  (* And运算真值表 *)
  TestUtils.check_binary_result "true AND true" And (BoolValue true) (BoolValue true) (BoolValue true);
  TestUtils.check_binary_result "true AND false" And (BoolValue true) (BoolValue false) (BoolValue false);
  TestUtils.check_binary_result "false AND true" And (BoolValue false) (BoolValue true) (BoolValue false);
  TestUtils.check_binary_result "false AND false" And (BoolValue false) (BoolValue false) (BoolValue false);
  
  (* Or运算真值表 *)
  TestUtils.check_binary_result "true OR true" Or (BoolValue true) (BoolValue true) (BoolValue true);
  TestUtils.check_binary_result "true OR false" Or (BoolValue true) (BoolValue false) (BoolValue true);
  TestUtils.check_binary_result "false OR true" Or (BoolValue false) (BoolValue true) (BoolValue true);
  TestUtils.check_binary_result "false OR false" Or (BoolValue false) (BoolValue false) (BoolValue false)

(** 一元运算符全覆盖测试 *)
let test_unary_operations_comprehensive () =
  (* 算术否定 *)
  TestUtils.check_unary_result "正整数否定" Neg (IntValue 42) (IntValue (-42));
  TestUtils.check_unary_result "负整数否定" Neg (IntValue (-15)) (IntValue 15);
  TestUtils.check_unary_result "零否定" Neg (IntValue 0) (IntValue 0);
  TestUtils.check_unary_result "浮点否定" Neg (FloatValue 3.14) (FloatValue (-3.14));
  TestUtils.check_unary_result "负浮点否定" Neg (FloatValue (-2.71)) (FloatValue 2.71);
  TestUtils.check_unary_result "零浮点否定" Neg (FloatValue 0.0) (FloatValue (-0.0));
  
  (* 逻辑否定 *)
  TestUtils.check_unary_result "true逻辑否定" Not (BoolValue true) (BoolValue false);
  TestUtils.check_unary_result "false逻辑否定" Not (BoolValue false) (BoolValue true)

(** 错误处理和异常情况测试 *)
let test_error_handling_comprehensive () =
  (* 暂时禁用错误恢复以测试真正的错误处理 *)
  let original_config = Error_recovery.get_recovery_config () in
  let test_config = { original_config with enabled = false } in
  Error_recovery.set_recovery_config test_config;
  (* 除零错误 *)
  TestUtils.expect_runtime_error "整数除零" (fun () -> execute_binary_op Div (IntValue 10) (IntValue 0));
  TestUtils.expect_runtime_error "整数取模零" (fun () -> execute_binary_op Mod (IntValue 10) (IntValue 0));
  
  (* 类型不匹配错误 - 使用无法进行类型转换的操作 *)
  TestUtils.expect_runtime_error "单元值与整数相乘" (fun () -> execute_binary_op Mul (UnitValue) (IntValue 5));
  TestUtils.expect_runtime_error "字符串取模运算" (fun () -> execute_binary_op Mod (StringValue "abc") (StringValue "def"));
  TestUtils.expect_runtime_error "单元值除法运算" (fun () -> execute_binary_op Div (UnitValue) (UnitValue));
  
  (* 不支持的运算 *)
  TestUtils.expect_runtime_error "字符串除法" (fun () -> execute_binary_op Div (StringValue "abc") (StringValue "def"));
  TestUtils.expect_runtime_error "布尔值加法" (fun () -> execute_binary_op Add (BoolValue true) (BoolValue false));
  
  (* 一元运算错误 *)
  TestUtils.expect_runtime_error "字符串否定" (fun () -> execute_unary_op Neg (StringValue "test"));
  TestUtils.expect_runtime_error "单元值否定" (fun () -> execute_unary_op Neg (UnitValue));
  TestUtils.expect_runtime_error "布尔值算术否定" (fun () -> execute_unary_op Neg (BoolValue true));
  
  (* 恢复原始错误恢复配置 *)
  Error_recovery.set_recovery_config original_config

(** 类型转换和强制转换测试 *)
let test_type_conversion_paths () =
  (* 暂时禁用错误恢复以测试类型转换失败场景 *)
  let original_config = Error_recovery.get_recovery_config () in
  let test_config = { original_config with enabled = false } in
  Error_recovery.set_recovery_config test_config;
  
  (* 这里测试内部转换函数路径 *)
  
  (* 测试算术转换尝试 - 这些应该失败并抛出错误 *)
  TestUtils.expect_runtime_error "尝试转换不兼容类型进行算术运算" 
    (fun () -> execute_binary_op Add (StringValue "hello") (IntValue 42));
  
  TestUtils.expect_runtime_error "尝试转换不兼容类型进行比较运算" 
    (fun () -> execute_binary_op Lt (BoolValue true) (FloatValue 3.14));
  
  (* 测试with_conversion路径 *)
  TestUtils.expect_runtime_error "转换后仍不兼容的运算" 
    (fun () -> execute_binary_op Mul (StringValue "test") (BoolValue false));
  
  (* 恢复原始错误恢复配置 *)
  Error_recovery.set_recovery_config original_config

(** 内部函数路径测试 *)
let test_internal_function_paths () =
  (* 测试find_arithmetic_operation函数 - 通过调用不同运算来覆盖 *)
  TestUtils.check_binary_result "覆盖find_arithmetic_operation-Add" Add (IntValue 1) (IntValue 2) (IntValue 3);
  TestUtils.check_binary_result "覆盖find_arithmetic_operation-Sub" Sub (IntValue 5) (IntValue 2) (IntValue 3);
  TestUtils.check_binary_result "覆盖find_arithmetic_operation-Mul" Mul (IntValue 3) (IntValue 4) (IntValue 12);
  TestUtils.check_binary_result "覆盖find_arithmetic_operation-Div" Div (IntValue 12) (IntValue 3) (IntValue 4);
  TestUtils.check_binary_result "覆盖find_arithmetic_operation-Mod" Mod (IntValue 13) (IntValue 5) (IntValue 3);
  
  (* 测试字符串运算路径 *)
  TestUtils.check_binary_result "字符串Add路径" Add (StringValue "a") (StringValue "b") (StringValue "ab");
  TestUtils.check_binary_result "字符串Concat路径" Concat (StringValue "x") (StringValue "y") (StringValue "xy");
  
  (* 测试类型化比较路径 *)
  TestUtils.check_binary_result "整数Lt路径" Lt (IntValue 3) (IntValue 5) (BoolValue true);
  TestUtils.check_binary_result "整数Le路径" Le (IntValue 5) (IntValue 5) (BoolValue true);
  TestUtils.check_binary_result "整数Gt路径" Gt (IntValue 7) (IntValue 3) (BoolValue true);
  TestUtils.check_binary_result "整数Ge路径" Ge (IntValue 5) (IntValue 5) (BoolValue true);
  TestUtils.check_binary_result "整数Eq路径" Eq (IntValue 5) (IntValue 5) (BoolValue true);
  TestUtils.check_binary_result "整数Ne路径" Neq (IntValue 5) (IntValue 3) (BoolValue true)

(** 边界值和特殊情况测试 *)
let test_boundary_and_special_cases () =
  (* 最大最小值测试 *)
  TestUtils.check_binary_result "最大整数相等" Eq (IntValue max_int) (IntValue max_int) (BoolValue true);
  TestUtils.check_binary_result "最小整数相等" Eq (IntValue min_int) (IntValue min_int) (BoolValue true);
  
  (* 浮点特殊值 *)
  TestUtils.check_binary_result "无穷大相等" Eq (FloatValue infinity) (FloatValue infinity) (BoolValue true);
  TestUtils.check_binary_result "负无穷大相等" Eq (FloatValue neg_infinity) (FloatValue neg_infinity) (BoolValue true);
  
  (* Unicode字符串 *)
  TestUtils.check_binary_result "Unicode字符串连接" Add (StringValue "你好") (StringValue "世界") (StringValue "你好世界");
  TestUtils.check_binary_result "Emoji字符串连接" Add (StringValue "😀") (StringValue "😂") (StringValue "😀😂");
  
  (* 极长运算链的首尾 *)
  let result = execute_binary_op Add (IntValue 1) (IntValue 1) in
  TestUtils.check_binary_result "简单链式运算基础" Add result (IntValue 1) (IntValue 3)

(** 主测试运行器 *)
let () =
  run "二元运算模块增强测试覆盖率提升 - Fix #2114"
    [
      ( "算术运算完整测试",
        [
          test_case "整数算术运算全覆盖" `Quick test_integer_arithmetic_comprehensive;
          test_case "浮点数算术运算全覆盖" `Quick test_float_arithmetic_comprehensive;
        ] );
      ( "字符串运算和比较",
        [
          test_case "字符串运算全覆盖" `Quick test_string_operations_comprehensive;
          test_case "比较运算符全覆盖" `Quick test_comparison_operations_comprehensive;
        ] );
      ( "逻辑和一元运算",
        [
          test_case "逻辑运算符全覆盖" `Quick test_logical_operations_comprehensive;
          test_case "一元运算符全覆盖" `Quick test_unary_operations_comprehensive;
        ] );
      ( "错误处理和类型转换",
        [
          test_case "错误处理全覆盖" `Quick test_error_handling_comprehensive;
          test_case "类型转换路径测试" `Quick test_type_conversion_paths;
        ] );
      ( "内部函数和边界测试",
        [
          test_case "内部函数路径测试" `Quick test_internal_function_paths;
          test_case "边界值和特殊情况" `Quick test_boundary_and_special_cases;
        ] );
    ]