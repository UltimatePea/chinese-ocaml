let test_hello_world () =
  let source_code = "让 「问候」 为 『你好，世界！』\n「打印」 「问候」" in
  let result = Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.test_options source_code in
  Printf.printf "Hello World test: %b\n" result

let test_arithmetic () =
  let source_code =
    "\n\
     让 「a」 为 一十\n\
     让 「b」 为 五\n\
     让 「和」 为 「a」 加上 「b」\n\
     让 「差」 为 「a」 减去 「b」\n\
     让 「积」 为 「a」 乘以 「b」\n\
     让 「商」 为 「a」 除以 「b」\n\
     「打印」 『和： 』\n\
     「打印」 「和」\n\
     「打印」 『差： 』\n\
     「打印」 「差」\n\
     「打印」 『积： 』\n\
     「打印」 「积」\n\
     「打印」 『商： 』\n\
     「打印」 「商」"
  in
  let result = Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.test_options source_code in
  Printf.printf "Arithmetic test: %b\n" result

let () =
  Printf.printf "=== Testing with test_options ===\n";
  test_hello_world ();
  test_arithmetic ()