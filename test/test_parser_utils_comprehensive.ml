(** 骆言语法分析器工具模块全面测试 - Comprehensive Test for Parser Utils Module *)

open Alcotest
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_utils

(** 定义 token testable *)
let token_testable = testable pp_token equal_token

(** 辅助函数：创建位置信息 *)
let make_pos line column = { line; column; filename = "test" }

(** 辅助函数：创建定位token *)
let make_token token line column = (token, make_pos line column)

(** 测试1: 错误消息生成函数 *)
let test_error_message_generation () =
  let token = "意外词元" in
  let pos = make_pos 1 5 in
  let error = make_unexpected_token_error token pos in
  match error with
  | SyntaxError (msg, error_pos) ->
      check string "错误消息内容" "意外的词元: 意外词元" msg;
      check int "错误位置行号" 1 error_pos.line;
      check int "错误位置列号" 5 error_pos.column
  | _ -> fail "意外的异常类型"

let test_expected_but_found_error () =
  let expected = "左括号" in
  let found = "右括号" in
  let pos = make_pos 2 10 in
  let error = make_expected_but_found_error expected found pos in
  match error with
  | SyntaxError (msg, error_pos) ->
      check string "期望错误消息" "期望左括号，但遇到 右括号" msg;
      check int "错误位置行号" 2 error_pos.line
  | _ -> fail "意外的异常类型"

(** 测试2: 解析器状态操作 *)
let test_create_parser_state () =
  let tokens = [
    make_token (IntToken 42) 1 1;
    make_token Plus 1 4;
    make_token (IntToken 24) 1 6;
    make_token EOF 1 8;
  ] in
  let state = create_parser_state tokens in
  check int "token数组长度" 4 state.array_length;
  check int "初始位置" 0 state.current_pos

let test_current_token () =
  let tokens = [
    make_token (IntToken 42) 1 1;
    make_token Plus 1 4;
    make_token EOF 1 6;
  ] in
  let state = create_parser_state tokens in
  let token, pos = current_token state in
  check token_testable "当前token" (IntToken 42) token;
  check int "当前位置行号" 1 pos.line;
  check int "当前位置列号" 1 pos.column

let test_current_token_at_end () =
  let tokens = [] in
  let state = create_parser_state tokens in
  let token, pos = current_token state in
  check token_testable "空数组末尾token" EOF token;
  check int "空数组末尾位置行号" 0 pos.line

let test_peek_token () =
  let tokens = [
    make_token (IntToken 42) 1 1;
    make_token Plus 1 4;
    make_token (IntToken 24) 1 6;
  ] in
  let state = create_parser_state tokens in
  let token, pos = peek_token state in
  check token_testable "peek token" Plus token;
  check int "peek位置行号" 1 pos.line;
  check int "peek位置列号" 4 pos.column;
  (* 验证state没有改变 *)
  check int "state位置未变" 0 state.current_pos

let test_peek_token_at_end () =
  let tokens = [make_token (IntToken 42) 1 1] in
  let state = create_parser_state tokens in
  let token, _ = peek_token state in
  check token_testable "末尾peek token" EOF token

let test_advance_parser () =
  let tokens = [
    make_token (IntToken 42) 1 1;
    make_token Plus 1 4;
  ] in
  let state = create_parser_state tokens in
  let new_state = advance_parser state in
  check int "前进后位置" 1 new_state.current_pos;
  (* 验证原state未改变 *)
  check int "原state位置不变" 0 state.current_pos

let test_advance_parser_at_end () =
  let tokens = [make_token (IntToken 42) 1 1] in
  let state = create_parser_state tokens in
  let state_at_end = { state with current_pos = 1 } in
  let new_state = advance_parser state_at_end in
  check int "末尾前进位置不变" 1 new_state.current_pos

(** 测试3: skip_newlines函数 *)
let test_skip_newlines_empty () =
  let tokens = [] in
  let state = create_parser_state tokens in
  let new_state = skip_newlines state in
  check int "空数组跳过换行后位置" 0 new_state.current_pos

let test_skip_newlines_semicolons () =
  let tokens = [
    make_token Semicolon 1 1;
    make_token ChineseSemicolon 1 2;
    make_token Semicolon 1 3;
    make_token (IntToken 42) 1 4;
  ] in
  let state = create_parser_state tokens in
  let new_state = skip_newlines state in
  check int "跳过分号后位置" 3 new_state.current_pos;
  let token, _ = current_token new_state in
  check token_testable "跳过后当前token" (IntToken 42) token

