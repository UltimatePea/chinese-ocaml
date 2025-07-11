(** 豫语编译器测试 *)

open Yyocamlc_lib
open Alcotest

(** 测试词法分析器 *)
let test_lexer () =
  let input = "让 x = 42" in
  let token_list = Lexer.tokenize input "test" in
  let expected_tokens = [
    (Lexer.LetKeyword, { Lexer.line = 1; column = 1; filename = "test" });
    (Lexer.IdentifierToken "x", { Lexer.line = 1; column = 3; filename = "test" });
    (Lexer.Assign, { Lexer.line = 1; column = 5; filename = "test" });
    (Lexer.IntToken 42, { Lexer.line = 1; column = 7; filename = "test" });
    (Lexer.EOF, { Lexer.line = 1; column = 9; filename = "test" });
  ] in
  check int "词元数量" (List.length expected_tokens) (List.length token_list)

(** 测试解析器 *)
let test_parser () =
  let input = "让 x = 42" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [Ast.LetStmt ("x", Ast.LitExpr (Ast.IntLit 42))] -> ()
  | _ -> failwith "解析结果不匹配"

(** 测试基本表达式求值 *)
let test_basic_evaluation () =
  let expr = Ast.BinaryOpExpr (
    Ast.LitExpr (Ast.IntLit 1),
    Ast.Add,
    Ast.LitExpr (Ast.IntLit 2)
  ) in
  let result = Codegen.eval_expr [] expr in
  match result with
  | Codegen.IntValue 3 -> ()
  | _ -> failwith "求值结果不正确"

(** 测试套件 *)
let () =
  run "豫语编译器测试" [
    ("词法分析器", [
      test_case "基本词法分析" `Quick test_lexer;
    ]);
    ("语法分析器", [
      test_case "基本语法分析" `Quick test_parser;
    ]);
    ("代码生成器", [
      test_case "基本表达式求值" `Quick test_basic_evaluation;
    ]);
  ]