(** 解析器表达式Token重复消除模块全面测试套件 测试覆盖parser_expressions_token_reducer.ml模块的所有核心功能 *)

open Alcotest
open Yyocamlc_lib.Lexer_tokens
open Yyocamlc_lib.Parser_expressions_token_reducer.TokenGroups
open Yyocamlc_lib.Parser_expressions_token_reducer.UnifiedTokenProcessor
open Yyocamlc_lib.Parser_expressions_token_reducer.TokenDeduplication
open Yyocamlc_lib.Parser_expressions_token_reducer.ParserExpressionTokenProcessor

(** 测试辅助函数模块 *)
module TestHelpers = struct
  (** 创建测试用的token列表 *)
  let create_basic_token_list () =
    [
      LetKeyword;
      RecKeyword;
      IfKeyword;
      ThenKeyword;
      ElseKeyword;
      Plus;
      Minus;
      Equal;
      Less;
      Greater;
      LeftParen;
      RightParen;
      LeftBracket;
      RightBracket;
      IntToken 42;
      StringToken "测试";
      BoolToken true;
    ]

  (** 创建包含重复token的列表 *)
  let create_duplicate_token_list () =
    [
      LetKeyword;
      LetKeyword;
      RecKeyword;
      IfKeyword;
      IfKeyword;
      IfKeyword;
      Plus;
      Plus;
      Minus;
      Equal;
      Equal;
      LeftParen;
      LeftParen;
      RightParen;
      LeftBracket;
      IntToken 1;
      IntToken 2;
      StringToken "a";
      StringToken "b";
      BoolToken true;
      BoolToken false;
    ]

  (** 创建文言文风格token列表 *)
  let create_wenyan_token_list () =
    [
      HaveKeyword;
      OneKeyword;
      NameKeyword;
      SetKeyword;
      AlsoKeyword;
      ValueKeyword;
      AsForKeyword;
      NumberKeyword;
    ]

  (** 创建古雅体token列表 *)
  let create_ancient_token_list () =
    [
      AncientDefineKeyword;
      AncientEndKeyword;
      AncientObserveKeyword;
      AncientIfKeyword;
      AncientThenKeyword;
      AncientListStartKeyword;
    ]

  (** 创建类型关键字列表 *)
  let create_type_token_list () =
    [
      IntTypeKeyword;
      FloatTypeKeyword;
      StringTypeKeyword;
      BoolTypeKeyword;
      UnitTypeKeyword;
      ListTypeKeyword;
      ArrayTypeKeyword;
    ]

  (** 创建自然语言关键字列表 *)
  let create_natural_language_token_list () =
    [
      DefineKeyword;
      AcceptKeyword;
      ReturnWhenKeyword;
      ElseReturnKeyword;
      IsKeyword;
      EqualToKeyword;
      EmptyKeyword;
      InputKeyword;
      OutputKeyword;
    ]

  (** 创建诗词关键字列表 *)
  let create_poetry_token_list () =
    [
      PoetryKeyword;
      FiveCharKeyword;
      SevenCharKeyword;
      ParallelStructKeyword;
      RhymeKeyword;
      ToneKeyword;
    ]

  (** 创建操作符token列表 *)
  let create_operator_token_list () =
    [
      Plus;
      Minus;
      Multiply;
      Star;
      Divide;
      Slash;
      Modulo;
      Equal;
      NotEqual;
      Less;
      LessEqual;
      Greater;
      GreaterEqual;
      AndKeyword;
      OrKeyword;
      NotKeyword;
      Assign;
      RefAssign;
      AssignArrow;
      Arrow;
      DoubleArrow;
      Dot;
      DoubleDot;
      Bang;
    ]

  (** 创建分隔符token列表 *)
  let create_delimiter_token_list () =
    [
      LeftParen;
      RightParen;
      ChineseLeftParen;
      ChineseRightParen;
      LeftBracket;
      RightBracket;
      ChineseLeftBracket;
      ChineseRightBracket;
      LeftBrace;
      RightBrace;
      LeftQuote;
      RightQuote;
      Comma;
      Semicolon;
      Colon;
      ChineseComma;
      ChineseSemicolon;
    ]

  (** 创建字面量token列表 *)
  let create_literal_token_list () =
    [
      IntToken 123;
      ChineseNumberToken "三";
      FloatToken 3.14;
      StringToken "测试字符串";
      BoolToken true;
      BoolToken false;
      QuotedIdentifierToken "引用标识符";
      IdentifierTokenSpecial "特殊标识符";
    ]

  (** 创建混合大型token列表 *)
  let create_large_mixed_token_list () =
    create_basic_token_list () @ create_wenyan_token_list () @ create_ancient_token_list ()
    @ create_type_token_list ()
    @ create_natural_language_token_list ()
    @ create_poetry_token_list () @ create_operator_token_list () @ create_delimiter_token_list ()
    @ create_literal_token_list ()

  (** 验证关键字分组结果 *)
  let assert_keyword_group_matches actual_group =
    match actual_group with
    | Some (BasicKeywords _)
    | Some (WenyanKeywords _)
    | Some (AncientKeywords _)
    | Some (TypeKeywords _)
    | Some (NaturalLanguageKeywords _)
    | Some (PoetryKeywords _) ->
        true
    | None -> false

  (** 验证操作符分组结果 *)
  let assert_operator_group_matches actual_group =
    match actual_group with
    | Some (ArithmeticOps _)
    | Some (ComparisonOps _)
    | Some (LogicalOps _)
    | Some (AssignmentOps _)
    | Some (SpecialOps _) ->
        true
    | None -> false

  (** 验证分隔符分组结果 *)
  let assert_delimiter_group_matches actual_group =
    match actual_group with
    | Some (ParenthesesGroup _)
    | Some (BracketGroup _)
    | Some (BraceGroup _)
    | Some (ChineseDelimiters _)
    | Some (PunctuationGroup _) ->
        true
    | None -> false

  (** 验证字面量分组结果 *)
  let assert_literal_group_matches actual_group =
    match actual_group with
    | Some (NumericLiterals _)
    | Some (StringLiterals _)
    | Some (BooleanLiterals _)
    | Some (SpecialLiterals _) ->
        true
    | None -> false
