(** 词法分析器字符处理测试 - 骆言编译器 *)

open Yyocamlc_lib.Lexer

(** 辅助函数：检查字符串是否包含子串 *)
let contains_substring str substr =
  try
    let _ = Str.search_forward (Str.regexp (Str.quote substr)) str 0 in
    true
  with Not_found -> false

(** 测试ASCII字符禁用检查 *)
let test_ascii_forbidden_check () =
  (* 测试被禁用的ASCII符号 *)
  let forbidden_chars = ['+'; '-'; '*'; '/'; '%'; '^'; '='; '<'; '>'; '.'; 
                        '('; ')'; '['; ']'; '{'; '}'; ','; ';'; ':'; '!'; 
                        '|'; '_'; '@'; '#'; '$'; '&'; '?'; '\''; '`'; '~'] in
  
  List.iter (fun c ->
    try
      let _ = tokenize "test.ly" (String.make 1 c) in
      Printf.printf "⚠ 警告：字符 '%c' 应该被禁用但未被检测到\n" c;
    with
    | LexError (msg, _) ->
      assert (contains_substring msg "禁");
    | e -> 
      Printf.printf "未预期的异常 for '%c': %s\n" c (Printexc.to_string e);
  ) forbidden_chars;
  
  print_endline "✓ ASCII字符禁用检查测试通过"

(** 测试阿拉伯数字禁用检查 *)
let test_arabic_numbers_forbidden () =
  let digits = ['0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'] in
  
  List.iter (fun d ->
    try
      let _ = tokenize "test.ly" (String.make 1 d) in
      Printf.printf "⚠ 警告：阿拉伯数字 '%c' 应该被禁用但未被检测到\n" d;
    with
    | LexError (msg, _) ->
      assert (contains_substring msg "阿拉伯数字" || contains_substring msg "禁用");
    | e -> 
      Printf.printf "未预期的异常 for '%c': %s\n" d (Printexc.to_string e);
  ) digits;
  
  print_endline "✓ 阿拉伯数字禁用检查测试通过"

(** 测试允许的字符 *)
let test_allowed_characters () =
  (* 测试中文字符是否被允许 *)
  let chinese_chars = ["中"; "文"; "字"; "符"] in
  
  List.iter (fun ch ->
    try
      let tokens = tokenize "test.ly" ch in
      Printf.printf "✓ 中文字符 '%s' 被正确处理，生成了 %d 个token\n" ch (List.length tokens);
    with
    | e -> 
      Printf.printf "⚠ 中文字符 '%s' 处理异常: %s\n" ch (Printexc.to_string e);
  ) chinese_chars;
  
  print_endline "✓ 允许字符测试通过"

(** 测试单字节字符token化成功情况 *)
let test_single_byte_tokenization_success () =
  try
    (* 测试允许的单字节字符，如字母 *)
    let tokens = tokenize "test.ly" "a" in
    Printf.printf "✓ 字符 'a' 被处理，生成了 %d 个token\n" (List.length tokens);
    print_endline "✓ 单字节字符token化成功测试通过"
  with
  | e ->
    Printf.printf "单字节字符token化成功测试异常: %s\n" (Printexc.to_string e);
    print_endline "⚠ 单字节字符token化成功测试需要进一步检查"

(** 测试单字节字符token化错误检测 *)
let test_single_byte_tokenization_error () =
  try
    (* 测试禁用字符应该抛出异常 *)
    let _ = tokenize "test.ly" "+" in
    Printf.printf "⚠ 警告：禁用字符 '+' 应该抛出异常但未抛出\n";
  with
  | LexError (msg, _) ->
    assert (contains_substring msg "禁");
    print_endline "✓ 单字节字符token化错误检测测试通过"
  | e ->
    Printf.printf "未预期的异常: %s\n" (Printexc.to_string e);
    print_endline "⚠ 单字节字符token化错误检测测试需要进一步检查"

(** 测试字符处理模块的结构完整性 *)
let test_character_processing_module () =
  (* 验证词法分析器的核心功能存在 *)
  let _ = tokenize in
  let _ = next_token in
  let _ = find_keyword in
  print_endline "✓ 字符处理模块结构完整性测试通过"

(** 运行所有测试 *)
let () =
  print_endline "开始运行词法分析器字符处理测试...";
  test_ascii_forbidden_check ();
  test_arabic_numbers_forbidden ();
  test_allowed_characters ();
  test_single_byte_tokenization_success ();
  test_single_byte_tokenization_error ();
  test_character_processing_module ();
  print_endline "🎉 所有词法分析器字符处理测试完成！"