(* 代码模式学习系统测试 *)

open Ai.Pattern_learning_system

let test_pattern_extraction () =
  Printf.printf "🧪 测试模式提取...\n";

  (* 测试递归函数模式 *)
  let recursive_expr = SRecursiveFunctionDef ("斐波那契", ["n"],
    SIfThenElse (
      SBinaryOp ("<=", SVariable "n", SLiteral "1"),
      SVariable "n",
      SBinaryOp ("+",
        SFunctionCall ("斐波那契", [SBinaryOp ("-", SVariable "n", SLiteral "1")]),
        SFunctionCall ("斐波那契", [SBinaryOp ("-", SVariable "n", SLiteral "2")]))
    )) in

  let pattern = extract_pattern recursive_expr in

  Printf.printf "   检测到的模式类型: %s\n" (match pattern.pattern_type with
    | RecursionPattern -> "递归模式"
    | FunctionPattern -> "函数模式"
    | ConditionalPattern -> "条件模式"
    | _ -> "其他模式");
  Printf.printf "   上下文标签: %s\n" (String.concat ", " pattern.context_tags);
  Printf.printf "   置信度: %.2f\n" pattern.confidence;

  assert (pattern.pattern_type = RecursionPattern || pattern.pattern_type = FunctionPattern);
  assert (pattern.confidence > 0.0);

  Printf.printf "✅ 递归函数模式提取成功\n";

  (* 测试条件表达式模式 *)
  let conditional_expr = SIfThenElse (
    SBinaryOp (">", SVariable "分数", SLiteral "60"),
    SLiteral "及格",
    SLiteral "不及格") in

  let cond_pattern = extract_pattern conditional_expr in

  assert (cond_pattern.pattern_type = ConditionalPattern);
  assert (List.mem "条件判断" cond_pattern.context_tags);

  Printf.printf "✅ 条件表达式模式提取成功\n"

let test_complexity_calculation () =
  Printf.printf "🧪 测试复杂度计算...\n";

  (* 简单表达式 *)
  let simple_expr = SBinaryOp ("+", SLiteral "1", SLiteral "2") in
  let simple_complexity = calculate_complexity simple_expr in

  assert (simple_complexity.cyclomatic_complexity >= 1);
  assert (simple_complexity.nesting_depth >= 0);

  Printf.printf "✅ 简单表达式复杂度: 圈复杂度=%d, 嵌套深度=%d\n"
    simple_complexity.cyclomatic_complexity simple_complexity.nesting_depth;

  (* 复杂表达式 *)
  let complex_expr = SIfThenElse (
    SBinaryOp ("&&",
      SBinaryOp (">", SVariable "x", SLiteral "0"),
      SBinaryOp ("<", SVariable "x", SLiteral "100")),
    SIfThenElse (
      SBinaryOp ("=", SBinaryOp ("%", SVariable "x", SLiteral "2"), SLiteral "0"),
      SLiteral "偶数",
      SLiteral "奇数"),
    SLiteral "超出范围") in

  let complex_complexity = calculate_complexity complex_expr in

  assert (complex_complexity.cyclomatic_complexity > simple_complexity.cyclomatic_complexity);
  assert (complex_complexity.nesting_depth > simple_complexity.nesting_depth);

  Printf.printf "✅ 复杂表达式复杂度: 圈复杂度=%d, 嵌套深度=%d\n"
    complex_complexity.cyclomatic_complexity complex_complexity.nesting_depth

let test_pattern_similarity () =
  Printf.printf "🧪 测试模式相似度计算...\n";

  let pattern1 = {
    pattern_id = "test1";
    pattern_type = FunctionPattern;
    structure = SFunctionDef (["x"], SVariable "x");
    frequency = 1;
    confidence = 0.8;
    examples = [];
    variations = [];
    context_tags = ["函数定义"; "简单"];
    semantic_meaning = "简单函数";
  } in

  let pattern2 = {
    pattern_id = "test2";
    pattern_type = FunctionPattern;
    structure = SFunctionDef (["y"], SVariable "y");
    frequency = 1;
    confidence = 0.9;
    examples = [];
    variations = [];
    context_tags = ["函数定义"; "基础"];
    semantic_meaning = "基础函数";
  } in

  let pattern3 = {
    pattern_id = "test3";
    pattern_type = ConditionalPattern;
    structure = SIfThenElse (SVariable "x", SLiteral "1", SLiteral "0");
    frequency = 1;
    confidence = 0.7;
    examples = [];
    variations = [];
    context_tags = ["条件判断"];
    semantic_meaning = "条件表达式";
  } in

  let sim1_2 = calculate_pattern_similarity pattern1 pattern2 in
  let sim1_3 = calculate_pattern_similarity pattern1 pattern3 in

  assert (sim1_2 > sim1_3);  (* 相同类型的模式应该更相似 *)

  Printf.printf "✅ 模式相似度计算正确: 同类型=%.2f, 不同类型=%.2f\n" sim1_2 sim1_3

