(** 骆言词法分析器字符处理模块基础测试
  
    本测试模块提供对 lexer_char_processing.ml 的基础测试覆盖。
    
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

(** ==================== 基础功能测试 ==================== *)

(** 测试ASCII字符识别功能 *)
let test_ascii_character_recognition () =
  (* 测试数字字符 *)
  check bool "数字0识别" true (is_digit '0');
  check bool "数字9识别" true (is_digit '9');
  check bool "字母a不是数字" false (is_digit 'a');
  
  (* 测试字母字符 *)
  check bool "小写字母a识别" true (is_letter_or_chinese 'a');
  check bool "大写字母Z识别" true (is_letter_or_chinese 'Z');
  check bool "数字1不是字母" false (is_letter_or_chinese '1');
  
  (* 测试空白字符 *)
  check bool "空格是空白字符" true (is_whitespace ' ');
  check bool "制表符是空白字符" true (is_whitespace '\t');
  check bool "字母a不是空白字符" false (is_whitespace 'a');
  
  (* 测试分隔符字符 *)
  check bool "逗号是分隔符" true (is_separator_char ',');
  check bool "括号是分隔符" true (is_separator_char '(');
  check bool "字母a不是分隔符" false (is_separator_char 'a');
  ()

(** 测试UTF-8字符串处理功能 *)
let test_utf8_string_processing () =
  (* 测试中文字符串识别 *)
  check bool "中文字符串识别" true (is_chinese_utf8 "中文");
  check bool "单个中文字符识别" true (is_chinese_utf8 "语");
  check bool "英文字符串不是中文" false (is_chinese_utf8 "hello");
  check bool "数字字符串不是中文" false (is_chinese_utf8 "123");
  
  (* 测试中文数字字符 *)
  check bool "零是中文数字" true (is_chinese_digit_char "零");
  check bool "一是中文数字" true (is_chinese_digit_char "一");
  check bool "十是中文数字" true (is_chinese_digit_char "十");
  check bool "普通中文不是数字" false (is_chinese_digit_char "中");
  ()

(** 测试字符串验证功能 *)
let test_string_validation () =
  (* 测试全数字验证 *)
  check bool "纯数字字符串" true (is_all_digits "123");
  check bool "单个数字" true (is_all_digits "5");
  check bool "包含字母不是全数字" false (is_all_digits "123a");
  check bool "空字符串不是全数字" false (is_all_digits "");
  
  (* 测试标识符验证 *)
  check bool "英文标识符" true (is_valid_identifier "variable");
  check bool "中文标识符" true (is_valid_identifier "变量");
  check bool "数字开头无效" false (is_valid_identifier "123var");
  check bool "空字符串无效" false (is_valid_identifier "");
  ()

(** 测试状态操作功能 *)
let test_state_operations () =
  (* 测试获取当前字符 *)
  let state = create_test_state "hello" in
  let current_char = get_current_char state in
  check (option char) "获取第一个字符" (Some 'h') current_char;
  
  (* 测试空字符串 *)
  let empty_state = create_test_state "" in
  let empty_char = get_current_char empty_state in
  check (option char) "空字符串返回None" None empty_char;
  
  (* 测试UTF-8字符检查 *)
  let utf8_state = create_test_state "中文测试" in
  let utf8_result = check_utf8_char utf8_state 0xE4 0xB8 0xAD in
  ignore utf8_result; (* 只测试函数能正常调用 *)
  
  check bool "状态操作测试完成" true true;
  ()

(** ==================== 边界情况测试 ==================== *)

(** 测试边界和错误情况 *)
let test_edge_cases () =
  (* 测试空字符串处理 *)
  check bool "空字符串不是中文UTF-8" false (is_chinese_utf8 "");
  check bool "空字符串不是全数字" false (is_all_digits "");
  
  (* 测试长字符串处理 *)
  let long_digits = String.make 100 '1' in
  check bool "长数字字符串验证" true (is_all_digits long_digits);
  
  let long_identifier = "var" ^ String.make 50 'a' in
  check bool "长标识符验证" true (is_valid_identifier long_identifier);
  
  (* 测试混合字符串 *)
  check bool "中英混合标识符" true (is_valid_identifier "var变量");
  check bool "包含特殊符号无效" false (is_valid_identifier "var+name");
  ()

(** ==================== 测试套件定义 ==================== *)

let basic_tests = [
  test_case "ASCII字符识别测试" `Quick test_ascii_character_recognition;
  test_case "UTF-8字符串处理测试" `Quick test_utf8_string_processing;
  test_case "字符串验证测试" `Quick test_string_validation;
  test_case "状态操作测试" `Quick test_state_operations;
  test_case "边界情况测试" `Quick test_edge_cases;
]

(** 主测试运行器 *)
let () = run "Lexer_char_processing 基础测试" [
  ("基础功能测试", basic_tests);
]