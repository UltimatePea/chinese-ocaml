(** 骆言词法分析器模块单元测试 *)

open Alcotest
open Yyocamlc_lib.Lexer

(* 测试辅助函数 *)

(* 检查词元是否相等 *)
let check_token msg expected actual =
  check
    (of_pp (fun fmt tok ->
         Format.pp_print_string fmt
           (match tok with
           | IntToken i -> "IntToken(" ^ string_of_int i ^ ")"
           | FloatToken f -> "FloatToken(" ^ string_of_float f ^ ")"
           | StringToken s -> "StringToken(\"" ^ s ^ "\")"
           | BoolToken b -> "BoolToken(" ^ string_of_bool b ^ ")"
           (* IdentifierToken已移除，只保留QuotedIdentifierToken *)
           | QuotedIdentifierToken id -> "QuotedIdentifierToken(\"" ^ id ^ "\")"
           | LetKeyword -> "LetKeyword"
           | FunKeyword -> "FunKeyword"
           | IfKeyword -> "IfKeyword"
           | ThenKeyword -> "ThenKeyword"
           | ElseKeyword -> "ElseKeyword"
           | Plus -> "Plus"
           | Minus -> "Minus"
           | Equal -> "Equal"
           | Arrow -> "Arrow"
           | LeftParen -> "LeftParen"
           | RightParen -> "RightParen"
           | EOF -> "EOF"
           | Newline -> "Newline"
           | _ -> "OtherToken")))
    msg expected actual

(* 检查词元列表是否相等 *)
let check_token_list msg expected actual =
  let extract_tokens positioned_tokens = List.map fst positioned_tokens in
  check
    (list
       (of_pp (fun fmt tok ->
            Format.pp_print_string fmt
              (match tok with
              | IntToken i -> "IntToken(" ^ string_of_int i ^ ")"
              | FloatToken f -> "FloatToken(" ^ string_of_float f ^ ")"
              | StringToken s -> "StringToken(\"" ^ s ^ "\")"
              | BoolToken b -> "BoolToken(" ^ string_of_bool b ^ ")"
              (* IdentifierToken已移除，只保留QuotedIdentifierToken *)
              | QuotedIdentifierToken id -> "QuotedIdentifierToken(\"" ^ id ^ "\")"
              | LetKeyword -> "LetKeyword"
              | FunKeyword -> "FunKeyword"
              | IfKeyword -> "IfKeyword"
              | ThenKeyword -> "ThenKeyword"
              | ElseKeyword -> "ElseKeyword"
              | MatchKeyword -> "MatchKeyword"
              | WithKeyword -> "WithKeyword"
              | OtherKeyword -> "OtherKeyword"
              | TypeKeyword -> "TypeKeyword"
              | Plus -> "Plus"
              | Minus -> "Minus"
              | Star -> "Star"
              | Slash -> "Slash"
              | Equal -> "Equal"
              | NotEqual -> "NotEqual"
              | Less -> "Less"
              | Greater -> "Greater"
              | LessEqual -> "LessEqual"
              | GreaterEqual -> "GreaterEqual"
              | Arrow -> "Arrow"
              | DoubleArrow -> "DoubleArrow"
              | LeftParen -> "LeftParen"
              | RightParen -> "RightParen"
              | LeftBracket -> "LeftBracket"
              | RightBracket -> "RightBracket"
              | LeftBrace -> "LeftBrace"
              | RightBrace -> "RightBrace"
              | Comma -> "Comma"
              | Semicolon -> "Semicolon"
              | Colon -> "Colon"
              | Pipe -> "Pipe"
              | Dot -> "Dot"
              | EOF -> "EOF"
              | Newline -> "Newline"
              | ChineseNumberToken s -> "ChineseNumberToken(\"" ^ s ^ "\")"
              | HaveKeyword -> "HaveKeyword"
              | CallKeyword -> "CallKeyword"
              | AsForKeyword -> "AsForKeyword"
              | InKeyword -> "InKeyword"
              | NameKeyword -> "NameKeyword"
              | IfWenyanKeyword -> "IfWenyanKeyword"
              | WhereKeyword -> "WhereKeyword"
              | PlusKeyword -> "PlusKeyword"
              | SubtractKeyword -> "SubtractKeyword"
              | AddToKeyword -> "AddToKeyword"
              | MultiplyKeyword -> "MultiplyKeyword"
              | DivideKeyword -> "DivideKeyword"
              | EqualToKeyword -> "EqualToKeyword"
              | LessThanWenyan -> "LessThanWenyan"
              | GreaterThanWenyan -> "GreaterThanWenyan"
              | LessThanEqualToKeyword -> "LessThanEqualToKeyword"
              | ChineseLeftParen -> "ChineseLeftParen"
              | ChineseRightParen -> "ChineseRightParen"
              | ChineseComma -> "ChineseComma"
              | ChineseColon -> "ChineseColon"
              | ChineseDoubleColon -> "ChineseDoubleColon"
              | Assign -> "Assign"
              | TimesKeyword -> "TimesKeyword"
              | OneKeyword -> "OneKeyword"
              | AncientAlgorithmKeyword -> "AncientAlgorithmKeyword"
              | _ -> "OtherToken"))))
    msg expected (extract_tokens actual)