let test_codebase_analysis () =
  Printf.printf "🧪 测试代码库分析...\n";

  let sample_codes = [
    "让 加法 = 函数 x y → x + y";
    "如果 条件 那么 结果1 否则 结果2";
    "匹配 值 与 | 模式1 → 结果1 | 模式2 → 结果2";
  ] in

  let patterns = analyze_codebase sample_codes in

  assert (List.length patterns = List.length sample_codes);
  assert (List.for_all (fun p -> p.confidence > 0.0) patterns);

  Printf.printf "✅ 代码库分析成功，发现 %d 个模式\n" (List.length patterns)

let test_pattern_suggestions () =
  Printf.printf "🧪 测试模式建议...\n";

  (* 先添加一些模式到存储中 *)
  let test_pattern = {
    pattern_id = "suggestion_test";
    pattern_type = FunctionPattern;
    structure = SFunctionDef (["x"], SVariable "x");
    frequency = 5;
    confidence = 0.9;
    examples = ["恒等函数"];
    variations = [];
    context_tags = ["函数定义"; "基础"];
    semantic_meaning = "基础函数模式";
  } in

  (* 手动添加到模式库进行测试 *)
  let original_patterns = pattern_store.patterns in
  pattern_store.patterns <- [test_pattern];

  let target_expr = SFunctionDef (["y"], SBinaryOp ("+", SVariable "y", SLiteral "1")) in
  let suggestions = get_pattern_suggestions target_expr in

  (* 恢复原始模式库 *)
  pattern_store.patterns <- original_patterns;

  Printf.printf "✅ 模式建议测试完成，获得 %d 个建议\n" (List.length suggestions)

let test_learning_from_program () =
  Printf.printf "🧪 测试从程序学习...\n";

  let test_expressions = [
    SFunctionDef (["x"], SVariable "x");
    SLiteral "42";
  ] in

  let original_count = List.length pattern_store.patterns in
  learn_from_code test_expressions;
  let new_count = List.length pattern_store.patterns in

  assert (new_count > original_count);

  Printf.printf "✅ 程序学习成功，模式数量从 %d 增加到 %d\n" original_count new_count

let test_learning_stats () =
  Printf.printf "🧪 测试学习统计...\n";

  let stats = export_learning_data () in

  assert (stats.total_patterns >= 0);
  assert (stats.pattern_confidence_avg >= 0.0 && stats.pattern_confidence_avg <= 1.0);
  assert (stats.learning_accuracy >= 0.0 && stats.learning_accuracy <= 1.0);

  let formatted = format_learning_stats stats in
  assert (String.length formatted > 0);

  Printf.printf "✅ 学习统计测试通过\n";
  Printf.printf "%s\n" formatted

let run_all_tests () =
  Printf.printf "\n🎯 开始代码模式学习系统全面测试\n";
  Printf.printf "═══════════════════════════════════════════\n";

  try
    test_pattern_extraction ();
    test_complexity_calculation ();
    test_pattern_similarity ();
    test_codebase_analysis ();
    test_pattern_suggestions ();
    test_learning_from_program ();
    test_learning_stats ();

    Printf.printf "\n🎉 所有测试通过！代码模式学习系统功能正常\n";
    Printf.printf "═══════════════════════════════════════════\n";

    (* 运行完整的系统测试 *)
    test_pattern_learning_system ();

  with
  | e ->
      Printf.printf "\n❌ 测试失败: %s\n" (Printexc.to_string e);
      exit 1

let () = run_all_tests ()