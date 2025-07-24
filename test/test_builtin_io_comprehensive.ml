open Yyocamlc_lib.Builtin_io
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_error
module Ast = Yyocamlc_lib.Ast

let test_file_path = "/tmp/luoyan_test_file.txt"
let test_dir_path = "/tmp/luoyan_test_dir"

let () =
  Printf.printf "TEST: 骆言内置I/O模块全面测试开始\n\n";

  (* 测试 print_function *)
  Printf.printf "PRINT: 测试 print_function\n";
  (try
    (* 测试字符串打印 *)
    Printf.printf "测试字符串打印输出: ";
    let result1 = print_function [StringValue "骆言编程语言"] in
    assert (result1 = UnitValue);
    Printf.printf "√ 字符串打印测试通过\n";
    
    (* 测试整数打印 *)
    Printf.printf "测试整数打印输出: ";
    let result2 = print_function [IntValue 42] in
    assert (result2 = UnitValue);
    Printf.printf "√ 整数打印测试通过\n";
    
    (* 测试浮点数打印 *)
    Printf.printf "测试浮点数打印输出: ";
    let result3 = print_function [FloatValue 3.14159] in
    assert (result3 = UnitValue);
    Printf.printf "√ 浮点数打印测试通过\n";
    
    (* 测试布尔值打印 *)
    Printf.printf "测试布尔值打印输出: ";
    let result4 = print_function [BoolValue true] in
    assert (result4 = UnitValue);
    Printf.printf "√ 布尔值打印测试通过\n";
    
    (* 测试Unit值打印 *)
    Printf.printf "测试Unit值打印输出: ";
    let result5 = print_function [UnitValue] in
    assert (result5 = UnitValue);
    Printf.printf "√ Unit值打印测试通过\n";
  with
  | e -> Printf.printf "X print_function 测试失败: %s\n" (Printexc.to_string e));

  (* 测试文件操作前的清理 *)
  Printf.printf "\nCLEAN: 测试环境准备\n";
  (try
    (* 删除可能存在的测试文件 *)
    if Sys.file_exists test_file_path then Sys.remove test_file_path;
    if Sys.file_exists test_dir_path then Unix.rmdir test_dir_path;
    Printf.printf "√ 测试环境清理完成\n";
  with
  | e -> Printf.printf "⚠️  测试环境清理: %s\n" (Printexc.to_string e));

  (* 测试 file_exists_function *)
  Printf.printf "\n📁 测试 file_exists_function\n";
  (try
    (* 测试不存在的文件 *)
    let result1 = file_exists_function [StringValue test_file_path] in
    assert (result1 = BoolValue false);
    Printf.printf "√ 不存在文件检查测试通过: %s -> false\n" test_file_path;
    
    (* 测试存在的文件（使用当前测试文件） *)
    let current_file = Sys.argv.(0) in
    let result2 = file_exists_function [StringValue current_file] in
    assert (result2 = BoolValue true);
    Printf.printf "√ 存在文件检查测试通过: %s -> true\n" current_file;
    
    (* 测试空文件名 *)
    let result3 = file_exists_function [StringValue ""] in
    assert (result3 = BoolValue false);
    Printf.printf "√ 空文件名检查测试通过: \"\" -> false\n";
  with
  | e -> Printf.printf "X file_exists_function 测试失败: %s\n" (Printexc.to_string e));

  (* 测试 write_file_function *)
  Printf.printf "\nWRITE: 测试 write_file_function\n";
  (try
    let test_content = "骆言编程语言测试内容\n这是第二行\n包含中文字符：你好世界！" in
    let result1 = match write_file_function [StringValue test_file_path] with
      | BuiltinFunctionValue f -> f [StringValue test_content]
      | _ -> UnitValue in
    assert (result1 = UnitValue);
    Printf.printf "√ 文件写入测试通过: 写入 %d 字符到 %s\n" (String.length test_content) test_file_path;
    
    (* 验证文件确实被创建 *)
    let file_exists = file_exists_function [StringValue test_file_path] in
    assert (file_exists = BoolValue true);
    Printf.printf "√ 文件创建验证通过: 文件已存在\n";
    
    (* 测试写入空内容 *)
    let empty_file_path = "/tmp/luoyan_empty_test.txt" in
    let result2 = match write_file_function [StringValue empty_file_path] with
      | BuiltinFunctionValue f -> f [StringValue ""]
      | _ -> UnitValue in
    assert (result2 = UnitValue);
    Printf.printf "√ 空内容写入测试通过\n";
    
    (* 清理空文件 *)
    if Sys.file_exists empty_file_path then Sys.remove empty_file_path;
  with
  | e -> Printf.printf "X write_file_function 测试失败: %s\n" (Printexc.to_string e));

  (* 测试 read_file_function *)
  Printf.printf "\n📖 测试 read_file_function\n";
  (try
    let result1 = read_file_function [StringValue test_file_path] in
    (match result1 with
    | StringValue content ->
        let expected_content = "骆言编程语言测试内容\n这是第二行\n包含中文字符：你好世界！" in
        if String.equal content expected_content then
          Printf.printf "√ 文件读取测试通过: 内容匹配（%d 字符）\n" (String.length content)
        else
          Printf.printf "X 文件内容不匹配\n期望: \"%s\"\n实际: \"%s\"\n" expected_content content
    | _ -> Printf.printf "X 文件读取返回类型错误\n");
    
    (* 测试读取不存在的文件 *)
    let non_existent_file = "/tmp/non_existent_file_骆言.txt" in
    (try
      let result2 = read_file_function [StringValue non_existent_file] in
      Printf.printf "⚠️  读取不存在文件时应该抛出异常\n"
    with
    | _ -> Printf.printf "√ 读取不存在文件正确抛出异常\n");
  with
  | e -> Printf.printf "X read_file_function 测试失败: %s\n" (Printexc.to_string e));

  (* 测试 list_directory_function *)
  Printf.printf "\n📂 测试 list_directory_function\n";
  (try
    (* 创建测试目录 *)
    Unix.mkdir test_dir_path 0o755;
    
    (* 在测试目录中创建一些文件 *)
    let test_files = ["文件1.txt"; "file2.ly"; "测试文档.md"] in
    List.iter (fun filename ->
      let filepath = Filename.concat test_dir_path filename in
      let oc = open_out filepath in
      output_string oc ("测试文件内容: " ^ filename);
      close_out oc
    ) test_files;
    
    let result1 = list_directory_function [StringValue test_dir_path] in
    (match result1 with
    | ListValue contents ->
        let content_strings = List.map (function
          | StringValue s -> s
          | _ -> ""
        ) contents in
        Printf.printf "√ 目录列举测试通过: 找到 %d 个项目\n" (List.length content_strings);
        Printf.printf "📋 目录内容: %s\n" (String.concat ", " content_strings);
        
        (* 验证所有创建的文件都被列出 *)
        let missing_files = List.filter (fun file -> not (List.mem file content_strings)) test_files in
        if missing_files = [] then
          Printf.printf "√ 所有创建的文件都被正确列出\n"
        else
          Printf.printf "X 缺少文件: %s\n" (String.concat ", " missing_files)
    | _ -> Printf.printf "X 目录列举返回类型错误\n");
    
    (* 测试列举不存在的目录 *)
    (try
      let result2 = list_directory_function [StringValue "/tmp/non_existent_directory_骆言"] in
      Printf.printf "⚠️  列举不存在目录时应该抛出异常\n"
    with
    | _ -> Printf.printf "√ 列举不存在目录正确抛出异常\n");
  with
  | e -> Printf.printf "X list_directory_function 测试失败: %s\n" (Printexc.to_string e));

  (* 测试文件操作的原子性和一致性 *)
  Printf.printf "\n🔄 测试文件操作一致性\n";
  (try
    let consistency_file = "/tmp/luoyan_consistency_test.txt" in
    let original_content = "原始内容" in
    let updated_content = "更新后的内容：包含中文和特殊字符！@#$%^&*()" in
    
    (* 写入原始内容 *)
    let _ = match write_file_function [StringValue consistency_file] with
      | BuiltinFunctionValue f -> f [StringValue original_content]
      | _ -> UnitValue in
    
    (* 读取验证 *)
    let read_result1 = read_file_function [StringValue consistency_file] in
    (match read_result1 with
    | StringValue content when String.equal content original_content ->
        Printf.printf "√ 原始内容读写一致性测试通过\n"
    | _ -> Printf.printf "X 原始内容读写不一致\n");
    
    (* 更新内容 *)
    let _ = match write_file_function [StringValue consistency_file] with
      | BuiltinFunctionValue f -> f [StringValue updated_content]
      | _ -> UnitValue in
    
    (* 再次读取验证 *)
    let read_result2 = read_file_function [StringValue consistency_file] in
    (match read_result2 with
    | StringValue content when String.equal content updated_content ->
        Printf.printf "√ 更新内容读写一致性测试通过\n"
    | _ -> Printf.printf "X 更新内容读写不一致\n");
    
    (* 清理 *)
    if Sys.file_exists consistency_file then Sys.remove consistency_file;
  with
  | e -> Printf.printf "X 一致性测试失败: %s\n" (Printexc.to_string e));

  (* 测试边界条件和性能 *)
  Printf.printf "\n⚡ 性能和边界条件测试\n";
  (try
    (* 测试大文件写入和读取 *)
    let large_content = String.make 100000 'A' in  (* 100K ASCII 字符 *)
    let large_file = "/tmp/luoyan_large_test.txt" in
    
    let start_time = Sys.time () in
    let _ = match write_file_function [StringValue large_file] with
      | BuiltinFunctionValue f -> f [StringValue large_content]
      | _ -> UnitValue in
    let write_time = Sys.time () -. start_time in
    Printf.printf "√ 大文件写入测试通过: 100K字符，耗时 %.6f秒\n" write_time;
    
    let start_read_time = Sys.time () in
    let read_result = read_file_function [StringValue large_file] in
    let read_time = Sys.time () -. start_read_time in
    (match read_result with
    | StringValue content when String.length content = 100000 ->
        Printf.printf "√ 大文件读取测试通过: 100K字符，耗时 %.6f秒\n" read_time
    | _ -> Printf.printf "X 大文件读取失败\n");
    
    (* 清理大文件 *)
    if Sys.file_exists large_file then Sys.remove large_file;
    
    (* 测试多个文件操作 *)
    let multi_file_start = Sys.time () in
    for i = 1 to 100 do
      let temp_file = Printf.sprintf "/tmp/luoyan_multi_%d.txt" i in
      let temp_content = Printf.sprintf "文件 %d 的内容" i in
      let _ = match write_file_function [StringValue temp_file] with
        | BuiltinFunctionValue f -> f [StringValue temp_content]
        | _ -> UnitValue in
      let _ = read_file_function [StringValue temp_file] in
      if Sys.file_exists temp_file then Sys.remove temp_file
    done;
    let multi_file_time = Sys.time () -. multi_file_start in
    Printf.printf "√ 多文件操作测试通过: 100个文件，耗时 %.6f秒\n" multi_file_time;
  with
  | e -> Printf.printf "X 性能测试失败: %s\n" (Printexc.to_string e));

  (* 清理测试环境 *)
  Printf.printf "\nCLEAN: 测试后清理\n";
  (try
    if Sys.file_exists test_file_path then Sys.remove test_file_path;
    
    (* 清理测试目录 *)
    if Sys.file_exists test_dir_path then begin
      let files = Sys.readdir test_dir_path in
      Array.iter (fun file ->
        let filepath = Filename.concat test_dir_path file in
        if Sys.file_exists filepath then Sys.remove filepath
      ) files;
      Unix.rmdir test_dir_path
    end;
    
    Printf.printf "√ 测试环境清理完成\n";
  with
  | e -> Printf.printf "⚠️  清理过程中出现错误: %s\n" (Printexc.to_string e));

  Printf.printf "\n🎉 骆言内置I/O模块全面测试完成！\n";
  Printf.printf "📊 测试涵盖: 打印输出、文件读写、文件存在检查、目录列举\n";
  Printf.printf "🔧 包含性能测试、一致性测试和边界条件测试\n";
  Printf.printf "🌏 包含中文字符和Unicode支持测试\n"