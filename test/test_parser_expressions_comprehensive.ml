(** 核心表达式解析器全面测试套件
    测试覆盖parser_expressions.ml模块的所有主要功能 *)

open Alcotest
open Yyocamlc_lib.Lexer_tokens
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Parser_expressions

(** 测试辅助函数模块 *)
module TestHelpers = struct
  (** 创建基础解析器状态 *)
  let create_parser_state tokens =
    let token_array = Array.of_list tokens in
    { token_array; current_index = 0; token_count = Array.length token_array }

  (** 创建简单表达式token序列 *)
  let create_simple_expression_tokens () = [
    IntToken 42; Plus; IntToken 10; EOF
  ]

  (** 创建复杂表达式token序列 *)
  let create_complex_expression_tokens () = [
    LeftParen; IntToken 5; Plus; IntToken 3; RightParen; 
    Multiply; IntToken 2; EOF
  ]

  (** 创建条件表达式token序列 *)
  let create_conditional_tokens () = [
    IfKeyword; BoolToken true; ThenKeyword; IntToken 1; 
    ElseKeyword; IntToken 0; EOF
  ]

  (** 创建文言文条件表达式token序列 *)
  let create_wenyan_conditional_tokens () = [
    IfWenyanKeyword; BoolToken true; ThenKeyword; IntToken 1; 
    ElseKeyword; IntToken 0; EOF
  ]

  (** 创建let表达式token序列 *)
  let create_let_expression_tokens () = [
    LetKeyword; IdentifierTokenSpecial "x"; Equal; IntToken 42; 
    InKeyword; IdentifierTokenSpecial "x"; EOF
  ]

  (** 创建文言文let表达式token序列 *)
  let create_wenyan_let_tokens () = [
    HaveKeyword; IdentifierTokenSpecial "x"; SetKeyword; IntToken 42; 
    InKeyword; IdentifierTokenSpecial "x"; EOF
  ]

  (** 创建简单let表达式token序列 *)
  let create_simple_let_tokens () = [
    SetKeyword; IdentifierTokenSpecial "x"; Equal; IntToken 42; EOF
  ]

  (** 创建函数表达式token序列 *)
  let create_function_expression_tokens () = [
    FunKeyword; IdentifierTokenSpecial "x"; Arrow; 
    IdentifierTokenSpecial "x"; Plus; IntToken 1; EOF
  ]

  (** 创建匹配表达式token序列 *)
  let create_match_expression_tokens () = [
    MatchKeyword; IntToken 1; WithKeyword; 
    IntToken 1; Arrow; IntToken 10; EOF
  ]

  (** 创建古雅体匹配表达式token序列 *)
  let create_ancient_match_tokens () = [
    AncientObserveKeyword; IntToken 1; WithKeyword; 
    IntToken 1; Arrow; IntToken 10; EOF
  ]

  (** 创建try表达式token序列 *)
  let create_try_expression_tokens () = [
    TryKeyword; IntToken 42; WithKeyword; 
    IdentifierTokenSpecial "exn"; Arrow; IntToken 0; EOF
  ]

  (** 创建raise表达式token序列 *)
  let create_raise_expression_tokens () = [
    RaiseKeyword; IdentifierTokenSpecial "Not_found"; EOF
  ]

  (** 创建ref表达式token序列 *)
  let create_ref_expression_tokens () = [
    RefKeyword; IntToken 42; EOF
  ]

  (** 创建组合表达式token序列 *)
  let create_combine_expression_tokens () = [
    CombineKeyword; LeftParen; IntToken 1; Comma; IntToken 2; RightParen; EOF
  ]

  (** 创建数组表达式token序列 *)
  let create_array_expression_tokens () = [
    LeftArray; IntToken 1; Semicolon; IntToken 2; RightArray; EOF
  ]

  (** 创建中文数组表达式token序列 *)
  let create_chinese_array_tokens () = [
    ChineseLeftArray; IntToken 1; ChineseSemicolon; IntToken 2; ChineseRightArray; EOF
  ]

  (** 创建记录表达式token序列 *)
  let create_record_expression_tokens () = [
    LeftBrace; IdentifierTokenSpecial "name"; Equal; StringToken "test"; RightBrace; EOF
  ]

  (** 创建自然语言函数定义token序列 *)
  let create_natural_function_tokens () = [
    DefineKeyword; IdentifierTokenSpecial "double"; AcceptKeyword; 
    IdentifierTokenSpecial "x"; ReturnWhenKeyword; IdentifierTokenSpecial "x"; 
    Multiply; IntToken 2; EOF
  ]

  (** 创建诗词关键字表达式token序列 *)
  let create_poetry_expression_tokens () = [
    ParallelStructKeyword; StringToken "春花秋月"; EOF
  ]

  (** 创建类型关键字表达式token序列 *)
  let create_type_keyword_tokens () = [
    IntTypeKeyword; EOF
  ]

  (** 创建字面量表达式token序列 *)
  let create_literal_tokens () = [
    IntToken 123; EOF;
    ChineseNumberToken "五"; EOF;
    FloatToken 3.14; EOF;
    StringToken "你好"; EOF;
    BoolToken true; EOF;
  ]

  (** 创建复合嵌套表达式token序列 *)
  let create_nested_expression_tokens () = [
    LeftParen; IfKeyword; BoolToken true; ThenKeyword; 
    LeftParen; IntToken 1; Plus; IntToken 2; RightParen; 
    ElseKeyword; IntToken 0; RightParen; EOF
  ]

  (** 创建函数调用表达式token序列 *)
  let create_function_call_tokens () = [
    IdentifierTokenSpecial "print"; LeftParen; StringToken "hello"; RightParen; EOF
  ]

  (** 创建标签参数表达式token序列 *)
  let create_labeled_arg_tokens () = [
    TildeKeyword; IdentifierTokenSpecial "name"; Colon; StringToken "test"; EOF
  ]

  (** 检查解析是否成功（不抛出异常） *)
  let assert_parse_success parse_func tokens =
    try
      let state = create_parser_state tokens in
      let _ = parse_func state in
      true
    with _ -> false

  (** 检查解析是否失败（抛出异常） *)
  let assert_parse_failure parse_func tokens =
    try
      let state = create_parser_state tokens in
      let _ = parse_func state in
      false
    with _ -> true

  (** 验证表达式解析结果的类型（通过不抛出异常验证） *)
  let verify_expression_parse tokens =
    assert_parse_success parse_expression tokens

