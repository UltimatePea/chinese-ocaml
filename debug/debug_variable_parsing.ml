open Yyocamlc_lib

let test_variable_parsing () =
  let source = "让 去空白 = \"test\"" in
  Printf.printf "测试: %s\n" source;
  try
    let result = Compiler.compile_string Compiler.quiet_options source in
    Printf.printf "编译结果: %b\n" result
  with
  | e -> Printf.printf "错误: %s\n" (Printexc.to_string e)

let () = test_variable_parsing ()