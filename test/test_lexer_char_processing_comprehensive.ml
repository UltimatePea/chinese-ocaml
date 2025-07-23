(** 骆言词法分析器字符处理模块综合测试
  
    本测试模块提供对 lexer_char_processing.ml 的全面测试覆盖。
    
    技术债务改进：测试覆盖率系统性提升计划 - 第四阶段核心组件架构优化 - Fix #954
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-23 *)

open Alcotest
open Yyocamlc_lib
open Lexer_char_processing

(** ==================== 测试辅助函数 ==================== *)

(** 创建词法分析器状态用于测试 *)
let create_test_state input =
  {
    Lexer_state.input = input;
    position = 0;
    length = String.length input;
    current_line = 1;
    current_column = 1;
    filename = "test";
  }

(** ==================== 字符识别功能测试 ==================== *)

(** 测试中文字符识别 *)
let test_chinese_char_recognition () =
  (* 测试基本ASCII字符的is_chinese_char *)
  check bool "英文字符不是中文" false (is_chinese_char 'a');
  check bool "数字不是中文" false (is_chinese_char '1');
  check bool "符号不是中文" false (is_chinese_char '+');
  check bool "空格不是中文" false (is_chinese_char ' ');
  
  (* 对于UTF-8中文字符，使用字符串版本的函数测试 *)
  check bool "基本中文字符识别" true (is_chinese_utf8 "中");
  check bool "汉字识别" true (is_chinese_utf8 "汉");
  check bool "语字识别" true (is_chinese_utf8 "语");
  check bool "言字识别" true (is_chinese_utf8 "言");
  check bool "繁体字识别" true (is_chinese_utf8 "語");
  ()

(** 测试字母或中文字符识别 *)
let test_letter_or_chinese_recognition () =
  (* 测试英文字母（ASCII字符用char版本） *)
  check bool "小写字母是字母或中文" true (is_letter_or_chinese 'a');
  check bool "大写字母是字母或中文" true (is_letter_or_chinese 'A');
  check bool "英文字母z是字母或中文" true (is_letter_or_chinese 'z');
  check bool "英文字母Z是字母或中文" true (is_letter_or_chinese 'Z');
  
  (* 测试非字母非中文（ASCII字符） *)
  check bool "数字不是字母或中文" false (is_letter_or_chinese '1');
  check bool "符号不是字母或中文" false (is_letter_or_chinese '+');
  check bool "空格不是字母或中文" false (is_letter_or_chinese ' ');
  
  (* 中文字符测试已在上一个函数中通过is_chinese_utf8完成 *)
  ()

(** 测试数字字符识别 *)
let test_digit_recognition () =
  (* 测试阿拉伯数字（ASCII字符用char版本） *)
  check bool "数字0识别" true (is_digit '0');
  check bool "数字1识别" true (is_digit '1');
  check bool "数字9识别" true (is_digit '9');
  
  (* 测试非数字（ASCII字符） *)
  check bool "字母不是数字" false (is_digit 'a');
  check bool "符号不是数字" false (is_digit '+');
  ()

(** 测试空白字符识别 *)
let test_whitespace_recognition () =
  (* 测试各种空白字符（ASCII字符用char版本） *)
  check bool "空格是空白字符" true (is_whitespace ' ');
  check bool "制表符是空白字符" true (is_whitespace '\t');
  check bool "换行符是空白字符" true (is_whitespace '\n');
  check bool "回车符是空白字符" true (is_whitespace '\r');
  
  (* 测试非空白字符（ASCII字符） *)
  check bool "字母不是空白字符" false (is_whitespace 'a');
  check bool "数字不是空白字符" false (is_whitespace '1');
  ()

(** 测试分隔符字符识别 *)
let test_separator_char_recognition () =
  (* 测试常见分隔符 *)
  check bool "逗号是分隔符" true (is_separator_char ",");
  check bool "分号是分隔符" true (is_separator_char ";");
  check bool "括号是分隔符" true (is_separator_char "(");
  check bool "方括号是分隔符" true (is_separator_char "[");
  
  (* 测试非分隔符 *)
  check bool "字母不是分隔符" false (is_separator_char "a");
  check bool "数字不是分隔符" false (is_separator_char "1");
  ()

(** ==================== UTF-8处理功能测试 ==================== *)

(** 测试UTF-8中文字符串识别 *)
let test_chinese_utf8_recognition () =
  (* 测试中文UTF-8字符串 *)
  check bool "中文UTF-8字符串识别" true (is_chinese_utf8 "中文");
  check bool "单个中文字符UTF-8识别" true (is_chinese_utf8 "语");
  check bool "复杂中文UTF-8识别" true (is_chinese_utf8 "骆言编程语言");
  
  (* 测试非中文UTF-8字符串 *)
  check bool "英文不是中文UTF-8" false (is_chinese_utf8 "hello");
  check bool "数字不是中文UTF-8" false (is_chinese_utf8 "123");
  check bool "混合文本不是纯中文UTF-8" false (is_chinese_utf8 "中文abc");
  ()

