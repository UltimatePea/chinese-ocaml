open Yyocamlc_lib
open Lexer

let test_chinese_punctuation () =
  let test_inputs = [
    ("（", "Chinese left paren");
    ("）", "Chinese right paren");
    ("「", "Chinese left bracket");
    ("」", "Chinese right bracket");
    ("『", "Chinese left brace");
    ("』", "Chinese right brace");
    ("：", "Chinese colon");
    ("，", "Chinese comma");
    ("；", "Chinese semicolon");
    ("｜", "Chinese pipe");
    ("→", "Chinese arrow");
    ("⇒", "Chinese double arrow");
    ("←", "Chinese assign arrow");
  ] in
  
  List.iter (fun (input, desc) ->
    try
      let tokens = tokenize input "test" in
      Printf.printf "%s (%s): " desc input;
      List.iter (fun (token, _) ->
        match token with
        | ChineseLeftParen -> Printf.printf "ChineseLeftParen "
        | ChineseRightParen -> Printf.printf "ChineseRightParen "
        | ChineseLeftBracket -> Printf.printf "ChineseLeftBracket "
        | ChineseRightBracket -> Printf.printf "ChineseRightBracket "
        | ChineseLeftBrace -> Printf.printf "ChineseLeftBrace "
        | ChineseRightBrace -> Printf.printf "ChineseRightBrace "
        | ChineseColon -> Printf.printf "ChineseColon "
        | ChineseComma -> Printf.printf "ChineseComma "
        | ChineseSemicolon -> Printf.printf "ChineseSemicolon "
        | ChinesePipe -> Printf.printf "ChinesePipe "
        | ChineseArrow -> Printf.printf "ChineseArrow "
        | ChineseDoubleArrow -> Printf.printf "ChineseDoubleArrow "
        | ChineseAssignArrow -> Printf.printf "ChineseAssignArrow "
        | EOF -> Printf.printf "EOF "
        | _ -> Printf.printf "Other "
      ) tokens;
      Printf.printf "\n"
    with
    | e -> Printf.printf "%s (%s): ERROR - %s\n" desc input (Printexc.to_string e)
  ) test_inputs

let () = test_chinese_punctuation ()