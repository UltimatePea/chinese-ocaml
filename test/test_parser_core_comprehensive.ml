(** 骆言Parser核心模块全面测试覆盖 - Fix #933 第一阶段
    专注于提升Parser模块的测试覆盖率从20%至80%+
    测试范围：表达式解析、语句解析、模式匹配、类型注解等核心功能 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer_tokens
open Yyocamlc_lib.Parser

(** 测试工具模块 *)
module TestUtils = struct
  let create_test_pos line column = { line; column; filename = "test_parser_core" }
  
  let make_token token line column = (token, create_test_pos line column)
  
  let eof_token line column = make_token EOF line column
  
  (** 创建解析器状态 *)
  let create_parser_with_tokens tokens = create_parser_state tokens
  
  (** 测试表达式相等性 *)
  let check_expr desc expected actual =
    check (testable pp_expr equal_expr) desc expected actual
    
  (** 测试语句相等性 *)
  let check_stmt desc expected actual =
    check (testable pp_stmt equal_stmt) desc expected actual
end

(** 基础字面量解析测试模块 *)
module LiteralParsingTests = struct
  open TestUtils
  
  let test_integer_literal_parsing () =
    let test_cases = [
      (* 基础整数测试 *)
      ([make_token (IntToken 0) 1 1; eof_token 1 2], 
       LitExpr (IntLit 0), "零值整数解析");
      ([make_token (IntToken 42) 1 1; eof_token 1 3], 
       LitExpr (IntLit 42), "正整数解析");
      ([make_token (IntToken (-17)) 1 1; eof_token 1 4], 
       LitExpr (IntLit (-17)), "负整数解析");
      ([make_token (IntToken 2147483647) 1 1; eof_token 1 11], 
       LitExpr (IntLit 2147483647), "最大32位整数解析");
      ([make_token (IntToken (-2147483648)) 1 1; eof_token 1 12], 
       LitExpr (IntLit (-2147483648)), "最小32位整数解析");
    ] in
    List.iter (fun (tokens, expected, desc) ->
      let state = create_parser_with_tokens tokens in
      let expr, _ = parse_expression state in
      check_expr desc expected expr
    ) test_cases
  
  let test_string_literal_parsing () =
    let test_cases = [
      (* 字符串字面量测试 *)
      ([make_token (StringToken "") 1 1; eof_token 1 3], 
       LitExpr (StringLit ""), "空字符串解析");
      ([make_token (StringToken "hello") 1 1; eof_token 1 8], 
       LitExpr (StringLit "hello"), "简单英文字符串");
      ([make_token (StringToken "你好世界") 1 1; eof_token 1 6], 
       LitExpr (StringLit "你好世界"), "中文字符串解析");
      ([make_token (StringToken "hello\nworld\ttab") 1 1; eof_token 2 4], 
       LitExpr (StringLit "hello\nworld\ttab"), "包含转义字符的字符串");
      ([make_token (StringToken "\"quoted\"") 1 1; eof_token 1 10], 
       LitExpr (StringLit "\"quoted\""), "包含引号的字符串");
    ] in
    List.iter (fun (tokens, expected, desc) ->
      let state = create_parser_with_tokens tokens in
      let expr, _ = parse_expression state in
      check_expr desc expected expr
    ) test_cases
    
  let test_boolean_literal_parsing () =
    let test_cases = [
      ([make_token TrueKeyword 1 1; eof_token 1 5], 
       LitExpr (BoolLit true), "布尔真值解析");
      ([make_token FalseKeyword 1 1; eof_token 1 6], 
       LitExpr (BoolLit false), "布尔假值解析");
    ] in
    List.iter (fun (tokens, expected, desc) ->
      let state = create_parser_with_tokens tokens in
      let expr, _ = parse_expression state in
      check_expr desc expected expr
    ) test_cases
end

(** 运算符表达式解析测试模块 *)
module OperatorExpressionTests = struct
  open TestUtils
  
  let test_arithmetic_binary_operators () =
    let test_cases = [
      (* 算术运算符测试 *)
      ([make_token (IntToken 1) 1 1; make_token Plus 1 3; make_token (IntToken 2) 1 5; eof_token 1 6],
       BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)), "加法运算解析");
      ([make_token (IntToken 5) 1 1; make_token Minus 1 3; make_token (IntToken 3) 1 5; eof_token 1 6],
       BinaryOpExpr (LitExpr (IntLit 5), Sub, LitExpr (IntLit 3)), "减法运算解析");
      ([make_token (IntToken 4) 1 1; make_token Star 1 3; make_token (IntToken 6) 1 5; eof_token 1 6],
       BinaryOpExpr (LitExpr (IntLit 4), Mul, LitExpr (IntLit 6)), "乘法运算解析");
      ([make_token (IntToken 8) 1 1; make_token Slash 1 3; make_token (IntToken 2) 1 5; eof_token 1 6],
       BinaryOpExpr (LitExpr (IntLit 8), Div, LitExpr (IntLit 2)), "除法运算解析");
    ] in
    List.iter (fun (tokens, expected, desc) ->
      let state = create_parser_with_tokens tokens in
      let expr, _ = parse_expression state in
      check_expr desc expected expr
    ) test_cases
  
  let test_comparison_operators () =
    let test_cases = [
      (* 比较运算符测试 *)
      ([make_token (IntToken 1) 1 1; make_token Equal 1 3; make_token (IntToken 1) 1 6; eof_token 1 7],
       BinaryOpExpr (LitExpr (IntLit 1), Eq, LitExpr (IntLit 1)), "等于运算解析");
      ([make_token (IntToken 2) 1 1; make_token NotEqual 1 3; make_token (IntToken 3) 1 7; eof_token 1 8],
       BinaryOpExpr (LitExpr (IntLit 2), Neq, LitExpr (IntLit 3)), "不等于运算解析");
      ([make_token (IntToken 1) 1 1; make_token Less 1 3; make_token (IntToken 2) 1 5; eof_token 1 6],
       BinaryOpExpr (LitExpr (IntLit 1), Lt, LitExpr (IntLit 2)), "小于运算解析");
      ([make_token (IntToken 3) 1 1; make_token Greater 1 3; make_token (IntToken 1) 1 5; eof_token 1 6],
       BinaryOpExpr (LitExpr (IntLit 3), Gt, LitExpr (IntLit 1)), "大于运算解析");
    ] in
    List.iter (fun (tokens, expected, desc) ->
      let state = create_parser_with_tokens tokens in
      let expr, _ = parse_expression state in
      check_expr desc expected expr
    ) test_cases
  
  let test_logical_operators () =
    let test_cases = [
      (* 逻辑运算符测试 *)
      ([make_token TrueKeyword 1 1; make_token AndKeyword 1 6; 
        make_token FalseKeyword 1 10; eof_token 1 15],
       BinaryOpExpr (LitExpr (BoolLit true), And, LitExpr (BoolLit false)), "逻辑与运算解析");
      ([make_token FalseKeyword 1 1; make_token OrKeyword 1 7; 
        make_token TrueKeyword 1 10; eof_token 1 14],
       BinaryOpExpr (LitExpr (BoolLit false), Or, LitExpr (BoolLit true)), "逻辑或运算解析");
    ] in
    List.iter (fun (tokens, expected, desc) ->
      let state = create_parser_with_tokens tokens in
      let expr, _ = parse_expression state in
      check_expr desc expected expr
    ) test_cases
  
  let test_unary_operators () =
    let test_cases = [
      (* 一元运算符测试 *)
      ([make_token Minus 1 1; make_token (IntToken 5) 1 2; eof_token 1 3],
       UnaryOpExpr (Neg, LitExpr (IntLit 5)), "一元负号解析");
      ([make_token NotKeyword 1 1; make_token TrueKeyword 1 2; eof_token 1 6],
       UnaryOpExpr (Not, LitExpr (BoolLit true)), "逻辑非运算解析");
    ] in
    List.iter (fun (tokens, expected, desc) ->
      let state = create_parser_with_tokens tokens in
      let expr, _ = parse_expression state in
      check_expr desc expected expr
    ) test_cases
