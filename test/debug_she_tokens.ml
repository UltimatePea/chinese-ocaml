open Yyocamlc_lib

let debug_she_tokens () =
  Printf.printf "调试'设数值为42'分词过程:\n\n";
  
  let test_inputs = [
    "设";
    "数";
    "值";
    "为";
    "42";
    "数值";
    "设数值";
    "数值为";
    "值为42";
    "设数值为42";
  ] in
  
  List.iter (fun input ->
    Printf.printf "输入: '%s'\n" input;
    let tokens = Lexer.tokenize input "test" in
    List.iter (fun (token, _) ->
      let token_name = match token with
        | Lexer.SetKeyword -> "SetKeyword"
        | Lexer.IdentifierToken s -> Printf.sprintf "IdentifierToken(%s)" s
        | Lexer.AsForKeyword -> "AsForKeyword"
        | Lexer.IntToken n -> Printf.sprintf "IntToken(%d)" n
        | Lexer.NumberKeyword -> "NumberKeyword"
        | Lexer.EOF -> "EOF"
        | _ -> "其他Token"
      in
      Printf.printf "  -> %s\n" token_name
    ) tokens;
    Printf.printf "\n"
  ) test_inputs

let () = debug_she_tokens ()