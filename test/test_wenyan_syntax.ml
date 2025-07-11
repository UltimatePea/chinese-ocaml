open Alcotest
open Yyocamlc_lib

(** 测试文言风格关键字词法分析 *)
let test_wenyan_lexer () =
  let input = "吾有 一 名曰 设 也 乃 曰 其值 为 数" in
  let token_list = Lexer.tokenize input "test" in
  let keywords = [
    Lexer.HaveKeyword;
    Lexer.OneKeyword;
    Lexer.NameKeyword;
    Lexer.SetKeyword;
    Lexer.AlsoKeyword;
    Lexer.ThenGetKeyword;
    Lexer.CallKeyword;
    Lexer.ValueKeyword;
    Lexer.AsForKeyword;
    Lexer.NumberKeyword;
  ] in
  let actual_keywords = List.map (fun (token, _) -> token) token_list in
  let wenyan_keyword_tokens = List.filter (function
    | Lexer.HaveKeyword | Lexer.OneKeyword | Lexer.NameKeyword | Lexer.SetKeyword |
      Lexer.AlsoKeyword | Lexer.ThenGetKeyword | Lexer.CallKeyword | Lexer.ValueKeyword |
      Lexer.AsForKeyword | Lexer.NumberKeyword -> true
    | _ -> false) actual_keywords in
  check int "文言风格关键字数量" (List.length keywords) (List.length wenyan_keyword_tokens)

(** 测试文言风格语法解析 *)
let test_wenyan_parsing () =
  (* 测试简单的设语句解析 *)
  let code = "设数值为42" in
  let tokens = Lexer.tokenize code "test_wenyan.yu" in
  let state = Parser.create_parser_state tokens in
  try
    let (_ast, _) = Parser.parse_expression state in
    (* 检查是否解析成功（不抛出异常） *)
    check bool "设语句解析成功" true true
  with
  | Parser.SyntaxError (msg, _) -> failwith ("语法解析失败: " ^ msg)
  | _ -> failwith "意外的解析错误"

(** 测试吾有语句解析 *)
let test_wenyan_full_parsing () =
  (* 测试吾有语句解析 *)
  let code = "吾有一数名曰数值其值42也" in
  let tokens = Lexer.tokenize code "test_wenyan.yu" in
  let state = Parser.create_parser_state tokens in
  try
    let (_ast, _) = Parser.parse_expression state in
    (* 检查是否解析成功（不抛出异常） *)
    check bool "吾有语句解析成功" true true
  with
  | Parser.SyntaxError (msg, _) -> failwith ("语法解析失败: " ^ msg)
  | _ -> failwith "意外的解析错误"

let wenyan_syntax_tests = [
  ("文言风格关键字词法分析", `Quick, test_wenyan_lexer);
  ("文言风格语法解析", `Quick, test_wenyan_parsing);
  ("文言风格完整语法解析", `Quick, test_wenyan_full_parsing);
]

let () =
  run "文言风格语法测试" [
    ("文言语法", wenyan_syntax_tests);
  ]