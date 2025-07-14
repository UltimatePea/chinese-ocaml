open Yyocamlc_lib.Lexer

let debug_tokens input =
  let tokens = tokenize input "test.ly" in
  let rec print_tokens tokens =
    match tokens with
    | [] -> ()
    | (token, _pos) :: rest ->
      Printf.printf "%s " (show_token token);
      print_tokens rest
  in
  Printf.printf "Input: %s\n" input;
  Printf.printf "Tokens: ";
  print_tokens tokens;
  Printf.printf "\n"

let () =
  debug_tokens "设 「乘法」 为 函数 ~「x」:「整数」 ~「y」:「整数」 -> x * y"