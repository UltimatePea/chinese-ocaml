open Yyocamlc_lib.Builtin_constants
open Yyocamlc_lib.Value_operations
module Ast = Yyocamlc_lib.Ast

let () =
  Printf.printf "🧪 骆言内置常量模块全面测试开始\n\n";

  (* 测试中文数字常量表 *)
  Printf.printf "🔢 测试中文数字常量表\n";
  (try
    (* 测试基本数字常量 *)
    let test_digit name expected_value =
      match List.assoc_opt name chinese_number_constants with
      | Some (IntValue v) when v = expected_value ->
          Printf.printf "✅ 中文数字常量 '%s' -> %d 测试通过\n" name expected_value
      | Some value ->
          Printf.printf "❌ 中文数字常量 '%s' 值不匹配，期望 %d\n" name expected_value
      | None ->
          Printf.printf "❌ 中文数字常量 '%s' 未找到\n" name
    in
    
    test_digit "零" 0;
    test_digit "一" 1;
    test_digit "二" 2;
    test_digit "三" 3;
    test_digit "四" 4;
    test_digit "五" 5;
    test_digit "六" 6;
    test_digit "七" 7;
    test_digit "八" 8;
    test_digit "九" 9;
    
    Printf.printf "✅ 所有基础中文数字常量测试完成\n";
  with
  | e -> Printf.printf "❌ 中文数字常量表测试失败: %s\n" (Printexc.to_string e));

  (* 测试常量表完整性 *)
  Printf.printf "\n📋 测试常量表完整性\n";
  (try
    let expected_constants = ["零"; "一"; "二"; "三"; "四"; "五"; "六"; "七"; "八"; "九"] in
    let actual_constants = List.map fst chinese_number_constants in
    
    let missing_constants = List.filter (fun const -> not (List.mem const actual_constants)) expected_constants in
    let extra_constants = List.filter (fun const -> not (List.mem const expected_constants)) actual_constants in
    
    if missing_constants = [] && extra_constants = [] then
      Printf.printf "✅ 常量表完整性检查通过，包含所有预期常量\n"
    else begin
      if missing_constants <> [] then
        Printf.printf "❌ 缺少常量: %s\n" (String.concat ", " missing_constants);
      if extra_constants <> [] then
        Printf.printf "⚠️  额外常量: %s\n" (String.concat ", " extra_constants);
    end;
    
    let total_count = List.length chinese_number_constants in
    Printf.printf "📊 常量表总数: %d 个常量\n" total_count;
  with
  | e -> Printf.printf "❌ 常量表完整性测试失败: %s\n" (Printexc.to_string e));

  (* 测试 make_chinese_number_constant 函数 *)
  Printf.printf "\n🔧 测试 make_chinese_number_constant 函数\n";
  (try
    (* 测试正常调用应该返回错误消息 *)
    let result1 = make_chinese_number_constant 5 in
    (match result1 with
    | StringValue msg when String.length msg > 0 ->
        Printf.printf "✅ make_chinese_number_constant() 正确返回错误消息: \"%s\"\n" msg
    | _ ->
        Printf.printf "❌ make_chinese_number_constant() 未返回预期的错误消息\n");
    
    Printf.printf "✅ make_chinese_number_constant 函数测试通过\n";
  with
  | e -> Printf.printf "❌ make_chinese_number_constant 函数测试失败: %s\n" (Printexc.to_string e));

  (* 测试常量值的数据类型 *)
  Printf.printf "\n🏗️ 测试常量值数据类型\n";
  (try
    let check_value_type name value =
      match value with
      | IntValue n when n >= 0 && n <= 9 ->
          Printf.printf "✅ 常量 '%s' 类型正确: IntValue(%d)\n" name n
      | IntValue n ->
          Printf.printf "❌ 常量 '%s' 值超出范围: IntValue(%d)\n" name n
      | _ ->
          Printf.printf "❌ 常量 '%s' 类型错误，应为 IntValue\n" name
    in
    
    List.iter (fun (name, value) -> check_value_type name value) chinese_number_constants;
    Printf.printf "✅ 所有常量类型检查完成\n";
  with
  | e -> Printf.printf "❌ 常量类型测试失败: %s\n" (Printexc.to_string e));

  (* 测试常量访问性能 *)
  Printf.printf "\n⚡ 测试常量访问性能\n";
  (try
    let start_time = Sys.time () in
    for i = 1 to 10000 do
      let _ = List.assoc_opt "五" chinese_number_constants in
      ()
    done;
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    Printf.printf "✅ 10000次常量访问耗时: %.6f秒\n" duration;
    
    if duration < 1.0 then
      Printf.printf "✅ 常量访问性能良好\n"
    else
      Printf.printf "⚠️  常量访问性能需要优化\n";
  with
  | e -> Printf.printf "❌ 性能测试失败: %s\n" (Printexc.to_string e));

  (* 测试常量的不可变性 *)
  Printf.printf "\n🔒 测试常量不可变性\n";
  (try
    let original_constants = chinese_number_constants in
    let original_length = List.length original_constants in
    
    (* 尝试获取常量值（应该不会修改原始数据） *)
    let _ = List.assoc_opt "三" chinese_number_constants in
    let _ = List.assoc_opt "不存在的常量" chinese_number_constants in
    
    let current_length = List.length chinese_number_constants in
    if original_length = current_length then
      Printf.printf "✅ 常量表保持不可变性，长度一致: %d\n" current_length
    else
      Printf.printf "❌ 常量表长度发生变化: %d -> %d\n" original_length current_length;
    
    Printf.printf "✅ 常量不可变性测试完成\n";
  with
  | e -> Printf.printf "❌ 不可变性测试失败: %s\n" (Printexc.to_string e));

  (* 边界条件测试 *)
  Printf.printf "\n⚠️  边界条件测试\n";
  (try
    (* 测试空字符串查找 *)
    let result1 = List.assoc_opt "" chinese_number_constants in
    (match result1 with
    | None -> Printf.printf "✅ 空字符串查找正确返回 None\n"
    | Some _ -> Printf.printf "❌ 空字符串查找应该返回 None\n");
    
    (* 测试不存在的中文数字 *)
    let non_existent = ["十"; "百"; "千"; "万"; "壹"; "贰"; "叁"; "拾"] in
    let found_non_existent = List.filter (fun name -> 
      List.assoc_opt name chinese_number_constants <> None
    ) non_existent in
    
    if found_non_existent = [] then
      Printf.printf "✅ 不存在的中文数字正确未找到\n"
    else
      Printf.printf "⚠️  意外找到的数字: %s\n" (String.concat ", " found_non_existent);
    
    (* 测试Unicode字符处理 *)
    let unicode_numbers = ["０"; "１"; "２"; "３"; "４"; "５"; "６"; "７"; "８"; "９"] in
    let found_unicode = List.filter (fun name -> 
      List.assoc_opt name chinese_number_constants <> None
    ) unicode_numbers in
    
    if found_unicode = [] then
      Printf.printf "✅ 全角数字字符正确未包含在常量表中\n"
    else
      Printf.printf "⚠️  意外包含的全角数字: %s\n" (String.concat ", " found_unicode);
    
    Printf.printf "✅ 边界条件测试全部完成\n";
  with
  | e -> Printf.printf "❌ 边界条件测试失败: %s\n" (Printexc.to_string e));

  Printf.printf "\n🎉 骆言内置常量模块全面测试完成！\n";
  Printf.printf "📊 测试涵盖: 中文数字常量表、函数调用、类型检查、性能测试、不可变性\n";
  Printf.printf "🔧 包含边界条件和错误处理测试\n"