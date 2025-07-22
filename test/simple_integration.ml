(** 简化版集成测试 - 无复杂文件I/O操作 *)

open Alcotest

(** 简化的测试 - 只检查编译成功，不捕获输出 *)
let test_simple_hello_world () =
  let source_code = "让 「问候」 为 『你好，世界！』\n「打印」 「问候」" in
  let success =
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.test_options source_code
  in
  check bool "Hello World 程序执行成功" true success

let test_simple_arithmetic () =
  let source_code = "让 「a」 为 一十\n让 「b」 为 五\n让 「和」 为 「a」 加上 「b」\n「打印」 「和」" in
  let success =
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.test_options source_code
  in
  check bool "基本算术程序执行成功" true success

let test_simple_factorial () =
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
  let success =
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.test_options source_code
  in
  check bool "阶乘程序执行成功" true success

let test_simple_fibonacci () =
  let source_code =
    "递归 让 「斐波那契」 为 函数 「数」 故\n\
     如果 「数」 等于 零 那么\n\
     零\n\
     否则 如果 「数」 等于 一 那么\n\
     一\n\
     否则\n\
     「斐波那契」（「数」 减去 一） 加上 「斐波那契」（「数」 减去 二）\n\n\
     让 「结果」 为 「斐波那契」 二\n\
     「打印」 「结果」"
  in
  let success =
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.test_options source_code
  in
  check bool "斐波那契程序执行成功" true success

(** 简化的测试套件 *)
let () =
  run "简化版集成测试"
    [
      ( "基础功能",
        [
          test_case "Hello World" `Quick test_simple_hello_world;
          test_case "基本算术" `Quick test_simple_arithmetic;
        ] );
      ( "递归函数",
        [
          test_case "阶乘计算" `Quick test_simple_factorial;
          test_case "斐波那契数列" `Quick test_simple_fibonacci;
        ] );
    ]
