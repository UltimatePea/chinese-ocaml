(** 调试数组解析问题 *)

open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser

let debug_parse source =
  Printf.printf "\n=== 调试解析 ===\n";
  Printf.printf "源码: %s\n" source;

  Printf.printf "\n--- 词法分析 ---\n";
  let tokens = tokenize source "<debug>" in
  List.iteri
    (fun i (token, pos) ->
      Printf.printf "%d. %s (行%d 列%d)\n" i (show_token token) pos.line pos.column)
    tokens;

  Printf.printf "\n--- 语法分析 ---\n";
  try
    let program = parse_program tokens in
    Printf.printf "解析成功\n";
    Printf.printf "AST: %s\n" (Yyocamlc_lib.Ast.show_program program)
  with
  | SyntaxError (msg, pos) -> Printf.printf "语法错误: %s (行%d 列%d)\n" msg pos.line pos.column
  | e -> Printf.printf "其他错误: %s\n" (Printexc.to_string e)

let () =
  debug_parse "让 第一个 = 数组.(0)";
  debug_parse "让 创建5 = 创建数组 5";
  debug_parse "数组.(0)"
