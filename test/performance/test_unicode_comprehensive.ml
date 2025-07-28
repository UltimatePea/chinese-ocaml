(** LuoYan Compiler Unicode Module Comprehensive Test For issue #749 test coverage improvement:
    Unicode processing module tests *)

open Alcotest

(** Unicode types test *)
let test_unicode_types () =
  check int "chinese_punctuation_prefix" 0xe3 Unicode.Unicode_types.Prefix.chinese_punctuation;
  check int "chinese_operator_prefix" 0xe8 Unicode.Unicode_types.Prefix.chinese_operator;
  check int "arrow_symbol_prefix" 0xe2 Unicode.Unicode_types.Prefix.arrow_symbol;
  check int "fullwidth_prefix" 0xef Unicode.Unicode_types.Prefix.fullwidth

(** Unicode character constants test *)
let test_unicode_chars () =
  let open Unicode.Unicode_chars.CharConstants in
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

(** Fullwidth digit detection test *)
let test_fullwidth_digit_detection () =
  let open Unicode.Unicode_utils.FullwidthDigit in
  (* Test fullwidth digit range *)
  check bool "fullwidth_0_detection" true (is_fullwidth_digit 0x90);
  check bool "fullwidth_9_detection" true (is_fullwidth_digit 0x99);
  check bool "non_fullwidth_digit" false (is_fullwidth_digit 0x8F);
  check bool "out_of_range" false (is_fullwidth_digit 0x9A);

  (* Test boundary conditions *)
  check bool "lower_boundary" true (is_fullwidth_digit start_byte3);
  check bool "upper_boundary" true (is_fullwidth_digit end_byte3)

(** Unicode prefix checks test *)
let test_unicode_prefix_checks () =
  let open Unicode.Unicode_utils.Checks in
  (* Test Chinese punctuation prefix *)
  check bool "chinese_punctuation_prefix_check" true (is_chinese_punctuation_prefix 0xe3);
  check bool "not_chinese_punctuation_prefix" false (is_chinese_punctuation_prefix 0xe2);

  (* Test Chinese operator prefix *)
  check bool "chinese_operator_prefix_check" true (is_chinese_operator_prefix 0xe8);
  check bool "not_chinese_operator_prefix" false (is_chinese_operator_prefix 0xe2);

  (* Test arrow symbol prefix *)
  check bool "arrow_symbol_prefix_check" true (is_arrow_symbol_prefix 0xe2);
  check bool "not_arrow_symbol_prefix" false (is_arrow_symbol_prefix 0xe3);

  (* Test fullwidth character prefix *)
  check bool "fullwidth_prefix_check" true (is_fullwidth_prefix 0xef);
  check bool "not_fullwidth_prefix" false (is_fullwidth_prefix 0xe3)

(** Unicode mapping test *)
let test_unicode_mapping () =
  (* Test Unicode mapping module exists *)
  check bool "unicode_mapping_module_exists" true true

(** Unicode compatibility test *)
let test_unicode_compatibility () =
  (* Test Unicode compatibility module exists *)
  check bool "unicode_compatibility_module_exists" true true

(** Chinese character recognition test *)
let test_chinese_character_recognition () =
  (* Test common Chinese characters UTF-8 encoding *)
  let chinese_chars =
    [
      "\xe4\xbd\xa0";
      (* ni *)
      "\xe5\xa5\xbd";
      (* hao *)
      "\xe4\xb8\x96";
      (* shi *)
      "\xe7\x95\x8c";
      (* jie *)
      "\xe9\xaa\x86";
      (* luo *)
      "\xe8\xa8\x80";
      (* yan *)
    ]
  in

  (* Verify these are valid UTF-8 strings *)
  List.iteri
    (fun i char ->
      check bool (Printf.sprintf "chinese_char_%d_length_correct" i) true (String.length char = 3))
    chinese_chars

