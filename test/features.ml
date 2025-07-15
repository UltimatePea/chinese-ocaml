(* AI功能测试模块 *)
open Ai

let test_intent_parser () =
  Printf.printf "🧪 开始意图解析器测试...\n\n";

  let test_cases =
    [
      ("创建斐波那契函数", "CreateFunction");
      ("对列表排序", "ProcessList");
      ("计算阶乘", "CreateFunction");
      ("过滤正数", "ProcessList");
      ("条件判断", "Unknown");
    ]
  in

  let success_count = ref 0 in
  let total_count = List.length test_cases in

  List.iter
    (fun (input, _expected_category) ->
      Printf.printf "🔍 测试: %s\n" input;
      try
        let suggestions = Intent_parser.intelligent_completion input in
        if List.length suggestions > 0 then (
          let best_suggestion = List.hd suggestions in
          Printf.printf "✅ 获得建议: %s (置信度: %.0f%%)\n" best_suggestion.description
            (best_suggestion.confidence *. 100.0);
          if best_suggestion.confidence > 0.5 then incr success_count)
        else Printf.printf "❌ 没有生成建议\n"
      with e ->
        Printf.printf "❌ 测试失败: %s\n" (Printexc.to_string e);
        Printf.printf "\n")
    test_cases;

  Printf.printf "📊 意图解析测试结果: %d/%d 通过\n" !success_count total_count;
  if !success_count = total_count then Printf.printf "🎉 所有意图解析测试通过！\n"
  else Printf.printf "⚠️  部分测试未通过\n";
  Printf.printf "\n"

let test_code_completion () =
  Printf.printf "🧪 开始代码补全测试...\n\n";

  let test_cases =
    [ ("让 ", 3, "变量声明"); ("函", 1, "函数关键字"); ("匹配", 2, "模式匹配"); ("递", 1, "递归关键字"); ("打", 1, "打印函数") ]
  in

  let success_count = ref 0 in
  let total_count = List.length test_cases in

  List.iter
    (fun (input, cursor_pos, description) ->
      Printf.printf "🔍 测试: '%s' (位置: %d) - %s\n" input cursor_pos description;
      try
        let context = Code_completion.create_default_context () in
        let completions = Code_completion.complete_code input cursor_pos context in
        if List.length completions > 0 then (
          Printf.printf "✅ 获得 %d 个补全建议\n" (List.length completions);
          let best = List.hd completions in
          Printf.printf "   最佳建议: %s (评分: %.2f)\n" best.display_text best.score;
          if best.score > 0.3 then incr success_count)
        else Printf.printf "❌ 没有补全建议\n"
      with e ->
        Printf.printf "❌ 测试失败: %s\n" (Printexc.to_string e);
        Printf.printf "\n")
    test_cases;

  Printf.printf "📊 代码补全测试结果: %d/%d 通过\n" !success_count total_count;
  if !success_count = total_count then Printf.printf "🎉 所有代码补全测试通过！\n"
  else Printf.printf "⚠️  部分测试未通过\n";
  Printf.printf "\n"

let test_pattern_matching () =
  Printf.printf "🧪 开始模式匹配测试...\n\n";

  let test_cases =
    [
      ("递归函数计算阶乘", "递归函数模式");
      ("处理列表中的元素", "列表处理模式");
      ("条件判断检查", "条件分支模式");
      ("快速排序算法", "分治算法模式");
      ("状态机处理", "状态机模式");
    ]
  in

  let success_count = ref 0 in
  let total_count = List.length test_cases in

  List.iter
    (fun (input, _expected_pattern) ->
      Printf.printf "🔍 测试: %s\n" input;
      try
        let matches = Pattern_matching.find_best_patterns input 3 in
        if List.length matches > 0 then (
          let best_match = List.hd matches in
          Printf.printf "✅ 匹配模式: %s (置信度: %.0f%%)\n" best_match.pattern.name
            (best_match.confidence *. 100.0);
          if best_match.confidence > 0.2 then incr success_count)
        else Printf.printf "❌ 没有匹配的模式\n"
      with e ->
        Printf.printf "❌ 测试失败: %s\n" (Printexc.to_string e);
        Printf.printf "\n")
    test_cases;

  Printf.printf "📊 模式匹配测试结果: %d/%d 通过\n" !success_count total_count;
  if !success_count = total_count then Printf.printf "🎉 所有模式匹配测试通过！\n"
  else Printf.printf "⚠️  部分测试未通过\n";
  Printf.printf "\n"

