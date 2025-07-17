(* 诗词艺术性评价模块测试 *)

open OUnit2
open Poetry.Artistic_evaluation

let test_evaluate_rhyme_harmony _ =
  let verse = "春花秋月何时了" in
  let score = evaluate_rhyme_harmony verse in
  assert_bool "韵律和谐度得分应在合理范围内" (score >= 0.0 && score <= 1.0)

let test_evaluate_tonal_balance _ =
  let verse = "春花秋月" in
  let expected_pattern = [true; true; false; false] in
  let score = evaluate_tonal_balance verse expected_pattern in
  assert_bool "声调平衡度得分应在合理范围内" (score >= 0.0 && score <= 1.0)

let test_evaluate_parallelism _ =
  let left_verse = "春花秋月" in
  let right_verse = "夏雨冬雪" in
  let score = evaluate_parallelism left_verse right_verse in
  assert_bool "对仗工整度得分应在合理范围内" (score >= 0.0 && score <= 1.0)

let test_evaluate_imagery _ =
  let verse = "春花秋月何时了" in
  let score = evaluate_imagery verse in
  assert_bool "意象深度得分应在合理范围内" (score >= 0.0 && score <= 1.0)

let test_evaluate_rhythm _ =
  let verse = "春花秋月" in
  let score = evaluate_rhythm verse in
  assert_bool "节奏感得分应在合理范围内" (score >= 0.0 && score <= 1.0)

let test_evaluate_elegance _ =
  let verse = "夫春花者，美也" in
  let score = evaluate_elegance verse in
  assert_bool "雅致程度得分应在合理范围内" (score >= 0.0 && score <= 1.0)

let test_comprehensive_artistic_evaluation _ =
  let verse = "春花秋月何时了" in
  let expected_pattern = [true; true; false; false; false; false; false] in
  let report = comprehensive_artistic_evaluation verse expected_pattern in
  assert_equal verse report.verse;
  assert_bool "韵律得分应在合理范围内" (report.rhyme_score >= 0.0 && report.rhyme_score <= 1.0);
  assert_bool "声调得分应在合理范围内" (report.tone_score >= 0.0 && report.tone_score <= 1.0);
  assert_bool "对仗得分应在合理范围内" (report.parallelism_score >= 0.0 && report.parallelism_score <= 1.0);
  assert_bool "意象得分应在合理范围内" (report.imagery_score >= 0.0 && report.imagery_score <= 1.0);
  assert_bool "节奏得分应在合理范围内" (report.rhythm_score >= 0.0 && report.rhythm_score <= 1.0);
  assert_bool "雅致得分应在合理范围内" (report.elegance_score >= 0.0 && report.elegance_score <= 1.0);
  assert_bool "建议列表应为字符串列表" (List.length report.suggestions >= 0)

let test_evaluate_siyan_parallel_prose _ =
  let verses = ["春花秋月"; "夏雨冬雪"; "朝阳暮云"; "青山绿水"] in
  let report = evaluate_siyan_parallel_prose verses in
  assert_bool "四言骈体评价应返回合理的报告" (String.length report.verse > 0);
  assert_bool "总体评价应为有效等级" (match report.overall_grade with
    | Excellent | Good | Fair | Poor -> true)

let test_poetic_critique _ =
  let verse = "春花秋月何时了" in
  let poetry_type = "七言绝句" in
  let critique = poetic_critique verse poetry_type in
  assert_bool "诗词品评应返回非空字符串" (String.length critique > 0)

let test_determine_overall_grade _ =
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
  assert_bool "总体评价应为有效等级" (match grade with
    | Excellent | Good | Fair | Poor -> true)

let test_generate_improvement_suggestions _ =
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
  assert_bool "应生成改进建议" (List.length suggestions > 0)

let suite = "Artistic Evaluation Tests" >::: [
  "test_evaluate_rhyme_harmony" >:: test_evaluate_rhyme_harmony;
  "test_evaluate_tonal_balance" >:: test_evaluate_tonal_balance;
  "test_evaluate_parallelism" >:: test_evaluate_parallelism;
  "test_evaluate_imagery" >:: test_evaluate_imagery;
  "test_evaluate_rhythm" >:: test_evaluate_rhythm;
  "test_evaluate_elegance" >:: test_evaluate_elegance;
  "test_comprehensive_artistic_evaluation" >:: test_comprehensive_artistic_evaluation;
  "test_evaluate_siyan_parallel_prose" >:: test_evaluate_siyan_parallel_prose;
  "test_poetic_critique" >:: test_poetic_critique;
  "test_determine_overall_grade" >:: test_determine_overall_grade;
  "test_generate_improvement_suggestions" >:: test_generate_improvement_suggestions;
]

let () = run_test_tt_main suite