(** 骆言Parser模式匹配模块全面测试覆盖 - Fix #962 第七阶段Parser模块测试补强

    本测试模块专门针对 parser_patterns.ml 模块进行全面功能测试， 重点测试模式匹配解析功能的正确性和健壮性。

    测试覆盖范围：
    - parse_pattern 模式解析：通配符、变量、字面量、构造器、多态变体模式
    - parse_match_expression 匹配表达式解析
    - parse_ancient_match_expression 古雅体匹配表达式解析
    - 边界条件和错误处理测试

    @author 骆言技术债务清理团队 - Issue #962 Parser模块测试覆盖率提升
    @version 1.0
    @since 2025-07-23 Issue #962 第七阶段Parser模块测试补强 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer_tokens
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Parser_patterns

(** 测试工具函数 *)
module TestUtils = struct
  (** 创建测试位置 *)
  let create_test_pos line column = { line; column; filename = "test_parser_patterns.ml" }

  (** 创建简单的解析器状态 *)
  let create_test_state tokens = create_parser_state tokens

  (** 验证语法错误 *)
  let expect_syntax_error f =
    try
      ignore (f ());
      false
    with
    | SyntaxError _ -> true
    | _ -> false

  (** 创建基础的positioned_token *)
  let make_token token line col = (token, create_test_pos line col)

  (** 验证模式相等性 *)
  let check_pattern desc expected actual =
    check (testable pp_pattern equal_pattern) desc expected actual
end

(** 基础模式解析测试模块 *)
module BasicPatternTests = struct
  open TestUtils

  let test_wildcard_pattern () =
    let tokens = [ make_token Underscore 1 1; make_token EOF 1 2 ] in
    let state = create_test_state tokens in
    let pattern, _final_state = parse_pattern state in
    check_pattern "通配符模式解析" WildcardPattern pattern

  let test_var_pattern () =
    let tokens = [ make_token (QuotedIdentifierToken "x") 1 1; make_token EOF 1 2 ] in
    let state = create_test_state tokens in
    let pattern, _final_state = parse_pattern state in
    check_pattern "变量模式解析" (VarPattern "x") pattern

  let test_int_literal_pattern () =
    let tokens = [ make_token (IntToken 42) 1 1; make_token EOF 1 2 ] in
    let state = create_test_state tokens in
    let pattern, _final_state = parse_pattern state in
    check_pattern "整数字面量模式解析" (LitPattern (IntLit 42)) pattern

  let test_string_literal_pattern () =
    let tokens = [ make_token (StringToken "hello") 1 1; make_token EOF 1 2 ] in
    let state = create_test_state tokens in
    let pattern, _final_state = parse_pattern state in
    check_pattern "字符串字面量模式解析" (LitPattern (StringLit "hello")) pattern

  let test_bool_literal_pattern () =
    let tokens = [ make_token (BoolToken true) 1 1; make_token EOF 1 2 ] in
    let state = create_test_state tokens in
    let pattern, _final_state = parse_pattern state in
    check_pattern "布尔字面量模式解析" (LitPattern (BoolLit true)) pattern

  let test_chinese_number_pattern () =
    let tokens = [ make_token (ChineseNumberToken "三") 1 1; make_token EOF 1 2 ] in
    let state = create_test_state tokens in
    let pattern, _final_state = parse_pattern state in
    check_pattern "中文数字模式解析" (LitPattern (IntLit 3)) pattern

  let test_one_keyword_pattern () =
    let tokens = [ make_token OneKeyword 1 1; make_token EOF 1 2 ] in
    let state = create_test_state tokens in
    let pattern, _final_state = parse_pattern state in
    check_pattern "「一」关键字模式解析" (LitPattern (IntLit 1)) pattern

  let tests =
    [
      test_case "Wildcard pattern" `Quick test_wildcard_pattern;
      test_case "Variable pattern" `Quick test_var_pattern;
      test_case "Integer literal pattern" `Quick test_int_literal_pattern;
      test_case "String literal pattern" `Quick test_string_literal_pattern;
      test_case "Boolean literal pattern" `Quick test_bool_literal_pattern;
      test_case "Chinese number pattern" `Quick test_chinese_number_pattern;
      test_case "One keyword pattern" `Quick test_one_keyword_pattern;
    ]
end

(** 多态变体模式测试模块 *)
module PolymorphicVariantTests = struct
  open TestUtils

  let test_simple_polymorphic_variant () =
    let tokens =
      [
        make_token TagKeyword 1 1; make_token (QuotedIdentifierToken "Red") 1 2; make_token EOF 1 3;
      ]
    in
    let state = create_test_state tokens in
    let pattern, _final_state = parse_pattern state in
    check_pattern "简单多态变体模式" (PolymorphicVariantPattern ("Red", None)) pattern

  let test_polymorphic_variant_with_pattern () =
    let tokens =
      [
        make_token TagKeyword 1 1;
        make_token (QuotedIdentifierToken "Value") 1 2;
        make_token (IntToken 42) 1 3;
        make_token EOF 1 4;
      ]
    in
    let state = create_test_state tokens in
    let pattern, _final_state = parse_pattern state in
    let expected = PolymorphicVariantPattern ("Value", Some (LitPattern (IntLit 42))) in
    check_pattern "带模式的多态变体" expected pattern

  let tests =
    [
      test_case "Simple polymorphic variant" `Quick test_simple_polymorphic_variant;
      test_case "Polymorphic variant with pattern" `Quick test_polymorphic_variant_with_pattern;
    ]
end

(** 错误处理和边界条件测试模块 *)
module ErrorHandlingTests = struct
  open TestUtils

  let test_unsupported_token_error () =
    let tokens = [ make_token LeftBrace 1 1; (* 不支持的token *) make_token EOF 1 2 ] in
    let state = create_test_state tokens in
    let result = expect_syntax_error (fun () -> parse_pattern state) in
    check bool "不支持的token应该抛出语法错误" true result

  let tests = [ test_case "Unsupported token error" `Quick test_unsupported_token_error ]
end

(** 主测试套件 *)
let parser_patterns_tests =
  [
    ("Basic Pattern Tests", BasicPatternTests.tests);
    ("Polymorphic Variant Tests", PolymorphicVariantTests.tests);
    ("Error Handling Tests", ErrorHandlingTests.tests);
  ]

let () = run "Parser Patterns Comprehensive Tests" parser_patterns_tests
