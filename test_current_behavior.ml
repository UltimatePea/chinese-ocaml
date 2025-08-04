open Yyocamlc_lib.Lexer

let test_char char_str =
  try
    let tokens = tokenize char_str "<test>" in
    Printf.printf "Character '%s' succeeded: %d tokens\n" char_str (List.length tokens)
  with
  | LexError (msg, _) -> Printf.printf "Character '%s' failed with LexError: %s\n" char_str msg
  | e -> Printf.printf "Character '%s' failed with: %s\n" char_str (Printexc.to_string e)

let () =
  Printf.printf "Testing current Unicode-enhanced lexer behavior:\n";
  test_char "+";
  test_char "==";
  test_char "1";
  test_char "（"
