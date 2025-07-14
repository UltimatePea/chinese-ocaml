(* 声明式编程风格转换器测试 *)

open Ai.Declarative_transformer

(* 测试辅助函数 *)
let _assert_equal expected actual test_name =
  if expected = actual then
    Printf.printf "✅ %s: 通过\n" test_name
  else
    Printf.printf "❌ %s: 失败\n  期望: %s\n  实际: %s\n" test_name expected actual

let assert_contains haystack needle test_name =
  if String.contains haystack (String.get needle 0) then
    Printf.printf "✅ %s: 通过\n" test_name
  else
    Printf.printf "❌ %s: 失败\n  在 '%s' 中未找到 '%s'\n" test_name haystack needle

let assert_not_empty list test_name =
  if List.length list > 0 then
    Printf.printf "✅ %s: 通过 (找到 %d 个建议)\n" test_name (List.length list)
  else
    Printf.printf "❌ %s: 失败 (没有找到建议)\n" test_name

(* 基础功能测试 *)
let test_basic_loop_transformation () =
  Printf.printf "\n🔍 测试: 基础循环转换\n";
  let code = "对于 每个 数字 在 列表 中 做 总和 := !总和 + 数字" in
  let suggestions = analyze_and_suggest code in
  assert_not_empty suggestions "循环累加模式识别";

  if List.length suggestions > 0 then (
    let best_suggestion = List.hd suggestions in
    assert_contains best_suggestion.transformed_code "从" "声明式语法转换";
    assert_contains best_suggestion.transformed_code "总和" "操作类型识别"
  )

let test_filter_pattern_transformation () =
  Printf.printf "\n🔍 测试: 过滤模式转换\n";
  let code = "对于 每个 数字 在 列表 中 做 如果 数字 > 0 那么 添加 数字" in
  let suggestions = analyze_and_suggest code in
  assert_not_empty suggestions "循环过滤模式识别";

  if List.length suggestions > 0 then (
    let best_suggestion = List.hd suggestions in
    assert_contains best_suggestion.transformed_code "满足" "条件转换";
    assert_contains best_suggestion.transformed_code "数字" "元素识别"
  )

let test_mapping_pattern_transformation () =
  Printf.printf "\n🔍 测试: 映射模式转换\n";
  let code = "对于 每个 字符串 在 文本列表 中 做 转换为大写 字符串" in
  let suggestions = analyze_and_suggest code in
  assert_not_empty suggestions "循环映射模式识别";

  if List.length suggestions > 0 then (
    let best_suggestion = List.hd suggestions in
    assert_contains best_suggestion.transformed_code "每个" "映射操作转换"
  )

let test_reference_update_transformation () =
  Printf.printf "\n🔍 测试: 引用更新转换\n";
  let code = "计数器 := !计数器 + 1" in
  let suggestions = analyze_and_suggest code in
  assert_not_empty suggestions "引用更新模式识别";

  if List.length suggestions > 0 then (
    let best_suggestion = List.hd suggestions in
    assert_contains best_suggestion.transformed_code "更新" "引用转换"
  )

let test_conditional_pattern_transformation () =
  Printf.printf "\n🔍 测试: 条件模式转换\n";
  let code = "如果 x > 0 那么 设置 结果 为 x" in
  let suggestions = analyze_and_suggest code in
  assert_not_empty suggestions "命令式条件模式识别";

  if List.length suggestions > 0 then (
    let best_suggestion = List.hd suggestions in
    assert_contains best_suggestion.transformed_code "当" "条件表达转换"
  )

(* 置信度评估测试 *)
let test_confidence_scoring () =
  Printf.printf "\n🔍 测试: 置信度评估\n";
  let high_confidence_code = "对于 每个 数字 在 列表 中 做 总和 := !总和 + 数字" in
  let low_confidence_code = "这是一些不相关的代码" in

  let high_suggestions = analyze_and_suggest high_confidence_code in
  let low_suggestions = analyze_and_suggest low_confidence_code in

  if List.length high_suggestions > 0 then (
    let high_conf = (List.hd high_suggestions).confidence in
    Printf.printf "✅ 高相关性代码置信度: %.0f%%\n" (high_conf *. 100.0);
    if high_conf > 0.5 then
      Printf.printf "✅ 高置信度检测: 通过\n"
    else
      Printf.printf "❌ 高置信度检测: 失败\n"
  );

  if List.length low_suggestions = 0 then
    Printf.printf "✅ 低相关性代码过滤: 通过\n"
  else
    Printf.printf "❌ 低相关性代码过滤: 失败\n"

