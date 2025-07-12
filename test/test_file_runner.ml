(** 骆言编译器文件测试运行器 - File Test Runner *)

(* open Yyocamlc_lib *)
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

(** 读取文件内容 *)
let read_file filename =
  let ic = open_in filename in
  let content = really_input_string ic (in_channel_length ic) in
  close_in ic;
  content

(** 测试单个文件 *)
let test_single_file test_name source_file expected_file should_fail =
  try
    let source_content = read_file source_file in
    let expected_output = if should_fail then "" else read_file expected_file in
    
    let (success, output) = capture_output (fun () ->
      Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options source_content
    ) in
  
    if should_fail then (
      check bool (test_name ^ " 应该失败") false success;
      check bool (test_name ^ " 应该有错误输出") true (String.length output > 0)
    ) else (
      check bool (test_name ^ " 执行成功") true success;
      check string (test_name ^ " 输出正确") expected_output output
    )
  with
  | exn ->
    Printf.printf "Exception in test %s: %s\n" test_name (Printexc.to_string exn);
    flush_all ();
    raise exn

(** 测试所有文件 *)
let test_all_files () =
  (* Determine the correct path based on whether we're in the build directory or project root *)
  let test_files_path = 
    if Sys.file_exists "test_files/hello_world.yu" then "test_files/"
    else if Sys.file_exists "test/test_files/hello_world.yu" then "test/test_files/"
    else failwith "Cannot find test files directory"
  in
  let test_cases = [
    ("Hello World", test_files_path ^ "hello_world.yu", test_files_path ^ "hello_world.expected", false);
    ("基本算术", test_files_path ^ "arithmetic.yu", test_files_path ^ "arithmetic.expected", false);
    ("阶乘计算", test_files_path ^ "factorial.yu", test_files_path ^ "factorial.expected", false);
    ("斐波那契数列", test_files_path ^ "fibonacci.yu", test_files_path ^ "fibonacci.expected", false);
    ("条件语句", test_files_path ^ "conditionals.yu", test_files_path ^ "conditionals.expected", false);
    ("模式匹配", test_files_path ^ "pattern_matching.yu", test_files_path ^ "pattern_matching.expected", false);
    ("列表操作", test_files_path ^ "list_operations.yu", test_files_path ^ "list_operations.expected", false);
    ("嵌套函数", test_files_path ^ "nested_functions.yu", test_files_path ^ "nested_functions.expected", false);
  ] in
  
  List.iter (fun (name, source, expected, should_fail) ->
    test_single_file name source expected should_fail
  ) test_cases

(** 测试错误情况 *)
let test_error_cases () =
  (* Determine the correct path based on whether we're in the build directory or project root *)
  let test_files_path = 
    if Sys.file_exists "test_files/error_lexer.yu" then "test_files/"
    else if Sys.file_exists "test/test_files/error_lexer.yu" then "test/test_files/"
    else failwith "Cannot find test files directory"
  in
  let error_cases = [
    ("词法错误", test_files_path ^ "error_lexer.yu", true);
    ("语法错误", test_files_path ^ "error_syntax.yu", true);
    ("运行时错误", test_files_path ^ "error_runtime.yu", true);
  ] in
  
  List.iter (fun (name, source, should_fail) ->
    test_single_file name source "" should_fail
  ) error_cases

(** 测试文件编译 *)
let test_file_compilation () =
  (* Determine the correct path based on whether we're in the build directory or project root *)
  let test_files_path = 
    if Sys.file_exists "test_files/hello_world.yu" then "test_files/"
    else if Sys.file_exists "test/test_files/hello_world.yu" then "test/test_files/"
    else failwith "Cannot find test files directory"
  in
  let test_file = test_files_path ^ "hello_world.yu" in
  let _expected_output = read_file (test_files_path ^ "hello_world.expected") in
  let _ = _expected_output in (* suppress unused warning *)
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_file Yyocamlc_lib.Compiler.quiet_options test_file
  ) in
  
  check bool "文件编译执行成功" true success;
  check bool "文件编译有输出" true (String.length output > 0)

(** 测试复杂程序 *)
let test_complex_programs () =
  (* 测试插入排序算法 *)
  let insertion_sort_source = "
递归 让 插入 = 函数 x -> 函数 lst ->
  匹配 lst 与
  | [] -> [x]
  | [h, ...t] ->
    如果 x < h 那么
      [x, h, ...t]
    否则
      让 插入x = 插入 x
      [h, ...插入x t]

递归 让 插入排序 = 函数 lst ->
  匹配 lst 与
  | [] -> []
  | [h, ...t] -> 
    让 插入h = 插入 h
    插入h (插入排序 t)

让 测试列表 = [3, 1, 4, 1, 5, 9, 2, 6]
让 排序结果 = 插入排序 测试列表
打印 \"排序结果: \"
打印 排序结果" in
  
  let expected_output = "排序结果: \n[1; 1; 2; 3; 4; 5; 6; 9]\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options insertion_sort_source
  ) in
  
  check bool "插入排序程序执行成功" true success;
  check string "插入排序输出正确" expected_output output

(** 测试性能程序 *)
let test_performance_programs () =
  (* 测试大数累加 *)
  let sum_source = "
递归 让 累加 = 函数 n ->
  如果 n == 0 那么
    0
  否则
    n + 累加 (n - 1)

让 结果 = 累加 100
打印 \"1到100的和: \"
打印 结果" in
  
  let expected_output = "1到100的和: \n5050\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options sum_source
  ) in
  
  check bool "大数累加程序执行成功" true success;
  check string "大数累加输出正确" expected_output output

(** 测试边界条件 *)
let test_edge_cases () =
  let edge_source = "
让 空字符串 = \"\"
让 零 = 0
让 负数 = -5
让 大数 = 999999

打印 \"空字符串长度: \"
打印 (长度 空字符串)
打印 \"零: \"
打印 零
打印 \"负数: \"
打印 负数
打印 \"大数: \"
打印 大数" in
  
  let expected_output = "空字符串长度: \n0\n零: \n0\n负数: \n-5\n大数: \n999999\n" in
  
  let (success, output) = capture_output (fun () ->
    Yyocamlc_lib.Compiler.compile_string Yyocamlc_lib.Compiler.quiet_options edge_source
  ) in
  
  check bool "边界条件程序执行成功" true success;
  check string "边界条件输出正确" expected_output output

(** 测试套件 *)
let () =
  run "骆言编译器文件测试" [
    ("基础功能测试", [
      test_case "所有基础文件" `Quick test_all_files;
      test_case "文件编译" `Quick test_file_compilation;
    ]);
    ("错误处理测试", [
      test_case "错误情况" `Quick test_error_cases;
    ]);
    ("复杂程序测试", [
      test_case "复杂程序" `Quick test_complex_programs;
      test_case "性能程序" `Quick test_performance_programs;
      test_case "边界条件" `Quick test_edge_cases;
    ]);
  ]