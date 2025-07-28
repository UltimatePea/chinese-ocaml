(** Echo测试工程师调试Alcotest集成问题
    Author: Echo, Test Engineer Agent  
    Purpose: Understand why direct compilation succeeds but Alcotest tests fail
*)

open Alcotest

let debug_compile_with_output_capture () =
  Printf.printf "=== 调试Alcotest编译问题 ===\n";
  
  let simple_code = "让 「问候」 为 『你好，世界！』\n「打印」 「问候」" in
  
  (* 捕获stdout以分析实际发生了什么 *)
  let old_stdout = Unix.dup Unix.stdout in
  let (fd_in, fd_out) = Unix.pipe () in
  Unix.dup2 fd_out Unix.stdout;
  
  let result = 
    try
      let options = Yyocamlc_lib.Compiler.test_options in
      let compile_result = Yyocamlc_lib.Compiler.compile_string options simple_code in
      
      (* 恢复stdout *)
      Unix.dup2 old_stdout Unix.stdout;
      Unix.close fd_out;
      
      (* 读取捕获的输出 *)
      let buffer = Bytes.create 1024 in
      let bytes_read = Unix.read fd_in buffer 0 1024 in
      let captured_output = Bytes.sub_string buffer 0 bytes_read in
      
      Unix.close fd_in;
      Unix.close old_stdout;
      
      Printf.printf "编译结果: %b\n" compile_result;
      Printf.printf "捕获的输出: '%s'\n" captured_output;
      Printf.printf "输出长度: %d 字节\n" bytes_read;
      
      compile_result
    with
    | exn ->
      (* 确保恢复stdout *)
      Unix.dup2 old_stdout Unix.stdout;
      Unix.close fd_out;
      Unix.close fd_in;
      Unix.close old_stdout;
      
      Printf.printf "异常: %s\n" (Printexc.to_string exn);
      false
  in
  
  Printf.printf "最终结果: %b\n" result;
  result

let test_basic_compilation () =
  let result = debug_compile_with_output_capture () in
  check bool "基础编译应该成功" true result

let () =
  run "Alcotest调试测试"
    [
      ("编译测试", 
       [
         test_case "基础编译调试" `Quick test_basic_compilation;
       ]
      );
    ]