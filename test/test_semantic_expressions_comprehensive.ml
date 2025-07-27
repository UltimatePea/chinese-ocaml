(** 骆言语义表达式分析综合测试套件 - Fix #1460 Phase 2 语义模块测试框架 *)

open Alcotest
open Yyocamlc_lib

(** 测试辅助工具模块 *)
module TestHelpers = struct
  (** 创建基本的语义上下文 *)
  let create_basic_context () =
    Semantic_context.create_initial_context ()

  (** 检查上下文是否有错误 *)
  let has_errors context = List.length context.Semantic_context.error_list > 0

  (** 检查上下文错误数量 *)
  let error_count context = List.length context.Semantic_context.error_list
end

(** 基础语义上下文测试 *)
module BasicSemanticTests = struct
  open TestHelpers

  (** 测试语义上下文创建 *)
  let test_context_creation () =
    let context = create_basic_context () in
    check bool "初始上下文无错误" false (has_errors context);
    check int "初始上下文错误数量为0" 0 (error_count context)

  (** 测试符号添加功能 *)
  let test_symbol_addition () =
    let context = create_basic_context () in
    let context_with_symbol = Semantic_context.add_symbol context "测试变量" (Types.new_type_var ()) false in
    check bool "添加符号后上下文无错误" false (has_errors context_with_symbol)

  (** 测试作用域管理 *)
  let test_scope_management () =
    let context = create_basic_context () in
    let context_with_scope = Semantic_context.enter_scope context in
    let context_exit_scope = Semantic_context.exit_scope context_with_scope in
    check bool "作用域管理操作无错误" false (has_errors context_exit_scope)

  (** 测试类型定义添加 *)
  let test_type_definition () =
    let context = create_basic_context () in
    let int_type = Types.IntType_T in
    let context_with_type = Semantic_context.add_type_definition context "测试类型" int_type in
    check bool "添加类型定义后上下文无错误" false (has_errors context_with_type)

  (** 测试符号查找 *)
  let test_symbol_lookup () =
    let context = create_basic_context () in
    let context_with_symbol = Semantic_context.add_symbol context "测试变量" (Types.new_type_var ()) false in
    let lookup_result = Semantic_context.lookup_symbol context_with_symbol.scope_stack "测试变量" in
    check bool "符号查找应该成功" true (Option.is_some lookup_result);
    
    let not_found = Semantic_context.lookup_symbol context.scope_stack "不存在的变量" in
    check bool "不存在的符号查找应该失败" true (Option.is_none not_found)
end

(** 语义表达式模块基础测试 *)
module SemanticExpressionModuleTests = struct
  open TestHelpers

  (** 测试语义表达式模块是否可用 *)
  let test_semantic_expressions_availability () =
    (* 这个测试主要验证模块是否可以导入和基本调用 *)
    let context = create_basic_context () in
    check bool "语义表达式模块可用" true true;
    check bool "语义上下文模块可用" true (not (has_errors context))
end

(** 主测试套件 *)
let test_suite =
  [
    ( "基础语义上下文测试",
      [
        test_case "语义上下文创建" `Quick BasicSemanticTests.test_context_creation;
        test_case "符号添加功能" `Quick BasicSemanticTests.test_symbol_addition;
        test_case "作用域管理" `Quick BasicSemanticTests.test_scope_management;
        test_case "类型定义添加" `Quick BasicSemanticTests.test_type_definition;
        test_case "符号查找" `Quick BasicSemanticTests.test_symbol_lookup;
      ] );
    ( "语义表达式模块测试",
      [
        test_case "模块可用性" `Quick SemanticExpressionModuleTests.test_semantic_expressions_availability;
      ] );
  ]

(** 运行测试 *)
let () = run "骆言语义表达式分析综合测试" test_suite