open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser

let test_parse_simple_expression () =
  let tokens =
    [
      (IntToken 42, { line = 1; column = 1; filename = "test" });
      (EOF, { line = 1; column = 3; filename = "test" });
    ]
  in
  let state = create_parser_state tokens in
  let expr, _ = parse_expression state in
  check (testable pp_expr equal_expr) "简单整数表达式解析" (LitExpr (IntLit 42)) expr

let test_parse_string_expression () =
  let tokens =
    [
      (StringToken "hello", { line = 1; column = 1; filename = "test" });
      (EOF, { line = 1; column = 8; filename = "test" });
    ]
  in
  let state = create_parser_state tokens in
  let expr, _ = parse_expression state in
  check (testable pp_expr equal_expr) "字符串表达式解析" (LitExpr (StringLit "hello")) expr

let test_parse_variable_expression () =
  let tokens =
    [
      (QuotedIdentifierToken "x", { line = 1; column = 1; filename = "test" });
      (EOF, { line = 1; column = 2; filename = "test" });
    ]
  in
  let state = create_parser_state tokens in
  let expr, _ = parse_expression state in
  check (testable pp_expr equal_expr) "变量表达式解析" (VarExpr "x") expr

let test_parse_binary_operation () =
  let tokens =
    [
      (IntToken 1, { line = 1; column = 1; filename = "test" });
      (Plus, { line = 1; column = 3; filename = "test" });
      (IntToken 2, { line = 1; column = 5; filename = "test" });
      (EOF, { line = 1; column = 6; filename = "test" });
    ]
  in
  let state = create_parser_state tokens in
  let expr, _ = parse_expression state in
  check (testable pp_expr equal_expr) "二元运算表达式解析"
    (BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)))
    expr

let test_parse_function_call () =
  let tokens =
    [
      (QuotedIdentifierToken "print", { line = 1; column = 1; filename = "test" });
      (LeftParen, { line = 1; column = 6; filename = "test" });
      (StringToken "hello", { line = 1; column = 7; filename = "test" });
      (RightParen, { line = 1; column = 14; filename = "test" });
      (EOF, { line = 1; column = 15; filename = "test" });
    ]
  in
  let state = create_parser_state tokens in
  let expr, _ = parse_expression state in
  check (testable pp_expr equal_expr) "函数调用表达式解析"
    (FunCallExpr (VarExpr "print", [ LitExpr (StringLit "hello") ]))
    expr

let test_parse_let_statement () =
  let tokens =
    [
      (LetKeyword, { line = 1; column = 1; filename = "test" });
      (QuotedIdentifierToken "x", { line = 1; column = 5; filename = "test" });
      (AsForKeyword, { line = 1; column = 7; filename = "test" });
      (IntToken 42, { line = 1; column = 9; filename = "test" });
      (EOF, { line = 1; column = 11; filename = "test" });
    ]
  in
  let state = create_parser_state tokens in
  let stmt, _ = parse_statement state in
  check (testable pp_stmt equal_stmt) "let语句解析" (LetStmt ("x", LitExpr (IntLit 42))) stmt

let test_parse_complex_expression () =
  let tokens =
    [
      (LeftParen, { line = 1; column = 1; filename = "test" });
      (IntToken 1, { line = 1; column = 2; filename = "test" });
      (Plus, { line = 1; column = 4; filename = "test" });
      (IntToken 2, { line = 1; column = 6; filename = "test" });
      (RightParen, { line = 1; column = 7; filename = "test" });
      (Multiply, { line = 1; column = 9; filename = "test" });
      (IntToken 3, { line = 1; column = 11; filename = "test" });
      (EOF, { line = 1; column = 12; filename = "test" });
    ]
  in
  let state = create_parser_state tokens in
  let expr, _ = parse_expression state in
  check (testable pp_expr equal_expr) "复杂表达式解析"
    (BinaryOpExpr
       (BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)), Mul, LitExpr (IntLit 3)))
    expr

let test_parse_simple_program () =
  let tokens =
    [
      (LetKeyword, { line = 1; column = 1; filename = "test" });
      (QuotedIdentifierToken "x", { line = 1; column = 5; filename = "test" });
      (AsForKeyword, { line = 1; column = 7; filename = "test" });
      (IntToken 42, { line = 1; column = 9; filename = "test" });
      (Semicolon, { line = 1; column = 11; filename = "test" });
      (QuotedIdentifierToken "x", { line = 2; column = 1; filename = "test" });
      (EOF, { line = 2; column = 2; filename = "test" });
    ]
  in
  let program = parse_program tokens in
  check
    (testable pp_program equal_program)
    "简单程序解析"
    [ LetStmt ("x", LitExpr (IntLit 42)); ExprStmt (VarExpr "x") ]
    program

let test_parse_error_handling () =
  let tokens =
    [
      (IntToken 1, { line = 1; column = 1; filename = "test" });
      (Plus, { line = 1; column = 3; filename = "test" });
      (EOF, { line = 1; column = 4; filename = "test" });
    ]
  in
  let test_function () = ignore (parse_program tokens) in
  check_raises "语法错误处理" (Failure "") (fun () ->
      try test_function () with SyntaxError (_, _) -> raise (Failure "") | other -> raise other)

let () =
  run "Parser模块单元测试"
    [
      ( "基本表达式解析测试",
        [
          test_case "简单整数表达式" `Quick test_parse_simple_expression;
          test_case "字符串表达式" `Quick test_parse_string_expression;
          test_case "变量表达式" `Quick test_parse_variable_expression;
          test_case "二元运算表达式" `Quick test_parse_binary_operation;
          test_case "函数调用表达式" `Quick test_parse_function_call;
          test_case "复杂表达式" `Quick test_parse_complex_expression;
        ] );
      ( "语句解析测试",
        [
          test_case "let语句解析" `Quick test_parse_let_statement;
          test_case "简单程序解析" `Quick test_parse_simple_program;
        ] );
      ("错误处理测试", [ test_case "语法错误处理" `Quick test_parse_error_handling ]);
    ]
