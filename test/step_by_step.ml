open Yyocamlc_lib.Lexer

let test_inputs = ["为"; "为４２"; "「x」为"; "「x」为４２"]

let print_token_simple token =
  match token with
  | AsForKeyword -> "AsForKeyword"
  | IntToken i -> Printf.sprintf "IntToken(%d)" i
  | QuotedIdentifierToken s -> Printf.sprintf "QuotedIdentifierToken(\"%s\")" s
  | IdentifierToken s -> Printf.sprintf "IdentifierToken(\"%s\")" s
  | EOF -> "EOF"
  | _ -> show_token token

let () =
  List.iter (fun input ->
    Printf.printf "\nInput: \"%s\"\n" input;
    try
      let tokens = tokenize input "test.cl" in
      List.iteri (fun i (token, pos) ->
        Printf.printf "  %d. %s at line %d, column %d\n" 
          (i + 1) (print_token_simple token) pos.line pos.column
      ) tokens
    with
    | LexError (msg, pos) ->
      Printf.printf "  Lexer error: %s at line %d, column %d\n" msg pos.line pos.column
  ) test_inputs