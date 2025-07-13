open Yyocamlc_lib.Parser
open Yyocamlc_lib.Codegen
open Yyocamlc_lib.Lexer

let test_source = "让 「创建5」 = 创建数组 5"

let () =
  try
    let tokens = tokenize test_source "<debug>" in
    List.iter (fun (token, _) -> 
      print_endline (show_token token)
    ) tokens;
    print_endline "--- Parsing ---";
    let program = parse_program tokens in
    print_endline "Parse successful!"
  with
  | e -> print_endline ("Error: " ^ (Printexc.to_string e))