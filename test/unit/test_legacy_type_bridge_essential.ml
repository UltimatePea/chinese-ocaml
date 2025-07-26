(** 骆言编译器 - Legacy Type Bridge 基础测试套件
    
    针对Issue #1357中Delta专员指出的测试覆盖率不足问题，
    为legacy_type_bridge.ml模块提供基础测试覆盖。
    
    @author Echo, 测试工程师
    @version 1.0
    @since 2025-07-26
    @issue #1357 *)

open Alcotest

(** 简单的literal_token测试类型 *)
let literal_token_testable = 
  let pp fmt = function
    | Token_system_unified_core.Token_types.IntToken i -> Format.fprintf fmt "IntToken(%d)" i
    | Token_system_unified_core.Token_types.FloatToken f -> Format.fprintf fmt "FloatToken(%f)" f
    | Token_system_unified_core.Token_types.StringToken s -> Format.fprintf fmt "StringToken(%s)" s
    | Token_system_unified_core.Token_types.BoolToken b -> Format.fprintf fmt "BoolToken(%b)" b
    | Token_system_unified_core.Token_types.ChineseNumberToken s -> Format.fprintf fmt "ChineseNumberToken(%s)" s
  in
  testable pp (=)

(** Token测试类型 *)
let token_testable = 
  let pp fmt = function
    | Token_system_unified_core.Token_types.Literal _ -> Format.fprintf fmt "Literal(...)"
    | Token_system_unified_core.Token_types.Identifier _ -> Format.fprintf fmt "Identifier(...)"
    | Token_system_unified_core.Token_types.CoreLanguage _ -> Format.fprintf fmt "CoreLanguage(...)"
    | Token_system_unified_core.Token_types.Operator _ -> Format.fprintf fmt "Operator(...)"
    | Token_system_unified_core.Token_types.Delimiter _ -> Format.fprintf fmt "Delimiter(...)"
    | Token_system_unified_core.Token_types.Special _ -> Format.fprintf fmt "Special(...)"
    | _ -> Format.fprintf fmt "Other(...)"
  in
  testable pp (=)

(** {1 基础转换函数测试} *)

(** 测试整数转换 *)
let test_convert_int_token () =
  let result = Token_system_unified_conversion.Legacy_type_bridge.convert_int_token 42 in
  check literal_token_testable "convert int 42" (Token_system_unified_core.Token_types.IntToken 42) result;
  
  let result = Token_system_unified_conversion.Legacy_type_bridge.convert_int_token 0 in
  check literal_token_testable "convert int 0" (Token_system_unified_core.Token_types.IntToken 0) result;
  
  let result = Token_system_unified_conversion.Legacy_type_bridge.convert_int_token (-1) in
  check literal_token_testable "convert int -1" (Token_system_unified_core.Token_types.IntToken (-1)) result

(** 测试浮点数转换 *)
let test_convert_float_token () =
  let result = Token_system_unified_conversion.Legacy_type_bridge.convert_float_token 3.14 in
  check literal_token_testable "convert float 3.14" (Token_system_unified_core.Token_types.FloatToken 3.14) result;
  
  let result = Token_system_unified_conversion.Legacy_type_bridge.convert_float_token 0.0 in
  check literal_token_testable "convert float 0.0" (Token_system_unified_core.Token_types.FloatToken 0.0) result

(** 测试字符串转换 *)
let test_convert_string_token () =
  let result = Token_system_unified_conversion.Legacy_type_bridge.convert_string_token "hello" in
  check literal_token_testable "convert string hello" (Token_system_unified_core.Token_types.StringToken "hello") result;
  
  let result = Token_system_unified_conversion.Legacy_type_bridge.convert_string_token "" in
  check literal_token_testable "convert empty string" (Token_system_unified_core.Token_types.StringToken "") result

(** 测试布尔转换 *)
let test_convert_bool_token () =
  let result = Token_system_unified_conversion.Legacy_type_bridge.convert_bool_token true in
  check literal_token_testable "convert bool true" (Token_system_unified_core.Token_types.BoolToken true) result;
  
  let result = Token_system_unified_conversion.Legacy_type_bridge.convert_bool_token false in
  check literal_token_testable "convert bool false" (Token_system_unified_core.Token_types.BoolToken false) result

(** 测试中文数字转换 *)  
let test_convert_chinese_number_token () =
  let result = Token_system_unified_conversion.Legacy_type_bridge.convert_chinese_number_token "一" in
  check literal_token_testable "convert chinese number 一" (Token_system_unified_core.Token_types.ChineseNumberToken "一") result

(** {1 Token构造函数测试} *)

(** 测试字面量Token构造 *)
let test_make_literal_token () =
  let int_lit = Token_system_unified_conversion.Legacy_type_bridge.convert_int_token 42 in
  let token = Token_system_unified_conversion.Legacy_type_bridge.make_literal_token int_lit in
  check token_testable "make literal token" (Token_system_unified_core.Token_types.Literal (Token_system_unified_core.Token_types.IntToken 42)) token

(** 测试标识符Token构造 *)
let test_make_identifier_token () =
  let simple_id = Token_system_unified_conversion.Legacy_type_bridge.convert_simple_identifier "test" in
  let token = Token_system_unified_conversion.Legacy_type_bridge.make_identifier_token simple_id in
  check token_testable "make identifier token" (Token_system_unified_core.Token_types.Identifier (Token_system_unified_core.Token_types.SimpleIdentifier "test")) token

(** {1 Token类型检查测试} *)

let test_is_literal_token () =
  let literal = Token_system_unified_conversion.Legacy_type_bridge.make_literal_token (Token_system_unified_conversion.Legacy_type_bridge.convert_int_token 42) in
  check bool "is_literal_token should be true" true (Token_system_unified_conversion.Legacy_type_bridge.is_literal_token literal);
  
  let identifier = Token_system_unified_conversion.Legacy_type_bridge.make_identifier_token (Token_system_unified_conversion.Legacy_type_bridge.convert_simple_identifier "test") in
  check bool "is_literal_token should be false for identifier" false (Token_system_unified_conversion.Legacy_type_bridge.is_literal_token identifier)

let test_is_identifier_token () =
  let identifier = Token_system_unified_conversion.Legacy_type_bridge.make_identifier_token (Token_system_unified_conversion.Legacy_type_bridge.convert_simple_identifier "test") in
  check bool "is_identifier_token should be true" true (Token_system_unified_conversion.Legacy_type_bridge.is_identifier_token identifier);
  
  let literal = Token_system_unified_conversion.Legacy_type_bridge.make_literal_token (Token_system_unified_conversion.Legacy_type_bridge.convert_int_token 42) in
  check bool "is_identifier_token should be false for literal" false (Token_system_unified_conversion.Legacy_type_bridge.is_identifier_token literal)

(** {1 位置信息测试} *)

let test_make_position () =
  let pos = Token_system_unified_conversion.Legacy_type_bridge.make_position ~line:10 ~column:5 ~offset:100 in
  check int "position line" 10 pos.Token_system_unified_core.Token_types.line;
  check int "position column" 5 pos.Token_system_unified_core.Token_types.column;
  check int "position offset" 100 pos.Token_system_unified_core.Token_types.offset

(** {1 测试套件定义} *)

let conversion_tests = [
  test_case "convert_int_token" `Quick test_convert_int_token;
  test_case "convert_float_token" `Quick test_convert_float_token;
  test_case "convert_string_token" `Quick test_convert_string_token;
  test_case "convert_bool_token" `Quick test_convert_bool_token;
  test_case "convert_chinese_number_token" `Quick test_convert_chinese_number_token;
]

let construction_tests = [
  test_case "make_literal_token" `Quick test_make_literal_token;
  test_case "make_identifier_token" `Quick test_make_identifier_token;
]

let type_check_tests = [
  test_case "is_literal_token" `Quick test_is_literal_token;
  test_case "is_identifier_token" `Quick test_is_identifier_token;
]

let position_tests = [
  test_case "make_position" `Quick test_make_position;
]

(** 运行所有测试 *)
let () =
  run "Legacy Type Bridge Essential Tests" [
    ("Basic Conversions", conversion_tests);
    ("Token Construction", construction_tests);
    ("Type Checks", type_check_tests);
    ("Position Handling", position_tests);
  ]