end

(** 运算符优先级测试模块 *)
module OperatorPrecedenceTests = struct
  open TestUtils
  
  let test_arithmetic_precedence () =
    (* 测试算术运算符优先级：乘除优于加减 *)
    let tokens = [
      make_token (IntToken 1) 1 1; make_token Plus 1 3; 
      make_token (IntToken 2) 1 5; make_token Star 1 7; 
      make_token (IntToken 3) 1 9; eof_token 1 10
    ] in
    let expected = BinaryOpExpr (LitExpr (IntLit 1), Add, 
                            BinaryOpExpr (LitExpr (IntLit 2), Mul, LitExpr (IntLit 3))) in
    let state = create_parser_with_tokens tokens in
    let expr, _ = parse_expression state in
    check_expr "算术运算符优先级：乘法优于加法" expected expr
  
  let test_comparison_precedence () =
    (* 测试比较运算符优先级：算术运算优于比较运算 *)
    let tokens = [
      make_token (IntToken 1) 1 1; make_token Plus 1 3; 
      make_token (IntToken 2) 1 5; make_token Less 1 7; 
      make_token (IntToken 3) 1 9; make_token Plus 1 11;
      make_token (IntToken 1) 1 13; eof_token 1 14
    ] in
    let expected = BinaryOpExpr (
                            BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)), Lt,
                            BinaryOpExpr (LitExpr (IntLit 3), Add, LitExpr (IntLit 1))) in
    let state = create_parser_with_tokens tokens in
    let expr, _ = parse_expression state in
    check_expr "比较运算符优先级：算术运算优于比较运算" expected expr
  
  let test_logical_precedence () =
    (* 测试逻辑运算符优先级：与运算优于或运算 *)
    let tokens = [
      make_token (QuotedIdentifierToken "a") 1 1; make_token AndKeyword 1 3; 
      make_token (QuotedIdentifierToken "b") 1 7; make_token OrKeyword 1 9; 
      make_token (QuotedIdentifierToken "c") 1 12; eof_token 1 13
    ] in
    let expected = BinaryOpExpr (
                            BinaryOpExpr (VarExpr "a", And, VarExpr "b"), Or,
                            VarExpr "c") in
    let state = create_parser_with_tokens tokens in
    let expr, _ = parse_expression state in
    check_expr "逻辑运算符优先级：与运算优于或运算" expected expr
