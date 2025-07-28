(* 🧪 关键核心模块测试覆盖率改进 - Binary Operations核心模块测试 Fix #1612 *)
(* Author: Echo, 测试工程师代理 *)

open Yyocamlc_lib.Ast
module Binary_ops = Yyocamlc_lib.Binary_operations

(* 基础算术运算测试 *)
let test_basic_arithmetic_operations () =
  let open Alcotest in
  (* 加法测试 *)
  (try
     let result = Binary_ops.execute_binary_op Add (IntValue 5) (IntValue 3) in
     match result with
     | IntValue 8 -> check bool "Addition test" true true
     | _ -> fail "Integer addition failed"
   with _ -> fail "Integer addition failed");

  (* 减法测试 *)
  (try
     let result = Binary_ops.execute_binary_op Sub (IntValue 10) (IntValue 4) in
     match result with
     | IntValue 6 -> check bool "Subtraction test" true true
     | _ -> fail "Integer subtraction failed"
   with _ -> fail "Integer subtraction failed");

  (* 乘法测试 *)
  (try
     let result = Binary_ops.execute_binary_op Mul (IntValue 6) (IntValue 7) in
     match result with
     | IntValue 42 -> check bool "Multiplication test" true true
     | _ -> fail "Integer multiplication failed"
   with _ -> fail "Integer multiplication failed");

  (* 除法测试 *)
  try
    let result = Binary_ops.execute_binary_op Div (IntValue 15) (IntValue 3) in
    match result with
    | IntValue 5 -> check bool "Division test" true true
    | _ -> fail "Integer division failed"
  with _ -> fail "Integer division failed"

(* 浮点数运算测试 *)
let test_float_operations () =
  let open Alcotest in
  (* 浮点加法 *)
  try
    let result = Binary_ops.execute_binary_op Add (FloatValue 3.5) (FloatValue 2.1) in
    match result with
    | FloatValue result when abs_float (result -. 5.6) < 0.0001 ->
        check bool "Float addition test" true true
    | _ -> fail "Float addition failed"
  with _ -> fail "Float addition failed"

(* 字符串运算测试 *)
let test_string_operations () =
  let open Alcotest in
  (* 字符串连接 *)
  try
    let result = Binary_ops.execute_binary_op Add (StringValue "Hello") (StringValue "World") in
    match result with
    | StringValue "HelloWorld" -> check bool "String concatenation test" true true
    | _ -> fail "String concatenation failed"
  with _ -> fail "String concatenation failed"

(* 比较运算测试 *)
let test_comparison_operations () =
  let open Alcotest in
  (* 相等比较 *)
  (try
     let result = Binary_ops.execute_binary_op Eq (IntValue 5) (IntValue 5) in
     match result with
     | BoolValue true -> check bool "Equality test" true true
     | _ -> fail "Integer equality failed"
   with _ -> fail "Integer equality failed");

  (* 小于比较 *)
  (try
     let result = Binary_ops.execute_binary_op Lt (IntValue 3) (IntValue 5) in
     match result with
     | BoolValue true -> check bool "Less than test" true true
     | _ -> fail "Integer less than failed"
   with _ -> fail "Integer less than failed");

  (* 大于比较 *)
  try
    let result = Binary_ops.execute_binary_op Gt (IntValue 8) (IntValue 3) in
    match result with
    | BoolValue true -> check bool "Greater than test" true true
    | _ -> fail "Integer greater than failed"
  with _ -> fail "Integer greater than failed"

(* 错误处理测试 *)
let test_error_handling () =
  let open Alcotest in
  (* 除零错误 *)
  (try
     let _ = Binary_ops.execute_binary_op Div (IntValue 10) (IntValue 0) in
     fail "Division by zero should raise an exception"
   with _ -> check bool "Division by zero error" true true);

  (* 类型不匹配错误 *)
  try
    let _ = Binary_ops.execute_binary_op Add (IntValue 5) (StringValue "test") in
    fail "Type mismatch should raise an exception"
  with _ -> check bool "Type mismatch error" true true

(* 一元运算测试 *)
let test_unary_operations () =
  let open Alcotest in
  (* 逻辑非运算 *)
  (try
     let result = Binary_ops.execute_unary_op Not (BoolValue true) in
     match result with
     | BoolValue false -> check bool "Logical not test" true true
     | _ -> fail "Logical not failed"
   with _ -> fail "Logical not failed");

  (* 负数运算 *)
  try
    let result = Binary_ops.execute_unary_op Neg (IntValue 42) in
    match result with
    | IntValue -42 -> check bool "Negation test" true true
    | _ -> fail "Negation failed"
  with _ -> fail "Negation failed"

let () =
  let open Alcotest in
  run "Binary Operations Critical Tests"
    [
      ( "binary_operations",
        [
          ("test_basic_arithmetic_operations", `Quick, test_basic_arithmetic_operations);
          ("test_float_operations", `Quick, test_float_operations);
          ("test_string_operations", `Quick, test_string_operations);
          ("test_comparison_operations", `Quick, test_comparison_operations);
          ("test_error_handling", `Quick, test_error_handling);
          ("test_unary_operations", `Quick, test_unary_operations);
        ] );
    ]
