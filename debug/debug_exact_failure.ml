open Yyocamlc_lib

let test_exact_failure () =
  let source = "\n  让 原始 = \"  Hello World  \"\n  让 去空白 = 去除空白 原始\n  让 大写 = 大写转换 去空白\n  " in
  Printf.printf "测试完整场景\n";
  try
    let result = Compiler.compile_string Compiler.quiet_options source in
    Printf.printf "编译结果: %b\n" result
  with e -> Printf.printf "错误: %s\n" (Printexc.to_string e)

let () = test_exact_failure ()
