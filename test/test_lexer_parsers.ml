(** 骆言词法分析解析器模块完整测试覆盖 *)

open Alcotest
open Yyocamlc_lib.Lexer_state
open Yyocamlc_lib.Lexer_tokens
open Yyocamlc_lib.Lexer_parsers

(** 辅助函数：创建测试用的词法状态 *)
let create_test_state input filename =
  {
    input = input;
    position = 0;
    length = String.length input;
    current_line = 1;
    current_column = 1;
    filename = filename;
  }

(** 测试 check_utf8_char 函数 *)
let test_check_utf8_char () =
  (* 测试UTF-8字符匹配 - 』 (U+300F) *)
  let input = "\xE3\x80\x8F" in
  let state = create_test_state input "test.ly" in
  let result = check_utf8_char state 0xE3 0x80 0x8F in
  check bool "UTF-8字符『』正确匹配" true result;

  (* 测试不匹配的字符 *)
  let input2 = "\xE3\x80\x8E" in
  let state2 = create_test_state input2 "test.ly" in
  let result2 = check_utf8_char state2 0xE3 0x80 0x8F in
  check bool "UTF-8字符不匹配" false result2;

  (* 测试边界条件：字符串太短 *)
  let input3 = "\xE3\x80" in
  let state3 = create_test_state input3 "test.ly" in
  let result3 = check_utf8_char state3 0xE3 0x80 0x8F in
  check bool "字符串太短时不匹配" false result3

