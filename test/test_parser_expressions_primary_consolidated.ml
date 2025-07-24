(** 骆言语法分析器基础表达式解析模块测试 - 整合版 增强版

    本测试模块验证 parser_expressions_primary_consolidated.ml 的完整功能。 从基础接口测试扩展为全面的功能测试。

    技术债务改进 - Fix #909 升级为 Fix #962
    @author 骆言技术债务清理团队 - Issue #962 Parser模块测试覆盖率提升
    @version 2.0 - 全面功能测试版
    @since 2025-07-23 Issue #962 第七阶段Parser模块测试补强 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Parser_expressions_primary_consolidated
module Calls = Yyocamlc_lib.Parser_expressions_calls

(** ==================== 测试辅助函数 ==================== *)

module TestUtils = struct
  (** 创建测试位置 *)
  let create_test_pos line column = { line; column; filename = "test_primary.ml" }

  (** 创建简单的解析器状态 *)
  let create_test_state tokens = create_parser_state tokens

  (** 创建基础的positioned_token *)
  let make_token token line col = (token, create_test_pos line col)

  (** 模拟的表达式解析器（递归调用） *)
  let rec mock_parse_expression state =
    match current_token state with
    | IntToken n, _ -> (LitExpr (IntLit n), advance_parser state)
    | StringToken s, _ -> (LitExpr (StringLit s), advance_parser state)
    | QuotedIdentifierToken id, _ -> (VarExpr id, advance_parser state)
    | BoolToken b, _ -> (LitExpr (BoolLit b), advance_parser state)
    | LeftParen, _ ->
        (* Handle nested parentheses *)
        let state1 = advance_parser state in
        let token, _ = current_token state1 in
        if is_right_paren token then
          (* Unit literal () *)
          let state2 = advance_parser state1 in
          (LitExpr UnitLit, state2)
        else
          (* Nested expression (expr) *)
          let expr, state2 = mock_parse_expression state1 in
          let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
          (expr, state3)
    | _ -> failwith "Cannot parse expression"

  (** 模拟的数组表达式解析器 *)
  let mock_parse_array_expression state = (ArrayExpr [], advance_parser state)

  (** 模拟的记录表达式解析器 *)
  let mock_parse_record_expression state = (RecordExpr [], advance_parser state)

  (** 验证表达式相等性 *)
  let expr_equal = equal_expr

  (** 验证解析结果 *)
  let check_parse_result (result_expr, _final_state) expected_expr msg =
    check bool msg true (expr_equal result_expr expected_expr)
end

(** ==================== 基础模块测试 ==================== *)

(** 检查模块是否存在的基础测试 *)
let test_module_exists () =
  (* 只是验证模块可以被导入 *)
  let _ = parse_literal_expr in
  check bool "模块导入成功" true true

let test_module_interface () =
  (* 验证主要函数接口存在 *)
  let _ = parse_primary_expr in
  let _ = parse_function_call_or_variable in
  check bool "模块接口存在" true true

(** ==================== 字面量表达式测试 ==================== *)

let test_integer_literal () =
  let tokens = [ TestUtils.make_token (IntToken 42) 1 1; TestUtils.make_token EOF 1 2 ] in
  let state = TestUtils.create_test_state tokens in
  try
    let result, final_state = parse_literal_expr state in
    let expected = LitExpr (IntLit 42) in
    TestUtils.check_parse_result (result, final_state) expected "整数字面量解析正确"
  with
  | SyntaxError _ -> check bool "整数字面量解析应该成功" false true
  | _ -> check bool "整数字面量解析出现意外错误" false true

let test_string_literal () =
  let tokens = [ TestUtils.make_token (StringToken "hello") 1 1; TestUtils.make_token EOF 1 2 ] in
  let state = TestUtils.create_test_state tokens in
  try
    let result, final_state = parse_literal_expr state in
    let expected = LitExpr (StringLit "hello") in
    TestUtils.check_parse_result (result, final_state) expected "字符串字面量解析正确"
  with
  | SyntaxError _ -> check bool "字符串字面量解析应该成功" false true
  | _ -> check bool "字符串字面量解析出现意外错误" false true

let test_boolean_literal () =
  let test_cases =
    [ (BoolToken true, LitExpr (BoolLit true)); (BoolToken false, LitExpr (BoolLit false)) ]
  in
  List.iter
    (fun (token_lit, expected_expr) ->
      let tokens = [ TestUtils.make_token token_lit 1 1; TestUtils.make_token EOF 1 2 ] in
      let state = TestUtils.create_test_state tokens in
      try
        let result, final_state = parse_literal_expr state in
        TestUtils.check_parse_result (result, final_state) expected_expr "布尔字面量解析正确"
      with
      | SyntaxError _ -> check bool "布尔字面量解析应该成功" false true
      | _ -> check bool "布尔字面量解析出现意外错误" false true)
    test_cases

let test_unit_literal () =
  let tokens =
    [
      TestUtils.make_token LeftParen 1 1;
      TestUtils.make_token RightParen 1 2;
      TestUtils.make_token EOF 1 3;
    ]
  in
  let state = TestUtils.create_test_state tokens in
  try
    let result, final_state =
      parse_primary_expr TestUtils.mock_parse_expression TestUtils.mock_parse_array_expression
        TestUtils.mock_parse_record_expression state
    in
    let expected = LitExpr UnitLit in
    TestUtils.check_parse_result (result, final_state) expected "单元字面量解析正确"
  with
  | SyntaxError _ -> check bool "单元字面量解析应该成功" false true
  | _ -> check bool "单元字面量解析出现意外错误" false true

(** ==================== 基础表达式解析测试 ==================== *)

let test_variable_expression () =
  let tokens =
    [
      TestUtils.make_token (QuotedIdentifierToken "variable_name") 1 1; TestUtils.make_token EOF 1 2;
    ]
  in
  let state = TestUtils.create_test_state tokens in
  try
    let result, final_state =
      parse_primary_expr TestUtils.mock_parse_expression TestUtils.mock_parse_array_expression
        TestUtils.mock_parse_record_expression state
    in
    let expected = VarExpr "variable_name" in
    TestUtils.check_parse_result (result, final_state) expected "变量表达式解析正确"
  with
  | SyntaxError _ -> check bool "变量表达式解析应该成功" false true
  | _ -> check bool "变量表达式解析出现意外错误" false true

let test_parenthesized_expression () =
  let tokens =
    [
      TestUtils.make_token LeftParen 1 1;
      TestUtils.make_token (IntToken 42) 1 2;
      TestUtils.make_token RightParen 1 3;
      TestUtils.make_token EOF 1 4;
    ]
  in
  let state = TestUtils.create_test_state tokens in
  try
    let result, final_state =
      parse_primary_expr TestUtils.mock_parse_expression TestUtils.mock_parse_array_expression
        TestUtils.mock_parse_record_expression state
    in
    let expected = LitExpr (IntLit 42) in
    TestUtils.check_parse_result (result, final_state) expected "括号表达式解析正确"
  with
  | SyntaxError _ -> check bool "括号表达式解析应该成功" false true
  | _ -> check bool "括号表达式解析出现意外错误" false true

(** ==================== 函数调用测试 ==================== *)

let test_function_call_or_variable_simple () =
  let tokens = [ TestUtils.make_token EOF 1 1 ] in
  let state = TestUtils.create_test_state tokens in
  try
    let result, final_state = parse_function_call_or_variable "test_func" state in
    let expected = VarExpr "test_func" in
    TestUtils.check_parse_result (result, final_state) expected "简单函数/变量解析正确"
  with
  | SyntaxError _ -> check bool "简单函数/变量解析应该成功" false true
  | _ -> check bool "简单函数/变量解析出现意外错误" false true

let test_function_call_with_arguments () =
  let tokens =
    [
      TestUtils.make_token (IntToken 1) 1 1;
      TestUtils.make_token (IntToken 2) 1 2;
      TestUtils.make_token EOF 1 3;
    ]
  in
  let state = TestUtils.create_test_state tokens in
  try
    let _result, _final_state = parse_function_call_or_variable "add" state in
    check bool "带参数的函数调用解析成功" true true
  with
  | SyntaxError _ -> check bool "带参数的函数调用解析应该成功" false true
  | _ -> check bool "带参数的函数调用解析出现意外错误" false true

(** ==================== 后缀表达式测试 ==================== *)

let test_field_access_postfix () =
  let base_expr = VarExpr "record" in
  let tokens =
    [
      TestUtils.make_token Dot 1 1;
      TestUtils.make_token (QuotedIdentifierToken "field") 1 2;
      TestUtils.make_token EOF 1 3;
    ]
  in
  let state = TestUtils.create_test_state tokens in
  try
    let result, final_state = Calls.parse_postfix_expr TestUtils.mock_parse_expression base_expr state in
    let expected = FieldAccessExpr (VarExpr "record", "field") in
    TestUtils.check_parse_result (result, final_state) expected "字段访问后缀表达式解析正确"
  with
  | SyntaxError _ -> check bool "字段访问后缀表达式解析应该成功" false true
  | _ -> check bool "字段访问后缀表达式解析出现意外错误" false true

let test_array_access_postfix () =
  let base_expr = VarExpr "array" in
  let tokens =
    [
      TestUtils.make_token LeftParen 1 1;
      TestUtils.make_token (IntToken 0) 1 2;
      TestUtils.make_token RightParen 1 3;
      TestUtils.make_token EOF 1 4;
    ]
  in
  let state = TestUtils.create_test_state tokens in
  try
    let _result, _final_state =
      Calls.parse_postfix_expr TestUtils.mock_parse_expression base_expr state
    in
    check bool "数组访问后缀表达式解析成功" true true
  with
  | SyntaxError _ -> check bool "数组访问后缀表达式解析应该成功" false true
  | _ -> check bool "数组访问后缀表达式解析出现意外错误" false true

(** ==================== 复杂表达式测试 ==================== *)

let test_nested_primary_expressions () =
  let tokens =
    [
      TestUtils.make_token LeftParen 1 1;
      TestUtils.make_token LeftParen 1 2;
      TestUtils.make_token (IntToken 42) 1 3;
      TestUtils.make_token RightParen 1 4;
      TestUtils.make_token RightParen 1 5;
      TestUtils.make_token EOF 1 6;
    ]
  in
  let state = TestUtils.create_test_state tokens in
  try
    let result, final_state =
      parse_primary_expr TestUtils.mock_parse_expression TestUtils.mock_parse_array_expression
        TestUtils.mock_parse_record_expression state
    in
    let expected = LitExpr (IntLit 42) in
    TestUtils.check_parse_result (result, final_state) expected "嵌套括号表达式解析正确"
  with
  | SyntaxError _ -> check bool "嵌套括号表达式解析应该成功" false true
  | _ -> check bool "嵌套括号表达式解析出现意外错误" false true

(** ==================== 错误处理测试 ==================== *)

let test_invalid_literal () =
  let tokens =
    [
      TestUtils.make_token (QuotedIdentifierToken "not_a_literal") 1 1; TestUtils.make_token EOF 1 2;
    ]
  in
  let state = TestUtils.create_test_state tokens in
  try
    let _result, _final_state = parse_literal_expr state in
    check bool "无效字面量应该触发错误" false true
  with
  | SyntaxError _ -> check bool "无效字面量正确触发语法错误" true true
  | _ -> check bool "无效字面量处理出现意外错误" false true

let test_mismatched_parentheses () =
  let tokens =
    [
      TestUtils.make_token LeftParen 1 1;
      TestUtils.make_token (IntToken 42) 1 2;
      TestUtils.make_token EOF 1 3;
    ]
  in
  let state = TestUtils.create_test_state tokens in
  try
    let _result, _final_state =
      parse_primary_expr TestUtils.mock_parse_expression TestUtils.mock_parse_array_expression
        TestUtils.mock_parse_record_expression state
    in
    check bool "不匹配的括号应该触发错误" false true
  with
  | SyntaxError _ -> check bool "不匹配的括号正确触发语法错误" true true
  | _ -> check bool "不匹配的括号处理出现意外错误" false true

(** ==================== 测试运行器 ==================== *)

let basic_tests =
  [ test_case "模块存在性测试" `Quick test_module_exists; test_case "模块接口测试" `Quick test_module_interface ]

let literal_tests =
  [
    test_case "整数字面量" `Quick test_integer_literal;
    test_case "字符串字面量" `Quick test_string_literal;
    test_case "布尔字面量" `Quick test_boolean_literal;
    test_case "单元字面量" `Quick test_unit_literal;
  ]

let primary_tests =
  [
    test_case "变量表达式" `Quick test_variable_expression;
    test_case "括号表达式" `Quick test_parenthesized_expression;
  ]

let function_tests =
  [
    test_case "简单函数/变量" `Quick test_function_call_or_variable_simple;
    test_case "带参数函数调用" `Quick test_function_call_with_arguments;
  ]

let postfix_tests =
  [
    test_case "字段访问后缀" `Quick test_field_access_postfix;
    test_case "数组访问后缀" `Quick test_array_access_postfix;
  ]

let complex_tests = [ test_case "嵌套括号表达式" `Quick test_nested_primary_expressions ]

let error_tests =
  [
    test_case "无效字面量" `Quick test_invalid_literal;
    test_case "不匹配括号" `Quick test_mismatched_parentheses;
  ]

let () =
  run "Parser_expressions_primary_consolidated Enhanced Tests"
    [
      ("基础模块测试", basic_tests);
      ("字面量表达式测试", literal_tests);
      ("基础表达式测试", primary_tests);
      ("函数调用测试", function_tests);
      ("后缀表达式测试", postfix_tests);
      ("复杂表达式测试", complex_tests);
      ("错误处理测试", error_tests);
    ]
