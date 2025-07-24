(** 骆言解析器工具模块综合测试套件 - Fix #1009 Phase 2 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Types

(** 测试辅助工具模块 *)
module TestHelpers = struct
  (** 创建位置信息 *)
  let make_pos line column filename = { line; column; filename }

  (** 创建位置标记token *)
  let make_positioned_token token line column filename =
    (token, make_pos line column filename)

  (** 创建测试用的parser状态 *)
  let create_test_state tokens =
    let positioned_tokens = List.mapi (fun i token -> 
      make_positioned_token token (i + 1) 1 "test.ly") tokens in
    create_parser_state positioned_tokens

end

(** 1. 解析器状态管理测试 *)

let test_create_parser_state () =
  let tokens = [IntToken 42; StringToken "hello"; EOF] in
  let state = TestHelpers.create_test_state tokens in
  check int "数组长度" 3 state.array_length;
  check int "初始位置" 0 state.current_pos

let test_current_token () =
  let tokens = [IntToken 42; StringToken "hello"; EOF] in
  let state = TestHelpers.create_test_state tokens in
  let token, pos = current_token state in
  check bool "当前token正确" true (token = IntToken 42);
  check int "位置行号" 1 pos.line;
  
  (* 测试空状态 *)
  let empty_state = TestHelpers.create_test_state [] in
  let empty_token, _empty_pos = current_token empty_state in
  check bool "空状态返回EOF" true (empty_token = EOF)

let test_peek_token () =
  let tokens = [IntToken 42; StringToken "hello"; EOF] in
  let state = TestHelpers.create_test_state tokens in
  let next_token, _ = peek_token state in
  check bool "peek下一个token" true (next_token = StringToken "hello");
  
  (* 确认当前状态未改变 *)
  let current_token_after, _ = current_token state in
  check bool "peek不改变当前状态" true (current_token_after = IntToken 42)

let test_advance_parser () =
  let tokens = [IntToken 42; StringToken "hello"; EOF] in
  let state = TestHelpers.create_test_state tokens in
  let new_state = advance_parser state in
  check int "位置前进" 1 new_state.current_pos;
  
  let token, _ = current_token new_state in
  check bool "前进后的token" true (token = StringToken "hello");
  
  (* 测试边界条件 *)
  let end_state = { state with current_pos = 3 } in
  let unchanged_state = advance_parser end_state in
  check int "超出边界时不变" 3 unchanged_state.current_pos

let test_skip_newlines () =
  let tokens = [Semicolon; ChineseSemicolon; IntToken 42; EOF] in
  let state = TestHelpers.create_test_state tokens in
  let new_state = skip_newlines state in
  let token, _ = current_token new_state in
  check bool "跳过分号后的token" true (token = IntToken 42);
  
  (* 测试EOF情况 *)
  let eof_state = TestHelpers.create_test_state [EOF] in
  let eof_result = skip_newlines eof_state in
  let eof_token, _ = current_token eof_result in
  check bool "EOF时停止" true (eof_token = EOF)

(** 2. Token期望和检查测试 *)

let test_expect_token () =
  let tokens = [LeftParen; IntToken 42; RightParen] in
  let state = TestHelpers.create_test_state tokens in
  
  (* 正确期望 *)
  let new_state = expect_token state LeftParen in
  let token, _ = current_token new_state in
  check bool "期望正确token后前进" true (token = IntToken 42);
  
  (* 错误期望应该抛出异常 *)
  try
    let _ = expect_token state RightParen in
    fail "应该抛出异常"
  with SyntaxError (msg, _) ->
    check bool "错误消息包含期望字符" true (String.contains msg (String.get "期" 0))

let test_is_token () =
  let tokens = [LeftParen; IntToken 42] in
  let state = TestHelpers.create_test_state tokens in
  
  check bool "匹配当前token" true (is_token state LeftParen);
  check bool "不匹配其他token" false (is_token state RightParen)

(** 3. 标识符解析测试 *)

let test_parse_identifier () =
  let tokens = [QuotedIdentifierToken "变量名"; IntToken 42] in
  let state = TestHelpers.create_test_state tokens in
  
  let name, new_state = parse_identifier state in
  check string "解析标识符名称" "变量名" name;
  let token, _ = current_token new_state in
  check bool "解析后前进" true (token = IntToken 42);
  
  (* 测试错误情况 *)
  let wrong_tokens = [IntToken 42] in
  let wrong_state = TestHelpers.create_test_state wrong_tokens in
  try
    let _ = parse_identifier wrong_state in
    fail "应该抛出异常"
  with SyntaxError (msg, _) ->
    check bool "错误消息包含引用" true (String.contains msg (String.get "引" 0))

let test_parse_identifier_allow_keywords () =
  let tokens = [QuotedIdentifierToken "标识符"; EmptyKeyword; IntToken 42] in
  let state = TestHelpers.create_test_state tokens in
  
  (* 测试引用标识符 *)
  let name1, state1 = parse_identifier_allow_keywords state in
  check string "引用标识符" "标识符" name1;
  
  (* 测试关键字 *)
  let name2, _state2 = parse_identifier_allow_keywords state1 in
  check string "空关键字" "空" name2

let test_parse_wenyan_compound_identifier () =
  let tokens = [QuotedIdentifierToken "变量"; QuotedIdentifierToken "名称"; ValueKeyword] in
  let state = TestHelpers.create_test_state tokens in
  
  let compound_name, new_state = parse_wenyan_compound_identifier state in
  check string "复合标识符" "变量名称" compound_name;
  let token, _ = current_token new_state in
  check bool "在ValueKeyword处停止" true (token = ValueKeyword);
  
  (* 测试单个标识符 *)
  let single_tokens = [QuotedIdentifierToken "单一"; EOF] in
  let single_state = TestHelpers.create_test_state single_tokens in
  let single_name, _ = parse_wenyan_compound_identifier single_state in
  check string "单个标识符" "单一" single_name

(** 4. 中文标点符号测试 *)

let test_punctuation_checkers () =
  (* 测试括号 *)
  check bool "ASCII左括号" true (is_left_paren LeftParen);
  check bool "中文左括号" true (is_left_paren ChineseLeftParen);
  check bool "ASCII右括号" true (is_right_paren RightParen);
  check bool "中文右括号" true (is_right_paren ChineseRightParen);
  
  (* 测试方括号 *)
  check bool "ASCII左方括号" true (is_left_bracket LeftBracket);
  check bool "中文左方括号" true (is_left_bracket ChineseLeftBracket);
  check bool "ASCII右方括号" true (is_right_bracket RightBracket);
  check bool "中文右方括号" true (is_right_bracket ChineseRightBracket);
  
  (* 测试其他标点 *)
  check bool "ASCII分号" true (is_semicolon Semicolon);
  check bool "中文分号" true (is_semicolon ChineseSemicolon);
  check bool "ASCII冒号" true (is_colon Colon);
  check bool "中文冒号" true (is_colon ChineseColon);
  check bool "ASCII箭头" true (is_arrow Arrow);
  check bool "中文箭头" true (is_arrow ChineseArrow)

let test_expect_token_punctuation () =
  let tokens = [ChineseLeftParen; IntToken 42] in
  let state = TestHelpers.create_test_state tokens in
  
  (* 正确期望 *)
  let new_state = expect_token_punctuation state is_left_paren "左括号" in
  let token, _ = current_token new_state in
  check bool "期望标点后前进" true (token = IntToken 42);
  
  (* 错误期望应该抛出异常 *)
  try
    let _ = expect_token_punctuation state is_right_paren "右括号" in
    fail "应该抛出异常"
  with SyntaxError (msg, _) ->
    check bool "错误消息包含期望" true (String.contains msg (String.get "期" 0))

(** 5. Token分类测试 *)

let test_token_classification () =
  (* 测试标识符类型 *)
  check bool "引用标识符" true (is_identifier_like (QuotedIdentifierToken "test"));
  check bool "空关键字" true (is_identifier_like EmptyKeyword);
  check bool "函数关键字" true (is_identifier_like FunKeyword);
  check bool "数字不是标识符" false (is_identifier_like (IntToken 42));
  
  (* 测试字面量类型 *)
  check bool "整数字面量" true (is_literal_token (IntToken 42));
  check bool "字符串字面量" true (is_literal_token (StringToken "test"));
  check bool "布尔字面量" true (is_literal_token (BoolToken true));
  check bool "中文数字字面量" true (is_literal_token (ChineseNumberToken "五"));
  check bool "括号不是字面量" false (is_literal_token LeftParen);
  
  (* 测试类型注解 *)
  check bool "中文双冒号" true (is_type_colon ChineseDoubleColon);
  check bool "普通冒号不是类型注解" false (is_type_colon Colon)

(** 6. 字面量解析测试 *)

let test_chinese_number_conversion () =
  check int "零转换" 0 (chinese_digit_to_int "零");
  check int "一转换" 1 (chinese_digit_to_int "一");
  check int "五转换" 5 (chinese_digit_to_int "五");
  check int "十转换" 10 (chinese_digit_to_int "十");
  
  (* 测试错误情况 *)
  try
    let _ = chinese_digit_to_int "invalid" in
    fail "应该抛出异常"
  with SemanticError (msg, _) ->
    check bool "错误消息包含无效" true (String.contains msg (String.get "无" 0));
  
  check int "中文数字转换" 3 (chinese_number_to_int "三");
  
  (* 测试小数点错误 *)
  try
    let _ = chinese_number_to_int "点" in
    fail "应该抛出异常"
  with SemanticError (msg, _) ->
    check bool "小数点错误" true (String.contains msg (String.get "小" 0))

let test_parse_literal () =
  let tokens = [IntToken 42; ChineseNumberToken "七"; FloatToken 3.14; 
                StringToken "hello"; BoolToken true] in
  let state = TestHelpers.create_test_state tokens in
  
  (* 测试整数 *)
  let lit1, state1 = parse_literal state in
  check bool "整数字面量" true (lit1 = IntLit 42);
  
  (* 测试中文数字 *)
  let lit2, state2 = parse_literal state1 in
  check bool "中文数字字面量" true (lit2 = IntLit 7);
  
  (* 测试浮点数 *)
  let lit3, state3 = parse_literal state2 in
  check bool "浮点数字面量" true (lit3 = FloatLit 3.14);
  
  (* 测试字符串 *)
  let lit4, state4 = parse_literal state3 in
  check bool "字符串字面量" true (lit4 = StringLit "hello");
  
  (* 测试布尔值 *)
  let lit5, _state5 = parse_literal state4 in
  check bool "布尔字面量" true (lit5 = BoolLit true)

(** 7. 运算符解析测试 *)

let test_binary_operator_parsing () =
  (* 测试ASCII运算符 *)
  check bool "加号" true (token_to_binary_op Plus = Some Add);
  check bool "减号" true (token_to_binary_op Minus = Some Sub);
  check bool "乘号" true (token_to_binary_op Star = Some Mul);
  check bool "除号" true (token_to_binary_op Slash = Some Div);
  check bool "等号" true (token_to_binary_op Equal = Some Eq);
  
  (* 测试中文运算符 *)
  check bool "中文加" true (token_to_binary_op PlusKeyword = Some Add);
  check bool "中文减" true (token_to_binary_op SubtractKeyword = Some Sub);
  check bool "中文乘" true (token_to_binary_op MultiplyKeyword = Some Mul);
  check bool "中文等于" true (token_to_binary_op EqualToKeyword = Some Eq);
  
  (* 测试古雅风格 *)
  check bool "古雅加" true (token_to_binary_op AncientAddToKeyword = Some Add);
  
  (* 测试无效运算符 *)
  check bool "EOF不是运算符" true (token_to_binary_op EOF = None);
  check bool "括号不是运算符" true (token_to_binary_op LeftParen = None)

(** 8. 诗词解析工具测试 *)

let test_parse_identifier_content () =
  let tokens = [QuotedIdentifierToken "引用"; IdentifierTokenSpecial "特殊"; StringToken "字符串"] in
  let state = TestHelpers.create_test_state tokens in
  
  (* 测试引用标识符 *)
  let content1, state1 = parse_identifier_content state in
  check string "引用标识符内容" "引用" content1;
  
  (* 测试特殊标识符 *)
  let content2, state2 = parse_identifier_content state1 in
  check string "特殊标识符内容" "特殊" content2;
  
  (* 测试字符串内容 *)
  let content3, _state3 = parse_identifier_content state2 in
  check string "字符串内容" "字符串" content3

let test_parse_specific_keyword () =
  let tokens = [QuotedIdentifierToken "如果"; IdentifierTokenSpecial "那么"] in
  let state = TestHelpers.create_test_state tokens in
  
  (* 正确解析关键字 *)
  let new_state1 = parse_specific_keyword state "如果" in
  let token1, _ = current_token new_state1 in
  check bool "解析正确关键字后前进" true (token1 = IdentifierTokenSpecial "那么");
  
  let new_state2 = parse_specific_keyword new_state1 "那么" in
  let token2, _ = current_token new_state2 in
  check bool "解析完成" true (token2 = EOF)

(** 9. 类型解析工具测试 *)

let test_try_parse_basic_type () =
  let tokens = [IntTypeKeyword; StringTypeKeyword; ListTypeKeyword] in
  let state = TestHelpers.create_test_state tokens in
  
  (* 测试基本类型 *)
  let result1 = try_parse_basic_type IntTypeKeyword state in
  check bool "整数类型解析" true (result1 <> None);
  (match result1 with
   | Some (BaseTypeExpr IntType, _) -> ()
   | _ -> fail "整数类型解析错误");
  
  (* 测试字符串类型 *)
  let result2 = try_parse_basic_type StringTypeKeyword (advance_parser state) in
  check bool "字符串类型解析" true (result2 <> None);
  
  (* 测试列表类型 *)
  let result3 = try_parse_basic_type ListTypeKeyword (advance_parser (advance_parser state)) in
  check bool "列表类型解析" true (result3 <> None);
  
  (* 测试无效类型 *)
  let result4 = try_parse_basic_type EOF state in
  check bool "无效类型返回None" true (result4 = None)

(** 10. 边界条件和错误处理测试 *)

let test_boundary_conditions () =
  (* 空token列表 *)
  let empty_state = TestHelpers.create_test_state [] in
  let empty_token, _ = current_token empty_state in
  check bool "空列表返回EOF" true (empty_token = EOF);
  
  (* 单个token *)
  let single_state = TestHelpers.create_test_state [IntToken 42] in
  let peek_result, _ = peek_token single_state in
  check bool "单个token peek返回EOF" true (peek_result = EOF);
  
  (* 超出范围的操作 *)
  let over_state = { single_state with current_pos = 10 } in
  let over_token, _ = current_token over_state in
  check bool "超出范围返回EOF" true (over_token = EOF)

let test_error_handling () =
  (* 测试错误消息生成 *)
  let pos = TestHelpers.make_pos 1 1 "test.ly" in
  let error1 = make_unexpected_token_error "意外token" pos in
  check bool "意外token错误" true (match error1 with SyntaxError (msg, _) -> String.contains msg (String.get "意" 0) | _ -> false);
  
  let error2 = make_expected_but_found_error "期望" "实际" pos in
  check bool "期望错误消息" true (match error2 with SyntaxError (msg, _) -> String.contains msg (String.get "期" 0) | _ -> false)

(** 11. 性能和压力测试 *)

let test_performance () =
  (* 大量token的处理 *)
  let large_tokens = Array.to_list (Array.init 1000 (fun i -> IntToken i)) in
  let large_state = TestHelpers.create_test_state large_tokens in
  
  (* 快速前进测试 *)
  let rec advance_n_times n state =
    if n <= 0 then state
    else advance_n_times (n - 1) (advance_parser state)
  in
  
  let final_state = advance_n_times 500 large_state in
  check int "大量前进操作" 500 final_state.current_pos;
  
  (* 大型复合标识符测试 *)
  let compound_tokens = Array.to_list (Array.init 50 (fun i -> 
    QuotedIdentifierToken ("部分" ^ string_of_int i))) @ [ValueKeyword] in
  let compound_state = TestHelpers.create_test_state compound_tokens in
  let compound_result, _ = parse_wenyan_compound_identifier compound_state in
  check bool "大型复合标识符" true (String.length compound_result > 100)

(** 测试套件定义 *)

let parser_state_tests = [
  test_case "create_parser_state" `Quick test_create_parser_state;
  test_case "current_token" `Quick test_current_token;
  test_case "peek_token" `Quick test_peek_token;
  test_case "advance_parser" `Quick test_advance_parser;
  test_case "skip_newlines" `Quick test_skip_newlines;
]

let token_expectation_tests = [
  test_case "expect_token" `Quick test_expect_token;
  test_case "is_token" `Quick test_is_token;
]

let identifier_parsing_tests = [
  test_case "parse_identifier" `Quick test_parse_identifier;
  test_case "parse_identifier_allow_keywords" `Quick test_parse_identifier_allow_keywords;
  test_case "parse_wenyan_compound_identifier" `Quick test_parse_wenyan_compound_identifier;
]

let punctuation_tests = [
  test_case "punctuation_checkers" `Quick test_punctuation_checkers;
  test_case "expect_token_punctuation" `Quick test_expect_token_punctuation;
]

let token_classification_tests = [
  test_case "token_classification" `Quick test_token_classification;
]

let literal_parsing_tests = [
  test_case "chinese_number_conversion" `Quick test_chinese_number_conversion;
  test_case "parse_literal" `Quick test_parse_literal;
]

let operator_parsing_tests = [
  test_case "binary_operator_parsing" `Quick test_binary_operator_parsing;
]

let poetry_parsing_tests = [
  test_case "parse_identifier_content" `Quick test_parse_identifier_content;
  test_case "parse_specific_keyword" `Quick test_parse_specific_keyword;
]

let type_parsing_tests = [
  test_case "try_parse_basic_type" `Quick test_try_parse_basic_type;
]

let boundary_and_error_tests = [
  test_case "boundary_conditions" `Quick test_boundary_conditions;
  test_case "error_handling" `Quick test_error_handling;
]

let performance_tests = [
  test_case "performance" `Quick test_performance;
]

let () =
  run "骆言解析器工具模块综合测试" [
    "解析器状态管理", parser_state_tests;
    "Token期望和检查", token_expectation_tests;
    "标识符解析", identifier_parsing_tests;
    "中文标点符号", punctuation_tests;
    "Token分类", token_classification_tests;
    "字面量解析", literal_parsing_tests;
    "运算符解析", operator_parsing_tests;
    "诗词解析工具", poetry_parsing_tests;
    "类型解析工具", type_parsing_tests;
    "边界条件和错误处理", boundary_and_error_tests;
    "性能和压力测试", performance_tests;
  ]