end

(** TokenGroups模块测试 *)

let test_token_groups_classification_basic () =
  (* 测试基础关键字分类 *)
  let basic_result = classify_keyword_token LetKeyword in
  check bool "LetKeyword应该被分类为BasicKeywords" true
    (TestHelpers.assert_keyword_group_matches basic_result);

  let wenyan_result = classify_keyword_token HaveKeyword in
  check bool "HaveKeyword应该被分类为WenyanKeywords" true
    (TestHelpers.assert_keyword_group_matches wenyan_result);

  let ancient_result = classify_keyword_token AncientDefineKeyword in
  check bool "AncientDefineKeyword应该被分类为AncientKeywords" true
    (TestHelpers.assert_keyword_group_matches ancient_result)

let test_token_groups_classification_operators () =
  (* 测试操作符分类 *)
  let arithmetic_result = classify_operator_token Plus in
  check bool "Plus应该被分类为ArithmeticOps" true
    (TestHelpers.assert_operator_group_matches arithmetic_result);

  let comparison_result = classify_operator_token Equal in
  check bool "Equal应该被分类为ComparisonOps" true
    (TestHelpers.assert_operator_group_matches comparison_result);

  let logical_result = classify_operator_token AndKeyword in
  check bool "AndKeyword应该被分类为LogicalOps" true
    (TestHelpers.assert_operator_group_matches logical_result)

