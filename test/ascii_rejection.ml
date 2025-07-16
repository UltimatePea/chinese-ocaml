(** ASCII符号拒绝测试 *)

open Alcotest
open Yyocamlc_lib.Lexer

(** 辅助函数：检查字符串是否包含指定的UTF-8子字符串 *)
let contains_utf8_substring haystack needle =
  try
    let _ = Str.search_forward (Str.regexp_string needle) haystack 0 in
    true
  with Not_found -> false

(** 测试ASCII运算符被拒绝 *)
let test_ascii_operators_rejected () =
  let ascii_operators = [ "+"; "-"; "*"; "/"; "%"; "^"; "="; "<"; ">"; "." ] in

  List.iter
    (fun op ->
      try
        let _ = tokenize op "<test>" in
        check bool ("ASCII运算符 " ^ op ^ " 应该被拒绝") false true
      with
      | LexError (msg, _) ->
          let contains_expected =
            contains_utf8_substring msg "符" && contains_utf8_substring msg "禁"
          in
          check bool ("ASCII运算符 " ^ op ^ " 错误消息应该包含'符号已禁用'") true contains_expected
      | _ -> check bool ("ASCII运算符 " ^ op ^ " 应该抛出 LexError") false true)
    ascii_operators

(** 测试ASCII标点符号被拒绝 *)
let test_ascii_punctuation_rejected () =
  let ascii_punctuation = [ "("; ")"; "["; "]"; "{"; "}"; ","; ";"; ":"; "|"; "_"; "\"" ] in

  List.iter
    (fun punct ->
      try
        let _ = tokenize punct "<test>" in
        check bool ("ASCII标点符号 " ^ punct ^ " 应该被拒绝") false true
      with
      | LexError (msg, _) ->
          let contains_expected =
            contains_utf8_substring msg "符" && contains_utf8_substring msg "禁"
          in
          check bool ("ASCII标点符号 " ^ punct ^ " 错误消息应该包含'符号已禁用'") true contains_expected
      | _ -> check bool ("ASCII标点符号 " ^ punct ^ " 应该抛出 LexError") false true)
    ascii_punctuation

(** 测试ASCII数字被允许 - Issue #192 *)
let test_ascii_digits_allowed () =
  let ascii_digits = [ "0"; "1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"; "9" ] in

  List.iter
    (fun digit ->
      try
        let tokens = tokenize digit "<test>" in
        match tokens with
        | [ (IntToken n, _); (EOF, _) ] when n = int_of_string digit ->
            check bool ("ASCII数字 " ^ digit ^ " 应该被识别为 IntToken") true true
        | _ -> check bool ("ASCII数字 " ^ digit ^ " 应该产生正确的tokens") false true
      with _ -> check bool ("ASCII数字 " ^ digit ^ " 不应该抛出错误") false true)
    ascii_digits

(** 测试ASCII字母作为非关键字被拒绝 *)
let test_ascii_letters_rejected () =
  let ascii_letters = [ "a"; "b"; "x"; "y"; "z"; "A"; "B"; "X"; "Y"; "Z" ] in

  List.iter
    (fun letter ->
      try
        let _ = tokenize letter "<test>" in
        check bool ("ASCII字母 " ^ letter ^ " 应该被拒绝") false true
      with
      | LexError (msg, _) ->
          let contains_expected =
            contains_utf8_substring msg "字" && contains_utf8_substring msg "禁"
          in
          check bool ("ASCII字母 " ^ letter ^ " 错误消息应该包含'字母已禁用'") true contains_expected
      | _ -> check bool ("ASCII字母 " ^ letter ^ " 应该抛出 LexError") false true)
    ascii_letters

(** 测试ASCII关键字仍然被允许 *)
let test_ascii_keywords_allowed () =
  (* "of" 是一个ASCII关键字，应该仍然被允许 *)
  try
    let tokens = tokenize "of" "<test>" in
    match tokens with
    | [ (token, _); (EOF, _) ] ->
        check bool "ASCII关键字 'of' 应该被识别为 OfKeyword" true (token = OfKeyword)
    | _ -> check bool "ASCII关键字 'of' 应该产生正确的tokens" false true
  with _ -> check bool "ASCII关键字 'of' 不应该抛出错误" false true

(** 测试中文符号仍然正常工作 *)
let test_chinese_symbols_work () =
  try
    let tokens = tokenize "（" "<test>" in
    match tokens with
    | [ (token, _); (EOF, _) ] ->
        check bool "中文符号 '（' 应该被识别为 ChineseLeftParen" true (token = ChineseLeftParen)
    | _ -> check bool "中文符号 '（' 应该产生正确的tokens" false true
  with _ -> check bool "中文符号 '（' 不应该抛出错误" false true

(** 测试中文数字正常工作（Issue #105: 替代全宽数字） *)
let test_fullwidth_digits_work () =
  try
    let tokens = tokenize "「零」" "<test>" in
    match tokens with
    | [ (QuotedIdentifierToken "零", _); (EOF, _) ] ->
        check bool "中文数字 '「零」' 应该被识别为 QuotedIdentifierToken " true true
    | [ (token, _); (EOF, _) ] ->
        check bool ("中文数字 '「零」' 应该被识别为 QuotedIdentifierToken，但得到: " ^ show_token token) false true
    | _ -> check bool "中文数字 '「零」' 应该产生正确的tokens" false true
  with _ -> check bool "中文数字 '「零」' 不应该抛出错误" false true

(** ASCII拒绝测试套件 *)
let () =
  run "ASCII符号拒绝测试"
    [
      ( "ASCII符号拒绝",
        [
          test_case "ASCII运算符被拒绝" `Quick test_ascii_operators_rejected;
          test_case "ASCII标点符号被拒绝" `Quick test_ascii_punctuation_rejected;
          test_case "ASCII数字被允许" `Quick test_ascii_digits_allowed;
          test_case "ASCII字母被拒绝" `Quick test_ascii_letters_rejected;
        ] );
      ( "允许的字符",
        [
          test_case "ASCII关键字仍然允许" `Quick test_ascii_keywords_allowed;
          test_case "中文符号正常工作" `Quick test_chinese_symbols_work;
          test_case "中文数字正常工作" `Quick test_fullwidth_digits_work;
        ] );
    ]
