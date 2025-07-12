open Yyocamlc_lib.Lexer

let test_source = {|异常 匹配失败 of 字符串

让 处理值 = 函数 x ->
  匹配 x 与
  | 0 -> 抛出 (匹配失败 "零值")|}

let () =
  try
    let tokens = tokenize test_source "debug" in
    List.iteri (fun i (token, pos) ->
      Printf.printf "%d: %s (行:%d, 列:%d)\n" i (show_token token) pos.line pos.column
    ) tokens
  with
  | e -> Printf.printf "错误: %s\n" (Printexc.to_string e)