end

(** 主表达式解析测试 *)

let test_parse_expression_basic () =
  (* 测试基础算术表达式 *)
  let simple_tokens = TestHelpers.create_simple_expression_tokens () in
  check bool "应该能解析简单算术表达式" true
    (TestHelpers.verify_expression_parse simple_tokens);

  (* 测试复杂算术表达式 *)
  let complex_tokens = TestHelpers.create_complex_expression_tokens () in
  check bool "应该能解析复杂算术表达式" true
    (TestHelpers.verify_expression_parse complex_tokens)

let test_parse_expression_conditional () =
  (* 测试条件表达式 *)
  let conditional_tokens = TestHelpers.create_conditional_tokens () in
  check bool "应该能解析条件表达式" true
    (TestHelpers.verify_expression_parse conditional_tokens);

  (* 测试文言文条件表达式 *)
  let wenyan_conditional_tokens = TestHelpers.create_wenyan_conditional_tokens () in
  check bool "应该能解析文言文条件表达式" true
    (TestHelpers.verify_expression_parse wenyan_conditional_tokens)

let test_parse_expression_let_bindings () =
  (* 测试let表达式 *)
  let let_tokens = TestHelpers.create_let_expression_tokens () in
  check bool "应该能解析let表达式" true
    (TestHelpers.verify_expression_parse let_tokens);

  (* 测试文言文let表达式 *)
  let wenyan_let_tokens = TestHelpers.create_wenyan_let_tokens () in
  check bool "应该能解析文言文let表达式" true
    (TestHelpers.verify_expression_parse wenyan_let_tokens);

  (* 测试简单let表达式 *)
  let simple_let_tokens = TestHelpers.create_simple_let_tokens () in
  check bool "应该能解析简单let表达式" true
    (TestHelpers.verify_expression_parse simple_let_tokens)

