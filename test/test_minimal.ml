open Yyocamlc_lib

let test_source = "让 「数组一」 为 （「创建数组」 「五」） 「零」"

let () =
  try
    let tokens = Lexer.tokenize test_source "<test>" in
    Printf.printf "Tokenization successful: %d tokens\n" (List.length tokens)
  with
  | Lexer.LexError (msg, _) -> Printf.printf "Lexer error: %s\n" msg
  | e -> Printf.printf "Other error: %s\n" (Printexc.to_string e)
