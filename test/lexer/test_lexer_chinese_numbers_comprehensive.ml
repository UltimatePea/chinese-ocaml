(** 骆言词法分析器 - 中文数字处理模块全面测试套件 *)

open Alcotest
open Yyocamlc_lib.Lexer_chinese_numbers
open Yyocamlc_lib.Lexer_tokens
open Yyocamlc_lib.Lexer_state

(** 测试工具函数 *)
let create_test_state input = create_lexer_state input "<test>"

let string_of_token = function
  | IntToken i -> Printf.sprintf "IntToken(%d)" i
  | FloatToken f -> Printf.sprintf "FloatToken(%g)" f
  | _ -> "OtherToken"

let token_testable = testable (fun ppf t -> Fmt.pf ppf "%s" (string_of_token t)) ( = )

(** === 中文数字转换器单元测试 === *)

(** 测试基础数字字符映射 *)
let test_char_to_digit () =
  let module C = ChineseNumberConverter in
  check int "一 maps to 1" 1 (C.char_to_digit "一");
  check int "二 maps to 2" 2 (C.char_to_digit "二");
  check int "三 maps to 3" 3 (C.char_to_digit "三");
  check int "四 maps to 4" 4 (C.char_to_digit "四");
  check int "五 maps to 5" 5 (C.char_to_digit "五");
  check int "六 maps to 6" 6 (C.char_to_digit "六");
  check int "七 maps to 7" 7 (C.char_to_digit "七");
  check int "八 maps to 8" 8 (C.char_to_digit "八");
  check int "九 maps to 9" 9 (C.char_to_digit "九");
  check int "零 maps to 0" 0 (C.char_to_digit "零");
  check int "unknown char maps to 0" 0 (C.char_to_digit "x")

(** 测试单位字符映射 *)
let test_char_to_unit () =
  let module C = ChineseNumberConverter in
  check int "十 maps to 10" 10 (C.char_to_unit "十");
  check int "百 maps to 100" 100 (C.char_to_unit "百");
  check int "千 maps to 1000" 1000 (C.char_to_unit "千");
  check int "万 maps to 10000" 10000 (C.char_to_unit "万");
  check int "亿 maps to 100000000" 100000000 (C.char_to_unit "亿");
  check int "unknown char maps to 1" 1 (C.char_to_unit "x")

(** 测试UTF-8字符串解析 *)
let test_utf8_to_char_list () =
  let module C = ChineseNumberConverter in
  let result1 = C.utf8_to_char_list "一二三" 0 [] in
  check (list string) "parse 一二三" [ "一"; "二"; "三" ] result1;

  let result2 = C.utf8_to_char_list "十五" 0 [] in
  check (list string) "parse 十五" [ "十"; "五" ] result2;

  let result3 = C.utf8_to_char_list "" 0 [] in
  check (list string) "parse empty string" [] result3;

  let result4 = C.utf8_to_char_list "一千二百三十四" 0 [] in
  check (list string) "parse complex number" [ "一"; "千"; "二"; "百"; "三"; "十"; "四" ] result4

(** 测试简单数字序列解析 *)
let test_parse_simple_digits () =
  let module C = ChineseNumberConverter in
  check int "parse 一二三" 123 (C.parse_simple_digits [ "一"; "二"; "三" ] 0);
  check int "parse 九八七" 987 (C.parse_simple_digits [ "九"; "八"; "七" ] 0);
  check int "parse 五" 5 (C.parse_simple_digits [ "五" ] 0);
  check int "parse empty list" 0 (C.parse_simple_digits [] 0)

(** 测试带单位的复杂数字解析 *)
let test_parse_with_units () =
  let module C = ChineseNumberConverter in
  (* 基础单位测试 *)
  check int "parse 十" 10 (C.parse_with_units [ "十" ] 0 0);
  check int "parse 五十" 50 (C.parse_with_units [ "五"; "十" ] 0 0);
  check int "parse 一百" 100 (C.parse_with_units [ "一"; "百" ] 0 0);
  check int "parse 三千" 3000 (C.parse_with_units [ "三"; "千" ] 0 0);

  (* 复合数字测试 *)
  check int "parse 二十三" 23 (C.parse_with_units [ "二"; "十"; "三" ] 0 0);
  check int "parse 一百二十" 120 (C.parse_with_units [ "一"; "百"; "二"; "十" ] 0 0);
  check int "parse 五千三百二十一" 5321 (C.parse_with_units [ "五"; "千"; "三"; "百"; "二"; "十"; "一" ] 0 0);

  (* 大单位测试 *)
  check int "parse 一万" 10000 (C.parse_with_units [ "一"; "万" ] 0 0);
  check int "parse 十万" 100000 (C.parse_with_units [ "十"; "万" ] 0 0);
  check int "parse 三万五千" 35000 (C.parse_with_units [ "三"; "万"; "五"; "千" ] 0 0);

  (* 零的处理测试 *)
  check int "parse 一千零五" 1005 (C.parse_with_units [ "一"; "千"; "零"; "五" ] 0 0)

