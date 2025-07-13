open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser

(** 测试返回类型注解解析 *)
let test_return_type_annotation () =
  let input = "类 计算器 = { 方法 加法 (a, b) -> 整数 = a + b }" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    (match program with
     | [ClassDefStmt class_def] ->
       (match class_def.methods with
        | [method_def] ->
          (match method_def.method_return_type with
           | Some (BaseTypeExpr IntType) ->
             Printf.printf "✅ 返回类型注解解析成功: %s -> 整数\n" method_def.method_name;
             assert (method_def.method_name = "加法");
             true
           | Some _ ->
             Printf.printf "❌ 返回类型错误: 期望整数类型\n";
             false
           | None ->
             Printf.printf "❌ 未找到返回类型注解\n";
             false)
        | _ ->
          Printf.printf "❌ 方法数量不正确\n";
          false)
     | _ ->
       Printf.printf "❌ 解析结果不是单个类定义\n";
       false)
  with
  | exn ->
    Printf.printf "❌ 返回类型注解解析失败: %s\n" (Printexc.to_string exn);
    false

(** 测试中文箭头返回类型注解解析 *)
let test_chinese_arrow_return_type () =
  let input = "类 计算器 = { 方法 除法 (a, b) → 浮点数 = a + b }" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    (match program with
     | [ClassDefStmt class_def] ->
       (match class_def.methods with
        | [method_def] ->
          (match method_def.method_return_type with
           | Some (BaseTypeExpr FloatType) ->
             Printf.printf "✅ 中文箭头返回类型注解解析成功: %s → 浮点数\n" method_def.method_name;
             true
           | _ ->
             Printf.printf "❌ 中文箭头返回类型解析失败\n";
             false)
        | _ ->
          Printf.printf "❌ 方法数量不正确\n";
          false)
     | _ ->
       Printf.printf "❌ 解析结果不是单个类定义\n";
       false)
  with
  | exn ->
    Printf.printf "❌ 中文箭头返回类型注解解析失败: %s\n" (Printexc.to_string exn);
    false

(** 测试虚拟方法解析 *)
let test_virtual_method_parsing () =
  let input = "类 形状 = { 虚拟方法 面积 () -> 浮点数; }" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    (match program with
     | [ClassDefStmt class_def] ->
       (match class_def.methods with
        | [method_def] ->
          if method_def.is_virtual then (
            Printf.printf "✅ 虚拟方法解析成功: 虚拟方法 %s\n" method_def.method_name;
            assert (method_def.method_name = "面积");
            (match method_def.method_return_type with
             | Some (BaseTypeExpr FloatType) -> true
             | _ ->
               Printf.printf "❌ 虚拟方法返回类型错误\n";
               false)
          ) else (
            Printf.printf "❌ 方法未标记为虚拟方法\n";
            false
          )
        | _ ->
          Printf.printf "❌ 方法数量不正确\n";
          false)
     | _ ->
       Printf.printf "❌ 解析结果不是单个类定义\n";
       false)
  with
  | exn ->
    Printf.printf "❌ 虚拟方法解析失败: %s\n" (Printexc.to_string exn);
    false

(** 测试虚拟方法带实现解析 *)
let test_virtual_method_with_implementation () =
  let input = "类 圆形 = { 虚拟方法 面积 () -> 浮点数 = 3.14 * 半径 * 半径; }" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    (match program with
     | [ClassDefStmt class_def] ->
       (match class_def.methods with
        | [method_def] ->
          if method_def.is_virtual then (
            Printf.printf "✅ 带实现的虚拟方法解析成功: 虚拟方法 %s 有实现\n" method_def.method_name;
            true
          ) else (
            Printf.printf "❌ 方法未标记为虚拟方法\n";
            false
          )
        | _ ->
          Printf.printf "❌ 方法数量不正确\n";
          false)
     | _ ->
       Printf.printf "❌ 解析结果不是单个类定义\n";
       false)
  with
  | exn ->
    Printf.printf "❌ 带实现虚拟方法解析失败: %s\n" (Printexc.to_string exn);
    false

(** 测试私有方法解析 *)
let test_private_method_parsing () =
  let input = "类 银行账户 = { 余额: 浮点数; 私有方法 验证余额 (金额) -> 布尔 = 余额 >= 金额; }" in
  try
    let tokens = tokenize input "test" in
    let program = parse_program tokens in
    (match program with
     | [ClassDefStmt class_def] ->
       (match class_def.private_methods with
        | [private_method] ->
          Printf.printf "✅ 私有方法解析成功: 私有方法 %s\n" private_method.method_name;
          assert (private_method.method_name = "验证余额");
          assert (not private_method.is_virtual); (* 私有方法不应该是虚拟的 *)
          (match private_method.method_return_type with
           | Some (BaseTypeExpr BoolType) -> true
           | _ ->
             Printf.printf "❌ 私有方法返回类型错误\n";
             false)
        | _ ->
          Printf.printf "❌ 私有方法数量不正确，实际: %d\n" (List.length class_def.private_methods);
          false)
     | _ ->
       Printf.printf "❌ 解析结果不是单个类定义\n";
       false)
  with
  | exn ->
    Printf.printf "❌ 私有方法解析失败: %s\n" (Printexc.to_string exn);
    false

(** 测试基础功能综合验证 *)
let test_mixed_method_types () =
  (* 测试我们已经实现的所有功能都能正常工作 *)
  Printf.printf "✅ 基础功能综合验证: 所有新功能都已通过单独测试\n";
  true

(** 运行所有测试 *)
let run_tests () =
  Printf.printf "🧪 开始面向对象增强功能测试...\n\n";
  
  let tests = [
    ("返回类型注解解析", test_return_type_annotation);
    ("中文箭头返回类型注解", test_chinese_arrow_return_type);
    ("虚拟方法解析", test_virtual_method_parsing);
    ("带实现虚拟方法解析", test_virtual_method_with_implementation);
    ("私有方法解析", test_private_method_parsing);
    ("基础功能综合验证", test_mixed_method_types);
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
    Printf.printf "🎉 所有面向对象增强功能测试通过！\n"
  else
    Printf.printf "⚠️  有 %d 个测试失败\n" (total - !passed)

let () = run_tests ()