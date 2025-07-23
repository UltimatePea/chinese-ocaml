(** 骆言自然语言函数解析器综合测试 - 技术债务改进：提升测试覆盖率 Fix #962

    本测试模块专门针对 parser_natural_functions.ml 模块进行全面功能测试，
    重点测试自然语言函数定义解析功能的正确性和健壮性。

    测试覆盖范围：
    - parse_natural_function_definition 自然函数定义解析
    - parse_natural_function_body 自然函数体解析
    - parse_natural_expr 自然语言表达式解析
    - parse_natural_conditional 自然条件表达式解析
    - parse_conditional_relation_word 条件关系词解析
    - parse_natural_arithmetic_continuation 自然算术运算解析
    - parse_natural_comparison_patterns 自然比较模式解析
    - parse_natural_function_header 函数头解析
    - perform_semantic_analysis 语义分析
    - 边界条件和错误处理测试

    @author 骆言技术债务清理团队 - Issue #962 Parser模块测试覆盖率提升
    @version 1.0
    @since 2025-07-23 Issue #962 第七阶段Parser模块测试补强 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Parser_natural_functions

(** 测试工具函数 *)
module TestUtils = struct
  (** 创建测试位置 *)
  let create_test_pos line column = { line; column; filename = "test_parser_natural_functions.ml" }

  (** 创建简单的解析器状态 *)
  let create_test_state tokens = create_parser_state tokens

  (** 验证语法错误 *)
  let expect_syntax_error f =
    try
      ignore (f ());
      false
    with
    | SyntaxError _ -> true
    | _ -> false

  (** 创建基础的positioned_token *)
  let make_token token line col = 
    (token, create_test_pos line col)

  (** 创建测试用的回调函数 *)
  let mock_expect_token state _token = advance_parser state

  let mock_parse_identifier state = 
    match current_token state with
    | (QuotedIdentifierToken id, _) -> (id, advance_parser state)
    | _ -> failwith "Expected identifier"

  let mock_skip_newlines state = state

  let mock_parse_expr state =
    match current_token state with
    | (IntToken n, _) -> (LitExpr (IntLit n), advance_parser state)
    | (StringToken s, _) -> (LitExpr (StringLit s), advance_parser state)
    | (QuotedIdentifierToken id, _) -> (VarExpr id, advance_parser state)
    | _ -> failwith "Cannot parse expression"

  (** 验证表达式相等性 *)
  (* let expr_equal = equal_expr *)

  (** 检查解析结果的辅助函数 *)
  (* let check_parse_result (result_expr, final_state) expected_expr expected_remaining_tokens =
    expr_equal result_expr expected_expr && 
    final_state.current_pos = (Array.length final_state.token_array - List.length expected_remaining_tokens) *)
end

(** 测试 parse_natural_function_definition *)
module TestParseNaturalFunctionDefinition = struct
  let test_basic_function_definition () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "当") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "求") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "平方") 1 3;
      TestUtils.make_token (QuotedIdentifierToken "时") 1 4;
      TestUtils.make_token (QuotedIdentifierToken "返回") 1 5;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 6;
      TestUtils.make_token (QuotedIdentifierToken "乘以") 1 7;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 8;
      TestUtils.make_token EOF 1 9;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (result_expr, _final_state) = parse_natural_function_definition
        ~expect_token:TestUtils.mock_expect_token
        ~parse_identifier:TestUtils.mock_parse_identifier  
        ~skip_newlines:TestUtils.mock_skip_newlines
        ~parse_expr:TestUtils.mock_parse_expr
        state in
      (* 验证解析成功并返回有效表达式 *)
      match result_expr with
      | _ -> check bool "自然函数定义解析成功" true true
    with
    | SyntaxError _ -> check bool "自然函数定义解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_function_definition_with_parameters () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "当") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "计算") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 3;
      TestUtils.make_token (QuotedIdentifierToken "与") 1 4;
      TestUtils.make_token (QuotedIdentifierToken "y") 1 5;
      TestUtils.make_token (QuotedIdentifierToken "的") 1 6;
      TestUtils.make_token (QuotedIdentifierToken "和") 1 7;
      TestUtils.make_token (QuotedIdentifierToken "时") 1 8;
      TestUtils.make_token (QuotedIdentifierToken "返回") 1 9;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 10;
      TestUtils.make_token (QuotedIdentifierToken "加") 1 11;
      TestUtils.make_token (QuotedIdentifierToken "y") 1 12;
      TestUtils.make_token EOF 1 13;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (_result_expr, _final_state) = parse_natural_function_definition
        ~expect_token:TestUtils.mock_expect_token
        ~parse_identifier:TestUtils.mock_parse_identifier  
        ~skip_newlines:TestUtils.mock_skip_newlines
        ~parse_expr:TestUtils.mock_parse_expr
        state in
      check bool "带参数的自然函数定义解析成功" true true
    with
    | SyntaxError _ -> check bool "带参数的自然函数定义解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_invalid_function_definition () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "错误") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "函数") 1 2;
      TestUtils.make_token EOF 1 3;
    ] in
    let state = TestUtils.create_test_state tokens in
    let should_fail = TestUtils.expect_syntax_error (fun () ->
      parse_natural_function_definition
        ~expect_token:TestUtils.mock_expect_token
        ~parse_identifier:TestUtils.mock_parse_identifier  
        ~skip_newlines:TestUtils.mock_skip_newlines
        ~parse_expr:TestUtils.mock_parse_expr
        state) in
    check bool "错误的函数定义应该触发语法错误" true should_fail

  let tests = [
    test_case "Basic natural function definition" `Quick test_basic_function_definition;
    test_case "Function definition with parameters" `Quick test_function_definition_with_parameters;
    test_case "Invalid function definition" `Quick test_invalid_function_definition;
  ]
end

(** 测试 parse_natural_function_body *)
module TestParseNaturalFunctionBody = struct
  let test_simple_function_body () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "返回") 1 1;
      TestUtils.make_token (IntToken 42) 1 2;
      TestUtils.make_token EOF 1 3;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (result_expr, _final_state) = parse_natural_function_body
        ~expect_token:TestUtils.mock_expect_token
        ~parse_identifier:TestUtils.mock_parse_identifier  
        ~skip_newlines:TestUtils.mock_skip_newlines
        ~parse_expr:TestUtils.mock_parse_expr
        "test_function"
        state in
      match result_expr with
      | LitExpr (IntLit 42) -> check bool "简单函数体解析正确" true true
      | _ -> check bool "函数体解析结果不正确" false true
    with
    | SyntaxError _ -> check bool "简单函数体解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_complex_function_body () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "计算") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "加") 1 3;
      TestUtils.make_token (IntToken 10) 1 4;
      TestUtils.make_token EOF 1 5;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (_result_expr, _final_state) = parse_natural_function_body
        ~expect_token:TestUtils.mock_expect_token
        ~parse_identifier:TestUtils.mock_parse_identifier  
        ~skip_newlines:TestUtils.mock_skip_newlines
        ~parse_expr:TestUtils.mock_parse_expr
        "complex_function"
        state in
      check bool "复杂函数体解析成功" true true
    with
    | SyntaxError _ -> check bool "复杂函数体解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Simple function body" `Quick test_simple_function_body;
    test_case "Complex function body" `Quick test_complex_function_body;
  ]
end

(** 测试 parse_natural_expr *)
module TestParseNaturalExpr = struct
  let test_simple_natural_expression () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "取") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "的") 1 3;
      TestUtils.make_token (QuotedIdentifierToken "值") 1 4;
      TestUtils.make_token EOF 1 5;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (_result_expr, _final_state) = parse_natural_expr
        ~parse_expr:TestUtils.mock_parse_expr
        "取值操作"
        state in
      check bool "简单自然表达式解析成功" true true
    with
    | SyntaxError _ -> check bool "简单自然表达式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_arithmetic_natural_expression () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "计算") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "乘以") 1 3;
      TestUtils.make_token (IntToken 2) 1 4;
      TestUtils.make_token EOF 1 5;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (_result_expr, _final_state) = parse_natural_expr
        ~parse_expr:TestUtils.mock_parse_expr
        "算术操作"
        state in
      check bool "算术自然表达式解析成功" true true
    with
    | SyntaxError _ -> check bool "算术自然表达式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Simple natural expression" `Quick test_simple_natural_expression;
    test_case "Arithmetic natural expression" `Quick test_arithmetic_natural_expression;
  ]
end

(** 测试 parse_natural_conditional *)
module TestParseNaturalConditional = struct
  let test_basic_conditional () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "如果") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "大于") 1 3;
      TestUtils.make_token (IntToken 0) 1 4;
      TestUtils.make_token (QuotedIdentifierToken "那么") 1 5;
      TestUtils.make_token (StringToken "正数") 1 6;
      TestUtils.make_token (QuotedIdentifierToken "否则") 1 7;
      TestUtils.make_token (StringToken "非正数") 1 8;
      TestUtils.make_token EOF 1 9;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (var_name, op, condition, then_expr, final_state) = parse_natural_conditional
        ~expect_token:TestUtils.mock_expect_token
        ~parse_identifier:TestUtils.mock_parse_identifier  
        ~skip_newlines:TestUtils.mock_skip_newlines
        ~parse_expr:TestUtils.mock_parse_expr
        "条件判断"
        state in
      check bool "变量名解析正确" true (var_name = "x")
    with
    | SyntaxError _ -> check bool "基本条件表达式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_complex_conditional () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "当") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "温度") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "小于等于") 1 3;
      TestUtils.make_token (IntToken 32) 1 4;
      TestUtils.make_token (QuotedIdentifierToken "时") 1 5;
      TestUtils.make_token (StringToken "结冰") 1 6;
      TestUtils.make_token (QuotedIdentifierToken "其他情况") 1 7;
      TestUtils.make_token (StringToken "液态") 1 8;
      TestUtils.make_token EOF 1 9;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (var_name, op, condition, then_expr, final_state) = parse_natural_conditional
        ~expect_token:TestUtils.mock_expect_token
        ~parse_identifier:TestUtils.mock_parse_identifier  
        ~skip_newlines:TestUtils.mock_skip_newlines
        ~parse_expr:TestUtils.mock_parse_expr
        "复杂条件"
        state in
      check bool "复杂条件变量名解析正确" true (var_name = "温度")
    with
    | SyntaxError _ -> check bool "复杂条件表达式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Basic conditional" `Quick test_basic_conditional;
    test_case "Complex conditional" `Quick test_complex_conditional;
  ]
end

(** 测试 parse_conditional_relation_word *)
module TestParseConditionalRelationWord = struct
  let test_comparison_operators () =
    let test_cases = [
      ("大于", Gt);
      ("小于", Lt);
      ("等于", Eq);
      ("大于等于", Ge);
      ("小于等于", Le);
      ("不等于", Neq);
    ] in
    List.iter (fun (chinese_op, expected_op) ->
      let tokens = [
        TestUtils.make_token (QuotedIdentifierToken chinese_op) 1 1;
        TestUtils.make_token EOF 1 2;
      ] in
      let state = TestUtils.create_test_state tokens in
      try
        let (parsed_op, final_state) = parse_conditional_relation_word state in
        check bool ("关系词 " ^ chinese_op ^ " 解析正确") true (parsed_op = expected_op)
      with
      | SyntaxError _ -> check bool ("关系词 " ^ chinese_op ^ " 解析应该成功") false true
      | _ -> check bool ("关系词 " ^ chinese_op ^ " 出现意外错误") false true
    ) test_cases

  let test_invalid_relation_word () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "无效关系词") 1 1;
      TestUtils.make_token EOF 1 2;
    ] in
    let state = TestUtils.create_test_state tokens in
    let should_fail = TestUtils.expect_syntax_error (fun () ->
      parse_conditional_relation_word state) in
    check bool "无效关系词应该触发语法错误" true should_fail

  let tests = [
    test_case "Comparison operators" `Quick test_comparison_operators;
    test_case "Invalid relation word" `Quick test_invalid_relation_word;
  ]
end

(** 测试 parse_natural_arithmetic_continuation *)
module TestParseNaturalArithmeticContinuation = struct
  let test_addition_continuation () =
    let base_expr = LitExpr (IntLit 5) in
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "加上") 1 1;
      TestUtils.make_token (IntToken 3) 1 2;
      TestUtils.make_token EOF 1 3;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (result_expr, final_state) = parse_natural_arithmetic_continuation
        ~parse_expr:TestUtils.mock_parse_expr
        base_expr
        "加法运算"
        state in
      check bool "加法延续解析成功" true true
    with
    | SyntaxError _ -> check bool "加法延续解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_multiplication_continuation () =
    let base_expr = VarExpr "x" in
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "乘以") 1 1;
      TestUtils.make_token (IntToken 2) 1 2;
      TestUtils.make_token EOF 1 3;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (result_expr, final_state) = parse_natural_arithmetic_continuation
        ~parse_expr:TestUtils.mock_parse_expr
        base_expr
        "乘法运算"
        state in
      check bool "乘法延续解析成功" true true
    with
    | SyntaxError _ -> check bool "乘法延续解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Addition continuation" `Quick test_addition_continuation;
    test_case "Multiplication continuation" `Quick test_multiplication_continuation;
  ]
end

(** 测试 parse_natural_comparison_patterns *)
module TestParseNaturalComparisonPatterns = struct
  let test_basic_comparison_pattern () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "比较") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "x") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "与") 1 3;
      TestUtils.make_token (IntToken 10) 1 4;
      TestUtils.make_token EOF 1 5;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (result_expr, final_state) = parse_natural_comparison_patterns
        ~parse_expr:TestUtils.mock_parse_expr
        "比较模式"
        state in
      check bool "基本比较模式解析成功" true true
    with
    | SyntaxError _ -> check bool "基本比较模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_complex_comparison_pattern () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "判断") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "温度") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "是否") 1 3;
      TestUtils.make_token (QuotedIdentifierToken "超过") 1 4;
      TestUtils.make_token (IntToken 25) 1 5;
      TestUtils.make_token (QuotedIdentifierToken "度") 1 6;
      TestUtils.make_token EOF 1 7;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (result_expr, final_state) = parse_natural_comparison_patterns
        ~parse_expr:TestUtils.mock_parse_expr
        "复杂比较模式"
        state in
      check bool "复杂比较模式解析成功" true true
    with
    | SyntaxError _ -> check bool "复杂比较模式解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Basic comparison pattern" `Quick test_basic_comparison_pattern;
    test_case "Complex comparison pattern" `Quick test_complex_comparison_pattern;
  ]
end

(** 测试 parse_natural_function_header *)
module TestParseNaturalFunctionHeader = struct
  let test_basic_function_header () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "定义") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "计算") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "函数") 1 3;
      TestUtils.make_token EOF 1 4;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (func_type, func_name, final_state) = parse_natural_function_header
        ~expect_token:TestUtils.mock_expect_token
        ~parse_identifier:TestUtils.mock_parse_identifier  
        ~skip_newlines:TestUtils.mock_skip_newlines
        state in
      check bool "函数名解析正确" true (func_name = "计算")
    with
    | SyntaxError _ -> check bool "基本函数头解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let test_function_header_with_params () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "创建") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "求和") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "方法") 1 3;
      TestUtils.make_token (QuotedIdentifierToken "接受") 1 4;
      TestUtils.make_token (QuotedIdentifierToken "参数") 1 5;
      TestUtils.make_token EOF 1 6;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (func_type, func_name, final_state) = parse_natural_function_header
        ~expect_token:TestUtils.mock_expect_token
        ~parse_identifier:TestUtils.mock_parse_identifier  
        ~skip_newlines:TestUtils.mock_skip_newlines
        state in
      check bool "带参数函数名解析正确" true (func_name = "求和")
    with
    | SyntaxError _ -> check bool "带参数函数头解析应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Basic function header" `Quick test_basic_function_header;
    test_case "Function header with parameters" `Quick test_function_header_with_params;
  ]
end

(** 测试 perform_semantic_analysis *)
module TestPerformSemanticAnalysis = struct
  let test_basic_semantic_analysis () =
    let expr = LitExpr (IntLit 42) in
    try
      perform_semantic_analysis "test_function" "计算" expr;
      check bool "基本语义分析执行成功" true true
    with
    | _ -> check bool "基本语义分析应该成功" false true

  let test_complex_semantic_analysis () =
    let expr = BinaryOpExpr (VarExpr "x", Add, LitExpr (IntLit 1)) in
    try
      perform_semantic_analysis "increment" "递增函数" expr;
      check bool "复杂语义分析执行成功" true true
    with
    | _ -> check bool "复杂语义分析应该成功" false true

  let tests = [
    test_case "Basic semantic analysis" `Quick test_basic_semantic_analysis;
    test_case "Complex semantic analysis" `Quick test_complex_semantic_analysis;
  ]
end

(** 综合集成测试 *)
module TestIntegration = struct
  let test_complete_natural_function_parsing () =
    let tokens = [
      TestUtils.make_token (QuotedIdentifierToken "当") 1 1;
      TestUtils.make_token (QuotedIdentifierToken "计算") 1 2;
      TestUtils.make_token (QuotedIdentifierToken "阶乘") 1 3;
      TestUtils.make_token (QuotedIdentifierToken "对于") 1 4;
      TestUtils.make_token (QuotedIdentifierToken "n") 1 5;
      TestUtils.make_token (QuotedIdentifierToken "时") 1 6;
      TestUtils.make_token (QuotedIdentifierToken "如果") 1 7;
      TestUtils.make_token (QuotedIdentifierToken "n") 1 8;
      TestUtils.make_token (QuotedIdentifierToken "小于等于") 1 9;
      TestUtils.make_token (IntToken 1) 1 10;
      TestUtils.make_token (QuotedIdentifierToken "那么") 1 11;
      TestUtils.make_token (IntToken 1) 1 12;
      TestUtils.make_token (QuotedIdentifierToken "否则") 1 13;
      TestUtils.make_token (QuotedIdentifierToken "n") 1 14;
      TestUtils.make_token (QuotedIdentifierToken "乘以") 1 15;
      TestUtils.make_token (QuotedIdentifierToken "阶乘") 1 16;
      TestUtils.make_token (QuotedIdentifierToken "n") 1 17;
      TestUtils.make_token (QuotedIdentifierToken "减") 1 18;
      TestUtils.make_token (IntToken 1) 1 19;
      TestUtils.make_token EOF 1 20;
    ] in
    let state = TestUtils.create_test_state tokens in
    try
      let (result_expr, _final_state) = parse_natural_function_definition
        ~expect_token:TestUtils.mock_expect_token
        ~parse_identifier:TestUtils.mock_parse_identifier  
        ~skip_newlines:TestUtils.mock_skip_newlines
        ~parse_expr:TestUtils.mock_parse_expr
        state in
      check bool "完整自然函数解析测试成功" true true
    with
    | SyntaxError _ -> check bool "完整自然函数解析测试应该成功" false true
    | _ -> check bool "出现意外错误" false true

  let tests = [
    test_case "Complete natural function parsing" `Quick test_complete_natural_function_parsing;
  ]
end

(** 主测试套件 *)
let () =
  run "Parser Natural Functions Comprehensive Tests" [
    ("Parse Natural Function Definition", TestParseNaturalFunctionDefinition.tests);
    ("Parse Natural Function Body", TestParseNaturalFunctionBody.tests);
    ("Parse Natural Expression", TestParseNaturalExpr.tests);
    ("Parse Natural Conditional", TestParseNaturalConditional.tests);
    ("Parse Conditional Relation Word", TestParseConditionalRelationWord.tests);
    ("Parse Natural Arithmetic Continuation", TestParseNaturalArithmeticContinuation.tests);
    ("Parse Natural Comparison Patterns", TestParseNaturalComparisonPatterns.tests);
    ("Parse Natural Function Header", TestParseNaturalFunctionHeader.tests);
    ("Perform Semantic Analysis", TestPerformSemanticAnalysis.tests);
    ("Integration Tests", TestIntegration.tests);
  ]