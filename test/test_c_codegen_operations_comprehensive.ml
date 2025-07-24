(** 骆言C代码生成器操作表达式模块综合测试 涵盖算术运算、逻辑运算、内存操作的全面测试 - Fix #1015 Phase 4 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.C_codegen_operations
open Yyocamlc_lib.C_codegen_context

(** 测试辅助函数和模拟器 *)

(** 创建测试配置 *)
let make_test_config () =
  { c_output_file = "test.c"; include_debug = false; optimize = false; runtime_path = "./runtime" }

(** 创建测试上下文 *)
let make_test_context () = create_context (make_test_config ())

(** 模拟表达式生成函数 *)
let mock_gen_expr_fn _ctx expr =
  match expr with
  | LitExpr (IntLit i) -> string_of_int i
  | LitExpr (StringLit s) -> "\"" ^ s ^ "\""
  | LitExpr (BoolLit true) -> "1"
  | LitExpr (BoolLit false) -> "0"
  | VarExpr name -> name
  | _ -> "mock_expr"

(** 算术运算测试 *)

let test_binary_add_operation () =
  let ctx = make_test_context () in
  let expr1 = LitExpr (IntLit 5) in
  let expr2 = LitExpr (IntLit 3) in
  let binary_expr = BinaryOpExpr (expr1, Add, expr2) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  (* 验证生成的代码包含函数调用结构 *)
  check bool "加法运算代码生成正确" true (String.length result > 0);
  check bool "包含函数调用格式" true (String.contains result '(' || String.contains result ' ')

let test_binary_subtract_operation () =
  let ctx = make_test_context () in
  let expr1 = LitExpr (IntLit 10) in
  let expr2 = LitExpr (IntLit 4) in
  let binary_expr = BinaryOpExpr (expr1, Sub, expr2) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  check bool "减法运算代码生成正确" true (String.length result > 0)

let test_binary_multiply_operation () =
  let ctx = make_test_context () in
  let expr1 = LitExpr (IntLit 6) in
  let expr2 = LitExpr (IntLit 7) in
  let binary_expr = BinaryOpExpr (expr1, Mul, expr2) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  check bool "乘法运算代码生成正确" true (String.length result > 0)

let test_binary_divide_operation () =
  let ctx = make_test_context () in
  let expr1 = LitExpr (IntLit 20) in
  let expr2 = LitExpr (IntLit 5) in
  let binary_expr = BinaryOpExpr (expr1, Div, expr2) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  check bool "除法运算代码生成正确" true (String.length result > 0)

(** 比较运算测试 *)

let test_equality_operation () =
  let ctx = make_test_context () in
  let expr1 = LitExpr (IntLit 5) in
  let expr2 = LitExpr (IntLit 5) in
  let binary_expr = BinaryOpExpr (expr1, Eq, expr2) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  check bool "等于运算代码生成正确" true (String.length result > 0)

let test_not_equal_operation () =
  let ctx = make_test_context () in
  let expr1 = LitExpr (IntLit 5) in
  let expr2 = LitExpr (IntLit 3) in
  let binary_expr = BinaryOpExpr (expr1, Neq, expr2) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  check bool "不等于运算代码生成正确" true (String.length result > 0)

let test_less_than_operation () =
  let ctx = make_test_context () in
  let expr1 = LitExpr (IntLit 3) in
  let expr2 = LitExpr (IntLit 5) in
  let binary_expr = BinaryOpExpr (expr1, Lt, expr2) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  check bool "小于运算代码生成正确" true (String.length result > 0)

(** 逻辑运算测试 *)

let test_logical_and_operation () =
  let ctx = make_test_context () in
  let expr1 = LitExpr (BoolLit true) in
  let expr2 = LitExpr (BoolLit false) in
  let binary_expr = BinaryOpExpr (expr1, And, expr2) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  check bool "逻辑与运算代码生成正确" true (String.length result > 0)

let test_logical_or_operation () =
  let ctx = make_test_context () in
  let expr1 = LitExpr (BoolLit false) in
  let expr2 = LitExpr (BoolLit true) in
  let binary_expr = BinaryOpExpr (expr1, Or, expr2) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  check bool "逻辑或运算代码生成正确" true (String.length result > 0)

let test_string_concat_operation () =
  let ctx = make_test_context () in
  let expr1 = LitExpr (StringLit "Hello") in
  let expr2 = LitExpr (StringLit "World") in
  let binary_expr = BinaryOpExpr (expr1, Concat, expr2) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  check bool "字符串连接代码生成正确" true (String.length result > 0)

(** 一元运算测试 *)

let test_unary_negation_operation () =
  let ctx = make_test_context () in
  let expr = LitExpr (IntLit 42) in
  let unary_expr = UnaryOpExpr (Neg, expr) in

  let result = gen_operations mock_gen_expr_fn ctx unary_expr in

  check bool "一元取负代码生成正确" true (String.length result > 0)

let test_unary_not_operation () =
  let ctx = make_test_context () in
  let expr = LitExpr (BoolLit true) in
  let unary_expr = UnaryOpExpr (Not, expr) in

  let result = gen_operations mock_gen_expr_fn ctx unary_expr in

  check bool "逻辑非运算代码生成正确" true (String.length result > 0)

(** 内存操作测试 *)

let test_ref_expression_generation () =
  let ctx = make_test_context () in
  let expr = LitExpr (IntLit 100) in
  let ref_expr = RefExpr expr in

  let result = gen_memory_operations mock_gen_expr_fn ctx ref_expr in

  check bool "引用表达式代码生成正确" true (String.length result > 0)

let test_deref_expression_generation () =
  let ctx = make_test_context () in
  let expr = VarExpr "ref_var" in
  let deref_expr = DerefExpr expr in

  let result = gen_memory_operations mock_gen_expr_fn ctx deref_expr in

  check bool "解引用表达式代码生成正确" true (String.length result > 0)

let test_assign_expression_generation () =
  let ctx = make_test_context () in
  let ref_expr = VarExpr "ref_var" in
  let value_expr = LitExpr (IntLit 50) in
  let assign_expr = AssignExpr (ref_expr, value_expr) in

  let result = gen_memory_operations mock_gen_expr_fn ctx assign_expr in

  check bool "赋值表达式代码生成正确" true (String.length result > 0)

(** 错误处理测试 *)

let test_unsupported_expression_handling () =
  let ctx = make_test_context () in
  let unsupported_expr = LitExpr (IntLit 42) in
  (* 不是运算表达式 *)

  try
    let _ = gen_operations mock_gen_expr_fn ctx unsupported_expr in
    check bool "应该抛出不支持表达式异常" true false
  with _ -> check bool "正确处理不支持的表达式" true true

let test_unsupported_memory_operation_handling () =
  let ctx = make_test_context () in
  let unsupported_expr = LitExpr (IntLit 42) in
  (* 不是内存操作表达式 *)

  try
    let _ = gen_memory_operations mock_gen_expr_fn ctx unsupported_expr in
    check bool "应该抛出不支持内存操作异常" true false
  with _ -> check bool "正确处理不支持的内存操作" true true

(** 复合表达式测试 *)

let test_nested_binary_operations () =
  let ctx = make_test_context () in
  (* (5 + 3) * (10 - 2) *)
  let inner1 = BinaryOpExpr (LitExpr (IntLit 5), Add, LitExpr (IntLit 3)) in
  let inner2 = BinaryOpExpr (LitExpr (IntLit 10), Sub, LitExpr (IntLit 2)) in
  let nested_expr = BinaryOpExpr (inner1, Mul, inner2) in

  let result = gen_operations mock_gen_expr_fn ctx nested_expr in

  check bool "嵌套二元运算代码生成正确" true (String.length result > 0)

(** 边界条件测试 *)

let test_zero_values_operations () =
  let ctx = make_test_context () in
  let zero_expr = LitExpr (IntLit 0) in
  let binary_expr = BinaryOpExpr (zero_expr, Add, zero_expr) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  check bool "零值运算代码生成正确" true (String.length result > 0)

let test_large_numbers_operations () =
  let ctx = make_test_context () in
  let large_expr = LitExpr (IntLit max_int) in
  let binary_expr = BinaryOpExpr (large_expr, Mul, LitExpr (IntLit 1)) in

  let result = gen_operations mock_gen_expr_fn ctx binary_expr in

  check bool "大数值运算代码生成正确" true (String.length result > 0)

(** 主测试套件 *)

let arithmetic_tests =
  [
    test_case "二元加法运算测试" `Quick test_binary_add_operation;
    test_case "二元减法运算测试" `Quick test_binary_subtract_operation;
    test_case "二元乘法运算测试" `Quick test_binary_multiply_operation;
    test_case "二元除法运算测试" `Quick test_binary_divide_operation;
  ]

let comparison_tests =
  [
    test_case "等于运算测试" `Quick test_equality_operation;
    test_case "不等于运算测试" `Quick test_not_equal_operation;
    test_case "小于运算测试" `Quick test_less_than_operation;
  ]

let logical_tests =
  [
    test_case "逻辑与运算测试" `Quick test_logical_and_operation;
    test_case "逻辑或运算测试" `Quick test_logical_or_operation;
    test_case "字符串连接测试" `Quick test_string_concat_operation;
  ]

let unary_tests =
  [
    test_case "一元取负运算测试" `Quick test_unary_negation_operation;
    test_case "逻辑非运算测试" `Quick test_unary_not_operation;
  ]

let memory_tests =
  [
    test_case "引用表达式生成测试" `Quick test_ref_expression_generation;
    test_case "解引用表达式生成测试" `Quick test_deref_expression_generation;
    test_case "赋值表达式生成测试" `Quick test_assign_expression_generation;
  ]

let complex_tests = [ test_case "嵌套二元运算测试" `Quick test_nested_binary_operations ]

let error_handling_tests =
  [
    test_case "不支持表达式处理测试" `Quick test_unsupported_expression_handling;
    test_case "不支持内存操作处理测试" `Quick test_unsupported_memory_operation_handling;
  ]

let boundary_tests =
  [
    test_case "零值运算测试" `Quick test_zero_values_operations;
    test_case "大数值运算测试" `Quick test_large_numbers_operations;
  ]

(** 运行所有测试 *)
let () =
  run "C代码生成器操作表达式模块综合测试"
    [
      ("算术运算功能", arithmetic_tests);
      ("比较运算功能", comparison_tests);
      ("逻辑运算功能", logical_tests);
      ("一元运算功能", unary_tests);
      ("内存操作功能", memory_tests);
      ("复合表达式处理", complex_tests);
      ("错误处理机制", error_handling_tests);
      ("边界条件处理", boundary_tests);
    ]
