(** 调试创建5问题 *)

open Yyocamlc_lib.Lexer

let debug_tokenize text =
  let tokens = tokenize text "<debug>" in
  Printf.printf "输入: %s\n" text;
  Printf.printf "词元: ";
  List.iter (fun (token, _) -> Printf.printf "%s " (show_token token)) tokens;
  Printf.printf "\n\n"

let () =
  debug_tokenize "创建5";
  debug_tokenize "创建3";
  debug_tokenize "让 创建5 = 创建数组 5"
