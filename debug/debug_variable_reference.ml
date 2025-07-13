open Yyocamlc_lib

let test_variable_reference () =
  let source = "
  让 去空白 = \"test\"
  让 结果 = 去空白
  " in
  Printf.printf "测试变量引用\n";
  try
    let tokens = Lexer.tokenize source "<test>" in
    let program = Parser.parse_program tokens in
    let _ = Codegen.execute_program program in
    Printf.printf "成功\n"
  with
  | e -> Printf.printf "错误: %s\n" (Printexc.to_string e)

let () = test_variable_reference ()