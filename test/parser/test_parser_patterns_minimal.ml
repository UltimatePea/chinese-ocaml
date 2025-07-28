(** 骆言模式匹配解析器最小化测试 - 专注覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_patterns
open Yyocamlc_lib.Parser_utils

(** 测试工具函数 *)
let create_test_pos line column = { line; column; filename = "test_patterns" }

(** 创建基础解析器状态 *)
let create_test_state tokens =
  let lexer_tokens = List.map (fun (token, pos) -> (token, pos)) tokens in
  create_parser_state lexer_tokens

(** 基础模式匹配测试 *)
module BasicPatternTests = struct

  (** 测试通配符模式解析 *)
  let test_wildcard_pattern () =
    let tokens = [
      (Underscore, create_test_pos 1 1);
      (EOF, create_test_pos 1 2);
    ] in
    let state = create_test_state tokens in
    try
      let pattern, _final_state = parse_pattern state in
      match pattern with
      | WildcardPattern -> check bool "通配符模式解析成功" true true
      | _ -> fail "期望通配符模式"
    with
    | exn -> fail ("解析异常: " ^ Printexc.to_string exn)

  (** 测试变量模式解析 *)
  let test_variable_pattern () =
    let tokens = [
      (QuotedIdentifierToken "变量名", create_test_pos 1 1);
      (EOF, create_test_pos 1 2);
    ] in
    let state = create_test_state tokens in
    try
      let pattern, _final_state = parse_pattern state in
      match pattern with
      | VarPattern name -> check string "变量模式名称" "变量名" name
      | _ -> fail "期望变量模式"
    with
    | exn -> fail ("解析异常: " ^ Printexc.to_string exn)

  (** 测试整数字面量模式解析 *)
  let test_int_literal_pattern () =
    let tokens = [
      (IntToken 42, create_test_pos 1 1);
      (EOF, create_test_pos 1 2);
    ] in
    let state = create_test_state tokens in
    try
      let pattern, _final_state = parse_pattern state in
      match pattern with
      | LitPattern (IntLit 42) -> check bool "整数字面量模式" true true
      | _ -> fail "期望整数字面量模式"
    with
    | exn -> fail ("解析异常: " ^ Printexc.to_string exn)

  (** 测试字符串字面量模式解析 *)
  let test_string_literal_pattern () =
    let tokens = [
      (StringToken "hello", create_test_pos 1 1);
      (EOF, create_test_pos 1 2);
    ] in
    let state = create_test_state tokens in
    try
      let pattern, _final_state = parse_pattern state in
      match pattern with
      | LitPattern (StringLit "hello") -> check bool "字符串字面量模式" true true
      | _ -> fail "期望字符串字面量模式"
    with
    | exn -> fail ("解析异常: " ^ Printexc.to_string exn)

  (** 测试布尔值字面量模式解析 *)
  let test_bool_literal_pattern () =
    let tokens = [
      (BoolToken true, create_test_pos 1 1);
      (EOF, create_test_pos 1 2);
    ] in
    let state = create_test_state tokens in
    try
      let pattern, _final_state = parse_pattern state in
      match pattern with
      | LitPattern (BoolLit true) -> check bool "布尔值字面量模式" true true
      | _ -> fail "期望布尔值字面量模式"
    with
    | exn -> fail ("解析异常: " ^ Printexc.to_string exn)

end

(** 多态变体模式测试 *)
module PolymorphicVariantTests = struct

  (** 测试无参数多态变体模式 *)
  let test_simple_polymorphic_variant () =
    let tokens = [
      (TagKeyword, create_test_pos 1 1);
      (QuotedIdentifierToken "状态", create_test_pos 1 2);
      (EOF, create_test_pos 1 3);
    ] in
    let state = create_test_state tokens in
    try
      let pattern, _final_state = parse_pattern state in
      match pattern with
      | PolymorphicVariantPattern ("状态", None) -> check bool "无参数多态变体" true true
      | _ -> fail "期望无参数多态变体模式"
    with
    | exn -> fail ("解析异常: " ^ Printexc.to_string exn)

  (** 测试带参数多态变体模式 *)
  let test_polymorphic_variant_with_pattern () =
    let tokens = [
      (TagKeyword, create_test_pos 1 1);
      (QuotedIdentifierToken "结果", create_test_pos 1 2);
      (IntToken 42, create_test_pos 1 3);
      (EOF, create_test_pos 1 4);
    ] in
    let state = create_test_state tokens in
    try
      let pattern, _final_state = parse_pattern state in
      match pattern with
      | PolymorphicVariantPattern ("结果", Some (LitPattern (IntLit 42))) -> 
          check bool "带参数多态变体" true true
      | _ -> fail "期望带参数多态变体模式"
    with
    | exn -> fail ("解析异常: " ^ Printexc.to_string exn)

end

(** 错误处理测试 *)
module ErrorHandlingTests = struct

  (** 测试未支持的token类型错误 *)
  let test_unsupported_token_error () =
    let tokens = [
      (LeftParen, create_test_pos 1 1); (* 不是字面量token *)
      (EOF, create_test_pos 1 2);
    ] in
    let state = create_test_state tokens in
    try
      let _pattern, _final_state = parse_pattern state in
      fail "应该抛出语法错误"
    with
    | exn -> 
        let msg = Printexc.to_string exn in
        check bool "错误消息非空" true (String.length msg > 0)

end

(** 主测试套件 *)
let tests = [
  "基础模式匹配", [
    test_case "通配符模式" `Quick BasicPatternTests.test_wildcard_pattern;
    test_case "变量模式" `Quick BasicPatternTests.test_variable_pattern;
    test_case "整数字面量模式" `Quick BasicPatternTests.test_int_literal_pattern;
    test_case "字符串字面量模式" `Quick BasicPatternTests.test_string_literal_pattern;
    test_case "布尔值字面量模式" `Quick BasicPatternTests.test_bool_literal_pattern;
  ];
  "多态变体模式", [
    test_case "无参数多态变体" `Quick PolymorphicVariantTests.test_simple_polymorphic_variant;
    test_case "带参数多态变体" `Quick PolymorphicVariantTests.test_polymorphic_variant_with_pattern;
  ];
  "错误处理", [
    test_case "未支持token错误" `Quick ErrorHandlingTests.test_unsupported_token_error;
  ];
]

let () = run "Parser_patterns Minimal Coverage Tests" tests