(** 测试 read_string_literal 基础功能 *)
let test_read_string_literal_basic () =
  (* 简单字符串字面量 *)
  let input = "你好世界\xE3\x80\x8F" in
  let state = create_test_state input "test.ly" in
  let token, new_state = read_string_literal state in
  check (of_pp (fun fmt tok ->
      match tok with
      | StringToken s -> Format.pp_print_string fmt ("StringToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "简单字符串解析" (StringToken "你好世界") token;
  check int "解析后位置正确" 15 new_state.position

(** 测试 read_string_literal 转义序列 *)
let test_read_string_literal_escapes () =
  (* 测试换行转义 *)
  let input = "行一\\n行二\xE3\x80\x8F" in
  let state = create_test_state input "test.ly" in
  let token, _ = read_string_literal state in
  check (of_pp (fun fmt tok ->
      match tok with
      | StringToken s -> Format.pp_print_string fmt ("StringToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "换行转义序列" (StringToken "行一\n行二") token;

  (* 测试制表符转义 *)
  let input2 = "前\\t后\xE3\x80\x8F" in
  let state2 = create_test_state input2 "test.ly" in
  let token2, _ = read_string_literal state2 in
  check (of_pp (fun fmt tok ->
      match tok with
      | StringToken s -> Format.pp_print_string fmt ("StringToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "制表符转义序列" (StringToken "前\t后") token2;

  (* 测试回车转义 *)
  let input3 = "前\\r后\xE3\x80\x8F" in
  let state3 = create_test_state input3 "test.ly" in
  let token3, _ = read_string_literal state3 in
  check (of_pp (fun fmt tok ->
      match tok with
      | StringToken s -> Format.pp_print_string fmt ("StringToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "回车转义序列" (StringToken "前\r后") token3;

  (* 测试双引号转义 *)
  let input4 = "包含\\\"引号\xE3\x80\x8F" in
  let state4 = create_test_state input4 "test.ly" in
  let token4, _ = read_string_literal state4 in
  check (of_pp (fun fmt tok ->
      match tok with
      | StringToken s -> Format.pp_print_string fmt ("StringToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "双引号转义序列" (StringToken "包含\"引号") token4;

  (* 测试反斜杠转义 *)
  let input5 = "反斜杠\\\\测试\xE3\x80\x8F" in
  let state5 = create_test_state input5 "test.ly" in
  let token5, _ = read_string_literal state5 in
  check (of_pp (fun fmt tok ->
      match tok with
      | StringToken s -> Format.pp_print_string fmt ("StringToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "反斜杠转义序列" (StringToken "反斜杠\\测试") token5

(** 测试 read_string_literal 错误处理 *)
let test_read_string_literal_errors () =
  (* 测试未闭合字符串 *)
  let input = "未闭合的字符串" in
  let state = create_test_state input "test.ly" in
  (try
     let _ = read_string_literal state in
     fail "应该抛出词法错误"
   with
   | Yyocamlc_lib.Lexer_tokens.LexError (msg, _) -> 
     check bool "错误信息非空" true (String.length msg > 0)
   | _ -> fail "应该抛出LexError异常");

  (* 测试未闭合的转义序列 *)
  let input2 = "字符串\\" in
  let state2 = create_test_state input2 "test.ly" in
  (try
     let _ = read_string_literal state2 in
     fail "应该抛出词法错误"
   with
   | Yyocamlc_lib.Lexer_tokens.LexError (msg, _) -> 
     check bool "错误信息非空" true (String.length msg > 0)
   | _ -> fail "应该抛出LexError异常")

(** 测试 read_quoted_identifier 基础功能 *)
let test_read_quoted_identifier_basic () =
  (* 简单引用标识符 *)
  let input = "变量名」" in
  let state = create_test_state input "test.ly" in
  let token, new_state = read_quoted_identifier state in
  check (of_pp (fun fmt tok ->
      match tok with
      | QuotedIdentifierToken s -> Format.pp_print_string fmt ("QuotedIdentifierToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "简单引用标识符" (QuotedIdentifierToken "变量名") token;
  check int "解析后位置正确" 12 new_state.position

(** 测试 read_quoted_identifier 中文字符 *)
let test_read_quoted_identifier_chinese () =
  (* 复杂中文标识符 *)
  let input = "复杂的中文变量名称」" in
  let state = create_test_state input "test.ly" in
  let token, _ = read_quoted_identifier state in
  check (of_pp (fun fmt tok ->
      match tok with
      | QuotedIdentifierToken s -> Format.pp_print_string fmt ("QuotedIdentifierToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "中文引用标识符" (QuotedIdentifierToken "复杂的中文变量名称") token;

  (* 包含数字和符号的标识符 *)
  let input2 = "变量123_test」" in
  let state2 = create_test_state input2 "test.ly" in
  let token2, _ = read_quoted_identifier state2 in
  check (of_pp (fun fmt tok ->
      match tok with
      | QuotedIdentifierToken s -> Format.pp_print_string fmt ("QuotedIdentifierToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "混合字符引用标识符" (QuotedIdentifierToken "变量123_test") token2

(** 测试 read_quoted_identifier 错误处理 *)
let test_read_quoted_identifier_errors () =
  (* 测试未闭合的引用标识符 *)
  let input = "未闭合标识符" in
  let state = create_test_state input "test.ly" in
  (try
     let _ = read_quoted_identifier state in
     fail "应该抛出词法错误"
   with
   | Yyocamlc_lib.Lexer_tokens.LexError (msg, _) -> 
     check bool "错误信息非空" true (String.length msg > 0)
   | _ -> fail "应该抛出LexError异常");

  (* 测试空字符串输入 *)
  let input2 = "" in
  let state2 = create_test_state input2 "test.ly" in
  (try
     let _ = read_quoted_identifier state2 in
     fail "应该抛出词法错误"
   with
   | Yyocamlc_lib.Lexer_tokens.LexError (msg, _) -> 
     check bool "错误信息非空" true (String.length msg > 0)
   | _ -> fail "应该抛出LexError异常")

(** 测试边界条件 *)
let test_boundary_conditions () =
  (* 测试单字符字符串 *)
  let input = "单\xE3\x80\x8F" in
  let state = create_test_state input "test.ly" in
  let token, _ = read_string_literal state in
  check (of_pp (fun fmt tok ->
      match tok with
      | StringToken s -> Format.pp_print_string fmt ("StringToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "单字符字符串" (StringToken "单") token;

  (* 测试空字符串 *)
  let input2 = "\xE3\x80\x8F" in
  let state2 = create_test_state input2 "test.ly" in
  let token2, _ = read_string_literal state2 in
  check (of_pp (fun fmt tok ->
      match tok with
      | StringToken s -> Format.pp_print_string fmt ("StringToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "空字符串" (StringToken "") token2;

  (* 测试单字符引用标识符 *)
  let input3 = "单」" in
  let state3 = create_test_state input3 "test.ly" in
  let token3, _ = read_quoted_identifier state3 in
  check (of_pp (fun fmt tok ->
      match tok with
      | QuotedIdentifierToken s -> Format.pp_print_string fmt ("QuotedIdentifierToken(\"" ^ s ^ "\")")
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "单字符引用标识符" (QuotedIdentifierToken "单") token3

(** 性能和复杂度测试 *)
let test_performance_edge_cases () =
  (* 测试长字符串处理 *)
  let long_content = String.make 1000 'a' in
  let input = long_content ^ "\xE3\x80\x8F" in
  let state = create_test_state input "test.ly" in
  let token, _ = read_string_literal state in
  check (of_pp (fun fmt tok ->
      match tok with
      | StringToken s -> Format.pp_print_string fmt ("StringToken length: " ^ string_of_int (String.length s))
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "长字符串处理" (StringToken long_content) token;

  (* 测试长引用标识符 *)
  let long_identifier = String.make 500 'x' in
  let input2 = long_identifier ^ "」" in
  let state2 = create_test_state input2 "test.ly" in
  let token2, _ = read_quoted_identifier state2 in
  check (of_pp (fun fmt tok ->
      match tok with
      | QuotedIdentifierToken s -> Format.pp_print_string fmt ("QuotedIdentifierToken length: " ^ string_of_int (String.length s))
      | _ -> Format.pp_print_string fmt "OtherToken")) 
    "长引用标识符处理" (QuotedIdentifierToken long_identifier) token2

(** 测试套件 *)
let test_suite =
  [
    ("UTF-8字符匹配检查", `Quick, test_check_utf8_char);
    ("字符串字面量基础解析", `Quick, test_read_string_literal_basic);
    ("字符串转义序列处理", `Quick, test_read_string_literal_escapes);
    ("字符串字面量错误处理", `Quick, test_read_string_literal_errors);
    ("引用标识符基础解析", `Quick, test_read_quoted_identifier_basic);
    ("引用标识符中文字符", `Quick, test_read_quoted_identifier_chinese);
    ("引用标识符错误处理", `Quick, test_read_quoted_identifier_errors);
    ("边界条件测试", `Quick, test_boundary_conditions);
    ("性能边缘情况", `Quick, test_performance_edge_cases);
  ]

let () = run "Lexer_parsers模块完整测试" [ ("Lexer_parsers模块完整测试", test_suite) ]