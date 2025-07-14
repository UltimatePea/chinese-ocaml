open Yyocamlc_lib

let debug_parse source =
  print_endline ("=== 调试源代码: " ^ source ^ " ===");
  let token_list = Lexer.tokenize source "debug" in
  Printf.printf "词法分析生成了 %d 个令牌\n" (List.length token_list);
  
  try
    let program = Parser.parse_program token_list in
    print_endline "=== 语法分析结果 ===";
    List.iter (fun stmt ->
      match stmt with
      | Ast.LetStmt (name, expr) ->
          Printf.printf "LetStmt(\"%s\", %s)\n" name (match expr with
            | Ast.LitExpr (Ast.IntLit i) -> Printf.sprintf "IntLit(%d)" i
            | Ast.LitExpr (Ast.StringLit s) -> Printf.sprintf "StringLit(\"%s\")" s
            | _ -> "Other expression")
      | _ -> print_endline "Other statement"
    ) program
  with
  | e -> Printf.printf "解析错误: %s\n" (Printexc.to_string e)

let () =
  debug_parse "设「数值」为 四";
  debug_parse "设问候为「你好世界」"