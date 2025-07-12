open Yyocamlc_lib

let () =
  let input = "设数值为42" in
  let tokens = Lexer.tokenize input "test" in
  List.iter (fun (token, pos) ->
    Printf.printf "%s at line %d, col %d\n" 
      (Lexer.show_token token) pos.line pos.column
  ) tokens