let test_skip_newlines_no_semicolons () =
  let tokens = [
    make_token (IntToken 42) 1 1;
    make_token Plus 1 4;
  ] in
  let state = create_parser_state tokens in
  let new_state = skip_newlines state in
  check int "无分号跳过后位置不变" 0 new_state.current_pos

(** 测试4: expect_token函数 *)
let test_expect_token_success () =
  let tokens = [
    make_token LeftParen 1 1;
    make_token (IntToken 42) 1 2;
  ] in
  let state = create_parser_state tokens in
  let new_state = expect_token state LeftParen in
  check int "期望token成功后位置" 1 new_state.current_pos

let test_expect_token_failure () =
  let tokens = [
    make_token RightParen 1 1;
    make_token (IntToken 42) 1 2;
  ] in
  let state = create_parser_state tokens in
  check_raises "期望token失败抛出异常"
    (SyntaxError ("期望Lexer.LeftParen，但遇到 Lexer.RightParen", make_pos 1 1))
    (fun () -> ignore (expect_token state LeftParen))

(** 测试5: is_token函数 *)
let test_is_token_true () =
  let tokens = [make_token LeftParen 1 1] in
  let state = create_parser_state tokens in
  let result = is_token state LeftParen in
  check bool "is_token返回true" true result

let test_is_token_false () =
  let tokens = [make_token RightParen 1 1] in
  let state = create_parser_state tokens in
  let result = is_token state LeftParen in
  check bool "is_token返回false" false result

(** 测试6: 标识符解析函数 *)
let test_parse_identifier_success () =
  let tokens = [make_token (QuotedIdentifierToken "测试名称") 1 1] in
  let state = create_parser_state tokens in
  let name, new_state = parse_identifier state in
  check string "解析标识符名称" "测试名称" name;
  check int "解析标识符后位置" 1 new_state.current_pos

let test_parse_identifier_failure () =
  let tokens = [make_token (IntToken 42) 1 1] in
  let state = create_parser_state tokens in
  check_raises "解析标识符失败抛出异常"
    (SyntaxError ("期望引用标识符「名称」，但遇到 (Lexer.IntToken 42)", make_pos 1 1))
    (fun () -> ignore (parse_identifier state))

let test_parse_identifier_allow_keywords_quoted () =
  let tokens = [make_token (QuotedIdentifierToken "关键字名") 1 1] in
  let state = create_parser_state tokens in
  let name, new_state = parse_identifier_allow_keywords state in
  check string "解析允许关键字的标识符" "关键字名" name;
  check int "解析后位置" 1 new_state.current_pos

let test_parse_identifier_allow_keywords_empty () =
  let tokens = [make_token EmptyKeyword 1 1] in
  let state = create_parser_state tokens in
  let name, new_state = parse_identifier_allow_keywords state in
  check string "解析空关键字为标识符" "空" name;
  check int "解析后位置" 1 new_state.current_pos

let test_parse_identifier_allow_keywords_failure () =
  let tokens = [make_token (IntToken 42) 1 1] in
  let state = create_parser_state tokens in
  check_raises "解析允许关键字标识符失败"
    (SyntaxError ("期望引用标识符「名称」，但遇到 (Lexer.IntToken 42)", make_pos 1 1))
    (fun () -> ignore (parse_identifier_allow_keywords state))

(** 测试7: 文言复合标识符解析 *)
let test_parse_wenyan_compound_single () =
  let tokens = [make_token (QuotedIdentifierToken "单一") 1 1] in
  let state = create_parser_state tokens in
  let name, new_state = parse_wenyan_compound_identifier state in
  check string "单一复合标识符" "单一" name;
  check int "解析后位置" 1 new_state.current_pos

let test_parse_wenyan_compound_multiple () =
  let tokens = [
    make_token (QuotedIdentifierToken "第一") 1 1;
    make_token (QuotedIdentifierToken "第二") 1 3;
    make_token (QuotedIdentifierToken "第三") 1 5;
    make_token ValueKeyword 1 7;
  ] in
  let state = create_parser_state tokens in
  let name, new_state = parse_wenyan_compound_identifier state in
  check string "多部分复合标识符" "第一第二第三" name;
  check int "解析后位置" 3 new_state.current_pos

let test_parse_wenyan_compound_with_special () =
  let tokens = [
    make_token (IdentifierTokenSpecial "数值") 1 1;
    make_token NumberKeyword 1 3;
    make_token EmptyKeyword 1 5;
    make_token Plus 1 7;
  ] in
  let state = create_parser_state tokens in
  let name, new_state = parse_wenyan_compound_identifier state in
  check string "包含特殊token的复合标识符" "数值数空" name;
  check int "解析后位置" 3 new_state.current_pos

