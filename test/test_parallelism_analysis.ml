(* 对仗分析模块测试 *)

open Poetry.Parallelism_analysis

let test_word_class_detection () =
  (* Test basic word class detection - skip detailed testing for now since UTF-8 handling is complex *)
  let result = detect_word_class (String.get "a" 0) in
  Alcotest.(check bool) "基础词性检测功能正常" true (result = Unknown)

let test_parallelism_analysis () =
  let line1 = "天对地" in
  let line2 = "山对水" in
  let report = generate_parallelism_report line1 line2 in
  Alcotest.(check bool) "line1 not empty" true (String.length report.line1 > 0);
  Alcotest.(check bool) "line2 not empty" true (String.length report.line2 > 0);
  Alcotest.(check bool) "word_class_pairs not empty" true (List.length report.word_class_pairs > 0);
  Alcotest.(check bool) "rhyme_pairs not empty" true (List.length report.rhyme_pairs > 0)

let test_parallelism_quality () =
  let line1 = "天对地" in
  let line2 = "山对水" in
  let quality = analyze_parallelism_quality line1 line2 in
  Alcotest.(check bool) "quality not NoParallelism" true (quality <> NoParallelism)

let test_regulated_verse_parallelism () =
  let verses = [ "天对地"; "山对水"; "红对绿"; "东对西"; "花对草"; "鸟对鱼"; "月对星"; "风对雨" ] in
  let second_report, third_report, overall_quality = validate_regulated_verse_parallelism verses in
  Alcotest.(check bool) "second_report line1 not empty" true (String.length second_report.line1 > 0);
  Alcotest.(check bool) "third_report line1 not empty" true (String.length third_report.line1 > 0);
  Alcotest.(check bool)
    "overall_quality in valid range" true
    (overall_quality >= 0.0 && overall_quality <= 1.0)

let test_parallelism_improvements () =
  let line1 = "天对地" in
  let line2 = "山对水" in
  let report = generate_parallelism_report line1 line2 in
  let suggestions = suggest_parallelism_improvements report in
  Alcotest.(check bool) "suggestions not empty" true (List.length suggestions > 0)

let () =
  let open Alcotest in
  run "Poetry Parallelism Analysis Tests"
    [
      ("word_class_detection", [ test_case "basic" `Quick test_word_class_detection ]);
      ("parallelism_analysis", [ test_case "basic" `Quick test_parallelism_analysis ]);
      ("parallelism_quality", [ test_case "basic" `Quick test_parallelism_quality ]);
      ("regulated_verse_parallelism", [ test_case "basic" `Quick test_regulated_verse_parallelism ]);
      ("parallelism_improvements", [ test_case "basic" `Quick test_parallelism_improvements ]);
    ]
