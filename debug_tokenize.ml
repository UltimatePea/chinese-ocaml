open Yyocamlc_lib.Lexer

let debug_tokenize input =
  let tokens = tokenize input "debug" in
  List.iteri (fun i (token, pos) ->
    Printf.printf "%d: %s (行:%d, 列:%d)\n" i (show_token token) pos.line pos.column
  ) tokens

let () =
  debug_tokenize "数组长度 数组"