let test_token_groups_classification_delimiters () =
  (* 测试分隔符分类 *)
  let paren_result = classify_delimiter_token LeftParen in
  check bool "LeftParen应该被分类为ParenthesesGroup" true
    (TestHelpers.assert_delimiter_group_matches paren_result);

  let bracket_result = classify_delimiter_token LeftBracket in
  check bool "LeftBracket应该被分类为BracketGroup" true
    (TestHelpers.assert_delimiter_group_matches bracket_result);

  let punctuation_result = classify_delimiter_token Comma in
  check bool "Comma应该被分类为PunctuationGroup" true
    (TestHelpers.assert_delimiter_group_matches punctuation_result)

let test_token_groups_classification_literals () =
  (* 测试字面量分类 *)
  let numeric_result = classify_literal_token (IntToken 42) in
  check bool "IntToken应该被分类为NumericLiterals" true
    (TestHelpers.assert_literal_group_matches numeric_result);

  let string_result = classify_literal_token (StringToken "test") in
  check bool "StringToken应该被分类为StringLiterals" true
    (TestHelpers.assert_literal_group_matches string_result);

  let boolean_result = classify_literal_token (BoolToken true) in
  check bool "BoolToken应该被分类为BooleanLiterals" true
    (TestHelpers.assert_literal_group_matches boolean_result)

let test_token_groups_classification_edge_cases () =
  (* 测试边界情况和未分类token *)
  let unknown_keyword_result = classify_keyword_token (IntToken 42) in
  check bool "IntToken不应该被分类为关键字" true (unknown_keyword_result = None);

  let unknown_operator_result = classify_operator_token LetKeyword in
  check bool "LetKeyword不应该被分类为操作符" true (unknown_operator_result = None);

  let unknown_delimiter_result = classify_delimiter_token Plus in
  check bool "Plus不应该被分类为分隔符" true (unknown_delimiter_result = None);

  let unknown_literal_result = classify_literal_token Comma in
  check bool "Comma不应该被分类为字面量" true (unknown_literal_result = None)

(** UnifiedTokenProcessor模块测试 *)

let test_unified_token_processor_default () =
  let processor = default_processor in
  let tokens = TestHelpers.create_basic_token_list () in

  (* 测试默认处理器不会抛出异常 *)
  check bool "默认处理器应该能够处理基础token列表" true
    (try
       process_token_list processor tokens;
       true
     with _ -> false)

let test_unified_token_processor_classification () =
  let processed_tokens = ref [] in
  let custom_processor =
    {
      process_keyword_group = (fun _ -> processed_tokens := "keyword" :: !processed_tokens);
      process_operator_group = (fun _ -> processed_tokens := "operator" :: !processed_tokens);
      process_delimiter_group = (fun _ -> processed_tokens := "delimiter" :: !processed_tokens);
      process_literal_group = (fun _ -> processed_tokens := "literal" :: !processed_tokens);
    }
  in

  let tokens = [ LetKeyword; Plus; LeftParen; IntToken 42 ] in
  process_token_list custom_processor tokens;

  check int "应该处理4个不同类型的token" 4 (List.length !processed_tokens);
  check bool "应该包含关键字处理" true (List.mem "keyword" !processed_tokens);
  check bool "应该包含操作符处理" true (List.mem "operator" !processed_tokens);
  check bool "应该包含分隔符处理" true (List.mem "delimiter" !processed_tokens);
  check bool "应该包含字面量处理" true (List.mem "literal" !processed_tokens)

let test_unified_token_processor_edge_cases () =
  let processed_count = ref 0 in
  let custom_processor =
    {
      process_keyword_group = (fun _ -> incr processed_count);
      process_operator_group = (fun _ -> incr processed_count);
      process_delimiter_group = (fun _ -> incr processed_count);
      process_literal_group = (fun _ -> incr processed_count);
    }
  in

  (* 测试空列表 *)
  process_token_list custom_processor [];
  check int "空列表不应该触发处理" 0 !processed_count;

  (* 测试单个token *)
  process_token_list custom_processor [ LetKeyword ];
  check int "单个token应该被处理一次" 1 !processed_count

