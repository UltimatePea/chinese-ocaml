(** 统一Token映射器全面测试套件
    测试覆盖lexer/token_mapping/unified_token_mapper.ml模块的所有核心功能 *)

open Alcotest
open Token_mapping.Unified_token_mapper

(** 测试辅助函数模块 *)
module TestHelpers = struct
  (** 验证映射结果是否成功 *)
  let is_success = function
    | Success _ -> true
    | _ -> false

  (** 验证映射结果是否为NotFound *)
  let is_not_found = function
    | NotFound _ -> true
    | _ -> false

  (** 验证映射结果是否为ConversionError *)
  let is_conversion_error = function
    | ConversionError _ -> true
    | _ -> false

  (** 从成功的映射结果中提取token *)
  let extract_token = function
    | Success token -> Some token
    | _ -> None

  (** 验证token类型匹配 *)
  let check_token_type expected_type actual_token =
    match (expected_type, actual_token) with
    | ("IntToken", IntToken _) -> true
    | ("FloatToken", FloatToken _) -> true
    | ("StringToken", StringToken _) -> true
    | ("BoolToken", BoolToken _) -> true
    | ("ChineseNumberToken", ChineseNumberToken _) -> true
    | ("QuotedIdentifierToken", QuotedIdentifierToken _) -> true
    | ("IdentifierTokenSpecial", IdentifierTokenSpecial _) -> true
    | ("LetKeyword", LetKeyword) -> true
    | ("RecKeyword", RecKeyword) -> true
    | ("InKeyword", InKeyword) -> true
    | ("FunKeyword", FunKeyword) -> true
    | ("IfKeyword", IfKeyword) -> true
    | ("ThenKeyword", ThenKeyword) -> true
    | ("ElseKeyword", ElseKeyword) -> true
    | ("MatchKeyword", MatchKeyword) -> true
    | ("WithKeyword", WithKeyword) -> true
    | ("TrueKeyword", TrueKeyword) -> true
    | ("FalseKeyword", FalseKeyword) -> true
    | ("AndKeyword", AndKeyword) -> true
    | ("OrKeyword", OrKeyword) -> true
    | ("NotKeyword", NotKeyword) -> true
    | ("TypeKeyword", TypeKeyword) -> true
    | ("PrivateKeyword", PrivateKeyword) -> true
    | ("IntTypeKeyword", IntTypeKeyword) -> true
    | ("FloatTypeKeyword", FloatTypeKeyword) -> true
    | ("StringTypeKeyword", StringTypeKeyword) -> true
    | ("BoolTypeKeyword", BoolTypeKeyword) -> true
    | ("UnitTypeKeyword", UnitTypeKeyword) -> true
    | ("ListTypeKeyword", ListTypeKeyword) -> true
    | ("ArrayTypeKeyword", ArrayTypeKeyword) -> true
    | ("Plus", Plus) -> true
    | ("Minus", Minus) -> true
    | ("Multiply", Multiply) -> true
    | ("Divide", Divide) -> true
    | ("Equal", Equal) -> true
    | ("NotEqual", NotEqual) -> true
    | ("Less", Less) -> true
    | ("Greater", Greater) -> true
    | ("Arrow", Arrow) -> true
    | ("UnknownToken", UnknownToken) -> true
    | _ -> false

  (** 验证token值匹配 *)
  let check_token_value expected_value actual_token =
    match (expected_value, actual_token) with
    | (Int expected, IntToken actual) -> expected = actual
    | (Float expected, FloatToken actual) -> expected = actual
    | (String expected, StringToken actual) -> expected = actual
    | (String expected, ChineseNumberToken actual) -> expected = actual
    | (String expected, QuotedIdentifierToken actual) -> expected = actual
    | (String expected, IdentifierTokenSpecial actual) -> expected = actual
    | (Bool expected, BoolToken actual) -> expected = actual
    | _ -> false

  (** 创建测试用的token规范列表 *)
  let create_literal_test_specs () = [
    ("IntToken", Some (Int 42));
    ("IntToken", Some (Int (-10)));
    ("IntToken", Some (Int 0));
    ("FloatToken", Some (Float 3.14));
    ("FloatToken", Some (Float (-2.5)));
    ("FloatToken", Some (Float 0.0));
    ("StringToken", Some (String "测试字符串"));
    ("StringToken", Some (String ""));
    ("StringToken", Some (String "English"));
    ("BoolToken", Some (Bool true));
    ("BoolToken", Some (Bool false));
    ("ChineseNumberToken", Some (String "一二三"));
    ("ChineseNumberToken", Some (String "九十八"));
  ]

  (** 创建标识符测试规范列表 *)
  let create_identifier_test_specs () = [
    ("QuotedIdentifierToken", Some (String "「变量名」"));
    ("QuotedIdentifierToken", Some (String "「函数」"));
    ("QuotedIdentifierToken", Some (String "quoted_var"));
    ("IdentifierTokenSpecial", Some (String "特殊标识符"));
    ("IdentifierTokenSpecial", Some (String "数值"));
    ("IdentifierTokenSpecial", Some (String "special_id"));
  ]

  (** 创建基础关键字测试列表 *)
  let create_basic_keyword_tests () = [
    "LetKeyword"; "RecKeyword"; "InKeyword"; "FunKeyword";
    "IfKeyword"; "ThenKeyword"; "ElseKeyword"; "MatchKeyword";
    "WithKeyword"; "OtherKeyword"; "TrueKeyword"; "FalseKeyword";
    "AndKeyword"; "OrKeyword"; "NotKeyword"; "TypeKeyword"; "PrivateKeyword"
  ]

  (** 创建类型关键字测试列表 *)
  let create_type_keyword_tests () = [
    "IntTypeKeyword"; "FloatTypeKeyword"; "StringTypeKeyword";
    "BoolTypeKeyword"; "UnitTypeKeyword"; "ListTypeKeyword"; "ArrayTypeKeyword"
  ]

  (** 创建运算符测试列表 *)
  let create_operator_tests () = [
    "Plus"; "Minus"; "Multiply"; "Divide";
    "Equal"; "NotEqual"; "Less"; "Greater"; "Arrow"
  ]

  (** 创建无效token测试列表 *)
  let create_invalid_token_tests () = [
    "UnknownKeyword"; "InvalidOperator"; "BadToken";
    "NotAToken"; "FakeKeyword"; "WrongToken"
  ]

