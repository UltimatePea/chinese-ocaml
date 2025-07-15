open Yyocamlc_lib.Lexer

let debug_code = "为"

let () =
  Printf.printf "调试代码: %s\n\n" debug_code;
  let tokens = tokenize debug_code "test.ly" in
  List.iteri (fun i (token, _pos) -> Printf.printf "%d: %s\n" i (show_token token)) tokens
