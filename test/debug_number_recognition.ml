(** 调试数字识别问题 *)

open Yyocamlc_lib.Lexer

let debug_tokenize text =
  let tokens = tokenize text "<debug>" in
  Printf.printf "输入: %s\n" text;
  Printf.printf "词元: ";
  List.iter (fun (token, _) -> Printf.printf "%s " (show_token token)) tokens;
  Printf.printf "\n\n"

let () =
  debug_tokenize "0";
  debug_tokenize "1";
  debug_tokenize "42";
  debug_tokenize "数组.(0)";
  debug_tokenize "数组.(1)";
  debug_tokenize "数组.(42)";
  debug_tokenize "一";
  debug_tokenize "二";
  debug_tokenize "三"
