(* 🧪 关键核心模块测试覆盖率改进 - Parser Patterns核心模块测试 Fix #1612 *)
(* Author: Alpha, 核心工作代理 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_patterns

(* 创建测试状态辅助函数 *)
let create_test_state tokens =
  let lexer_tokens = List.map (fun t -> (t, {filename = "test"; line = 1; column = 1})) tokens in
  Parser_utils.create_parser_state lexer_tokens

(* 通配符模式解析测试 *)
let test_wildcard_pattern_parsing () =
  let tokens = [Underscore; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (WildcardPattern, _) -> ()
  | _ -> Alcotest.fail "Wildcard pattern parsing failed"

(* 变量模式解析测试 *)
let test_variable_pattern_parsing () =
  let tokens = [QuotedIdentifierToken "x"; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (VarPattern "x", _) -> ()
  | _ -> Alcotest.fail "Variable pattern parsing failed"

(* 中文标识符变量模式测试 *)
let test_chinese_variable_pattern () =
  let tokens = [QuotedIdentifierToken "变量"; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (VarPattern "变量", _) -> ()
  | _ -> Alcotest.fail "Chinese variable pattern parsing failed"

(* 整数字面量模式解析测试 *)
let test_int_literal_pattern () =
  let tokens = [IntToken 42; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (LitPattern (IntLit 42), _) -> ()
  | _ -> Alcotest.fail "Integer literal pattern parsing failed"

(* 中文数字模式解析测试 *)
let test_chinese_number_pattern () =
  let tokens = [ChineseNumberToken "五"; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (LitPattern (IntLit 5), _) -> ()
  | _ -> Alcotest.fail "Chinese number pattern parsing failed"

(* 关键字数字模式解析测试 *)
let test_one_keyword_pattern () =
  let tokens = [OneKeyword; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (LitPattern (IntLit 1), _) -> ()
  | _ -> Alcotest.fail "One keyword pattern parsing failed"

(* 浮点数字面量模式解析测试 *)
let test_float_literal_pattern () =
  let tokens = [FloatToken 3.14; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (LitPattern (FloatLit 3.14), _) -> ()
  | _ -> Alcotest.fail "Float literal pattern parsing failed"

(* 字符串字面量模式解析测试 *)
let test_string_literal_pattern () =
  let tokens = [StringToken "hello"; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (LitPattern (StringLit "hello"), _) -> ()
  | _ -> Alcotest.fail "String literal pattern parsing failed"

(* 布尔字面量模式解析测试 *)
let test_bool_literal_pattern () =
  let tokens = [BoolToken true; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (LitPattern (BoolLit true), _) -> ()
  | _ -> Alcotest.fail "Boolean literal pattern parsing failed"

(* 多态变体模式解析测试 - 无参数 *)
let test_polymorphic_variant_pattern_no_args () =
  let tokens = [TagKeyword; QuotedIdentifierToken "Success"; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (PolymorphicVariantPattern ("Success", None), _) -> ()
  | _ -> Alcotest.fail "Polymorphic variant pattern (no args) parsing failed"

(* 多态变体模式解析测试 - 有参数 *)
let test_polymorphic_variant_pattern_with_args () =
  let tokens = [TagKeyword; QuotedIdentifierToken "Some"; IntToken 42; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (PolymorphicVariantPattern ("Some", Some _), _) -> ()
  | _ -> Alcotest.fail "Polymorphic variant pattern (with args) parsing failed"

(* 构造器模式解析测试 - 基础版本，避免依赖表达式解析器 *)
let test_constructor_pattern_basic () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Constructor pattern parsing attempt"
    (Error "parse_error")
    (try
      let tokens = [QuotedIdentifierToken "Some"; LeftParen; IntToken 42; RightParen; EOF] in
      let state = create_test_state tokens in
      let _ = parse_pattern state in
      Ok "parsed"
    with
    | Types.ParseError _ -> Error "parse_error" 
    | _ -> Error "other_error")

(* 嵌套模式解析测试 *)
let test_nested_pattern_parsing () =
  let tokens = [TagKeyword; QuotedIdentifierToken "Nested"; Underscore; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (PolymorphicVariantPattern ("Nested", Some WildcardPattern), _) -> ()
  | _ -> Alcotest.fail "Nested pattern parsing failed"

(* 无效模式错误处理测试 *)
let test_invalid_pattern_error_handling () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Invalid pattern error handling"
    (Error "syntax_error")
    (try
      let tokens = [LeftParen; EOF] in (* 无效token开始模式 *)
      let state = create_test_state tokens in
      let _ = parse_pattern state in
      Ok "parsed"
    with
    | Parser_utils.SyntaxError _ -> Error "syntax_error" 
    | _ -> Error "other_error")

(* 复杂标识符模式测试 *)
let test_complex_identifier_pattern () =
  let tokens = [QuotedIdentifierToken "复杂变量名"; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (VarPattern "复杂变量名", _) -> ()
  | _ -> Alcotest.fail "Complex identifier pattern parsing failed"

(* 边界值模式测试 *)
let test_boundary_value_patterns () =
  (* 测试最大整数 *)
  let tokens = [IntToken max_int; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (LitPattern (IntLit n), _) when n = max_int -> ()
  | _ -> Alcotest.fail "Max int boundary pattern parsing failed";
  
  (* 测试零值 *)
  let tokens = [IntToken 0; EOF] in
  let state = create_test_state tokens in
  match parse_pattern state with
  | (LitPattern (IntLit 0), _) -> ()
  | _ -> Alcotest.fail "Zero boundary pattern parsing failed"

let suite = [
  "test_wildcard_pattern_parsing", `Quick, test_wildcard_pattern_parsing;
  "test_variable_pattern_parsing", `Quick, test_variable_pattern_parsing;
  "test_chinese_variable_pattern", `Quick, test_chinese_variable_pattern;
  "test_int_literal_pattern", `Quick, test_int_literal_pattern;
  "test_chinese_number_pattern", `Quick, test_chinese_number_pattern;
  "test_one_keyword_pattern", `Quick, test_one_keyword_pattern;
  "test_float_literal_pattern", `Quick, test_float_literal_pattern;
  "test_string_literal_pattern", `Quick, test_string_literal_pattern;
  "test_bool_literal_pattern", `Quick, test_bool_literal_pattern;
  "test_polymorphic_variant_pattern_no_args", `Quick, test_polymorphic_variant_pattern_no_args;
  "test_polymorphic_variant_pattern_with_args", `Quick, test_polymorphic_variant_pattern_with_args;
  "test_constructor_pattern_basic", `Quick, test_constructor_pattern_basic;
  "test_nested_pattern_parsing", `Quick, test_nested_pattern_parsing;
  "test_invalid_pattern_error_handling", `Quick, test_invalid_pattern_error_handling;
  "test_complex_identifier_pattern", `Quick, test_complex_identifier_pattern;
  "test_boundary_value_patterns", `Quick, test_boundary_value_patterns;
]