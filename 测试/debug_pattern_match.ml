open Yyocamlc_lib

let debug_pattern_match () =
  Printf.printf "调试模式匹配问题:\n";
  
  let source_code = "
让 测试数字 = 函数 x ->
  匹配 x 与
  | 0 -> \"零\"
  | 1 -> \"一\"
  | 2 -> \"二\"
  | _ -> \"其他\"

打印 (测试数字 0)
打印 (测试数字 1)
打印 (测试数字 2)
打印 (测试数字 5)" in
  
  Printf.printf "源代码:\n%s\n\n" source_code;
  
  Printf.printf "尝试编译:\n";
  try
    let success = Compiler.compile_string Compiler.quiet_options source_code in
    Printf.printf "编译结果: %b\n" success
  with
  | e ->
    Printf.printf "编译错误: %s\n" (Printexc.to_string e)

let () = debug_pattern_match ()