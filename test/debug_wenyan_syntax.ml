open Yyocamlc_lib

let debug_wenyan_syntax () =
  Printf.printf "调试Wenyan语法问题:\n";
  
  let test_input = "设数值为42" in
  
  Printf.printf "源代码: '%s'\n\n" test_input;
  
  Printf.printf "词法分析结果:\n";
  let tokens = Lexer.tokenize test_input "test" in
  List.iteri (fun i (token, _) ->
    let token_name = match token with
      | Lexer.SetKeyword -> "SetKeyword"
      | Lexer.IdentifierToken s -> Printf.sprintf "IdentifierToken(%s)" s
      | Lexer.AsForKeyword -> "AsForKeyword"
      | Lexer.IntToken n -> Printf.sprintf "IntToken(%d)" n
      | Lexer.NumberKeyword -> "NumberKeyword"
      | Lexer.EOF -> "EOF"
      | _ -> "其他Token"
    in
    Printf.printf "  %d: %s\n" i token_name
  ) tokens;
  
  Printf.printf "\n语法分析:\n";
  try
    let _ = Parser.parse_program tokens in
    Printf.printf "解析成功!\n"
  with
  | Parser.SyntaxError (msg, pos) ->
    Printf.printf "语法错误 (行:%d, 列:%d): %s\n" pos.line pos.column msg
  | e ->
    Printf.printf "其他错误: %s\n" (Printexc.to_string e)

let () = debug_wenyan_syntax ()