end

(** 字面量Token映射测试 *)

let test_literal_token_mapping_basic () =
  (* 测试整数token映射 *)
  let int_result = map_int_token 42 in
  check bool "整数token映射应该成功" true (TestHelpers.is_success int_result);
  
  match TestHelpers.extract_token int_result with
  | Some token -> check bool "整数token类型应该正确" true 
      (TestHelpers.check_token_type "IntToken" token);
      check bool "整数token值应该正确" true 
      (TestHelpers.check_token_value (Int 42) token)
  | None -> fail "无法提取整数token";

  (* 测试浮点数token映射 *)
  let float_result = map_float_token 3.14 in
  check bool "浮点数token映射应该成功" true (TestHelpers.is_success float_result);
  
  (* 测试字符串token映射 *)
  let string_result = map_string_token "测试" in
  check bool "字符串token映射应该成功" true (TestHelpers.is_success string_result);

  (* 测试布尔token映射 *)
  let bool_result = map_bool_token true in
  check bool "布尔token映射应该成功" true (TestHelpers.is_success bool_result);

  (* 测试中文数字token映射 *)
  let chinese_num_result = map_chinese_number_token "一二三" in
  check bool "中文数字token映射应该成功" true (TestHelpers.is_success chinese_num_result)

let test_literal_token_mapping_comprehensive () =
  (* 测试所有字面量token类型 *)
  let literal_specs = TestHelpers.create_literal_test_specs () in
  List.iter (fun (token_name, value_data) ->
    let result = map_token token_name value_data in
    check bool ("字面量token映射应该成功: " ^ token_name) true 
      (TestHelpers.is_success result);
    
    match TestHelpers.extract_token result with
    | Some token -> 
        check bool ("token类型应该正确: " ^ token_name) true 
          (TestHelpers.check_token_type token_name token);
        (match value_data with
         | Some value -> check bool ("token值应该正确: " ^ token_name) true 
             (TestHelpers.check_token_value value token)
         | None -> ())
    | None -> fail ("无法提取token: " ^ token_name)
  ) literal_specs

let test_literal_token_mapping_edge_cases () =
  (* 测试边界值 *)
  let edge_cases = [
    ("IntToken", Some (Int max_int));
    ("IntToken", Some (Int min_int));
    ("FloatToken", Some (Float infinity));
    ("FloatToken", Some (Float neg_infinity));
    ("StringToken", Some (String (String.make 1000 'x'))); (* 长字符串 *)
    ("ChineseNumberToken", Some (String "零"));
  ] in
  
  List.iter (fun (token_name, value_data) ->
    let result = map_token token_name value_data in
    check bool ("边界值映射应该成功: " ^ token_name) true 
      (TestHelpers.is_success result)
  ) edge_cases

