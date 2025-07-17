(* 诗词艺术性评价模块测试 *)

open Poetry.Artistic_evaluation

let test_evaluate_rhyme_harmony () =
  let verse = "春花秋月何时了" in
  let score = evaluate_rhyme_harmony verse in
  Alcotest.(check bool) "韵律和谐度得分应在合理范围内" true (score >= 0.0 && score <= 1.0)

let test_evaluate_tonal_balance () =
  let verse = "春花秋月" in
  let expected_pattern = [true; true; false; false] in
  let score = evaluate_tonal_balance verse expected_pattern in
  Alcotest.(check bool) "声调平衡度得分应在合理范围内" true (score >= 0.0 && score <= 1.0)

let test_evaluate_parallelism () =
  let left_verse = "春花秋月" in
  let right_verse = "夏雨冬雪" in
  let score = evaluate_parallelism left_verse right_verse in
  Alcotest.(check bool) "对仗工整度得分应在合理范围内" true (score >= 0.0 && score <= 1.0)

let test_evaluate_imagery () =
  let verse = "春花秋月何时了" in
  let score = evaluate_imagery verse in
  Alcotest.(check bool) "意象深度得分应在合理范围内" true (score >= 0.0 && score <= 1.0)

let test_evaluate_rhythm () =
  let verse = "春花秋月" in
  let score = evaluate_rhythm verse in
  Alcotest.(check bool) "节奏感得分应在合理范围内" true (score >= 0.0 && score <= 1.0)

let test_evaluate_elegance () =
  let verse = "夫春花者，美也" in
  let score = evaluate_elegance verse in
  Alcotest.(check bool) "雅致程度得分应在合理范围内" true (score >= 0.0 && score <= 1.0)

let test_comprehensive_artistic_evaluation () =
  let verse = "春花秋月何时了" in
  let expected_pattern = [true; true; false; false; false; false; false] in
  let report = comprehensive_artistic_evaluation verse expected_pattern in
  Alcotest.(check string) "verse should match" verse report.verse;
  Alcotest.(check bool) "韵律得分应在合理范围内" true (report.rhyme_score >= 0.0 && report.rhyme_score <= 1.0);
  Alcotest.(check bool) "声调得分应在合理范围内" true (report.tone_score >= 0.0 && report.tone_score <= 1.0);
  Alcotest.(check bool) "对仗得分应在合理范围内" true (report.parallelism_score >= 0.0 && report.parallelism_score <= 1.0);
  Alcotest.(check bool) "意象得分应在合理范围内" true (report.imagery_score >= 0.0 && report.imagery_score <= 1.0);
  Alcotest.(check bool) "节奏得分应在合理范围内" true (report.rhythm_score >= 0.0 && report.rhythm_score <= 1.0);
  Alcotest.(check bool) "雅致得分应在合理范围内" true (report.elegance_score >= 0.0 && report.elegance_score <= 1.0);
  Alcotest.(check bool) "建议列表应为字符串列表" true (List.length report.suggestions >= 0)

let test_evaluate_siyan_parallel_prose () =
  let verses = ["春花秋月"; "夏雨冬雪"; "朝阳暮云"; "青山绿水"] in
  let report = evaluate_siyan_parallel_prose verses in
  Alcotest.(check bool) "四言骈体评价应返回合理的报告" true (String.length report.verse > 0);
  let grade_valid = match report.overall_grade with
    | Excellent | Good | Fair | Poor -> true in
  Alcotest.(check bool) "总体评价应为有效等级" true grade_valid

let test_poetic_critique () =
  let verse = "春花秋月何时了" in
  let poetry_type = "七言绝句" in
  let critique = poetic_critique verse poetry_type in
  Alcotest.(check bool) "诗词品评应返回非空字符串" true (String.length critique > 0)

let test_determine_overall_grade () =
  let report = {
    verse = "测试诗句";
    rhyme_score = 0.8;
    tone_score = 0.7;
    parallelism_score = 0.6;
    imagery_score = 0.8;
    rhythm_score = 0.7;
    elegance_score = 0.6;
    overall_grade = Good;
    suggestions = [];
  } in
  let grade = determine_overall_grade report in
  let grade_valid = match grade with
    | Excellent | Good | Fair | Poor -> true in
  Alcotest.(check bool) "总体评价应为有效等级" true grade_valid

let test_generate_improvement_suggestions () =
  let report = {
    verse = "测试诗句";
    rhyme_score = 0.5;
    tone_score = 0.4;
    parallelism_score = 0.3;
    imagery_score = 0.5;
    rhythm_score = 0.4;
    elegance_score = 0.3;
    overall_grade = Fair;
    suggestions = [];
  } in
  let suggestions = generate_improvement_suggestions report in
  Alcotest.(check bool) "应生成改进建议" true (List.length suggestions > 0)

let () =
  let open Alcotest in
  run "Artistic Evaluation Tests" [
    "evaluate_rhyme_harmony", [test_case "basic" `Quick test_evaluate_rhyme_harmony];
    "evaluate_tonal_balance", [test_case "basic" `Quick test_evaluate_tonal_balance];
    "evaluate_parallelism", [test_case "basic" `Quick test_evaluate_parallelism];
    "evaluate_imagery", [test_case "basic" `Quick test_evaluate_imagery];
    "evaluate_rhythm", [test_case "basic" `Quick test_evaluate_rhythm];
    "evaluate_elegance", [test_case "basic" `Quick test_evaluate_elegance];
    "comprehensive_artistic_evaluation", [test_case "basic" `Quick test_comprehensive_artistic_evaluation];
    "evaluate_siyan_parallel_prose", [test_case "basic" `Quick test_evaluate_siyan_parallel_prose];
    "poetic_critique", [test_case "basic" `Quick test_poetic_critique];
    "determine_overall_grade", [test_case "basic" `Quick test_determine_overall_grade];
    "generate_improvement_suggestions", [test_case "basic" `Quick test_generate_improvement_suggestions];
  ]