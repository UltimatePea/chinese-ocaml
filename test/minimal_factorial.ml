(** 最小化阶乘测试 - 排查CI超时问题 *)

let test_simple_factorial () =
  let source_code = "让 「结果」 为 一二零\n「打印」 「结果」" in
  Printf.printf "Testing non-recursive simple program...\n";

  try
    let success =
      Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.test_options source_code
    in
    Printf.printf "Simple test result: %b\n" success
  with exn -> Printf.printf "Exception in simple test: %s\n" (Printexc.to_string exn)

let test_recursive_factorial () =
  let source_code =
    "递归 让 「阶乘」 为 函数 「值」 应得\n\
     如果 「值」 等于 零 那么\n\
     一\n\
     否则\n\
     「值」 乘以 「阶乘」 （「值」 减去 一）\n\n\
     让 「数字」 为 五\n\
     让 「结果」 为 「阶乘」 「数字」\n\
     「打印」 「结果」"
  in
  Printf.printf "Testing recursive factorial...\n";

  try
    let success =
      Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.test_options source_code
    in
    Printf.printf "Recursive factorial result: %b\n" success
  with exn -> Printf.printf "Exception in recursive test: %s\n" (Printexc.to_string exn)

let () =
  Printf.printf "=== 最小化阶乘测试开始 ===\n";
  test_simple_factorial ();
  Printf.printf "Simple test completed.\n";
  test_recursive_factorial ();
  Printf.printf "=== 最小化阶乘测试结束 ===\n"
