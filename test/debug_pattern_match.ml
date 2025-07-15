open Yyocamlc_lib

let debug_pattern_match () =
  Printf.printf "调试模式匹配问题:\n";

  let source_code = "让 「测试变量」 为 一" in

  Printf.printf "源代码:\n%s\n\n" source_code;

  Printf.printf "尝试编译:\n";
  try
    let success = Compiler.compile_string Compiler.quiet_options source_code in
    Printf.printf "编译结果: %b\n" success
  with e -> Printf.printf "编译错误: %s\n" (Printexc.to_string e)

let () = debug_pattern_match ()

