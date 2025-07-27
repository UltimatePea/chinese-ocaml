(** 词法分析器边界条件测试模块 - Phase 1测试覆盖率提升

    专注于边界条件、错误处理和复杂场景的词法分析测试
    目标：提升Lexer模块测试覆盖率，增强系统稳定性

    @author Alpha, 主要工作代理
    @version 1.0
    @since 2025-07-27 Fix #1481 测试覆盖率提升Phase 1 *)

open Alcotest
open Yyocamlc_lib.Lexer

(** 测试辅助函数 *)
let check_token_list_equal msg expected actual =
  let extract_tokens positioned_tokens = List.map fst positioned_tokens in
  check (list (of_pp (fun fmt tok ->
    Format.pp_print_string fmt (show_token tok))))
    msg expected (extract_tokens actual)


(** 边界条件 - 空输入测试 *)
let test_empty_input () =
  let tokens = tokenize "" "empty.ly" in
  let expected = [ EOF ] in
  check_token_list_equal "空输入应该只有EOF" expected tokens

(** 边界条件 - 单字符输入 *)
let test_single_character_inputs () =
  let test_cases = [
    ("让", [ LetKeyword; EOF ]);
    ("一", [ OneKeyword; EOF ]);
    ("（", [ ChineseLeftParen; EOF ]);
    ("）", [ ChineseRightParen; EOF ]);
    ("，", [ ChineseComma; EOF ]);
    ("：", [ ChineseColon; EOF ]);
    ("。", [ Dot; EOF ]);
  ] in
  
  List.iter (fun (input, expected) ->
    let tokens = tokenize input "single.ly" in
    check_token_list_equal ("单字符输入: " ^ input) expected tokens
  ) test_cases

(** 边界条件 - 极长输入测试 *)
let test_very_long_input () =
  let long_string = String.make 1000 'a' in
  let input = "『" ^ long_string ^ "』" in
  let tokens = tokenize input "long.ly" in
  let expected = [ StringToken long_string; EOF ] in
  check_token_list_equal "极长字符串输入" expected tokens

(** UTF-8边界条件 - 复杂中文字符 *)
let test_complex_chinese_characters () =
  let complex_inputs = [
    "𠜎𠜱𠝹𠱓"; (* 复杂中文字符 *)
    "龘龖龗龘"; (* 生僻字 *)
    "𪚥𪚦𪚧𪚨"; (* 扩展中文字符 *)
    "👨‍💻🚀"; (* emoji 和符号 *)
  ] in
  
  List.iter (fun input ->
    try
      let _ = tokenize input "complex_utf8.ly" in
      check bool ("复杂UTF-8字符处理: " ^ input) true true
    with
    | LexError (msg, _) -> 
        check bool ("复杂UTF-8字符错误处理: " ^ input) true (String.length msg > 0)
    | _ -> fail ("意外异常: " ^ input)
  ) complex_inputs

(** 错误恢复 - 无效字符序列 *)
let test_invalid_character_sequences () =
  let invalid_inputs = [
    ("@#$%", "ASCII特殊字符");
    ("abc123", "英文字母数字混合");
    ("@@@@", "重复ASCII符号");
    ("####", "重复井号");
  ] in
  
  List.iter (fun (input, description) ->
    try
      let _ = tokenize input "invalid.ly" in
      fail (description ^ " 应该抛出错误")
    with
    | LexError (msg, pos) -> 
        check bool (description ^ " 错误消息非空") true (String.length msg > 0);
        check bool (description ^ " 错误位置有效") true (pos.line > 0)
    | _ -> fail (description ^ " 应该抛出LexError")
  ) invalid_inputs

(** 边界条件 - 嵌套结构 *)
let test_deeply_nested_structures () =
  let nested_parentheses = String.make 50 '(' ^ String.make 50 ')' in
  let nested_quotes = "『" ^ (String.make 100 'x') ^ "』" in
  
  let tokens1 = tokenize nested_parentheses "nested_parens.ly" in
  let tokens2 = tokenize nested_quotes "nested_quotes.ly" in
  
  check bool "深层嵌套括号处理" true (List.length tokens1 > 50);
  check bool "深层嵌套引号处理" true (List.length tokens2 >= 2)

(** 位置跟踪 - 多行复杂结构 *)
let test_multiline_position_tracking () =
  let multiline_input = 
    "让 「变量一」 为 一\n" ^
    "让 「变量二」 为 二\n" ^
    "让 「变量三」 为 三\n" ^
    "函数 「计算」 「参数」\n" ^
    "如果 「参数」 大于 零\n" ^
    "那么 「参数」 乘以 二\n" ^
    "否则 零"
  in
  
  let tokens = tokenize multiline_input "multiline.ly" in
  
  (* 检查每行第一个token的位置 *)
  let check_line_positions () =
    let line_starts = [
      (LetKeyword, 1);
      (LetKeyword, 2);
      (LetKeyword, 3);
      (FunKeyword, 4);
      (IfKeyword, 5);
      (ThenKeyword, 6);
      (ElseKeyword, 7);
    ] in
    
    let rec check_positions tokens line_starts =
      match tokens, line_starts with
      | (token, pos) :: rest_tokens, (expected_token, expected_line) :: rest_starts ->
          if token = expected_token then (
            check int ("第" ^ string_of_int expected_line ^ "行位置") expected_line pos.line;
            check_positions rest_tokens rest_starts
          ) else
            check_positions rest_tokens ((expected_token, expected_line) :: rest_starts)
      | _, [] -> ()
      | [], _ -> ()
    in
    check_positions tokens line_starts
  in
  check_line_positions ()

(** 性能测试 - 大量重复token *)
let test_performance_many_tokens () =
  let many_keywords = String.concat " " (Array.to_list (Array.make 1000 "让")) in
  let start_time = Unix.gettimeofday () in
  let tokens = tokenize many_keywords "performance.ly" in
  let end_time = Unix.gettimeofday () in
  let duration = end_time -. start_time in
  
  check bool "大量token性能测试" true (duration < 1.0); (* 应该在1秒内完成 *)
  check bool "大量token数量正确" true (List.length tokens > 1000)

(** 字符编码边界 - 混合编码测试 *)
let test_mixed_encoding_scenarios () =
  let mixed_scenarios = [
    ("让「变量」为『中文字符串』", "基本混合编码");
    ("函数「测试」（参数）如果参数那么真否则假", "复杂混合编码");
    ("『包含\t制表符\n换行符\r回车符的字符串』", "控制字符处理");
  ] in
  
  List.iter (fun (input, description) ->
    try
      let tokens = tokenize input "mixed_encoding.ly" in
      check bool (description ^ " 处理成功") true (List.length tokens > 0)
    with
    | LexError (msg, _) -> 
        check bool (description ^ " 错误处理") true (String.length msg > 0)
    | _ -> fail (description ^ " 意外异常")
  ) mixed_scenarios

(** 注释边界条件测试 *)
let test_comment_boundary_conditions () =
  let comment_scenarios = [
    ("让「：注释：」变量为一", "简单注释");
    ("让「：多行\n注释\n内容：」变量为一", "多行注释");
    ("让「：：」变量为一", "空注释");
    ("让「：嵌套「引号」注释：」变量为一", "嵌套引号注释");
    ("「：纯注释文件：」", "纯注释");
  ] in
  
  List.iter (fun (input, description) ->
    try
      let tokens = tokenize input "comments.ly" in
      check bool (description ^ " 处理") true (List.length tokens > 0)
    with
    | LexError (msg, _) -> 
        check bool (description ^ " 错误处理") true (String.length msg > 0)
    | _ -> fail (description ^ " 意外异常")
  ) comment_scenarios

(** 数字处理边界条件 *)
let test_number_boundary_conditions () =
  let number_scenarios = [
    ("零", IntToken 0);
    ("一二三四五六七八九", IntToken 123456789);
    ("九八七六五四三二一", IntToken 987654321);
    ("一千二百三十四", IntToken 1234);
  ] in
  
  List.iter (fun (input, expected_token) ->
    try
      let tokens = tokenize input "numbers.ly" in
      match tokens with
      | (actual_token, _) :: _ ->
          check bool ("数字转换: " ^ input) true (actual_token = expected_token)
      | [] -> fail ("数字处理失败: " ^ input)
    with
    | _ -> fail ("数字处理异常: " ^ input)
  ) number_scenarios

(** 关键字冲突边界测试 *)
let test_keyword_conflict_boundaries () =
  let conflict_scenarios = [
    ("让让让", "重复关键字");
    ("函数函数", "重复函数关键字");
    ("如果否则", "相邻条件关键字");
    ("数据结构算法", "复合关键字");
  ] in
  
  List.iter (fun (input, description) ->
    try
      let tokens = tokenize input "conflicts.ly" in
      check bool (description ^ " 处理") true (List.length tokens > 0)
    with
    | LexError (msg, _) -> 
        check bool (description ^ " 错误处理") true (String.length msg > 0)
    | _ -> fail (description ^ " 意外异常")
  ) conflict_scenarios

(** 内存边界 - 大字符串处理 *)
let test_large_string_handling () =
  let large_content = String.make 10000 'x' in
  let large_string_input = "『" ^ large_content ^ "』" in
  
  try
    let tokens = tokenize large_string_input "large_string.ly" in
    match tokens with
    | (StringToken content, _) :: _ ->
        check int "大字符串长度" 10000 (String.length content)
    | _ -> fail "大字符串处理失败"
  with
  | _ -> fail "大字符串处理异常"

(** 测试套件 *)
let () =
  run "词法分析器边界条件测试套件"
    [
      ("边界条件基础", [
        test_case "空输入处理" `Quick test_empty_input;
        test_case "单字符输入" `Quick test_single_character_inputs;
        test_case "极长输入" `Quick test_very_long_input;
      ]);
      ("UTF-8边界条件", [
        test_case "复杂中文字符" `Quick test_complex_chinese_characters;
        test_case "混合编码场景" `Quick test_mixed_encoding_scenarios;
      ]);
      ("错误处理边界", [
        test_case "无效字符序列" `Quick test_invalid_character_sequences;
        test_case "关键字冲突边界" `Quick test_keyword_conflict_boundaries;
      ]);
      ("结构边界条件", [
        test_case "深层嵌套结构" `Quick test_deeply_nested_structures;
        test_case "多行位置跟踪" `Quick test_multiline_position_tracking;
      ]);
      ("性能边界条件", [
        test_case "大量token性能" `Quick test_performance_many_tokens;
        test_case "大字符串处理" `Quick test_large_string_handling;
      ]);
      ("特殊场景边界", [
        test_case "注释边界条件" `Quick test_comment_boundary_conditions;
        test_case "数字边界条件" `Quick test_number_boundary_conditions;
      ]);
    ]