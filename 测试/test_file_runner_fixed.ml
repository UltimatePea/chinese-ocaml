(** 骆言编译器文件测试运行器 - 修复版 *)

open Alcotest

[@@@warning "-33"] (* unused open *)

(** 测试辅助函数 - 捕获输出 *)
let capture_output f =
  let temp_file = Filename.temp_file "yyocamlc_test" ".txt" in
  let original_stdout = Unix.dup Unix.stdout in
  let output_channel = open_out temp_file in
  
  Unix.dup2 (Unix.descr_of_out_channel output_channel) Unix.stdout;
  let result = f () in
  close_out output_channel;
  Unix.dup2 original_stdout Unix.stdout;
  Unix.close original_stdout;
  
  let ic = open_in temp_file in
  let output = really_input_string ic (in_channel_length ic) in
  close_in ic;
  Sys.remove temp_file;
  
  (result, output)

(** 测试Hello World文件 *)
let test_hello_world () =
  let source_content = "让 问候 = \"你好，世界！\"\n打印 问候" in
  let expected_output = "你好，世界！\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_content
  ) in
  
  check bool "Hello World 执行成功" true success;
  check string "Hello World 输出正确" expected_output output

(** 测试基本算术 *)
let test_arithmetic () =
  let source_content = "让 a = 10\n让 b = 5\n让 和 = a + b\n打印 和" in
  let expected_output = "15\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_content
  ) in
  
  check bool "算术运算执行成功" true success;
  check string "算术运算输出正确" expected_output output

(** 测试错误情况 *)
let test_error_case () =
  let source_content = "让 x = 未定义变量" in
  
  let (success, output) = capture_output (fun () ->
    let no_recovery_options = { Yyocamlc_lib.Compiler.quiet_options with recovery_mode = false } in
    Yyocamlc_lib.Compiler.compile_string no_recovery_options source_content
  ) in
  
  check bool "错误程序应该失败" false success;
  check bool "错误应该有输出" true (String.length output > 0)

(** 文件测试套件 *)
let () =
  run "骆言编译器文件测试" [
    ("基础功能测试", [
      test_case "Hello World" `Quick test_hello_world;
      test_case "基本算术" `Quick test_arithmetic;
    ]);
    ("错误处理测试", [
      test_case "错误情况" `Quick test_error_case;
    ]);
  ]