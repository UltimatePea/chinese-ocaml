open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser

(** 测试类定义解析 *)
let test_class_definition () =
  let input = "类 人 = { 姓名: 字符串; 年龄: 整数; 方法 介绍自己 () = 打印 (字符串连接 \"我是\" 姓名) }" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    (match program with
     | [ClassDefStmt class_def] ->
       Printf.printf "✅ 类定义解析成功: 类名=%s, 字段数=%d, 方法数=%d\n"
         class_def.class_name
         (List.length class_def.fields)
         (List.length class_def.methods);
       assert (class_def.class_name = "人");
       assert (List.length class_def.fields = 2);
       assert (List.length class_def.methods = 1);
       true
     | _ -> 
       Printf.printf "❌ 解析结果不是单个类定义\n";
       false)
  with
  | exn ->
    Printf.printf "❌ 类定义解析失败: %s\n" (Printexc.to_string exn);
    false

(** 测试继承语法解析 *)
let test_inheritance_parsing () =
  let input = "类 学生 继承 人 = { 学号: 字符串; 方法 学习 () = 打印 \"正在学习\" }" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    (match program with
     | [ClassDefStmt class_def] ->
       Printf.printf "✅ 继承解析成功: %s 继承 %s\n"
         class_def.class_name
         (match class_def.superclass with Some s -> s | None -> "无");
       assert (class_def.class_name = "学生");
       assert (class_def.superclass = Some "人");
       true
     | _ ->
       Printf.printf "❌ 继承解析结果格式错误\n";
       false)
  with
  | exn ->
    Printf.printf "❌ 继承解析失败: %s\n" (Printexc.to_string exn);
    false

(** 测试对象创建解析 *)
let test_object_creation_parsing () =
  let input = "让 小明 = 新建 人 { 姓名 = \"小明\"; 年龄 = 20 }" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    (match program with
     | [LetStmt (var_name, NewObjectExpr (class_name, field_inits))] ->
       Printf.printf "✅ 对象创建解析成功: %s = new %s 有 %d 个字段\n"
         var_name class_name (List.length field_inits);
       assert (var_name = "小明");
       assert (class_name = "人");
       assert (List.length field_inits = 2);
       true
     | _ ->
       Printf.printf "❌ 对象创建解析结果格式错误\n";
       false)
  with
  | exn ->
    Printf.printf "❌ 对象创建解析失败: %s\n" (Printexc.to_string exn);
    false

(** 测试方法调用解析 *)
let test_method_call_parsing () =
  let input = "小明#介绍自己" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    (match program with
     | [ExprStmt (MethodCallExpr (VarExpr obj_name, method_name, args))] ->
       Printf.printf "✅ 方法调用解析成功: %s#%s 有 %d 个参数\n"
         obj_name method_name (List.length args);
       assert (obj_name = "小明");
       assert (method_name = "介绍自己");
       assert (List.length args = 0); (* 无参数 *)
       true
     | _ ->
       Printf.printf "❌ 方法调用解析结果格式错误\n";
       false)
  with
  | exn ->
    Printf.printf "❌ 方法调用解析失败: %s\n" (Printexc.to_string exn);
    false

(** 测试自己引用解析 *)
let test_self_parsing () =
  let input = "自己" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    (match program with
     | [ExprStmt SelfExpr] ->
       Printf.printf "✅ 自己引用解析成功\n";
       true
     | _ ->
       Printf.printf "❌ 自己引用解析结果格式错误\n";
       false)
  with
  | exn ->
    Printf.printf "❌ 自己引用解析失败: %s\n" (Printexc.to_string exn);
    false

(** 运行所有测试 *)
let run_tests () =
  Printf.printf "🧪 开始面向对象语法解析测试...\n\n";
  
  let tests = [
    ("类定义解析", test_class_definition);
    ("继承语法解析", test_inheritance_parsing);
    ("对象创建解析", test_object_creation_parsing);
    ("方法调用解析", test_method_call_parsing);
    ("自己引用解析", test_self_parsing);
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
    Printf.printf "🎉 所有面向对象语法解析测试通过！\n"
  else
    Printf.printf "⚠️  有 %d 个测试失败\n" (total - !passed)

let () = run_tests ()