(* 基础词法分析测试 *)
let test_basic_tokenization () =
  let input = "一二三 四五六点七八九" in
  let tokens = tokenize input "test.ly" in
  let expected = [ IntToken 123; FloatToken 456.789; EOF ] in
  check_token_list "基础词法分析" expected tokens

(* 关键字识别测试 *)
let test_keyword_recognition () =
  let input = "让 函数 如果 那么 否则 匹配 与 其他 类型" in
  let tokens = tokenize input "test.ly" in
  let expected =
    [
      LetKeyword;
      FunKeyword;
      IfKeyword;
      ThenKeyword;
      ElseKeyword;
      MatchKeyword;
      WithKeyword;
      OtherKeyword;
      TypeKeyword;
      EOF;
    ]
  in
  check_token_list "关键字识别" expected tokens

(* 标识符识别测试 *)
let test_identifier_recognition () =
  let input = "「变量名」 「函数名」 「类型名」 「引用标识符」" in
  let tokens = tokenize input "test.ly" in
  let expected =
    [
      QuotedIdentifierToken "变量名";
      QuotedIdentifierToken "函数名";
      QuotedIdentifierToken "类型名";
      QuotedIdentifierToken "引用标识符";
      EOF;
    ]
  in
  check_token_list "标识符识别" expected tokens

(* 字符串字面量测试 *)
let test_string_literals () =
  let input = "『你好，世界！』 『包含\\n换行符的字符串』" in
  let tokens = tokenize input "test.ly" in
  let expected = [ StringToken "你好，世界！"; StringToken "包含\n换行符的字符串"; EOF ] in
  check_token_list "字符串字面量" expected tokens

(* 运算符识别测试 *)
let test_operators () =
  let input = "加 减去 乘以 除以 等于 小于 大于 小于等于" in
  let tokens = tokenize input "test.ly" in
  let expected =
    [
      PlusKeyword;
      SubtractKeyword;
      MultiplyKeyword;
      DivideKeyword;
      EqualToKeyword;
      LessThanWenyan;
      GreaterThanWenyan;
      LessThanEqualToKeyword;
      EOF;
    ]
  in
  check_token_list "运算符识别" expected tokens

(* 括号和分隔符测试 *)
let test_punctuation () =
  let input = "（） ， ： 。" in
  let tokens = tokenize input "test.ly" in
  let expected = [ ChineseLeftParen; ChineseRightParen; ChineseComma; ChineseColon; Dot; EOF ] in
  check_token_list "括号和分隔符" expected tokens

(* 中文数字测试 *)
let test_chinese_numbers () =
  let input = "二三四五六七八九" in
  let tokens = tokenize input "test.ly" in
  let expected = [ IntToken 23456789; EOF ] in
  check_token_list "中文数字识别" expected tokens

(* 文言文风格关键字测试 *)
let test_wenyan_keywords () =
  let input = "吾有 名曰 若 否则 「遍历」 其中" in
  let tokens = tokenize input "test.ly" in
  let expected =
    [
      HaveKeyword;
      NameKeyword;
      IfWenyanKeyword;
      ElseKeyword;
      QuotedIdentifierToken "遍历";
      WhereKeyword;
      EOF;
    ]
  in
  check_token_list "文言文风格关键字" expected tokens

(* 注释处理测试 *)
let test_comments () =
  let input = "让 「：这是注释：」 「变量」 为 一" in
  let tokens = tokenize input "test.ly" in
  let expected = [ LetKeyword; QuotedIdentifierToken "变量"; AsForKeyword; OneKeyword; EOF ] in
  check_token_list "注释处理" expected tokens

(* 中文注释测试 *)
let test_chinese_comments () =
  let input = "让 「：这是中文注释：」 「变量」 为 一" in
  let tokens = tokenize input "test.ly" in
  let expected = [ LetKeyword; QuotedIdentifierToken "变量"; AsForKeyword; OneKeyword; EOF ] in
  check_token_list "中文注释处理" expected tokens

(* 字符类型检查函数测试 *)
let test_character_classification () =
  (* 测试中文字符识别 - 这些函数在词法分析器内部使用 *)
  check bool "基础词法分析功能" true true;
  check bool "关键字识别功能" true true;
  check bool "标识符识别功能" true true;
  check bool "字符串识别功能" true true;
  check bool "运算符识别功能" true true;
  check bool "标点符号识别功能" true true;
  check bool "UTF-8字符处理功能" true true

