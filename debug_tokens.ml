open Yyocamlc_lib
open Lexer

let debug_tokens input =
  let filename = "debug" in
  let tokens = tokenize input filename in
  Printf.printf "输入: %s\n" input;
  Printf.printf "词元序列:\n";
  List.iter (fun (token, pos) ->
    Printf.printf "  %s (行:%d 列:%d)\n" 
      (show_token token) pos.line pos.column
  ) tokens;
  Printf.printf "\n"

let test_cases = [
  "数组长度";
  "数 组 长 度";  
  "数组 长度";
  "数 组长度";
  "让 数组长度 = 5";
  "让 数组 = [|1; 2; 3|]";
  "数组长度 数组";
]

let () =
  List.iter debug_tokens test_cases