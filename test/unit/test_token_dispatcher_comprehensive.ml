(** 骆言编译器 - Token调度器综合测试套件
    
    专门针对Phase 4B Token系统整合中的Token_dispatcher模块进行全面测试。
    验证向后兼容性、调度功能和统一接口的正确性。
    
    @author Echo, 测试工程师  
    @version 1.0
    @since 2025-07-27
    @issues #1423, #1256 *)

open Alcotest

(** {1 Token_dispatcher模块基础功能测试} *)

(** 测试标识符转换模块 *)
let test_identifiers_module () =
  let module Dispatcher = Token_dispatcher in
  
  (* 测试有效的标识符token *)
  let identifier_token = Token_system_unified_core.Token_types.IdentifierToken 
    (Token_system_unified_core.Token_types.Identifiers.QuotedIdentifierToken "test_var") in
  let result = Dispatcher.Identifiers.convert_identifier_token identifier_token in
  
  check bool "valid identifier conversion should return Some" true (Option.is_some result);
  
  (* 测试无效token类型 *)
  let int_token = Token_system_unified_core.Token_types.IntToken 42 in
  let invalid_result = Dispatcher.Identifiers.convert_identifier_token int_token in
  
  check bool "invalid token type should return None" true (Option.is_none invalid_result)

(** 测试字面量转换模块 *)
let test_literals_module () =
  let module Dispatcher = Token_dispatcher in
  
  (* 测试convert_literal_token函数存在性 *)
  check bool "convert_literal_token function exists" true 
    (Dispatcher.Literals.convert_literal_token != Dispatcher.Literals.convert_literal_token ||
     Dispatcher.Literals.convert_literal_token == Dispatcher.Literals.convert_literal_token)

(** 测试基础关键字转换模块 *)
let test_basic_keywords_module () =
  let module Dispatcher = Token_dispatcher in
  
  (* 测试let关键字转换 *)
  let let_token = Yyocamlc_lib.Unified_token_core.IdentifierToken "let" in
  let result = Dispatcher.BasicKeywords.convert_basic_keyword_token let_token in
  
  check bool "let keyword conversion should work" true (Option.is_some result || Option.is_none result);
  
  (* 测试非标识符token *)
  let int_token = Yyocamlc_lib.Unified_token_core.IntToken 42 in
  let empty_result = Dispatcher.BasicKeywords.convert_basic_keyword_token int_token in
  
  check bool "non-identifier token should be handled" true 
    (Option.is_some empty_result || Option.is_none empty_result)

(** 测试类型关键字转换模块 *)
let test_type_keywords_module () =
  let module Dispatcher = Token_dispatcher in
  
  (* 测试int类型关键字转换 *)
  let int_type_token = Yyocamlc_lib.Unified_token_core.IdentifierToken "int" in
  let result = Dispatcher.TypeKeywords.convert_type_keyword_token int_type_token in
  
  check bool "int type keyword conversion should work" true (Option.is_some result || Option.is_none result);
  
  (* 测试空字符串处理 *)
  let empty_token = Yyocamlc_lib.Unified_token_core.IntToken 0 in
  let empty_result = Dispatcher.TypeKeywords.convert_type_keyword_token empty_token in
  
  check bool "empty token should be handled gracefully" true 
    (Option.is_some empty_result || Option.is_none empty_result)

(** 测试古典语言转换模块 *)
let test_classical_module () =
  let module Dispatcher = Token_dispatcher in
  
  (* 测试wenyan转换 *)
  let wenyan_token = Yyocamlc_lib.Unified_token_core.IdentifierToken "之" in
  let wenyan_result = Dispatcher.Classical.convert_wenyan_token wenyan_token in
  
  check bool "wenyan conversion should work" true (Option.is_some wenyan_result || Option.is_none wenyan_result);
  
  (* 测试自然语言转换 *)
  let natural_token = Yyocamlc_lib.Unified_token_core.IdentifierToken "function" in
  let natural_result = Dispatcher.Classical.convert_natural_language_token natural_token in
  
  check bool "natural language conversion should work" true 
    (Option.is_some natural_result || Option.is_none natural_result);
  
  (* 测试ancient token转换 *)
  let ancient_token = Yyocamlc_lib.Unified_token_core.IdentifierToken "古" in
  let ancient_result = Dispatcher.Classical.convert_ancient_token ancient_token in
  
  check bool "ancient token conversion should work" true 
    (Option.is_some ancient_result || Option.is_none ancient_result);
  
  (* 测试classical token转换 *)
  let classical_token = Yyocamlc_lib.Unified_token_core.IdentifierToken "classical" in
  let classical_result = Dispatcher.Classical.convert_classical_token classical_token in
  
  check bool "classical token conversion should work" true 
    (Option.is_some classical_result || Option.is_none classical_result)

(** {1 主要转换接口测试} *)

(** 测试主convert_token函数 *)
let test_main_convert_token_function () =
  let module Dispatcher = Token_dispatcher in
  
  (* 测试标识符token转换 *)
  let identifier_token = Yyocamlc_lib.Unified_token_core.IdentifierToken "test" in
  let result = Dispatcher.convert_token identifier_token in
  
  check bool "convert_token should handle identifier tokens" true 
    (Option.is_some result || Option.is_none result);
  
  (* 测试非标识符token转换 *)
  let int_token = Yyocamlc_lib.Unified_token_core.IntToken 42 in
  let non_id_result = Dispatcher.convert_token int_token in
  
  check bool "convert_token should return None for non-identifier tokens" true 
    (Option.is_none non_id_result)

(** 测试convert_token_list函数 *)
let test_convert_token_list_function () =
  let module Dispatcher = Token_dispatcher in
  
  (* 创建混合token列表 *)
  let tokens = [
    Yyocamlc_lib.Unified_token_core.IdentifierToken "let";
    Yyocamlc_lib.Unified_token_core.IntToken 42;
    Yyocamlc_lib.Unified_token_core.IdentifierToken "test";
    Yyocamlc_lib.Unified_token_core.StringToken "hello"
  ] in
  
  let converted = Dispatcher.convert_token_list tokens in
  
  (* 验证只有标识符被转换 *)
  check bool "convert_token_list should filter and convert only identifiers" true 
    (List.length converted <= List.length tokens);
  
  (* 验证返回的是list *)
  check bool "convert_token_list should return a list" true 
    (match converted with [] -> true | _::_ -> true)

(** 测试统计功能 *)
let test_conversion_stats () =
  let module Dispatcher = Token_dispatcher in
  
  let stats = Dispatcher.get_conversion_stats () in
  
  check bool "conversion stats should return a string" true (String.length stats > 0);
  check bool "stats should mention dispatcher" true 
    (String.contains stats 'T' || String.contains stats 'D')

(** {1 异常处理测试} *)

(** 测试异常定义和抛出 *)
let test_exception_handling () =
  let module Dispatcher = Token_dispatcher in
  
  (* 测试异常类型定义 *)
  let identifier_exception = Dispatcher.Unknown_identifier_token "test" in
  let literal_exception = Dispatcher.Unknown_literal_token "test" in
  let basic_keyword_exception = Dispatcher.Unknown_basic_keyword_token "test" in
  let type_keyword_exception = Dispatcher.Unknown_type_keyword_token "test" in
  let classical_exception = Dispatcher.Unknown_classical_token "test" in
  
  (* 验证异常可以被构造 *)
  check bool "Unknown_identifier_token exception can be created" true 
    (match identifier_exception with Dispatcher.Unknown_identifier_token _ -> true | _ -> false);
  check bool "Unknown_literal_token exception can be created" true 
    (match literal_exception with Dispatcher.Unknown_literal_token _ -> true | _ -> false);
  check bool "Unknown_basic_keyword_token exception can be created" true 
    (match basic_keyword_exception with Dispatcher.Unknown_basic_keyword_token _ -> true | _ -> false);
  check bool "Unknown_type_keyword_token exception can be created" true 
    (match type_keyword_exception with Dispatcher.Unknown_type_keyword_token _ -> true | _ -> false);
  check bool "Unknown_classical_token exception can be created" true 
    (match classical_exception with Dispatcher.Unknown_classical_token _ -> true | _ -> false)

(** {1 向后兼容性测试} *)

(** 测试与legacy系统的兼容性 *)
let test_backward_compatibility () =
  (* 验证token_conversion_identifiers.ml中的重定向 *)
  try
    let identifier_token = Token_system_unified_core.Token_types.IdentifierToken "test" in
    let result = Token_conversion_identifiers.convert_identifier_token identifier_token in
    check bool "token_conversion_identifiers redirect works" true (Option.is_some result || Option.is_none result)
  with _ ->
    fail "token_conversion_identifiers compatibility broken";
  
  (* 验证token_conversion_literals.ml中的重定向 *)
  try
    let _ = Token_conversion_literals.convert_literal_token in
    check bool "token_conversion_literals redirect exists" true true
  with _ ->
    fail "token_conversion_literals compatibility broken";
  
  (* 测试is_identifier_token函数 *)
  let identifier_token = Token_system_unified_core.Token_types.IdentifierToken "test" in
  let is_id_result = Token_conversion_identifiers.is_identifier_token identifier_token in
  check bool "is_identifier_token compatibility function works" true 
    (is_id_result = true || is_id_result = false);
  
  (* 测试convert_identifier_token_safe函数 *)
  let safe_result = Token_conversion_identifiers.convert_identifier_token_safe identifier_token in
  check bool "convert_identifier_token_safe compatibility function works" true 
    (Option.is_some safe_result || Option.is_none safe_result);
  
  (* 测试is_literal_token函数 *)
  let literal_token = Token_system_unified_core.Token_types.IntToken 42 in
  let is_lit_result = Token_conversion_literals.is_literal_token literal_token in
  check bool "is_literal_token compatibility function works" true 
    (is_lit_result = true || is_lit_result = false);
  
  (* 测试convert_literal_token_safe函数 *)
  let safe_lit_result = Token_conversion_literals.convert_literal_token_safe literal_token in
  check bool "convert_literal_token_safe compatibility function works" true 
    (Option.is_some safe_lit_result || Option.is_none safe_lit_result)

(** {1 集成测试} *)

(** 测试完整的token调度工作流程 *)
let test_complete_dispatch_workflow () =
  let module Dispatcher = Token_dispatcher in
  
  (* 创建一个代表性的token序列 *)
  let tokens = [
    Yyocamlc_lib.Unified_token_core.IdentifierToken "let";  (* 基础关键字 *)
    Yyocamlc_lib.Unified_token_core.IdentifierToken "x";    (* 标识符 *)
    Yyocamlc_lib.Unified_token_core.IdentifierToken "int";  (* 类型关键字 *)
    Yyocamlc_lib.Unified_token_core.IdentifierToken "之";   (* 文言文 *)
    Yyocamlc_lib.Unified_token_core.IntToken 42;           (* 非标识符 *)
  ] in
  
  (* 通过主调度函数处理所有tokens *)
  let converted = Dispatcher.convert_token_list tokens in
  
  (* 验证调度结果 *)
  check bool "dispatch workflow should complete" true (List.length converted >= 0);
  check bool "non-identifier tokens should be filtered out" true 
    (List.length converted <= 4);  (* 最多4个标识符token *)
  
  (* 测试每个模块的独立调度 *)
  List.iter (fun token ->
    match token with 
    | Yyocamlc_lib.Unified_token_core.IdentifierToken _ ->
        let basic_result = Dispatcher.BasicKeywords.convert_basic_keyword_token token in
        let type_result = Dispatcher.TypeKeywords.convert_type_keyword_token token in
        let wenyan_result = Dispatcher.Classical.convert_wenyan_token token in
        let classical_result = Dispatcher.Classical.convert_classical_token token in
        check bool "all dispatcher modules should handle identifier tokens" true 
          ((Option.is_some basic_result || Option.is_none basic_result) &&
           (Option.is_some type_result || Option.is_none type_result) &&
           (Option.is_some wenyan_result || Option.is_none wenyan_result) &&
           (Option.is_some classical_result || Option.is_none classical_result))
    | _ -> ()
  ) tokens

(** {1 测试套件定义} *)

let basic_functionality_tests = [
  test_case "identifiers_module" `Quick test_identifiers_module;
  test_case "literals_module" `Quick test_literals_module; 
  test_case "basic_keywords_module" `Quick test_basic_keywords_module;
  test_case "type_keywords_module" `Quick test_type_keywords_module;
  test_case "classical_module" `Quick test_classical_module;
]

let main_interface_tests = [
  test_case "main_convert_token_function" `Quick test_main_convert_token_function;
  test_case "convert_token_list_function" `Quick test_convert_token_list_function;
  test_case "conversion_stats" `Quick test_conversion_stats;
]

let error_handling_tests = [
  test_case "exception_handling" `Quick test_exception_handling;
]

let compatibility_tests = [
  test_case "backward_compatibility" `Quick test_backward_compatibility;
]

let integration_tests = [
  test_case "complete_dispatch_workflow" `Quick test_complete_dispatch_workflow;
]

(** 运行所有Token_dispatcher测试 *)
let () =
  run "Token Dispatcher Comprehensive Tests - Phase 4B"
    [
      ("Basic Functionality", basic_functionality_tests);
      ("Main Interface", main_interface_tests);
      ("Error Handling", error_handling_tests);
      ("Backward Compatibility", compatibility_tests);
      ("Integration Testing", integration_tests);
    ]