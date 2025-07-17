open Yyocamlc_lib

let test_simple () =
  let tokens = [
    (Lexer.QuotedIdentifierToken "print", { line = 1; column = 1; filename = "test" });
    (Lexer.LeftParen, { line = 1; column = 6; filename = "test" });
    (Lexer.StringToken "hello", { line = 1; column = 7; filename = "test" });
    (Lexer.RightParen, { line = 1; column = 14; filename = "test" });
    (Lexer.EOF, { line = 1; column = 15; filename = "test" });
  ] in
  let state = Parser.create_parser_state tokens in
  let expr, final_state = Parser.parse_expression state in
  print_endline ("Result: " ^ (Ast.pp_expr expr))

let () = test_simple ()