let test_natural_language () =
  Printf.printf "🧪 开始自然语言处理测试...\n\n";

  let test_cases =
    [
      ("定义「阶乘」函数", "函数定义"); ("计算列表长度", "计算操作"); ("过滤正数", "数据处理"); ("排序算法", "算法实现"); ("条件判断", "控制流");
    ]
  in

  let success_count = ref 0 in
  let total_count = List.length test_cases in

  List.iter
    (fun (input, description) ->
      Printf.printf "🔍 测试: %s - %s\n" input description;
      try
        let semantic_units = Natural_language.extract_semantic_units input in
        let intent = Natural_language.identify_intent semantic_units in
        let suggestions = Natural_language.generate_code_suggestions intent in

        Printf.printf "✅ 识别 %d 个语义单元，生成 %d 个建议\n" (List.length semantic_units)
          (List.length suggestions);

        if List.length semantic_units > 0 && List.length suggestions > 0 then incr success_count
      with e ->
        Printf.printf "❌ 测试失败: %s\n" (Printexc.to_string e);
        Printf.printf "\n")
    test_cases;

  Printf.printf "📊 自然语言处理测试结果: %d/%d 通过\n" !success_count total_count;
  if !success_count = total_count then Printf.printf "🎉 所有自然语言处理测试通过！\n"
  else Printf.printf "⚠️  部分测试未通过\n";
  Printf.printf "\n"

let test_integration () =
  Printf.printf "🧪 开始AI功能集成测试...\n\n";

  let test_input = "创建一个递归函数计算斐波那契数列" in
  Printf.printf "🔍 综合测试: %s\n\n" test_input;

  let success_steps = ref 0 in

  (* 步骤1: 意图解析 *)
  Printf.printf "步骤1: 意图解析\n";
  (try
     let suggestions = Intent_parser.intelligent_completion test_input in
     if List.length suggestions > 0 then (
       Printf.printf "✅ 意图解析成功，生成 %d 个建议\n" (List.length suggestions);
       incr success_steps)
     else Printf.printf "❌ 意图解析失败\n"
   with e -> Printf.printf "❌ 意图解析异常: %s\n" (Printexc.to_string e));

  (* 步骤2: 模式匹配 *)
  Printf.printf "\n步骤2: 模式匹配\n";
  (try
     let matches = Pattern_matching.find_best_patterns test_input 1 in
     if List.length matches > 0 then (
       Printf.printf "✅ 模式匹配成功，找到模式: %s\n" (List.hd matches).pattern.name;
       incr success_steps)
     else Printf.printf "❌ 模式匹配失败\n"
   with e -> Printf.printf "❌ 模式匹配异常: %s\n" (Printexc.to_string e));

  (* 步骤3: 自然语言处理 *)
  Printf.printf "\n步骤3: 自然语言处理\n";
  (try
     let code_suggestions = Natural_language.natural_language_to_code test_input in
     if List.length code_suggestions > 0 then (
       Printf.printf "✅ 自然语言处理成功，生成 %d 个代码建议\n" (List.length code_suggestions);
       incr success_steps)
     else Printf.printf "❌ 自然语言处理失败\n"
   with e -> Printf.printf "❌ 自然语言处理异常: %s\n" (Printexc.to_string e));

  Printf.printf "\n📊 集成测试结果: %d/3 步骤成功\n" !success_steps;
  if !success_steps = 3 then Printf.printf "🎉 AI功能集成测试完全通过！\n" else Printf.printf "⚠️  部分集成功能需要改进\n";
  Printf.printf "\n"

let run_all_tests () =
  Printf.printf "=== AI功能全面测试 ===\n\n";

  test_intent_parser ();
  test_code_completion ();
  test_pattern_matching ();
  test_natural_language ();
  test_integration ();

  Printf.printf "=== AI功能测试完成 ===\n"

(* 主测试入口 *)
let () = run_all_tests ()