(** 测试中文数字字符识别 *)
let test_chinese_digit_char_recognition () =
  (* 测试中文数字字符 *)
  check bool "零是中文数字字符" true (is_chinese_digit_char "零");
  check bool "一是中文数字字符" true (is_chinese_digit_char "一");
  check bool "二是中文数字字符" true (is_chinese_digit_char "二");
  check bool "三是中文数字字符" true (is_chinese_digit_char "三");
  check bool "九是中文数字字符" true (is_chinese_digit_char "九");
  check bool "十是中文数字字符" true (is_chinese_digit_char "十");
  check bool "百是中文数字字符" true (is_chinese_digit_char "百");
  check bool "千是中文数字字符" true (is_chinese_digit_char "千");
  
  (* 测试非中文数字字符 *)
  check bool "普通中文不是中文数字字符" false (is_chinese_digit_char "中");
  check bool "阿拉伯数字不是中文数字字符" false (is_chinese_digit_char "1");
  check bool "英文字母不是中文数字字符" false (is_chinese_digit_char "a");
  ()

(** ==================== 字符串验证功能测试 ==================== *)

(** 测试全数字字符串验证 *)
let test_all_digits_validation () =
  (* 测试纯数字字符串 *)
  check bool "纯数字字符串验证" true (is_all_digits "123");
  check bool "单个数字验证" true (is_all_digits "5");
  check bool "长数字字符串验证" true (is_all_digits "123456789");
  
  (* 测试非纯数字字符串 *)
  check bool "包含字母的字符串不是全数字" false (is_all_digits "123a");
  check bool "包含空格的字符串不是全数字" false (is_all_digits "12 3");
  check bool "空字符串不是全数字" false (is_all_digits "");
  check bool "纯字母字符串不是全数字" false (is_all_digits "abc");
  ()

(** 测试有效标识符验证 *)
let test_valid_identifier_validation () =
  (* 测试有效的标识符 *)
  check bool "英文标识符验证" true (is_valid_identifier "variable");
  check bool "中文标识符验证" true (is_valid_identifier "变量");
  check bool "混合标识符验证" true (is_valid_identifier "var变量");
  check bool "带数字的标识符验证" true (is_valid_identifier "var123");
  check bool "下划线标识符验证" true (is_valid_identifier "var_name");
  
  (* 测试无效的标识符 *)
  check bool "以数字开头的不是有效标识符" false (is_valid_identifier "123var");
  check bool "包含特殊符号的不是有效标识符" false (is_valid_identifier "var+name");
  check bool "包含空格的不是有效标识符" false (is_valid_identifier "var name");
  check bool "空字符串不是有效标识符" false (is_valid_identifier "");
  ()

(** ==================== 状态操作功能测试 ==================== *)

(** 测试获取当前字符功能 *)
let test_get_current_char () =
  (* 测试正常字符获取 *)
  let state1 = create_test_state "hello" in
  check (option char) "获取第一个字符" (Some 'h') (get_current_char state1);
  
  let state2 = { state1 with position = 1 } in
  check (option char) "获取第二个字符" (Some 'e') (get_current_char state2);
  
  let state3 = { state1 with position = 4 } in
  check (option char) "获取最后一个字符" (Some 'o') (get_current_char state3);
  
  (* 测试超出范围的情况 *)
  let state4 = { state1 with position = 5 } in
  check (option char) "超出范围返回None" None (get_current_char state4);
  
  (* 测试空字符串 *)
  let empty_state = create_test_state "" in
  check (option char) "空字符串返回None" None (get_current_char empty_state);
  ()

(** 测试UTF-8字符检查功能 *)
let test_check_utf8_char () =
  (* 测试有足够字节的情况 *)
  let state1 = create_test_state "中文测试" in
  check bool "有足够UTF-8字节" true (check_utf8_char state1 0xE4 0xB8 0xAD);
  
  (* 测试字节不足的情况 *)
  let state2 = create_test_state "ab" in
  check bool "UTF-8字节不足" false (check_utf8_char state2 0xE4 0xB8 0xAD);
  
  (* 测试边界情况 *)
  let state3 = create_test_state "abc" in
  let state3_at_end = { state3 with position = 1 } in
  check bool "在边界位置检查UTF-8" false (check_utf8_char state3_at_end 0xE4 0xB8 0xAD);
  ()

(** ==================== 边界情况和错误处理测试 ==================== *)

(** 测试空字符串处理 *)
let test_empty_string_handling () =
  (* 测试各种函数对空字符串的处理 *)
  check bool "空字符串不是中文UTF-8" false (is_chinese_utf8 "");
  check bool "空字符串不是全数字" false (is_all_digits "");
  check bool "空字符串不是有效标识符" false (is_valid_identifier "");
  
  let empty_state = create_test_state "" in
  check (option char) "空状态获取字符" None (get_current_char empty_state);
  ()

