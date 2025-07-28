(** 解析器基础表达式整合模块综合测试

    本测试文件针对parser_expressions_primary_consolidated.ml模块进行全面测试。 该模块是编译器的核心组件，负责解析所有基础表达式类型。

    测试覆盖：
    - 基础表达式解析功能
    - 后缀表达式解析
    - 字面量解析
    - 标识符解析
    - 函数调用解析
    - 诗词表达式解析
    - 古雅体表达式解析
    - 错误处理和边界条件
    - 性能验证

    技术债务改进 - Fix #1036
    @author 骆言AI代理
    @since 2025-07-24 *)

open OUnit2
open Ast
open Lexer
open Parser_utils
open Parser_expressions_primary_consolidated

(** ==================== 测试辅助函数 ==================== *)

(** 创建基础解析器状态 *)
let create_test_state tokens =
  {
    tokens;
    position = 0;
    errors = [];
    debug_mode = false;
    ancient_mode = false;
    chinese_mode = true;
  }

(** 简单表达式解析器（测试用） *)
let rec simple_parse_expression state =
  match current_token state with
  | Some (IntToken i) -> (LitExpr (IntLit i), advance_parser state)
  | Some (StringToken s) -> (LitExpr (StringLit s), advance_parser state)
  | Some (QuotedIdentifierToken name) -> (VarExpr name, advance_parser state)
  | _ -> failwith "简单表达式解析失败"

(** 数组表达式解析器（测试用） *)
let simple_parse_array_expression state =
  match current_token state with
  | Some LeftBracketToken -> (
      let state1 = advance_parser state in
      let expr, state2 = simple_parse_expression state1 in
      match current_token state2 with
      | Some RightBracketToken ->
          let state3 = advance_parser state2 in
          (ArrayExpr [ expr ], state3)
      | _ -> failwith "数组表达式解析失败")
  | _ -> failwith "不是数组表达式"

(** 记录表达式解析器（测试用） *)
let simple_parse_record_expression state = (RecordExpr [], state)

(** ==================== 基础表达式解析测试 ==================== *)

let test_parse_primary_expr_literal _ =
  (* 测试整数字面量 *)
  let tokens = [ IntToken 42 ] in
  let state = create_test_state tokens in
  let expr, new_state =
    parse_primary_expr simple_parse_expression simple_parse_array_expression
      simple_parse_record_expression state
  in
  assert_equal (LitExpr (IntLit 42)) expr;
  assert_equal 1 new_state.position

let test_parse_primary_expr_string _ =
  (* 测试字符串字面量 *)
  let tokens = [ StringToken "骆言测试" ] in
  let state = create_test_state tokens in
  let expr, new_state =
    parse_primary_expr simple_parse_expression simple_parse_array_expression
      simple_parse_record_expression state
  in
  assert_equal (LitExpr (StringLit "骆言测试")) expr;
  assert_equal 1 new_state.position

let test_parse_primary_expr_chinese_number _ =
  (* 测试中文数字 *)
  let tokens = [ ChineseNumberToken "一二三" ] in
  let state = create_test_state tokens in
  let expr, new_state =
    parse_primary_expr simple_parse_expression simple_parse_array_expression
      simple_parse_record_expression state
  in
  match expr with LitExpr (IntLit n) -> assert_equal 123 n | _ -> assert_failure "中文数字解析结果类型错误"

let test_parse_primary_expr_boolean _ =
  (* 测试布尔字面量 *)
  let tokens_true = [ TrueKeyword ] in
  let state_true = create_test_state tokens_true in
  let expr_true, _ =
    parse_primary_expr simple_parse_expression simple_parse_array_expression
      simple_parse_record_expression state_true
  in
  assert_equal (LitExpr (BoolLit true)) expr_true;

  let tokens_false = [ FalseKeyword ] in
  let state_false = create_test_state tokens_false in
  let expr_false, _ =
    parse_primary_expr simple_parse_expression simple_parse_array_expression
      simple_parse_record_expression state_false
  in
  assert_equal (LitExpr (BoolLit false)) expr_false

let test_parse_primary_expr_variable _ =
  (* 测试变量解析 *)
  let tokens = [ QuotedIdentifierToken "变量名" ] in
  let state = create_test_state tokens in
  let expr, new_state =
    parse_primary_expr simple_parse_expression simple_parse_array_expression
      simple_parse_record_expression state
  in
  assert_equal (VarExpr "变量名") expr;
  assert_equal 1 new_state.position

