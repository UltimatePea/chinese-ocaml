open Yyocamlc_lib
open Lexer
open Parser

let test_chinese_expressions () =
  let test_inputs = [
    ("（１ ＋ ２）", "Simple arithmetic with Chinese parentheses and fullwidth numbers");
    ("（１ ＋ ２）", "Simple arithmetic with Chinese parentheses and fullwidth numbers");
  ] in
  
  List.iter (fun (input, desc) ->
    try
      Printf.printf "Testing %s: %s\n" desc input;
      let tokens = tokenize input "test" in
      Printf.printf "  Tokens: ";
      List.iter (fun (token, _) ->
        let token_name = match token with
          | ChineseLeftParen -> "（"
          | ChineseRightParen -> "）"
          | LeftQuote -> "「"
          | RightQuote -> "」"
          | ChineseColon -> "："
          | ChineseComma -> "，"
          | ChineseSemicolon -> "；"
          | ChineseArrow -> "→"
          | LetKeyword -> "让"
          | IntToken n -> string_of_int n
          | Plus -> "+"
          | IdentifierToken s -> s
          | StringToken s -> "\"" ^ s ^ "\""
          | EOF -> "EOF"
          | _ -> "Other"
        in
        Printf.printf "%s " token_name
      ) tokens;
      Printf.printf "\n";
      
      (* Try parsing as expression only *)
      let parser_state = create_parser_state tokens in
      let (_ast, _final_state) = parse_expression parser_state in
      Printf.printf "  ✓ Parsing successful\n\n"
    with
    | e -> Printf.printf "  ✗ Error: %s\n\n" (Printexc.to_string e)
  ) test_inputs

let () = test_chinese_expressions ()