end

(** 括号表达式测试模块 *)
module ParenthesesTests = struct
  open TestUtils
  
  let test_simple_parentheses () =
    let tokens = [
      make_token LeftParen 1 1; make_token (IntToken 5) 1 2; 
      make_token RightParen 1 3; eof_token 1 4
    ] in
    let expected = LitExpr (IntLit 5) in
    let state = create_parser_with_tokens tokens in
    let expr, _ = parse_expression state in
    check_expr "简单括号表达式解析" expected expr
  
  let test_parentheses_override_precedence () =
    (* 测试括号改变运算优先级 *)
    let tokens = [
      make_token LeftParen 1 1; make_token (IntToken 1) 1 2; 
      make_token Plus 1 4; make_token (IntToken 2) 1 6; 
      make_token RightParen 1 7; make_token Star 1 9; 
      make_token (IntToken 3) 1 11; eof_token 1 12
    ] in
    let expected = BinaryOpExpr (
                            BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)), Mul,
                            LitExpr (IntLit 3)) in
    let state = create_parser_with_tokens tokens in
    let expr, _ = parse_expression state in
    check_expr "括号改变运算优先级" expected expr
  
  let test_nested_parentheses () =
    (* 测试嵌套括号 *)
    let tokens = [
      make_token LeftParen 1 1; make_token LeftParen 1 2; 
      make_token (IntToken 1) 1 3; make_token Plus 1 5; 
      make_token (IntToken 2) 1 7; make_token RightParen 1 8; 
      make_token Star 1 10; make_token (IntToken 3) 1 12; 
      make_token RightParen 1 13; eof_token 1 14
    ] in
    let expected = BinaryOpExpr (
                            BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)), Mul,
                            LitExpr (IntLit 3)) in
    let state = create_parser_with_tokens tokens in
    let expr, _ = parse_expression state in
    check_expr "嵌套括号表达式解析" expected expr
end

