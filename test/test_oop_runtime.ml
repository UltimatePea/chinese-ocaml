open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Codegen

(** 测试基础类定义和对象创建 *)
let test_basic_class_and_object () =
  let input = "
类 人 = { 
  姓名: 字符串; 
  年龄: 整数; 
  方法 介绍自己 () = 打印 (「字符串连接」 \"我是\" 姓名) 
}

让 小明 = 新建 人 { 姓名 = \"小明\"; 年龄 = 20 }
小明
" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    match execute_program program with
    | Ok result ->
      (match result with
       | ObjectValue (class_name, _field_table, _method_table) ->
         Printf.printf "✅ 对象创建成功: 类型=%s\n" class_name;
         assert (class_name = "人");
         true
       | _ ->
         Printf.printf "❌ 对象创建失败，返回类型: %s\n" (value_to_string result);
         false)
    | Error msg ->
      Printf.printf "❌ 程序执行失败: %s\n" msg;
      false
  with
  | exn ->
    Printf.printf "❌ 基础类和对象测试失败: %s\n" (Printexc.to_string exn);
    false

(** 测试方法调用 *)
let test_method_call () =
  let input = "
类 问候器 = { 
  问候语: 字符串; 
  方法 问候 () = 打印 问候语
}

让 中文问候器 = 新建 问候器 { 问候语 = \"你好！\" }
中文问候器#问候
" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    match execute_program program with
    | Ok result ->
      Printf.printf "✅ 方法调用测试完成，结果: %s\n" (value_to_string result);
      (* 方法调用应该返回单元值，因为打印函数返回单元值 *)
      assert (result = UnitValue);
      true
    | Error msg ->
      Printf.printf "❌ 方法调用执行失败: %s\n" msg;
      false
  with
  | exn ->
    Printf.printf "❌ 方法调用测试失败: %s\n" (Printexc.to_string exn);
    false

(** 测试继承 *)
let test_inheritance () =
  let input = "
类 动物 = { 
  名字: 字符串; 
  方法 叫声 () = 打印 \"一些声音\"
}

类 狗 继承 动物 = { 
  品种: 字符串; 
  方法 叫声 () = 打印 \"汪汪！\"
}

让 小白 = 新建 狗 { 名字 = \"小白\"; 品种 = \"金毛\" }
小白
" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    match execute_program program with
    | Ok result ->
      (match result with
       | ObjectValue (class_name, _field_table, _method_table) ->
         Printf.printf "✅ 继承测试成功: 类型=%s\n" class_name;
         assert (class_name = "狗");
         true
       | _ ->
         Printf.printf "❌ 继承测试失败，返回类型: %s\n" (value_to_string result);
         false)
    | Error msg ->
      Printf.printf "❌ 继承程序执行失败: %s\n" msg;
      false
  with
  | exn ->
    Printf.printf "❌ 继承测试失败: %s\n" (Printexc.to_string exn);
    false

(** 测试字段访问 *)
let test_field_access () =
  let input = "
类 学生 = { 
  姓名: 字符串; 
  学号: 字符串;
  方法 获取姓名 () = 姓名
}

让 张三 = 新建 学生 { 姓名 = \"张三\"; 学号 = \"2021001\" }
张三#获取姓名
" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    match execute_program program with
    | Ok result ->
      (match result with
       | StringValue name ->
         Printf.printf "✅ 字段访问测试成功: 姓名=%s\n" name;
         assert (name = "张三");
         true
       | _ ->
         Printf.printf "❌ 字段访问测试失败，返回类型: %s\n" (value_to_string result);
         false)
    | Error msg ->
      Printf.printf "❌ 字段访问程序执行失败: %s\n" msg;
      false
  with
  | exn ->
    Printf.printf "❌ 字段访问测试失败: %s\n" (Printexc.to_string exn);
    false

(** 测试带参数的方法 *)
let test_method_with_parameters () =
  let input = "
类 计算器 = {
  方法 加法 (a, b) = a + b
}

让 我的计算器 = 新建 计算器 {}
我的计算器#加法 5 3
" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    match execute_program program with
    | Ok result ->
      (match result with
       | IntValue sum ->
         Printf.printf "✅ 带参数方法测试成功: 5 + 3 = %d\n" sum;
         assert (sum = 8);
         true
       | _ ->
         Printf.printf "❌ 带参数方法测试失败，返回类型: %s\n" (value_to_string result);
         false)
    | Error msg ->
      Printf.printf "❌ 带参数方法程序执行失败: %s\n" msg;
      false
  with
  | exn ->
    Printf.printf "❌ 带参数方法测试失败: %s\n" (Printexc.to_string exn);
    false

(** 运行所有测试 *)
let run_tests () =
  Printf.printf "🧪 开始面向对象运行时测试...\n\n";
  
  let tests = [
    ("基础类和对象", test_basic_class_and_object);
    ("方法调用", test_method_call);
    ("继承", test_inheritance);
    ("字段访问", test_field_access);
    ("带参数的方法", test_method_with_parameters);
  ] in
  
  let passed = ref 0 in
  let total = List.length tests in
  
  List.iter (fun (name, test) ->
    Printf.printf "🔍 测试: %s\n" name;
    if test () then incr passed;
    Printf.printf "\n"
  ) tests;
  
  Printf.printf "📊 测试结果: %d/%d 通过\n" !passed total;
  if !passed = total then
    Printf.printf "🎉 所有面向对象运行时测试通过！\n"
  else
    Printf.printf "⚠️  有 %d 个测试失败\n" (total - !passed)

let () = run_tests ()