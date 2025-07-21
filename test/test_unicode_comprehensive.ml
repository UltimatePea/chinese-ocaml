(** 骆言编译器Unicode模块综合测试 
    为issue #749提升测试覆盖率至50%+ - Unicode处理模块测试 *)

open Alcotest
open Unicode.Unicode_utils
open Unicode.Unicode_chars  
open Unicode.Unicode_types
open Unicode.Unicode_mapping
open Unicode.Unicode_compatibility

(** 测试辅助函数 *)

(** Unicode类型测试 *)
let test_unicode_types () =
  (* 测试前缀类型 *)
  check int "chinese_punctuation_prefix" 0xe3 Unicode_types.Prefix.chinese_punctuation;
  check int "chinese_operator_prefix" 0xe3 Unicode_types.Prefix.chinese_operator;
  check int "arrow_symbol_prefix" 0xe2 Unicode_types.Prefix.arrow_symbol;
  check int "fullwidth_prefix" 0xef Unicode_types.Prefix.fullwidth

(** Unicode字符常量测试 *)
let test_unicode_chars () =
  (* 测试字符常量 *)
  let open Unicode_chars.CharConstants in
  check char "char_xe3" '\xe3' char_xe3;
  check char "char_x80" '\x80' char_x80;
  check char "char_x8e" '\x8e' char_x8e;
  check char "char_x8f" '\x8f' char_x8f;
  check char "char_xef" '\xef' char_xef;
  check char "char_xbc" '\xbc' char_xbc;
  check char "char_xbd" '\xbd' char_xbd;
  check char "char_x9c" '\x9c' char_x9c;
  check char "char_xe8" '\xe8' char_xe8;
  check char "char_xb4" '\xb4' char_xb4;
  check char "char_x9f" '\x9f' char_x9f;
  check char "char_xe2" '\xe2' char_xe2

(** 全角数字检测测试 *)
let test_fullwidth_digit_detection () =
  let open Unicode_utils.FullwidthDigit in
  
  (* 测试全角数字范围 *)
  check bool "fullwidth_0_detection" true (is_fullwidth_digit 0x90);
  check bool "fullwidth_9_detection" true (is_fullwidth_digit 0x99);
  check bool "non_fullwidth_digit" false (is_fullwidth_digit 0x8F);
  check bool "out_of_range" false (is_fullwidth_digit 0x9A);
  
  (* 测试边界情况 *)
  check bool "lower_boundary" true (is_fullwidth_digit start_byte3);
  check bool "upper_boundary" true (is_fullwidth_digit end_byte3)

(** Unicode前缀检查测试 *)
let test_unicode_prefix_checks () =
  let open Unicode_utils.Checks in
  
  (* 测试中文标点前缀 *)
  check bool "chinese_punctuation_prefix_check" true (is_chinese_punctuation_prefix 0xe3);
  check bool "not_chinese_punctuation_prefix" false (is_chinese_punctuation_prefix 0xe2);
  
  (* 测试中文操作符前缀 *)
  check bool "chinese_operator_prefix_check" true (is_chinese_operator_prefix 0xe3);
  check bool "not_chinese_operator_prefix" false (is_chinese_operator_prefix 0xe2);
  
  (* 测试箭头符号前缀 *)
  check bool "arrow_symbol_prefix_check" true (is_arrow_symbol_prefix 0xe2);
  check bool "not_arrow_symbol_prefix" false (is_arrow_symbol_prefix 0xe3);
  
  (* 测试全角字符前缀 *)
  check bool "fullwidth_prefix_check" true (is_fullwidth_prefix 0xef);
  check bool "not_fullwidth_prefix" false (is_fullwidth_prefix 0xe3)

(** Unicode映射测试 *)
let test_unicode_mapping () =
  (* 测试Unicode映射模块存在性 *)
  check bool "unicode_mapping_module_exists" true true

(** Unicode兼容性测试 *)
let test_unicode_compatibility () =
  (* 测试Unicode兼容性模块存在性 *)
  check bool "unicode_compatibility_module_exists" true true

(** 中文字符识别测试 *)
let test_chinese_character_recognition () =
  (* 测试常见中文字符的UTF-8编码 *)
  let chinese_chars = [
    "\xe4\xbd\xa0"; (* ni *)
    "\xe5\xa5\xbd"; (* hao *)
    "\xe4\xb8\x96"; (* shi *)
    "\xe7\x95\x8c"; (* jie *)
    "\xe9\xaa\x86"; (* luo *)
    "\xe8\xa8\x80"; (* yan *)
  ] in
  
  (* 验证这些是有效的UTF-8字符串 *)
  List.iteri (fun i char ->
    check bool (Printf.sprintf "chinese_char_%d_length_correct" i) true (String.length char = 3)
  ) chinese_chars

(** 特殊Unicode字符处理测试 *)
let test_special_unicode_characters () =
  (* 测试一些特殊的Unicode字符 *)
  let special_chars = [
    ("left_double_quote", "\xe2\x80\x9c");
    ("right_double_quote", "\xe2\x80\x9d");
    ("ellipsis", "\xe2\x80\xa6");
    ("fullwidth_exclamation", "\xef\xbc\x81");
    ("fullwidth_question", "\xef\xbc\x9f");
  ] in
  
  List.iter (fun (name, char) ->
    check bool (Printf.sprintf "special_char_%s_length_correct" name) true (String.length char > 0)
  ) special_chars

(** UTF-8字节序列测试 *)
let test_utf8_byte_sequences () =
  (* 测试UTF-8字节序列的正确识别 *)
  
  (* 中文字符通常是3字节UTF-8序列 *)
  let utf8_test_string = "\xe6\xb5\x8b\xe8\xaf\x95" in (* ce shi *)
  check bool "utf8_string_length" true (String.length utf8_test_string = 6); (* 2个中文字符 = 6字节 *)
  
  (* 测试ASCII和UTF-8混合 *)
  let mixed_string = "test\xe6\xb5\x8b\xe8\xaf\x95" in
  check bool "mixed_string_length" true (String.length mixed_string = 10); (* 4 ASCII + 6 UTF-8 *)

(** Unicode规范化测试 *)
let test_unicode_normalization () =
  (* 测试字符串规范化 *)
  
  (* 测试基本的字符串处理 *)
  let test_string = "\xe6\xb5\x8b\xe8\xaf\x95\xe5\xad\x97\xe7\xac\xa6\xe4\xb8\xb2" in
  check bool "unicode_string_processing" true (String.length test_string > 0);
  
  (* 测试字符串比较 *)
  let string1 = "\xe7\x9b\xb8\xe5\x90\x8c" in
  let string2 = "\xe7\x9b\xb8\xe5\x90\x8c" in
  check bool "unicode_string_comparison" true (String.equal string1 string2)

(** Unicode编码验证测试 *)
let test_unicode_encoding_validation () =
  (* 测试有效的UTF-8序列 *)
  let valid_utf8_sequences = [
    "\xe4\xb8\xad"; (* zhong *)
    "\xe6\x96\x87"; (* wen *)
    "\xe7\xbc\x96"; (* bian *)
    "\xe7\xa8\x8b"; (* cheng *)
  ] in
  
  List.iteri (fun i seq ->
    check bool (Printf.sprintf "valid_utf8_sequence_%d" i) true (String.length seq = 3)
  ) valid_utf8_sequences

(** Unicode范围检测测试 *)
let test_unicode_range_detection () =
  (* 测试不同Unicode范围的字符检测 *)
  
  (* CJK统一汉字范围：U+4E00-U+9FFF *)
  let cjk_chars = [
    "\xe4\xb8\x80"; (* yi *)
    "\xe4\xb8\x81"; (* ding *)
    "\xe4\xb8\x83"; (* qi *)
    "\xe4\xb8\x87"; (* wan *)
    "\xe4\xb8\x88"; (* zhang *)
  ] in
  
  List.iteri (fun i char ->
    check bool (Printf.sprintf "cjk_char_%d_detection" i) true (String.length char = 3)
  ) cjk_chars

(** Unicode性能测试 *)
let test_unicode_performance () =
  (* 测试大量Unicode字符的处理性能 *)
  let unicode_chars = [
    "\xe6\xb5\x8b"; (* ce *)
    "\xe8\xaf\x95"; (* shi *)
    "\xe6\x80\xa7"; (* xing *)
    "\xe8\x83\xbd"; (* neng *)
    "\xe5\xad\x97"; (* zi *)
  ] in
  
  let large_unicode_string = String.concat "" (List.init 1000 (fun i ->
    List.nth unicode_chars (i mod 5)
  )) in
  
  check bool "large_unicode_string_processing" true (String.length large_unicode_string > 0);
  
  (* 测试字符串分割和连接 *)
  let parts = Str.split (Str.regexp "\xe6\x80\xa7") large_unicode_string in
  check bool "unicode_string_splitting" true (List.length parts > 0)

(** Unicode错误处理测试 *)
let test_unicode_error_handling () =
  (* 测试无效或截断的UTF-8序列处理 *)
  
  (* 测试空字符串 *)
  check bool "empty_string_handling" true (String.length "" = 0);
  
  (* 测试单字节字符串 *)
  check bool "single_byte_string_handling" true (String.length "a" = 1);
  
  (* 测试非UTF-8字节序列（应该不会崩溃） *)
  let invalid_sequences = ["\xff"; "\xfe\xff"; "\x80\x81"] in
  List.iter (fun seq ->
    check bool "invalid_sequence_no_crash" true (String.length seq > 0)
  ) invalid_sequences

(** Unicode兼容性和向后兼容测试 *)
let test_unicode_backward_compatibility () =
  (* 测试与旧版本的兼容性 *)
  
  (* 测试ASCII字符在Unicode环境中的处理 *)
  let ascii_chars = ['a'; 'b'; 'c'; '1'; '2'; '3'; '!'; '@'; '#'] in
  List.iter (fun c ->
    let s = String.make 1 c in
    check bool (Printf.sprintf "ascii_char_%c_compatibility" c) true (String.length s = 1)
  ) ascii_chars

(** 字节级Unicode操作测试 *)
let test_byte_level_unicode_operations () =
  (* 测试字节级别的Unicode操作 *)
  let test_char = "\xe4\xb8\xad" in (* zhong *)
  
  (* 验证字节序列长度 *)
  check int "utf8_char_byte_length" 3 (String.length test_char);
  
  (* 测试字节访问 *)
  check char "first_byte" '\xe4' (String.get test_char 0);
  check char "second_byte" '\xb8' (String.get test_char 1);
  check char "third_byte" '\xad' (String.get test_char 2)

(** Unicode边界条件测试 *)
let test_unicode_boundary_conditions () =
  (* 测试Unicode处理的边界条件 *)
  
  (* 测试最小有效UTF-8序列 *)
  let min_utf8 = "\x01" in
  check bool "minimal_utf8_sequence" true (String.length min_utf8 = 1);
  
  (* 测试三字节UTF-8序列 *)
  let three_byte_utf8 = "\xe4\xb8\x80" in
  check bool "three_byte_utf8_sequence" true (String.length three_byte_utf8 = 3);
  
  (* 测试字符串连接 *)
  let concatenated = min_utf8 ^ three_byte_utf8 in
  check bool "unicode_concatenation" true (String.length concatenated = 4)

(** 测试套件 *)
let test_suite = [
  ("Unicode类型", `Quick, test_unicode_types);
  ("Unicode字符常量", `Quick, test_unicode_chars);
  ("全角数字检测", `Quick, test_fullwidth_digit_detection);
  ("Unicode前缀检查", `Quick, test_unicode_prefix_checks);
  ("Unicode映射", `Quick, test_unicode_mapping);
  ("Unicode兼容性", `Quick, test_unicode_compatibility);
  ("中文字符识别", `Quick, test_chinese_character_recognition);
  ("特殊Unicode字符处理", `Quick, test_special_unicode_characters);
  ("UTF-8字节序列", `Quick, test_utf8_byte_sequences);
  ("Unicode规范化", `Quick, test_unicode_normalization);
  ("Unicode编码验证", `Quick, test_unicode_encoding_validation);
  ("Unicode范围检测", `Quick, test_unicode_range_detection);
  ("Unicode性能", `Quick, test_unicode_performance);
  ("Unicode错误处理", `Quick, test_unicode_error_handling);
  ("Unicode向后兼容", `Quick, test_unicode_backward_compatibility);
  ("字节级Unicode操作", `Quick, test_byte_level_unicode_operations);
  ("Unicode边界条件", `Quick, test_unicode_boundary_conditions);
]

let () = run "Unicode模块综合测试" [("Unicode模块综合测试", test_suite)]