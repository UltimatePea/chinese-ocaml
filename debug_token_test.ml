open Yyocamlc_lib

let input = "设「数值」为４２"

let () =
  List.iter
    (fun (token, pos) ->
      Printf.printf "%s at %d:%d\n" (Lexer.string_of_token token) pos.line pos.column)
    (Lexer.tokenize input "test")
