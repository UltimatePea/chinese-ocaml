(** 骆言编译器 - Token系统综合测试套件
    
    Phase T2测试实施：建立Token系统的系统性测试覆盖，
    专注于token_system核心模块的全面验证。
    
    @author Echo, 测试工程师
    @version 2.0
    @since 2025-07-26
    @phase T2
    @issues #1357, #1355 *)

open Alcotest

(** {1 Token系统核心模块测试} *)

(** 测试Token类型定义和基础操作 *)
let test_token_types_core () =
  (* 测试基础字面量类型 *)
  let int_literal = Token_system_core.Token_types.IntToken 42 in
  let float_literal = Token_system_core.Token_types.FloatToken 3.14 in
  let string_literal = Token_system_core.Token_types.StringToken "hello" in
  let bool_literal = Token_system_core.Token_types.BoolToken true in

  (* 验证字面量类型构造正确 *)
  check bool "IntToken construction" true (match int_literal with IntToken _ -> true | _ -> false);
  check bool "FloatToken construction" true
    (match float_literal with FloatToken _ -> true | _ -> false);
  check bool "StringToken construction" true
    (match string_literal with StringToken _ -> true | _ -> false);
  check bool "BoolToken construction" true
    (match bool_literal with BoolToken _ -> true | _ -> false)

(** 测试Token注册表功能 *)
let test_token_registry_operations () =
  (* 测试空注册表创建 *)
  let empty_registry = Token_system_core.Token_registry.create () in
  check int "empty registry size" 0 (Token_system_core.Token_registry.size empty_registry);

  (* 测试基础token注册 *)
  let registry = Token_system_core.Token_registry.create () in
  let registry = Token_system_core.Token_registry.register_keyword registry "let" "core.let" in
  check int "registry with one keyword" 1 (Token_system_core.Token_registry.size registry);

  (* 测试keyword查找 *)
  let found = Token_system_core.Token_registry.lookup_keyword registry "let" in
  check bool "keyword lookup success" true (Option.is_some found)

(** 测试Token转换器功能 *)
let test_token_conversion_system () =
  (* 测试关键字转换器 *)
  let keyword_result = Token_system_conversion.Keyword_converter.convert_let_keyword () in
  check bool "let keyword conversion" true
    (match keyword_result with Token_system_core.Token_types.CoreLanguage _ -> true | _ -> false);

  (* 测试标识符转换器 *)
  let identifier_result =
    Token_system_conversion.Identifier_converter.convert_simple_identifier "test_var"
  in
  check bool "identifier conversion" true
    (match identifier_result with
    | Token_system_core.Token_types.SimpleIdentifier _ -> true
    | _ -> false);

  (* 测试操作符转换器 *)
  let operator_result =
    Token_system_conversion.Operator_converter.convert_arithmetic_operator "+"
  in
  check bool "operator conversion" true
    (match operator_result with
    | Token_system_core.Token_types.ArithmeticOperator _ -> true
    | _ -> false)

(** 测试Token工具函数 *)
let test_token_utils_comprehensive () =
  (* 创建测试Token *)
  let literal_token =
    Token_system_compatibility.Legacy_type_bridge.make_literal_token
      (Token_system_compatibility.Legacy_type_bridge.convert_int_token 42)
  in
  let identifier_token =
    Token_system_compatibility.Legacy_type_bridge.make_identifier_token
      (Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier "test")
  in

  (* 测试Token分类工具 *)
  check bool "is_literal_token utility" true
    (Token_system_utils.Token_utils.is_literal literal_token);
  check bool "is_identifier_token utility" true
    (Token_system_utils.Token_utils.is_identifier identifier_token);
  check bool "is_literal false for identifier" false
    (Token_system_utils.Token_utils.is_literal identifier_token);

  (* 测试Token信息提取 *)
  let token_info = Token_system_utils.Token_utils.get_token_info literal_token in
  check string "token info type" "Literal" token_info.token_type;
  check bool "token info has position" true (Option.is_some token_info.position)

(** 测试Token错误处理 *)
let test_token_error_handling () =
  (* 测试无效Token类型错误 *)
  let error = Token_system_core.Token_errors.invalid_token_type "UnknownToken" in
  check bool "invalid token error created" true
    (match error with Token_system_core.Token_errors.InvalidTokenType _ -> true | _ -> false);

  (* 测试Token转换错误 *)
  let conversion_error = Token_system_core.Token_errors.conversion_failed "test" "reason" in
  check bool "conversion error created" true
    (match conversion_error with
    | Token_system_core.Token_errors.ConversionFailed _ -> true
    | _ -> false);

  (* 测试错误消息格式化 *)
  let error_msg = Token_system_core.Token_errors.format_error error in
  check bool "error message not empty" true (String.length error_msg > 0)

(** {1 集成测试} *)

(** 测试完整的Token处理流程 *)
let test_complete_token_processing_flow () =
  (* 创建一个简单的Token序列：let x = 42 *)
  let tokens =
    [
      Token_system_compatibility.Legacy_type_bridge.make_keyword_token
        (Token_system_compatibility.Legacy_type_bridge.convert_let_keyword ());
      Token_system_compatibility.Legacy_type_bridge.make_identifier_token
        (Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier "x");
      Token_system_compatibility.Legacy_type_bridge.make_operator_token
        (Token_system_compatibility.Legacy_type_bridge.convert_assign_op ());
      Token_system_compatibility.Legacy_type_bridge.make_literal_token
        (Token_system_compatibility.Legacy_type_bridge.convert_int_token 42);
    ]
  in

  (* 验证Token序列的正确性 *)
  check int "token sequence length" 4 (List.length tokens);

  (* 验证每个Token的类型 *)
  let keyword_token = List.nth tokens 0 in
  let identifier_token = List.nth tokens 1 in
  let operator_token = List.nth tokens 2 in
  let literal_token = List.nth tokens 3 in

  check bool "first token is keyword" true
    (Token_system_compatibility.Legacy_type_bridge.is_keyword_token keyword_token);
  check bool "second token is identifier" true
    (Token_system_compatibility.Legacy_type_bridge.is_identifier_token identifier_token);
  check bool "third token is operator" true
    (Token_system_compatibility.Legacy_type_bridge.is_operator_token operator_token);
  check bool "fourth token is literal" true
    (Token_system_compatibility.Legacy_type_bridge.is_literal_token literal_token)

(** 测试Token统计和分析功能 *)
let test_token_statistics_and_analysis () =
  (* 创建混合Token集合 *)
  let mixed_tokens =
    [
      Token_system_compatibility.Legacy_type_bridge.make_literal_token
        (Token_system_compatibility.Legacy_type_bridge.convert_int_token 1);
      Token_system_compatibility.Legacy_type_bridge.make_literal_token
        (Token_system_compatibility.Legacy_type_bridge.convert_int_token 2);
      Token_system_compatibility.Legacy_type_bridge.make_literal_token
        (Token_system_compatibility.Legacy_type_bridge.convert_string_token "hello");
      Token_system_compatibility.Legacy_type_bridge.make_identifier_token
        (Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier "var1");
      Token_system_compatibility.Legacy_type_bridge.make_identifier_token
        (Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier "var2");
      Token_system_compatibility.Legacy_type_bridge.make_keyword_token
        (Token_system_compatibility.Legacy_type_bridge.convert_let_keyword ());
    ]
  in

  (* 统计Token类型分布 *)
  let stats = Token_system_compatibility.Legacy_type_bridge.count_token_types mixed_tokens in

  (* 验证统计结果 *)
  let find_count type_name = try List.assoc type_name stats with Not_found -> 0 in

  check int "literal count in mixed tokens" 3 (find_count "Literal");
  check int "identifier count in mixed tokens" 2 (find_count "Identifier");
  check int "keyword count in mixed tokens" 1 (find_count "Keyword");

  (* 测试Token过滤功能 *)
  let literals_only = Token_system_utils.Token_utils.filter_by_type mixed_tokens "Literal" in
  check int "filtered literals count" 3 (List.length literals_only)

(** {1 性能测试} *)

(** 测试大规模Token操作性能 *)
let test_large_scale_token_operations () =
  let start_time = Sys.time () in

  (* 创建大量Token *)
  let large_token_set =
    List.init 10000 (fun i ->
        if i mod 3 = 0 then
          Token_system_compatibility.Legacy_type_bridge.make_literal_token
            (Token_system_compatibility.Legacy_type_bridge.convert_int_token i)
        else if i mod 3 = 1 then
          Token_system_compatibility.Legacy_type_bridge.make_identifier_token
            (Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier
               ("var" ^ string_of_int i))
        else
          Token_system_compatibility.Legacy_type_bridge.make_keyword_token
            (Token_system_compatibility.Legacy_type_bridge.convert_let_keyword ()))
  in

  (* 执行批量操作 *)
  let stats = Token_system_compatibility.Legacy_type_bridge.count_token_types large_token_set in
  let validation_result =
    Token_system_compatibility.Legacy_type_bridge.validate_token_stream large_token_set
  in

  let end_time = Sys.time () in
  let duration = end_time -. start_time in

  (* 验证操作结果 *)
  check int "large token set size" 10000 (List.length large_token_set);
  check bool "large token set validation" true validation_result;
  check bool "large scale operation performance" true (duration < 2.0);

  (* 应该在2秒内完成 *)

  (* 验证统计准确性 *)
  let literal_count, identifier_count, keyword_count =
    let find_count type_name = try List.assoc type_name stats with Not_found -> 0 in
    (find_count "Literal", find_count "Identifier", find_count "Keyword")
  in
  check bool "performance test statistics accuracy" true
    (literal_count + identifier_count + keyword_count = 10000)

(** {1 测试套件定义} *)

let core_system_tests =
  [
    test_case "token_types_core" `Quick test_token_types_core;
    test_case "token_registry_operations" `Quick test_token_registry_operations;
    test_case "token_conversion_system" `Quick test_token_conversion_system;
    test_case "token_utils_comprehensive" `Quick test_token_utils_comprehensive;
    test_case "token_error_handling" `Quick test_token_error_handling;
  ]

let integration_tests =
  [
    test_case "complete_token_processing_flow" `Quick test_complete_token_processing_flow;
    test_case "token_statistics_and_analysis" `Quick test_token_statistics_and_analysis;
  ]

let performance_tests =
  [ test_case "large_scale_token_operations" `Slow test_large_scale_token_operations ]

(** 运行所有综合测试 *)
let () =
  run "Token System Comprehensive Tests - Phase T2"
    [
      ("Core System Components", core_system_tests);
      ("Integration Testing", integration_tests);
      ("Performance Validation", performance_tests);
    ]
