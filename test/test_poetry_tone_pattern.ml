(* 平仄检测模块测试 *)

open OUnit2
open Poetry.Tone_pattern

let test_detect_tone _ =
  assert_equal LevelTone (detect_tone "一");
  assert_equal LevelTone (detect_tone "天");
  assert_equal RisingTone (detect_tone "上");
  assert_equal DepartingTone (detect_tone "去");
  assert_equal EnteringTone (detect_tone "入")

let test_is_level_tone _ =
  assert_equal true (is_level_tone "一");
  assert_equal true (is_level_tone "天");
  assert_equal false (is_level_tone "上");
  assert_equal false (is_level_tone "去")

let test_is_oblique_tone _ =
  assert_equal false (is_oblique_tone "一");
  assert_equal false (is_oblique_tone "天");
  assert_equal true (is_oblique_tone "上");
  assert_equal true (is_oblique_tone "去")

let test_analyze_simple_tone_pattern _ =
  let pattern = analyze_simple_tone_pattern "一天上去" in
  assert_equal [true; true; false; false] pattern

let test_validate_tone_pattern _ =
  let expected_pattern = [true; true; false; false] in
  assert_equal true (validate_tone_pattern "一天上去" expected_pattern);
  assert_equal false (validate_tone_pattern "上去一天" expected_pattern)

let test_validate_siyan_tone_pattern _ =
  let verses = ["一天上去"; "上去一天"] in
  assert_equal true (validate_siyan_tone_pattern verses)

let test_generate_tone_report _ =
  let expected_pattern = [true; true; false; false] in
  let report = generate_tone_report "一天上去" expected_pattern in
  assert_equal "一天上去" report.verse;
  assert_equal [LevelTone; LevelTone; RisingTone; DepartingTone] report.tone_sequence;
  assert_equal [true; true; false; false] report.simple_pattern;
  assert_equal true report.pattern_match

let suite = "Poetry Tone Pattern Tests" >::: [
  "test_detect_tone" >:: test_detect_tone;
  "test_is_level_tone" >:: test_is_level_tone;
  "test_is_oblique_tone" >:: test_is_oblique_tone;
  "test_analyze_simple_tone_pattern" >:: test_analyze_simple_tone_pattern;
  "test_validate_tone_pattern" >:: test_validate_tone_pattern;
  "test_validate_siyan_tone_pattern" >:: test_validate_siyan_tone_pattern;
  "test_generate_tone_report" >:: test_generate_tone_report;
]

let () = run_test_tt_main suite