open Yyocamlc_lib.Lexer

let test_keywords = [ "为"; "吾有"; "数值" ]

let () =
  List.iter
    (fun keyword ->
      match find_keyword keyword with
      | Some token -> Printf.printf "Keyword '%s' -> %s\n" keyword (show_token token)
      | None -> Printf.printf "Keyword '%s' -> Not found\n" keyword)
    test_keywords
