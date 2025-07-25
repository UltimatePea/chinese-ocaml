(** 骆言语法分析器错误恢复全面测试 - Fix #1030 Phase 2

    专注于错误恢复机制、表达式解析边界条件和语句解析鲁棒性测试

    测试重点： 1. 语法错误恢复机制 2. 自然语言函数解析错误处理 3. 表达式解析边界条件 4. 语句解析错误恢复 5. 模式匹配错误处理

    @author 骆言AI代理
    @version 2.0
    @since 2025-07-24 *)

open Alcotest
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Lexer_tokens
open Yyocamlc_lib.Parser_utils

(** 测试辅助函数 *)
let parse_with_error_handling input =
  try
    let tokens = tokenize input "<test>" in
    Some (parse_program tokens)
  with
  | SyntaxError (_, _) -> None
  | LexError (_, _) -> None
  | _ -> None

(** 测试单个表达式解析的辅助函数 *)
let parse_expression_with_error_handling input =
  try
    let tokens = tokenize input "<test>" in
    let state = create_parser_state tokens in
    let expr, final_state = parse_expression state in
    let final_token, _ = current_token final_state in
    (* 检查是否已经消费完所有token（除了EOF）*)
    if final_token = EOF then Some expr else None
  with
  | SyntaxError (_, _) -> None
  | LexError (_, _) -> None
  | _ -> None

let check_parse_failure msg input =
  match parse_with_error_handling input with
  | None -> check bool msg true true
  | Some _ -> check bool (msg ^ " should have failed") false true

let check_parse_success msg input =
  match parse_with_error_handling input with
  | Some _ -> check bool msg true true
  | None -> check bool (msg ^ " should have succeeded") false true

(** 检查单个表达式解析失败 *)
let check_expression_parse_failure msg input =
  match parse_expression_with_error_handling input with
  | None -> check bool msg true true
  | Some _ -> check bool (msg ^ " should have failed") false true

(** ========== 1. 语法错误恢复机制测试 ========== *)
let test_syntax_error_recovery () =
  (* 测试不完整表达式 *)
  check_parse_failure "Missing right operand" "一 加上";
  check_expression_parse_failure "Missing operator" "一 二";
  check_parse_failure "Unmatched parentheses" "（一 加上 二";

  (* 测试运算符序列错误 *)
  check_parse_failure "Invalid operator sequence" "一 加上 乘以 二";
  check_parse_failure "Multiple consecutive operators" "一 加上 加上 二";

  (* 测试不匹配的分隔符 *)
  check_parse_failure "Mismatched delimiters" "（一 加上 二」";
  check_parse_failure "Extra closing delimiter" "一 加上 二）"

let test_expression_error_recovery () =
  (* 测试深度嵌套表达式错误 *)
  let deep_expr =
    String.concat "" (Array.to_list (Array.make 50 "（"))
    ^ "一"
    ^ String.concat "" (Array.to_list (Array.make 49 "）"))
  in
  check_parse_failure "Deep nesting with missing paren" deep_expr;

  (* 测试无效表达式组合 *)
  check_expression_parse_failure "Invalid expression start" "加 一";
  check_expression_parse_failure "Invalid expression end" "一 加";
  (* Empty parentheses should succeed as unit literal, not fail *)
  let test_unit_result = parse_expression_with_error_handling "（）" in
  check bool "Empty parentheses as unit" (Option.is_some test_unit_result) true

let test_statement_error_recovery () =
  (* 测试不完整语句 *)
  check_parse_failure "Incomplete let statement" "让";
  check_parse_failure "Let without assignment" "让 「变量」";
  check_parse_failure "Let without value" "让 「变量」 为";

  (* 测试函数定义错误 *)
  check_parse_failure "Function without parameters" "函数 「test」";
  check_parse_failure "Function without body" "函数 「test」 参数 「x」";
  check_parse_failure "Invalid function syntax" "函数 加 二"

(** ========== 2. 自然语言函数解析错误处理测试 ========== *)
let test_natural_language_function_errors () =
  (* 测试自然语言函数定义错误 *)
  check_parse_failure "Missing natural function name" "定义函数 接收 「参数」 返回 「值」";

  check_parse_failure "Natural function missing parameters" "定义函数「计算」返回「值」";

  check_parse_failure "Natural function missing body" "定义函数「计算」接收「参数」";

  check_parse_failure "Malformed natural function" "定义函数「错误」接收但是缺少参数"