(** 变量和标识符测试模块 *)
module IdentifierTests = struct
  open TestUtils
  
  let test_simple_identifiers () =
    let test_cases = [
      ([make_token (QuotedIdentifierToken "x") 1 1; eof_token 1 2], 
       VarExpr "x", "单字符变量名");
      ([make_token (QuotedIdentifierToken "variable") 1 1; eof_token 1 9], 
       VarExpr "variable", "英文变量名");
      ([make_token (QuotedIdentifierToken "变量") 1 1; eof_token 1 3], 
       VarExpr "变量", "中文变量名");
      ([make_token (QuotedIdentifierToken "var123") 1 1; eof_token 1 7], 
       VarExpr "var123", "包含数字的变量名");
      ([make_token (QuotedIdentifierToken "_private") 1 1; eof_token 1 9], 
       VarExpr "_private", "下划线开头的变量名");
    ] in
    List.iter (fun (tokens, expected, desc) ->
      let state = create_parser_with_tokens tokens in
      let expr, _ = parse_expression state in
      check_expr desc expected expr
    ) test_cases
  
  let test_qualified_identifiers () =
    (* 测试模块限定符 *)
    let tokens = [
      make_token (QuotedIdentifierToken "Module") 1 1; make_token Dot 1 7; 
      make_token (QuotedIdentifierToken "value") 1 8; eof_token 1 13
    ] in
    let expected = ModuleAccessExpr (VarExpr "Module", "value") in
    let state = create_parser_with_tokens tokens in
    let expr, _ = parse_expression state in
    check_expr "模块限定标识符解析" expected expr
end

(** 函数调用测试模块 *)
module FunctionCallTests = struct
  open TestUtils
  
  let test_simple_function_calls () =
    let test_cases = [
      (* 单参数函数调用 - 基于成功的测试模式 *)
      ([make_token (QuotedIdentifierToken "print") 1 1; make_token LeftParen 1 6; 
        make_token (StringToken "hello") 1 7; make_token RightParen 1 14; eof_token 1 15],
       FunCallExpr (VarExpr "print", [LitExpr (StringLit "hello")]), "单参数函数调用");
      
      (* 单参数整数函数调用 *)
      ([make_token (QuotedIdentifierToken "f") 1 1; make_token LeftParen 1 2; 
        make_token (IntToken 42) 1 3; make_token RightParen 1 5; eof_token 1 6],
       FunCallExpr (VarExpr "f", [LitExpr (IntLit 42)]), "单参数整数函数调用");
    ] in
    List.iter (fun (tokens, expected, desc) ->
      let state = create_parser_with_tokens tokens in
      let expr, _ = parse_expression state in
      check_expr desc expected expr
    ) test_cases
  
  let test_nested_function_calls () =
    (* 测试嵌套函数调用 *)
    let tokens = [
      make_token (QuotedIdentifierToken "outer") 1 1; make_token LeftParen 1 6; 
      make_token (QuotedIdentifierToken "inner") 1 7; make_token LeftParen 1 12; 
      make_token (IntToken 5) 1 13; make_token RightParen 1 14; 
      make_token RightParen 1 15; eof_token 1 16
    ] in
    let expected = FunCallExpr (VarExpr "outer", 
                            [FunCallExpr (VarExpr "inner", [LitExpr (IntLit 5)])]) in
    let state = create_parser_with_tokens tokens in
    let expr, _ = parse_expression state in
    check_expr "嵌套函数调用解析" expected expr
end