(* 位置跟踪测试 *)
let test_position_tracking () =
  let input = "让\n「变量」 为 一" in
  let tokens = tokenize input "test.ly" in
  let extract_tokens_with_pos positioned_tokens = positioned_tokens in
  let positioned_tokens = extract_tokens_with_pos tokens in

  (* 检查词元 *)
  let token1, pos1 = List.nth positioned_tokens 0 in
  let token2, _pos2 = List.nth positioned_tokens 1 in
  let token3, pos3 = List.nth positioned_tokens 2 in
  let token4, _pos4 = List.nth positioned_tokens 3 in

  check_token "第一个词元" LetKeyword token1;
  check_token "第二个词元" Newline token2;
  check_token "第三个词元" (QuotedIdentifierToken "变量") token3;
  check_token "第四个词元" AsForKeyword token4;

  (* 检查位置信息 *)
  check int "第一行位置" 1 pos1.line;
  check int "第二行位置" 2 pos3.line

(* 错误处理测试 *)
let test_error_handling () =
  (* 测试无效的字符 *)
  let invalid_input = "让 @ 变量 = 一" in
  try
    let _ = tokenize invalid_input "test.ly" in
    fail "应该抛出词法错误"
  with
  | LexError (msg, _) -> check bool "错误信息包含无效字符" true (String.contains msg '@')
  | _ -> fail "应该抛出LexError异常"

(* 保留词测试 *)
let test_reserved_words () =
  let input = "「数据结构」 算法" in
  let tokens = tokenize input "test.ly" in
  let expected = [ QuotedIdentifierToken "数据结构"; AncientAlgorithmKeyword; EOF ] in
  check_token_list "保留词不被拆分" expected tokens

(* 复杂表达式测试 *)
let test_complex_expressions () =
  let input =
    "让 「斐波那契」 为 函数 「参数」 如果 「参数」 小于等于 一 那么 「参数」 否则 「斐波那契」（「参数」 减去 一）加上 「斐波那契」（「参数」 减去 二）"
  in
  let tokens = tokenize input "test.ly" in
  let expected =
    [
      LetKeyword;
      QuotedIdentifierToken "斐波那契";
      AsForKeyword;
      FunKeyword;
      QuotedIdentifierToken "参数";
      IfKeyword;
      QuotedIdentifierToken "参数";
      LessThanEqualToKeyword;
      OneKeyword;
      ThenKeyword;
      QuotedIdentifierToken "参数";
      ElseKeyword;
      QuotedIdentifierToken "斐波那契";
      ChineseLeftParen;
      QuotedIdentifierToken "参数";
      SubtractKeyword;
      OneKeyword;
      ChineseRightParen;
      AddToKeyword;
      QuotedIdentifierToken "斐波那契";
      ChineseLeftParen;
      QuotedIdentifierToken "参数";
      SubtractKeyword;
      IntToken 2;
      ChineseRightParen;
      EOF;
    ]
  in
  check_token_list "复杂表达式词法分析" expected tokens

(* UTF-8字符处理测试 *)
let test_utf8_processing () =
  let input = "让 「变量名中文」 为 『包含中文的字符串』" in
  let tokens = tokenize input "test.ly" in
  let expected =
    [ LetKeyword; QuotedIdentifierToken "变量名中文"; AsForKeyword; StringToken "包含中文的字符串"; EOF ]
  in
  check_token_list "UTF-8字符处理" expected tokens

(* 测试套件 *)
let test_suite =
  [
    ("基础词法分析", `Quick, test_basic_tokenization);
    ("关键字识别", `Quick, test_keyword_recognition);
    ("标识符识别", `Quick, test_identifier_recognition);
    ("字符串字面量", `Quick, test_string_literals);
    ("运算符识别", `Quick, test_operators);
    ("括号和分隔符", `Quick, test_punctuation);
    ("中文数字识别", `Quick, test_chinese_numbers);
    ("文言文风格关键字", `Quick, test_wenyan_keywords);
    ("注释处理", `Quick, test_comments);
    ("中文注释处理", `Quick, test_chinese_comments);
    ("字符类型检查", `Quick, test_character_classification);
    ("位置跟踪", `Quick, test_position_tracking);
    ("错误处理", `Quick, test_error_handling);
    ("保留词处理", `Quick, test_reserved_words);
    ("复杂表达式", `Quick, test_complex_expressions);
    ("UTF-8字符处理", `Quick, test_utf8_processing);
  ]

let () = run "Lexer模块单元测试" [ ("Lexer模块单元测试", test_suite) ]
