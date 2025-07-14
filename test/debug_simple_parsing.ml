open Yyocamlc_lib
open Lexer
open Parser

let () =
  try
    Printf.printf "Testing parsing: 【1； 2； 3】\n";
    let tokens = tokenize "【1； 2； 3】" "test" in
    Printf.printf "Tokens: ";
    List.iter (fun (token, _) ->
      match token with
      | IntToken n -> Printf.printf "IntToken(%d) " n
      | LeftQuote -> Printf.printf "LeftQuote "
      | RightQuote -> Printf.printf "RightQuote "
      | Comma -> Printf.printf "Comma "
      | EOF -> Printf.printf "EOF "
      | _ -> Printf.printf "Other(%s) " (show_token token)
    ) tokens;
    Printf.printf "\n";
    
    Printf.printf "Attempting to parse...\n";
    let parser_state = create_parser_state tokens in
    let (_ast, _final_state) = parse_expression parser_state in
    Printf.printf "✓ Parsing successful!\n";
  with
  | e -> Printf.printf "✗ Error: %s\n" (Printexc.to_string e)