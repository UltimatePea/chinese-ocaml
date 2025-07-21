(** 骆言编译器Unicode模块简化测试 
    为issue #749提升测试覆盖率至50%+ - Unicode处理模块测试 *)

open Alcotest

(** Unicode类型测试 *)
let test_unicode_types () =
  check int "chinese_punctuation_prefix" 0xe3 Unicode.Unicode_types.Prefix.chinese_punctuation;
  check int "chinese_operator_prefix" 0xe3 Unicode.Unicode_types.Prefix.chinese_operator;
  check int "arrow_symbol_prefix" 0xe2 Unicode.Unicode_types.Prefix.arrow_symbol;
  check int "fullwidth_prefix" 0xef Unicode.Unicode_types.Prefix.fullwidth

(** Unicode字符常量测试 *)
let test_unicode_chars () =
  let open Unicode.Unicode_chars.CharConstants in
  check char "char_xe3" '\xe3' char_xe3;
  check char "char_x80" '\x80' char_x80;
  check char "char_xef" '\xef' char_xef;
  check char "char_xe2" '\xe2' char_xe2

(** 全角数字检测测试 *)
let test_fullwidth_digit_detection () =
  let open Unicode.Unicode_utils.FullwidthDigit in
  check bool "fullwidth_0_detection" true (is_fullwidth_digit 0x90);
  check bool "fullwidth_9_detection" true (is_fullwidth_digit 0x99);
  check bool "non_fullwidth_digit" false (is_fullwidth_digit 0x8F);
  check bool "out_of_range" false (is_fullwidth_digit 0x9A)

(** Unicode前缀检查测试 *)
let test_unicode_prefix_checks () =
  let open Unicode.Unicode_utils.Checks in
  check bool "chinese_punctuation_prefix_check" true (is_chinese_punctuation_prefix 0xe3);
  check bool "not_chinese_punctuation_prefix" false (is_chinese_punctuation_prefix 0xe2);
  check bool "arrow_symbol_prefix_check" true (is_arrow_symbol_prefix 0xe2);
  check bool "fullwidth_prefix_check" true (is_fullwidth_prefix 0xef)

(** UTF-8字符串测试 *)
let test_utf8_strings () =
  let utf8_char = "\xe4\xb8\xad" in (* zhong *)
  check int "utf8_char_length" 3 (String.length utf8_char);
  
  let mixed_string = "test\xe6\xb5\x8b" in
  check bool "mixed_string_length" true (String.length mixed_string > 4)

(** 基本Unicode操作测试 *)
let test_basic_unicode_operations () =
  let chinese_chars = ["\xe4\xbd\xa0"; "\xe5\xa5\xbd"] in
  List.iter (fun char ->
    check bool "chinese_char_valid" true (String.length char = 3)
  ) chinese_chars;
  
  let ascii_chars = ['a'; 'b'; 'c'] in
  List.iter (fun c ->
    let s = String.make 1 c in
    check bool "ascii_char_valid" true (String.length s = 1)
  ) ascii_chars

(** 测试套件 *)
let test_suite = [
  ("Unicode类型", `Quick, test_unicode_types);
  ("Unicode字符常量", `Quick, test_unicode_chars);
  ("全角数字检测", `Quick, test_fullwidth_digit_detection);
  ("Unicode前缀检查", `Quick, test_unicode_prefix_checks);
  ("UTF-8字符串", `Quick, test_utf8_strings);
  ("基本Unicode操作", `Quick, test_basic_unicode_operations);
]

let () = run "Unicode模块简化测试" [("Unicode模块简化测试", test_suite)]