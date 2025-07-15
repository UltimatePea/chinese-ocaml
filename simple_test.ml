open Yyocamlc_lib.Lexer

let test_simple () =
  (* 测试基本的引用标识符 *)
  let tokens = tokenize "让「变量」为" "test" in
  List.iter (fun (token, _) -> Printf.printf "%s\n" (show_token token)) tokens;
  
  (* 测试未引用标识符会报错 *)
  try
    let _tokens = tokenize "变量" "test" in
    Printf.printf "Error: 未引用标识符没有报错\n"
  with
  | LexError (msg, _) -> Printf.printf "Success: %s\n" msg
  | _ -> Printf.printf "Error: 抛出了意外的错误\n"

let () = test_simple ()