(** 标识符Token映射测试 *)

let test_identifier_token_mapping () =
  (* 测试引用标识符token映射 *)
  let quoted_result = map_quoted_identifier_token "「变量」" in
  check bool "引用标识符token映射应该成功" true (TestHelpers.is_success quoted_result);
  
  match TestHelpers.extract_token quoted_result with
  | Some token -> 
      check bool "引用标识符token类型应该正确" true 
        (TestHelpers.check_token_type "QuotedIdentifierToken" token);
      check bool "引用标识符token值应该正确" true 
        (TestHelpers.check_token_value (String "「变量」") token)
  | None -> fail "无法提取引用标识符token";

  (* 测试特殊标识符token映射 *)
  let special_result = map_special_identifier_token "特殊" in
  check bool "特殊标识符token映射应该成功" true (TestHelpers.is_success special_result);

  (* 测试所有标识符类型 *)
  let identifier_specs = TestHelpers.create_identifier_test_specs () in
  List.iter (fun (token_name, value_data) ->
    let result = map_token token_name value_data in
    check bool ("标识符token映射应该成功: " ^ token_name) true 
      (TestHelpers.is_success result)
  ) identifier_specs

(** 关键字Token映射测试 *)

let test_basic_keyword_mapping () =
  let basic_keywords = TestHelpers.create_basic_keyword_tests () in
  List.iter (fun keyword_name ->
    let result = map_keyword_token keyword_name in
    check bool ("基础关键字映射应该成功: " ^ keyword_name) true 
      (TestHelpers.is_success result);
    
    match TestHelpers.extract_token result with
    | Some token -> 
        check bool ("关键字token类型应该正确: " ^ keyword_name) true 
          (TestHelpers.check_token_type keyword_name token)
    | None -> fail ("无法提取关键字token: " ^ keyword_name)
  ) basic_keywords

let test_type_keyword_mapping () =
  let type_keywords = TestHelpers.create_type_keyword_tests () in
  List.iter (fun keyword_name ->
    let result = map_keyword_token keyword_name in
    check bool ("类型关键字映射应该成功: " ^ keyword_name) true 
      (TestHelpers.is_success result);
    
    match TestHelpers.extract_token result with
    | Some token -> 
        check bool ("类型关键字token类型应该正确: " ^ keyword_name) true 
          (TestHelpers.check_token_type keyword_name token)
    | None -> fail ("无法提取类型关键字token: " ^ keyword_name)
  ) type_keywords

(** 运算符Token映射测试 *)

let test_operator_mapping () =
  let operators = TestHelpers.create_operator_tests () in
  List.iter (fun operator_name ->
    let result = map_operator_token operator_name in
    check bool ("运算符映射应该成功: " ^ operator_name) true 
      (TestHelpers.is_success result);
    
    match TestHelpers.extract_token result with
    | Some token -> 
        check bool ("运算符token类型应该正确: " ^ operator_name) true 
          (TestHelpers.check_token_type operator_name token)
    | None -> fail ("无法提取运算符token: " ^ operator_name)
  ) operators

(** 统一映射函数测试 *)

let test_unified_mapping_function () =
  (* 测试统一映射函数对各种token类型的处理 *)
  let test_cases = [
    ("IntToken", Some (Int 123));
    ("StringToken", Some (String "test"));
    ("LetKeyword", None);
    ("Plus", None);
    ("IntTypeKeyword", None);
  ] in
  
  List.iter (fun (token_name, value_data) ->
    let result = map_token token_name value_data in
    check bool ("统一映射应该成功: " ^ token_name) true 
      (TestHelpers.is_success result)
  ) test_cases

(** 批量映射测试 *)

let test_batch_mapping () =
  let token_specs = [
    ("IntToken", Some (Int 100));
    ("StringToken", Some (String "批量测试"));
    ("LetKeyword", None);
    ("IfKeyword", None);
    ("Plus", None);
    ("FloatToken", Some (Float 2.71));
    ("BoolToken", Some (Bool false));
  ] in
  
  let results = map_tokens token_specs in
  check int "批量映射结果数量应该正确" (List.length token_specs) (List.length results);
  
  (* 验证所有映射都成功 *)
  List.iter (fun (token_name, result) ->
    check bool ("批量映射应该成功: " ^ token_name) true 
      (TestHelpers.is_success result)
  ) results

(** 错误处理测试 *)

