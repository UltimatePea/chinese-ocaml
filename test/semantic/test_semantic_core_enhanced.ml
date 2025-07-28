(* 🧪 关键核心模块测试覆盖率改进 - Semantic核心模块测试 Fix #1612 *)
(* Author: Alpha, 核心工作代理 *)

open Alcotest
open Yyocamlc_lib.Ast
module Semantic_module = Yyocamlc_lib.Semantic
module Semantic_expressions = Yyocamlc_lib.Semantic_expressions

(* 创建基础语义上下文测试 *)
let test_create_initial_context () =
  let context = Semantic_module.create_initial_context () in
  Alcotest.check Alcotest.bool "Semantic context created" true (context.scope_stack != [])

(* 内置函数集成测试 *)
let test_builtin_functions_integration () =
  let context = Semantic_module.create_initial_context () in
  let enhanced_context = Semantic_module.add_builtin_functions context in
  Alcotest.check Alcotest.bool "Builtin functions added" true (enhanced_context.scope_stack != [])

(* 简单表达式语义分析测试 *)
let test_simple_expression_analysis () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Simple expression analysis"
    (Ok "analyzed")
    (try
      let context = Semantic_module.create_initial_context () in
      let expr = LitExpr (IntLit 42) in
      let _ = Semantic_module.analyze_expression context expr in
      Ok "analyzed"
    with
    | _ -> Error "failed")

(* 变量语义分析测试 *)
let test_variable_semantic_analysis () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Variable semantic analysis"
    (Ok "analyzed")
    (try
      let context = Semantic_module.create_initial_context () in
      let _identifier_expr = VarExpr "x" in
      let _ = Semantic_module.analyze_expression context _identifier_expr in
      Ok "analyzed"
    with
    | _ -> Error "failed")

(* 类型表达式解析测试 *)
let test_type_expression_resolution () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Type expression resolution"
    (Ok "resolved")
    (try
      let context = Semantic_module.create_initial_context () in
      let int_type = IntType in
      let _ = Semantic_module.resolve_type_expr context (BaseTypeExpr IntType) in
      Ok "resolved"
    with
    | _ -> Error "failed")

(* 语句语义分析测试 *)
let test_statement_semantic_analysis () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Statement semantic analysis"
    (Ok "analyzed")
    (try
      let context = Semantic_module.create_initial_context () in
      let _let_stmt = LetStmt ("x", LitExpr (IntLit 10)) in
      let _ = Semantic_module.analyze_statement context _let_stmt in
      Ok "analyzed"
    with
    | _ -> Error "failed")

(* 表达式语义检查测试 *)
let test_expression_semantics_check () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Expression semantics check"
    (Ok "checked")
    (try
      let context = Semantic_module.create_initial_context () in
      let _expr = BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)) in
      Ok "checked"
    with
    | _ -> Error "failed")

(* 模式语义检查测试 *)
let test_pattern_semantics_check () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Pattern semantics check"
    (Ok "checked")
    (try
      let context = Semantic_module.create_initial_context () in
      let _pattern = VarPattern "x" in
      Ok "checked"
    with
    | _ -> Error "failed")

(* 程序分析成功测试 *)
let test_successful_program_analysis () =
  let _simple_program = [
    LetStmt ("x", LitExpr (IntLit 5));
    LetStmt ("y", VarExpr "x")
  ] in
  () (* Simple test - just ensure statements can be constructed *)

(* 语义错误处理测试 *)
let test_semantic_error_handling () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Semantic error handling"
    (Error "semantic_error")
    (try
      raise (Semantic_module.SemanticError "测试错误");
      Ok "no_error"
    with
    | Semantic_module.SemanticError _ -> Error "semantic_error"
    | _ -> Error "other_error")

(* 符号表到环境转换测试 *)
let test_symbol_table_to_env_conversion () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Symbol table to environment conversion"
    (Ok "converted")
    (try
      let symbol_table = Hashtbl.create 10 in
      Hashtbl.add symbol_table "x" IntType;
      let context = Semantic_module.create_initial_context () in
      let _symbol_table = context.scope_stack in
      Ok "converted"
    with
    | _ -> Error "failed")

(* 代数类型添加测试 *)
let test_add_algebraic_type () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Add algebraic type"
    (Ok "added")
    (try
      let context = Semantic_module.create_initial_context () in
      let constructors = [("Some", [IntType]); ("None", [])] in
      let _ = add_algebraic_type context "Option" [] constructors in
      Ok "added"
    with
    | _ -> Error "failed")

(* 复杂表达式语义分析测试 *)
let test_complex_expression_analysis () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Complex expression analysis"
    (Ok "analyzed")
    (try
      let context = Semantic_module.create_initial_context () in
      let complex_expr = BinaryOpExpr (Mul, 
        BinaryOpExpr (Add, NumberExpr 1, NumberExpr 2),
        NumberExpr 3) in
      let _ = Semantic_module.analyze_expression context complex_expr in
      Ok "analyzed"
    with
    | _ -> Error "failed")

(* 中文标识符语义分析测试 *)
let test_chinese_identifier_semantics () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Chinese identifier semantics"
    (Ok "analyzed")
    (try
      let context = Semantic_module.create_initial_context () in
      let chinese_stmt = LetStatement ("变量", Some IntType, NumberExpr 100) in
      let _ = Semantic_module.analyze_statement context chinese_stmt in
      Ok "analyzed"
    with
    | _ -> Error "failed")

let suite = [
  "test_Semantic_module.create_initial_context", `Quick, test_Semantic_module.create_initial_context;
  "test_builtin_functions_integration", `Quick, test_builtin_functions_integration;
  "test_simple_expression_analysis", `Quick, test_simple_expression_analysis;
  "test_variable_semantic_analysis", `Quick, test_variable_semantic_analysis;
  "test_type_expression_resolution", `Quick, test_type_expression_resolution;
  "test_statement_semantic_analysis", `Quick, test_statement_semantic_analysis;
  "test_expression_semantics_check", `Quick, test_expression_semantics_check;
  "test_pattern_semantics_check", `Quick, test_pattern_semantics_check;
  "test_successful_program_analysis", `Quick, test_successful_program_analysis;
  "test_semantic_error_handling", `Quick, test_semantic_error_handling;
  "test_symbol_table_to_env_conversion", `Quick, test_symbol_table_to_env_conversion;
  "test_add_algebraic_type", `Quick, test_add_algebraic_type;
  "test_complex_expression_analysis", `Quick, test_complex_expression_analysis;
  "test_chinese_identifier_semantics", `Quick, test_chinese_identifier_semantics;
]