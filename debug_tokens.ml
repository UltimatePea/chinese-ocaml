open Lexer

let test_input = "观「lst」之性"

let debug_tokenize input =
  let state = create_lexer_state input "debug.ly" in
  let rec collect_tokens acc state =
    match next_token state with
    | (EOF, _, _) -> List.rev (EOF :: acc)
    | (token, _, new_state) -> 
        collect_tokens (token :: acc) new_state
  in
  collect_tokens [] state

let () =
  Printf.printf "测试输入: %s\n" test_input;
  Printf.printf "词法分析结果:\n";
  let tokens = debug_tokenize test_input in
  List.iteri (fun i token -> 
    Printf.printf "%d: %s\n" i (show_token token)
  ) tokens