(** 骆言编译器 - Token系统Phase T2测试套件
    
    Phase T2测试实施：扩展现有Token系统测试覆盖，
    专注于已验证可工作的compatibility bridge API。
    
    @author Echo, 测试工程师
    @version 2.1
    @since 2025-07-26
    @phase T2
    @issues #1357, #1355 *)

open Alcotest

(** 简化的literal_token测试类型 *)
let literal_token_testable = 
  let pp fmt = function
    | Token_system_core.Token_types.IntToken i -> Format.fprintf fmt "IntToken(%d)" i
    | Token_system_core.Token_types.FloatToken f -> Format.fprintf fmt "FloatToken(%f)" f
    | Token_system_core.Token_types.StringToken s -> Format.fprintf fmt "StringToken(%s)" s
    | Token_system_core.Token_types.BoolToken b -> Format.fprintf fmt "BoolToken(%b)" b
    | Token_system_core.Token_types.ChineseNumberToken s -> Format.fprintf fmt "ChineseNumberToken(%s)" s
  in
  testable pp (=)


(** {1 扩展的转换函数测试} *)

(** 测试所有基础字面量转换函数 *)
let test_all_literal_conversions () =
  (* 测试整数边界值 *)
  let max_int_token = Token_system_compatibility.Legacy_type_bridge.convert_int_token max_int in
  check literal_token_testable "convert max_int" (Token_system_core.Token_types.IntToken max_int) max_int_token;
  
  let min_int_token = Token_system_compatibility.Legacy_type_bridge.convert_int_token min_int in
  check literal_token_testable "convert min_int" (Token_system_core.Token_types.IntToken min_int) min_int_token;
  
  (* 测试浮点数边界值 *)
  let zero_float = Token_system_compatibility.Legacy_type_bridge.convert_float_token 0.0 in
  check literal_token_testable "convert 0.0" (Token_system_core.Token_types.FloatToken 0.0) zero_float;
  
  let negative_float = Token_system_compatibility.Legacy_type_bridge.convert_float_token (-3.14) in
  check literal_token_testable "convert negative float" (Token_system_core.Token_types.FloatToken (-3.14)) negative_float;
  
  (* 测试字符串边界情况 *)
  let empty_string = Token_system_compatibility.Legacy_type_bridge.convert_string_token "" in
  check literal_token_testable "convert empty string" (Token_system_core.Token_types.StringToken "") empty_string;
  
  let unicode_string = Token_system_compatibility.Legacy_type_bridge.convert_string_token "你好世界" in
  check literal_token_testable "convert unicode string" (Token_system_core.Token_types.StringToken "你好世界") unicode_string;
  
  (* 测试中文数字 *)
  let chinese_numbers = ["零"; "一"; "二"; "三"; "十"; "百"; "千"; "万"] in
  List.iteri (fun _i num ->
    let token = Token_system_compatibility.Legacy_type_bridge.convert_chinese_number_token num in
    check literal_token_testable ("convert chinese number " ^ num) 
      (Token_system_core.Token_types.ChineseNumberToken num) token
  ) chinese_numbers

(** 测试复合转换操作 *)
let test_compound_conversion_operations () =
  (* 测试多种类型的混合转换 *)
  let mixed_literals = [
    Token_system_compatibility.Legacy_type_bridge.convert_int_token 42;
    Token_system_compatibility.Legacy_type_bridge.convert_float_token 3.14;
    Token_system_compatibility.Legacy_type_bridge.convert_string_token "test";
    Token_system_compatibility.Legacy_type_bridge.convert_bool_token true;
    Token_system_compatibility.Legacy_type_bridge.convert_chinese_number_token "五";
  ] in
  
  (* 验证每个转换结果的正确性 *)
  check int "mixed literals count" 5 (List.length mixed_literals);
  
  (* 将字面量转换为Token *)
  let mixed_tokens = List.map (fun lit ->
    Token_system_compatibility.Legacy_type_bridge.make_literal_token lit
  ) mixed_literals in
  
  (* 验证所有Token都是Literal类型 *)
  List.iteri (fun i token ->
    check bool ("mixed token " ^ string_of_int i ^ " is literal") true
      (Token_system_compatibility.Legacy_type_bridge.is_literal_token token)
  ) mixed_tokens

(** 测试标识符转换的完整性 *)
let test_identifier_conversion_completeness () =
  (* 测试各种标识符类型 *)
  let simple_ids = ["x"; "variable"; "function_name"; "中文变量"; "测试标识符"] in
  
  List.iter (fun id_name ->
    let simple_id = Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier id_name in
    let token = Token_system_compatibility.Legacy_type_bridge.make_identifier_token simple_id in
    
    check bool (id_name ^ " is identifier token") true
      (Token_system_compatibility.Legacy_type_bridge.is_identifier_token token);
    check bool (id_name ^ " is not literal token") false  
      (Token_system_compatibility.Legacy_type_bridge.is_literal_token token)
  ) simple_ids

(** {1 批量操作测试} *)

(** 测试批量Token创建和验证 *)
let test_batch_token_operations () =
  (* 批量创建字面量Token *)
  let batch_literal_data = [
    ("int_1", `Int 1);
    ("int_100", `Int 100);
    ("float_pi", `Float 3.14159);
    ("string_hello", `String "hello");
    ("string_chinese", `String "中文");
    ("bool_true", `Bool true);
    ("bool_false", `Bool false);
  ] in
  
  let batch_tokens = Token_system_compatibility.Legacy_type_bridge.make_literal_tokens batch_literal_data in
  check int "batch tokens count" 7 (List.length batch_tokens);
  
  (* 验证所有Token都是字面量 *)
  List.iteri (fun i token ->
    check bool ("batch token " ^ string_of_int i ^ " is literal") true
      (Token_system_compatibility.Legacy_type_bridge.is_literal_token token)
  ) batch_tokens;
  
  (* 批量创建标识符Token *)
  let batch_identifiers = ["var1"; "var2"; "function1"; "中文函数"; "测试变量"] in
  let batch_id_tokens = Token_system_compatibility.Legacy_type_bridge.make_identifier_tokens batch_identifiers in
  check int "batch identifier tokens count" 5 (List.length batch_id_tokens);
  
  (* 验证所有Token都是标识符 *)
  List.iteri (fun i token ->
    check bool ("batch identifier " ^ string_of_int i ^ " is identifier") true
      (Token_system_compatibility.Legacy_type_bridge.is_identifier_token token)
  ) batch_id_tokens

(** 测试Token流验证的完整性 *)  
let test_token_stream_validation_extended () =
  (* 创建复杂的Token流 *)
  let complex_token_stream = [
    (* let keyword *)
    Token_system_compatibility.Legacy_type_bridge.make_core_language_token
      (Token_system_compatibility.Legacy_type_bridge.convert_let_keyword ());
    (* variable identifier *)
    Token_system_compatibility.Legacy_type_bridge.make_identifier_token
      (Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier "result");
    (* equal operator *)
    Token_system_compatibility.Legacy_type_bridge.make_operator_token
      (Token_system_compatibility.Legacy_type_bridge.convert_equal_op ());
    (* integer literal *)
    Token_system_compatibility.Legacy_type_bridge.make_literal_token
      (Token_system_compatibility.Legacy_type_bridge.convert_int_token 42);
    (* plus operator *)
    Token_system_compatibility.Legacy_type_bridge.make_operator_token
      (Token_system_compatibility.Legacy_type_bridge.convert_plus_op ());
    (* float literal *)
    Token_system_compatibility.Legacy_type_bridge.make_literal_token
      (Token_system_compatibility.Legacy_type_bridge.convert_float_token 3.14);
  ] in
  
  (* 验证Token流有效性 *)
  check bool "complex token stream valid" true
    (Token_system_compatibility.Legacy_type_bridge.validate_token_stream complex_token_stream);
  
  check int "complex token stream length" 6 (List.length complex_token_stream);
  
  (* 验证Token流的统计信息 *)
  let stream_stats = Token_system_compatibility.Legacy_type_bridge.count_token_types complex_token_stream in
  
  let find_count type_name =
    try List.assoc type_name stream_stats
    with Not_found -> 0
  in
  
  check int "keywords in complex stream" 1 (find_count "CoreLanguage");
  check int "identifiers in complex stream" 1 (find_count "Identifier");
  check int "operators in complex stream" 2 (find_count "Operator");
  check int "literals in complex stream" 2 (find_count "Literal")

(** {1 高级功能测试} *)

(** 测试Token推断的准确性 *)
let test_token_inference_accuracy () =
  (* 测试各种输入的Token推断 *)
  let test_inferences = [
    ("123", "literal", Token_system_compatibility.Legacy_type_bridge.is_literal_token);
    ("3.14", "literal", Token_system_compatibility.Legacy_type_bridge.is_literal_token);
    ("let", "keyword", Token_system_compatibility.Legacy_type_bridge.is_keyword_token);
    ("fun", "keyword", Token_system_compatibility.Legacy_type_bridge.is_keyword_token);
    ("if", "keyword", Token_system_compatibility.Legacy_type_bridge.is_keyword_token);
    ("variable_name", "identifier", Token_system_compatibility.Legacy_type_bridge.is_identifier_token);
    ("中文变量", "identifier", Token_system_compatibility.Legacy_type_bridge.is_identifier_token);
  ] in
  
  List.iter (fun (input, expected_type, check_fn) ->
    match Token_system_compatibility.Legacy_type_bridge.infer_token_from_string input with
    | Some token ->
        check bool (input ^ " should be inferred as " ^ expected_type) true (check_fn token)
    | None ->
        fail ("Failed to infer token for: " ^ input)
  ) test_inferences

(** 测试位置信息的完整处理 *)
let test_position_information_handling () =
  (* 测试各种位置信息 *)
  let positions = [
    (1, 1, 0);    (* 文件开始 *)
    (10, 25, 250); (* 中间位置 *)
    (100, 1, 2000); (* 行首 *)
    (50, 80, 4000); (* 行尾 *)
  ] in
  
  List.iter (fun (line, column, offset) ->
    let pos = Token_system_compatibility.Legacy_type_bridge.make_position ~line ~column ~offset in
    check int ("position line " ^ string_of_int line) line pos.Token_system_core.Token_types.line;
    check int ("position column " ^ string_of_int column) column pos.Token_system_core.Token_types.column;
    check int ("position offset " ^ string_of_int offset) offset pos.Token_system_core.Token_types.offset;
    
    (* 创建带位置信息的Token *)
    let token = Token_system_compatibility.Legacy_type_bridge.make_literal_token
      (Token_system_compatibility.Legacy_type_bridge.convert_int_token 42) in
    let positioned_token = Token_system_compatibility.Legacy_type_bridge.make_positioned_token
      ~token ~position:pos ~text:"42" in
    
    check int ("positioned token line " ^ string_of_int line) line 
      positioned_token.Token_system_core.Token_types.position.line;
    check string ("positioned token text at " ^ string_of_int line) "42" 
      positioned_token.Token_system_core.Token_types.text
  ) positions

(** {1 性能和压力测试} *)

(** 测试中等规模Token处理性能 *)
let test_medium_scale_token_performance () =
  let start_time = Sys.time () in
  
  (* 创建中等规模的Token集合 (5000个) *)
  let medium_token_set = List.init 5000 (fun i ->
    let token_type = i mod 4 in
    match token_type with
    | 0 -> Token_system_compatibility.Legacy_type_bridge.make_literal_token 
             (Token_system_compatibility.Legacy_type_bridge.convert_int_token i)
    | 1 -> Token_system_compatibility.Legacy_type_bridge.make_identifier_token
             (Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier ("var" ^ string_of_int i))
    | 2 -> Token_system_compatibility.Legacy_type_bridge.make_core_language_token
             (Token_system_compatibility.Legacy_type_bridge.convert_let_keyword ())
    | _ -> Token_system_compatibility.Legacy_type_bridge.make_operator_token
             (Token_system_compatibility.Legacy_type_bridge.convert_plus_op ())
  ) in
  
  (* 执行各种操作 *)
  let validation_result = Token_system_compatibility.Legacy_type_bridge.validate_token_stream medium_token_set in
  let stats = Token_system_compatibility.Legacy_type_bridge.count_token_types medium_token_set in
  
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  (* 验证结果 *)
  check int "medium scale token set size" 5000 (List.length medium_token_set);
  check bool "medium scale validation result" true validation_result;
  check bool "medium scale operation time reasonable" true (duration < 1.5);
  
  (* 验证统计准确性 *)
  let find_count type_name = try List.assoc type_name stats with Not_found -> 0 in
  let total_counted = find_count "Literal" + find_count "Identifier" + 
                     find_count "CoreLanguage" + find_count "Operator" in
  check int "medium scale statistics accuracy" 5000 total_counted

(** {1 测试套件定义} *)

let extended_conversion_tests = [
  test_case "all_literal_conversions" `Quick test_all_literal_conversions;
  test_case "compound_conversion_operations" `Quick test_compound_conversion_operations;
  test_case "identifier_conversion_completeness" `Quick test_identifier_conversion_completeness;
]

let batch_operation_tests = [
  test_case "batch_token_operations" `Quick test_batch_token_operations;
  test_case "token_stream_validation_extended" `Quick test_token_stream_validation_extended;
]

let advanced_feature_tests = [
  test_case "token_inference_accuracy" `Quick test_token_inference_accuracy;
  test_case "position_information_handling" `Quick test_position_information_handling;
]

let performance_tests = [
  test_case "medium_scale_token_performance" `Slow test_medium_scale_token_performance;
]

(** 运行所有Phase T2测试 *)
let () =
  run "Token System Phase T2 Tests - Extended Coverage" [
    ("Extended Conversion Tests", extended_conversion_tests);
    ("Batch Operation Tests", batch_operation_tests);
    ("Advanced Feature Tests", advanced_feature_tests);
    ("Performance Tests", performance_tests);
  ]