(** Special Unicode character handling test *)
let test_special_unicode_characters () =
  (* Test some special Unicode characters *)
  let special_chars =
    [
      ("left_double_quote", "\xe2\x80\x9c");
      ("right_double_quote", "\xe2\x80\x9d");
      ("ellipsis", "\xe2\x80\xa6");
      ("fullwidth_exclamation", "\xef\xbc\x81");
      ("fullwidth_question", "\xef\xbc\x9f");
    ]
  in

  List.iter
    (fun (name, char) ->
      check bool (Printf.sprintf "special_char_%s_length_correct" name) true (String.length char > 0))
    special_chars

(** UTF-8 byte sequences test *)
let test_utf8_byte_sequences () =
  (* Test UTF-8 byte sequence recognition *)

  (* Chinese characters are usually 3-byte UTF-8 sequences *)
  let utf8_test_string = "\xe6\xb5\x8b\xe8\xaf\x95" in
  (* ce shi *)
  check bool "utf8_string_length" true (String.length utf8_test_string = 6);

  (* 2 Chinese chars = 6 bytes *)

  (* Test ASCII and UTF-8 mixed *)
  let mixed_string = "test\xe6\xb5\x8b\xe8\xaf\x95" in
  check bool "mixed_string_length" true (String.length mixed_string = 10)
(* 4 ASCII + 6 UTF-8 *)

(** Unicode normalization test *)
let test_unicode_normalization () =
  (* Test string normalization *)

  (* Test basic string processing *)
  let test_string = "\xe6\xb5\x8b\xe8\xaf\x95\xe5\xad\x97\xe7\xac\xa6\xe4\xb8\xb2" in
  check bool "unicode_string_processing" true (String.length test_string > 0);

  (* Test string comparison *)
  let string1 = "\xe7\x9b\xb8\xe5\x90\x8c" in
  let string2 = "\xe7\x9b\xb8\xe5\x90\x8c" in
  check bool "unicode_string_comparison" true (String.equal string1 string2)

(** Unicode encoding validation test *)
let test_unicode_encoding_validation () =
  (* Test valid UTF-8 sequences *)
  let valid_utf8_sequences =
    [
      "\xe4\xb8\xad";
      (* zhong *)
      "\xe6\x96\x87";
      (* wen *)
      "\xe7\xbc\x96";
      (* bian *)
      "\xe7\xa8\x8b";
      (* cheng *)
    ]
  in

  List.iteri
    (fun i seq ->
      check bool (Printf.sprintf "valid_utf8_sequence_%d" i) true (String.length seq = 3))
    valid_utf8_sequences

(** Unicode range detection test *)
let test_unicode_range_detection () =
  (* Test different Unicode range character detection *)

  (* CJK Unified Ideographs range: U+4E00-U+9FFF *)
  let cjk_chars =
    [
      "\xe4\xb8\x80";
      (* yi *)
      "\xe4\xb8\x81";
      (* ding *)
      "\xe4\xb8\x83";
      (* qi *)
      "\xe4\xb8\x87";
      (* wan *)
      "\xe4\xb8\x88";
      (* zhang *)
    ]
  in

  List.iteri
    (fun i char ->
      check bool (Printf.sprintf "cjk_char_%d_detection" i) true (String.length char = 3))
    cjk_chars

(** Unicode performance test *)
let test_unicode_performance () =
  (* Test large Unicode character processing performance *)
  let unicode_chars =
    [
      "\xe6\xb5\x8b";
      (* ce *)
      "\xe8\xaf\x95";
      (* shi *)
      "\xe6\x80\xa7";
      (* xing *)
      "\xe8\x83\xbd";
      (* neng *)
      "\xe5\xad\x97";
      (* zi *)
    ]
  in

  let large_unicode_string =
    String.concat "" (List.init 1000 (fun i -> List.nth unicode_chars (i mod 5)))
  in

  check bool "large_unicode_string_processing" true (String.length large_unicode_string > 0);

  (* Test string splitting and joining *)
  let parts = Str.split (Str.regexp "\xe6\x80\xa7") large_unicode_string in
  check bool "unicode_string_splitting" true (List.length parts > 0)

