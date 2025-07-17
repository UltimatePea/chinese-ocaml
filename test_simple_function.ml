open Yyocamlc_lib

let () =
  (* Test just the function part *)
  let simple_func = "函数 「n」 故 「n」" in
  print_endline ("Testing: " ^ simple_func);
  try
    let tokens = Lexer.tokenize simple_func "test" in
    let parser_state = Parser.create_parser_state tokens in
    let expr, _ = Parser.parse_function_expression parser_state in
    print_endline "Function parsing successful!"
  with e -> print_endline ("Error: " ^ Printexc.to_string e)
