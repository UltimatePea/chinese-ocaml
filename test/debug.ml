(** 语义类型系统调试测试 *)

open Yyocamlc_lib

let () =
  Printf.printf "测试简单的语义类型表达式...\n";

  let source = "让「变量」作为 临时变量 为 十" in
  Printf.printf "源代码: %s\n" source;

  try
    let result = Compiler.compile_string Compiler.default_options source in
    Printf.printf "编译结果: %b\n" result
  with e ->
    Printf.printf "异常: %s\n" (Printexc.to_string e);
    Printexc.print_backtrace stdout

