open Yyocamlc_lib.Lexer

let debug_tokenize text =
  Printf.printf "=== 调试词法分析: \"%s\" ===\n" text;
  let tokens = ref [] in
  let state = create_state text in
  let rec loop state =
    match next_token state with
    | (EOF, _) -> List.rev !tokens
    | (token, new_state) ->
      tokens := token :: !tokens;
      loop new_state
  in
  let result = loop state in
  List.iteri (fun i token ->
    Printf.printf "%d: %s\n" i (token_to_string token)
  ) result;
  Printf.printf "\n"

let () =
  debug_tokenize "平方根值";
  debug_tokenize "平方根";
  debug_tokenize "值";
  debug_tokenize "让 平方根值 = 平方根 2.0";