open Yyocamlc_lib

let () =
  Printf.printf "Testing tokenization of wenyan keywords...\n";
  
  let test_input input =
    Printf.printf "\nInput: %s\n" input;
    let tokens = Lexer.tokenize input "debug" in
    List.iter (fun (token, pos) ->
      let token_str = match token with
        | Lexer.SheKeyword -> "SheKeyword(设)"
        | Lexer.WeiKeyword -> "WeiKeyword(为)"
        | Lexer.Identifier s -> Printf.sprintf "Identifier(%s)" s
        | Lexer.IntLit i -> Printf.sprintf "IntLit(%d)" i
        | _ -> "Other"
      in
      Printf.printf "  Token: %s at line %d, col %d\n" token_str pos.line pos.column
    ) tokens
  in
  
  test_input "设";
  test_input "为";
  test_input "设数值为42";