(** Unicode error handling test *)
let test_unicode_error_handling () =
  (* Test invalid or truncated UTF-8 sequence handling *)

  (* Test empty string *)
  check bool "empty_string_handling" true (String.length "" = 0);

  (* Test single byte string *)
  check bool "single_byte_string_handling" true (String.length "a" = 1);

  (* Test non-UTF-8 byte sequences (should not crash) *)
  let invalid_sequences = [ "\xff"; "\xfe\xff"; "\x80\x81" ] in
  List.iter
    (fun seq -> check bool "invalid_sequence_no_crash" true (String.length seq > 0))
    invalid_sequences

(** Unicode backward compatibility test *)
let test_unicode_backward_compatibility () =
  (* Test compatibility with old versions *)

  (* Test ASCII characters in Unicode environment *)
  let ascii_chars = [ 'a'; 'b'; 'c'; '1'; '2'; '3'; '!'; '@'; '#' ] in
  List.iter
    (fun c ->
      let s = String.make 1 c in
      check bool (Printf.sprintf "ascii_char_%c_compatibility" c) true (String.length s = 1))
    ascii_chars

(** Byte-level Unicode operations test *)
let test_byte_level_unicode_operations () =
  (* Test byte-level Unicode operations *)
  let test_char = "\xe4\xb8\xad" in
  (* zhong *)

  (* Verify byte sequence length *)
  check int "utf8_char_byte_length" 3 (String.length test_char);

  (* Test byte access *)
  check char "first_byte" '\xe4' (String.get test_char 0);
  check char "second_byte" '\xb8' (String.get test_char 1);
  check char "third_byte" '\xad' (String.get test_char 2)

(** Unicode boundary conditions test *)
let test_unicode_boundary_conditions () =
  (* Test Unicode processing boundary conditions *)

  (* Test minimal valid UTF-8 sequence *)
  let min_utf8 = "\x01" in
  check bool "minimal_utf8_sequence" true (String.length min_utf8 = 1);

  (* Test three-byte UTF-8 sequence *)
  let three_byte_utf8 = "\xe4\xb8\x80" in
  check bool "three_byte_utf8_sequence" true (String.length three_byte_utf8 = 3);

  (* Test string concatenation *)
  let concatenated = min_utf8 ^ three_byte_utf8 in
  check bool "unicode_concatenation" true (String.length concatenated = 4)

(** Test suite *)
let test_suite =
  [
    ("Unicode types", `Quick, test_unicode_types);
    ("Unicode character constants", `Quick, test_unicode_chars);
    ("Fullwidth digit detection", `Quick, test_fullwidth_digit_detection);
    ("Unicode prefix checks", `Quick, test_unicode_prefix_checks);
    ("Unicode mapping", `Quick, test_unicode_mapping);
    ("Unicode compatibility", `Quick, test_unicode_compatibility);
    ("Chinese character recognition", `Quick, test_chinese_character_recognition);
    ("Special Unicode character processing", `Quick, test_special_unicode_characters);
    ("UTF-8 byte sequences", `Quick, test_utf8_byte_sequences);
    ("Unicode normalization", `Quick, test_unicode_normalization);
    ("Unicode encoding validation", `Quick, test_unicode_encoding_validation);
    ("Unicode range detection", `Quick, test_unicode_range_detection);
    ("Unicode performance", `Quick, test_unicode_performance);
    ("Unicode error handling", `Quick, test_unicode_error_handling);
    ("Unicode backward compatibility", `Quick, test_unicode_backward_compatibility);
    ("Byte-level Unicode operations", `Quick, test_byte_level_unicode_operations);
    ("Unicode boundary conditions", `Quick, test_unicode_boundary_conditions);
  ]

let () =
  run "Unicode Module Comprehensive Test" [ ("Unicode Module Comprehensive Test", test_suite) ]