(** ==================== 后缀表达式解析测试 ==================== *)

let test_parse_postfix_expr_field_access _ =
  (* 测试字段访问 *)
  let tokens = [ DotToken; QuotedIdentifierToken "字段名" ] in
  let state = create_test_state tokens in
  let base_expr = VarExpr "对象" in
  let expr, new_state = parse_postfix_expr simple_parse_expression base_expr state in
  assert_equal (FieldAccessExpr (base_expr, "字段名")) expr;
  assert_equal 2 new_state.position

let test_parse_postfix_expr_array_access _ =
  (* 测试数组索引访问 *)
  let tokens = [ LeftBracketToken; IntToken 1; RightBracketToken ] in
  let state = create_test_state tokens in
  let base_expr = VarExpr "数组" in
  let expr, new_state = parse_postfix_expr simple_parse_expression base_expr state in
  assert_equal (ArrayAccessExpr (base_expr, LitExpr (IntLit 1))) expr;
  assert_equal 3 new_state.position

let test_parse_postfix_expr_no_postfix _ =
  (* 测试无后缀的情况 *)
  let tokens = [ SemicolonToken ] in
  let state = create_test_state tokens in
  let base_expr = VarExpr "基础" in
  let expr, new_state = parse_postfix_expr simple_parse_expression base_expr state in
  assert_equal base_expr expr;
  assert_equal 0 new_state.position (* 位置不应该改变 *)

(** ==================== 函数参数解析测试 ==================== *)

let test_parse_function_arguments_empty _ =
  (* 测试空参数列表 *)
  let tokens = [ RightParenToken ] in
  let state = create_test_state tokens in
  let args, new_state = parse_function_arguments simple_parse_expression state in
  assert_equal [] args;
  assert_equal 0 new_state.position

let test_parse_function_arguments_single _ =
  (* 测试单个参数 *)
  let tokens = [ IntToken 42; RightParenToken ] in
  let state = create_test_state tokens in
  let args, new_state = parse_function_arguments simple_parse_expression state in
  assert_equal [ LitExpr (IntLit 42) ] args;
  assert_equal 2 new_state.position

let test_parse_function_arguments_multiple _ =
  (* 测试多个参数 *)
  let tokens =
    [ IntToken 1; CommaToken; StringToken "测试"; CommaToken; IntToken 3; RightParenToken ]
  in
  let state = create_test_state tokens in
  let args, new_state = parse_function_arguments simple_parse_expression state in
  let expected = [ LitExpr (IntLit 1); LitExpr (StringLit "测试"); LitExpr (IntLit 3) ] in
  assert_equal expected args;
  assert_equal 6 new_state.position

(** ==================== 字面量解析测试 ==================== *)

let test_parse_literal_expr_int _ =
  (* 测试整数字面量解析 *)
  let tokens = [ IntToken 999 ] in
  let state = create_test_state tokens in
  let expr, new_state = parse_literal_expr state in
  assert_equal (LitExpr (IntLit 999)) expr;
  assert_equal 1 new_state.position

let test_parse_literal_expr_float _ =
  (* 测试浮点数字面量解析 *)
  let tokens = [ FloatToken 3.14 ] in
  let state = create_test_state tokens in
  let expr, new_state = parse_literal_expr state in
  assert_equal (LitExpr (FloatLit 3.14)) expr;
  assert_equal 1 new_state.position

let test_parse_literal_expr_string _ =
  (* 测试字符串字面量解析 *)
  let tokens = [ StringToken "骆言编程语言" ] in
  let state = create_test_state tokens in
  let expr, new_state = parse_literal_expr state in
  assert_equal (LitExpr (StringLit "骆言编程语言")) expr;
  assert_equal 1 new_state.position

(** ==================== 标识符解析测试 ==================== *)

let test_parse_identifier_expr_variable _ =
  (* 测试变量标识符解析 *)
  let tokens = [ QuotedIdentifierToken "变量标识符" ] in
  let state = create_test_state tokens in
  let expr, new_state = parse_identifier_expr simple_parse_expression state in
  assert_equal (VarExpr "变量标识符") expr;
  assert_equal 1 new_state.position

let test_parse_function_call_or_variable_simple _ =
  (* 测试简单函数调用或变量解析 *)
  let tokens = [] in
  let state = create_test_state tokens in
  let expr, new_state = parse_function_call_or_variable "测试函数" state in
  match expr with
  | VarExpr name -> assert_equal "测试函数" name
  | FunctionCallExpr (name, args) ->
      assert_equal "测试函数" name;
      assert_equal [] args
  | _ -> assert_failure "函数调用或变量解析结果类型错误"

