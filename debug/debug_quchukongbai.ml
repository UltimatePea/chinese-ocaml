open Yyocamlc_lib.Lexer

let () =
  let source = "让 结果 = 去除空白 \"hello\"" in
  Printf.printf "正在分析: %s\n" source;
  let tokens = tokenize source "<test>" in
  List.iter (fun (token, pos) ->
    Printf.printf "  Token: %s (行 %d, 列 %d)\n"
      (show_token token) pos.line pos.column
  ) tokens