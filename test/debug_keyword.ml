open Yyocamlc_lib

let () =
  let keywords = [ "设"; "数值"; "为"; "数" ] in
  List.iter
    (fun kw ->
      match Lexer.find_keyword kw with
      | Some token -> Printf.printf "'%s' -> %s\n" kw (Lexer.show_token token)
      | None -> Printf.printf "'%s' -> NOT FOUND\n" kw)
    keywords