let test_parse_wenyan_compound_empty_failure () =
  let tokens = [make_token (IntToken 42) 1 1] in
  let state = create_parser_state tokens in
  check_raises "空复合标识符解析失败"
    (SyntaxError ("期望标识符，但遇到 (Lexer.IntToken 42)", make_pos 1 1))
    (fun () -> ignore (parse_wenyan_compound_identifier state))

let test_parse_wenyan_compound_value_keyword_stop () =
  let tokens = [make_token ValueKeyword 1 1] in
  let state = create_parser_state tokens in
  check_raises "ValueKeyword开头的复合标识符解析失败"
    (SyntaxError ("期望标识符，但遇到 Lexer.ValueKeyword", make_pos 1 1))
    (fun () -> ignore (parse_wenyan_compound_identifier state))

(** 测试8: 边界和异常情况 *)
let test_state_operations_consistency () =
  let tokens = [
    make_token (IntToken 1) 1 1;
    make_token (IntToken 2) 1 2;
    make_token (IntToken 3) 1 3;
  ] in
  let state = create_parser_state tokens in
  
  (* 测试连续操作的一致性 *)
  let state1 = advance_parser state in
  let state2 = advance_parser state1 in
  let state3 = advance_parser state2 in
  
  check int "连续前进位置1" 1 state1.current_pos;
  check int "连续前进位置2" 2 state2.current_pos;
  check int "连续前进位置3" 3 state3.current_pos;
  
  let token3, _ = current_token state3 in
  check token_testable "末尾超出后EOF" EOF token3

let test_empty_token_list_operations () =
  let state = create_parser_state [] in
  
  (* 空列表所有操作都应该返回EOF *)
  let token, _ = current_token state in
  check token_testable "空列表当前token" EOF token;
  
  let peek_token_result, _ = peek_token state in
  check token_testable "空列表peek token" EOF peek_token_result;
  
  let new_state = advance_parser state in
  check int "空列表前进后位置" 0 new_state.current_pos;
  
  let skip_state = skip_newlines state in
  check int "空列表跳过换行后位置" 0 skip_state.current_pos

(** 测试套件定义和运行 *)
let parser_utils_tests = [
  ("错误消息生成", `Quick, test_error_message_generation);
  ("期望但发现错误", `Quick, test_expected_but_found_error);
  ("创建解析器状态", `Quick, test_create_parser_state);
  ("获取当前token", `Quick, test_current_token);
  ("末尾获取当前token", `Quick, test_current_token_at_end);
  ("peek token", `Quick, test_peek_token);
  ("末尾peek token", `Quick, test_peek_token_at_end);
  ("前进解析器", `Quick, test_advance_parser);
  ("末尾前进解析器", `Quick, test_advance_parser_at_end);
  ("跳过换行-空数组", `Quick, test_skip_newlines_empty);
  ("跳过换行-分号", `Quick, test_skip_newlines_semicolons);
  ("跳过换行-无分号", `Quick, test_skip_newlines_no_semicolons);
  ("期望token成功", `Quick, test_expect_token_success);
  ("期望token失败", `Quick, test_expect_token_failure);
  ("is_token返回true", `Quick, test_is_token_true);
  ("is_token返回false", `Quick, test_is_token_false);
  ("解析标识符成功", `Quick, test_parse_identifier_success);
  ("解析标识符失败", `Quick, test_parse_identifier_failure);
  ("解析允许关键字标识符-引用", `Quick, test_parse_identifier_allow_keywords_quoted);
  ("解析允许关键字标识符-空", `Quick, test_parse_identifier_allow_keywords_empty);
  ("解析允许关键字标识符失败", `Quick, test_parse_identifier_allow_keywords_failure);
  ("文言复合标识符-单一", `Quick, test_parse_wenyan_compound_single);
  ("文言复合标识符-多部分", `Quick, test_parse_wenyan_compound_multiple);
  ("文言复合标识符-特殊token", `Quick, test_parse_wenyan_compound_with_special);
  ("文言复合标识符-空失败", `Quick, test_parse_wenyan_compound_empty_failure);
  ("文言复合标识符-ValueKeyword停止", `Quick, test_parse_wenyan_compound_value_keyword_stop);
  ("状态操作一致性", `Quick, test_state_operations_consistency);
  ("空token列表操作", `Quick, test_empty_token_list_operations);
]

let () =
  run "Parser_utils模块全面测试" [
    ("Parser Utils", parser_utils_tests);
  ]