(** 骆言解释器核心基础测试 - Core Interpreter Basic Tests *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Interpreter

(** 测试工具函数 *)
module TestUtils = struct
  let values_equal v1 v2 =
    match (v1, v2) with
    | IntValue a, IntValue b -> a = b
    | StringValue a, StringValue b -> a = b
    | BoolValue a, BoolValue b -> a = b
    | UnitValue, UnitValue -> true
    | ListValue a, ListValue b -> List.length a = List.length b && List.for_all2 ( = ) a b
    | TupleValue a, TupleValue b -> List.length a = List.length b && List.for_all2 ( = ) a b
    | _ -> false
end

(** 测试基础程序执行 *)
let test_basic_program_execution () =
  (* 简单表达式程序 *)
  let program1 = [ ExprStmt (LitExpr (IntLit 42)) ] in
  match execute_program program1 with
  | Ok result -> check bool "简单表达式程序" true (TestUtils.values_equal result (IntValue 42))
  | Error msg -> (
      check bool ("程序执行失败: " ^ msg) false true;

      (* 字符串程序 *)
      let program2 = [ ExprStmt (LitExpr (StringLit "骆言语言")) ] in
      match execute_program program2 with
      | Ok result -> check bool "字符串程序" true (TestUtils.values_equal result (StringValue "骆言语言"))
      | Error msg -> check bool ("字符串程序执行失败: " ^ msg) false true)

(** 测试算术运算程序 *)
let test_arithmetic_programs () =
  (* 加法程序 *)
  let add_program = [ ExprStmt (BinaryOpExpr (LitExpr (IntLit 20), Add, LitExpr (IntLit 22))) ] in
  match execute_program add_program with
  | Ok result -> check bool "加法程序" true (TestUtils.values_equal result (IntValue 42))
  | Error msg -> (
      check bool ("加法程序执行失败: " ^ msg) false true;

      (* 减法程序 *)
      let sub_program =
        [ ExprStmt (BinaryOpExpr (LitExpr (IntLit 100), Sub, LitExpr (IntLit 58))) ]
      in
      match execute_program sub_program with
      | Ok result -> check bool "减法程序" true (TestUtils.values_equal result (IntValue 42))
      | Error msg -> check bool ("减法程序执行失败: " ^ msg) false true)

(** 测试变量定义程序 *)
let test_variable_definition_programs () =
  (* Let定义程序 *)
  let let_program =
    [
      LetStmt ("x", LitExpr (IntLit 25));
      ExprStmt (BinaryOpExpr (VarExpr "x", Add, LitExpr (IntLit 17)));
    ]
  in
  match execute_program let_program with
  | Ok result -> check bool "Let定义程序" true (TestUtils.values_equal result (IntValue 42))
  | Error msg -> (
      check bool ("Let定义程序执行失败: " ^ msg) false true;

      (* 中文变量名程序 *)
      let chinese_var_program = [ LetStmt ("数值", LitExpr (IntLit 42)); ExprStmt (VarExpr "数值") ] in
      match execute_program chinese_var_program with
      | Ok result -> check bool "中文变量名程序" true (TestUtils.values_equal result (IntValue 42))
      | Error msg -> check bool ("中文变量名程序执行失败: " ^ msg) false true)

(** 测试条件分支程序 *)
let test_conditional_programs () =
  (* 真分支程序 *)
  let true_branch_program =
    [
      ExprStmt (CondExpr (LitExpr (BoolLit true), LitExpr (StringLit "真"), LitExpr (StringLit "假")));
    ]
  in
  match execute_program true_branch_program with
  | Ok result -> check bool "真分支程序" true (TestUtils.values_equal result (StringValue "真"))
  | Error msg -> (
      check bool ("真分支程序执行失败: " ^ msg) false true;

      (* 假分支程序 *)
      let false_branch_program =
        [
          ExprStmt
            (CondExpr (LitExpr (BoolLit false), LitExpr (StringLit "真"), LitExpr (StringLit "假")));
        ]
      in
      match execute_program false_branch_program with
      | Ok result -> check bool "假分支程序" true (TestUtils.values_equal result (StringValue "假"))
      | Error msg -> check bool ("假分支程序执行失败: " ^ msg) false true)

(** 测试复合程序 *)
let test_compound_programs () =
  (* 多语句程序 *)
  let compound_program =
    [
      LetStmt ("a", LitExpr (IntLit 10));
      LetStmt ("b", LitExpr (IntLit 20));
      LetStmt ("c", BinaryOpExpr (VarExpr "a", Add, VarExpr "b"));
      ExprStmt (BinaryOpExpr (VarExpr "c", Add, LitExpr (IntLit 12)));
    ]
  in
  match execute_program compound_program with
  | Ok result -> check bool "复合程序" true (TestUtils.values_equal result (IntValue 42))
  | Error msg -> check bool ("复合程序执行失败: " ^ msg) false true

(** 测试静默解释 *)
let test_quiet_interpretation () =
  let program = [ ExprStmt (LitExpr (IntLit 42)) ] in
  let result = interpret_quiet program in
  check bool "静默解释成功" true result

(** 测试数据结构程序 *)
let test_data_structure_programs () =
  (* 元组程序 *)
  let tuple_program = [ ExprStmt (TupleExpr [ LitExpr (IntLit 1); LitExpr (IntLit 2) ]) ] in
  match execute_program tuple_program with
  | Ok result ->
      check bool "元组程序" true (TestUtils.values_equal result (TupleValue [ IntValue 1; IntValue 2 ]))
  | Error msg -> (
      check bool ("元组程序执行失败: " ^ msg) false true;

      (* 列表程序 *)
      let list_program = [ ExprStmt (ListExpr [ LitExpr (IntLit 10); LitExpr (IntLit 20) ]) ] in
      match execute_program list_program with
      | Ok result ->
          check bool "列表程序" true
            (TestUtils.values_equal result (ListValue [ IntValue 10; IntValue 20 ]))
      | Error msg -> check bool ("列表程序执行失败: " ^ msg) false true)

(** 测试套件 *)
let interpreter_core_tests =
  [
    test_case "基础程序执行" `Quick test_basic_program_execution;
    test_case "算术运算程序" `Quick test_arithmetic_programs;
    test_case "变量定义程序" `Quick test_variable_definition_programs;
    test_case "条件分支程序" `Quick test_conditional_programs;
    test_case "复合程序" `Quick test_compound_programs;
    test_case "静默解释" `Quick test_quiet_interpretation;
    test_case "数据结构程序" `Quick test_data_structure_programs;
  ]

let () = run "骆言解释器核心基础测试" [ ("解释器核心基础功能", interpreter_core_tests) ]
