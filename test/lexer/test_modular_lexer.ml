(** 测试模块化词法分析器 *)

open Yyocamlc_lib.Lexer

let test_basic_tokenization () =
  let input = "让 「变量」 = 123" in
  let filename = "test.ly" in
  try
    let tokens = Yyocamlc_lib.Lexer.tokenize input filename in
    Printf.printf "成功解析 %d 个token：\n" (List.length tokens);
    List.iter
      (fun (token, pos) -> Printf.printf "  %s 在 %d:%d\n" (show_token token) pos.line pos.column)
      tokens;
    true
  with
  | LexError (msg, pos) ->
      Printf.printf "词法分析错误：%s 在 %d:%d\n" msg pos.line pos.column;
      false
  | e ->
      Printf.printf "其他错误：%s\n" (Printexc.to_string e);
      false

let test_keyword_matching () =
  let test_cases = [ "让"; "函数"; "如果"; "否则"; "匹配"; "let"; "function"; "if"; "else"; "match" ] in
  Printf.printf "\n测试关键字匹配：\n";
  List.iter (fun keyword -> Printf.printf "  %s -> 关键字测试跳过\n" keyword) test_cases

let test_utf8_utils () =
  let test_strings = [ "让"; "变量"; "123"; "hello"; "一二三" ] in
  Printf.printf "\n测试UTF-8工具：\n";
  List.iter
    (fun s ->
      Printf.printf "  %s: 长度=%d, 全中文=%b\n" s
        (Yyocamlc_lib.Utf8_utils.StringUtils.utf8_length s)
        (Yyocamlc_lib.Utf8_utils.StringUtils.is_all_chinese s))
    test_strings

let () =
  Printf.printf "=== 模块化词法分析器测试 ===\n";
  let success = test_basic_tokenization () in
  test_keyword_matching ();
  test_utf8_utils ();

  if success then Printf.printf "\n✓ 基本测试通过！\n" else Printf.printf "\n✗ 基本测试失败！\n"
