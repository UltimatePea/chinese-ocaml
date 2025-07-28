(* 🧪 关键核心模块测试覆盖率改进 - Parser Patterns核心模块测试 Fix #1612 *)
(* Author: Echo, 测试工程师代理 *)

open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_patterns

(* 创建测试状态辅助函数 *)
let create_test_state tokens =
  let lexer_tokens = List.map (fun t -> (t, {filename = "test"; line = 1; column = 1})) tokens in
  Yyocamlc_lib.Parser_utils.create_parser_state lexer_tokens

(* 通配符模式解析测试 *)
let test_wildcard_pattern_parsing () =
  let open Alcotest in
  let tokens = [Underscore; EOF] in
  let state = create_test_state tokens in
  try
    match parse_pattern state with
    | (WildcardPattern, _) -> check bool "Wildcard pattern test" true true
    | _ -> fail "Wildcard pattern parsing failed"
  with _ -> fail "Wildcard pattern parsing failed"

(* 变量模式解析测试 *)
let test_variable_pattern_parsing () =
  let open Alcotest in
  let tokens = [QuotedIdentifierToken "x"; EOF] in
  let state = create_test_state tokens in
  try
    match parse_pattern state with
    | (VarPattern "x", _) -> check bool "Variable pattern test" true true
    | _ -> fail "Variable pattern parsing failed"
  with _ -> fail "Variable pattern parsing failed"

(* 中文标识符变量模式测试 *)
let test_chinese_variable_pattern () =
  let open Alcotest in
  let tokens = [QuotedIdentifierToken "变量"; EOF] in
  let state = create_test_state tokens in
  try
    match parse_pattern state with
    | (VarPattern "变量", _) -> check bool "Chinese variable pattern test" true true
    | _ -> fail "Chinese variable pattern parsing failed"
  with _ -> fail "Chinese variable pattern parsing failed"

(* 整数字面量模式解析测试 *)
let test_int_literal_pattern () =
  let open Alcotest in
  let tokens = [IntToken 42; EOF] in
  let state = create_test_state tokens in
  try
    match parse_pattern state with
    | (LitPattern (IntLit 42), _) -> check bool "Int literal pattern test" true true
    | _ -> fail "Integer literal pattern parsing failed"
  with _ -> fail "Integer literal pattern parsing failed"

(* 字符串字面量模式解析测试 *)
let test_string_literal_pattern () =
  let open Alcotest in
  let tokens = [StringToken "hello"; EOF] in
  let state = create_test_state tokens in
  try
    match parse_pattern state with
    | (LitPattern (StringLit "hello"), _) -> check bool "String literal pattern test" true true
    | _ -> fail "String literal pattern parsing failed"
  with _ -> fail "String literal pattern parsing failed"

(* 错误处理测试 *)
let test_error_handling () =
  let open Alcotest in
  try
    let tokens = [LeftParen; EOF] in (* 无效token开始模式 *)
    let state = create_test_state tokens in
    let _ = parse_pattern state in
    fail "Invalid pattern should raise an exception"
  with
  | Yyocamlc_lib.Parser_utils.SyntaxError _ -> check bool "Syntax error test" true true
  | _ -> check bool "Other error test" true true

let () = 
  let open Alcotest in
  run "Parser Patterns Critical Tests" [
    "parser_patterns", [
      "test_wildcard_pattern_parsing", `Quick, test_wildcard_pattern_parsing;
      "test_variable_pattern_parsing", `Quick, test_variable_pattern_parsing;
      "test_chinese_variable_pattern", `Quick, test_chinese_variable_pattern;
      "test_int_literal_pattern", `Quick, test_int_literal_pattern;
      "test_string_literal_pattern", `Quick, test_string_literal_pattern;
      "test_error_handling", `Quick, test_error_handling;
    ];
  ]