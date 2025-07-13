(** 调试关键字匹配问题 *)

open Yyocamlc_lib.Lexer

let debug_tokenize input =
  Printf.printf "输入: %s\n" input;
  let tokens = tokenize input "debug.luo" in
  List.iteri (fun i (token, pos) ->
    Printf.printf "%d: %s (行%d 列%d)\n" i (show_token token) pos.line pos.column
  ) tokens;
  Printf.printf "\n"

let () =
  Printf.printf "=== 调试关键字匹配 ===\n\n";
  
  (* 测试 "设数值为42" *)
  debug_tokenize "设数值为42";
  
  (* 测试单独的 "数值" *)
  debug_tokenize "数值";
  
  (* 测试单独的 "数" *)
  debug_tokenize "数";
  
  (* 测试 "数值类型" *)
  debug_tokenize "数值类型";
  
  (* 测试 "数组" *)
  debug_tokenize "数组";