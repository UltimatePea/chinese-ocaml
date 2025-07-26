(** 骆言编译器 - Legacy Type Bridge 综合测试套件
    
    针对Issue #1357中Delta专员指出的测试覆盖率不足问题，
    为legacy_type_bridge.ml模块提供完整的测试覆盖。
    
    @author Echo, 测试工程师
    @version 1.0
    @since 2025-07-26
    @issue #1357 *)

open Alcotest
open Token_system_core.Token_types
open Token_system_compatibility.Legacy_type_bridge

(** {1 测试辅助工具} *)

(** 生成测试用的位置信息 *)
let make_test_position line column offset =
  { line; column; offset }

(** 断言两个Token相等 *)
let token_testable = testable (fun fmt _ -> Format.fprintf fmt "Token") (=)

(** 生成大规模测试数据 *)
let generate_test_integers n =
  List.init n (fun i -> i * 7 + 3) (* 生成非平凡的整数序列 *)

(** 生成边界值测试数据 *)
let boundary_integers = [
  0; 1; -1; 
  max_int; min_int;
  42; -42;
  1000; -1000
]

let boundary_floats = [
  0.0; 1.0; -1.0;
  3.14159; -3.14159;
  1e10; 1e-10;
  infinity; neg_infinity
]

let test_strings = [
  ""; "hello"; "world";
  "中文测试"; "🎯测试";
  "带空格的字符串";
  "特殊字符!@#$%^&*()";
  String.make 1000 'x' (* 长字符串 *)
]

let chinese_numbers = [
  "一"; "二"; "三"; "四"; "五";
  "六"; "七"; "八"; "九"; "十";
  "一十二"; "二十三"; "一百";
  "三点一四"; "零点五"
]

(** {1 基础类型转换函数测试} *)

(** 整数Token转换测试 *)
let test_convert_int_token () =
  (* 基础整数转换 *)
  let result = convert_int_token 42 in
  check (testable (fun fmt -> function IntToken i -> Format.fprintf fmt "IntToken %d" i | _ -> Format.fprintf fmt "Other") (=)) "convert_int_token basic" (IntToken 42) result;
  
  (* 边界值测试 *)
  List.iter (fun i ->
    let result = convert_int_token i in
    check (testable (fun fmt -> function IntToken i -> Format.fprintf fmt "IntToken %d" i | _ -> Format.fprintf fmt "Other") (=)) ("convert_int_token boundary " ^ string_of_int i) (IntToken i) result
  ) boundary_integers

(** 浮点数Token转换测试 *)
let test_convert_float_token _ =
  (* 基础浮点数转换 *)
  let result = convert_float_token 3.14 in
  assert_equal (FloatToken 3.14) result;
  
  (* 边界值测试 *)
  List.iter (fun f ->
    let result = convert_float_token f in
    assert_equal (FloatToken f) result
  ) boundary_floats;
  
  (* 特殊浮点值测试 *)
  let nan_result = convert_float_token nan in
  match nan_result with
  | FloatToken f when classify_float f = FP_nan -> ()
  | _ -> assert_failure "NaN conversion failed"

(** 字符串Token转换测试 *)
let test_convert_string_token _ =
  List.iter (fun s ->
    let result = convert_string_token s in
    assert_equal (StringToken s) result
  ) test_strings

(** 布尔Token转换测试 *)  
let test_convert_bool_token _ =
  let true_result = convert_bool_token true in
  assert_equal (BoolToken true) true_result;
  
  let false_result = convert_bool_token false in
  assert_equal (BoolToken false) false_result

(** 中文数字Token转换测试 *)
let test_convert_chinese_number_token _ =
  List.iter (fun cn ->
    let result = convert_chinese_number_token cn in
    assert_equal (ChineseNumberToken cn) result
  ) chinese_numbers

(** {1 标识符转换函数测试} *)

let test_identifiers = [
  "hello"; "world"; "test_var";
  "CamelCase"; "snake_case"; "_private";
  "中文变量"; "混合_Chinese_标识符";
  "a"; String.make 100 'x' (* 长标识符 *)
]

(** 简单标识符转换测试 *)
let test_convert_simple_identifier _ =
  List.iter (fun id ->
    let result = convert_simple_identifier id in
    assert_equal (SimpleIdentifier id) result
  ) test_identifiers

(** 引用标识符转换测试 *)
let test_convert_quoted_identifier _ =
  List.iter (fun id ->
    let result = convert_quoted_identifier id in
    assert_equal (QuotedIdentifierToken id) result
  ) test_identifiers

(** 特殊标识符转换测试 *)
let test_convert_special_identifier _ =
  List.iter (fun id ->
    let result = convert_special_identifier id in
    assert_equal (IdentifierTokenSpecial id) result
  ) test_identifiers

(** {1 核心关键字转换函数测试} *)

(** 关键字转换测试 *)
let test_keyword_conversions _ =
  assert_equal LetKeyword (convert_let_keyword ());
  assert_equal FunKeyword (convert_fun_keyword ());
  assert_equal IfKeyword (convert_if_keyword ());
  assert_equal ThenKeyword (convert_then_keyword ());
  assert_equal ElseKeyword (convert_else_keyword ())

(** {1 操作符转换函数测试} *)

(** 操作符转换测试 *)
let test_operator_conversions _ =
  assert_equal Plus (convert_plus_op ());
  assert_equal Minus (convert_minus_op ());
  assert_equal Multiply (convert_multiply_op ());
  assert_equal Divide (convert_divide_op ());
  assert_equal Equal (convert_equal_op ())

(** {1 分隔符转换函数测试} *)

(** 分隔符转换测试 *)
let test_delimiter_conversions _ =
  assert_equal LeftParen (convert_left_paren ());
  assert_equal RightParen (convert_right_paren ());
  assert_equal Comma (convert_comma ());
  assert_equal Semicolon (convert_semicolon ())

(** {1 特殊Token转换函数测试} *)

(** 特殊Token转换测试 *)
let test_special_token_conversions _ =
  assert_equal EOF (convert_eof ());
  assert_equal Newline (convert_newline ());
  
  let comment_text = "this is a comment" in
  assert_equal (Comment comment_text) (convert_comment comment_text);
  
  let whitespace_text = "   \t  " in
  assert_equal (Whitespace whitespace_text) (convert_whitespace whitespace_text)

(** {1 统一Token构造函数测试} *)

(** 字面量Token构造测试 *)
let test_make_literal_token _ =
  let int_lit = convert_int_token 42 in
  let token = make_literal_token int_lit in
  assert_equal (Literal (IntToken 42)) token;
  
  let float_lit = convert_float_token 3.14 in  
  let token = make_literal_token float_lit in
  assert_equal (Literal (FloatToken 3.14)) token;
  
  let string_lit = convert_string_token "hello" in
  let token = make_literal_token string_lit in
  assert_equal (Literal (StringToken "hello")) token

(** 标识符Token构造测试 *)
let test_make_identifier_token _ =
  let simple_id = convert_simple_identifier "test" in
  let token = make_identifier_token simple_id in
  assert_equal (Identifier (SimpleIdentifier "test")) token;
  
  let quoted_id = convert_quoted_identifier "quoted" in
  let token = make_identifier_token quoted_id in
  assert_equal (Identifier (QuotedIdentifierToken "quoted")) token

(** 关键字Token构造测试 *)
let test_make_core_language_token _ =
  let let_kw = convert_let_keyword () in
  let token = make_core_language_token let_kw in
  assert_equal (CoreLanguage LetKeyword) token;
  
  let fun_kw = convert_fun_keyword () in
  let token = make_core_language_token fun_kw in
  assert_equal (CoreLanguage FunKeyword) token

(** 操作符Token构造测试 *)
let test_make_operator_token _ =
  let plus_op = convert_plus_op () in
  let token = make_operator_token plus_op in
  assert_equal (Operator Plus) token;
  
  let equal_op = convert_equal_op () in
  let token = make_operator_token equal_op in
  assert_equal (Operator Equal) token

(** 分隔符Token构造测试 *)
let test_make_delimiter_token _ =
  let left_paren = convert_left_paren () in
  let token = make_delimiter_token left_paren in
  assert_equal (Delimiter LeftParen) token;
  
  let comma = convert_comma () in
  let token = make_delimiter_token comma in
  assert_equal (Delimiter Comma) token

(** 特殊Token构造测试 *)
let test_make_special_token _ =
  let eof = convert_eof () in
  let token = make_special_token eof in
  assert_equal (Special EOF) token;
  
  let comment = convert_comment "test comment" in
  let token = make_special_token comment in
  assert_equal (Special (Comment "test comment")) token

(** {1 位置信息处理测试} *)

(** 位置信息创建测试 *)
let test_make_position _ =
  let pos = make_position ~line:10 ~column:5 ~offset:100 in
  assert_equal 10 pos.line;
  assert_equal 5 pos.column;
  assert_equal 100 pos.offset

(** 带位置Token创建测试 *)
let test_make_positioned_token _ =
  let token = make_literal_token (convert_int_token 42) in
  let position = make_position ~line:1 ~column:1 ~offset:0 in
  let positioned = make_positioned_token ~token ~position ~text:"42" in
  
  assert_equal token positioned.token;
  assert_equal position positioned.position;
  assert_equal "42" positioned.text

(** {1 Token类别检查工具测试} *)

(** Token类别获取测试 *)
let test_get_token_category _ =
  let literal = make_literal_token (convert_int_token 42) in
  assert_equal CategoryLiteral (get_token_category literal);
  
  let identifier = make_identifier_token (convert_simple_identifier "test") in
  assert_equal CategoryIdentifier (get_token_category identifier);
  
  let keyword = make_core_language_token (convert_let_keyword ()) in
  assert_equal CategoryKeyword (get_token_category keyword);
  
  let operator = make_operator_token (convert_plus_op ()) in
  assert_equal CategoryOperator (get_token_category operator);
  
  let delimiter = make_delimiter_token (convert_left_paren ()) in
  assert_equal CategoryDelimiter (get_token_category delimiter);
  
  let special = make_special_token (convert_eof ()) in
  assert_equal CategorySpecial (get_token_category special)

(** Token类型检查函数测试 *)
let test_token_type_checks _ =
  let literal = make_literal_token (convert_int_token 42) in
  assert_bool "is_literal_token failed" (is_literal_token literal);
  assert_bool "is_identifier_token should be false" (not (is_identifier_token literal));
  
  let identifier = make_identifier_token (convert_simple_identifier "test") in
  assert_bool "is_identifier_token failed" (is_identifier_token identifier);
  assert_bool "is_literal_token should be false" (not (is_literal_token identifier));
  
  let keyword = make_core_language_token (convert_let_keyword ()) in
  assert_bool "is_keyword_token failed" (is_keyword_token keyword);
  assert_bool "is_operator_token should be false" (not (is_operator_token keyword));
  
  let operator = make_operator_token (convert_plus_op ()) in
  assert_bool "is_operator_token failed" (is_operator_token operator);
  assert_bool "is_delimiter_token should be false" (not (is_delimiter_token operator));
  
  let delimiter = make_delimiter_token (convert_left_paren ()) in
  assert_bool "is_delimiter_token failed" (is_delimiter_token delimiter);
  assert_bool "is_special_token should be false" (not (is_special_token delimiter));
  
  let special = make_special_token (convert_eof ()) in
  assert_bool "is_special_token failed" (is_special_token special);
  assert_bool "is_literal_token should be false" (not (is_literal_token special))

(** {1 调试和诊断工具测试} *)

(** Token类型名称测试 *)
let test_token_type_name _ =
  let test_cases = [
    (make_literal_token (convert_int_token 42), "Literal");
    (make_identifier_token (convert_simple_identifier "test"), "Identifier");
    (make_core_language_token (convert_let_keyword ()), "CoreLanguage");
    (make_operator_token (convert_plus_op ()), "Operator");
    (make_delimiter_token (convert_left_paren ()), "Delimiter");
    (make_special_token (convert_eof ()), "Special");
  ] in
  List.iter (fun (token, expected_name) ->
    assert_equal expected_name (token_type_name token)
  ) test_cases

(** Token统计功能测试 *)
let test_count_token_types _ =
  let tokens = [
    make_literal_token (convert_int_token 1);
    make_literal_token (convert_int_token 2);
    make_operator_token (convert_plus_op ());
    make_identifier_token (convert_simple_identifier "x");
    make_special_token (convert_eof ());
  ] in
  
  let counts = count_token_types tokens in
  let find_count name = 
    List.assoc name counts 
  in
  
  assert_equal 2 (find_count "Literal");
  assert_equal 1 (find_count "Operator");
  assert_equal 1 (find_count "Identifier");
  assert_equal 1 (find_count "Special")

(** {1 批量处理工具测试} *)

(** 批量字面量Token创建测试 *)
let test_make_literal_tokens _ =
  let values = [
    ("int1", `Int 42);
    ("float1", `Float 3.14);
    ("string1", `String "hello");
    ("bool1", `Bool true);
  ] in
  
  let tokens = make_literal_tokens values in
  assert_equal 4 (List.length tokens);
  
  (* 验证第一个Token *)
  match List.hd tokens with
  | Literal (IntToken 42) -> ()
  | _ -> assert_failure "First token incorrect";
  
  (* 验证最后一个Token *)
  match List.rev tokens |> List.hd with
  | Literal (BoolToken true) -> ()
  | _ -> assert_failure "Last token incorrect"

(** 批量标识符Token创建测试 *)
let test_make_identifier_tokens _ =
  let names = ["var1"; "var2"; "function_name"; "中文变量"] in
  let tokens = make_identifier_tokens names in
  
  assert_equal 4 (List.length tokens);
  List.iter2 (fun name token ->
    match token with
    | Identifier (SimpleIdentifier id) -> assert_equal name id
    | _ -> assert_failure "Invalid identifier token"
  ) names tokens

(** {1 实验性转换功能测试} *)

(** 字符串推断Token类型测试 *)
let test_infer_token_from_string _ =
  (* 测试整数推断 *)
  (match infer_token_from_string "42" with
   | Some (Literal (IntToken 42)) -> ()
   | _ -> assert_failure "Integer inference failed");
  
  (* 测试浮点数推断 *)
  (match infer_token_from_string "3.14" with
   | Some (Literal (FloatToken 3.14)) -> ()
   | _ -> assert_failure "Float inference failed");
  
  (* 测试关键字推断 *)
  (match infer_token_from_string "let" with
   | Some (CoreLanguage LetKeyword) -> ()
   | _ -> assert_failure "Keyword inference failed");
  
  (* 测试中文关键字推断 *)
  (match infer_token_from_string "让" with
   | Some (CoreLanguage LetKeyword) -> ()
   | _ -> assert_failure "Chinese keyword inference failed");
  
  (* 测试操作符推断 *)
  (match infer_token_from_string "+" with
   | Some (Operator Plus) -> ()
   | _ -> assert_failure "Operator inference failed");
  
  (* 测试标识符推断 *)
  (match infer_token_from_string "variable_name" with
   | Some (Identifier (SimpleIdentifier "variable_name")) -> ()
   | _ -> assert_failure "Identifier inference failed")

(** Token流验证测试 *)
let test_validate_token_stream _ =
  let valid_tokens = [
    make_literal_token (convert_int_token 42);
    make_operator_token (convert_plus_op ());
    make_literal_token (convert_int_token 3);
    make_special_token (convert_eof ());
  ] in
  
  assert_bool "Valid token stream validation failed" 
    (validate_token_stream valid_tokens);
  
  (* 测试空Token流 *)
  assert_bool "Empty token stream validation failed"
    (validate_token_stream [])

(** {1 边界条件和错误处理测试} *)

(** 空字符串处理测试 *)
let test_empty_string_handling _ =
  let empty_string_token = convert_string_token "" in
  assert_equal (StringToken "") empty_string_token;
  
  let empty_identifier = convert_simple_identifier "" in
  assert_equal (SimpleIdentifier "") empty_identifier

(** 极大值处理测试 *)
let test_large_values _ =
  (* 测试大整数 *)
  let large_int = max_int in
  let result = convert_int_token large_int in
  assert_equal (IntToken large_int) result;
  
  (* 测试长字符串 *)
  let long_string = String.make 10000 'x' in
  let result = convert_string_token long_string in
  assert_equal (StringToken long_string) result

(** 性能压力测试 *)
let test_performance_stress _ =
  (* 大量Token转换性能测试 *)
  let start_time = Sys.time () in
  
  for i = 1 to 1000 do
    let _ = convert_int_token i in
    let _ = convert_string_token (string_of_int i) in
    let _ = make_literal_token (convert_int_token i) in
    ()
  done;
  
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  (* 期望在合理时间内完成 *)
  assert_bool "Performance test took too long" (duration < 1.0)

(** {1 往返转换一致性测试} *)

(** 基础往返转换测试 *)
let test_roundtrip_consistency _ =
  (* 测试整数往返转换 *)
  let original_int = 42 in
  let converted = convert_int_token original_int in
  let token = make_literal_token converted in
  (match token with
   | Literal (IntToken i) -> assert_equal original_int i
   | _ -> assert_failure "Integer roundtrip failed");
  
  (* 测试字符串往返转换 *)
  let original_string = "test_string" in
  let converted = convert_string_token original_string in
  let token = make_literal_token converted in
  (match token with
   | Literal (StringToken s) -> assert_equal original_string s
   | _ -> assert_failure "String roundtrip failed")

(** {1 测试套件组装} *)

let conversion_tests = "Basic Conversion Tests" >::: [
  "test_convert_int_token" >:: test_convert_int_token;
  "test_convert_float_token" >:: test_convert_float_token;
  "test_convert_string_token" >:: test_convert_string_token;
  "test_convert_bool_token" >:: test_convert_bool_token;
  "test_convert_chinese_number_token" >:: test_convert_chinese_number_token;
]

let identifier_tests = "Identifier Conversion Tests" >::: [
  "test_convert_simple_identifier" >:: test_convert_simple_identifier;
  "test_convert_quoted_identifier" >:: test_convert_quoted_identifier;
  "test_convert_special_identifier" >:: test_convert_special_identifier;
]

let keyword_tests = "Keyword Conversion Tests" >::: [
  "test_keyword_conversions" >:: test_keyword_conversions;
]

let operator_tests = "Operator Conversion Tests" >::: [
  "test_operator_conversions" >:: test_operator_conversions;
]

let delimiter_tests = "Delimiter Conversion Tests" >::: [
  "test_delimiter_conversions" >:: test_delimiter_conversions;
]

let special_tests = "Special Token Conversion Tests" >::: [
  "test_special_token_conversions" >:: test_special_token_conversions;
]

let construction_tests = "Token Construction Tests" >::: [
  "test_make_literal_token" >:: test_make_literal_token;
  "test_make_identifier_token" >:: test_make_identifier_token;
  "test_make_core_language_token" >:: test_make_core_language_token;
  "test_make_operator_token" >:: test_make_operator_token;
  "test_make_delimiter_token" >:: test_make_delimiter_token;
  "test_make_special_token" >:: test_make_special_token;
]

let position_tests = "Position Handling Tests" >::: [
  "test_make_position" >:: test_make_position;
  "test_make_positioned_token" >:: test_make_positioned_token;
]

let category_tests = "Token Category Tests" >::: [
  "test_get_token_category" >:: test_get_token_category;
  "test_token_type_checks" >:: test_token_type_checks;
]

let utility_tests = "Utility Function Tests" >::: [
  "test_token_type_name" >:: test_token_type_name;
  "test_count_token_types" >:: test_count_token_types;
]

let batch_tests = "Batch Processing Tests" >::: [
  "test_make_literal_tokens" >:: test_make_literal_tokens;
  "test_make_identifier_tokens" >:: test_make_identifier_tokens;
]

let experimental_tests = "Experimental Feature Tests" >::: [
  "test_infer_token_from_string" >:: test_infer_token_from_string;
  "test_validate_token_stream" >:: test_validate_token_stream;
]

let edge_case_tests = "Edge Case and Error Handling Tests" >::: [
  "test_empty_string_handling" >:: test_empty_string_handling;
  "test_large_values" >:: test_large_values;
  "test_performance_stress" >:: test_performance_stress;
]

let roundtrip_tests = "Roundtrip Consistency Tests" >::: [
  "test_roundtrip_consistency" >:: test_roundtrip_consistency;
]

(** 主测试套件 *)
let suite = "Legacy Type Bridge Comprehensive Tests" >::: [
  conversion_tests;
  identifier_tests;
  keyword_tests;
  operator_tests;
  delimiter_tests;
  special_tests;
  construction_tests;
  position_tests;
  category_tests;
  utility_tests;
  batch_tests;
  experimental_tests;
  edge_case_tests;
  roundtrip_tests;
]

(** 运行测试 *)
let () = run_test_tt_main suite