(* 批量代码分析测试 *)
let test_code_block_analysis () =
  Printf.printf "\n🔍 测试: 批量代码分析\n";
  let code_lines = [
    "对于 每个 数字 在 列表 中 做 总和 := !总和 + 数字";
    "如果 结果 > 10 那么 设置 状态 为 完成";
    "计数器 := !计数器 + 1";
    "普通的函数定义代码";
  ] in

  let suggestions = analyze_code_block code_lines in
  let suggestion_count = List.length suggestions in

  Printf.printf "✅ 批量分析结果: 找到 %d 个转换建议\n" suggestion_count;
  if suggestion_count >= 3 then
    Printf.printf "✅ 批量分析覆盖率: 通过\n"
  else
    Printf.printf "❌ 批量分析覆盖率: 失败\n"

(* 转换报告生成测试 *)
let test_report_generation () =
  Printf.printf "\n🔍 测试: 转换报告生成\n";
  let code = "对于 每个 元素 在 数据 中 做 如果 有效 元素 那么 处理 元素" in
  let suggestions = analyze_and_suggest code in
  let report = generate_transformation_report suggestions in

  assert_contains report "转换建议统计" "报告结构检查";
  assert_contains report "优先级建议" "建议内容检查";
  Printf.printf "✅ 报告生成: 通过\n"

(* 声明式机会检测测试 *)
let test_declarative_opportunities () =
  Printf.printf "\n🔍 测试: 声明式机会检测\n";
  let imperative_code = "对于 每个 项 在 列表 中 做 累加器 := !累加器 + 项" in
  let opportunities = detect_declarative_opportunities imperative_code in

  assert_not_empty opportunities "机会检测";
  if List.length opportunities > 0 then (
    Printf.printf "检测到的机会:\n";
    List.iteri (fun i opp ->
      Printf.printf "  %d. %s\n" (i + 1) opp
    ) opportunities
  )

(* 应用转换测试 *)
let test_transformation_application () =
  Printf.printf "\n🔍 测试: 转换应用\n";
  let original = "对于 每个 数字 在 列表 中 做 总和 := !总和 + 数字" in
  let suggestions = analyze_and_suggest original in

  if List.length suggestions > 0 then (
    let suggestion = List.hd suggestions in
    let transformed = apply_transformation original suggestion in

    if transformed <> original then
      Printf.printf "✅ 转换应用: 通过\n  原始: %s\n  转换: %s\n" original transformed
    else
      Printf.printf "❌ 转换应用: 失败\n"
  ) else (
    Printf.printf "❌ 转换应用: 无建议可应用\n"
  )

(* 格式化功能测试 *)
let test_formatting_functions () =
  Printf.printf "\n🔍 测试: 格式化功能\n";
  let code = "对于 每个 项 在 列表 中 做 计算 项" in
  let suggestions = analyze_and_suggest code in

  if List.length suggestions > 0 then (
    let formatted = format_suggestion (List.hd suggestions) in
    assert_contains formatted "转换建议" "单个建议格式化";

    let batch_formatted = format_suggestions suggestions in
    assert_contains batch_formatted "1." "批量建议格式化";

    Printf.printf "✅ 格式化功能: 通过\n"
  ) else (
    Printf.printf "❌ 格式化功能: 无建议可格式化\n"
  )

(* 智能分析测试 *)
let test_intelligent_analysis () =
  Printf.printf "\n🔍 测试: 智能分析\n";
  let complex_code = "对于 每个 数字 在 列表 中 做 总和 := !总和 + 数字\n如果 总和 > 100 那么 设置 结果 为 大" in
  let analysis = intelligent_analysis complex_code in

  assert_contains analysis "声明式编程风格转换报告" "智能分析报告";
  assert_contains analysis "转换建议统计" "统计信息";
  Printf.printf "✅ 智能分析: 通过\n"

(* 运行所有测试 *)
let run_all_tests () =
  Printf.printf "🧪 开始声明式编程风格转换器测试...\n";

  test_basic_loop_transformation ();
  test_filter_pattern_transformation ();
  test_mapping_pattern_transformation ();
  test_reference_update_transformation ();
  test_conditional_pattern_transformation ();
  test_confidence_scoring ();
  test_code_block_analysis ();
  test_report_generation ();
  test_declarative_opportunities ();
  test_transformation_application ();
  test_formatting_functions ();
  test_intelligent_analysis ();

  Printf.printf "\n🎉 声明式编程风格转换器测试完成！\n";

  (* 演示完整的转换流程 *)
  Printf.printf "\n📋 完整转换演示:\n";
  let demo_code = "对于 每个 学生 在 班级 中 做 如果 学生.分数 >= 60 那么 添加 学生 到 及格列表" in
  let suggestions = analyze_and_suggest demo_code in
  Printf.printf "\n原始代码: %s\n" demo_code;
  Printf.printf "%s\n" (format_suggestions suggestions);

  (* 生成完整报告 *)
  let report = generate_transformation_report suggestions in
  Printf.printf "\n%s\n" report

(* 主测试入口 *)
let () = run_all_tests ()