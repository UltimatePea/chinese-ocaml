(** 骆言编译器 - Legacy Type Bridge 综合测试套件
    
    针对PR #1356引入的Legacy Type Bridge模块进行全面测试，
    确保新Token系统兼容性桥接层的正确性和稳定性。
    
    @author Echo, 测试工程师专员
    @version 1.0
    @since 2025-07-26
    @issue #1355 Phase 2 Token系统整合 *)

open Alcotest

(** {1 Legacy Type Bridge模块测试} *)

(** 测试基础字面量转换函数 *)
let test_literal_token_conversions () =
  (* 测试整数Token转换 *)
  let int_token = Token_system_compatibility.Legacy_type_bridge.convert_int_token 42 in
  check bool "整数Token转换正确性" true 
    (match int_token with Token_system_core.Token_types.IntToken 42 -> true | _ -> false);
  
  (* 测试浮点数Token转换 *)
  let float_token = Token_system_compatibility.Legacy_type_bridge.convert_float_token 3.14 in
  check bool "浮点数Token转换正确性" true
    (match float_token with Token_system_core.Token_types.FloatToken 3.14 -> true | _ -> false);
  
  (* 测试字符串Token转换 *)
  let string_token = Token_system_compatibility.Legacy_type_bridge.convert_string_token "骆言" in
  check bool "字符串Token转换正确性" true
    (match string_token with Token_system_core.Token_types.StringToken "骆言" -> true | _ -> false);
  
  (* 测试布尔Token转换 *)
  let bool_true_token = Token_system_compatibility.Legacy_type_bridge.convert_bool_token true in
  let bool_false_token = Token_system_compatibility.Legacy_type_bridge.convert_bool_token false in
  check bool "布尔true Token转换正确性" true
    (match bool_true_token with Token_system_core.Token_types.BoolToken true -> true | _ -> false);
  check bool "布尔false Token转换正确性" true
    (match bool_false_token with Token_system_core.Token_types.BoolToken false -> true | _ -> false);
  
  (* 测试中文数字Token转换 *)
  let chinese_num_token = Token_system_compatibility.Legacy_type_bridge.convert_chinese_number_token "四十二" in
  check bool "中文数字Token转换正确性" true
    (match chinese_num_token with Token_system_core.Token_types.ChineseNumberToken "四十二" -> true | _ -> false)

(** 测试标识符转换函数 *)
let test_identifier_token_conversions () =
  (* 测试简单标识符转换 *)
  let simple_id = Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier "变量名" in
  check bool "简单标识符转换正确性" true
    (match simple_id with Token_system_core.Token_types.SimpleIdentifier "变量名" -> true | _ -> false);
  
  (* 测试引用标识符转换 *)
  let quoted_id = Token_system_compatibility.Legacy_type_bridge.convert_quoted_identifier "引用变量" in
  check bool "引用标识符转换正确性" true
    (match quoted_id with Token_system_core.Token_types.QuotedIdentifierToken "引用变量" -> true | _ -> false);
  
  (* 测试特殊标识符转换 *)
  let special_id = Token_system_compatibility.Legacy_type_bridge.convert_special_identifier "__内部变量__" in
  check bool "特殊标识符转换正确性" true
    (match special_id with Token_system_core.Token_types.IdentifierTokenSpecial "__内部变量__" -> true | _ -> false)

(** 测试核心关键字转换函数 *)
let test_core_keyword_conversions () =
  (* 测试let关键字转换 *)
  let let_token = Token_system_compatibility.Legacy_type_bridge.convert_let_keyword () in
  check bool "let关键字转换正确性" true
    (match let_token with Token_system_core.Token_types.LetKeyword -> true | _ -> false);
  
  (* 测试fun关键字转换 *)
  let fun_token = Token_system_compatibility.Legacy_type_bridge.convert_fun_keyword () in
  check bool "fun关键字转换正确性" true
    (match fun_token with Token_system_core.Token_types.FunKeyword -> true | _ -> false);
  
  (* 测试if关键字转换 *)
  let if_token = Token_system_compatibility.Legacy_type_bridge.convert_if_keyword () in
  check bool "if关键字转换正确性" true
    (match if_token with Token_system_core.Token_types.IfKeyword -> true | _ -> false);
  
  (* 测试then关键字转换 *)
  let then_token = Token_system_compatibility.Legacy_type_bridge.convert_then_keyword () in
  check bool "then关键字转换正确性" true
    (match then_token with Token_system_core.Token_types.ThenKeyword -> true | _ -> false)

(** 测试操作符转换函数 *)
let test_operator_conversions () =
  (* 测试算术操作符转换 *)
  let plus_op = Token_system_compatibility.Legacy_type_bridge.convert_plus_op () in
  check bool "加法操作符转换正确性" true
    (match plus_op with Token_system_core.Token_types.Plus -> true | _ -> false);
  
  let minus_op = Token_system_compatibility.Legacy_type_bridge.convert_minus_op () in
  check bool "减法操作符转换正确性" true
    (match minus_op with Token_system_core.Token_types.Minus -> true | _ -> false);
  
  (* 测试乘法和除法操作符转换 *)
  let multiply_op = Token_system_compatibility.Legacy_type_bridge.convert_multiply_op () in
  check bool "乘法操作符转换正确性" true
    (match multiply_op with Token_system_core.Token_types.Multiply -> true | _ -> false);
  
  let divide_op = Token_system_compatibility.Legacy_type_bridge.convert_divide_op () in
  check bool "除法操作符转换正确性" true
    (match divide_op with Token_system_core.Token_types.Divide -> true | _ -> false);
  
  (* 测试等于操作符转换 *)
  let equal_op = Token_system_compatibility.Legacy_type_bridge.convert_equal_op () in
  check bool "等于操作符转换正确性" true
    (match equal_op with Token_system_core.Token_types.Equal -> true | _ -> false)

(** 测试分隔符转换函数 *)
let test_delimiter_conversions () =
  (* 测试括号分隔符转换 *)
  let left_paren = Token_system_compatibility.Legacy_type_bridge.convert_left_paren () in
  check bool "左括号转换正确性" true
    (match left_paren with Token_system_core.Token_types.LeftParen -> true | _ -> false);
  
  let right_paren = Token_system_compatibility.Legacy_type_bridge.convert_right_paren () in
  check bool "右括号转换正确性" true
    (match right_paren with Token_system_core.Token_types.RightParen -> true | _ -> false);
  
  (* 测试逗号和分号分隔符转换 *)
  let comma = Token_system_compatibility.Legacy_type_bridge.convert_comma () in
  check bool "逗号转换正确性" true
    (match comma with Token_system_core.Token_types.Comma -> true | _ -> false);
  
  let semicolon = Token_system_compatibility.Legacy_type_bridge.convert_semicolon () in
  check bool "分号转换正确性" true
    (match semicolon with Token_system_core.Token_types.Semicolon -> true | _ -> false)

(** 测试Token构造工具函数 *)
let test_token_construction_utilities () =
  (* 测试make_literal_token函数 *)
  let int_literal = Token_system_compatibility.Legacy_type_bridge.convert_int_token 123 in
  let literal_token = Token_system_compatibility.Legacy_type_bridge.make_literal_token int_literal in
  check bool "字面量Token构造正确性" true
    (Token_system_compatibility.Legacy_type_bridge.is_literal_token literal_token);
  
  (* 测试make_identifier_token函数 *)
  let simple_id = Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier "test_var" in
  let identifier_token = Token_system_compatibility.Legacy_type_bridge.make_identifier_token simple_id in
  check bool "标识符Token构造正确性" true
    (Token_system_compatibility.Legacy_type_bridge.is_identifier_token identifier_token);
  
  (* 测试make_core_language_token函数 (关键字) *)
  let let_keyword = Token_system_compatibility.Legacy_type_bridge.convert_let_keyword () in
  let keyword_token = Token_system_compatibility.Legacy_type_bridge.make_core_language_token let_keyword in
  check bool "关键字Token构造正确性" true
    (Token_system_compatibility.Legacy_type_bridge.is_keyword_token keyword_token)

(** 测试Token分类检查函数 *)
let test_token_classification_functions () =
  (* 创建不同类型的Token进行分类测试 *)
  let literal_token = Token_system_compatibility.Legacy_type_bridge.make_literal_token 
    (Token_system_compatibility.Legacy_type_bridge.convert_int_token 42) in
  let identifier_token = Token_system_compatibility.Legacy_type_bridge.make_identifier_token
    (Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier "test") in
  let keyword_token = Token_system_compatibility.Legacy_type_bridge.make_keyword_token
    (Token_system_compatibility.Legacy_type_bridge.convert_let_keyword ()) in
  let operator_token = Token_system_compatibility.Legacy_type_bridge.make_operator_token
    (Token_system_compatibility.Legacy_type_bridge.convert_plus_op ()) in
  let delimiter_token = Token_system_compatibility.Legacy_type_bridge.make_delimiter_token
    (Token_system_compatibility.Legacy_type_bridge.convert_comma ()) in
  
  (* 测试is_literal分类 *)
  check bool "字面量Token正确识别为literal" true
    (Token_system_compatibility.Legacy_type_bridge.is_literal literal_token);
  check bool "非字面量Token不被识别为literal" false
    (Token_system_compatibility.Legacy_type_bridge.is_literal identifier_token);
  
  (* 测试is_keyword分类 *)
  check bool "关键字Token正确识别为keyword" true
    (Token_system_compatibility.Legacy_type_bridge.is_keyword keyword_token);
  check bool "非关键字Token不被识别为keyword" false
    (Token_system_compatibility.Legacy_type_bridge.is_keyword literal_token);
  
  (* 测试is_operator分类 *)
  check bool "操作符Token正确识别为operator" true
    (Token_system_compatibility.Legacy_type_bridge.is_operator operator_token);
  check bool "非操作符Token不被识别为operator" false
    (Token_system_compatibility.Legacy_type_bridge.is_operator keyword_token);
  
  (* 测试is_delimiter分类 *)
  check bool "分隔符Token正确识别为delimiter" true
    (Token_system_compatibility.Legacy_type_bridge.is_delimiter delimiter_token);
  check bool "非分隔符Token不被识别为delimiter" false
    (Token_system_compatibility.Legacy_type_bridge.is_delimiter operator_token)

(** 测试批量处理工具函数 *)
let test_batch_processing_utilities () =
  (* 创建混合Token列表 *)
  let mixed_tokens = [
    Token_system_compatibility.Legacy_type_bridge.make_literal_token 
      (Token_system_compatibility.Legacy_type_bridge.convert_int_token 1);
    Token_system_compatibility.Legacy_type_bridge.make_literal_token 
      (Token_system_compatibility.Legacy_type_bridge.convert_int_token 2);
    Token_system_compatibility.Legacy_type_bridge.make_identifier_token
      (Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier "var1");
    Token_system_compatibility.Legacy_type_bridge.make_keyword_token
      (Token_system_compatibility.Legacy_type_bridge.convert_let_keyword ());
    Token_system_compatibility.Legacy_type_bridge.make_keyword_token
      (Token_system_compatibility.Legacy_type_bridge.convert_fun_keyword ());
  ] in
  
  (* 测试create_token_list函数 *)
  let token_list = Token_system_compatibility.Legacy_type_bridge.create_token_list mixed_tokens in
  check int "Token列表创建正确长度" 5 (List.length token_list);
  
  (* 测试count_token_types函数 *)
  let type_counts = Token_system_compatibility.Legacy_type_bridge.count_token_types mixed_tokens in
  let get_count type_name = 
    try List.assoc type_name type_counts 
    with Not_found -> 0 
  in
  check int "字面量Token数量统计正确" 2 (get_count "Literal");
  check int "标识符Token数量统计正确" 1 (get_count "Identifier");
  check int "关键字Token数量统计正确" 2 (get_count "Keyword");
  
  (* 测试validate_token_stream函数 *)
  let validation_result = Token_system_compatibility.Legacy_type_bridge.validate_token_stream mixed_tokens in
  check bool "Token流验证通过" true validation_result

(** 测试调试和诊断工具 *)
let test_debug_and_diagnostics () =
  let test_token = Token_system_compatibility.Legacy_type_bridge.make_literal_token 
    (Token_system_compatibility.Legacy_type_bridge.convert_string_token "调试测试") in
  
  (* 测试get_token_debug_info函数 *)
  let debug_info = Token_system_compatibility.Legacy_type_bridge.get_token_debug_info test_token in
  check bool "调试信息不为空" true (String.length debug_info > 0);
  check bool "调试信息包含Token类型" true (String.contains debug_info 'L'); (* Literal开头 *)
  
  (* 测试print_token_summary函数 *)
  let summary = Token_system_compatibility.Legacy_type_bridge.print_token_summary test_token in
  check bool "Token摘要不为空" true (String.length summary > 0)

(** 测试实验性功能 *)
let test_experimental_features () =
  (* 测试infer_token_type_from_string函数 *)
  let inferred_int = Token_system_compatibility.Legacy_type_bridge.infer_token_type_from_string "123" in
  check string "整数字符串类型推断" "Literal" inferred_int;
  
  let inferred_identifier = Token_system_compatibility.Legacy_type_bridge.infer_token_type_from_string "variable_name" in
  check string "标识符字符串类型推断" "Identifier" inferred_identifier;
  
  let inferred_keyword = Token_system_compatibility.Legacy_type_bridge.infer_token_type_from_string "let" in
  check string "关键字字符串类型推断" "Keyword" inferred_keyword

(** 测试边界条件和错误处理 *)
let test_edge_cases_and_error_handling () =
  (* 测试空字符串处理 *)
  let empty_string_token = Token_system_compatibility.Legacy_type_bridge.convert_string_token "" in
  check bool "空字符串Token转换" true
    (match empty_string_token with Token_system_core.Token_types.StringToken "" -> true | _ -> false);
  
  (* 测试极大整数处理 *)
  let max_int_token = Token_system_compatibility.Legacy_type_bridge.convert_int_token max_int in
  check bool "最大整数Token转换" true
    (match max_int_token with Token_system_core.Token_types.IntToken i when i = max_int -> true | _ -> false);
  
  (* 测试特殊浮点数处理 *)
  let nan_token = Token_system_compatibility.Legacy_type_bridge.convert_float_token nan in
  check bool "NaN浮点数Token转换" true
    (match nan_token with Token_system_core.Token_types.FloatToken f when Float.is_nan f -> true | _ -> false);
  
  (* 测试空Token列表处理 *)
  let empty_list_validation = Token_system_compatibility.Legacy_type_bridge.validate_token_stream [] in
  check bool "空Token列表验证通过" true empty_list_validation

(** {1 集成测试} *)

(** 测试完整Token处理工作流 *)
let test_complete_token_workflow () =
  (* 模拟一个简单的let表达式：let x = "hello" + "world" *)
  let workflow_tokens = [
    (* let关键字 *)
    Token_system_compatibility.Legacy_type_bridge.make_keyword_token
      (Token_system_compatibility.Legacy_type_bridge.convert_let_keyword ());
    (* 变量名x *)
    Token_system_compatibility.Legacy_type_bridge.make_identifier_token
      (Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier "x");
    (* 赋值操作符= *)
    Token_system_compatibility.Legacy_type_bridge.make_operator_token
      (Token_system_compatibility.Legacy_type_bridge.convert_assign_op ());
    (* 字符串"hello" *)
    Token_system_compatibility.Legacy_type_bridge.make_literal_token
      (Token_system_compatibility.Legacy_type_bridge.convert_string_token "hello");
    (* 加法操作符+ *)
    Token_system_compatibility.Legacy_type_bridge.make_operator_token
      (Token_system_compatibility.Legacy_type_bridge.convert_plus_op ());
    (* 字符串"world" *)
    Token_system_compatibility.Legacy_type_bridge.make_literal_token
      (Token_system_compatibility.Legacy_type_bridge.convert_string_token "world");
  ] in
  
  (* 验证整个工作流 *)
  check int "工作流Token数量正确" 6 (List.length workflow_tokens);
  
  (* 验证Token序列的语法正确性 *)
  let validation_result = Token_system_compatibility.Legacy_type_bridge.validate_token_stream workflow_tokens in
  check bool "工作流Token序列验证通过" true validation_result;
  
  (* 统计Token类型分布 *)
  let type_stats = Token_system_compatibility.Legacy_type_bridge.count_token_types workflow_tokens in
  let get_count type_name = try List.assoc type_name type_stats with Not_found -> 0 in
  check int "工作流中关键字数量" 1 (get_count "Keyword");
  check int "工作流中标识符数量" 1 (get_count "Identifier");
  check int "工作流中操作符数量" 2 (get_count "Operator");
  check int "工作流中字面量数量" 2 (get_count "Literal")

(** {1 测试套件定义} *)

let literal_conversion_tests = [
  test_case "字面量Token转换测试" `Quick test_literal_token_conversions;
]

let identifier_conversion_tests = [
  test_case "标识符Token转换测试" `Quick test_identifier_token_conversions;
]

let keyword_conversion_tests = [
  test_case "关键字Token转换测试" `Quick test_core_keyword_conversions;
]

let operator_conversion_tests = [
  test_case "操作符Token转换测试" `Quick test_operator_conversions;
]

let delimiter_conversion_tests = [
  test_case "分隔符Token转换测试" `Quick test_delimiter_conversions;
]

let utility_function_tests = [
  test_case "Token构造工具测试" `Quick test_token_construction_utilities;
  test_case "Token分类检查测试" `Quick test_token_classification_functions;
  test_case "批量处理工具测试" `Quick test_batch_processing_utilities;
  test_case "调试诊断工具测试" `Quick test_debug_and_diagnostics;
]

let experimental_feature_tests = [
  test_case "实验性功能测试" `Quick test_experimental_features;
]

let edge_case_tests = [
  test_case "边界条件和错误处理测试" `Quick test_edge_cases_and_error_handling;
]

let integration_tests = [
  test_case "完整Token工作流测试" `Quick test_complete_token_workflow;
]

(** 运行所有Legacy Type Bridge测试 *)
let () =
  run "Legacy Type Bridge 综合测试套件 - PR #1356" [
    ("字面量转换功能", literal_conversion_tests);
    ("标识符转换功能", identifier_conversion_tests);
    ("关键字转换功能", keyword_conversion_tests);
    ("操作符转换功能", operator_conversion_tests);
    ("分隔符转换功能", delimiter_conversion_tests);
    ("工具函数功能", utility_function_tests);
    ("实验性功能", experimental_feature_tests);
    ("边界条件处理", edge_case_tests);
    ("集成测试", integration_tests);
  ]