open Yyocamlc_lib.Lexer

let test_source = "让 数组 = [|1; 2; 3|]; 让 长度 = 数组长度 数组"

let () =
  print_endline "Testing lexer with: ";
  print_endline test_source;
  print_endline "Tokens:";
  let tokens = tokenize test_source "<test>" in
  List.iteri (fun i (token, _) -> 
    Printf.printf "%d: %s\n" i (match token with
      | IdentifierToken s -> "IdentifierToken(" ^ s ^ ")"
      | LetKeyword -> "LetKeyword"
      | Assign -> "Assign"
      | LeftArray -> "LeftArray"
      | IntToken n -> "IntToken(" ^ string_of_int n ^ ")"
      | Semicolon -> "Semicolon"
      | RightArray -> "RightArray"
      | EOF -> "EOF"
      | _ -> "Other")
  ) tokens