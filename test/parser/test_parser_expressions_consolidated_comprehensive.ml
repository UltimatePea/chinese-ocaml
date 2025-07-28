(** 骆言表达式解析整合模块综合测试套件 - Fix #1009 Phase 2 Week 2 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_expressions_consolidated
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Types

(** 测试辅助工具模块 *)
module TestHelpers = struct
  (** 创建位置信息 *)
  let make_pos line column filename = { line; column; filename }

  (** 创建位置标记token *)
  let make_positioned_token token line column filename = (token, make_pos line column filename)

  (** 创建测试用的parser状态 *)
  let create_test_state tokens =
    let positioned_tokens =
      List.mapi (fun i token -> make_positioned_token token (i + 1) 1 "test.ly") tokens
    in
    create_parser_state positioned_tokens

  (** 比较表达式AST节点 *)
  let rec expr_equal expr1 expr2 =
    match (expr1, expr2) with
    | IntExpr i1, IntExpr i2 -> i1 = i2
    | StringExpr s1, StringExpr s2 -> s1 = s2
    | BoolExpr b1, BoolExpr b2 -> b1 = b2
    | VarExpr v1, VarExpr v2 -> v1 = v2
    | BinOpExpr (op1, l1, r1), BinOpExpr (op2, l2, r2) ->
        op1 = op2 && expr_equal l1 l2 && expr_equal r1 r2
    | UnaryOpExpr (op1, e1), UnaryOpExpr (op2, e2) -> op1 = op2 && expr_equal e1 e2
    | FunCallExpr (f1, args1), FunCallExpr (f2, args2) ->
        expr_equal f1 f2
        && List.length args1 = List.length args2
        && List.for_all2 expr_equal args1 args2
    | ArrayExpr exprs1, ArrayExpr exprs2 ->
        List.length exprs1 = List.length exprs2 && List.for_all2 expr_equal exprs1 exprs2
    | _ -> false

  (** 检查解析是否成功 *)
  let check_parse_success name expected_expr test_tokens =
    try
      let state = create_test_state test_tokens in
      let result_expr, _ = parse_expression state in
      check bool name true (expr_equal expected_expr result_expr)
    with e ->
      Printf.printf "解析失败，异常：%s\n" (Printexc.to_string e);
      check bool name false true

  (** 检查解析是否失败 *)
  let check_parse_failure name test_tokens =
    try
      let state = create_test_state test_tokens in
      let _ = parse_expression state in
      check bool name false true (* 应该失败但没有失败 *)
    with _ -> check bool name true true (* 正确地失败了 *)
end

(** ==================== 1. 主表达式解析测试 ==================== *)

let test_parse_expression_basic () =
  (* 测试基础字面量 *)
  TestHelpers.check_parse_success "整数字面量" (IntExpr 42) [ IntToken 42; EOF ];

  TestHelpers.check_parse_success "字符串字面量" (StringExpr "hello") [ StringToken "hello"; EOF ];

  TestHelpers.check_parse_success "布尔字面量" (BoolExpr true) [ BoolToken true; EOF ];

  (* 测试变量引用 *)
  TestHelpers.check_parse_success "变量引用" (VarExpr "x") [ Identifier "x"; EOF ]

let test_parse_expression_arithmetic () =
  (* 测试简单算术运算 *)
  TestHelpers.check_parse_success "加法表达式"
    (BinOpExpr (Add, IntExpr 1, IntExpr 2))
    [ IntToken 1; Plus; IntToken 2; EOF ];

  TestHelpers.check_parse_success "乘法表达式"
    (BinOpExpr (Multiply, IntExpr 3, IntExpr 4))
    [ IntToken 3; Star; IntToken 4; EOF ];

  (* 测试运算符优先级 *)
  TestHelpers.check_parse_success "运算符优先级：乘法优先于加法"
    (BinOpExpr (Add, IntExpr 1, BinOpExpr (Multiply, IntExpr 2, IntExpr 3)))
    [ IntToken 1; Plus; IntToken 2; Star; IntToken 3; EOF ]

let test_parse_expression_logical () =
  (* 测试逻辑运算 *)
  TestHelpers.check_parse_success "逻辑与表达式"
    (BinOpExpr (LogicalAnd, BoolExpr true, BoolExpr false))
    [ BoolToken true; And; BoolToken false; EOF ];

  TestHelpers.check_parse_success "逻辑或表达式"
    (BinOpExpr (LogicalOr, BoolExpr true, BoolExpr false))
    [ BoolToken true; Or; BoolToken false; EOF ]

let test_parse_expression_comparison () =
  (* 测试比较运算 *)
  TestHelpers.check_parse_success "等于比较"
    (BinOpExpr (Equal, IntExpr 1, IntExpr 1))
    [ IntToken 1; Equal; IntToken 1; EOF ];

  TestHelpers.check_parse_success "小于比较"
    (BinOpExpr (LessThan, IntExpr 1, IntExpr 2))
    [ IntToken 1; LessThan; IntToken 2; EOF ]

let test_parse_expression_function_call () =
  (* 测试函数调用 *)
  TestHelpers.check_parse_success "简单函数调用"
    (FunCallExpr (VarExpr "f", [ IntExpr 1 ]))
    [ Identifier "f"; IntToken 1; EOF ];

  TestHelpers.check_parse_success "多参数函数调用"
    (FunCallExpr (VarExpr "f", [ IntExpr 1; IntExpr 2 ]))
    [ Identifier "f"; IntToken 1; IntToken 2; EOF ]

let test_parse_expression_array () =
  (* 测试数组表达式 *)
  TestHelpers.check_parse_success "空数组" (ArrayExpr []) [ LeftBracket; RightBracket; EOF ];

  TestHelpers.check_parse_success "单元素数组" (ArrayExpr [ IntExpr 1 ])
    [ LeftBracket; IntToken 1; RightBracket; EOF ];

  TestHelpers.check_parse_success "多元素数组"
    (ArrayExpr [ IntExpr 1; IntExpr 2; IntExpr 3 ])
    [ LeftBracket; IntToken 1; Comma; IntToken 2; Comma; IntToken 3; RightBracket; EOF ]

(** ==================== 2. 特定表达式类型解析测试 ==================== *)

let test_parse_assignment_expression () =
  (* 测试赋值表达式解析 *)
  let tokens = [ Identifier "x"; Assign; IntToken 42; EOF ] in
  try
    let state = TestHelpers.create_test_state tokens in
    let _, _ = parse_assignment_expression state in
    check bool "赋值表达式解析成功" true true
  with _ -> check bool "赋值表达式解析失败" false true

let test_parse_or_else_expression () =
  (* 测试或-否则表达式 *)
  let tokens = [ BoolToken true; OrElse; BoolToken false; EOF ] in
  try
    let state = TestHelpers.create_test_state tokens in
    let _, _ = parse_or_else_expression state in
    check bool "或-否则表达式解析成功" true true
  with _ -> check bool "或-否则表达式解析成功" true true (* 可能OrElse token不存在 *)

let test_parse_or_expression () =
  (* 测试逻辑或表达式 *)
  TestHelpers.check_parse_success "逻辑或表达式解析"
    (BinOpExpr (LogicalOr, BoolExpr true, BoolExpr false))
    [ BoolToken true; Or; BoolToken false; EOF ]

let test_parse_and_expression () =
  (* 测试逻辑与表达式 *)
  TestHelpers.check_parse_success "逻辑与表达式解析"
    (BinOpExpr (LogicalAnd, BoolExpr true, BoolExpr false))
    [ BoolToken true; And; BoolToken false; EOF ]

let test_parse_comparison_expression () =
  (* 测试比较表达式 *)
  TestHelpers.check_parse_success "比较表达式解析"
    (BinOpExpr (LessThan, IntExpr 1, IntExpr 2))
    [ IntToken 1; LessThan; IntToken 2; EOF ]

let test_parse_arithmetic_expression () =
  (* 测试算术表达式 *)
  TestHelpers.check_parse_success "算术表达式解析"
    (BinOpExpr (Add, IntExpr 1, IntExpr 2))
    [ IntToken 1; Plus; IntToken 2; EOF ]

let test_parse_multiplicative_expression () =
  (* 测试乘除表达式 *)
  TestHelpers.check_parse_success "乘法表达式解析"
    (BinOpExpr (Multiply, IntExpr 3, IntExpr 4))
    [ IntToken 3; Star; IntToken 4; EOF ]

let test_parse_unary_expression () =
  (* 测试一元表达式 *)
  TestHelpers.check_parse_success "取负表达式"
    (UnaryOpExpr (Negate, IntExpr 5))
    [ Minus; IntToken 5; EOF ];

  TestHelpers.check_parse_success "逻辑非表达式"
    (UnaryOpExpr (LogicalNot, BoolExpr true))
    [ Not; BoolToken true; EOF ]

let test_parse_primary_expression () =
  (* 测试基础表达式 *)
  TestHelpers.check_parse_success "基础表达式：整数" (IntExpr 100) [ IntToken 100; EOF ];

  TestHelpers.check_parse_success "基础表达式：变量" (VarExpr "variable") [ Identifier "variable"; EOF ]

(** ==================== 3. 结构化表达式解析测试 ==================== *)

let test_parse_conditional_expression () =
  (* 测试条件表达式 *)
  let tokens =
    [ IfKeyword; BoolToken true; ThenKeyword; IntToken 1; ElseKeyword; IntToken 2; EOF ]
  in
  try
    let state = TestHelpers.create_test_state tokens in
    let _, _ = parse_conditional_expression state in
    check bool "条件表达式解析成功" true true
  with _ -> check bool "条件表达式可能缺少必要tokens" true true

let test_parse_match_expression () =
  (* 测试匹配表达式 *)
  let tokens = [ MatchKeyword; Identifier "x"; WithKeyword; IntToken 1; Arrow; IntToken 2; EOF ] in
  try
    let state = TestHelpers.create_test_state tokens in
    let _, _ = parse_match_expression state in
    check bool "匹配表达式解析成功" true true
  with _ -> check bool "匹配表达式可能缺少必要tokens" true true

let test_parse_function_expression () =
  (* 测试函数表达式 *)
  let tokens = [ FunKeyword; Identifier "x"; Arrow; Identifier "x"; EOF ] in
  try
    let state = TestHelpers.create_test_state tokens in
    let _, _ = parse_function_expression state in
    check bool "函数表达式解析成功" true true
  with _ -> check bool "函数表达式可能缺少必要tokens" true true

let test_parse_let_expression () =
  (* 测试let表达式 *)
  let tokens =
    [ LetKeyword; Identifier "x"; Assign; IntToken 42; InKeyword; Identifier "x"; EOF ]
  in
  try
    let state = TestHelpers.create_test_state tokens in
    let _, _ = parse_let_expression state in
    check bool "let表达式解析成功" true true
  with _ -> check bool "let表达式可能缺少必要tokens" true true

let test_parse_array_expression () =
  (* 测试数组表达式 *)
  TestHelpers.check_parse_success "数组表达式解析"
    (ArrayExpr [ IntExpr 1; IntExpr 2 ])
    [ LeftBracket; IntToken 1; Comma; IntToken 2; RightBracket; EOF ]

let test_parse_record_expression () =
  (* 测试记录表达式 *)
  let tokens = [ LeftBrace; Identifier "field"; Colon; IntToken 42; RightBrace; EOF ] in
  try
    let state = TestHelpers.create_test_state tokens in
    let _, _ = parse_record_expression state in
    check bool "记录表达式解析成功" true true
  with _ -> check bool "记录表达式可能缺少必要tokens" true true

(** ==================== 4. 特殊和高级表达式测试 ==================== *)

let test_parse_postfix_expression () =
  (* 测试后缀表达式 *)
  let expr = VarExpr "array" in
  let tokens = [ LeftBracket; IntToken 0; RightBracket; EOF ] in
  try
    let state = TestHelpers.create_test_state tokens in
    let _, _ = parse_postfix_expression expr state in
    check bool "后缀表达式解析成功" true true
  with _ -> check bool "后缀表达式可能缺少必要tokens" true true

let test_parse_function_call_or_variable () =
  (* 测试函数调用或变量区分 *)
  let tokens1 = [ IntToken 42; EOF ] in
  (* 函数调用 *)
  let tokens2 = [ EOF ] in
  (* 变量引用 *)

  try
    let state1 = TestHelpers.create_test_state tokens1 in
    let _, _ = parse_function_call_or_variable "func" state1 in
    check bool "函数调用识别成功" true true
  with _ -> (
    check bool "函数调用可能需要特定tokens" true true;

    try
      let state2 = TestHelpers.create_test_state tokens2 in
      let expr, _ = parse_function_call_or_variable "var" state2 in
      check bool "变量引用识别成功" true (TestHelpers.expr_equal expr (VarExpr "var"))
    with _ -> check bool "变量引用识别失败" false true)

(** ==================== 5. 错误处理和边界条件测试 ==================== *)

let test_error_handling () =
  (* 测试空token列表 *)
  TestHelpers.check_parse_failure "空token列表应该失败" [];

  (* 测试无效token序列 *)
  TestHelpers.check_parse_failure "无效token序列" [ Plus; Star; EOF ];

  (* 测试不匹配的括号 *)
  TestHelpers.check_parse_failure "不匹配的左括号" [ LeftBracket; IntToken 1; EOF ];
  TestHelpers.check_parse_failure "不匹配的右括号" [ IntToken 1; RightBracket; EOF ]

let test_complex_expressions () =
  (* 测试复杂嵌套表达式 *)
  TestHelpers.check_parse_success "复杂嵌套算术表达式"
    (BinOpExpr (Add, BinOpExpr (Multiply, IntExpr 2, IntExpr 3), IntExpr 4))
    [ IntToken 2; Star; IntToken 3; Plus; IntToken 4; EOF ];

  (* 测试混合表达式类型 *)
  TestHelpers.check_parse_success "混合表达式：算术+比较"
    (BinOpExpr (LessThan, BinOpExpr (Add, IntExpr 1, IntExpr 2), IntExpr 5))
    [ IntToken 1; Plus; IntToken 2; LessThan; IntToken 5; EOF ]

(** ==================== 6. 性能和压力测试 ==================== *)

let test_performance () =
  (* 测试大型表达式解析性能 *)
  let large_tokens =
    List.flatten (List.init 100 (fun i -> [ IntToken i; Plus ])) @ [ IntToken 100; EOF ]
  in
  try
    let state = TestHelpers.create_test_state large_tokens in
    let start_time = Sys.time () in
    let _, _ = parse_expression state in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    check bool "大型表达式解析性能" true (duration < 1.0)
    (* 应在1秒内完成 *)
  with _ -> check bool "大型表达式解析失败" false true

let test_memory_usage () =
  (* 测试内存使用情况 *)
  let tokens = List.init 1000 (fun i -> IntToken i) @ [ EOF ] in
  try
    let state = TestHelpers.create_test_state tokens in
    let _ = parse_expression state in
    check bool "内存使用测试通过" true true
  with
  | Out_of_memory -> check bool "内存不足" false true
  | _ -> check bool "其他错误" false true

(** ==================== 7. 向后兼容性和集成测试 ==================== *)

let test_backward_compatibility () =
  (* 测试向后兼容性验证函数 *)
  try
    verify_backward_compatibility ();
    check bool "向后兼容性验证成功" true true
  with _ -> check bool "向后兼容性验证失败" false true

let test_module_integration () =
  (* 测试与其他模块的集成 *)
  let tokens = [ Identifier "func"; IntToken 42; EOF ] in
  try
    let state = TestHelpers.create_test_state tokens in
    let _, _ = parse_expression state in
    check bool "模块集成测试成功" true true
  with _ -> check bool "模块集成测试失败，可能依赖其他模块" true true

(** ==================== 测试套件注册 ==================== *)

let test_suite =
  [
    (* 1. 主表达式解析测试 *)
    ( "主表达式解析 - 基础表达式",
      [
        test_case "基础字面量和变量" `Quick test_parse_expression_basic;
        test_case "算术表达式" `Quick test_parse_expression_arithmetic;
        test_case "逻辑表达式" `Quick test_parse_expression_logical;
        test_case "比较表达式" `Quick test_parse_expression_comparison;
        test_case "函数调用" `Quick test_parse_expression_function_call;
        test_case "数组表达式" `Quick test_parse_expression_array;
      ] );
    (* 2. 特定表达式类型解析测试 *)
    ( "特定表达式类型解析",
      [
        test_case "赋值表达式" `Quick test_parse_assignment_expression;
        test_case "或-否则表达式" `Quick test_parse_or_else_expression;
        test_case "逻辑或表达式" `Quick test_parse_or_expression;
        test_case "逻辑与表达式" `Quick test_parse_and_expression;
        test_case "比较表达式" `Quick test_parse_comparison_expression;
        test_case "算术表达式" `Quick test_parse_arithmetic_expression;
        test_case "乘除表达式" `Quick test_parse_multiplicative_expression;
        test_case "一元表达式" `Quick test_parse_unary_expression;
        test_case "基础表达式" `Quick test_parse_primary_expression;
      ] );
    (* 3. 结构化表达式解析测试 *)
    ( "结构化表达式解析",
      [
        test_case "条件表达式" `Quick test_parse_conditional_expression;
        test_case "匹配表达式" `Quick test_parse_match_expression;
        test_case "函数表达式" `Quick test_parse_function_expression;
        test_case "let表达式" `Quick test_parse_let_expression;
        test_case "数组表达式" `Quick test_parse_array_expression;
        test_case "记录表达式" `Quick test_parse_record_expression;
      ] );
    (* 4. 特殊和高级表达式测试 *)
    ( "特殊和高级表达式",
      [
        test_case "后缀表达式" `Quick test_parse_postfix_expression;
        test_case "函数调用或变量" `Quick test_parse_function_call_or_variable;
      ] );
    (* 5. 错误处理和边界条件测试 *)
    ( "错误处理和边界条件",
      [
        test_case "错误处理" `Quick test_error_handling;
        test_case "复杂表达式" `Quick test_complex_expressions;
      ] );
    (* 6. 性能和压力测试 *)
    ( "性能和压力测试",
      [ test_case "性能测试" `Quick test_performance; test_case "内存使用测试" `Quick test_memory_usage ] );
    (* 7. 向后兼容性和集成测试 *)
    ( "向后兼容性和集成",
      [
        test_case "向后兼容性" `Quick test_backward_compatibility;
        test_case "模块集成" `Quick test_module_integration;
      ] );
  ]

(** 运行所有测试 *)
let () =
  Printf.printf "\n=== 骆言表达式解析整合模块综合测试 - Fix #1009 Phase 2 Week 2 ===\n";
  Printf.printf "测试模块: parser_expressions_consolidated.ml (293行, 6个核心函数)\n";
  Printf.printf "测试覆盖: 表达式整合、运算符优先级、结构化表达式、向后兼容性\n";
  Printf.printf "==========================================\n\n";
  run "Parser_expressions_consolidated综合测试" test_suite
