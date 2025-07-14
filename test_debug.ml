open Yyocamlc_lib

let () =
  let input = "让 「x」 为 ４２" in
  Printf.printf "测试输入: %s\n" input;

  try
    let tokens = Lexer.tokenize input "test" in
    Printf.printf "词法分析结果:\n";
    List.iter
      (fun (token, pos) ->
        let token_str =
          match token with
          | Lexer.LetKeyword -> "LetKeyword"
          | Lexer.QuotedIdentifierToken s -> "QuotedIdentifierToken(\"" ^ s ^ "\")"
          | Lexer.AsForKeyword -> "AsForKeyword"
          | Lexer.Assign -> "Assign"
          | Lexer.IntToken i -> "IntToken(" ^ string_of_int i ^ ")"
          | Lexer.EOF -> "EOF"
          | _ -> "Other"
        in
        Printf.printf "  %s\n" token_str)
      tokens;
    Printf.printf "\n";

    let program = Parser.parse_program tokens in
    Printf.printf "语法分析成功!\n"
  with e -> Printf.printf "错误: %s\n" (Printexc.to_string e)
