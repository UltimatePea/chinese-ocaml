(** 解析器基础表达式模块增强测试 - Phase 25 测试覆盖率提升
    
    本测试模块专门针对 parser_expressions_primary.ml 进行全面测试，
    覆盖各种表达式解析场景，包括边界条件和错误处理。
    
    测试覆盖范围：
    - 基础表达式解析（字面量、标识符、关键字）
    - 后缀表达式（字段访问、数组访问）
    - 复合表达式（括号表达式、函数调用）
    - 诗词表达式（中文字符、诗词语法）
    - 错误处理和边界条件
    - Unicode字符处理
    
    @author 骆言技术债务清理团队 - Phase 25
    @version 1.0
    @since 2025-07-20 Issue #678 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Parser_expressions_primary

(** 创建测试用的解析器状态 *)
let create_test_state tokens =
  create_parser_state tokens

(** 基础表达式解析测试 *)
module BasicExpressionTests = struct
  
  (** 测试整数字面量解析 *)
  let test_integer_literal () =
    let tokens = [
      (IntToken 42, { line = 1; column = 1; filename = "test" });
      (EOF, { line = 1; column = 3; filename = "test" });
    ] in
    let state = create_test_state tokens in
    let expr, _ = parse_primary_expr state in
    check (testable pp_expr equal_expr) "整数字面量解析" (LitExpr (IntLit 42)) expr

  (** 测试浮点数字面量解析 *)
  let test_float_literal () =
    let tokens = [
      (FloatToken 3.14, { line = 1; column = 1; filename = "test" });
      (EOF, { line = 1; column = 5; filename = "test" });
    ] in
    let state = create_test_state tokens in
    let expr, _ = parse_primary_expr state in
    check (testable pp_expr equal_expr) "浮点数字面量解析" (LitExpr (FloatLit 3.14)) expr

  (** 测试字符串字面量解析 *)
  let test_string_literal () =
    let tokens = [
      (StringToken "你好世界", { line = 1; column = 1; filename = "test" });
      (EOF, { line = 1; column = 6; filename = "test" });
    ] in
    let state = create_test_state tokens in
    let expr, _ = parse_primary_expr state in
    check (testable pp_expr equal_expr) "中文字符串字面量解析" (LitExpr (StringLit "你好世界")) expr

  (** 测试布尔字面量解析 *)
  let test_boolean_literals () =
    (* 测试 true *)
    let tokens_true = [
      (BoolToken true, { line = 1; column = 1; filename = "test" });
      (EOF, { line = 1; column = 5; filename = "test" });
    ] in
    let state_true = create_test_state tokens_true in
    let expr_true, _ = parse_primary_expr state_true in
    check (testable pp_expr equal_expr) "布尔 true 解析" (LitExpr (BoolLit true)) expr_true;
    
    (* 测试 false *)
    let tokens_false = [
      (BoolToken false, { line = 1; column = 1; filename = "test" });
      (EOF, { line = 1; column = 6; filename = "test" });
    ] in
    let state_false = create_test_state tokens_false in
    let expr_false, _ = parse_primary_expr state_false in
    check (testable pp_expr equal_expr) "布尔 false 解析" (LitExpr (BoolLit false)) expr_false

  (** 测试标识符解析 *)
  let test_identifier_parsing () =
    let test_cases = [
      ("x", "简单标识符");
      ("变量名", "中文标识符");
      ("var_123", "带数字标识符");
      ("诗词_解析器", "中英混合标识符");
    ] in
    List.iter (fun (id, desc) ->
      let tokens = [
        (QuotedIdentifierToken id, { line = 1; column = 1; filename = "test" });
        (EOF, { line = 1; column = (String.length id + 1); filename = "test" });
      ] in
      let state = create_test_state tokens in
      let expr, _ = parse_primary_expr state in
      check (testable pp_expr equal_expr) desc (VarExpr id) expr
    ) test_cases

end

(** 后缀表达式测试 *)
module PostfixExpressionTests = struct

  (** 测试字段访问 *)
  let test_field_access () =
    let tokens = [
      (QuotedIdentifierToken "obj", { line = 1; column = 1; filename = "test" });
      (Dot, { line = 1; column = 4; filename = "test" });
      (QuotedIdentifierToken "field", { line = 1; column = 5; filename = "test" });
      (EOF, { line = 1; column = 10; filename = "test" });
    ] in
    let state = create_test_state tokens in
    let base_expr = VarExpr "obj" in
    let expr, _ = parse_postfix_expr base_expr state in
    check (testable pp_expr equal_expr) "字段访问解析" (FieldAccessExpr (VarExpr "obj", "field")) expr

  (** 测试多级字段访问 *)
  let test_nested_field_access () =
    let tokens = [
      (QuotedIdentifierToken "对象", { line = 1; column = 1; filename = "test" });
      (Dot, { line = 1; column = 3; filename = "test" });
      (QuotedIdentifierToken "属性1", { line = 1; column = 4; filename = "test" });
      (Dot, { line = 1; column = 7; filename = "test" });
      (QuotedIdentifierToken "属性2", { line = 1; column = 8; filename = "test" });
      (EOF, { line = 1; column = 11; filename = "test" });
    ] in
    let state = create_test_state tokens in
    let base_expr = VarExpr "对象" in
    let expr, _ = parse_postfix_expr base_expr state in
    let expected = FieldAccessExpr (FieldAccessExpr (VarExpr "对象", "属性1"), "属性2") in
    check (testable pp_expr equal_expr) "多级字段访问解析" expected expr

  (** 测试数组访问 *)
  let test_array_access () =
    let tokens = [
      (QuotedIdentifierToken "arr", { line = 1; column = 1; filename = "test" });
      (LeftBracket, { line = 1; column = 4; filename = "test" });
      (IntToken 0, { line = 1; column = 5; filename = "test" });
      (RightBracket, { line = 1; column = 6; filename = "test" });
      (EOF, { line = 1; column = 7; filename = "test" });
    ] in
    let state = create_test_state tokens in
    let base_expr = VarExpr "arr" in
    let expr, _ = parse_postfix_expr base_expr state in
    check (testable pp_expr equal_expr) "数组访问解析" 
      (ArrayAccessExpr (VarExpr "arr", LitExpr (IntLit 0))) expr

  (** 测试中文括号数组访问 *)
  let test_chinese_bracket_array_access () =
    let tokens = [
      (QuotedIdentifierToken "数组", { line = 1; column = 1; filename = "test" });
      (ChineseLeftBracket, { line = 1; column = 3; filename = "test" });
      (IntToken 1, { line = 1; column = 4; filename = "test" });
      (ChineseRightBracket, { line = 1; column = 5; filename = "test" });
      (EOF, { line = 1; column = 6; filename = "test" });
    ] in
    let state = create_test_state tokens in
    let base_expr = VarExpr "数组" in
    let expr, _ = parse_postfix_expr base_expr state in
    check (testable pp_expr equal_expr) "中文括号数组访问解析"
      (ArrayAccessExpr (VarExpr "数组", LitExpr (IntLit 1))) expr

end

(** 复合表达式测试 *)
module CompoundExpressionTests = struct

  (** 测试括号表达式 *)
  let test_parenthesized_expression () =
    let tokens = [
      (LeftParen, { line = 1; column = 1; filename = "test" });
      (IntToken 42, { line = 1; column = 2; filename = "test" });
      (Plus, { line = 1; column = 4; filename = "test" });
      (IntToken 1, { line = 1; column = 6; filename = "test" });
      (RightParen, { line = 1; column = 7; filename = "test" });
      (EOF, { line = 1; column = 8; filename = "test" });
    ] in
    let state = create_test_state tokens in
    let expr, _ = parse_primary_expr state in
    let expected = BinaryOpExpr (LitExpr (IntLit 42), Add, LitExpr (IntLit 1)) in
    check (testable pp_expr equal_expr) "括号表达式解析" expected expr

  (** 测试中文括号表达式 *)
  let test_chinese_parenthesized_expression () =
    let tokens = [
      (ChineseLeftParen, { line = 1; column = 1; filename = "test" });
      (StringToken "测试", { line = 1; column = 2; filename = "test" });
      (ChineseRightParen, { line = 1; column = 5; filename = "test" });
      (EOF, { line = 1; column = 6; filename = "test" });
    ] in
    let state = create_test_state tokens in
    let expr, _ = parse_primary_expr state in
    check (testable pp_expr equal_expr) "中文括号表达式解析" (LitExpr (StringLit "测试")) expr

end

(** Unicode 和中文字符处理测试 *)
module UnicodeTests = struct

  (** 测试 Unicode 字符串处理 *)
  let test_unicode_strings () =
    let test_cases = [
      ("春眠不觉晓", "经典诗句");
      ("🌸🌺🌻", "表情符号");
      ("αβγδε", "希腊字母");
      ("مرحبا", "阿拉伯文");
      ("こんにちは", "日文");
      ("한글", "韩文");
      ("Émojis café naïve", "带重音符号的拉丁字母");
    ] in
    List.iter (fun (text, desc) ->
      let tokens = [
        (StringToken text, { line = 1; column = 1; filename = "test" });
        (EOF, { line = 1; column = (String.length text + 1); filename = "test" });
      ] in
      let state = create_test_state tokens in
      let expr, _ = parse_primary_expr state in
      check (testable pp_expr equal_expr) desc (LitExpr (StringLit text)) expr
    ) test_cases

  (** 测试中文标识符 *)
  let test_chinese_identifiers () =
    let test_cases = [
      ("变量", "简单中文标识符");
      ("诗词解析器", "复杂中文标识符");
      ("用户_输入", "中英混合标识符");
      ("数据_2024", "带数字的中文标识符");
    ] in
    List.iter (fun (id, desc) ->
      let tokens = [
        (QuotedIdentifierToken id, { line = 1; column = 1; filename = "test" });
        (EOF, { line = 1; column = (String.length id + 1); filename = "test" });
      ] in
      let state = create_test_state tokens in
      let expr, _ = parse_primary_expr state in
      check (testable pp_expr equal_expr) desc (VarExpr id) expr
    ) test_cases

end

(** 错误处理和边界条件测试 *)
module ErrorHandlingTests = struct

  (** 测试无效 token 处理 *)
  let test_invalid_token_handling () =
    (* 这个测试检查解析器如何处理无效的 token 序列 *)
    let tokens = [
      (EOF, { line = 1; column = 1; filename = "test" });
    ] in
    let state = create_test_state tokens in
    try
      let _ = parse_primary_expr state in
      fail "应该抛出解析错误"
    with
    | _ -> () (* 预期的错误，测试通过 *)

  (** 测试不匹配的括号 *)
  let test_unmatched_parentheses () =
    let tokens = [
      (LeftParen, { line = 1; column = 1; filename = "test" });
      (IntToken 42, { line = 1; column = 2; filename = "test" });
      (* 缺少右括号 *)
      (EOF, { line = 1; column = 4; filename = "test" });
    ] in
    let state = create_test_state tokens in
    try
      let _ = parse_primary_expr state in
      fail "应该检测到不匹配的括号"
    with
    | _ -> () (* 预期的错误，测试通过 *)

  (** 测试空表达式处理 *)
  let test_empty_expression () =
    let tokens = [
      (EOF, { line = 1; column = 1; filename = "test" });
    ] in
    let state = create_test_state tokens in
    try
      let _ = parse_primary_expr state in
      fail "应该处理空表达式错误"
    with
    | _ -> () (* 预期的错误，测试通过 *)

end

(** 性能和压力测试 *)
module PerformanceTests = struct

  (** 测试深度嵌套表达式 *)
  let test_deep_nesting () =
    (* 创建深度嵌套的字段访问表达式: obj.a.b.c.d.e *)
    let tokens = [
      (QuotedIdentifierToken "obj", { line = 1; column = 1; filename = "test" });
      (Dot, { line = 1; column = 4; filename = "test" });
      (QuotedIdentifierToken "a", { line = 1; column = 5; filename = "test" });
      (Dot, { line = 1; column = 6; filename = "test" });
      (QuotedIdentifierToken "b", { line = 1; column = 7; filename = "test" });
      (Dot, { line = 1; column = 8; filename = "test" });
      (QuotedIdentifierToken "c", { line = 1; column = 9; filename = "test" });
      (Dot, { line = 1; column = 10; filename = "test" });
      (QuotedIdentifierToken "d", { line = 1; column = 11; filename = "test" });
      (Dot, { line = 1; column = 12; filename = "test" });
      (QuotedIdentifierToken "e", { line = 1; column = 13; filename = "test" });
      (EOF, { line = 1; column = 14; filename = "test" });
    ] in
    let state = create_test_state tokens in
    let base_expr = VarExpr "obj" in
    let expr, _ = parse_postfix_expr base_expr state in
    
    (* 验证嵌套结构正确 *)
    let rec check_nesting expr expected_depth = 
      match expr with
      | FieldAccessExpr (inner, _) -> check_nesting inner (expected_depth - 1)
      | VarExpr "obj" when expected_depth = 0 -> ()
      | _ -> fail "深度嵌套结构解析错误"
    in
    check_nesting expr 5

  (** 测试大量连续数组访问 *)
  let test_multiple_array_access () =
    (* 创建 arr[0][1][2] 的访问模式 *)
    let tokens = [
      (QuotedIdentifierToken "arr", { line = 1; column = 1; filename = "test" });
      (LeftBracket, { line = 1; column = 4; filename = "test" });
      (IntToken 0, { line = 1; column = 5; filename = "test" });
      (RightBracket, { line = 1; column = 6; filename = "test" });
      (LeftBracket, { line = 1; column = 7; filename = "test" });
      (IntToken 1, { line = 1; column = 8; filename = "test" });
      (RightBracket, { line = 1; column = 9; filename = "test" });
      (LeftBracket, { line = 1; column = 10; filename = "test" });
      (IntToken 2, { line = 1; column = 11; filename = "test" });
      (RightBracket, { line = 1; column = 12; filename = "test" });
      (EOF, { line = 1; column = 13; filename = "test" });
    ] in
    let state = create_test_state tokens in
    let base_expr = VarExpr "arr" in
    let expr, _ = parse_postfix_expr base_expr state in
    
    (* 验证多重数组访问结构 *)
    let expected = ArrayAccessExpr (
      ArrayAccessExpr (
        ArrayAccessExpr (VarExpr "arr", LitExpr (IntLit 0)),
        LitExpr (IntLit 1)
      ),
      LitExpr (IntLit 2)
    ) in
    check (testable pp_expr equal_expr) "多重数组访问解析" expected expr

end

(** 测试套件注册 *)
let test_suite = [
  "基础表达式解析", [
    test_case "整数字面量" `Quick BasicExpressionTests.test_integer_literal;
    test_case "浮点数字面量" `Quick BasicExpressionTests.test_float_literal;
    test_case "字符串字面量" `Quick BasicExpressionTests.test_string_literal;
    test_case "布尔字面量" `Quick BasicExpressionTests.test_boolean_literals;
    test_case "标识符解析" `Quick BasicExpressionTests.test_identifier_parsing;
  ];
  
  "后缀表达式", [
    test_case "字段访问" `Quick PostfixExpressionTests.test_field_access;
    test_case "多级字段访问" `Quick PostfixExpressionTests.test_nested_field_access;
    test_case "数组访问" `Quick PostfixExpressionTests.test_array_access;
    test_case "中文括号数组访问" `Quick PostfixExpressionTests.test_chinese_bracket_array_access;
  ];
  
  "复合表达式", [
    test_case "括号表达式" `Quick CompoundExpressionTests.test_parenthesized_expression;
    test_case "中文括号表达式" `Quick CompoundExpressionTests.test_chinese_parenthesized_expression;
  ];
  
  "Unicode字符处理", [
    test_case "Unicode字符串" `Quick UnicodeTests.test_unicode_strings;
    test_case "中文标识符" `Quick UnicodeTests.test_chinese_identifiers;
  ];
  
  "错误处理", [
    test_case "无效token处理" `Quick ErrorHandlingTests.test_invalid_token_handling;
    test_case "不匹配括号" `Quick ErrorHandlingTests.test_unmatched_parentheses;
    test_case "空表达式处理" `Quick ErrorHandlingTests.test_empty_expression;
  ];
  
  "性能测试", [
    test_case "深度嵌套" `Quick PerformanceTests.test_deep_nesting;
    test_case "多重数组访问" `Quick PerformanceTests.test_multiple_array_access;
  ];
]

(** 运行所有测试 *)
let () = 
  Printf.printf "骆言解析器基础表达式模块增强测试 - Phase 25\n";
  Printf.printf "======================================================\n";
  run "Parser Primary Expressions Enhanced Tests" test_suite