open Yyocamlc_lib

let test_keywords () =
  let keywords_to_test = [
    ("设", "SheKeyword");
    ("为", "WeiKeyword");
    ("让", "LetKeyword");
  ] in
  List.iter (fun (keyword, expected) ->
    let tokens = Lexer.tokenize keyword "test" in
    match tokens with
    | [(actual_token, _); (Lexer.EOF, _)] ->
      let actual_str = match actual_token with
        | Lexer.SheKeyword -> "SheKeyword"
        | Lexer.WeiKeyword -> "WeiKeyword" 
        | Lexer.LetKeyword -> "LetKeyword"
        | Lexer.Identifier s -> "Identifier(" ^ s ^ ")"
        | _ -> "Unknown"
      in
      Printf.printf "%s -> %s (expected %s) %s\n" 
        keyword actual_str expected 
        (if actual_str = expected then "✓" else "✗")
    | _ -> Printf.printf "%s -> ERROR: unexpected token count\n" keyword
  ) keywords_to_test

let () = test_keywords ()