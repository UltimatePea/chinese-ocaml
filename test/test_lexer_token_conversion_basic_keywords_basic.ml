(** 骆言词法分析器基础关键字Token转换模块基础测试
  
    本测试模块提供对 lexer_token_conversion_basic_keywords.ml 的基础测试覆盖。
    
    技术债务改进：测试覆盖率系统性提升计划 - 第四阶段核心组件架构优化 - Fix #954
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-23 *)

open Alcotest
open Yyocamlc_lib
open Lexer_token_conversion_basic_keywords

(** ==================== 基础关键字转换测试 ==================== *)

(** 测试核心关键字的转换 *)
let test_core_keyword_conversions () =
  (* 测试基础控制结构关键字转换能正常执行 *)
  let let_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.LetKeyword in
  check bool "let关键字转换成功" true (let_result = Lexer_tokens.LetKeyword);
  
  let if_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.IfKeyword in
  check bool "if关键字转换成功" true (if_result = Lexer_tokens.IfKeyword);
  
  let then_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.ThenKeyword in
  check bool "then关键字转换成功" true (then_result = Lexer_tokens.ThenKeyword);
  
  let else_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.ElseKeyword in
  check bool "else关键字转换成功" true (else_result = Lexer_tokens.ElseKeyword);
  ()

(** 测试函数相关关键字 *)
let test_function_keywords () =
  let fun_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.FunKeyword in
  check bool "fun关键字转换成功" true (fun_result = Lexer_tokens.FunKeyword);
  
  let rec_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.RecKeyword in
  check bool "rec关键字转换成功" true (rec_result = Lexer_tokens.RecKeyword);
  
  let in_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.InKeyword in
  check bool "in关键字转换成功" true (in_result = Lexer_tokens.InKeyword);
  ()

(** 测试逻辑运算关键字 *)
let test_logical_keywords () =
  let and_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.AndKeyword in
  check bool "and关键字转换成功" true (and_result = Lexer_tokens.AndKeyword);
  
  let or_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.OrKeyword in
  check bool "or关键字转换成功" true (or_result = Lexer_tokens.OrKeyword);
  
  let not_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.NotKeyword in
  check bool "not关键字转换成功" true (not_result = Lexer_tokens.NotKeyword);
  ()

(** 测试匹配相关关键字 *)
let test_match_keywords () =
  let match_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.MatchKeyword in
  check bool "match关键字转换成功" true (match_result = Lexer_tokens.MatchKeyword);
  
  let with_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.WithKeyword in
  check bool "with关键字转换成功" true (with_result = Lexer_tokens.WithKeyword);
  
  let of_result = convert_basic_keyword_token Token_mapping.Token_definitions_unified.OfKeyword in
  check bool "of关键字转换成功" true (of_result = Lexer_tokens.OfKeyword);
  ()

(** ==================== 性能和稳定性测试 ==================== *)

(** 测试转换的一致性 *)
let test_conversion_consistency () =
  (* 测试多次转换同一关键字的一致性 *)
  let token = Token_mapping.Token_definitions_unified.LetKeyword in
  let result1 = convert_basic_keyword_token token in
  let result2 = convert_basic_keyword_token token in
  let result3 = convert_basic_keyword_token token in
  
  check bool "第一次转换结果正确" true (result1 = Lexer_tokens.LetKeyword);
  check bool "第二次转换结果正确" true (result2 = Lexer_tokens.LetKeyword);
  check bool "第三次转换结果正确" true (result3 = Lexer_tokens.LetKeyword);
  ()

(** 测试批量转换的稳定性 *)
let test_batch_conversion_stability () =
  let test_tokens = [
    Token_mapping.Token_definitions_unified.LetKeyword;
    Token_mapping.Token_definitions_unified.IfKeyword;
    Token_mapping.Token_definitions_unified.FunKeyword;
    Token_mapping.Token_definitions_unified.AndKeyword;
    Token_mapping.Token_definitions_unified.MatchKeyword;
  ] in
  
  (* 测试批量转换不会抛出异常 *)
  List.iter (fun token ->
    try
      ignore (convert_basic_keyword_token token);
      check bool "转换不应抛出异常" true true
    with
    | _ -> fail "关键字转换抛出了异常"
  ) test_tokens;
  ()

(** ==================== 边界情况测试 ==================== *)

(** 测试所有可用关键字的转换 *)
let test_available_keywords () =
  (* 测试所有我们知道存在的关键字 *)
  let available_keywords = [
    (Token_mapping.Token_definitions_unified.LetKeyword, "let");
    (Token_mapping.Token_definitions_unified.RecKeyword, "rec");
    (Token_mapping.Token_definitions_unified.InKeyword, "in");
    (Token_mapping.Token_definitions_unified.FunKeyword, "fun");
    (Token_mapping.Token_definitions_unified.IfKeyword, "if");
    (Token_mapping.Token_definitions_unified.ThenKeyword, "then");
    (Token_mapping.Token_definitions_unified.ElseKeyword, "else");
    (Token_mapping.Token_definitions_unified.MatchKeyword, "match");
    (Token_mapping.Token_definitions_unified.WithKeyword, "with");
    (Token_mapping.Token_definitions_unified.OtherKeyword, "other");
    (Token_mapping.Token_definitions_unified.AndKeyword, "and");
    (Token_mapping.Token_definitions_unified.OrKeyword, "or");
    (Token_mapping.Token_definitions_unified.NotKeyword, "not");
    (Token_mapping.Token_definitions_unified.OfKeyword, "of");
  ] in
  
  List.iter (fun (token, description) ->
    try
      let result = convert_basic_keyword_token token in
      (* 验证结果不为空 *)
      ignore result;
      check bool (description ^ "转换成功") true true
    with
    | _ -> fail (description ^ "转换失败")
  ) available_keywords;
  ()

(** ==================== 测试套件定义 ==================== *)

let core_conversion_tests = [
  test_case "核心关键字转换测试" `Quick test_core_keyword_conversions;
  test_case "函数关键字测试" `Quick test_function_keywords;
  test_case "逻辑关键字测试" `Quick test_logical_keywords;
  test_case "匹配关键字测试" `Quick test_match_keywords;
]

let stability_tests = [
  test_case "转换一致性测试" `Quick test_conversion_consistency;
  test_case "批量转换稳定性测试" `Quick test_batch_conversion_stability;
]

let coverage_tests = [
  test_case "可用关键字覆盖测试" `Quick test_available_keywords;
]

(** 主测试运行器 *)
let () = run "Lexer_token_conversion_basic_keywords 基础测试" [
  ("核心转换功能", core_conversion_tests);
  ("稳定性测试", stability_tests);
  ("覆盖率测试", coverage_tests);
]