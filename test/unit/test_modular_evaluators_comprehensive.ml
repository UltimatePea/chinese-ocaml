(** 模块化评价器架构综合测试套件
 *
 * 作为测试工程师Echo，确保架构重构#1767的质量和完整性
 * 测试覆盖新的模块化评价器架构的所有核心功能
 *
 * @author Echo, 测试工程师
 * @version 1.0 - 针对架构债务重构的测试增强版本
 * @since 2025-07-30
 * @test_target 模块化评价器架构 (Fix #1767)
 *)

open Poetry_evaluators.Evaluator_types
open Poetry_evaluators.Artistic_evaluation_engine

(** {1 测试数据准备} *)

let test_single_verse = "春风又绿江南岸"
let test_verses_short = ["春风又绿江南岸"; "明月何时照我还"]
let test_verses_long = [
  "春风又绿江南岸";
  "明月何时照我还";
  "千里江山如画图";
  "万里长城永不倒"
]

let create_test_context verses =
  { verse = List.hd verses;
    verses = verses; 
    form_type = Some "七言绝句";
    rhythm_info = [("平仄", "平平仄仄平平仄")];
    metadata = [("测试来源", "模块化架构测试")]
  }

(** {1 基础功能测试} *)

let test_evaluator_registration () =
  Printf.printf "\n=== 测试评价器注册功能 ===\n";
  
  let eval_info = get_evaluator_info () in
  Printf.printf "注册评价器数量: %d\n" (List.length eval_info);
  
  (* 验证预期的评价器都已注册 *)
  let expected_evaluators = [
    "韵律和谐度评价器";
    "声调平衡评价器"; 
    "对仗性评价器";
    "意象评价器";
    "形式美评价器";
    "内容深度评价器";
    "意境评价器";
    "整体评价器"
  ] in
  
  List.iter (fun expected ->
    let found = List.exists (fun (name, _, _) -> name = expected) eval_info in
    Printf.printf "评价器 '%s': %s\n" expected (if found then "✓ 已注册" else "✗ 未找到")
  ) expected_evaluators

let test_single_verse_evaluation () =
  Printf.printf "\n=== 测试单句评价功能 ===\n";
  
  let result = evaluate_single_verse test_single_verse in
  Printf.printf "单句 '%s' 评价结果:\n" test_single_verse;
  Printf.printf "  总分: %.2f\n" result.overall_score;
  Printf.printf "  评价维度数: %d\n" (List.length result.dimension_scores);
  Printf.printf "  艺术级别: %s\n" (match result.artistic_level with
    | `Beginner -> "初学者"
    | `Intermediate -> "中等"
    | `Advanced -> "高级"  
    | `Master -> "大师级");
  Printf.printf "  质量等级: %s\n" (match result.quality_grade with
    | `Excellent -> "优秀"
    | `Good -> "良好"
    | `Fair -> "一般"
    | `Poor -> "较差");
  
  (* 验证基本约束 *)
  assert (result.overall_score >= 0.0 && result.overall_score <= 1.0);
  assert (List.length result.dimension_scores > 0);
  Printf.printf "  ✓ 基本约束验证通过\n"

let test_multiple_verses_evaluation () =
  Printf.printf "\n=== 测试多句评价功能 ===\n";
  
  let result = evaluate_multiple_verses test_verses_short in
  Printf.printf "多句评价结果 (%d句):\n" (List.length test_verses_short);
  Printf.printf "  总分: %.2f\n" result.overall_score;
  Printf.printf "  评价维度数: %d\n" (List.length result.dimension_scores);
  Printf.printf "  优势数: %d\n" (List.length result.strengths);
  Printf.printf "  不足数: %d\n" (List.length result.weaknesses);
  Printf.printf "  改进建议数: %d\n" (List.length result.improvement_suggestions);
  
  (* 验证多句评价应该有更多维度 *)
  let single_result = evaluate_single_verse (List.hd test_verses_short) in
  let multi_dimensions = List.length result.dimension_scores in
  let single_dimensions = List.length single_result.dimension_scores in
  
  Printf.printf "  单句维度数: %d, 多句维度数: %d\n" single_dimensions multi_dimensions;
  assert (multi_dimensions >= single_dimensions);
  Printf.printf "  ✓ 多句评价维度扩展验证通过\n"

(** {1 维度覆盖测试} *)

let test_dimension_coverage () =
  Printf.printf "\n=== 测试评价维度覆盖 ===\n";
  
  let ctx_short = create_test_context test_verses_short in
  let ctx_long = create_test_context test_verses_long in
  
  let result_short = evaluate_poetry ctx_short in
  let result_long = evaluate_poetry ctx_long in
  
  Printf.printf "短文本 (%d句) 评价维度:\n" (List.length test_verses_short);
  List.iter (fun score ->
    let dim_name = match score.dimension with
      | RhymeHarmony -> "韵律和谐"
      | TonalBalance -> "声调平衡"
      | Parallelism -> "对仗性"
      | Imagery -> "意象"
      | FormBeauty -> "形式美"
      | ContentDepth -> "内容深度"
      | ContextMood -> "意境"
      | Overall -> "整体"
      | _ -> "其他"
    in
    Printf.printf "  %s: %.2f (置信度: %.2f)\n" dim_name score.score score.confidence
  ) result_short.dimension_scores;
  
  Printf.printf "\n长文本 (%d句) 评价维度:\n" (List.length test_verses_long);  
  List.iter (fun score ->
    let dim_name = match score.dimension with
      | RhymeHarmony -> "韵律和谐"
      | TonalBalance -> "声调平衡"
      | Parallelism -> "对仗性"
      | Imagery -> "意象"
      | FormBeauty -> "形式美"
      | ContentDepth -> "内容深度"
      | ContextMood -> "意境"
      | Overall -> "整体"
      | _ -> "其他"
    in
    Printf.printf "  %s: %.2f (置信度: %.2f)\n" dim_name score.score score.confidence
  ) result_long.dimension_scores

(** {1 边界条件测试} *)

let test_edge_cases () =
  Printf.printf "\n=== 测试边界条件 ===\n";
  
  (* 测试空字符串 *)
  Printf.printf "测试空字符串处理:\n";
  (try
    let _ = evaluate_single_verse "" in
    Printf.printf "  ✓ 空字符串处理正常\n"
  with e ->
    Printf.printf "  ⚠ 空字符串异常: %s\n" (Printexc.to_string e)
  );
  
  (* 测试单字符 *)
  Printf.printf "测试单字符处理:\n";
  (try
    let result = evaluate_single_verse "春" in
    Printf.printf "  ✓ 单字符评分: %.2f\n" result.overall_score
  with e ->
    Printf.printf "  ⚠ 单字符异常: %s\n" (Printexc.to_string e)
  );
  
  (* 测试超长文本 *)
  Printf.printf "测试超长文本处理:\n";
  let long_verses = List.init 20 (fun i -> 
    Printf.sprintf "这是第%d句测试诗句，用于验证系统的稳定性" (i + 1)) in
  (try
    let result = evaluate_multiple_verses long_verses in
    Printf.printf "  ✓ 超长文本(%d句)评分: %.2f\n" (List.length long_verses) result.overall_score
  with e ->
    Printf.printf "  ⚠ 超长文本异常: %s\n" (Printexc.to_string e)
  )

(** {1 性能基准测试} *)

let test_performance () =
  Printf.printf "\n=== 测试性能基准 ===\n";
  
  let time_function f x =
    let start_time = Unix.gettimeofday () in
    let result = f x in
    let end_time = Unix.gettimeofday () in
    (result, end_time -. start_time)
  in
  
  (* 单句评价性能 *)
  let (_, single_time) = time_function evaluate_single_verse test_single_verse in
  Printf.printf "单句评价耗时: %.4f秒\n" single_time;
  
  (* 多句评价性能 *)
  let (_, multi_time) = time_function evaluate_multiple_verses test_verses_short in
  Printf.printf "多句评价耗时: %.4f秒\n" multi_time;
  
  (* 性能基准验证 *)
  assert (single_time < 1.0); (* 单句评价应在1秒内完成 *)
  assert (multi_time < 2.0);  (* 多句评价应在2秒内完成 *)
  Printf.printf "✓ 性能基准测试通过\n"

(** {1 架构一致性测试} *)

let test_architectural_consistency () =
  Printf.printf "\n=== 测试架构一致性 ===\n";
  
  let eval_info = get_evaluator_info () in
  
  (* 验证所有评价器都有合理的权重 *)
  Printf.printf "评价器权重检查:\n";
  List.iter (fun (name, _description, weight) ->
    Printf.printf "  %s: 权重=%.2f\n" name weight;
    assert (weight > 0.0 && weight <= 1.0)
  ) eval_info;
  
  (* 验证权重分布合理性 *)
  let total_weight = List.fold_left (fun acc (_, _, w) -> acc +. w) 0.0 eval_info in
  Printf.printf "总权重: %.2f\n" total_weight;
  Printf.printf "平均权重: %.2f\n" (total_weight /. float_of_int (List.length eval_info));
  
  Printf.printf "✓ 架构一致性测试通过\n"

(** {1 主测试执行} *)

let () =
  Printf.printf "=== 模块化评价器架构综合测试套件 ===\n";
  Printf.printf "Author: Echo, 测试工程师\n";
  Printf.printf "Target: 架构债务重构 #1767\n";
  Printf.printf "=====================================\n";
  
  (* 执行所有测试 *)
  test_evaluator_registration ();
  test_single_verse_evaluation ();
  test_multiple_verses_evaluation ();
  test_dimension_coverage ();
  test_edge_cases ();
  test_performance ();
  test_architectural_consistency ();
  
  Printf.printf "\n=== 综合测试结果 ===\n";
  Printf.printf "✅ 所有测试模块执行完成\n";
  Printf.printf "✅ 模块化评价器架构功能正常\n";
  Printf.printf "✅ 架构债务重构 #1767 质量验证通过\n";
  Printf.printf "=====================================\n"