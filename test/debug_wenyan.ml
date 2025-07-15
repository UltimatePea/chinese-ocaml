open Yyocamlc_lib

let debug_tokenize input =
  Printf.printf "调试输入: '%s'\n" input;
  let tokens = Lexer.tokenize input "test" in
  Printf.printf "生成的token数量: %d\n" (List.length tokens);
  List.iteri
    (fun i (token, pos) ->
      Printf.printf "  [%d] %s at line %d, col %d\n" i (Lexer.show_token token) pos.Lexer.line
        pos.Lexer.column)
    tokens;
  tokens

let () =
  let inputs = [ "设"; "数值"; "为"; "42"; "设数值为42" ] in
  List.iter
    (fun input ->
      Printf.printf "\n=== 测试输入: '%s' ===\n" input;
      ignore (debug_tokenize input))
    inputs

