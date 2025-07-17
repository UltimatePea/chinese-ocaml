(* 音韵分析模块测试 *)

open OUnit2
open Poetry.Rhyme_analysis

let test_detect_rhyme_category _ =
  assert_equal PingSheng (detect_rhyme_category "安");
  assert_equal PingSheng (detect_rhyme_category "天");
  assert_equal ZeSheng (detect_rhyme_category "上");
  assert_equal ZeSheng (detect_rhyme_category "去");
  assert_equal RuSheng (detect_rhyme_category "入")

let test_detect_rhyme_group _ =
  assert_equal AnRhyme (detect_rhyme_group "安");
  assert_equal AnRhyme (detect_rhyme_group "山");
  assert_equal TianRhyme (detect_rhyme_group "天");
  assert_equal TianRhyme (detect_rhyme_group "年");
  assert_equal QuRhyme (detect_rhyme_group "去");
  assert_equal QuRhyme (detect_rhyme_group "路")

let test_extract_rhyme_ending _ =
  assert_equal (Some "安") (extract_rhyme_ending "平安");
  assert_equal (Some "天") (extract_rhyme_ending "春天");
  assert_equal None (extract_rhyme_ending "")

let test_validate_rhyme_consistency _ =
  assert_equal true (validate_rhyme_consistency ["平安"; "泰山"]);  (* 同为安韵 *)
  assert_equal true (validate_rhyme_consistency ["春天"; "今年"]);  (* 同为天韵 *)
  assert_equal false (validate_rhyme_consistency ["平安"; "春天"]) (* 不同韵组 *)

let test_chars_rhyme _ =
  assert_equal true (chars_rhyme "安" "山");   (* 同为安韵 *)
  assert_equal true (chars_rhyme "天" "年");   (* 同为天韵 *)
  assert_equal false (chars_rhyme "安" "天");  (* 不同韵组 *)

let test_generate_rhyme_report _ =
  let report = generate_rhyme_report "平安" in
  assert_equal "平安" report.verse;
  assert_equal (Some "安") report.rhyme_ending;
  assert_equal AnRhyme report.rhyme_group;
  assert_equal PingSheng report.rhyme_category

let suite = "Poetry Rhyme Analysis Tests" >::: [
  "test_detect_rhyme_category" >:: test_detect_rhyme_category;
  "test_detect_rhyme_group" >:: test_detect_rhyme_group;
  "test_extract_rhyme_ending" >:: test_extract_rhyme_ending;
  "test_validate_rhyme_consistency" >:: test_validate_rhyme_consistency;
  "test_chars_rhyme" >:: test_chars_rhyme;
  "test_generate_rhyme_report" >:: test_generate_rhyme_report;
]

let () = run_test_tt_main suite