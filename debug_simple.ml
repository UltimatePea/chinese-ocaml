open Yyocamlc_lib
open Lexer
open Parser

let () =
  try
    (* Test ASCII first *)
    Printf.printf "Testing ASCII: (1 + 2)\n";
    let tokens1 = tokenize "(1 + 2)" "test" in
    Printf.printf "Tokens: ";
    List.iter (fun (token, _) -> Printf.printf "%s " (show_token token)) tokens1;
    Printf.printf "\n";
    
    let parser_state1 = create_parser_state tokens1 in
    let (_ast1, _final_state1) = parse_expression parser_state1 in
    Printf.printf "ASCII parsing successful\n\n";
    
    (* Test Chinese *)
    Printf.printf "Testing Chinese: （１ ＋ ２）\n";
    let tokens2 = tokenize "（１ ＋ ２）" "test" in
    Printf.printf "Tokens: ";
    List.iter (fun (token, _) -> Printf.printf "%s " (show_token token)) tokens2;
    Printf.printf "\n";
    
    let parser_state2 = create_parser_state tokens2 in
    let (_ast2, _final_state2) = parse_expression parser_state2 in
    Printf.printf "Chinese parsing successful\n";
  with
  | e -> Printf.printf "Error: %s\n" (Printexc.to_string e)