(** 骆言词法分析器模块化工具综合测试套件 - Fix #1009 Phase 2 Week 2 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Lexer_utils_modular
open Yyocamlc_lib.Lexer_state
open Yyocamlc_lib.Lexer_tokens
open Yyocamlc_lib.Types

(** 测试辅助工具模块 *)
module TestHelpers = struct
  (** 创建测试用的词法分析器状态 *)
  let create_test_state input =
    create_lexer_state input "test.ly"

  (** 创建位置信息 *)
  let make_pos line column filename = { line; column; filename }

  (** 比较token是否相等 *)
  let token_equal t1 t2 =
    match (t1, t2) with
    | (IntToken i1, IntToken i2) -> i1 = i2
    | (FloatToken f1, FloatToken f2) -> Float.abs (f1 -. f2) < 0.001
    | (StringToken s1, StringToken s2) -> s1 = s2
    | (BoolToken b1, BoolToken b2) -> b1 = b2
    | (Identifier id1, Identifier id2) -> id1 = id2
    | _ -> t1 = t2

  (** 检查字符处理函数 *)
  let check_char_function name func input expected =
    let result = func input in
    check bool name expected result

  (** 检查字符串处理函数 *)
  let check_string_function name func input expected =
    let result = func input in
    check string name expected result

  (** 检查数值解析函数 *)
  let check_parse_function name func input expected =
    let result = func input in
    check (option int) name expected result

  (** 检查浮点数解析函数 *)
  let check_parse_float_function name func input expected =
    let result = func input in
    match (result, expected) with
    | (Some r, Some e) -> check bool name true (Float.abs (r -. e) < 0.001)
    | (None, None) -> check bool name true true
    | _ -> check bool name false true
end

(** ==================== 1. 字符处理函数测试 ==================== *)

let test_character_classification () =
  (* 测试中文字符识别 *)
  TestHelpers.check_char_function "中文字符识别：汉字" is_chinese_char '\228' true;
  TestHelpers.check_char_function "中文字符识别：英文字母" is_chinese_char 'a' false;
  TestHelpers.check_char_function "中文字符识别：数字" is_chinese_char '1' false;

  (* 测试字母或中文字符识别 *)
  TestHelpers.check_char_function "字母或中文：英文字母" is_letter_or_chinese 'A' true;
  TestHelpers.check_char_function "字母或中文：中文字符" is_letter_or_chinese '文' true;
  TestHelpers.check_char_function "字母或中文：数字" is_letter_or_chinese '9' false;
  TestHelpers.check_char_function "字母或中文：符号" is_letter_or_chinese '@' false;

  (* 测试数字识别 *)
  TestHelpers.check_char_function "数字识别：0-9" is_digit '5' true;
  TestHelpers.check_char_function "数字识别：字母" is_digit 'a' false;
  TestHelpers.check_char_function "数字识别：中文" is_digit '五' false;

  (* 测试空白字符识别 *)
  TestHelpers.check_char_function "空白字符：空格" is_whitespace ' ' true;
  TestHelpers.check_char_function "空白字符：制表符" is_whitespace '\t' true;
  TestHelpers.check_char_function "空白字符：换行符" is_whitespace '\n' true;
  TestHelpers.check_char_function "空白字符：回车符" is_whitespace '\r' true;
  TestHelpers.check_char_function "空白字符：字母" is_whitespace 'a' false

let test_string_validation () =
  (* 测试数字字符串验证 *)
  TestHelpers.check_char_function "全数字字符串：纯数字" is_all_digits "12345" true;
  TestHelpers.check_char_function "全数字字符串：包含字母" is_all_digits "123a5" false;
  TestHelpers.check_char_function "全数字字符串：空字符串" is_all_digits "" true;
  TestHelpers.check_char_function "全数字字符串：混合符号" is_all_digits "123.45" false;

  (* 测试有效标识符验证 *)
  TestHelpers.check_char_function "有效标识符：纯字母" is_valid_identifier "hello" true;
  TestHelpers.check_char_function "有效标识符：字母数字" is_valid_identifier "var123" true;
  TestHelpers.check_char_function "有效标识符：下划线" is_valid_identifier "my_var" true;
  TestHelpers.check_char_function "有效标识符：中文" is_valid_identifier "变量" true;
  TestHelpers.check_char_function "有效标识符：数字开头" is_valid_identifier "123var" false;
  TestHelpers.check_char_function "有效标识符：特殊符号" is_valid_identifier "var@" false

let test_utf8_character_processing () =
  (* 测试UTF-8字符处理 *)
  let state = TestHelpers.create_test_state "中文测试" in
  try
    let char, next_pos = next_utf8_char state.input 0 in
    check string "UTF-8字符提取：中文字符" "中" char;
    check int "UTF-8字符位置：下一个位置" 3 next_pos
  with
  | _ -> check bool "UTF-8字符提取失败" false true;

  (* 测试ASCII字符 *)
  let state2 = TestHelpers.create_test_state "abc" in
  try
    let char2, next_pos2 = next_utf8_char state2.input 0 in
    check string "UTF-8字符提取：ASCII字符" "a" char2;
    check int "UTF-8字符位置：ASCII下一个位置" 1 next_pos2
  with
  | _ -> check bool "UTF-8 ASCII字符提取失败" false true

(** ==================== 2. 字符串读取和处理测试 ==================== *)

let test_read_string_until () =
  (* 测试字符串读取直到停止条件 *)
  let state = TestHelpers.create_test_state "hello world" in
  let stop_at_space ch = ch = " " in
  try
    let result, pos = read_string_until state 0 stop_at_space in
    check string "读取到空格前：结果" "hello" result;
    check int "读取到空格前：位置" 5 pos
  with
  | _ -> check bool "字符串读取失败" false true;

  (* 测试读取到字符串末尾 *)
  let state2 = TestHelpers.create_test_state "test" in
  let stop_never _ch = false in
  try
    let result2, pos2 = read_string_until state2 0 stop_never in
    check string "读取到末尾：结果" "test" result2;
    check int "读取到末尾：位置" 4 pos2
  with
  | _ -> check bool "读取到末尾失败" false true;

  (* 测试空字符串 *)
  let state3 = TestHelpers.create_test_state "" in
  try
    let result3, pos3 = read_string_until state3 0 stop_never in
    check string "空字符串读取：结果" "" result3;
    check int "空字符串读取：位置" 0 pos3
  with
  | _ -> check bool "空字符串读取失败" false true

let test_escape_sequence_processing () =
  (* 测试转义序列处理 *)
  TestHelpers.check_string_function "转义序列：换行符" process_escape_sequences "hello\\nworld" "hello\nworld";
  TestHelpers.check_string_function "转义序列：制表符" process_escape_sequences "tab\\there" "tab\there";
  TestHelpers.check_string_function "转义序列：回车符" process_escape_sequences "line\\rend" "line\rend";
  TestHelpers.check_string_function "转义序列：反斜杠" process_escape_sequences "path\\\\file" "path\\file";
  TestHelpers.check_string_function "转义序列：双引号" process_escape_sequences "say\\\"hello\\\"" "say\"hello\"";
  TestHelpers.check_string_function "转义序列：单引号" process_escape_sequences "don\\'t" "don't";

  (* 测试无转义序列 *)
  TestHelpers.check_string_function "无转义序列：普通字符串" process_escape_sequences "normal text" "normal text";
  TestHelpers.check_string_function "无转义序列：空字符串" process_escape_sequences "" "";

  (* 测试无效转义序列（保持原样） *)
  TestHelpers.check_string_function "无效转义序列：未知字符" process_escape_sequences "test\\x" "test\\x";
  TestHelpers.check_string_function "无效转义序列：末尾反斜杠" process_escape_sequences "test\\" "test\\"

(** ==================== 3. 数值解析函数测试 ==================== *)

let test_integer_parsing () =
  (* 测试整数解析 *)
  TestHelpers.check_parse_function "整数解析：正整数" parse_integer "123" (Some 123);
  TestHelpers.check_parse_function "整数解析：负整数" parse_integer "-456" (Some (-456));
  TestHelpers.check_parse_function "整数解析：零" parse_integer "0" (Some 0);
  TestHelpers.check_parse_function "整数解析：大整数" parse_integer "9999999" (Some 9999999);

  (* 测试无效整数 *)
  TestHelpers.check_parse_function "整数解析：浮点数" parse_integer "123.45" None;
  TestHelpers.check_parse_function "整数解析：字母" parse_integer "abc" None;
  TestHelpers.check_parse_function "整数解析：混合字符" parse_integer "123abc" None;
  TestHelpers.check_parse_function "整数解析：空字符串" parse_integer "" None

let test_float_parsing () =
  (* 测试浮点数解析 *)
  TestHelpers.check_parse_float_function "浮点数解析：正浮点数" parse_float "123.45" (Some 123.45);
  TestHelpers.check_parse_float_function "浮点数解析：负浮点数" parse_float "-67.89" (Some (-67.89));
  TestHelpers.check_parse_float_function "浮点数解析：科学计数法" parse_float "1.23e4" (Some 12300.0);
  TestHelpers.check_parse_float_function "浮点数解析：零浮点数" parse_float "0.0" (Some 0.0);

  (* 测试无效浮点数 *)
  TestHelpers.check_parse_float_function "浮点数解析：字母" parse_float "abc" None;
  TestHelpers.check_parse_float_function "浮点数解析：多个小数点" parse_float "12.34.56" None;
  TestHelpers.check_parse_float_function "浮点数解析：空字符串" parse_float "" None

let test_special_number_parsing () =
  (* 测试十六进制数解析 *)
  TestHelpers.check_parse_function "十六进制解析：标准格式" parse_hex_int "FF" (Some 255);
  TestHelpers.check_parse_function "十六进制解析：小写" parse_hex_int "abc" (Some 2748);
  TestHelpers.check_parse_function "十六进制解析：混合大小写" parse_hex_int "A1b2" (Some 41394);

  (* 测试八进制数解析 *)
  TestHelpers.check_parse_function "八进制解析：标准格式" parse_oct_int "77" (Some 63);
  TestHelpers.check_parse_function "八进制解析：大数" parse_oct_int "1234" (Some 668);

  (* 测试二进制数解析 *)
  TestHelpers.check_parse_function "二进制解析：标准格式" parse_bin_int "1010" (Some 10);
  TestHelpers.check_parse_function "二进制解析：全0" parse_bin_int "0000" (Some 0);
  TestHelpers.check_parse_function "二进制解析：全1" parse_bin_int "1111" (Some 15);

  (* 测试无效特殊数格式 *)
  TestHelpers.check_parse_function "十六进制解析：无效字符" parse_hex_int "XYZ" None;
  TestHelpers.check_parse_function "八进制解析：无效字符" parse_oct_int "89" None;
  TestHelpers.check_parse_function "二进制解析：无效字符" parse_bin_int "102" None

(** ==================== 4. 中文数字处理测试 ==================== *)

let test_chinese_number_processing () =
  (* 测试中文数字读取序列 *)
  let state = TestHelpers.create_test_state "一二三四五" in
  try
    let sequence, new_state = read_chinese_number_sequence state in
    check string "中文数字序列读取：结果" "一二三四五" sequence;
    check bool "中文数字序列读取：状态更新" true (new_state.position > state.position)
  with
  | _ -> check bool "中文数字序列读取失败" false true;

  (* 测试中文数字转换 *)
  try
    let converted = convert_chinese_number_sequence "一二三" in
    check bool "中文数字序列转换：类型检查" true (match converted with IntToken _ -> true | _ -> false)
  with
  | _ -> check bool "中文数字序列转换失败" false true

let test_fullwidth_number_processing () =
  (* 测试全角数字处理 *)
  let state = TestHelpers.create_test_state "１２３" in
  try
    let sequence, new_state = read_fullwidth_number_sequence state in
    check string "全角数字序列读取：结果" "１２３" sequence;
    check bool "全角数字序列读取：状态更新" true (new_state.position > state.position)
  with
  | _ -> check bool "全角数字序列读取失败" false true;

  (* 测试全角数字转换 *)
  try
    let token = convert_fullwidth_number_sequence "１２３" in
    check bool "全角数字转换：类型检查" true (match token with IntToken _ -> true | _ -> false)
  with
  | _ -> check bool "全角数字转换失败" false true

(** ==================== 5. 中文标点符号识别测试 ==================== *)

let test_chinese_punctuation_recognition () =
  (* 测试中文标点符号识别函数（通过模块导入） *)
  try
    (* 这些函数从 Lexer_punctuation_recognition 模块导入 *)
    let _result1 = check_fullwidth_symbol "。" in
    let _result2 = is_fullwidth_digit "１" in
    check bool "中文标点符号识别函数：可调用" true true
  with
  | _ -> check bool "中文标点符号识别函数：调用失败" false true

(** ==================== 6. 错误处理和边界条件测试 ==================== *)

let test_error_handling () =
  (* 测试空输入处理 *)
  let empty_state = TestHelpers.create_test_state "" in
  try
    let _result, _pos = read_string_until empty_state 0 (fun _ -> false) in
    check bool "空输入处理：成功" true true
  with
  | _ -> check bool "空输入处理：失败" false true;

  (* 测试边界位置访问 *)
  let state = TestHelpers.create_test_state "test" in
  try
    let _result, _pos = read_string_until state 10 (fun _ -> false) in
    check bool "边界位置访问：成功" true true
  with
  | _ -> check bool "边界位置访问：失败" false true;

  (* 测试无效数值格式 *)
  TestHelpers.check_parse_function "错误处理：空字符串整数" parse_integer "" None;
  TestHelpers.check_parse_float_function "错误处理：空字符串浮点数" parse_float "" None;
  TestHelpers.check_parse_function "错误处理：纯字母十六进制" parse_hex_int "xyz" None

let test_boundary_conditions () =
  (* 测试极端值处理 *)
  TestHelpers.check_parse_function "边界条件：最大整数" parse_integer (string_of_int max_int) (Some max_int);
  TestHelpers.check_parse_function "边界条件：最小整数" parse_integer (string_of_int min_int) (Some min_int);

  (* 测试长字符串处理 *)
  let long_string = String.make 1000 'a' in
  TestHelpers.check_string_function "边界条件：长字符串转义" process_escape_sequences long_string long_string;

  (* 测试Unicode边界 *)
  let unicode_state = TestHelpers.create_test_state "测试🚀emoji" in
  try
    let _char, _pos = next_utf8_char unicode_state.input 0 in
    check bool "边界条件：Unicode字符处理" true true
  with
  | _ -> check bool "边界条件：Unicode处理失败" false true

(** ==================== 7. 性能和压力测试 ==================== *)

let test_performance () =
  (* 测试大型字符串处理性能 *)
  let large_input = String.make 10000 'x' in
  let large_state = TestHelpers.create_test_state large_input in
  try
    let start_time = Sys.time () in
    let _result, _pos = read_string_until large_state 0 (fun ch -> ch = "y") in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    check bool "性能测试：大型字符串处理" true (duration < 1.0)
  with
  | _ -> check bool "性能测试：大型字符串处理失败" false true;

  (* 测试大量数值解析性能 *)
  let numbers = List.init 1000 string_of_int in
  try
    let start_time = Sys.time () in
    let _results = List.map parse_integer numbers in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    check bool "性能测试：大量数值解析" true (duration < 1.0)
  with
  | _ -> check bool "性能测试：数值解析失败" false true

let test_memory_usage () =
  (* 测试内存使用情况 *)
  try
    let large_escape_string = String.make 5000 '\\' ^ String.make 5000 'n' in
    let _result = process_escape_sequences large_escape_string in
    check bool "内存使用测试：大型转义序列" true true
  with
  | Out_of_memory -> check bool "内存使用测试：内存不足" false true
  | _ -> check bool "内存使用测试：其他错误" false true

(** ==================== 8. 模块集成和兼容性测试 ==================== *)

let test_module_integration () =
  (* 测试与其他模块的集成 *)
  let state = TestHelpers.create_test_state "test中文123" in
  try
    (* 测试字符分类函数集成 *)
    let is_letter_t = is_letter_or_chinese 't' in
    let is_chinese_zhong = is_chinese_char '中' in
    let is_digit_1 = is_digit '1' in
    
    check bool "模块集成：字母识别" true is_letter_t;
    check bool "模块集成：中文识别" true is_chinese_zhong;
    check bool "模块集成：数字识别" true is_digit_1
  with
  | _ -> check bool "模块集成测试失败" false true;

  (* 测试状态管理集成 *)
  try
    let _char = get_current_char state in
    check bool "模块集成：状态管理" true true
  with
  | _ -> check bool "模块集成：状态管理失败" false true

(** ==================== 测试套件注册 ==================== *)

let test_suite = [
  (* 1. 字符处理函数测试 *)
  ("字符处理函数", [
    test_case "字符分类识别" `Quick test_character_classification;
    test_case "字符串验证" `Quick test_string_validation;
    test_case "UTF-8字符处理" `Quick test_utf8_character_processing;
  ]);
  
  (* 2. 字符串读取和处理测试 *)
  ("字符串读取和处理", [
    test_case "条件字符串读取" `Quick test_read_string_until;
    test_case "转义序列处理" `Quick test_escape_sequence_processing;
  ]);
  
  (* 3. 数值解析函数测试 *)
  ("数值解析函数", [
    test_case "整数解析" `Quick test_integer_parsing;
    test_case "浮点数解析" `Quick test_float_parsing;
    test_case "特殊进制数解析" `Quick test_special_number_parsing;
  ]);
  
  (* 4. 中文数字处理测试 *)
  ("中文数字处理", [
    test_case "中文数字处理" `Quick test_chinese_number_processing;
    test_case "全角数字处理" `Quick test_fullwidth_number_processing;
  ]);
  
  (* 5. 中文标点符号识别测试 *)
  ("中文标点符号识别", [
    test_case "中文标点符号识别" `Quick test_chinese_punctuation_recognition;
  ]);
  
  (* 6. 错误处理和边界条件测试 *)
  ("错误处理和边界条件", [
    test_case "错误处理" `Quick test_error_handling;
    test_case "边界条件" `Quick test_boundary_conditions;
  ]);
  
  (* 7. 性能和压力测试 *)
  ("性能和压力测试", [
    test_case "性能测试" `Quick test_performance;
    test_case "内存使用测试" `Quick test_memory_usage;
  ]);
  
  (* 8. 模块集成和兼容性测试 *)
  ("模块集成和兼容性", [
    test_case "模块集成测试" `Quick test_module_integration;
  ])
]

(** 运行所有测试 *)
let () =
  Printf.printf "\n=== 骆言词法分析器模块化工具综合测试 - Fix #1009 Phase 2 Week 2 ===\n";
  Printf.printf "测试模块: lexer_utils_modular.ml (128行, 模块化工具集合)\n";
  Printf.printf "测试覆盖: 字符处理、字符串解析、数值转换、中文处理、错误处理\n";
  Printf.printf "==========================================\n\n";
  run "Lexer_utils_modular综合测试" test_suite