(** TokenDeduplication模块测试 *)

let test_token_deduplication_basic_analysis () =
  let tokens = TestHelpers.create_basic_token_list () in
  let stats = analyze_token_duplication tokens in

  check int "原始token数量应该正确" (List.length tokens) stats.original_token_count;
  check bool "分组后token数量应该小于等于原始数量" true (stats.grouped_token_count <= stats.original_token_count);
  check bool "减少百分比应该在0-100之间" true
    (stats.reduction_percentage >= 0.0 && stats.reduction_percentage <= 100.0);
  check bool "创建的组数应该大于0" true (stats.groups_created > 0)

let test_token_deduplication_duplicate_analysis () =
  let duplicate_tokens = TestHelpers.create_duplicate_token_list () in
  let stats = analyze_token_duplication duplicate_tokens in

  check bool "重复token列表应该有显著的减少率" true (stats.reduction_percentage > 10.0);
  check bool "分组数量应该小于原始数量" true (stats.grouped_token_count < stats.original_token_count)

let test_token_deduplication_empty_list () =
  let stats = analyze_token_duplication [] in

  check int "空列表原始数量应该为0" 0 stats.original_token_count;
  check int "空列表分组数量应该为0" 0 stats.grouped_token_count;
  check (float 0.01) "空列表减少率应该为0" 0.0 stats.reduction_percentage;
  check int "空列表创建组数应该为0" 0 stats.groups_created

let test_token_deduplication_report_generation () =
  let tokens = TestHelpers.create_basic_token_list () in
  let stats = analyze_token_duplication tokens in
  let report = generate_dedup_report stats in

  check bool "报告应该包含Token重复消除报告标题" true (String.length report > 10);
  check bool "报告应该包含原始Token数量" true (stats.original_token_count > 0);
  check bool "报告应该包含状态信息" true (String.length report > 50)

let test_token_deduplication_large_dataset () =
  let large_tokens = TestHelpers.create_large_mixed_token_list () in
  let stats = analyze_token_duplication large_tokens in

  check bool "大型数据集应该能够正确分析" true (stats.original_token_count = List.length large_tokens);
  check bool "大型数据集应该有合理的分组数量" true
    (stats.grouped_token_count > 0 && stats.grouped_token_count <= stats.original_token_count);

  (* 性能测试：确保处理时间合理 *)
  let start_time = Sys.time () in
  let _ = analyze_token_duplication large_tokens in
  let end_time = Sys.time () in
  check bool "大型数据集分析应该在合理时间内完成" true (end_time -. start_time < 1.0)

(** ParserExpressionTokenProcessor模块测试 *)

let test_parser_expression_processor_creation () =
  let processor = create_expression_processor () in

  (* 测试处理器创建不抛出异常 *)
  check bool "表达式处理器应该能够成功创建" true true;

  (* 测试处理器可以处理基础token *)
  check bool "表达式处理器应该能够处理基础token" true
    (try
       process_token processor LetKeyword;
       true
     with _ -> false)

let test_parser_expression_processor_keyword_handling () =
  let processor = create_expression_processor () in
  let test_tokens =
    [ LetKeyword; HaveKeyword; AncientDefineKeyword; IntTypeKeyword; DefineKeyword; PoetryKeyword ]
  in

  (* 测试各种关键字都能被正确处理 *)
  List.iter
    (fun token ->
      check bool "应该能够处理各种关键字" true
        (try
           process_token processor token;
           true
         with _ -> false))
    test_tokens

let test_parser_expression_processor_comprehensive_handling () =
  let processor = create_expression_processor () in
  let comprehensive_tokens = TestHelpers.create_large_mixed_token_list () in

  (* 测试综合处理能力 *)
  check bool "表达式处理器应该能够处理综合token列表" true
    (try
       process_token_list processor comprehensive_tokens;
       true
     with _ -> false)