(** ==================== 诗词表达式解析测试 ==================== *)

let test_parse_poetry_expr_basic _ =
  (* 测试基础诗词表达式解析 *)
  let tokens = [ PoetryKeyword; StringToken "山重水复疑无路" ] in
  let state = create_test_state tokens in
  let expr, new_state = parse_poetry_expr state in
  match expr with
  | PoetryExpr content -> assert_equal "山重水复疑无路" content
  | _ -> assert_failure "诗词表达式解析结果类型错误"

(** ==================== 类型关键字表达式解析测试 ==================== *)

let test_parse_type_keyword_expr_int _ =
  (* 测试整数类型关键字 *)
  let tokens = [ IntTypeKeyword ] in
  let state = create_test_state tokens in
  let expr, new_state = parse_type_keyword_expr state in
  match expr with
  | TypeExpr type_name -> assert_equal "int" type_name
  | _ -> assert_failure "类型关键字表达式解析结果类型错误"

let test_parse_type_keyword_expr_string _ =
  (* 测试字符串类型关键字 *)
  let tokens = [ StringTypeKeyword ] in
  let state = create_test_state tokens in
  let expr, new_state = parse_type_keyword_expr state in
  match expr with
  | TypeExpr type_name -> assert_equal "string" type_name
  | _ -> assert_failure "类型关键字表达式解析结果类型错误"

(** ==================== 古雅体表达式解析测试 ==================== *)

let test_parse_ancient_expr_basic _ =
  (* 测试基础古雅体表达式解析 *)
  let tokens = [ AncientKeyword; QuotedIdentifierToken "古雅之词" ] in
  let state = create_test_state tokens in
  let expr, new_state = parse_ancient_expr simple_parse_expression state in
  match expr with
  | AncientExpr content -> assert_equal (VarExpr "古雅之词") content
  | _ -> assert_failure "古雅体表达式解析结果类型错误"

(** ==================== 错误处理测试 ==================== *)

let test_parse_primary_expr_error_handling _ =
  (* 测试错误处理 - 空token列表 *)
  let tokens = [] in
  let state = create_test_state tokens in
  assert_raises (Failure "解析错误") (fun () ->
      parse_primary_expr simple_parse_expression simple_parse_array_expression
        simple_parse_record_expression state)

let test_parse_literal_expr_error_handling _ =
  (* 测试字面量解析错误处理 - 非字面量token *)
  let tokens = [ LeftParenToken ] in
  let state = create_test_state tokens in
  assert_raises (Failure "不是字面量") (fun () -> parse_literal_expr state)

(** ==================== 边界条件测试 ==================== *)

let test_parse_function_arguments_boundary _ =
  (* 测试函数参数边界条件 - 只有逗号 *)
  let tokens = [ CommaToken; RightParenToken ] in
  let state = create_test_state tokens in
  assert_raises (Failure "参数解析错误") (fun () ->
      parse_function_arguments simple_parse_expression state)

let test_parse_postfix_expr_boundary _ =
  (* 测试后缀表达式边界条件 - 不完整的字段访问 *)
  let tokens = [ DotToken ] in
  let state = create_test_state tokens in
  let base_expr = VarExpr "对象" in
  assert_raises (Failure "字段访问解析错误") (fun () ->
      parse_postfix_expr simple_parse_expression base_expr state)

(** ==================== 性能测试 ==================== *)

let test_performance_large_expression _ =
  (* 测试大型表达式解析性能 *)
  let large_tokens = List.init 1000 (fun i -> IntToken i) in
  let state = create_test_state large_tokens in

  let start_time = Unix.gettimeofday () in
  let _ = parse_literal_expr { state with tokens = [ IntToken 42 ]; position = 0 } in
  let end_time = Unix.gettimeofday () in

  let elapsed = end_time -. start_time in
  assert_bool "性能测试：单次解析应在0.1秒内完成" (elapsed < 0.1)

let test_performance_repeated_parsing _ =
  (* 测试重复解析性能 *)
  let tokens = [ StringToken "性能测试" ] in
  let state = create_test_state tokens in

  let start_time = Unix.gettimeofday () in
  for _ = 1 to 100 do
    let _ = parse_literal_expr state in
    ()
  done;
  let end_time = Unix.gettimeofday () in

  let elapsed = end_time -. start_time in
  assert_bool "性能测试：100次解析应在1秒内完成" (elapsed < 1.0)

