(** 调试嵌套数组解析问题 *)

open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser

let debug_parse source =
  Printf.printf "正在解析: %s\n" source;
  try
    let tokens = tokenize source "<debug>" in
    Printf.printf "词法分析成功，词元数量: %d\n" (List.length tokens);
    List.iteri (fun i (token, pos) ->
      Printf.printf "  [%d] %s (行 %d, 列 %d)\n" 
        i (show_token token) pos.line pos.column
    ) tokens;
    
    let _ast = parse_program tokens in
    Printf.printf "语法分析成功！\n";
    Printf.printf "\n"
  with
  | Yyocamlc_lib.Parser.SyntaxError (msg, pos) ->
    Printf.printf "语法错误: %s (行 %d, 列 %d)\n\n" msg pos.line pos.column
  | Yyocamlc_lib.Lexer.LexError (msg, pos) ->
    Printf.printf "词法错误: %s (行 %d, 列 %d)\n\n" msg pos.line pos.column
  | e ->
    Printf.printf "其他错误: %s\n\n" (Printexc.to_string e)

let () =
  (* 测试简单数组 *)
  debug_parse "[|1; 2|]";
  
  (* 测试嵌套数组 *)
  debug_parse "[|[|1; 2|]; [|3; 4|]|]";
  
  (* 测试完整的嵌套数组语句 *)
  debug_parse "让 矩阵 = [|[|1; 2|]; [|3; 4|]|]";