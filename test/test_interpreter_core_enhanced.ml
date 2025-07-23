(** 骆言解释器核心增强测试 - Enhanced Core Interpreter Tests *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Interpreter

(** 测试辅助函数 *)
module TestHelper = struct
  let expect_int_value expected actual =
    match actual with
    | IntValue v -> check int "整数值匹配" expected v
    | _ -> check bool "期望整数值" true false

  let expect_string_value expected actual =
    match actual with
    | StringValue v -> check string "字符串值匹配" expected v
    | _ -> check bool "期望字符串值" true false

  let expect_bool_value expected actual =
    match actual with
    | BoolValue v -> check bool "布尔值匹配" expected v
    | _ -> check bool "期望布尔值" true false

  let expect_unit_value actual =
    match actual with
    | UnitValue -> check bool "单元值匹配" true true
    | _ -> check bool "期望单元值" true false
end

(** 测试变量定义和访问 *)
let test_variable_operations () =
  (* let语句测试 *)
  let let_program = [
    LetStmt ("x", LitExpr (IntLit 42));
    ExprStmt (VarExpr "x")
  ] in
  match execute_program let_program with
  | Ok result -> TestHelper.expect_int_value 42 result
  | Error msg -> check bool ("变量定义失败: " ^ msg) false true

(** 测试函数定义和调用 *)
let test_function_operations () =
  (* 简单函数定义和调用 *)
  let func_program = [
    LetStmt ("identity", FunExpr (["x"], VarExpr "x"));
    ExprStmt (FunCallExpr (VarExpr "identity", [LitExpr (IntLit 100)]))
  ] in
  match execute_program func_program with
  | Ok result -> TestHelper.expect_int_value 100 result
  | Error msg -> check bool ("函数操作失败: " ^ msg) false true

(** 测试条件表达式 *)
let test_conditional_expressions () =
  (* if-then-else测试 *)
  let cond_program = [
    ExprStmt (CondExpr (LitExpr (BoolLit true), LitExpr (IntLit 42), LitExpr (IntLit 0)))
  ] in
  match execute_program cond_program with
  | Ok result -> TestHelper.expect_int_value 42 result
  | Error msg -> check bool ("条件表达式失败: " ^ msg) false true

(** 测试模式匹配 *)
let test_pattern_matching () =
  (* 简单模式匹配 *)
  let match_program = [
    ExprStmt (MatchExpr (LitExpr (IntLit 42), [
      (LitPattern (IntLit 42), LitExpr (StringLit "匹配成功"));
      (VarPattern "_", LitExpr (StringLit "匹配失败"))
    ]))
  ] in
  match execute_program match_program with
  | Ok result -> TestHelper.expect_string_value "匹配成功" result
  | Error msg -> check bool ("模式匹配失败: " ^ msg) false true

(** 测试列表操作 *)
let test_list_operations () =
  (* 列表创建和访问 *)
  let list_program = [
    LetStmt ("my_list", ListExpr [LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3)]);
    ExprStmt (VarExpr "my_list")
  ] in
  match execute_program list_program with
  | Ok result -> (
    match result with
    | ListValue [IntValue 1; IntValue 2; IntValue 3] -> check bool "列表操作成功" true true
    | _ -> check bool "列表值不匹配" false true
  )
  | Error msg -> check bool ("列表操作失败: " ^ msg) false true

(** 测试元组操作 *)
let test_tuple_operations () =
  (* 元组创建 *)
  let tuple_program = [
    LetStmt ("my_tuple", TupleExpr [LitExpr (IntLit 42); LitExpr (StringLit "骆言")]);
    ExprStmt (VarExpr "my_tuple")
  ] in
  match execute_program tuple_program with
  | Ok result -> (
    match result with
    | TupleValue [IntValue 42; StringValue "骆言"] -> check bool "元组操作成功" true true
    | _ -> check bool "元组值不匹配" false true
  )
  | Error msg -> check bool ("元组操作失败: " ^ msg) false true

(** 测试递归函数 *)
let test_recursive_functions () =
  (* 阶乘函数 *)
  let factorial_program = [
    RecLetStmt ("factorial", FunExpr (["n"], 
      CondExpr (
        BinaryOpExpr (VarExpr "n", Eq, LitExpr (IntLit 0)),
        LitExpr (IntLit 1),
        BinaryOpExpr (
          VarExpr "n",
          Mul,
          FunCallExpr (VarExpr "factorial", [BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 1))])
        )
      )
    ));
    ExprStmt (FunCallExpr (VarExpr "factorial", [LitExpr (IntLit 5)]))
  ] in
  match execute_program factorial_program with
  | Ok result -> TestHelper.expect_int_value 120 result
  | Error msg -> check bool ("递归函数失败: " ^ msg) false true

(** 测试错误处理 *)
let test_error_handling () =
  (* 未定义变量错误 *)
  let error_program = [ExprStmt (VarExpr "undefined_var")] in
  match execute_program error_program with
  | Ok _ -> check bool "应该抛出未定义变量错误" false true
  | Error _ -> check bool "成功捕获未定义变量错误" true true

(** 测试复杂表达式 *)
let test_complex_expressions () =
  (* 复杂算术表达式 *)
  let complex_program = [
    LetStmt ("a", LitExpr (IntLit 10));
    LetStmt ("b", LitExpr (IntLit 20));
    ExprStmt (BinaryOpExpr (
      BinaryOpExpr (VarExpr "a", Add, VarExpr "b"),
      Mul,
      LitExpr (IntLit 2)
    ))
  ] in
  match execute_program complex_program with
  | Ok result -> TestHelper.expect_int_value 60 result
  | Error msg -> check bool ("复杂表达式失败: " ^ msg) false true

(** 测试嵌套作用域 *)
let test_nested_scopes () =
  (* 嵌套let表达式 *)
  let nested_program = [
    LetStmt ("x", LitExpr (IntLit 10));
    ExprStmt (LetExpr ("x", LitExpr (IntLit 20), VarExpr "x"))
  ] in
  match execute_program nested_program with
  | Ok result -> TestHelper.expect_int_value 20 result
  | Error msg -> check bool ("嵌套作用域失败: " ^ msg) false true

(** 主测试套件 *)
let () =
  run "骆言解释器核心增强测试"
    [
      ( "基础解释器功能",
        [
          test_case "变量操作" `Quick test_variable_operations;
          test_case "函数操作" `Quick test_function_operations;
          test_case "条件表达式" `Quick test_conditional_expressions;
        ] );
      ( "数据结构操作",
        [
          test_case "列表操作" `Quick test_list_operations;
          test_case "元组操作" `Quick test_tuple_operations;
          test_case "模式匹配" `Quick test_pattern_matching;
        ] );
      ( "高级功能",
        [
          test_case "递归函数" `Quick test_recursive_functions;
          test_case "复杂表达式" `Quick test_complex_expressions;
          test_case "嵌套作用域" `Quick test_nested_scopes;
        ] );
      ( "错误处理",
        [
          test_case "错误处理机制" `Quick test_error_handling;
        ] );
    ]