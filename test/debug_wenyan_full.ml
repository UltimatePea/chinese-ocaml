open Yyocamlc_lib

let () =
  let input = "吾有一数名曰数值其值42也在数值" in
  Printf.printf "调试输入: '%s'\n" input;
  let tokens = Lexer.tokenize input "test" in
  Printf.printf "Tokens:\n";
  List.iteri (fun i (token, _pos) ->
    Printf.printf "  [%d] %s\n" i (Lexer.show_token token)
  ) tokens