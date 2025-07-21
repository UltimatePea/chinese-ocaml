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

  let expected_output = "和： \n15\n差： \n5\n积： \n50\n商： \n2\n" in

  Printf.printf "Testing with test_options (log_level = \"quiet\"):\n";
  let success = Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.test_options source_code in
  Printf.printf "Success: %b\n" success;
  Printf.printf "Expected: %S\n" expected_output;
  Printf.printf "\n";

  Printf.printf "Testing with default_options (log_level = \"normal\"):\n";
  let success2 = Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.default_options source_code in
  Printf.printf "Success: %b\n" success2;
  Printf.printf "\n"

let () =
  test_arithmetic ()