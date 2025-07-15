open Yyocamlc_lib.Lexer

let test_char char_str =
  try
    let tokens = tokenize char_str "test" in
    Printf.printf "Success for '%s': %s\n" char_str 
      (String.concat " " (List.map (fun (token, _) -> show_token token) tokens))
  with
  | LexError (msg, pos) ->
    Printf.printf "Error for '%s': %s at line %d, col %d\n" 
      char_str msg pos.line pos.column
  | e ->
    Printf.printf "Other error for '%s': %s\n" char_str (Printexc.to_string e)

let () =
  test_char "最终";
  test_char "异常";
  test_char "抛出";
  test_char "捕获";
  test_char "|";
  test_char "「测试」";