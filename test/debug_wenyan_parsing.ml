open Yyocamlc_lib

let debug_parse input =
  Printf.printf "调试解析: '%s'\n" input;
  let tokens = Lexer.tokenize input "test" in
  Printf.printf "Tokens:\n";
  List.iteri (fun i (token, _pos) ->
    Printf.printf "  [%d] %s\n" i (Lexer.show_token token)
  ) tokens;
  
  let state = Parser.create_parser_state tokens in
  try
    let (ast, _final_state) = Parser.parse_expression state in
    Printf.printf "解析成功: %s\n" (Ast.show_expr ast);
    Printf.printf "解析完成\n"
  with
  | Parser.SyntaxError (msg, pos) -> Printf.printf "语法错误: %s at line %d\n" msg pos.line
  | e -> Printf.printf "其他错误: %s\n" (Printexc.to_string e)

let () =
  debug_parse "设数值为42";
  Printf.printf "\n";
  debug_parse "吾有一数名曰数值其值42也"