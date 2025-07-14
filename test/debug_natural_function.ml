open Yyocamlc_lib

let debug_tokenize input =
  let tokens = Lexer.tokenize input "test" in
  List.iter (fun (token, pos) ->
    Printf.printf "Token: %s (line %d, col %d)\n"
      (Lexer.show_token token) pos.Lexer.line pos.Lexer.column
  ) tokens

let () =
  let input = "定义「测试函数」接受「输入」: 当「输入」等于 1 时返回 1 不然返回 0" in
  Printf.printf "Input: %s\n" input;
  debug_tokenize input