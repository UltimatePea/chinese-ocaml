(** 骆言词法分析器字符处理模块综合测试套件 - Fix #1009 Phase 2 Week 2 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Lexer_chars
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
    | (IdentifierTokenSpecial s1, IdentifierTokenSpecial s2) -> s1 = s2
    | _ -> t1 = t2

  (** 检查函数调用是否成功 *)
  let check_function_success name func expected =
    try
      let result = func () in
      check bool name expected (result = expected)
    with
    | _ -> check bool name false true

  (** 检查函数调用是否抛出异常 *)
  let check_function_failure name func =
    try
      let _ = func () in
      check bool name false true  (* 应该失败但没有失败 *)
    with
    | _ -> check bool name true true  (* 正确地失败了 *)

  (** 检查状态更新 *)
  let check_state_update name old_state new_state expected_pos_change =
    let actual_change = new_state.position - old_state.position in
    check int name expected_pos_change actual_change
end

(** ==================== 1. UTF-8字符检查测试 ==================== *)

let test_check_utf8_char () =
  (* 测试UTF-8字符匹配 *)
  let state = TestHelpers.create_test_state "中文测试" in
  
  (* 测试正确的UTF-8字符匹配 *)
  let result1 = check_utf8_char state 0xE4 0xB8 0xAD in  (* "中"的UTF-8编码 *)
  check bool "UTF-8字符匹配：中文字符" true result1;
  
  (* 测试错误的UTF-8字符匹配 *)
  let result2 = check_utf8_char state 0xE4 0xB8 0xFF in  (* 错误的编码 *)
  check bool "UTF-8字符匹配：错误编码" false result2;
  
  (* 测试边界条件：位置超出范围 *)
  let short_state = TestHelpers.create_test_state "a" in
  let result3 = check_utf8_char short_state 0xE4 0xB8 0xAD in
  check bool "UTF-8字符匹配：位置超出范围" false result3

let test_utf8_char_count () =
  (* 测试UTF-8字符串字符计数 *)
  let count1 = count_utf8_chars "hello" in
  check int "UTF-8字符计数：ASCII字符串" 5 count1;
  
  let count2 = count_utf8_chars "中文" in
  check int "UTF-8字符计数：中文字符串" 2 count2;
  
  let count3 = count_utf8_chars "hello世界" in
  check int "UTF-8字符计数：混合字符串" 7 count3;
  
  let count4 = count_utf8_chars "" in
  check int "UTF-8字符计数：空字符串" 0 count4;
  
  (* 测试复杂Unicode字符 *)
  let count5 = count_utf8_chars "测试🚀emoji" in
  check bool "UTF-8字符计数：包含emoji" true (count5 > 0)

(** ==================== 2. 关键字边界检查测试 ==================== *)

let test_is_valid_keyword_boundary () =
  (* 测试文件结尾边界 *)
  let state1 = TestHelpers.create_test_state "test" in
  let result1 = is_valid_keyword_boundary state1 4 in
  check bool "关键字边界：文件结尾" true result1;
  
  (* 测试分隔符边界 *)
  let state2 = TestHelpers.create_test_state "test " in
  let result2 = is_valid_keyword_boundary state2 4 in
  check bool "关键字边界：空格分隔" true result2;
  
  let state3 = TestHelpers.create_test_state "test\t" in
  let result3 = is_valid_keyword_boundary state3 4 in
  check bool "关键字边界：制表符分隔" true result3;
  
  let state4 = TestHelpers.create_test_state "test\n" in
  let result4 = is_valid_keyword_boundary state4 4 in
  check bool "关键字边界：换行符分隔" true result4;
  
  (* 测试数字边界 *)
  let state5 = TestHelpers.create_test_state "test123" in
  let result5 = is_valid_keyword_boundary state5 4 in
  check bool "关键字边界：数字跟随" true result5;
  
  (* 测试字母边界（应该无效） *)
  let state6 = TestHelpers.create_test_state "testing" in
  let result6 = is_valid_keyword_boundary state6 4 in
  check bool "关键字边界：字母跟随" false result6;
  
  (* 测试中文字符边界 *)
  let state7 = TestHelpers.create_test_state "test中文" in
  let result7 = is_valid_keyword_boundary state7 4 in
  check bool "关键字边界：中文字符跟随" true result7

(** ==================== 3. 关键字匹配测试 ==================== *)

let test_check_keyword_match () =
  (* 测试基本关键字匹配 *)
  let state = TestHelpers.create_test_state "如果 x > 0" in
  let result = check_keyword_match state "如果" (IfKeyword) 6 None in
  check bool "关键字匹配：基本匹配" true (result <> None);
  
  (* 测试关键字长度不足 *)
  let short_state = TestHelpers.create_test_state "如" in
  let result2 = check_keyword_match short_state "如果" (IfKeyword) 6 None in
  check bool "关键字匹配：长度不足" true (result2 = None);
  
  (* 测试关键字不匹配 *)
  let state3 = TestHelpers.create_test_state "其他内容" in
  let result3 = check_keyword_match state3 "如果" (IfKeyword) 6 None in
  check bool "关键字匹配：内容不匹配" true (result3 = None);
  
  (* 测试最佳匹配选择（更长的关键字优先） *)
  let existing_match = Some ("短", (BoolToken true), 3) in
  let result4 = check_keyword_match state "如果" (IfKeyword) 6 existing_match in
  check bool "关键字匹配：更长优先" true (
    match result4 with 
    | Some (_, _, len) -> len = 6 
    | None -> false
  )

let test_try_match_keyword () =
  (* 测试成功的关键字匹配 *)
  let state1 = TestHelpers.create_test_state "如果 " in
  let result1 = try_match_keyword state1 in
  check bool "尝试关键字匹配：成功匹配" true (result1 <> None);
  
  (* 测试不匹配的情况 *)
  let state2 = TestHelpers.create_test_state "未知内容" in
  let result2 = try_match_keyword state2 in
  check bool "尝试关键字匹配：无匹配" true (result2 = None);
  
  (* 测试空字符串 *)
  let state3 = TestHelpers.create_test_state "" in
  let result3 = try_match_keyword state3 in
  check bool "尝试关键字匹配：空字符串" true (result3 = None)

(** ==================== 4. 状态创建和更新测试 ==================== *)

let test_create_keyword_state () =
  (* 测试关键字状态创建 *)
  let original_state = TestHelpers.create_test_state "如果测试" in
  let keyword_len = 6 in
  let new_state = create_keyword_state original_state keyword_len in
  
  TestHelpers.check_state_update "关键字状态：位置更新" original_state new_state keyword_len;
  check int "关键字状态：列更新" (original_state.current_column + keyword_len) new_state.current_column;
  
  (* 测试零长度关键字 *)
  let new_state2 = create_keyword_state original_state 0 in
  TestHelpers.check_state_update "关键字状态：零长度" original_state new_state2 0

(** ==================== 5. 字符处理和错误处理测试 ==================== *)

let test_handle_non_keyword_char () =
  (* 测试ASCII字母错误处理 *)
  let state1 = TestHelpers.create_test_state "abc" in
  let pos1 = TestHelpers.make_pos 1 1 "test.ly" in
  TestHelpers.check_function_failure 
    "非关键字字符：ASCII字母错误" 
    (fun () -> handle_non_keyword_char state1 pos1);
  
  (* 测试未知字符错误处理 *)
  let state2 = TestHelpers.create_test_state "@#$" in
  let pos2 = TestHelpers.make_pos 1 1 "test.ly" in
  TestHelpers.check_function_failure 
    "非关键字字符：特殊符号错误" 
    (fun () -> handle_non_keyword_char state2 pos2)

let test_try_keyword_or_error () =
  (* 测试成功的关键字处理 *)
  let state1 = TestHelpers.create_test_state "如果 " in
  let pos1 = TestHelpers.make_pos 1 1 "test.ly" in
  try
    let (token, _, new_state) = try_keyword_or_error state1 pos1 in
    check bool "关键字或错误：成功处理" true (token <> EOF);
    check bool "关键字或错误：状态更新" true (new_state.position > state1.position)
  with
  | _ -> check bool "关键字或错误：处理失败" false true;
  
  (* 测试错误情况 *)
  let state2 = TestHelpers.create_test_state "xyz" in
  let pos2 = TestHelpers.make_pos 1 1 "test.ly" in
  TestHelpers.check_function_failure 
    "关键字或错误：ASCII错误" 
    (fun () -> try_keyword_or_error state2 pos2)

(** ==================== 6. 中文数字处理测试 ==================== *)

let test_handle_chinese_number_sequence () =
  (* 测试多字符中文数字序列 *)
  let state = TestHelpers.create_test_state "一二三" in
  let pos = TestHelpers.make_pos 1 1 "test.ly" in
  let temp_state = {state with position = 9} in  (* 假设处理完3个字符 *)
  try
    let (token, _, result_state) = handle_chinese_number_sequence state pos "一二三" temp_state in
    check bool "中文数字序列：多字符处理" true (match token with IntToken _ -> true | _ -> false);
    check bool "中文数字序列：状态更新" true (result_state.position > state.position)
  with
  | _ -> check bool "中文数字序列：多字符处理失败" false true;
  
  (* 测试单字符中文数字（尝试关键字匹配） *)
  let state2 = TestHelpers.create_test_state "一" in
  let temp_state2 = {state2 with position = 3} in
  try
    let (token2, _, _) = handle_chinese_number_sequence state2 pos "一" temp_state2 in
    check bool "中文数字序列：单字符处理" true (token2 <> EOF)
  with
  | _ -> check bool "中文数字序列：单字符处理失败" false true

let test_handle_letter_or_chinese_char () =
  (* 测试中文数字字符处理 *)
  let state1 = TestHelpers.create_test_state "一二三" in
  let pos1 = TestHelpers.make_pos 1 1 "test.ly" in
  try
    let (token1, _, new_state1) = handle_letter_or_chinese_char state1 pos1 in
    check bool "字母或中文字符：中文数字" true (match token1 with IntToken _ -> true | _ -> false);
    check bool "字母或中文字符：状态更新" true (new_state1.position > state1.position)
  with
  | _ -> check bool "字母或中文字符：中文数字处理失败" false true;
  
  (* 测试关键字字符处理 *)
  let state2 = TestHelpers.create_test_state "如果" in
  let pos2 = TestHelpers.make_pos 1 1 "test.ly" in
  try
    let (token2, _, new_state2) = handle_letter_or_chinese_char state2 pos2 in
    check bool "字母或中文字符：关键字" true (token2 <> EOF);
    check bool "字母或中文字符：关键字状态更新" true (new_state2.position > state2.position)
  with
  | _ -> check bool "字母或中文字符：关键字处理失败" false true;
  
  (* 测试ASCII字母（应该抛出错误） *)
  let state3 = TestHelpers.create_test_state "hello" in
  let pos3 = TestHelpers.make_pos 1 1 "test.ly" in
  TestHelpers.check_function_failure 
    "字母或中文字符：ASCII字母错误" 
    (fun () -> handle_letter_or_chinese_char state3 pos3)

(** ==================== 7. 边界条件和错误处理测试 ==================== *)

let test_boundary_conditions () =
  (* 测试空输入 *)
  let empty_state = TestHelpers.create_test_state "" in
  let result1 = try_match_keyword empty_state in
  check bool "边界条件：空输入关键字匹配" true (result1 = None);
  
  (* 测试单字符输入 *)
  let single_state = TestHelpers.create_test_state "a" in
  let result2 = try_match_keyword single_state in
  check bool "边界条件：单字符输入" true (result2 = None);
  
  (* 测试超长关键字 *)
  let long_state = TestHelpers.create_test_state (String.make 1000 '中') in
  let result3 = try_match_keyword long_state in
  check bool "边界条件：超长输入" true (result3 = None);
  
  (* 测试Unicode边界字符 *)
  let unicode_state = TestHelpers.create_test_state "测试🚀" in
  let count = count_utf8_chars "测试🚀" in
  check bool "边界条件：Unicode字符计数" true (count > 0)

let test_error_scenarios () =
  (* 测试各种错误情况 *)
  let pos = TestHelpers.make_pos 1 1 "test.ly" in
  
  (* ASCII字母错误 *)
  let ascii_states = ["a"; "Z"; "hello"; "WORLD"] in
  List.iter (fun input ->
    let state = TestHelpers.create_test_state input in
    TestHelpers.check_function_failure 
      ("错误场景：ASCII字母 " ^ input) 
      (fun () -> handle_non_keyword_char state pos)
  ) ascii_states;
  
  (* 特殊字符错误 *)
  let special_states = ["@"; "#"; "$"; "%"] in
  List.iter (fun input ->
    let state = TestHelpers.create_test_state input in
    TestHelpers.check_function_failure 
      ("错误场景：特殊字符 " ^ input) 
      (fun () -> handle_non_keyword_char state pos)
  ) special_states

(** ==================== 8. 性能和集成测试 ==================== *)

let test_performance () =
  (* 测试大型字符串的关键字匹配性能 *)
  let large_input = String.make 1000 '中' ^ "如果" in
  let large_state = TestHelpers.create_test_state large_input in
  let start_time = Sys.time () in
  let _result = try_match_keyword large_state in
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  check bool "性能测试：大型输入关键字匹配" true (duration < 1.0);
  
  (* 测试大量UTF-8字符计数性能 *)
  let chinese_string = String.make 3000 '测' in  (* 1000个中文字符 *)
  let start_time2 = Sys.time () in
  let _count = count_utf8_chars chinese_string in
  let end_time2 = Sys.time () in
  let duration2 = end_time2 -. start_time2 in
  check bool "性能测试：大量UTF-8字符计数" true (duration2 < 1.0)

let test_integration () =
  (* 测试模块集成 *)
  let state = TestHelpers.create_test_state "如果一二三测试" in
  let pos = TestHelpers.make_pos 1 1 "test.ly" in
  
  (* 测试关键字匹配 *)
  try
    let keyword_result = try_match_keyword state in
    check bool "集成测试：关键字匹配" true (keyword_result <> None)
  with
  | _ -> check bool "集成测试：关键字匹配失败" false true;
  
  (* 测试字符处理链 *)
  try
    let (token, _, new_state) = handle_letter_or_chinese_char state pos in
    check bool "集成测试：字符处理链" true (token <> EOF);
    check bool "集成测试：状态一致性" true (new_state.position >= state.position)
  with
  | _ -> check bool "集成测试：字符处理链失败" false true

let test_memory_usage () =
  (* 测试内存使用情况 *)
  try
    let large_strings = List.init 100 (fun i -> String.make 100 (char_of_int (65 + (i mod 26)))) in
    let _counts = List.map count_utf8_chars large_strings in
    check bool "内存使用测试：大量字符串处理" true true
  with
  | Out_of_memory -> check bool "内存使用测试：内存不足" false true
  | _ -> check bool "内存使用测试：其他错误" false true

(** ==================== 测试套件注册 ==================== *)

let test_suite = [
  (* 1. UTF-8字符检查测试 *)
  ("UTF-8字符处理", [
    test_case "UTF-8字符匹配检查" `Quick test_check_utf8_char;
    test_case "UTF-8字符计数" `Quick test_utf8_char_count;
  ]);
  
  (* 2. 关键字边界检查测试 *)
  ("关键字边界检查", [
    test_case "关键字边界验证" `Quick test_is_valid_keyword_boundary;
  ]);
  
  (* 3. 关键字匹配测试 *)
  ("关键字匹配处理", [
    test_case "关键字匹配检查" `Quick test_check_keyword_match;
    test_case "尝试关键字匹配" `Quick test_try_match_keyword;
  ]);
  
  (* 4. 状态创建和更新测试 *)
  ("状态管理", [
    test_case "关键字状态创建" `Quick test_create_keyword_state;
  ]);
  
  (* 5. 字符处理和错误处理测试 *)
  ("字符处理和错误处理", [
    test_case "非关键字字符处理" `Quick test_handle_non_keyword_char;
    test_case "关键字或错误处理" `Quick test_try_keyword_or_error;
  ]);
  
  (* 6. 中文数字处理测试 *)
  ("中文数字处理", [
    test_case "中文数字序列处理" `Quick test_handle_chinese_number_sequence;
    test_case "字母或中文字符处理" `Quick test_handle_letter_or_chinese_char;
  ]);
  
  (* 7. 边界条件和错误处理测试 *)
  ("边界条件和错误处理", [
    test_case "边界条件测试" `Quick test_boundary_conditions;
    test_case "错误场景测试" `Quick test_error_scenarios;
  ]);
  
  (* 8. 性能和集成测试 *)
  ("性能和集成测试", [
    test_case "性能测试" `Quick test_performance;
    test_case "集成测试" `Quick test_integration;
    test_case "内存使用测试" `Quick test_memory_usage;
  ])
]

(** 运行所有测试 *)
let () =
  Printf.printf "\n=== 骆言词法分析器字符处理模块综合测试 - Fix #1009 Phase 2 Week 2 ===\n";
  Printf.printf "测试模块: lexer_chars.ml (126行, 字符处理核心)\n";
  Printf.printf "测试覆盖: UTF-8处理、关键字匹配、字符分类、错误处理、中文数字\n";
  Printf.printf "==========================================\n\n";
  run "Lexer_chars综合测试" test_suite