(** Token古典语言转换Phase 4.2重构测试 - Issue #1336
    
    测试策略模式重构后的古典语言转换系统，确保：
    1. 策略模式正确实现
    2. 向后兼容性保持
    3. 所有古典语言token类型正确转换
    4. 错误处理正确

    @author Alpha, 主工作代理 - Issue #1336
    @version 1.0
    @since 2025-07-25 *)

open Yyocamlc_lib.Token_conversion_classical
open Yyocamlc_lib.Lexer_tokens
module Token_input = Token_mapping.Token_definitions_unified

(** 测试辅助函数 *)
let test_strategy_conversion strategy_name strategy tokens expected_results =
  Printf.printf "\n=== 测试%s策略转换 ===\n" strategy_name;
  let test_single_token (input_token, expected) =
    try
      let result = convert_with_classical_strategy strategy input_token in
      if result = expected then (
        Printf.printf "✅ %s -> %s\n" 
          (match input_token with 
           | Token_input.HaveKeyword -> "HaveKeyword"
           | Token_input.DefineKeyword -> "DefineKeyword"
           | Token_input.AncientDefineKeyword -> "AncientDefineKeyword"
           | _ -> "其他token")
          (match result with
           | HaveKeyword -> "HaveKeyword"
           | DefineKeyword -> "DefineKeyword" 
           | AncientDefineKeyword -> "AncientDefineKeyword"
           | _ -> "其他token");
        true
      ) else (
        Printf.printf "❌ %s 转换失败\n" strategy_name;
        false
      )
    with
    | Unknown_classical_token msg ->
        Printf.printf "❌ %s 策略异常: %s\n" strategy_name msg;
        false
    | exn ->
        Printf.printf "❌ %s 策略错误: %s\n" strategy_name (Printexc.to_string exn);
        false
  in
  List.for_all test_single_token (List.combine tokens expected_results)

(** 测试文言文策略 *)
let test_wenyan_strategy () =
  Printf.printf "\n🔧 测试文言文转换策略...\n";
  let wenyan_tokens = [
    Token_input.HaveKeyword;
    Token_input.OneKeyword;
    Token_input.NameKeyword;
    Token_input.SetKeyword;
    Token_input.AlsoKeyword;
  ] in
  let expected_results = [
    HaveKeyword;
    OneKeyword;
    NameKeyword;
    SetKeyword;
    AlsoKeyword;
  ] in
  test_strategy_conversion "文言文" Wenyan wenyan_tokens expected_results

(** 测试自然语言策略 *)
let test_natural_language_strategy () =
  Printf.printf "\n🔧 测试自然语言转换策略...\n";
  let natural_tokens = [
    Token_input.DefineKeyword;
    Token_input.AcceptKeyword;
    Token_input.ReturnWhenKeyword;
    Token_input.MultiplyKeyword;
    Token_input.DivideKeyword;
  ] in
  let expected_results = [
    DefineKeyword;
    AcceptKeyword;
    ReturnWhenKeyword;
    MultiplyKeyword;
    DivideKeyword;
  ] in
  test_strategy_conversion "自然语言" Natural_Language natural_tokens expected_results

(** 测试古雅体策略 *)
let test_ancient_style_strategy () =
  Printf.printf "\n🔧 测试古雅体转换策略...\n";
  let ancient_tokens = [
    Token_input.AncientDefineKeyword;
    Token_input.AncientEndKeyword;
    Token_input.AncientAlgorithmKeyword;
    Token_input.AncientCompleteKeyword;
    Token_input.AncientObserveKeyword;
  ] in
  let expected_results = [
    AncientDefineKeyword;
    AncientEndKeyword;
    AncientAlgorithmKeyword;
    AncientCompleteKeyword;
    AncientObserveKeyword;
  ] in
  test_strategy_conversion "古雅体" Ancient_Style ancient_tokens expected_results

