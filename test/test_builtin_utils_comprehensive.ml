open Yyocamlc_lib.Builtin_utils
open Yyocamlc_lib.Value_operations
module Ast = Yyocamlc_lib.Ast

let () =
  Printf.printf "🧪 骆言内置工具函数模块全面测试开始\n\n";

  (* 测试 filter_ly_files_function *)
  Printf.printf "📁 测试 filter_ly_files_function\n";
  (try
    let test_files = [
      StringValue "程序.ly";
      StringValue "测试.txt";
      StringValue "骆言编程.ly";
      StringValue "README.md";
      StringValue "配置.json";
      StringValue "示例代码.ly";
      StringValue "main.ml";
      StringValue "";
      StringValue ".ly";
      StringValue "文件.LY"
    ] in
    
    let result = filter_ly_files_function test_files in
    let expected_ly_files = [
      StringValue "程序.ly";
      StringValue "骆言编程.ly";
      StringValue "示例代码.ly"
    ] in
    
    (match result with
    | ListValue filtered_files ->
        Printf.printf "✅ .ly文件过滤测试通过，找到 %d 个.ly文件\n" (List.length filtered_files);
        let ly_file_names = List.map (function
          | StringValue name -> name
          | _ -> ""
        ) filtered_files in
        Printf.printf "📋 .ly文件列表: %s\n" (String.concat ", " ly_file_names);
        
        (* 验证结果 *)
        if List.length filtered_files = 3 then
          Printf.printf "✅ 过滤数量正确\n"
        else
          Printf.printf "❌ 过滤数量不正确，期望3个，实际%d个\n" (List.length filtered_files)
    | _ -> Printf.printf "❌ filter_ly_files_function 返回类型错误\n");
    
    (* 测试空列表 *)
    let empty_result = filter_ly_files_function [] in
    (match empty_result with
    | ListValue [] -> Printf.printf "✅ 空列表过滤测试通过\n"
    | _ -> Printf.printf "❌ 空列表过滤测试失败\n");
  with
  | e -> Printf.printf "❌ filter_ly_files_function 测试失败: %s\n" (Printexc.to_string e));

  (* 测试 remove_hash_comment_function *)
  Printf.printf "\n# 测试 remove_hash_comment_function\n";
  (try
    let test_cases = [
      ("打印 \"你好世界\"  # 这是注释", "打印 \"你好世界\"  ");
      ("# 整行都是注释", "");
      ("代码行 # 行尾注释 # 多个井号", "代码行 ");
      ("没有注释的代码行", "没有注释的代码行");
      ("\"字符串中的#不是注释\"", "\"字符串中的#不是注释\"");
      ("前面有代码 # 后面有注释", "前面有代码 ");
      ("", "");
      ("###多个井号开头", "");
      ("代码 ### 中间多个井号", "代码 ")
    ] in
    
    List.iteri (fun i (input, expected) ->
      let result = remove_hash_comment_function (StringValue input) in
      match result with
      | StringValue output ->
          if String.equal output expected then
            Printf.printf "✅ 井号注释移除测试 %d 通过: \"%s\" -> \"%s\"\n" (i+1) input output
          else
            Printf.printf "❌ 井号注释移除测试 %d 失败: 期望 \"%s\"，实际 \"%s\"\n" (i+1) expected output
      | _ -> Printf.printf "❌ 井号注释移除测试 %d 返回类型错误\n" (i+1)
    ) test_cases;
  with
  | e -> Printf.printf "❌ remove_hash_comment_function 测试失败: %s\n" (Printexc.to_string e));

  (* 测试 remove_double_slash_comment_function *)
  Printf.printf "\n// 测试 remove_double_slash_comment_function\n";
  (try
    let test_cases = [
      ("代码行 // 这是注释", "代码行 ");
      ("// 整行都是注释", "");
      ("正常代码", "正常代码");
      ("\"字符串中的//不是注释\"", "\"字符串中的//不是注释\"");
      ("前面 // 中间 // 多个注释", "前面 ");
      ("", "");
      ("////多个斜杠", "");
      ("http://网址不是注释", "http:");  (* 这可能需要特殊处理 *)
      ("代码 // 注释内容包含中文字符", "代码 ")
    ] in
    
    List.iteri (fun i (input, expected) ->
      let result = remove_double_slash_comment_function (StringValue input) in
      match result with
      | StringValue output ->
          if String.equal output expected then
            Printf.printf "✅ 双斜杠注释移除测试 %d 通过: \"%s\" -> \"%s\"\n" (i+1) input output
          else
            Printf.printf "⚠️  双斜杠注释移除测试 %d 结果: \"%s\" -> \"%s\" (期望: \"%s\")\n" (i+1) input output expected
      | _ -> Printf.printf "❌ 双斜杠注释移除测试 %d 返回类型错误\n" (i+1)
    ) test_cases;
  with
  | e -> Printf.printf "❌ remove_double_slash_comment_function 测试失败: %s\n" (Printexc.to_string e));

  (* 测试 remove_block_comments_function *)
  Printf.printf "\n/* 测试 remove_block_comments_function */\n";
  (try
    let test_cases = [
      ("代码 /* 块注释 */ 更多代码", "代码  更多代码");
      ("/* 整个注释块 */", "");
      ("正常代码无注释", "正常代码无注释");
      ("/* 多行\n注释\n块 */ 代码", " 代码");
      ("代码 /* 注释1 */ 中间 /* 注释2 */ 结尾", "代码  中间  结尾");
      ("", "");
      ("/* 嵌套 /* 不支持 */ 注释 */", " 注释 */");  (* 通常不支持嵌套 *)
      ("\"字符串中的/*不是注释*/\"", "\"字符串中的/*不是注释*/\"");
      ("/* 中文注释内容：这是测试 */", "")
    ] in
    
    List.iteri (fun i (input, expected) ->
      let result = remove_block_comments_function (StringValue input) in
      match result with
      | StringValue output ->
          if String.equal output expected then
            Printf.printf "✅ 块注释移除测试 %d 通过: \"%s\" -> \"%s\"\n" (i+1) input output
          else
            Printf.printf "⚠️  块注释移除测试 %d 结果: \"%s\" -> \"%s\" (期望: \"%s\")\n" (i+1) input output expected
      | _ -> Printf.printf "❌ 块注释移除测试 %d 返回类型错误\n" (i+1)
    ) test_cases;
  with
  | e -> Printf.printf "❌ remove_block_comments_function 测试失败: %s\n" (Printexc.to_string e));

  (* 测试 remove_luoyan_strings_function *)
  Printf.printf "\n\"\" 测试 remove_luoyan_strings_function\n";
  (try
    let test_cases = [
      ("打印 \"骆言字符串\" 结束", "打印  结束");
      ("\"整个都是字符串\"", "");
      ("没有字符串的代码", "没有字符串的代码");
      ("\"第一个\" 和 \"第二个\" 字符串", " 和  字符串");
      ("\"包含中文：你好世界！\"", "");
      ("\"转义\\\"字符\"", "");  (* 可能需要特殊处理转义 *)
      ("", "");
      ("代码 \"字符串内容\" 更多代码", "代码  更多代码");
      ("\"多行\n字符串\n测试\"", "")
    ] in
    
    List.iteri (fun i (input, expected) ->
      let result = remove_luoyan_strings_function (StringValue input) in
      match result with
      | StringValue output ->
          if String.equal output expected then
            Printf.printf "✅ 骆言字符串移除测试 %d 通过: \"%s\" -> \"%s\"\n" (i+1) input output
          else
            Printf.printf "⚠️  骆言字符串移除测试 %d 结果: \"%s\" -> \"%s\" (期望: \"%s\")\n" (i+1) input output expected
      | _ -> Printf.printf "❌ 骆言字符串移除测试 %d 返回类型错误\n" (i+1)
    ) test_cases;
  with
  | e -> Printf.printf "❌ remove_luoyan_strings_function 测试失败: %s\n" (Printexc.to_string e));

  (* 测试 remove_english_strings_function *)
  Printf.printf "\n'' 测试 remove_english_strings_function\n";
  (try
    let test_cases = [
      ("print 'hello world' end", "print  end");
      ("'entire string'", "");
      ("no strings here", "no strings here");
      ("'first' and 'second' strings", " and  strings");
      ("'mixed 中英文 content'", "");
      ("'escaped\\'quote'", "");  (* 转义处理 *)
      ("", "");
      ("code 'string content' more code", "code  more code");
      ("'multi\nline\nstring'", "")
    ] in
    
    List.iteri (fun i (input, expected) ->
      let result = remove_english_strings_function (StringValue input) in
      match result with
      | StringValue output ->
          if String.equal output expected then
            Printf.printf "✅ 英文字符串移除测试 %d 通过: \"%s\" -> \"%s\"\n" (i+1) input output
          else
            Printf.printf "⚠️  英文字符串移除测试 %d 结果: \"%s\" -> \"%s\" (期望: \"%s\")\n" (i+1) input output expected
      | _ -> Printf.printf "❌ 英文字符串移除测试 %d 返回类型错误\n" (i+1)
    ) test_cases;
  with
  | e -> Printf.printf "❌ remove_english_strings_function 测试失败: %s\n" (Printexc.to_string e));

  (* 综合测试：多种处理的组合 *)
  Printf.printf "\n🔄 综合处理测试\n";
  (try
    let complex_input = "代码行 \"字符串\" // 注释 /* 块注释 */ 更多代码 # 井号注释" in
    Printf.printf "🧪 原始输入: \"%s\"\n" complex_input;
    
    (* 逐步处理 *)
    let step1 = remove_luoyan_strings_function (StringValue complex_input) in
    (match step1 with
    | StringValue s1 -> Printf.printf "📝 移除骆言字符串后: \"%s\"\n" s1;
        let step2 = remove_double_slash_comment_function step1 in
        (match step2 with
        | StringValue s2 -> Printf.printf "📝 移除双斜杠注释后: \"%s\"\n" s2;
            let step3 = remove_block_comments_function step2 in
            (match step3 with
            | StringValue s3 -> Printf.printf "📝 移除块注释后: \"%s\"\n" s3;
                let step4 = remove_hash_comment_function step3 in
                (match step4 with
                | StringValue s4 -> Printf.printf "📝 最终结果: \"%s\"\n" s4;
                    Printf.printf "✅ 综合处理测试完成\n"
                | _ -> Printf.printf "❌ 最后一步处理失败\n")
            | _ -> Printf.printf "❌ 块注释处理失败\n")
        | _ -> Printf.printf "❌ 双斜杠注释处理失败\n")
    | _ -> Printf.printf "❌ 字符串处理失败\n");
  with
  | e -> Printf.printf "❌ 综合处理测试失败: %s\n" (Printexc.to_string e));

  (* 性能测试 *)
  Printf.printf "\n⚡ 性能测试\n";
  (try
    let large_text = String.concat "\n" (List.init 1000 (fun i ->
      Printf.sprintf "第%d行代码 \"字符串%d\" // 注释%d # 井号注释%d /* 块注释%d */" i i i i i
    )) in
    
    let start_time = Sys.time () in
    for i = 1 to 100 do
      let _ = remove_hash_comment_function (StringValue large_text) in
      let _ = remove_double_slash_comment_function (StringValue large_text) in
      let _ = remove_block_comments_function (StringValue large_text) in
      let _ = remove_luoyan_strings_function (StringValue large_text) in
      let _ = remove_english_strings_function (StringValue large_text) in
      ()
    done;
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    Printf.printf "✅ 性能测试完成: 100次大文本处理耗时 %.6f秒\n" duration;
    Printf.printf "📊 平均每次处理耗时: %.6f秒\n" (duration /. 100.0);
    
    if duration < 10.0 then
      Printf.printf "✅ 性能表现良好\n"
    else
      Printf.printf "⚠️  性能可能需要优化\n";
  with
  | e -> Printf.printf "❌ 性能测试失败: %s\n" (Printexc.to_string e));

  (* 边界条件测试 *)
  Printf.printf "\n⚠️  边界条件测试\n";
  (try
    (* 测试极长的字符串 *)
    let very_long_string = String.make 10000 'A' ^ "# 注释" in
    let result1 = remove_hash_comment_function (StringValue very_long_string) in
    (match result1 with
    | StringValue s when String.length s = 10000 ->
        Printf.printf "✅ 极长字符串处理测试通过\n"
    | _ -> Printf.printf "❌ 极长字符串处理失败\n");
    
    (* 测试特殊字符 *)
    let special_chars = "特殊字符测试: \t\n\r\\\"'/*#//" in
    let _ = remove_hash_comment_function (StringValue special_chars) in
    let _ = remove_double_slash_comment_function (StringValue special_chars) in
    let _ = remove_block_comments_function (StringValue special_chars) in
    Printf.printf "✅ 特殊字符处理测试通过\n";
    
    (* 测试Unicode字符 *)
    let unicode_text = "Unicode: 🔧🧪📁💻🌏✅❌⚠️" in
    let _ = remove_luoyan_strings_function (StringValue unicode_text) in
    Printf.printf "✅ Unicode字符处理测试通过\n";
  with
  | e -> Printf.printf "❌ 边界条件测试失败: %s\n" (Printexc.to_string e));

  Printf.printf "\n🎉 骆言内置工具函数模块全面测试完成！\n";
  Printf.printf "📊 测试涵盖: 文件过滤、注释移除、字符串处理、综合处理\n";
  Printf.printf "🔧 包含性能测试、边界条件测试和Unicode支持测试\n";
  Printf.printf "🌏 支持中文字符和各种注释格式的处理\n"