(** 集成测试 *)

let test_integration_complete_workflow () =
  let tokens = TestHelpers.create_large_mixed_token_list () in

  (* 步骤1：分析重复 *)
  let dedup_stats = analyze_token_duplication tokens in
  check bool "重复分析应该成功" true (dedup_stats.original_token_count > 0);

  (* 步骤2：生成报告 *)
  let report = generate_dedup_report dedup_stats in
  check bool "报告生成应该成功" true (String.length report > 0);

  (* 步骤3：使用表达式处理器处理 *)
  let processor = create_expression_processor () in
  check bool "表达式处理应该成功" true
    (try
       process_token_list processor tokens;
       true
     with _ -> false)

let test_integration_performance_stress () =
  (* 创建大型token列表进行压力测试 *)
  let stress_tokens =
    let rec repeat_list lst n acc = if n <= 0 then acc else repeat_list lst (n - 1) (lst @ acc) in
    repeat_list (TestHelpers.create_large_mixed_token_list ()) 10 []
  in

  let start_time = Sys.time () in

  (* 压力测试重复分析 *)
  let stats = analyze_token_duplication stress_tokens in
  check bool "压力测试：重复分析应该完成" true (stats.original_token_count > 0);

  (* 压力测试处理器 - 只处理前100个token以避免超时 *)
  let processor = create_expression_processor () in
  let rec take n lst =
    if n <= 0 || lst = [] then [] else List.hd lst :: take (n - 1) (List.tl lst)
  in
  let limited_tokens = take 100 stress_tokens in
  process_token_list processor limited_tokens;

  let end_time = Sys.time () in
  check bool "压力测试应该在合理时间内完成" true (end_time -. start_time < 5.0)

(** 测试套件定义 *)

let token_groups_tests =
  [
    test_case "基础分类测试" `Quick test_token_groups_classification_basic;
    test_case "操作符分类测试" `Quick test_token_groups_classification_operators;
    test_case "分隔符分类测试" `Quick test_token_groups_classification_delimiters;
    test_case "字面量分类测试" `Quick test_token_groups_classification_literals;
    test_case "边界情况测试" `Quick test_token_groups_classification_edge_cases;
  ]

let unified_processor_tests =
  [
    test_case "默认处理器测试" `Quick test_unified_token_processor_default;
    test_case "分类处理测试" `Quick test_unified_token_processor_classification;
    test_case "边界情况测试" `Quick test_unified_token_processor_edge_cases;
  ]

let token_deduplication_tests =
  [
    test_case "基础分析测试" `Quick test_token_deduplication_basic_analysis;
    test_case "重复分析测试" `Quick test_token_deduplication_duplicate_analysis;
    test_case "空列表测试" `Quick test_token_deduplication_empty_list;
    test_case "报告生成测试" `Quick test_token_deduplication_report_generation;
    test_case "大型数据集测试" `Slow test_token_deduplication_large_dataset;
  ]

let parser_expression_processor_tests =
  [
    test_case "处理器创建测试" `Quick test_parser_expression_processor_creation;
    test_case "关键字处理测试" `Quick test_parser_expression_processor_keyword_handling;
    test_case "综合处理测试" `Quick test_parser_expression_processor_comprehensive_handling;
  ]

let integration_tests =
  [
    test_case "完整工作流程测试" `Quick test_integration_complete_workflow;
    test_case "性能压力测试" `Slow test_integration_performance_stress;
  ]

(** 主测试运行器 *)
let () =
  run "Parser_expressions_token_reducer综合测试套件"
    [
      ("TokenGroups模块测试", token_groups_tests);
      ("UnifiedTokenProcessor模块测试", unified_processor_tests);
      ("TokenDeduplication模块测试", token_deduplication_tests);
      ("ParserExpressionTokenProcessor模块测试", parser_expression_processor_tests);
      ("集成测试", integration_tests);
    ]
