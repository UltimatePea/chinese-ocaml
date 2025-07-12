open Yyocamlc_lib

let () =
  let test_chars = ["设"; "数"; "值"; "为"] in
  Printf.printf "关键字表测试:\n";
  List.iter (fun ch ->
    Printf.printf "'%s' -> " ch;
    (match Lexer.find_keyword ch with
     | Some token -> Printf.printf "%s\n" (Lexer.show_token token)
     | None -> Printf.printf "NOT FOUND\n")
  ) test_chars;
  
  Printf.printf "\n字节比较测试:\n";
  let wei_from_input = "\228\184\186" in
  let wei_keyword = "为" in
  Printf.printf "输入中的'为': ";
  for i = 0 to String.length wei_from_input - 1 do
    Printf.printf "%02X " (Char.code wei_from_input.[i])
  done;
  Printf.printf "\n关键字表中的'为': ";
  for i = 0 to String.length wei_keyword - 1 do
    Printf.printf "%02X " (Char.code wei_keyword.[i])
  done;
  Printf.printf "\n相等? %b\n" (wei_from_input = wei_keyword)