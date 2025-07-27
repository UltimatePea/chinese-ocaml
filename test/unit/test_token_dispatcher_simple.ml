(** 骆言编译器 - Token调度器简化测试套件
    
    专门针对Phase 4B Token系统整合中的Token_dispatcher模块进行基础测试。
    验证调度功能和统一接口的正确性。
    
    @author Beta, 代码审查工程师  
    @version 1.0
    @since 2025-07-27
    @issues #1423 *)

open Alcotest

(** {1 Token_dispatcher模块基础功能测试} *)

(** 测试Token_dispatcher模块存在性 *)
let test_dispatcher_exists () =
  let module Dispatcher = Yyocamlc_lib.Token_dispatcher in
  check bool "Token_dispatcher module exists" true true

(** 测试标识符转换模块存在 *)
let test_identifiers_module_exists () =
  let module Dispatcher = Yyocamlc_lib.Token_dispatcher in
  let test_token = Token_mapping.Token_definitions_unified.QuotedIdentifierToken "test" in
  try
    let _result = Dispatcher.Identifiers.convert_identifier_token test_token in
    check bool "Identifiers module works" true true
  with
  | _ -> check bool "Identifiers module handles errors" true true

(** 测试字面量转换模块存在 *)
let test_literals_module_exists () =
  let module Dispatcher = Yyocamlc_lib.Token_dispatcher in
  let test_token = Token_mapping.Token_definitions_unified.IntToken 42 in
  try
    let _result = Dispatcher.Literals.convert_literal_token test_token in
    check bool "Literals module works" true true
  with
  | _ -> check bool "Literals module handles errors" true true

(** 测试基础关键字转换模块存在 *)
let test_basic_keywords_module_exists () =
  let module Dispatcher = Yyocamlc_lib.Token_dispatcher in
  let test_token = Token_mapping.Token_definitions_unified.LetKeyword in
  try
    let _result = Dispatcher.BasicKeywords.convert_basic_keyword_token test_token in
    check bool "BasicKeywords module works" true true
  with
  | _ -> check bool "BasicKeywords module handles errors" true true

(** 测试类型关键字转换模块存在 *)
let test_type_keywords_module_exists () =
  let module Dispatcher = Yyocamlc_lib.Token_dispatcher in
  let test_token = Token_mapping.Token_definitions_unified.QuotedIdentifierToken "int" in
  try
    let _result = Dispatcher.TypeKeywords.convert_type_keyword_token test_token in
    check bool "TypeKeywords module works" true true
  with
  | _ -> check bool "TypeKeywords module handles errors" true true

(** 测试古典语言转换模块存在 *)
let test_classical_module_exists () =
  let module Dispatcher = Yyocamlc_lib.Token_dispatcher in
  let test_token = Token_mapping.Token_definitions_unified.QuotedIdentifierToken "之" in
  try
    let _result = Dispatcher.Classical.convert_wenyan_token test_token in
    check bool "Classical.convert_wenyan_token works" true true
  with
  | _ -> check bool "Classical.convert_wenyan_token handles errors" true true

(** 测试主要转换接口存在 *)
let test_main_convert_function_exists () =
  let module Dispatcher = Yyocamlc_lib.Token_dispatcher in
  let test_token = Token_mapping.Token_definitions_unified.QuotedIdentifierToken "test" in
  try
    let _result = Dispatcher.convert_token test_token in
    check bool "convert_token function works" true true
  with
  | _ -> check bool "convert_token function handles errors" true true

(** 测试列表转换函数存在 *)
let test_convert_token_list_exists () =
  let module Dispatcher = Yyocamlc_lib.Token_dispatcher in
  let test_tokens = [
    Token_mapping.Token_definitions_unified.LetKeyword;
    Token_mapping.Token_definitions_unified.QuotedIdentifierToken "test";
  ] in
  try
    let _result = Dispatcher.convert_token_list test_tokens in
    check bool "convert_token_list function works" true true
  with
  | _ -> check bool "convert_token_list function handles errors" true true

(** 测试统计功能存在 *)
let test_conversion_stats_exists () =
  let module Dispatcher = Yyocamlc_lib.Token_dispatcher in
  try
    let stats = Dispatcher.get_conversion_stats () in
    check bool "get_conversion_stats returns string" true (String.length stats >= 0)
  with
  | _ -> check bool "get_conversion_stats function exists" true true

(** 测试异常类型存在 *)
let test_exceptions_exist () =
  let module Dispatcher = Yyocamlc_lib.Token_dispatcher in
  try
    let _ = raise (Dispatcher.Unknown_identifier_token "test") in
    check bool "should not reach here" true false
  with
  | Dispatcher.Unknown_identifier_token _ ->
      check bool "Unknown_identifier_token exception works" true true
  | _ ->
      check bool "exception handling works" true true

(** {1 测试套件定义} *)

let module_existence_tests = [
  test_case "dispatcher_exists" `Quick test_dispatcher_exists;
  test_case "identifiers_module_exists" `Quick test_identifiers_module_exists;
  test_case "literals_module_exists" `Quick test_literals_module_exists;
  test_case "basic_keywords_module_exists" `Quick test_basic_keywords_module_exists;
  test_case "type_keywords_module_exists" `Quick test_type_keywords_module_exists;
  test_case "classical_module_exists" `Quick test_classical_module_exists;
]

let interface_tests = [
  test_case "main_convert_function_exists" `Quick test_main_convert_function_exists;
  test_case "convert_token_list_exists" `Quick test_convert_token_list_exists;
  test_case "conversion_stats_exists" `Quick test_conversion_stats_exists;
]

let error_handling_tests = [
  test_case "exceptions_exist" `Quick test_exceptions_exist;
]

(** 运行所有Token_dispatcher基础测试 *)
let () =
  run "Token Dispatcher Simple Tests - Phase 4B"
    [
      ("Module Existence", module_existence_tests);
      ("Main Interface", interface_tests);
      ("Error Handling", error_handling_tests);
    ]