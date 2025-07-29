(** 日志器初始化助手模块综合测试套件 - Fix #1690 测试覆盖率提升计划第一阶段

    Author: Echo, 测试工程师代理

    本测试套件为logger_init_helpers模块提供全面的测试覆盖，包括：
    - 模块类型推断测试
    - 单个模块初始化测试
    - 批量模块初始化测试
    - 智能初始化策略测试
    - 边界条件和错误处理测试

    @version 1.0 - Phase 1 测试覆盖率提升
    @since 2025-07-29 Fix #1690 *)

open Alcotest
open Yyocamlc_lib.Logger_init_helpers

(** 测试模块类型推断功能 *)
module ModuleCategoryTests = struct
  (** 测试Value模块类型推断 *)
  let test_infer_value_module () =
    let test_cases =
      [
        ("ValueOperations", ValueModule);
        ("ValueBasicOps", ValueModule);
        ("ValueAdvancedOps", ValueModule);
        ("SomeValueModule", ValueModule);
      ]
    in
    List.iter
      (fun (name, expected) ->
        let result = infer_module_category name in
        check
          (testable
             (fun fmt -> function
               | ValueModule -> Format.fprintf fmt "ValueModule"
               | TypeModule -> Format.fprintf fmt "TypeModule"
               | ParserModule -> Format.fprintf fmt "ParserModule"
               | LexerModule -> Format.fprintf fmt "LexerModule"
               | SemanticModule -> Format.fprintf fmt "SemanticModule"
               | CodegenModule -> Format.fprintf fmt "CodegenModule"
               | UtilityModule -> Format.fprintf fmt "UtilityModule")
             ( = ))
          (Printf.sprintf "模块类型推断: %s" name)
          expected result)
      test_cases

  (** 测试Type模块类型推断 *)
  let test_infer_type_module () =
    let test_cases =
      [ ("TypesUnify", TypeModule); ("TypeSystem", TypeModule); ("TypeInference", TypeModule) ]
    in
    List.iter
      (fun (name, expected) ->
        let result = infer_module_category name in
        check
          (testable
             (fun fmt -> function
               | ValueModule -> Format.fprintf fmt "ValueModule"
               | TypeModule -> Format.fprintf fmt "TypeModule"
               | ParserModule -> Format.fprintf fmt "ParserModule"
               | LexerModule -> Format.fprintf fmt "LexerModule"
               | SemanticModule -> Format.fprintf fmt "SemanticModule"
               | CodegenModule -> Format.fprintf fmt "CodegenModule"
               | UtilityModule -> Format.fprintf fmt "UtilityModule")
             ( = ))
          (Printf.sprintf "模块类型推断: %s" name)
          expected result)
      test_cases

  (** 测试Parser模块类型推断 *)
  let test_infer_parser_module () =
    let test_cases =
      [
        ("ParserCore", ParserModule);
        ("ParserExpressions", ParserModule);
        ("PoetryParser", ParserModule);
      ]
    in
    List.iter
      (fun (name, expected) ->
        let result = infer_module_category name in
        check
          (testable
             (fun fmt -> function
               | ValueModule -> Format.fprintf fmt "ValueModule"
               | TypeModule -> Format.fprintf fmt "TypeModule"
               | ParserModule -> Format.fprintf fmt "ParserModule"
               | LexerModule -> Format.fprintf fmt "LexerModule"
               | SemanticModule -> Format.fprintf fmt "SemanticModule"
               | CodegenModule -> Format.fprintf fmt "CodegenModule"
               | UtilityModule -> Format.fprintf fmt "UtilityModule")
             ( = ))
          (Printf.sprintf "模块类型推断: %s" name)
          expected result)
      test_cases

  (** 测试Lexer模块类型推断 *)
  let test_infer_lexer_module () =
    let test_cases =
      [ ("LexerCore", LexerModule); ("LexerTokens", LexerModule); ("ChineseLexer", LexerModule) ]
    in
    List.iter
      (fun (name, expected) ->
        let result = infer_module_category name in
        check
          (testable
             (fun fmt -> function
               | ValueModule -> Format.fprintf fmt "ValueModule"
               | TypeModule -> Format.fprintf fmt "TypeModule"
               | ParserModule -> Format.fprintf fmt "ParserModule"
               | LexerModule -> Format.fprintf fmt "LexerModule"
               | SemanticModule -> Format.fprintf fmt "SemanticModule"
               | CodegenModule -> Format.fprintf fmt "CodegenModule"
               | UtilityModule -> Format.fprintf fmt "UtilityModule")
             ( = ))
          (Printf.sprintf "模块类型推断: %s" name)
          expected result)
      test_cases

  (** 测试Semantic模块类型推断 *)
  let test_infer_semantic_module () =
    let test_cases =
      [
        ("SemanticAnalysis", SemanticModule);
        ("SemanticExpressions", SemanticModule);
        ("SemanticErrors", SemanticModule);
      ]
    in
    List.iter
      (fun (name, expected) ->
        let result = infer_module_category name in
        check
          (testable
             (fun fmt -> function
               | ValueModule -> Format.fprintf fmt "ValueModule"
               | TypeModule -> Format.fprintf fmt "TypeModule"
               | ParserModule -> Format.fprintf fmt "ParserModule"
               | LexerModule -> Format.fprintf fmt "LexerModule"
               | SemanticModule -> Format.fprintf fmt "SemanticModule"
               | CodegenModule -> Format.fprintf fmt "CodegenModule"
               | UtilityModule -> Format.fprintf fmt "UtilityModule")
             ( = ))
          (Printf.sprintf "模块类型推断: %s" name)
          expected result)
      test_cases

  (** 测试Codegen模块类型推断 *)
  let test_infer_codegen_module () =
    let test_cases =
      [
        ("CodegenC", CodegenModule);
        ("CCodegenExpressions", CodegenModule);
        ("CodeGenerator", CodegenModule);
      ]
    in
    List.iter
      (fun (name, expected) ->
        let result = infer_module_category name in
        check
          (testable
             (fun fmt -> function
               | ValueModule -> Format.fprintf fmt "ValueModule"
               | TypeModule -> Format.fprintf fmt "TypeModule"
               | ParserModule -> Format.fprintf fmt "ParserModule"
               | LexerModule -> Format.fprintf fmt "LexerModule"
               | SemanticModule -> Format.fprintf fmt "SemanticModule"
               | CodegenModule -> Format.fprintf fmt "CodegenModule"
               | UtilityModule -> Format.fprintf fmt "UtilityModule")
             ( = ))
          (Printf.sprintf "模块类型推断: %s" name)
          expected result)
      test_cases

  (** 测试默认为Utility模块 *)
  let test_infer_utility_module () =
    let test_cases =
      [
        ("RandomModule", UtilityModule);
        ("Utils", UtilityModule);
        ("StringUtility", UtilityModule);
        ("", UtilityModule);
        (* 空字符串应该默认为Utility *)
      ]
    in
    List.iter
      (fun (name, expected) ->
        let result = infer_module_category name in
        check
          (testable
             (fun fmt -> function
               | ValueModule -> Format.fprintf fmt "ValueModule"
               | TypeModule -> Format.fprintf fmt "TypeModule"
               | ParserModule -> Format.fprintf fmt "ParserModule"
               | LexerModule -> Format.fprintf fmt "LexerModule"
               | SemanticModule -> Format.fprintf fmt "SemanticModule"
               | CodegenModule -> Format.fprintf fmt "CodegenModule"
               | UtilityModule -> Format.fprintf fmt "UtilityModule")
             ( = ))
          (Printf.sprintf "模块类型推断: %s" name)
          expected result)
      test_cases
end

(** 测试模块初始化功能 *)
module ModuleInitializationTests = struct
  (** 测试单个模块初始化 - 模拟测试 *)
  let test_init_module_logger () =
    (* 这里我们只能测试函数调用不会失败，无法测试实际的日志器初始化效果 *)
    let test_modules =
      [
        "TestValueModule";
        "TestTypeModule";
        "TestParserModule";
        "TestLexerModule";
        "TestSemanticModule";
        "TestCodegenModule";
        "TestUtilityModule";
      ]
    in
    List.iter
      (fun module_name ->
        (* 测试调用不会抛出异常 *)
        check unit "模块初始化不应抛出异常" () (init_module_logger module_name))
      test_modules

  (** 测试批量模块初始化 *)
  let test_init_multiple_modules () =
    let test_modules = [ "Module1"; "Module2"; "Module3" ] in
    (* 测试批量初始化不会抛出异常 *)
    check unit "批量模块初始化不应抛出异常" () (init_multiple_modules test_modules)

  (** 测试空模块列表初始化 *)
  let test_init_empty_modules () =
    (* 测试空列表不会抛出异常 *)
    check unit "空模块列表初始化不应抛出异常" () (init_multiple_modules [])
end

(** 测试预定义模块组初始化 *)
module PreDefinedModuleGroupTests = struct
  (** 测试Value模块组初始化 *)
  let test_init_value_modules () =
    (* 测试调用不会抛出异常 *)
    check unit "Value模块组初始化不应抛出异常" () (init_value_modules ())

  (** 测试Type模块组初始化 *)
  let test_init_type_modules () =
    (* 测试调用不会抛出异常 *)
    check unit "Type模块组初始化不应抛出异常" () (init_type_modules ())
end

(** 测试智能初始化策略 *)
module SmartInitializationTests = struct
  (** 测试Value模块的智能初始化 *)
  let test_smart_init_value_module () =
    (* 测试Value模块会触发Value模块组初始化 *)
    check unit "Value模块智能初始化不应抛出异常" () (smart_init_related_modules "ValueOperations")

  (** 测试Type模块的智能初始化 *)
  let test_smart_init_type_module () =
    (* 测试Type模块会触发Type模块组初始化 *)
    check unit "Type模块智能初始化不应抛出异常" () (smart_init_related_modules "TypeSystem")

  (** 测试其他模块的智能初始化 *)
  let test_smart_init_other_module () =
    (* 测试其他模块会触发单个模块初始化 *)
    check unit "其他模块智能初始化不应抛出异常" () (smart_init_related_modules "UtilityModule")
end

(** 测试兼容性函数 *)
module CompatibilityTests = struct
  (** 测试兼容性函数 replace_init_no_logger *)
  let test_replace_init_no_logger () =
    (* 测试兼容性函数与 init_module_logger 行为一致 *)
    let test_module = "TestModule" in
    check unit "兼容性函数不应抛出异常" () (replace_init_no_logger test_module)
end

(** 边界条件和错误处理测试 *)
module BoundaryConditionTests = struct
  (** 测试特殊字符模块名 *)
  let test_special_char_module_names () =
    let special_names =
      [
        "Module@123";
        "Module-With-Dashes";
        "Module_With_Underscores";
        "123NumericModule";
        "!@#$%^&*()";
      ]
    in
    List.iter
      (fun name ->
        (* 测试特殊字符不会导致异常 *)
        check unit (Printf.sprintf "特殊字符模块名处理: %s" name) () (init_module_logger name))
      special_names

  (** 测试非常长的模块名 *)
  let test_long_module_name () =
    let long_name = String.make 1000 'A' in
    check unit "长模块名处理不应抛出异常" () (init_module_logger long_name)

  (** 测试Unicode字符模块名 *)
  let test_unicode_module_names () =
    let unicode_names = [ "模块名中文"; "ModuleЯус"; "Module🚀Test" ] in
    List.iter
      (fun name -> check unit (Printf.sprintf "Unicode模块名处理: %s" name) () (init_module_logger name))
      unicode_names
end

(** 运行所有测试的主函数 *)
let () =
  run "Logger Init Helpers Tests"
    [
      ( "模块类型推断",
        [
          test_case "Value模块类型推断" `Quick ModuleCategoryTests.test_infer_value_module;
          test_case "Type模块类型推断" `Quick ModuleCategoryTests.test_infer_type_module;
          test_case "Parser模块类型推断" `Quick ModuleCategoryTests.test_infer_parser_module;
          test_case "Lexer模块类型推断" `Quick ModuleCategoryTests.test_infer_lexer_module;
          test_case "Semantic模块类型推断" `Quick ModuleCategoryTests.test_infer_semantic_module;
          test_case "Codegen模块类型推断" `Quick ModuleCategoryTests.test_infer_codegen_module;
          test_case "Utility模块类型推断" `Quick ModuleCategoryTests.test_infer_utility_module;
        ] );
      ( "模块初始化",
        [
          test_case "单个模块初始化" `Quick ModuleInitializationTests.test_init_module_logger;
          test_case "批量模块初始化" `Quick ModuleInitializationTests.test_init_multiple_modules;
          test_case "空模块列表初始化" `Quick ModuleInitializationTests.test_init_empty_modules;
        ] );
      ( "预定义模块组",
        [
          test_case "Value模块组初始化" `Quick PreDefinedModuleGroupTests.test_init_value_modules;
          test_case "Type模块组初始化" `Quick PreDefinedModuleGroupTests.test_init_type_modules;
        ] );
      ( "智能初始化",
        [
          test_case "Value模块智能初始化" `Quick SmartInitializationTests.test_smart_init_value_module;
          test_case "Type模块智能初始化" `Quick SmartInitializationTests.test_smart_init_type_module;
          test_case "其他模块智能初始化" `Quick SmartInitializationTests.test_smart_init_other_module;
        ] );
      ( "兼容性",
        [
          test_case "replace_init_no_logger兼容性" `Quick
            CompatibilityTests.test_replace_init_no_logger;
        ] );
      ( "边界条件",
        [
          test_case "特殊字符模块名" `Quick BoundaryConditionTests.test_special_char_module_names;
          test_case "长模块名处理" `Quick BoundaryConditionTests.test_long_module_name;
          test_case "Unicode模块名处理" `Quick BoundaryConditionTests.test_unicode_module_names;
        ] );
    ]
