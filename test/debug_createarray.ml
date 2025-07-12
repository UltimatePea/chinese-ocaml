(** 调试创建数组问题 *)

open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser

let debug_parse source =
  Printf.printf "\n=== 调试解析 ===\n";
  Printf.printf "源码: %s\n" source;
  
  Printf.printf "\n--- 词法分析 ---\n";
  let tokens = tokenize source "<debug>" in
  List.iteri (fun i (token, pos) ->
    Printf.printf "%d. %s (行%d 列%d)\n" i (show_token token) pos.line pos.column
  ) tokens;
  
  Printf.printf "\n--- 语法分析 ---\n";
  try
    let _program = parse_program tokens in
    Printf.printf "解析成功\n"
  with
  | SyntaxError (msg, pos) ->
    Printf.printf "语法错误: %s (行%d 列%d)\n" msg pos.line pos.column

let () =
  debug_parse "
让 数组 = [|1; 2; 3|]
让 创建5 = 创建数组 5
让 创建3 = 创建数组 3
让 数组1 = 创建5 0
让 数组2 = 创建3 \"空\"
打印 数组1
打印 数组2
";