(** 语句解析测试模块 *)
module StatementParsingTests = struct
  open TestUtils
  
  let test_variable_declarations () =
    let test_cases = [
      (* let绑定 - 使用正确的AsForKeyword语法 *)
      ([make_token LetKeyword 1 1; make_token (QuotedIdentifierToken "x") 1 5; 
        make_token AsForKeyword 1 7; make_token (IntToken 42) 1 9; eof_token 1 11],
       LetStmt ("x", LitExpr (IntLit 42)), "变量声明语句");
      
      (* let绑定与表达式 - 使用正确的AsForKeyword语法 *)
      ([make_token LetKeyword 1 1; make_token (QuotedIdentifierToken "sum") 1 5; 
        make_token AsForKeyword 1 9; make_token (IntToken 1) 1 11; 
        make_token Plus 1 13; make_token (IntToken 2) 1 15; eof_token 1 16],
       LetStmt ("sum", BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2))), 
       "变量声明带表达式");
    ] in
    List.iter (fun (tokens, expected, desc) ->
      let state = create_parser_with_tokens tokens in
      let stmt, _ = parse_statement state in
      check_stmt desc expected stmt
    ) test_cases
  
  let test_if_statements () =
    (* 测试if语句 *)
    let tokens = [
      make_token IfKeyword 1 1; make_token TrueKeyword 1 4; 
      make_token ThenKeyword 1 9; make_token (IntToken 1) 1 14; 
      make_token ElseKeyword 1 16; make_token (IntToken 0) 1 21; eof_token 1 22
    ] in
    let expected = ExprStmt (CondExpr (LitExpr (BoolLit true), 
                           LitExpr (IntLit 1), 
                           LitExpr (IntLit 0))) in
    let state = create_parser_with_tokens tokens in
    let stmt, _ = parse_statement state in
    check_stmt "if-then-else语句解析" expected stmt
  
  let test_expression_statements () =
    let test_cases = [
      (* 表达式语句 *)
      ([make_token (IntToken 42) 1 1; eof_token 1 3],
       ExprStmt (LitExpr (IntLit 42)), "整数表达式语句");
      
      ([make_token (QuotedIdentifierToken "func") 1 1; make_token LeftParen 1 5; 
        make_token RightParen 1 6; eof_token 1 7],
       ExprStmt (FunCallExpr (VarExpr "func", [])), "函数调用表达式语句");
    ] in
    List.iter (fun (tokens, expected, desc) ->
      let state = create_parser_with_tokens tokens in
      let stmt, _ = parse_statement state in
      check_stmt desc expected stmt
    ) test_cases
end

(** 错误处理测试模块 *)
module ErrorHandlingTests = struct
  open TestUtils
  
  let test_syntax_error_recovery () =
    (* 测试语法错误恢复机制 *)
    let invalid_tokens = [
      make_token (IntToken 1) 1 1; make_token Plus 1 3; 
      (* 缺少右操作数 *)
      eof_token 1 4
    ] in
    (* 这里应该抛出解析错误 *)
    let state = create_parser_with_tokens invalid_tokens in
    try
      let _ = parse_expression state in
      fail "应该抛出解析错误"
    with
    | SyntaxError _ -> ()
    | _ -> fail "应该抛出SyntaxError"
  
  let test_unmatched_parentheses () =
    (* 测试不匹配的括号 *)
    let invalid_tokens = [
      make_token LeftParen 1 1; make_token (IntToken 5) 1 2; 
      (* 缺少右括号 *)
      eof_token 1 3
    ] in
    let state = create_parser_with_tokens invalid_tokens in
    try
      let _ = parse_expression state in
      fail "应该抛出括号不匹配错误"
    with
    | SyntaxError _ -> ()
    | _ -> fail "应该抛出SyntaxError"
end

