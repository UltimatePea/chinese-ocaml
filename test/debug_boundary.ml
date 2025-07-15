open Yyocamlc_lib

let test_boundary input pos =
  Printf.printf "测试边界: '%s' 位置 %d\n" input pos;
  let state = Lexer.create_lexer_state input "test" in
  let state_at_pos = { state with position = pos } in

  (* 测试try_match_keyword *)
  let result = Lexer.try_match_keyword state_at_pos in
  match result with
  | Some (keyword, token, len) ->
      Printf.printf "  找到关键字: '%s' -> %s (长度: %d)\n" keyword (Lexer.show_token token) len
  | None ->
      Printf.printf "  没有找到关键字\n";

      (* 测试当前字符和下一个字符 *)
      if pos < String.length input then Printf.printf "  当前位置字符: %02X\n" (Char.code input.[pos]);
      if pos + 3 < String.length input then
        Printf.printf "  下个位置字符: %02X\n" (Char.code input.[pos + 3])

let () =
  let input = "设数值为42" in
  Printf.printf "输入: '%s'\n" input;
  Printf.printf "字节序列: ";
  for i = 0 to String.length input - 1 do
    Printf.printf "%02X " (Char.code input.[i])
  done;
  Printf.printf "\n\n";

  (* 测试各个位置 *)
  let positions = [ 0; 3; 6; 9; 12 ] in
  List.iter (test_boundary input) positions
