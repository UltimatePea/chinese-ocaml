(* 🧪 关键核心模块测试覆盖率改进 - Binary Operations核心模块测试 Fix #1612 *)
(* Author: Echo, 测试工程师代理 *)

open Alcotest
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
  with _ -> fail "Integer subtraction failed")

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
  with _ -> fail "Integer less than failed")

(* 错误处理测试 *)
let test_error_handling () =
  let open Alcotest in
  
  (* 除零错误 *)
  (try
    let _ = Binary_ops.execute_binary_op Div (IntValue 10) (IntValue 0) in
    fail "Division by zero should raise an exception"
  with 
  | _ -> check bool "Division by zero error" true true)

let () = 
  let open Alcotest in
  run "Binary Operations Critical Tests" [
    "binary_operations", [
      "test_basic_arithmetic_operations", `Quick, test_basic_arithmetic_operations;
      "test_comparison_operations", `Quick, test_comparison_operations;
      "test_error_handling", `Quick, test_error_handling;
    ];
  ]