let test_parse_expression_functions () =
  (* 测试函数表达式 *)
  let function_tokens = TestHelpers.create_function_expression_tokens () in
  check bool "应该能解析函数表达式" true
    (TestHelpers.verify_expression_parse function_tokens);

  (* 测试自然语言函数定义 *)
  let natural_function_tokens = TestHelpers.create_natural_function_tokens () in
  check bool "应该能解析自然语言函数定义" true
    (TestHelpers.verify_expression_parse natural_function_tokens)

let test_parse_expression_pattern_matching () =
  (* 测试匹配表达式 *)
  let match_tokens = TestHelpers.create_match_expression_tokens () in
  check bool "应该能解析匹配表达式" true
    (TestHelpers.verify_expression_parse match_tokens);

  (* 测试古雅体匹配表达式 *)
  let ancient_match_tokens = TestHelpers.create_ancient_match_tokens () in
  check bool "应该能解析古雅体匹配表达式" true
    (TestHelpers.verify_expression_parse ancient_match_tokens)

let test_parse_expression_exception_handling () =
  (* 测试try表达式 *)
  let try_tokens = TestHelpers.create_try_expression_tokens () in
  check bool "应该能解析try表达式" true
    (TestHelpers.verify_expression_parse try_tokens);

  (* 测试raise表达式 *)
  let raise_tokens = TestHelpers.create_raise_expression_tokens () in
  check bool "应该能解析raise表达式" true
    (TestHelpers.verify_expression_parse raise_tokens)

let test_parse_expression_references () =
  (* 测试ref表达式 *)
  let ref_tokens = TestHelpers.create_ref_expression_tokens () in
  check bool "应该能解析ref表达式" true
    (TestHelpers.verify_expression_parse ref_tokens)

let test_parse_expression_compound_structures () =
  (* 测试组合表达式 *)
  let combine_tokens = TestHelpers.create_combine_expression_tokens () in
  check bool "应该能解析组合表达式" true
    (TestHelpers.verify_expression_parse combine_tokens);

  (* 测试数组表达式 *)
  let array_tokens = TestHelpers.create_array_expression_tokens () in
  check bool "应该能解析数组表达式" true
    (TestHelpers.verify_expression_parse array_tokens);

  (* 测试中文数组表达式 *)
  let chinese_array_tokens = TestHelpers.create_chinese_array_tokens () in
  check bool "应该能解析中文数组表达式" true
    (TestHelpers.verify_expression_parse chinese_array_tokens);

  (* 测试记录表达式 *)
  let record_tokens = TestHelpers.create_record_expression_tokens () in
  check bool "应该能解析记录表达式" true
    (TestHelpers.verify_expression_parse record_tokens)

(** 基础表达式解析测试 *)

let test_parse_primary_expression_literals () =
  (* 测试各种字面量 *)
  let literal_token_lists = TestHelpers.create_literal_tokens () in
  let all_literals = [
    [IntToken 123; EOF];
    [ChineseNumberToken "五"; EOF];
    [FloatToken 3.14; EOF];
    [StringToken "你好"; EOF];
    [BoolToken true; EOF];
  ] in
  
  List.iter (fun tokens ->
    check bool "应该能解析字面量表达式" true
      (TestHelpers.verify_expression_parse tokens)
  ) all_literals

let test_parse_primary_expression_type_keywords () =
  (* 测试类型关键字表达式 *)
  let type_keyword_tokens = TestHelpers.create_type_keyword_tokens () in
  check bool "应该能解析类型关键字表达式" true
    (TestHelpers.verify_expression_parse type_keyword_tokens);

  (* 测试其他类型关键字 *)
  let type_keywords = [
    [FloatTypeKeyword; EOF];
    [StringTypeKeyword; EOF];
    [BoolTypeKeyword; EOF];
    [UnitTypeKeyword; EOF];
    [ListTypeKeyword; EOF];
    [ArrayTypeKeyword; EOF];
  ] in

  List.iter (fun tokens ->
    check bool "应该能解析各种类型关键字" true
      (TestHelpers.verify_expression_parse tokens)
  ) type_keywords

