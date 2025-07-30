(** 中文字符分析测试套件 Author: Echo, 测试工程师代理 (重构自原调试代码) 目标: 测试中文字符处理和字节分析功能 *)

open Alcotest

(** {1 字符分析功能测试} *)

let test_chinese_character_byte_length () =
  let char = "为" in
  let byte_length = String.length char in
  check int "中文字符字节长度应该大于1" 3 byte_length

let test_fullwidth_number_analysis () =
  let char = "４" in
  let byte_length = String.length char in
  check bool "全角数字字节长度应该大于1" true (byte_length > 1)

let test_multiple_chinese_chars () =
  let chars = [ "为"; "４"; "２" ] in
  let all_multi_byte = List.for_all (fun c -> String.length c > 1) chars in
  check bool "所有中文字符都应该是多字节" true all_multi_byte

let test_character_encoding_consistency () =
  let char = "为" in
  let byte_length = String.length char in
  (* UTF-8编码的中文字符通常是3字节 *)
  check bool "中文字符编码一致性" true (byte_length >= 2)

(** {2 边界条件测试} *)

let test_empty_string_analysis () =
  let empty = "" in
  let byte_length = String.length empty in
  check int "空字符串字节长度应该为0" 0 byte_length

let test_ascii_vs_chinese_comparison () =
  let ascii_char = "a" in
  let chinese_char = "为" in
  let ascii_length = String.length ascii_char in
  let chinese_length = String.length chinese_char in
  check bool "中文字符应该比ASCII字符占用更多字节" true (chinese_length > ascii_length)

(** {3 实用功能测试} *)

let analyze_char_bytes c =
  let length = String.length c in
  let bytes = Array.make length 0 in
  for i = 0 to length - 1 do
    bytes.(i) <- Char.code c.[i]
  done;
  (length, bytes)

let test_char_byte_analysis_function () =
  let length, _bytes = analyze_char_bytes "为" in
  check bool "字符分析函数应该返回正确长度" true (length > 0)

let test_fullwidth_number_bytes () =
  let length, bytes = analyze_char_bytes "４" in
  check bool "全角数字分析" true (length > 1 && Array.length bytes > 0)

(** {4 测试套件定义} *)

let character_analysis_suite =
  [
    ("中文字符字节长度", `Quick, test_chinese_character_byte_length);
    ("全角数字分析", `Quick, test_fullwidth_number_analysis);
    ("多中文字符测试", `Quick, test_multiple_chinese_chars);
    ("字符编码一致性", `Quick, test_character_encoding_consistency);
  ]

let boundary_conditions_suite =
  [
    ("空字符串分析", `Quick, test_empty_string_analysis);
    ("ASCII与中文对比", `Quick, test_ascii_vs_chinese_comparison);
  ]

let utility_functions_suite =
  [
    ("字符字节分析函数", `Quick, test_char_byte_analysis_function);
    ("全角数字字节", `Quick, test_fullwidth_number_bytes);
  ]

(** {5 主测试运行器} *)

let () =
  run "中文字符分析测试"
    [
      ("字符分析功能", character_analysis_suite);
      ("边界条件测试", boundary_conditions_suite);
      ("实用功能测试", utility_functions_suite);
    ]