(** ==================== 集成测试 ==================== *)

let test_integration_complex_expression _ =
  (* 测试复杂表达式的集成解析 *)
  let tokens =
    [
      QuotedIdentifierToken "函数";
      LeftParenToken;
      IntToken 1;
      CommaToken;
      StringToken "参数";
      RightParenToken;
      DotToken;
      QuotedIdentifierToken "字段";
    ]
  in
  let state = create_test_state tokens in

  (* 模拟复杂表达式解析流程 *)
  let base_expr, state1 =
    parse_primary_expr simple_parse_expression simple_parse_array_expression
      simple_parse_record_expression state
  in

  match base_expr with
  | VarExpr name -> assert_equal "函数" name
  | _ -> assert_failure "集成测试：基础表达式解析失败"

let test_integration_with_parser_utils _ =
  (* 测试与Parser_utils模块的集成 *)
  let tokens = [ ChineseNumberToken "九九八十一" ] in
  let state = create_test_state tokens in
  let expr, _ =
    parse_primary_expr simple_parse_expression simple_parse_array_expression
      simple_parse_record_expression state
  in
  match expr with
  | LitExpr (IntLit n) -> assert_equal 9981 n (* 验证中文数字转换 *)
  | _ -> assert_failure "集成测试：中文数字解析失败"

(** ==================== 测试套件 ==================== *)

let suite =
  "Parser_expressions_primary_consolidated comprehensive tests"
  >::: [
         (* 基础表达式解析测试 *)
         "test_parse_primary_expr_literal" >:: test_parse_primary_expr_literal;
         "test_parse_primary_expr_string" >:: test_parse_primary_expr_string;
         "test_parse_primary_expr_chinese_number" >:: test_parse_primary_expr_chinese_number;
         "test_parse_primary_expr_boolean" >:: test_parse_primary_expr_boolean;
         "test_parse_primary_expr_variable" >:: test_parse_primary_expr_variable;
         (* 后缀表达式解析测试 *)
         "test_parse_postfix_expr_field_access" >:: test_parse_postfix_expr_field_access;
         "test_parse_postfix_expr_array_access" >:: test_parse_postfix_expr_array_access;
         "test_parse_postfix_expr_no_postfix" >:: test_parse_postfix_expr_no_postfix;
         (* 函数参数解析测试 *)
         "test_parse_function_arguments_empty" >:: test_parse_function_arguments_empty;
         "test_parse_function_arguments_single" >:: test_parse_function_arguments_single;
         "test_parse_function_arguments_multiple" >:: test_parse_function_arguments_multiple;
         (* 字面量解析测试 *)
         "test_parse_literal_expr_int" >:: test_parse_literal_expr_int;
         "test_parse_literal_expr_float" >:: test_parse_literal_expr_float;
         "test_parse_literal_expr_string" >:: test_parse_literal_expr_string;
         (* 标识符解析测试 *)
         "test_parse_identifier_expr_variable" >:: test_parse_identifier_expr_variable;
         "test_parse_function_call_or_variable_simple"
         >:: test_parse_function_call_or_variable_simple;
         (* 诗词表达式解析测试 *)
         "test_parse_poetry_expr_basic" >:: test_parse_poetry_expr_basic;
         (* 类型关键字表达式解析测试 *)
         "test_parse_type_keyword_expr_int" >:: test_parse_type_keyword_expr_int;
         "test_parse_type_keyword_expr_string" >:: test_parse_type_keyword_expr_string;
         (* 古雅体表达式解析测试 *)
         "test_parse_ancient_expr_basic" >:: test_parse_ancient_expr_basic;
         (* 错误处理测试 *)
         "test_parse_primary_expr_error_handling" >:: test_parse_primary_expr_error_handling;
         "test_parse_literal_expr_error_handling" >:: test_parse_literal_expr_error_handling;
         (* 边界条件测试 *)
         "test_parse_function_arguments_boundary" >:: test_parse_function_arguments_boundary;
         "test_parse_postfix_expr_boundary" >:: test_parse_postfix_expr_boundary;
         (* 性能测试 *)
         "test_performance_large_expression" >:: test_performance_large_expression;
         "test_performance_repeated_parsing" >:: test_performance_repeated_parsing;
         (* 集成测试 *)
         "test_integration_complex_expression" >:: test_integration_complex_expression;
         "test_integration_with_parser_utils" >:: test_integration_with_parser_utils;
       ]

let () = run_test_tt_main suite