(** 测试中文数字综合解析 *)
let test_parse_chinese_number () =
  let module C = ChineseNumberConverter in
  (* 简单数字 *)
  let chars1 = C.utf8_to_char_list "一二三" 0 [] in
  check int "parse simple 一二三" 123 (C.parse_chinese_number chars1);

  (* 带单位数字 *)
  let chars2 = C.utf8_to_char_list "二十三" 0 [] in
  check int "parse 二十三" 23 (C.parse_chinese_number chars2);

  let chars3 = C.utf8_to_char_list "一千二百三十四" 0 [] in
  check int "parse 一千二百三十四" 1234 (C.parse_chinese_number chars3);

  let chars4 = C.utf8_to_char_list "五万三千二百一十" 0 [] in
  check int "parse 五万三千二百一十" 53210 (C.parse_chinese_number chars4)

(** 测试浮点数值构造 *)
let test_construct_float_value () =
  let module C = ChineseNumberConverter in
  let epsilon = 0.0001 in

  let check_float msg expected actual =
    check bool msg true (abs_float (expected -. actual) < epsilon)
  in

  check_float "construct 12.34" 12.34 (C.construct_float_value 12 34 2);
  check_float "construct 1.5" 1.5 (C.construct_float_value 1 5 1);
  check_float "construct 100.001" 100.001 (C.construct_float_value 100 1 3)

(** === 中文数字序列读取测试 === *)

let test_read_chinese_number_sequence () =
  let state1 = create_test_state "一二三abc" in
  let seq1, _ = read_chinese_number_sequence state1 in
  check string "read sequence 一二三" "一二三" seq1;

  let state2 = create_test_state "十五万" in
  let seq2, _ = read_chinese_number_sequence state2 in
  check string "read sequence 十五万" "十五万" seq2;

  let state3 = create_test_state "abc" in
  let seq3, _ = read_chinese_number_sequence state3 in
  check string "read empty sequence" "" seq3

(** === 中文数字序列转换测试 === *)

(** 测试整数转换 *)
let test_convert_integer_sequences () =
  check token_testable "convert 一" (IntToken 1) (convert_chinese_number_sequence "一");
  check token_testable "convert 十" (IntToken 10) (convert_chinese_number_sequence "十");
  check token_testable "convert 二十三" (IntToken 23) (convert_chinese_number_sequence "二十三");
  check token_testable "convert 一百" (IntToken 100) (convert_chinese_number_sequence "一百");
  check token_testable "convert 一千二百三十四" (IntToken 1234) (convert_chinese_number_sequence "一千二百三十四");
  check token_testable "convert 五万" (IntToken 50000) (convert_chinese_number_sequence "五万");
  check token_testable "convert 三万五千二百一十" (IntToken 35210)
    (convert_chinese_number_sequence "三万五千二百一十")

(** 测试负数转换 *)
let test_convert_negative_numbers () =
  check token_testable "convert 负一" (IntToken (-1)) (convert_chinese_number_sequence "负一");
  check token_testable "convert 负十" (IntToken (-10)) (convert_chinese_number_sequence "负十");
  check token_testable "convert 负一百二十三" (IntToken (-123)) (convert_chinese_number_sequence "负一百二十三")

(** 测试小数转换 *)
let test_convert_float_sequences () =
  let epsilon = 0.0001 in

  let check_float_token msg expected actual =
    match actual with
    | FloatToken f -> check bool msg true (abs_float (expected -. f) < epsilon)
    | _ -> fail ("Expected FloatToken, got " ^ string_of_token actual)
  in

  check_float_token "convert 一点五" 1.5 (convert_chinese_number_sequence "一点五");
  check_float_token "convert 十二点三四" 12.34 (convert_chinese_number_sequence "十二点三四");
  check_float_token "convert 零点九" 0.9 (convert_chinese_number_sequence "零点九")

(** 测试负小数转换 *)
let test_convert_negative_floats () =
  let epsilon = 0.0001 in

  let check_float_token msg expected actual =
    match actual with
    | FloatToken f -> check bool msg true (abs_float (expected -. f) < epsilon)
    | _ -> fail ("Expected FloatToken, got " ^ string_of_token actual)
  in

  check_float_token "convert 负一点五" (-1.5) (convert_chinese_number_sequence "负一点五");
  check_float_token "convert 负十二点三四" (-12.34) (convert_chinese_number_sequence "负十二点三四")

(** === 边界条件和错误处理测试 === *)

