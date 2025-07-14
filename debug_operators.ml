open Yyocamlc_lib.Lexer

let debug_operators () =
  let input = "＋ － ＊ ／ ＝＝ ＜＞ ＜ ＜＝ ＞ ＞＝" in
  let token_list = tokenize input "test" in
  Printf.printf "调试运算符tokenize结果:\n";
  Printf.printf "输入: %s\n" input;
  Printf.printf "Token数量: %d\n" (List.length token_list);
  List.iteri (fun i (token, pos) ->
    Printf.printf "%d. %s 在位置 %d:%d\n" (i+1) (show_token token) pos.line pos.column
  ) token_list;
  let operators = List.filter (function
    | (Plus, _) | (Minus, _) | (Multiply, _) | (Divide, _) |
      (Equal, _) | (NotEqual, _) | (Less, _) | (LessEqual, _) |
      (Greater, _) | (GreaterEqual, _) -> true
    | _ -> false) token_list in
  Printf.printf "\n运算符数量: %d\n" (List.length operators);
  List.iteri (fun i (token, _) ->
    Printf.printf "%d. %s\n" (i+1) (show_token token)
  ) operators

let () = debug_operators ()