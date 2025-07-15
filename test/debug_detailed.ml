open Yyocamlc_lib

let debug_tokenize_detailed input =
  Printf.printf "\n=== 详细调试: '%s' ===\n" input;
  Printf.printf "输入长度: %d 字节\n" (String.length input);

  (* 逐字节分析 *)
  for i = 0 to String.length input - 1 do
    Printf.printf "  [%d] %02X '%c'\n" i (Char.code input.[i]) input.[i]
  done;

  let tokens = Lexer.tokenize input "test" in
  Printf.printf "生成的token:\n";
  List.iteri (fun i (token, _pos) -> Printf.printf "  [%d] %s\n" i (Lexer.show_token token)) tokens;

  (* 测试关键字查找 *)
  let test_keywords = [ "数值"; "为"; "42" ] in
  List.iter
    (fun kw ->
      match Lexer.find_keyword kw with
      | Some token -> Printf.printf "关键字查找 '%s' -> %s\n" kw (Lexer.show_token token)
      | None -> Printf.printf "关键字查找 '%s' -> NOT FOUND\n" kw)
    test_keywords

let () = debug_tokenize_detailed "设数值为42"

