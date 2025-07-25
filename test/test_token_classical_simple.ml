(** 简化的Token古典语言转换Phase 4.2测试 - Issue #1336
    
    验证重构后的核心功能：
    1. 策略模式正确工作
    2. 向后兼容性保持
    3. 基本错误处理

    @author Alpha, 主工作代理 - Issue #1336 *)

open Yyocamlc_lib.Token_conversion_classical
module TI = Token_mapping.Token_definitions_unified
module TO = Yyocamlc_lib.Lexer_tokens

let test_wenyan_strategy () =
  Printf.printf "测试文言文策略...\n";
  try
    let result = convert_with_classical_strategy Wenyan TI.HaveKeyword in
    if result = TO.HaveKeyword then (
      Printf.printf "✅ 文言文策略转换成功\n";
      true
    ) else (
      Printf.printf "❌ 文言文策略转换结果错误\n";
      false
    )
  with exn ->
    Printf.printf "❌ 文言文策略异常: %s\n" (Printexc.to_string exn);
    false

let test_natural_strategy () =
  Printf.printf "测试自然语言策略...\n";
  try
    let result = convert_with_classical_strategy Natural_Language TI.DefineKeyword in
    if result = TO.DefineKeyword then (
      Printf.printf "✅ 自然语言策略转换成功\n";
      true
    ) else (
      Printf.printf "❌ 自然语言策略转换结果错误\n";
      false
    )
  with exn ->
    Printf.printf "❌ 自然语言策略异常: %s\n" (Printexc.to_string exn);
    false

let test_ancient_strategy () =
  Printf.printf "测试古雅体策略...\n";
  try
    let result = convert_with_classical_strategy Ancient_Style TI.AncientDefineKeyword in
    if result = TO.AncientDefineKeyword then (
      Printf.printf "✅ 古雅体策略转换成功\n";
      true
    ) else (
      Printf.printf "❌ 古雅体策略转换结果错误\n";
      false
    )
  with exn ->
    Printf.printf "❌ 古雅体策略异常: %s\n" (Printexc.to_string exn);
    false

let test_backward_compatibility () =
  Printf.printf "测试向后兼容性...\n";
  try
    (* 测试主函数 *)
    let result1 = convert_classical_token TI.HaveKeyword in
    let result2 = convert_classical_token TI.DefineKeyword in
    let result3 = convert_classical_token TI.AncientDefineKeyword in
    
    (* 测试兼容性模块 *)
    let result4 = Wenyan.convert_wenyan_token TI.HaveKeyword in
    let result5 = Natural.convert_natural_language_token TI.DefineKeyword in
    let result6 = Ancient.convert_ancient_token TI.AncientDefineKeyword in
    
    if result1 = TO.HaveKeyword && result2 = TO.DefineKeyword && result3 = TO.AncientDefineKeyword &&
       result4 = TO.HaveKeyword && result5 = TO.DefineKeyword && result6 = TO.AncientDefineKeyword then (
      Printf.printf "✅ 向后兼容性测试通过\n";
      true
    ) else (
      Printf.printf "❌ 向后兼容性测试失败\n";
      false
    )
  with exn ->
    Printf.printf "❌ 向后兼容性测试异常: %s\n" (Printexc.to_string exn);
    false

let test_error_handling () =
  Printf.printf "测试错误处理...\n";
  try
    (* 测试错误的策略组合 *)
    let _ = convert_with_classical_strategy Wenyan TI.DefineKeyword in
    Printf.printf "❌ 应该抛出异常但没有\n";
    false
  with
  | Unknown_classical_token _ ->
      Printf.printf "✅ 错误处理正确\n";
      true
  | exn ->
      Printf.printf "❌ 抛出了错误的异常类型: %s\n" (Printexc.to_string exn);
      false

let run_all_tests () =
  Printf.printf "🚀 开始Token古典语言转换Phase 4.2简化测试\n";
  Printf.printf "=======================================\n";
  
  let tests = [
    ("文言文策略", test_wenyan_strategy);
    ("自然语言策略", test_natural_strategy);
    ("古雅体策略", test_ancient_strategy);
    ("向后兼容性", test_backward_compatibility);
    ("错误处理", test_error_handling);
  ] in
  
  let results = List.map (fun (name, test) ->
    Printf.printf "\n📋 %s测试:\n" name;
    let result = test () in
    result
  ) tests in
  
  let passed = List.fold_left (fun acc r -> if r then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=======================================\n";
  Printf.printf "🎯 测试结果: %d/%d 通过\n" passed total;
  
  if passed = total then (
    Printf.printf "🎉 所有测试通过！Phase 4.2重构成功！\n";
    true
  ) else (
    Printf.printf "⚠️  有 %d 个测试失败\n" (total - passed);
    false
  )

let () = 
  let _ = run_all_tests () in
  ()