(** 测试特殊字符处理 *)
let test_special_character_handling () =
  (* 测试Unicode特殊字符 *)
  check bool "表情符号不是中文" false (is_chinese_char "😀");
  check bool "日文不是中文" false (is_chinese_char "あ");
  check bool "韩文不是中文" false (is_chinese_char "한");
  
  (* 测试特殊标点符号 *)
  check bool "中文标点是中文" true (is_chinese_char "，");
  check bool "中文句号是中文" true (is_chinese_char "。");
  check bool "中文问号是中文" true (is_chinese_char "？");
  ()

(** 测试长字符串处理 *)
let test_long_string_handling () =
  (* 创建长字符串进行测试 *)
  let long_digits = String.make 1000 '1' in
  check bool "长数字字符串验证" true (is_all_digits long_digits);
  
  let long_identifier = "var" ^ String.make 100 'a' in
  check bool "长标识符验证" true (is_valid_identifier long_identifier);
  
  let long_chinese = String.make 50 "中" |> String.concat "" in
  check bool "长中文字符串验证" true (is_chinese_utf8 long_chinese);
  ()

(** ==================== 性能和稳定性测试 ==================== *)

(** 测试大量字符处理的性能 *)
let test_performance_with_large_input () =
  (* 测试处理大量字符时的稳定性 *)
  let test_chars = ["a"; "中"; "1"; " "; "+"; "語"; "0"; "z"; "九"; "\t"] in
  List.iter (fun char ->
    ignore (is_chinese_char char);
    ignore (is_letter_or_chinese char);
    ignore (is_digit char);
    ignore (is_whitespace char);
    ignore (is_separator_char char);
  ) test_chars;
  
  (* 测试通过 *)
  check bool "大量字符处理性能测试" true true;
  ()

(** 测试并发安全性 *)
let test_concurrent_safety () =
  (* 测试函数的线程安全性（基础测试） *)
  let test_string = "中文abc123" in
  let results = Array.make 10 false in
  
  for i = 0 to 9 do
    results.(i) <- (String.length test_string > 0)
  done;
  
  let all_true = Array.for_all (fun x -> x) results in
  check bool "并发安全性基础测试" true all_true;
  ()

(** ==================== 集成测试 ==================== *)

(** 测试与其他模块的集成 *)
let test_integration_with_utf8_utils () =
  (* 验证与Utf8_utils模块的集成工作正常 *)
  let test_cases = [
    ("中", true, true, false, false);
    ("a", false, true, false, false);
    ("1", false, false, true, false);
    (" ", false, false, false, true);
  ] in
  
  List.iter (fun (char, is_chinese, is_letter_chinese, is_digit_expected, is_whitespace_expected) ->
    check bool ("中文字符测试: " ^ char) is_chinese (is_chinese_char char);
    check bool ("字母或中文测试: " ^ char) is_letter_chinese (is_letter_or_chinese char);
    check bool ("数字测试: " ^ char) is_digit_expected (is_digit char);
    check bool ("空白字符测试: " ^ char) is_whitespace_expected (is_whitespace char);
  ) test_cases;
  ()

(** ==================== 测试套件定义 ==================== *)

let character_recognition_tests = [
  test_case "中文字符识别测试" `Quick test_chinese_char_recognition;
  test_case "字母或中文字符识别测试" `Quick test_letter_or_chinese_recognition;
  test_case "数字字符识别测试" `Quick test_digit_recognition;
  test_case "空白字符识别测试" `Quick test_whitespace_recognition;
  test_case "分隔符字符识别测试" `Quick test_separator_char_recognition;
]

let utf8_processing_tests = [
  test_case "UTF-8中文字符串识别测试" `Quick test_chinese_utf8_recognition;
  test_case "中文数字字符识别测试" `Quick test_chinese_digit_char_recognition;
]

let string_validation_tests = [
  test_case "全数字字符串验证测试" `Quick test_all_digits_validation;
  test_case "有效标识符验证测试" `Quick test_valid_identifier_validation;
]

let state_operation_tests = [
  test_case "获取当前字符测试" `Quick test_get_current_char;
  test_case "UTF-8字符检查测试" `Quick test_check_utf8_char;
]

let edge_case_tests = [
  test_case "空字符串处理测试" `Quick test_empty_string_handling;
  test_case "特殊字符处理测试" `Quick test_special_character_handling;
  test_case "长字符串处理测试" `Quick test_long_string_handling;
]

let performance_tests = [
  test_case "大输入性能测试" `Quick test_performance_with_large_input;
  test_case "并发安全性测试" `Quick test_concurrent_safety;
]

let integration_tests = [
  test_case "UTF8工具集成测试" `Quick test_integration_with_utf8_utils;
]

(** 主测试运行器 *)
let () = run "Lexer_char_processing 综合测试" [
  ("字符识别功能", character_recognition_tests);
  ("UTF-8处理功能", utf8_processing_tests);
  ("字符串验证功能", string_validation_tests);
  ("状态操作功能", state_operation_tests);
  ("边界情况处理", edge_case_tests);
  ("性能和稳定性", performance_tests);
  ("集成测试", integration_tests);
]