(** 测试零的特殊处理 *)
let test_zero_handling () =
  check token_testable "convert 零" (IntToken 0) (convert_chinese_number_sequence "零");
  check token_testable "convert 一千零五" (IntToken 1005) (convert_chinese_number_sequence "一千零五");
  check token_testable "convert 十万零一" (IntToken 100001) (convert_chinese_number_sequence "十万零一")

(** 测试空字符串和边界条件 *)
let test_edge_cases () =
  (* 注意：convert_chinese_number_sequence 对空字符串的行为 *)
  check token_testable "convert empty string" (IntToken 0) (convert_chinese_number_sequence "");

  (* 测试只有单位的情况 *)
  check token_testable "convert 十 (just unit)" (IntToken 10) (convert_chinese_number_sequence "十");
  check token_testable "convert 百 (just unit)" (IntToken 100) (convert_chinese_number_sequence "百")

(** 测试异常大数值 *)
let test_large_numbers () =
  check token_testable "convert 九万九千九百九十九" (IntToken 99999)
    (convert_chinese_number_sequence "九万九千九百九十九");
  check token_testable "convert 一千万" (IntToken 10000000) (convert_chinese_number_sequence "一千万");
  check token_testable "convert 一亿" (IntToken 100000000) (convert_chinese_number_sequence "一亿")

(** === 状态管理测试 === *)

(** 测试词法分析器状态更新 *)
let test_lexer_state_updates () =
  let state = create_test_state "一二三四五" in
  let _, new_state = read_chinese_number_sequence state in

  check int "position updated correctly" 15 new_state.position;
  (* 5 UTF-8 chars × 3 bytes each *)
  check int "column updated correctly" 16 new_state.current_column;
  (* original column + byte difference *)
  check int "line remains same" 1 new_state.current_line

(** === 集成测试 === *)

(** 测试完整的词法分析流程 *)
let test_full_lexing_workflow () =
  let state = create_test_state "二十三" in
  let sequence, new_state = read_chinese_number_sequence state in
  let token = convert_chinese_number_sequence sequence in

  check string "extracted sequence" "二十三" sequence;
  check token_testable "converted token" (IntToken 23) token;
  check int "state position updated" 9 new_state.position (* 3 UTF-8 chars × 3 bytes each *)

(** 测试复杂混合场景 *)
let test_complex_scenarios () =
  (* 测试包含零的复杂数字 *)
  let state1 = create_test_state "三千零七" in
  let seq1, _ = read_chinese_number_sequence state1 in
  let token1 = convert_chinese_number_sequence seq1 in
  check token_testable "complex with zero" (IntToken 3007) token1;

  (* 测试最大的基本单位组合 *)
  let state2 = create_test_state "九千九百九十九" in
  let seq2, _ = read_chinese_number_sequence state2 in
  let token2 = convert_chinese_number_sequence seq2 in
  check token_testable "max basic units" (IntToken 9999) token2

(** === 测试套件定义 === *)

let char_mapping_tests =
  [
    test_case "char_to_digit mapping" `Quick test_char_to_digit;
    test_case "char_to_unit mapping" `Quick test_char_to_unit;
  ]

let utf8_parsing_tests = [ test_case "utf8_to_char_list parsing" `Quick test_utf8_to_char_list ]

let number_parsing_tests =
  [
    test_case "simple digits parsing" `Quick test_parse_simple_digits;
    test_case "units parsing" `Quick test_parse_with_units;
    test_case "chinese number parsing" `Quick test_parse_chinese_number;
    test_case "float value construction" `Quick test_construct_float_value;
  ]

let sequence_reading_tests =
  [ test_case "chinese number sequence reading" `Quick test_read_chinese_number_sequence ]

let conversion_tests =
  [
    test_case "integer conversion" `Quick test_convert_integer_sequences;
    test_case "negative number conversion" `Quick test_convert_negative_numbers;
    test_case "float conversion" `Quick test_convert_float_sequences;
    test_case "negative float conversion" `Quick test_convert_negative_floats;
  ]

let edge_case_tests =
  [
    test_case "zero handling" `Quick test_zero_handling;
    test_case "edge cases" `Quick test_edge_cases;
    test_case "large numbers" `Quick test_large_numbers;
  ]

let state_management_tests = [ test_case "lexer state updates" `Quick test_lexer_state_updates ]

let integration_tests =
  [
    test_case "full lexing workflow" `Quick test_full_lexing_workflow;
    test_case "complex scenarios" `Quick test_complex_scenarios;
  ]

(** 主测试套件 *)
let tests =
  [
    ("字符映射测试", char_mapping_tests);
    ("UTF-8解析测试", utf8_parsing_tests);
    ("数字解析测试", number_parsing_tests);
    ("序列读取测试", sequence_reading_tests);
    ("转换功能测试", conversion_tests);
    ("边界条件测试", edge_case_tests);
    ("状态管理测试", state_management_tests);
    ("集成测试", integration_tests);
  ]

let () = run "中文数字处理模块全面测试" tests
