open Yyocamlc_lib.Lexer

let () =
  let input = "「x」为４２" in
  let tokens = tokenize input "test" in
  Printf.printf "Number of tokens: %d\n" (List.length tokens);
  List.iteri
    (fun i (token, pos) ->
      Printf.printf "%d: %s at line %d, column %d\n" i (show_token token) pos.line pos.column)
    tokens

