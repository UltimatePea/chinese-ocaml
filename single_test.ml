open Alcotest
open Yyocamlc_lib

let test_baseline () =
  let test_program = "设 甲 = 一 + 二" in
  print_endline ("Testing: " ^ test_program);
  print_endline
    ("Program bytes: "
    ^ String.concat " "
        (List.map (fun c -> string_of_int (Char.code c)) (List.of_seq (String.to_seq test_program)))
    );
  try
    let tokens = Lexer.tokenize "test_简单算术.ly" test_program in
    print_endline ("Success! Tokens: " ^ string_of_int (List.length tokens))
  with
  | Lexer_tokens.LexError (msg, pos) ->
      print_endline ("LexError: " ^ msg ^ " at position " ^ string_of_int pos);
      failwith ("Baseline test failed: " ^ msg)
  | exn ->
      print_endline ("Other error: " ^ Printexc.to_string exn);
      failwith ("Baseline test failed: " ^ Printexc.to_string exn)

let () = test_baseline ()
