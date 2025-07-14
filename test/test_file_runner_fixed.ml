(** 骆言编译器文件测试运行器 - 修复版 *)

open Alcotest


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

(** 测试Hello World文件 - 简化版，不使用字符串字面量 *)
let test_hello_world () =
  (* 注意：Issue #105 禁用了字符串字面量，因此测试数字输出代替 *)
  let source_content = "让 「数字」 为 八\n打印 「数字」" in
  let expected_output = "8\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_content
  ) in
  
  check bool "Hello World 执行成功" true success;
  check string "Hello World 输出正确" expected_output output

(** 测试基本算术 *)
let test_arithmetic () =
  let source_content = "让 「a」 为 十\n让 「b」 为 五\n让 「和」 为 「a」 加上 「b」\n打印 「和」" in
  let expected_output = "15\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_content
  ) in
  
  check bool "算术运算执行成功" true success;
  check string "算术运算输出正确" expected_output output

(** 测试错误情况 *)
let test_error_case () =
  let source_content = "让 「x」 为 「未定义变量」" in
  
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