(** 集成测试模块 *)
module IntegrationTests = struct
  open TestUtils
  
  let test_complex_expression_parsing () =
    (* 测试复杂表达式解析 *)
    let tokens = [
      make_token (QuotedIdentifierToken "f") 1 1; make_token LeftParen 1 2; 
      make_token (IntToken 1) 1 3; make_token Plus 1 5; 
      make_token (IntToken 2) 1 7; make_token Star 1 9; 
      make_token (IntToken 3) 1 11; make_token RightParen 1 12; 
      make_token Greater 1 14; make_token (IntToken 10) 1 16; eof_token 1 18
    ] in
    let expected = BinaryOpExpr (
                            FunCallExpr (VarExpr "f", 
                                     [BinaryOpExpr (LitExpr (IntLit 1), Add,
                                               BinaryOpExpr (LitExpr (IntLit 2), Mul, LitExpr (IntLit 3)))]), Gt,
                            LitExpr (IntLit 10)) in
    let state = create_parser_with_tokens tokens in
    let expr, _ = parse_expression state in
    check_expr "复杂表达式综合解析" expected expr
  
  let test_mixed_statement_parsing () =
    (* 测试混合语句解析 *)
    let tokens = [
      make_token LetKeyword 1 1; make_token (QuotedIdentifierToken "result") 1 5; 
      make_token AsForKeyword 1 12; make_token IfKeyword 1 14; 
      make_token (QuotedIdentifierToken "x") 1 17; make_token Greater 1 19; 
      make_token (IntToken 0) 1 21; make_token ThenKeyword 1 23; 
      make_token (QuotedIdentifierToken "x") 1 28; make_token Star 1 30; 
      make_token (IntToken 2) 1 32; make_token ElseKeyword 1 34; 
      make_token (IntToken 0) 1 39; eof_token 1 40
    ] in
    let expected = LetStmt ("result", 
                           CondExpr (BinaryOpExpr (VarExpr "x", Gt, LitExpr (IntLit 0)),
                                  BinaryOpExpr (VarExpr "x", Mul, LitExpr (IntLit 2)),
                                  LitExpr (IntLit 0))) in
    let state = create_parser_with_tokens tokens in
    let stmt, _ = parse_statement state in
    check_stmt "复杂混合语句解析" expected stmt
end

(** 主测试套件 *)
let test_suite = [
  (* 基础字面量解析测试 *)
  ("基础整数字面量解析", `Quick, LiteralParsingTests.test_integer_literal_parsing);
  ("基础字符串字面量解析", `Quick, LiteralParsingTests.test_string_literal_parsing);
  ("基础布尔字面量解析", `Quick, LiteralParsingTests.test_boolean_literal_parsing);
  
  (* 运算符表达式解析测试 *)
  ("算术二元运算符解析", `Quick, OperatorExpressionTests.test_arithmetic_binary_operators);
  ("比较运算符解析", `Quick, OperatorExpressionTests.test_comparison_operators);
  ("逻辑运算符解析", `Quick, OperatorExpressionTests.test_logical_operators);
  ("一元运算符解析", `Quick, OperatorExpressionTests.test_unary_operators);
  
  (* 运算符优先级测试 *)
  ("算术运算符优先级", `Quick, OperatorPrecedenceTests.test_arithmetic_precedence);
  ("比较运算符优先级", `Quick, OperatorPrecedenceTests.test_comparison_precedence);
  ("逻辑运算符优先级", `Quick, OperatorPrecedenceTests.test_logical_precedence);
  
  (* 括号表达式测试 *)
  ("简单括号表达式", `Quick, ParenthesesTests.test_simple_parentheses);
  ("括号优先级重写", `Quick, ParenthesesTests.test_parentheses_override_precedence);
  ("嵌套括号表达式", `Quick, ParenthesesTests.test_nested_parentheses);
  
  (* 标识符和变量测试 *)
  ("简单标识符解析", `Quick, IdentifierTests.test_simple_identifiers);
  ("限定标识符解析", `Quick, IdentifierTests.test_qualified_identifiers);
  
  (* 函数调用测试 *)
  ("简单函数调用", `Quick, FunctionCallTests.test_simple_function_calls);
  ("嵌套函数调用", `Quick, FunctionCallTests.test_nested_function_calls);
  
  (* 语句解析测试 *)
  ("变量声明语句", `Quick, StatementParsingTests.test_variable_declarations);
  ("if语句解析", `Quick, StatementParsingTests.test_if_statements);
  ("表达式语句", `Quick, StatementParsingTests.test_expression_statements);
  
  (* 错误处理测试 *)
  ("语法错误恢复", `Quick, ErrorHandlingTests.test_syntax_error_recovery);
  ("不匹配括号处理", `Quick, ErrorHandlingTests.test_unmatched_parentheses);
  
  (* 集成测试 *)
  ("复杂表达式集成解析", `Slow, IntegrationTests.test_complex_expression_parsing);
  ("混合语句集成解析", `Slow, IntegrationTests.test_mixed_statement_parsing);
]

(** 运行测试 *)
let () = 
  Alcotest.run "骆言Parser核心模块全面测试覆盖 - Fix #933" [
    ("parser_core_comprehensive", test_suite);
  ]