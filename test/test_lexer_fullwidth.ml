open Yyocamlc_lib.Lexer

(** Test script to understand full-width digit tokenization *)

let test_input = "「x」为４２"

let print_token token =
  match token with
  | QuotedIdentifierToken s -> Printf.printf "QuotedIdentifierToken(\"%s\")" s
  | AsForKeyword -> Printf.printf "AsForKeyword"
  | IntToken i -> Printf.printf "IntToken(%d)" i
  | RightQuote -> Printf.printf "RightQuote"
  | EOF -> Printf.printf "EOF"
  | _ -> Printf.printf "%s" (show_token token)

let () =
  try
    let tokens = tokenize test_input "test.cl" in
    Printf.printf "Input: \"%s\"\n" test_input;
    Printf.printf "Tokens:\n";
    List.iteri (fun i (token, pos) ->
      Printf.printf "%d. " (i + 1);
      print_token token;
      Printf.printf " at line %d, column %d\n" pos.line pos.column
    ) tokens
  with
  | LexError (msg, pos) ->
    Printf.printf "Lexer error: %s at line %d, column %d\n" msg pos.line pos.column
  | e ->
    Printf.printf "Error: %s\n" (Printexc.to_string e)