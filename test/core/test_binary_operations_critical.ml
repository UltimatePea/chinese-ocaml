(* 🧪 关键核心模块测试覆盖率改进 - Binary Operations核心模块测试 Fix #1612 *)
(* Author: Alpha, 核心工作代理 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Binary_operations

(* 基础整数算术运算测试 *)
let test_int_arithmetic_operations () =
  (* 加法测试 *)
  (match execute_int_arithmetic_op Add 5 3 with
  | Ok (IntValue 8) -> ()
  | _ -> Alcotest.fail "Integer addition failed");
  
  (* 减法测试 *)
  (match execute_int_arithmetic_op Sub 10 4 with
  | Ok (IntValue 6) -> ()
  | _ -> Alcotest.fail "Integer subtraction failed");
  
  (* 乘法测试 *)
  (match execute_int_arithmetic_op Mul 6 7 with
  | Ok (IntValue 42) -> ()
  | _ -> Alcotest.fail "Integer multiplication failed");
  
  (* 除法测试 *)
  (match execute_int_arithmetic_op Div 15 3 with
  | Ok (IntValue 5) -> ()
  | _ -> Alcotest.fail "Integer division failed")

(* 除零错误处理测试 *)
let test_division_by_zero () =
  (* 除法除零 *)
  (match execute_int_arithmetic_op Div 10 0 with
  | Error (RuntimeError _) -> ()
  | _ -> Alcotest.fail "Division by zero should fail");
  
  (* 取模除零 *)
  (match execute_int_arithmetic_op Mod 7 0 with
  | Error (RuntimeError _) -> ()
  | _ -> Alcotest.fail "Modulo by zero should fail")

(* 浮点算术运算测试 *)
let test_float_arithmetic_operations () =
  (* 浮点加法 *)
  (match execute_float_arithmetic_op Add 3.5 2.1 with
  | Ok (FloatValue result) when abs_float (result -. 5.6) < 0.0001 -> ()
  | _ -> Alcotest.fail "Float addition failed");
  
  (* 浮点减法 *)
  (match execute_float_arithmetic_op Sub 10.0 3.2 with
  | Ok (FloatValue result) when abs_float (result -. 6.8) < 0.0001 -> ()
  | _ -> Alcotest.fail "Float subtraction failed");
  
  (* 浮点乘法 *)
  (match execute_float_arithmetic_op Mul 2.5 4.0 with
  | Ok (FloatValue 10.0) -> ()
  | _ -> Alcotest.fail "Float multiplication failed");
  
  (* 浮点除法 *)
  (match execute_float_arithmetic_op Div 9.0 3.0 with
  | Ok (FloatValue 3.0) -> ()
  | _ -> Alcotest.fail "Float division failed")

(* 字符串运算测试 *)
let test_string_operations () =
  (* 字符串连接 - Add操作 *)
  (match execute_string_op Add "Hello" "World" with
  | Ok (StringValue "HelloWorld") -> ()
  | _ -> Alcotest.fail "String concatenation with Add failed");
  
  (* 字符串连接 - Concat操作 *)
  (match execute_string_op Concat "骆" "言" with
  | Ok (StringValue "骆言") -> ()
  | _ -> Alcotest.fail "String concatenation with Concat failed")

(* 整数比较运算测试 *)
let test_int_comparison_operations () =
  (* 小于运算 *)
  (match execute_typed_comparison Lt (IntValue 5) (IntValue 10) with
  | Ok (BoolValue true) -> ()
  | _ -> Alcotest.fail "Integer less than comparison failed");
  
  (* 大于运算 *)
  (match execute_typed_comparison Gt (IntValue 15) (IntValue 8) with
  | Ok (BoolValue true) -> ()
  | _ -> Alcotest.fail "Integer greater than comparison failed");
  
  (* 等于运算 *)
  (match execute_typed_comparison Eq (IntValue 7) (IntValue 7) with
  | Ok (BoolValue true) -> ()
  | _ -> Alcotest.fail "Integer equality comparison failed");
  
  (* 不等于运算 *)
  (match execute_typed_comparison Ne (IntValue 3) (IntValue 5) with
  | Ok (BoolValue true) -> ()
  | _ -> Alcotest.fail "Integer inequality comparison failed")

(* 浮点比较运算测试 *)
let test_float_comparison_operations () =
  (* 浮点小于运算 *)
  (match execute_typed_comparison Lt (FloatValue 2.5) (FloatValue 3.7) with
  | Ok (BoolValue true) -> ()
  | _ -> Alcotest.fail "Float less than comparison failed");
  
  (* 浮点等于运算 *)
  (match execute_typed_comparison Eq (FloatValue 4.2) (FloatValue 4.2) with
  | Ok (BoolValue true) -> ()
  | _ -> Alcotest.fail "Float equality comparison failed")

(* 字符串比较运算测试 *)
let test_string_comparison_operations () =
  (* 字符串等于 *)
  (match execute_typed_comparison Eq (StringValue "test") (StringValue "test") with
  | Ok (BoolValue true) -> ()
  | _ -> Alcotest.fail "String equality comparison failed");
  
  (* 字符串不等于 *)
  (match execute_typed_comparison Ne (StringValue "hello") (StringValue "world") with
  | Ok (BoolValue true) -> ()
  | _ -> Alcotest.fail "String inequality comparison failed")

(* 类型不匹配错误测试 *)
let test_type_mismatch_errors () =
  (* 整数与字符串比较应该失败 *)
  (match execute_typed_comparison Eq (IntValue 5) (StringValue "5") with
  | Error (RuntimeError _) -> ()
  | _ -> Alcotest.fail "Type mismatch should fail");
  
  (* 浮点与布尔值比较应该失败 *)
  (match execute_typed_comparison Lt (FloatValue 3.14) (BoolValue true) with
  | Error (RuntimeError _) -> ()
  | _ -> Alcotest.fail "Type mismatch should fail")

(* 边界值测试 *)
let test_boundary_values () =
  (* 最大整数操作 *)
  (match execute_int_arithmetic_op Add max_int (-1) with
  | Ok (IntValue result) -> Alcotest.check Alcotest.int "Max int boundary" (max_int - 1) result
  | _ -> Alcotest.fail "Max int boundary test failed");
  
  (* 零值运算 *)
  (match execute_int_arithmetic_op Mul 0 999 with
  | Ok (IntValue 0) -> ()
  | _ -> Alcotest.fail "Zero multiplication failed")

(* 无效运算测试 *)
let test_invalid_operations () =
  (* 字符串无效运算 *)
  (match execute_string_op Mul "hello" "world" with
  | Error (RuntimeError _) -> ()
  | _ -> Alcotest.fail "Invalid string operation should fail");
  
  (* 整数无效运算 - 使用不支持的运算符 *)
  (match execute_int_arithmetic_op Concat 5 3 with
  | Error (RuntimeError _) -> ()
  | _ -> Alcotest.fail "Invalid int operation should fail")

let suite = [
  "test_int_arithmetic_operations", `Quick, test_int_arithmetic_operations;
  "test_division_by_zero", `Quick, test_division_by_zero;
  "test_float_arithmetic_operations", `Quick, test_float_arithmetic_operations;
  "test_string_operations", `Quick, test_string_operations;
  "test_int_comparison_operations", `Quick, test_int_comparison_operations;
  "test_float_comparison_operations", `Quick, test_float_comparison_operations;
  "test_string_comparison_operations", `Quick, test_string_comparison_operations;
  "test_type_mismatch_errors", `Quick, test_type_mismatch_errors;
  "test_boundary_values", `Quick, test_boundary_values;
  "test_invalid_operations", `Quick, test_invalid_operations;
]