(** 测试向后兼容性 *)
let test_backward_compatibility () =
  Printf.printf "\n🔧 测试向后兼容性...\n";
  
  (* 测试主转换函数 *)
  let test_main_function () =
    Printf.printf "测试主转换函数 convert_classical_token...\n";
    try
      let result = convert_classical_token Token_input.HaveKeyword in
      if result = HaveKeyword then (
        Printf.printf "✅ 主转换函数正常工作\n";
        true
      ) else (
        Printf.printf "❌ 主转换函数结果错误\n";
        false
      )
    with exn ->
      Printf.printf "❌ 主转换函数异常: %s\n" (Printexc.to_string exn);
      false
  in
  
  (* 测试兼容性模块 *)
  let test_compatibility_modules () =
    Printf.printf "测试兼容性模块...\n";
    let wenyan_ok = 
      try
        let result = Wenyan.convert_wenyan_token Token_input.HaveKeyword in
        result = HaveKeyword
      with _ -> false
    in
    let natural_ok = 
      try
        let result = Natural.convert_natural_language_token Token_input.DefineKeyword in
        result = DefineKeyword
      with _ -> false
    in
    let ancient_ok = 
      try
        let result = Ancient.convert_ancient_token Token_input.AncientDefineKeyword in
        result = AncientDefineKeyword
      with _ -> false
    in
    
    if wenyan_ok && natural_ok && ancient_ok then (
      Printf.printf "✅ 所有兼容性模块正常工作\n";
      true
    ) else (
      Printf.printf "❌ 兼容性模块测试失败\n";
      false
    )
  in
  
  (test_main_function ()) && (test_compatibility_modules ())

(** 测试错误处理 *)
let test_error_handling () =
  Printf.printf "\n🔧 测试错误处理...\n";
  
  (* 测试未知token *)
  let test_unknown_token () =
    Printf.printf "测试未知token处理...\n";
    try
      let _ = convert_with_classical_strategy Wenyan Token_input.DefineKeyword in
      Printf.printf "❌ 应该抛出异常但没有\n";
      false
    with
    | Unknown_classical_token msg ->
        Printf.printf "✅ 正确抛出Unknown_classical_token: %s\n" msg;
        true
    | exn ->
        Printf.printf "❌ 抛出了错误的异常类型: %s\n" (Printexc.to_string exn);
        false
  in
  
  (* 测试安全转换函数 *)
  let test_safe_conversion () =
    Printf.printf "测试安全转换函数...\n";
    let safe_result = convert_classical_token_safe Token_input.HaveKeyword in
    let unsafe_result = convert_classical_token_safe Token_input.DefineKeyword in
    match safe_result, unsafe_result with
    | Some _, Some _ ->
        Printf.printf "✅ 安全转换函数正常工作\n";
        true
    | _ ->
        Printf.printf "❌ 安全转换函数异常\n";
        false
  in
  
  (test_unknown_token ()) && (test_safe_conversion ())

(** 性能对比测试 *)
let test_performance_comparison () =
  Printf.printf "\n🔧 测试性能对比...\n";
  let test_token = Token_input.HaveKeyword in
  let iterations = 10000 in
  
  (* 测试新策略版本 *)
  let start_time = Sys.time () in
  for _ = 1 to iterations do
    let _ = convert_with_classical_strategy Wenyan test_token in
    ()
  done;
  let strategy_time = Sys.time () -. start_time in
  
  (* 测试兼容性版本 *)
  let start_time = Sys.time () in
  for _ = 1 to iterations do
    let _ = convert_classical_token test_token in
    ()
  done;
  let compatibility_time = Sys.time () -. start_time in
  
  Printf.printf "策略版本时间: %.6f秒\n" strategy_time;
  Printf.printf "兼容性版本时间: %.6f秒\n" compatibility_time;
  Printf.printf "性能比率: %.2fx\n" (compatibility_time /. strategy_time);
  
  true

(** 主测试函数 *)
let run_all_tests () =
  Printf.printf "🚀 开始Token古典语言转换Phase 4.2重构测试\n";
  Printf.printf "=================================================\n";
  
  let tests = [
    ("文言文策略测试", test_wenyan_strategy);
    ("自然语言策略测试", test_natural_language_strategy); 
    ("古雅体策略测试", test_ancient_style_strategy);
    ("向后兼容性测试", test_backward_compatibility);
    ("错误处理测试", test_error_handling);
    ("性能对比测试", test_performance_comparison);
  ] in
  
  let run_test (name, test_func) =
    Printf.printf "\n📋 运行测试: %s\n" name;
    try
      let result = test_func () in
      if result then
        Printf.printf "✅ %s 通过\n" name
      else
        Printf.printf "❌ %s 失败\n" name;
      result
    with exn ->
      Printf.printf "❌ %s 异常: %s\n" name (Printexc.to_string exn);
      false
  in
  
  let results = List.map run_test tests in
  let passed = List.fold_left (fun acc r -> if r then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=================================================\n";
  Printf.printf "🎯 测试结果总结: %d/%d 通过\n" passed total;
  
  if passed = total then (
    Printf.printf "🎉 所有测试通过！Phase 4.2重构成功！\n";
    true
  ) else (
    Printf.printf "⚠️  有 %d 个测试失败，需要修复\n" (total - passed);
    false
  )

(** 执行测试 *)
let () = 
  let _ = run_all_tests () in
  ()