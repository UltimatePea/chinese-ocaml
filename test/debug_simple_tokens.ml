open Yyocamlc_lib
open Lexer

let () =
  try
    Printf.printf "Testing: （1 + 2）\n";
    let tokens = tokenize "（1 + 2）" "test" in
    Printf.printf "Tokens: ";
    List.iter
      (fun (token, _) ->
        match token with
        | IntToken n -> Printf.printf "IntToken(%d) " n
        | IdentifierToken s -> Printf.printf "IdentifierToken(%s) " s
        | ChineseLeftParen -> Printf.printf "ChineseLeftParen "
        | ChineseRightParen -> Printf.printf "ChineseRightParen "
        | Plus -> Printf.printf "Plus "
        | EOF -> Printf.printf "EOF "
        | _ -> Printf.printf "Other(%s) " (show_token token))
      tokens;
    Printf.printf "\n"
  with e -> Printf.printf "Error: %s\n" (Printexc.to_string e)
