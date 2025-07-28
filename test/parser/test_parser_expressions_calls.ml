(** 函数调用表达式解析器测试套件
   测试覆盖 parser_expressions_calls.ml 模块的所有主要功能
   Author: Alpha, 主要工作代理 - Fix #1615 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer_tokens
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Parser_expressions_calls

(** 测试辅助函数模块 *)
module TestHelpers = struct
  (** 创建基础解析器状态 *)
  let create_parser_state tokens =
    let positioned_tokens = List.map (fun t -> (t, {filename = "test"; line = 1; column = 1})) tokens in
    create_parser_state positioned_tokens

  (** 简单表达式解析器（用于测试依赖） *)
  let rec simple_parse_expr state =
    let token, _ = current_token state in
    match token with
    | IntToken i ->
        let next_state = advance_parser state in
        (LitExpr (IntLit i), next_state)
    | FloatToken f ->
        let next_state = advance_parser state in
        (LitExpr (FloatLit f), next_state)
    | StringToken s ->
        let next_state = advance_parser state in
        (LitExpr (StringLit s), next_state)
    | TrueKeyword ->
        let next_state = advance_parser state in
        (LitExpr (BoolLit true), next_state)
    | FalseKeyword ->
        let next_state = advance_parser state in
        (LitExpr (BoolLit false), next_state)
    | QuotedIdentifierToken name ->
        let next_state = advance_parser state in
        (VarExpr name, next_state)
    | LeftParen | ChineseLeftParen ->
        let st1 = advance_parser state in
        let inner_expr, st2 = simple_parse_expr st1 in
        let st3 = expect_token_punctuation st2 is_right_paren "right parenthesis" in
        (inner_expr, st3)
    | _ -> failwith ("Unexpected token in simple_parse_expr: " ^ show_token token)

  (** 验证解析结果的辅助函数 *)
  let check_parse_result description expected_expr result =
    match result with
    | expr, _state -> check (testable pp_expr (=)) description expected_expr expr
    | exception e -> fail ("Parse failed with exception: " ^ Printexc.to_string e)

  (** 检查是否抛出预期的异常 *)
  let check_parse_error description tokens expected_error_pattern =
    let state = create_parser_state tokens in
    try
      let _ = parse_single_argument simple_parse_expr (List.hd tokens) state in
      fail (description ^ ": Expected error but parsing succeeded")
    with
    | SyntaxError (msg, _) when String.length msg >= String.length expected_error_pattern &&
        String.sub msg 0 (String.length expected_error_pattern) = expected_error_pattern ->
        () (* Expected error occurred *)
    | e -> fail (description ^ ": Unexpected error: " ^ Printexc.to_string e)
end

(** 单个参数解析测试 *)
let test_parse_single_argument () =
  let open TestHelpers in
  
  (* 测试整数参数 *)
  let int_state = create_parser_state [IntToken 42; EOF] in
  let int_result = parse_single_argument simple_parse_expr (IntToken 42) int_state in
  check_parse_result "整数参数解析" (LitExpr (IntLit 42)) int_result;

  (* 测试浮点数参数 *)
  let float_state = create_parser_state [FloatToken 3.14; EOF] in
  let float_result = parse_single_argument simple_parse_expr (FloatToken 3.14) float_state in
  check_parse_result "浮点数参数解析" (LitExpr (FloatLit 3.14)) float_result;

  (* 测试字符串参数 *)
  let string_state = create_parser_state [StringToken "hello"; EOF] in
  let string_result = parse_single_argument simple_parse_expr (StringToken "hello") string_state in
  check_parse_result "字符串参数解析" (LitExpr (StringLit "hello")) string_result;

  (* 测试布尔参数 - true *)
  let bool_true_state = create_parser_state [TrueKeyword; EOF] in
  let bool_true_result = parse_single_argument simple_parse_expr TrueKeyword bool_true_state in
  check_parse_result "布尔true参数解析" (LitExpr (BoolLit true)) bool_true_result;

  (* 测试布尔参数 - false *)
  let bool_false_state = create_parser_state [FalseKeyword; EOF] in
  let bool_false_result = parse_single_argument simple_parse_expr FalseKeyword bool_false_state in
  check_parse_result "布尔false参数解析" (LitExpr (BoolLit false)) bool_false_result;

  (* 测试标识符参数 *)
  let var_state = create_parser_state [QuotedIdentifierToken "x"; EOF] in
  let var_result = parse_single_argument simple_parse_expr (QuotedIdentifierToken "x") var_state in
  check_parse_result "标识符参数解析" (VarExpr "x") var_result

(** 中文数字参数解析测试 *)
let test_chinese_number_argument () =
  let open TestHelpers in

  (* 测试中文数字"一" *)
  let chinese_one_state = create_parser_state [ChineseNumberToken "一"; EOF] in
  let chinese_one_result = parse_single_argument simple_parse_expr (ChineseNumberToken "一") chinese_one_state in
  check_parse_result "中文数字一参数解析" (LitExpr (IntLit 1)) chinese_one_result;

  (* 测试OneKeyword关键字 *)
  let one_keyword_state = create_parser_state [OneKeyword; EOF] in
  let one_keyword_result = parse_single_argument simple_parse_expr OneKeyword one_keyword_state in
  check_parse_result "OneKeyword参数解析" (LitExpr (IntLit 1)) one_keyword_result

(** 括号表达式参数解析测试 *)
let test_parenthesized_argument () =
  let open TestHelpers in

  (* 测试普通括号 *)
  let paren_state = create_parser_state [LeftParen; IntToken 42; RightParen; EOF] in
  let paren_result = parse_single_argument simple_parse_expr LeftParen paren_state in
  check_parse_result "括号表达式参数解析" (LitExpr (IntLit 42)) paren_result;

  (* 测试中文括号 *)
  let chinese_paren_state = create_parser_state [ChineseLeftParen; StringToken "test"; ChineseRightParen; EOF] in
  let chinese_paren_result = parse_single_argument simple_parse_expr ChineseLeftParen chinese_paren_state in
  check_parse_result "中文括号表达式参数解析" (LitExpr (StringLit "test")) chinese_paren_result

(** 函数参数列表解析测试 *)
let test_parse_function_arguments () =
  let open TestHelpers in

  (* 测试空参数列表 *)
  let empty_state = create_parser_state [EOF] in
  let empty_result = parse_function_arguments simple_parse_expr empty_state in
  let expected_empty_args = [] in
  check (list (testable pp_expr (=))) "空参数列表" expected_empty_args (fst empty_result);

  (* 测试单个参数 *)
  let single_state = create_parser_state [IntToken 42; EOF] in
  let single_result = parse_function_arguments simple_parse_expr single_state in
  let expected_single_args = [LitExpr (IntLit 42)] in
  check (list (testable pp_expr (=))) "单个参数列表" expected_single_args (fst single_result);

  (* 测试多个参数 *)
  let multi_state = create_parser_state [IntToken 1; StringToken "hello"; TrueKeyword; EOF] in
  let multi_result = parse_function_arguments simple_parse_expr multi_state in
  let expected_multi_args = [
    LitExpr (IntLit 1);
    LitExpr (StringLit "hello");
    LitExpr (BoolLit true)
  ] in
  check (list (testable pp_expr (=))) "多个参数列表" expected_multi_args (fst multi_result)

(** 函数调用与变量引用区分测试 *)
let test_function_call_or_variable () =
  let open TestHelpers in

  (* 测试函数调用（有参数） *)
  let func_call_state = create_parser_state [IntToken 42; StringToken "world"; EOF] in
  let func_call_result = parse_function_call_or_variable simple_parse_expr "test_func" func_call_state in
  let expected_func_call = FunCallExpr (VarExpr "test_func", [LitExpr (IntLit 42); LitExpr (StringLit "world")]) in
  check_parse_result "函数调用识别" expected_func_call func_call_result;

  (* 测试变量引用（无参数） *)
  let var_ref_state = create_parser_state [EOF] in
  let var_ref_result = parse_function_call_or_variable simple_parse_expr "test_var" var_ref_state in
  let expected_var_ref = VarExpr "test_var" in
  check_parse_result "变量引用识别" expected_var_ref var_ref_result

(** 函数参数token识别测试 *)
let test_is_function_argument_token () =
  (* 测试有效的参数token *)
  check bool "IntToken是参数token" true (is_function_argument_token (IntToken 42));
  check bool "FloatToken是参数token" true (is_function_argument_token (FloatToken 3.14));
  check bool "StringToken是参数token" true (is_function_argument_token (StringToken "test"));
  check bool "TrueKeyword是参数token" true (is_function_argument_token TrueKeyword);
  check bool "FalseKeyword是参数token" true (is_function_argument_token FalseKeyword);
  check bool "QuotedIdentifierToken是参数token" true (is_function_argument_token (QuotedIdentifierToken "x"));
  check bool "LetKeyword是参数token" true (is_function_argument_token LetKeyword);
  check bool "OneKeyword是参数token" true (is_function_argument_token OneKeyword);
  
  (* 测试无效的参数token *)
  check bool "Plus不是参数token" false (is_function_argument_token Plus);
  check bool "EOF不是参数token" false (is_function_argument_token EOF);
  check bool "Comma不是参数token" false (is_function_argument_token Comma)

(** 安全函数调用解析测试 *)
let test_parse_function_call_safe () =
  let open TestHelpers in

  (* 测试正常的安全解析 *)
  let normal_state = create_parser_state [IntToken 42; EOF] in
  let normal_result = parse_function_call_safe simple_parse_expr "safe_func" normal_state in
  let expected_normal = FunCallExpr (VarExpr "safe_func", [LitExpr (IntLit 42)]) in
  check_parse_result "安全函数调用解析" expected_normal normal_result

(** 函数调用上下文解析测试 *)
let test_parse_function_call_context () =
  let open TestHelpers in

  (* 测试上下文中的函数调用 *)
  let context_state = create_parser_state [FloatToken 2.5; TrueKeyword; EOF] in
  let context_result = parse_function_call_context simple_parse_expr "context_func" context_state in
  let expected_context = FunCallExpr (VarExpr "context_func", [LitExpr (FloatLit 2.5); LitExpr (BoolLit true)]) in
  check_parse_result "上下文函数调用解析" expected_context context_result

(** 错误处理测试 *)
let test_error_handling () =
  let open TestHelpers in

  (* 测试无效参数token错误 *)
  check_parse_error "无效参数token错误" [Plus; EOF] "意外的词元"

(** 复杂函数调用场景测试 *)
let test_complex_function_calls () =
  let open TestHelpers in

  (* 测试简单函数调用 *)  
  let simple_func_state = create_parser_state [IntToken 10; StringToken "nested"; EOF] in
  let simple_func_result = parse_function_call_or_variable simple_parse_expr "simple_func" simple_func_state in
  let expected_simple_func = FunCallExpr (VarExpr "simple_func", [LitExpr (IntLit 10); LitExpr (StringLit "nested")]) in
  check_parse_result "简单函数调用" expected_simple_func simple_func_result;

  (* 测试简化的中文参数函数调用 *)
  let chinese_state = create_parser_state [ChineseNumberToken "三"; OneKeyword; EOF] in
  let chinese_result = parse_function_call_or_variable simple_parse_expr "chinese_func" chinese_state in
  let expected_chinese = FunCallExpr (VarExpr "chinese_func", [
    LitExpr (IntLit 3);
    LitExpr (IntLit 1)
  ]) in
  check_parse_result "中文特色函数调用" expected_chinese chinese_result

(** 边界条件测试 *)
let test_edge_cases () =
  let open TestHelpers in

  (* 测试只有OneKeyword的函数调用 *)
  let one_only_state = create_parser_state [OneKeyword; EOF] in
  let one_only_result = parse_function_call_or_variable simple_parse_expr "one_func" one_only_state in
  let expected_one_only = FunCallExpr (VarExpr "one_func", [LitExpr (IntLit 1)]) in
  check_parse_result "只有OneKeyword的函数调用" expected_one_only one_only_result;

  (* 测试大量参数的函数调用 *)
  let many_args_tokens = [
    IntToken 1; IntToken 2; IntToken 3; IntToken 4; IntToken 5;
    StringToken "a"; StringToken "b"; TrueKeyword; FalseKeyword; EOF
  ] in
  let many_args_state = create_parser_state many_args_tokens in
  let many_args_result = parse_function_call_or_variable simple_parse_expr "many_args_func" many_args_state in
  let expected_many_args = FunCallExpr (VarExpr "many_args_func", [
    LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3);
    LitExpr (IntLit 4); LitExpr (IntLit 5);
    LitExpr (StringLit "a"); LitExpr (StringLit "b");
    LitExpr (BoolLit true); LitExpr (BoolLit false)
  ]) in
  check_parse_result "大量参数函数调用" expected_many_args many_args_result

(** 主测试套件 *)
let () =
  run "Parser_expressions_calls Tests" [
    ("单个参数解析", [
      test_case "基础参数类型解析" `Quick test_parse_single_argument;
      test_case "中文数字参数解析" `Quick test_chinese_number_argument;
      test_case "括号表达式参数解析" `Quick test_parenthesized_argument;
    ]);
    ("函数参数列表解析", [
      test_case "参数列表解析功能" `Quick test_parse_function_arguments;
    ]);
    ("函数调用识别", [
      test_case "函数调用与变量引用区分" `Quick test_function_call_or_variable;
      test_case "函数参数token识别" `Quick test_is_function_argument_token;
    ]);
    ("安全解析功能", [
      test_case "安全函数调用解析" `Quick test_parse_function_call_safe;
      test_case "上下文函数调用解析" `Quick test_parse_function_call_context;
    ]);
    ("错误处理", [
      test_case "错误处理机制" `Quick test_error_handling;
    ]);
    ("复杂场景", [
      test_case "复杂函数调用场景" `Quick test_complex_function_calls;
      test_case "边界条件处理" `Quick test_edge_cases;
    ]);
  ]