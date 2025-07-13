open Yyocamlc_lib.Lexer

let test_string = "观甲之性"

let () =
  let tokens = tokenize test_string "test" in
  List.iter (fun (token, pos) ->
    Printf.printf "%s at line %d, col %d\n" 
      (show_token token) pos.line pos.column
  ) tokens