let test_parse_primary_expression_poetry () =
  (* 测试诗词关键字表达式 *)
  let poetry_tokens = TestHelpers.create_poetry_expression_tokens () in
  check bool "应该能解析诗词关键字表达式" true
    (TestHelpers.verify_expression_parse poetry_tokens);

  (* 测试其他诗词关键字 *)
  let poetry_keywords = [
    [FiveCharKeyword; EOF];
    [SevenCharKeyword; EOF];
  ] in

  List.iter (fun tokens ->
    check bool "应该能解析各种诗词关键字" true
      (TestHelpers.verify_expression_parse tokens)
  ) poetry_keywords

let test_parse_primary_expression_parentheses () =
  (* 测试括号表达式 *)
  let paren_tokens = [LeftParen; IntToken 42; RightParen; EOF] in
  check bool "应该能解析括号表达式" true
    (TestHelpers.verify_expression_parse paren_tokens);

  (* 测试中文括号表达式 *)
  let chinese_paren_tokens = [ChineseLeftParen; IntToken 42; ChineseRightParen; EOF] in
  check bool "应该能解析中文括号表达式" true
    (TestHelpers.verify_expression_parse chinese_paren_tokens)

let test_parse_primary_expression_quoted_identifiers () =
  (* 测试引用标识符 *)
  let quoted_tokens = [QuotedIdentifierToken "test"; EOF] in
  check bool "应该能解析引用标识符" true
    (TestHelpers.verify_expression_parse quoted_tokens)

(** 复杂表达式解析测试 *)

let test_parse_complex_nested_expressions () =
  (* 测试嵌套表达式 *)
  let nested_tokens = TestHelpers.create_nested_expression_tokens () in
  check bool "应该能解析复杂嵌套表达式" true
    (TestHelpers.verify_expression_parse nested_tokens)

let test_parse_function_calls () =
  (* 测试函数调用 *)
  let function_call_tokens = TestHelpers.create_function_call_tokens () in
  check bool "应该能解析函数调用表达式" true
    (TestHelpers.verify_expression_parse function_call_tokens)

let test_parse_labeled_arguments () =
  (* 测试标签参数 *)
  let labeled_arg_tokens = TestHelpers.create_labeled_arg_tokens () in
  check bool "应该能解析标签参数" true
    (TestHelpers.verify_expression_parse labeled_arg_tokens)

(** 边界条件和错误处理测试 *)

let test_parse_expression_error_handling () =
  (* 测试无效token序列 *)
  let invalid_tokens = [Plus; Plus; EOF] in
  check bool "应该正确处理无效token序列" true
    (TestHelpers.assert_parse_failure parse_expression invalid_tokens);

  (* 测试空token序列 *)
  let empty_tokens = [EOF] in
  check bool "应该正确处理空token序列" true
    (TestHelpers.assert_parse_failure parse_expression empty_tokens);

  (* 测试不匹配的括号 *)
  let unmatched_tokens = [LeftParen; IntToken 42; EOF] in
  check bool "应该正确处理不匹配的括号" true
    (TestHelpers.assert_parse_failure parse_expression unmatched_tokens)

let test_parse_expression_unknown_tokens () =
  (* 测试未知token *)
  let unknown_tokens = [EOF] in  (* EOF作为第一个token应该导致错误 *)
  check bool "应该正确处理未知token" true
    (TestHelpers.assert_parse_failure parse_expression unknown_tokens)

(** 特殊关键字处理测试 *)

let test_special_keyword_expressions () =
  (* 测试特殊关键字表达式 *)
  let special_keywords = [
    [TagKeyword; EOF];
    [NumberKeyword; EOF];
    [OneKeyword; EOF];
    [EmptyKeyword; EOF];
    [ValueKeyword; EOF];
    [TrueKeyword; EOF];
    [FalseKeyword; EOF];
  ] in

  List.iter (fun tokens ->
    check bool "应该能解析特殊关键字表达式" true
      (TestHelpers.verify_expression_parse tokens)
  ) special_keywords

let test_ancient_keyword_expressions () =
  (* 测试古雅体关键字表达式 *)
  let ancient_keywords = [
    [AncientDefineKeyword; EOF];
    [AncientObserveKeyword; EOF];
    [AncientListStartKeyword; EOF];
  ] in

  List.iter (fun tokens ->
    check bool "应该能解析古雅体关键字表达式" true
      (TestHelpers.verify_expression_parse tokens)
  ) ancient_keywords

