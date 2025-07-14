open Yyocamlc_lib

let () =
  let input = "让 传统 = 100\n设wenyan为200" in
  Printf.printf "输入: '%s'\n" input;
  let tokens = Lexer.tokenize input "test" in
  Printf.printf "Tokens:\n";
  List.iteri
    (fun i (token, pos) ->
      Printf.printf "  [%d] %s at line %d, col %d\n" i (Lexer.show_token token) pos.Lexer.line
        pos.Lexer.column)
    tokens
