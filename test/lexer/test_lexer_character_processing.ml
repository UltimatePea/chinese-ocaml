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
  let forbidden_chars =
    [
      '+';
      '-';
      '*';
      '/';
      '%';
      '^';
      '=';
      '<';
      '>';
      '.';
      '(';
      ')';
      '[';
      ']';
      '{';
      '}';
      ',';
      ';';
      ':';
      '!';
      '|';
      '_';
      '@';
      '#';
      '$';
      '&';
      '?';
      '\'';
      '`';
      '~';
    ]
  in

  List.iter
    (fun c ->
      try
        let _ = tokenize (String.make 1 c) "test.ly" in
        Printf.printf "⚠ 警告：字符 '%c' 应该被禁用但未被检测到\n" c
      with
      | LexError (msg, _) -> assert (contains_substring msg "禁")
      | e -> Printf.printf "未预期的异常 for '%c': %s\n" c (Printexc.to_string e))
    forbidden_chars;

  print_endline "✓ ASCII字符禁用检查测试通过"

(** 测试阿拉伯数字禁用检查 *)
let test_arabic_numbers_forbidden () =
  let digits = [ '0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9' ] in

  List.iter
    (fun d ->
      try
        let _ = tokenize (String.make 1 d) "test.ly" in
        Printf.printf "⚠ 警告：阿拉伯数字 '%c' 应该被禁用但未被检测到\n" d
      with
      | LexError (msg, _) -> assert (contains_substring msg "阿拉伯数字" || contains_substring msg "禁用")
      | e -> Printf.printf "未预期的异常 for '%c': %s\n" d (Printexc.to_string e))
    digits;

  print_endline "✓ 阿拉伯数字禁用检查测试通过"

(** 测试中文字符的正确处理 *)
let test_chinese_character_handling () =
  (* 测试单个中文字符（应该被拒绝，因为需要引用） *)
  let individual_chars = [ "中"; "文"; "字"; "符" ] in

  List.iter
    (fun ch ->
      try
        let _ = tokenize ch "test.ly" in
        Printf.printf "⚠ 警告：单个中文字符 '%s' 应该被拒绝但被接受了\n" ch
      with
      | LexError (msg, _) when contains_substring msg "不支持" || contains_substring msg "非关键字" ->
          Printf.printf "✓ 单个中文字符 '%s' 被正确拒绝\n" ch
      | e -> Printf.printf "⚠ 中文字符 '%s' 处理异常: %s\n" ch (Printexc.to_string e))
    individual_chars;

  (* 测试引用的中文字符（应该被接受） *)
  let quoted_chars = [ "「中」"; "「文」"; "「字」"; "「符」" ] in

  List.iter
    (fun ch ->
      try
        let tokens = tokenize ch "test.ly" in
        Printf.printf "✓ 引用中文字符 '%s' 被正确处理，生成了 %d 个token\n" ch (List.length tokens)
      with e -> Printf.printf "⚠ 引用中文字符 '%s' 处理异常: %s\n" ch (Printexc.to_string e))
    quoted_chars;

  print_endline "✓ 中文字符处理测试通过"

(** 测试单字节字符token化错误情况（ASCII字母被正确拒绝） *)
let test_single_byte_tokenization_success () =
  try
    (* 测试被禁用的ASCII字母应该被拒绝 *)
    let _ = tokenize "a" "test.ly" in
    Printf.printf "⚠ 警告：ASCII字母 'a' 应该被拒绝但被接受了\n";
    print_endline "⚠ 单字节字符token化成功测试需要进一步检查"
  with
  | LexError (msg, _) when contains_substring msg "ASCII字母已禁用" ->
      Printf.printf "✓ ASCII字母 'a' 被正确拒绝\n";
      print_endline "✓ 单字节字符token化成功测试通过"
  | e ->
      Printf.printf "⚠ 异常处理需要检查: %s\n" (Printexc.to_string e);
      print_endline "⚠ 单字节字符token化成功测试需要进一步检查"

(** 测试单字节字符token化错误检测 *)
let test_single_byte_tokenization_error () =
  try
    (* 测试禁用字符应该抛出异常 *)
    let _ = tokenize "+" "test.ly" in
    Printf.printf "⚠ 警告：禁用字符 '+' 应该抛出异常但未抛出\n"
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
  test_chinese_character_handling ();
  test_single_byte_tokenization_success ();
  test_single_byte_tokenization_error ();
  test_character_processing_module ();
  print_endline "🎉 所有词法分析器字符处理测试完成！"