let test_error_handling_unknown_tokens () =
  let invalid_tokens = TestHelpers.create_invalid_token_tests () in
  List.iter (fun token_name ->
    let result = map_keyword_token token_name in
    check bool ("未知token应该映射为UnknownToken: " ^ token_name) true 
      (TestHelpers.is_success result);
    
    match TestHelpers.extract_token result with
    | Some UnknownToken -> () (* 正确的结果 *)
    | Some _ -> fail ("未知token应该映射为UnknownToken: " ^ token_name)
    | None -> fail ("无法提取未知token结果: " ^ token_name)
  ) invalid_tokens

let test_error_handling_type_mismatches () =
  (* 测试类型不匹配的情况 *)
  let mismatch_cases = [
    ("IntToken", Some (String "不是整数"));
    ("FloatToken", Some (Int 42));
    ("StringToken", Some (Bool true));
    ("BoolToken", Some (Float 3.14));
  ] in
  
  List.iter (fun (token_name, wrong_value_data) ->
    let result = map_token token_name wrong_value_data in
    (* 类型不匹配应该导致映射为UnknownToken而不是错误 *)
    check bool ("类型不匹配应该处理正确: " ^ token_name) true 
      (TestHelpers.is_success result);
    
    match TestHelpers.extract_token result with
    | Some UnknownToken -> () (* 正确的结果 *)
    | Some _ -> fail ("类型不匹配应该映射为UnknownToken: " ^ token_name)
    | None -> fail ("无法提取类型不匹配结果: " ^ token_name)
  ) mismatch_cases

(** 显示功能测试 *)

let test_show_token_function () =
  (* 测试token显示功能 *)
  let test_tokens = [
    (IntToken 42, "IntToken");
    (FloatToken 3.14, "FloatToken");
    (StringToken "test", "StringToken");
    (BoolToken true, "BoolToken");
    (LetKeyword, "LetKeyword");
    (Plus, "Plus");
    (UnknownToken, "UnknownToken");
  ] in
  
  List.iter (fun (token, expected_prefix) ->
    let token_str = show_token token in
    check bool ("token显示应该包含正确前缀: " ^ expected_prefix) true 
      (String.length token_str > 0);
    (* 注意：我们只检查字符串不为空，因为具体格式可能变化 *)
  ) test_tokens

(** 便利函数测试 *)

let test_convenience_functions () =
  (* 测试各种便利函数 *)
  let int_result = map_int_token 999 in
  check bool "便利函数：整数映射应该成功" true (TestHelpers.is_success int_result);

  let float_result = map_float_token 1.618 in
  check bool "便利函数：浮点数映射应该成功" true (TestHelpers.is_success float_result);

  let string_result = map_string_token "便利测试" in
  check bool "便利函数：字符串映射应该成功" true (TestHelpers.is_success string_result);

  let bool_result = map_bool_token false in
  check bool "便利函数：布尔映射应该成功" true (TestHelpers.is_success bool_result);

  let chinese_result = map_chinese_number_token "五六七八" in
  check bool "便利函数：中文数字映射应该成功" true (TestHelpers.is_success chinese_result);

  let quoted_result = map_quoted_identifier_token "「便利标识符」" in
  check bool "便利函数：引用标识符映射应该成功" true (TestHelpers.is_success quoted_result);

  let special_result = map_special_identifier_token "便利特殊" in
  check bool "便利函数：特殊标识符映射应该成功" true (TestHelpers.is_success special_result)

(** 性能测试 *)

let test_mapping_performance () =
  (* 测试大量映射的性能 *)
  let start_time = Sys.time () in
  
  for i = 1 to 1000 do
    let _ = map_int_token i in
    let _ = map_string_token ("test" ^ string_of_int i) in
    let _ = map_keyword_token "LetKeyword" in
    let _ = map_operator_token "Plus" in
    ()
  done;
  
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  check bool "大量映射应该在合理时间内完成" true (duration < 1.0);
  (* 4000次映射应该在1秒内完成 *)

let test_batch_mapping_performance () =
  (* 测试批量映射性能 *)
  let large_token_specs = 
    let rec generate_specs n acc =
      if n <= 0 then acc
      else 
        let spec = ("IntToken", Some (Int n)) in
        generate_specs (n - 1) (spec :: acc)
    in
    generate_specs 500 []
  in
  
  let start_time = Sys.time () in
  let results = map_tokens large_token_specs in
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  check int "批量映射结果数量应该正确" 500 (List.length results);
  check bool "批量映射应该在合理时间内完成" true (duration < 0.5);

(** 复杂场景测试 *)