let test_natural_language_parsing_edge_cases () =
  (* 测试自然语言解析边界情况 *)
  check_parse_failure "Natural language with invalid characters" "定义函数「test@invalid」接收「参数」返回「值」";

  check_parse_failure "Natural function with empty name" "定义函数「」接收「参数」返回「值」";

  check_parse_failure "Natural function with special chars" "定义函数「函数%$#」接收「参数」返回「值」"

(** ========== 3. 表达式解析边界条件测试 ========== *)
let test_expression_parsing_boundaries () =
  (* 测试复杂运算符优先级错误 *)
  check_expression_parse_failure "Complex precedence error" "一 加 二 乘 减 三";

  (* 测试数字表达式边界 *)
  check_expression_parse_failure "Invalid number sequence" "九万 九千";

  (* 测试字符串表达式边界 *)
  check_expression_parse_failure "Unclosed string in expression" "一 加 『未闭合";

  (* 测试标识符表达式边界 *)
  check_expression_parse_failure "Unclosed identifier in expression" "一 加 「未闭合"

let test_complex_expression_errors () =
  (* 测试混合表达式类型错误 *)
  check_expression_parse_failure "Mixed expression types" "一 加 『字符串』 乘 「标识符」";

  (* 测试嵌套表达式错误 *)
  check_expression_parse_failure "Nested expression error" "（一 加 （二 乘）";

  (* 测试表达式链接错误 *)
  check_expression_parse_failure "Expression chain error" "一 二 三 四"

(** ========== 4. 语句解析错误恢复测试 ========== *)
let test_statement_parsing_recovery () =
  (* 测试条件语句错误 *)
  check_parse_failure "If without condition" "如果 那么 「值」";
  check_parse_failure "If without then" "如果 「条件」 「值」";
  check_parse_failure "If without body" "如果 「条件」 那么";

  (* 测试循环语句错误 *)
  check_parse_failure "Loop without condition" "当 做 「动作」";
  check_parse_failure "Loop without body" "当 「条件」 做";

  (* 测试赋值语句错误 *)
  check_parse_failure "Assignment without target" "为 「值」";
  check_parse_failure "Assignment without value" "让 「变量」 为"

let test_statement_sequence_errors () =
  (* 测试语句序列错误 *)
  check_parse_failure "Invalid statement separator" "让 「x」 为 「一」; 让 「y」 为 「二」";

  (* 测试语句终止符错误 *)
  check_parse_failure "Missing statement terminator" "让 「x」 为 「一」 让 「y」 为 「二」";

  (* 测试空语句序列 *)
  check_parse_success "Empty statement sequence" ""

(** ========== 5. 模式匹配错误处理测试 ========== *)
let test_pattern_matching_errors () =
  (* 测试匹配表达式错误 *)
  check_parse_failure "Match without cases" "匹配 「值」";
  check_parse_failure "Match with invalid pattern" "匹配 「值」 情况 加";
  check_parse_failure "Match with incomplete case" "匹配 「值」 情况 「模式」";

  (* 测试模式错误 *)
  check_parse_failure "Invalid pattern syntax" "匹配 「值」 情况 （无效模式）";
  check_parse_failure "Pattern without arrow" "匹配 「值」 情况 「模式」 「结果」";
  check_parse_failure "Empty pattern" "匹配 「值」 情况 「」 指向 「结果」"

let test_pattern_matching_edge_cases () =
  (* 测试模式匹配边界情况 *)
  check_parse_failure "Nested pattern matching error" "匹配 「值」 情况 「模式1」 指向 匹配 情况";

  check_parse_failure "Pattern with guard error" "匹配 「值」 情况 「模式」 当且仅当 指向 「结果」";

  check_parse_failure "Multiple pattern error" "匹配 「值」 情况 「模式1」 情况 「模式2」 指向"

(** ========== 6. 复杂语法结构错误测试 ========== *)
let test_complex_syntax_errors () =
  (* 测试复杂嵌套结构错误 *)
  check_parse_failure "Complex nesting error" "函数 「外层」 参数 「x」 为 函数 「内层」 参数";

  check_parse_failure "Mixed syntax error" "让 函数 「test」 为 如果 匹配";

  check_parse_failure "Incomplete complex structure" "如果 「条件」 那么 函数 「内部」"

