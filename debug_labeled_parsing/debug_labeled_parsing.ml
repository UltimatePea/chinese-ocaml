open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser

let debug_labeled_parsing input =
  Printf.printf "Input: %s\n" input;
  let tokens = tokenize input "test.ly" in
  Printf.printf "Tokens: ";
  List.iter (fun (token, _pos) -> 
    match token with
    | QuotedIdentifierToken name -> Printf.printf "QuotedIdentifierToken(\"%s\") " name
    | IdentifierToken name -> Printf.printf "IdentifierToken(\"%s\") " name
    | _ -> Printf.printf "%s " (show_token token)
  ) tokens;
  Printf.printf "\n";
  try
    let _ast = parse_program tokens in
    Printf.printf "Parsing successful!\n";
    Printf.printf "AST parsed successfully (showing structure is complex)\n"
  with e ->
    Printf.printf "Parsing failed: %s\n" (Printexc.to_string e)

let () =
  debug_labeled_parsing "设 「乘法」 为 函数 ~「x」:「整数」 -> x";
  debug_labeled_parsing "设 「乘法」 为 函数 ~「x」:「整数」 ~「y」:「整数」 -> x * y"