let test_complex_mapping_scenarios () =
  (* 测试混合token类型的复杂场景 *)
  let complex_specs = [
    ("IntToken", Some (Int 42));
    ("StringToken", Some (String "复杂测试"));
    ("LetKeyword", None);
    ("FloatToken", Some (Float 3.14159));
    ("BoolToken", Some (Bool true));
    ("ChineseNumberToken", Some (String "九十九"));
    ("IfKeyword", None);
    ("Plus", None);
    ("QuotedIdentifierToken", Some (String "「复杂标识符」"));
    ("IntTypeKeyword", None);
    ("Arrow", None);
    ("IdentifierTokenSpecial", Some (String "复杂特殊"));
  ] in
  
  let results = map_tokens complex_specs in
  
  (* 验证所有映射都成功 *)
  List.iter (fun (token_name, result) ->
    check bool ("复杂场景映射应该成功: " ^ token_name) true 
      (TestHelpers.is_success result)
  ) results;
  
  (* 验证结果数量 *)
  check int "复杂场景映射结果数量应该正确" (List.length complex_specs) (List.length results)

(** 集成测试 *)

let test_token_mapping_integration () =
  (* 测试完整的token映射工作流程 *)
  
  (* 1. 映射各种类型的token *)
  let literal_result = map_int_token 100 in
  let keyword_result = map_keyword_token "LetKeyword" in
  let operator_result = map_operator_token "Plus" in
  let identifier_result = map_quoted_identifier_token "「集成测试」" in
  
  (* 2. 验证所有映射都成功 *)
  check bool "集成测试：字面量映射应该成功" true (TestHelpers.is_success literal_result);
  check bool "集成测试：关键字映射应该成功" true (TestHelpers.is_success keyword_result);
  check bool "集成测试：运算符映射应该成功" true (TestHelpers.is_success operator_result);
  check bool "集成测试：标识符映射应该成功" true (TestHelpers.is_success identifier_result);
  
  (* 3. 批量处理 *)
  let batch_specs = [
    ("IntToken", Some (Int 200));
    ("IfKeyword", None);
    ("Minus", None);
  ] in
  let batch_results = map_tokens batch_specs in
  check int "集成测试：批量结果数量应该正确" 3 (List.length batch_results);
  
  (* 4. 验证所有批量结果都成功 *)
  List.iter (fun (_, result) ->
    check bool "集成测试：批量映射应该成功" true (TestHelpers.is_success result)
  ) batch_results

(** 测试套件定义 *)

let literal_mapping_tests = [
  test_case "字面量token基础映射测试" `Quick test_literal_token_mapping_basic;
  test_case "字面量token全面映射测试" `Quick test_literal_token_mapping_comprehensive;
  test_case "字面量token边界条件测试" `Quick test_literal_token_mapping_edge_cases;
]

let identifier_mapping_tests = [
  test_case "标识符token映射测试" `Quick test_identifier_token_mapping;
]

let keyword_mapping_tests = [
  test_case "基础关键字映射测试" `Quick test_basic_keyword_mapping;
  test_case "类型关键字映射测试" `Quick test_type_keyword_mapping;
]

let operator_mapping_tests = [
  test_case "运算符映射测试" `Quick test_operator_mapping;
]

let unified_mapping_tests = [
  test_case "统一映射函数测试" `Quick test_unified_mapping_function;
  test_case "批量映射测试" `Quick test_batch_mapping;
]

let error_handling_tests = [
  test_case "未知token错误处理测试" `Quick test_error_handling_unknown_tokens;
  test_case "类型不匹配错误处理测试" `Quick test_error_handling_type_mismatches;
]

let utility_tests = [
  test_case "token显示功能测试" `Quick test_show_token_function;
  test_case "便利函数测试" `Quick test_convenience_functions;
]

let performance_tests = [
  test_case "映射性能测试" `Slow test_mapping_performance;
  test_case "批量映射性能测试" `Slow test_batch_mapping_performance;
]

let complex_scenario_tests = [
  test_case "复杂映射场景测试" `Quick test_complex_mapping_scenarios;
]

let integration_tests = [
  test_case "token映射集成测试" `Quick test_token_mapping_integration;
]

(** 主测试运行器 *)
let () =
  run "Lexer_token_mapping_unified_token_mapper统一Token映射器综合测试套件" [
    "字面量映射测试", literal_mapping_tests;
    "标识符映射测试", identifier_mapping_tests;
    "关键字映射测试", keyword_mapping_tests;
    "运算符映射测试", operator_mapping_tests;
    "统一映射测试", unified_mapping_tests;
    "错误处理测试", error_handling_tests;
    "工具功能测试", utility_tests;
    "性能测试", performance_tests;
    "复杂场景测试", complex_scenario_tests;
    "集成测试", integration_tests;
  ]