open Yyocamlc_lib

let debug_keyword_matching () =
  Printf.printf "测试各种输入的分词结果:\n";
  
  let test_cases = [
    "设";
    "数值";
    "为";
    "42";
    "设 数";
    "数 为";
  ] in
  
  List.iter (fun input ->
    Printf.printf "\n输入: '%s'\n" input;
    let tokens = Lexer.tokenize input "test" in
    List.iteri (fun i (token, _) ->
      let token_name = match token with
        | Lexer.SetKeyword -> "SetKeyword"
        | Lexer.IdentifierToken s -> "IdentifierToken(" ^ s ^ ")"
        | Lexer.AsForKeyword -> "AsForKeyword"
        | Lexer.IntToken n -> "IntToken(" ^ string_of_int n ^ ")"
        | Lexer.EOF -> "EOF"
        | _ -> "其他Token"
      in
      Printf.printf "  %d: %s\n" i token_name
    ) tokens
  ) test_cases

let () = debug_keyword_matching ()