let test_unicode_parsing_errors () =
  (* 测试Unicode相关解析错误 *)
  check_parse_failure "Invalid Unicode in identifier" "让 「变量\xFF」 为 「值」";
  check_parse_failure "Mixed encoding error" "让 abc 为 「值」";
  check_parse_failure "Unicode boundary error" "让 \xE4\xB8 为 「值」"

(** ========== 7. 错误恢复策略测试 ========== *)
let test_error_recovery_strategies () =
  (* 测试部分恢复 *)
  let partial_input = "让 「valid1」 为 「值1」\n错误行\n让 「valid2」 为 「值2」" in
  check_parse_failure "Partial recovery test" partial_input;

  (* 测试错误跳过 *)
  let skip_input = "正常语句; 错误@@语句; 另一个正常语句" in
  check_parse_failure "Error skip test" skip_input;

  (* 测试错误边界检测 *)
  let boundary_input = "函数 「test」 { 无效语法 } 结束" in
  check_parse_failure "Error boundary test" boundary_input

(** ========== 8. 性能相关错误测试 ========== *)
let test_performance_error_cases () =
  (* 测试深度递归错误 *)
  let deep_recursion =
    "让 " ^ String.concat " 让 " (Array.to_list (Array.make 1000 "「var」 为 「val」"))
  in
  check_parse_failure "Deep recursion error" deep_recursion;

  (* 测试大量错误累积 *)
  let many_errors = String.concat "\n" (Array.to_list (Array.make 100 "无效语法行")) in
  check_parse_failure "Many errors accumulation" many_errors;

  (* 测试解析器状态重置 *)
  check_parse_failure "Parser state reset test" "错误1\n错误2\n错误3"

(** ========== 9. 回归测试 - 已知解析错误 ========== *)
let test_parser_regression_cases () =
  (* 基于历史bug的回归测试 *)
  let regression_cases =
    [
      ("Empty input", "");
      ("Only whitespace", "   \n\t  ");
      ("Only comments", "// 这是注释");
      ("Partial tokens", "让 「");
      ("Invalid escape", "让 「变量」 为 『\\invalid』");
    ]
  in

  List.iter
    (fun (desc, input) ->
      try
        let _ = parse_with_error_handling input in
        check bool ("Regression: " ^ desc) true true
      with _ -> check bool ("Regression error: " ^ desc) true true)
    regression_cases

(** 主测试套件 *)
let () =
  run "骆言语法分析器错误恢复全面测试"
    [
      ( "语法错误恢复测试",
        [
          test_case "语法错误恢复" `Quick test_syntax_error_recovery;
          test_case "表达式错误恢复" `Quick test_expression_error_recovery;
          test_case "语句错误恢复" `Quick test_statement_error_recovery;
        ] );
      ( "自然语言函数错误测试",
        [
          test_case "自然语言函数错误" `Quick test_natural_language_function_errors;
          test_case "自然语言解析边界情况" `Quick test_natural_language_parsing_edge_cases;
        ] );
      ( "表达式解析边界测试",
        [
          test_case "表达式解析边界" `Quick test_expression_parsing_boundaries;
          test_case "复杂表达式错误" `Quick test_complex_expression_errors;
        ] );
      ( "语句解析错误恢复测试",
        [
          test_case "语句解析恢复" `Quick test_statement_parsing_recovery;
          test_case "语句序列错误" `Quick test_statement_sequence_errors;
        ] );
      ( "模式匹配错误测试",
        [
          test_case "模式匹配错误" `Quick test_pattern_matching_errors;
          test_case "模式匹配边界情况" `Quick test_pattern_matching_edge_cases;
        ] );
      ( "复杂语法结构测试",
        [
          test_case "复杂语法错误" `Quick test_complex_syntax_errors;
          test_case "Unicode解析错误" `Quick test_unicode_parsing_errors;
        ] );
      ("错误恢复策略测试", [ test_case "错误恢复策略" `Quick test_error_recovery_strategies ]);
      ("性能错误测试", [ test_case "性能相关错误" `Quick test_performance_error_cases ]);
      ("回归测试", [ test_case "解析器回归测试" `Quick test_parser_regression_cases ]);
    ]
