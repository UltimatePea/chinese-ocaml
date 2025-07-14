let () = 
  let tokens = Yyocamlc_lib.Lexer.tokenize "二" "test" in
  List.iter (fun (token, _) -> 
    Printf.printf "Token: %s\n" (Yyocamlc_lib.Lexer.show_token token)
  ) tokens;
  match tokens with
  | [(Yyocamlc_lib.Lexer.ChineseNumberToken s, _)] ->
    Printf.printf "Chinese number string: [%s]\n" s;
    Printf.printf "String length: %d\n" (String.length s);
    let chars = List.of_seq (String.to_seq s) in
    List.iteri (fun i c -> Printf.printf "Char %d: [%c] (code: %d)\n" i c (Char.code c)) chars
  | _ -> Printf.printf "Unexpected token structure\n"