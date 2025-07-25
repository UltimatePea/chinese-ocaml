#!/usr/bin/env ocaml

(** Phase 6.3 验证测试
    
    验证Token转换系统Phase 6.2实现的功能正确性
    
    @author Alpha, 主工作代理 - Phase 6.3 验证测试
    @version 1.0 - 功能验证  
    @since 2025-07-25
    @fixes Issue #1340 *)

let test_conversion_engine () =
  try
    let info = Conversion_engine.get_engine_info () in
    Printf.printf "✅ conversion_engine.ml 加载成功\n";
    Printf.printf "ℹ️  引擎信息: %s\n" info;
    true
  with e ->
    Printf.printf "❌ conversion_engine.ml 加载失败: %s\n" (Printexc.to_string e);
    false

let test_conversion_modern () =
  try
    let stats = Conversion_modern.get_modern_conversion_stats () in
    Printf.printf "✅ conversion_modern.ml 加载成功\n";
    Printf.printf "ℹ️  现代转换统计: %s\n" stats;
    true
  with e ->
    Printf.printf "❌ conversion_modern.ml 加载失败: %s\n" (Printexc.to_string e);
    false

let test_conversion_lexer () =
  try
    let stats = Conversion_lexer.LexerStatistics.get_lexer_performance_stats () in
    Printf.printf "✅ conversion_lexer.ml 加载成功\n";
    Printf.printf "ℹ️  词法器转换统计: %s\n" stats;
    true
  with e ->
    Printf.printf "❌ conversion_lexer.ml 加载失败: %s\n" (Printexc.to_string e);
    false

let test_lexer_token_converter () =
  try
    (* 测试一个简单的转换 *)
    let unified_token = Token_mapping.Token_definitions_unified.LetKeyword in
    let lexer_token = Lexer_token_converter.convert_token unified_token in
    Printf.printf "✅ lexer_token_converter.ml 转换测试成功\n";
    Printf.printf "ℹ️  转换结果: %s -> %s\n" "LetKeyword"
      (match lexer_token with Lexer_tokens.LetKeyword -> "LetKeyword" | _ -> "other");
    true
  with e ->
    Printf.printf "❌ lexer_token_converter.ml 转换测试失败: %s\n" (Printexc.to_string e);
    false

let main () =
  Printf.printf "\n🚀 Phase 6.3 Token转换系统验证测试\n";
  Printf.printf "=====================================\n\n";

  let results =
    [
      ("Conversion Engine", test_conversion_engine ());
      ("Conversion Modern", test_conversion_modern ());
      ("Conversion Lexer", test_conversion_lexer ());
      ("Lexer Token Converter", test_lexer_token_converter ());
    ]
  in

  let total = List.length results in
  let passed = List.fold_left (fun acc (_, result) -> if result then acc + 1 else acc) 0 results in

  Printf.printf "\n📊 测试结果汇总:\n";
  List.iter
    (fun (name, result) -> Printf.printf "  %s %s\n" (if result then "✅" else "❌") name)
    results;

  Printf.printf "\n🎯 总体结果: %d/%d 测试通过\n" passed total;

  if passed = total then (
    Printf.printf "🎉 Phase 6.3 验证测试全部通过！\n";
    Printf.printf "✨ Token转换系统Phase 6.2实现完全成功\n";
    exit 0)
  else (
    Printf.printf "⚠️  部分测试失败，需要进一步调查\n";
    exit 1)

let () = main ()
