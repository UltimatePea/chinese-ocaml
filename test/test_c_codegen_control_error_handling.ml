(** 骆言C代码生成控制模块错误处理测试 *)

open Printf
open Yyocamlc_lib.Ast
open Yyocamlc_lib.C_codegen_context
open Yyocamlc_lib.C_codegen_control

(** 创建测试用上下文 *)
let test_ctx = 
  let config = {
    c_output_file = "test.c";
    include_debug = false;
    optimize = false;
    runtime_path = "./runtime";
  } in
  create_context config

(** 简单的表达式生成函数用于测试 *)
let dummy_gen_expr _ctx expr =
  match expr with
  | LitExpr (IntLit i) -> sprintf "%d" i
  | VarExpr name -> sprintf "var_%s" name
  | _ -> "dummy_expr"

let dummy_gen_pattern_check _ctx _var_name _pattern = "pattern_check"

(** 测试函数调用表达式错误处理 *)
let test_func_call_error_handling () =
  printf "测试函数调用表达式错误处理...\n";
  let func_expr = VarExpr "test_func" in
  let args = [LitExpr (IntLit 42)] in
  let full_expr = FunCallExpr (func_expr, args) in
  try
    let result = gen_control_flow dummy_gen_expr dummy_gen_pattern_check test_ctx full_expr in
    printf "函数调用代码生成成功: %s\n" result;
    true
  with
  | Failure msg ->
    printf "预期内的失败: %s\n" msg;
    false

(** 测试函数定义表达式错误处理 *)
let test_func_def_error_handling () =
  printf "测试函数定义表达式错误处理...\n";
  let params = ["x"; "y"] in
  let body = LitExpr (IntLit 1) in
  let full_expr = FunExpr (params, body) in
  try
    let result = gen_control_flow dummy_gen_expr dummy_gen_pattern_check test_ctx full_expr in
    printf "函数定义代码生成成功: %s\n" result;
    true
  with
  | Failure msg ->
    printf "函数定义生成失败: %s\n" msg;
    false

(** 测试空参数名错误处理 *)
let test_empty_param_error_handling () =
  printf "测试空参数名错误处理...\n";
  let params = [""] in  (* 空参数名 *)
  let body = LitExpr (IntLit 1) in
  let full_expr = FunExpr (params, body) in
  try
    let _result = gen_control_flow dummy_gen_expr dummy_gen_pattern_check test_ctx full_expr in
    printf "错误：应该抛出异常但没有\n";
    false
  with
  | Failure msg ->
    printf "正确捕获空参数名错误: %s\n" msg;
    true

(** 测试let表达式空变量名错误处理 *)
let test_empty_var_error_handling () =
  printf "测试let表达式空变量名错误处理...\n";
  let var_name = "" in  (* 空变量名 *)
  let value_expr = LitExpr (IntLit 42) in
  let body_expr = VarExpr "x" in
  let full_expr = LetExpr (var_name, value_expr, body_expr) in
  try
    let _result = gen_control_flow dummy_gen_expr dummy_gen_pattern_check test_ctx full_expr in
    printf "错误：应该抛出异常但没有\n";
    false
  with
  | Failure msg ->
    printf "正确捕获空变量名错误: %s\n" msg;
    true

(** 测试条件表达式错误处理 *)
let test_if_expr_error_handling () =
  printf "测试条件表达式错误处理...\n";
  let cond_expr = VarExpr "condition" in
  let then_expr = LitExpr (IntLit 1) in
  let else_expr = LitExpr (IntLit 0) in
  let full_expr = CondExpr (cond_expr, then_expr, else_expr) in
  try
    let result = gen_control_flow dummy_gen_expr dummy_gen_pattern_check test_ctx full_expr in
    printf "条件表达式代码生成成功: %s\n" result;
    true
  with
  | Failure msg ->
    printf "条件表达式生成失败: %s\n" msg;
    false

(** 测试不支持的表达式类型错误处理 *)
let test_unsupported_expr_error_handling () =
  printf "测试不支持的表达式类型错误处理...\n";
  let unsupported_expr = ModuleExpr [] in
  try
    let _result = gen_control_flow dummy_gen_expr dummy_gen_pattern_check test_ctx unsupported_expr in
    printf "错误：应该抛出不支持表达式异常但没有\n";
    false
  with
  | Failure msg ->
    printf "正确捕获不支持表达式错误: %s\n" msg;
    true

(** 运行所有测试 *)
let run_tests () =
  printf "开始C代码生成控制模块错误处理测试...\n\n";
  let tests = [
    ("函数调用错误处理", test_func_call_error_handling);
    ("函数定义错误处理", test_func_def_error_handling);
    ("空参数名错误处理", test_empty_param_error_handling);
    ("空变量名错误处理", test_empty_var_error_handling);
    ("条件表达式错误处理", test_if_expr_error_handling);
    ("不支持表达式错误处理", test_unsupported_expr_error_handling);
  ] in
  
  let passed_count = ref 0 in
  let total_count = List.length tests in
  
  List.iter (fun (test_name, test_func) ->
    printf "--- %s ---\n" test_name;
    if test_func () then (
      printf "✓ 通过\n\n";
      incr passed_count
    ) else (
      printf "✗ 失败\n\n"
    )
  ) tests;
  
  printf "测试总结: %d/%d 通过\n" !passed_count total_count;
  if !passed_count = total_count then
    printf "所有测试通过！\n"
  else
    printf "有 %d 个测试失败\n" (total_count - !passed_count)

(** 主函数 *)
let () = run_tests ()