(** 性能和压力测试 *)

let test_parse_expression_performance () =
  (* 创建大型表达式进行性能测试 *)
  let rec create_large_expression depth =
    if depth <= 0 then [IntToken 1]
    else 
      LeftParen :: (create_large_expression (depth - 1)) @ 
      [Plus] @ (create_large_expression (depth - 1)) @ [RightParen]
  in
  
  let large_expr = create_large_expression 5 @ [EOF] in
  
  let start_time = Sys.time () in
  let success = TestHelpers.verify_expression_parse large_expr in
  let end_time = Sys.time () in
  
  check bool "应该能解析大型表达式" true success;
  check bool "大型表达式解析应该在合理时间内完成" true
    ((end_time -. start_time) < 2.0)

(** 集成测试 *)

let test_expression_parsing_integration () =
  (* 测试多种表达式类型的组合 *)
  let integration_tokens = [
    LetKeyword; IdentifierTokenSpecial "f"; Equal; 
    FunKeyword; IdentifierTokenSpecial "x"; Arrow;
    IfKeyword; IdentifierTokenSpecial "x"; Greater; IntToken 0;
    ThenKeyword; IdentifierTokenSpecial "x"; Multiply; IntToken 2;
    ElseKeyword; IntToken 0; InKeyword;
    IdentifierTokenSpecial "f"; LeftParen; IntToken 5; RightParen; EOF
  ] in
  
  check bool "应该能解析复杂集成表达式" true
    (TestHelpers.verify_expression_parse integration_tokens)

(** 测试套件定义 *)

let basic_expression_tests = [
  test_case "基础表达式解析" `Quick test_parse_expression_basic;
  test_case "条件表达式解析" `Quick test_parse_expression_conditional;
  test_case "Let绑定表达式解析" `Quick test_parse_expression_let_bindings;
  test_case "函数表达式解析" `Quick test_parse_expression_functions;
  test_case "模式匹配表达式解析" `Quick test_parse_expression_pattern_matching;
  test_case "异常处理表达式解析" `Quick test_parse_expression_exception_handling;
  test_case "引用表达式解析" `Quick test_parse_expression_references;
  test_case "复合结构表达式解析" `Quick test_parse_expression_compound_structures;
]

let primary_expression_tests = [
  test_case "字面量表达式解析" `Quick test_parse_primary_expression_literals;
  test_case "类型关键字表达式解析" `Quick test_parse_primary_expression_type_keywords;
  test_case "诗词表达式解析" `Quick test_parse_primary_expression_poetry;
  test_case "括号表达式解析" `Quick test_parse_primary_expression_parentheses;
  test_case "引用标识符表达式解析" `Quick test_parse_primary_expression_quoted_identifiers;
]

let complex_expression_tests = [
  test_case "复杂嵌套表达式解析" `Quick test_parse_complex_nested_expressions;
  test_case "函数调用解析" `Quick test_parse_function_calls;
  test_case "标签参数解析" `Quick test_parse_labeled_arguments;
]

let error_handling_tests = [
  test_case "表达式错误处理" `Quick test_parse_expression_error_handling;
  test_case "未知token处理" `Quick test_parse_expression_unknown_tokens;
]

let special_keyword_tests = [
  test_case "特殊关键字表达式" `Quick test_special_keyword_expressions;
  test_case "古雅体关键字表达式" `Quick test_ancient_keyword_expressions;
]

let performance_tests = [
  test_case "表达式解析性能测试" `Slow test_parse_expression_performance;
]

let integration_tests = [
  test_case "表达式解析集成测试" `Quick test_expression_parsing_integration;
]

(** 主测试运行器 *)
let () =
  run "Parser_expressions核心表达式解析器综合测试套件" [
    "基础表达式解析测试", basic_expression_tests;
    "基础表达式元素解析测试", primary_expression_tests;
    "复杂表达式解析测试", complex_expression_tests;
    "错误处理测试", error_handling_tests;
    "特殊关键字测试", special_keyword_tests;
    "性能测试", performance_tests;
    "集成测试", integration_tests;
  ]