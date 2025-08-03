open Yyocamlc.Builtin_shared_utils
open Yyocamlc.Builtin_string.Unicode_utils

(* Test Unicode string reversal *)
let test_unicode_reversal () =
  Printf.printf "Testing Unicode string reversal:\n";
  
  (* Test Chinese characters *)
  let chinese_test = "测试" in
  let reversed = reverse_string chinese_test in
  Printf.printf "Input: %s\n" chinese_test;
  Printf.printf "Reversed: %s\n" reversed;
  Printf.printf "Expected: 试测\n";
  Printf.printf "Correct: %b\n\n" (reversed = "试测");
  
  (* Test complex Chinese *)
  let complex_chinese = "中华人民共和国" in
  let complex_reversed = reverse_string complex_chinese in
  Printf.printf "Complex Input: %s\n" complex_chinese;
  Printf.printf "Complex Reversed: %s\n" complex_reversed;
  Printf.printf "Expected: 国和共民人华中\n";
  Printf.printf "Correct: %b\n\n" (complex_reversed = "国和共民人华中");
  
  (* Test UTF-8 character counting *)
  let char_count = utf8_char_count chinese_test in
  Printf.printf "Character count of '测试': %d\n" char_count;
  Printf.printf "Expected: 2\n";
  Printf.printf "Correct: %b\n" (char_count = 2)

let () = test_unicode_reversal ()