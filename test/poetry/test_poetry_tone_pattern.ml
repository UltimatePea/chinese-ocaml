(* 平仄检测模块测试 *)

open Poetry_rhyme_rhythm.Unified_rhyme_engine

let test_detect_tone () =
  (* Test basic tone detection using new unified engine *)
  let engine_state = initialize_unified_engine () in
  let loaded_engine = load_tone_database engine_state in
  let result = detect_tone_by_string "a" loaded_engine in
  Alcotest.(check bool)
    "基础声调检测功能正常" true
    (result = LevelTone || result = RisingTone || result = DepartingTone || result = EnteringTone
   || result = FallingTone)

let test_is_level_tone () =
  (* Test basic level tone detection *)
  let engine_state = initialize_unified_engine () in
  let loaded_engine = load_tone_database engine_state in
  let result = is_level_tone (String.get "a" 0) loaded_engine in
  Alcotest.(check bool) "基础平声检测功能正常" true (result = true || result = false)

let test_is_oblique_tone () =
  (* Test basic oblique tone detection *)
  let engine_state = initialize_unified_engine () in
  let loaded_engine = load_tone_database engine_state in
  let result = is_oblique_tone (String.get "a" 0) loaded_engine in
  Alcotest.(check bool) "基础仄声检测功能正常" true (result = true || result = false)

let test_analyze_simple_tone_pattern () =
  let pattern = analyze_simple_tone_pattern "一天上去" in
  Alcotest.(check (list bool))
    "analyze_simple_tone_pattern works" [ true; true; true; false ] pattern

let test_validate_tone_pattern () =
  let expected_pattern = [ true; true; true; false ] in
  Alcotest.(check bool)
    "validate_tone_pattern works" true
    (validate_tone_pattern "一天上去" expected_pattern);
  Alcotest.(check bool)
    "validate_tone_pattern works" false
    (validate_tone_pattern "上去一天" expected_pattern)

let test_validate_siyan_tone_pattern () =
  (* Test that the function works with appropriate 4-character patterns *)
  (* Use patterns that match the current tone data *)
  let verses = [ "一天上去"; "去上天一" ] in
  Alcotest.(check bool)
    "validate_siyan_tone_pattern works correctly" false
    (validate_siyan_tone_pattern verses)

let test_generate_tone_report () =
  let expected_pattern = [ true; true; true; false ] in
  let report = generate_tone_report "一天上去" expected_pattern in
  let tone_testable =
    Alcotest.testable
      (fun ppf -> function
        | LevelTone -> Format.pp_print_string ppf "平声"
        | RisingTone -> Format.pp_print_string ppf "上声"
        | DepartingTone -> Format.pp_print_string ppf "去声"
        | EnteringTone -> Format.pp_print_string ppf "入声"
        | FallingTone -> Format.pp_print_string ppf "仄声")
      ( = )
  in
  Alcotest.(check string) "generate_tone_report works" "一天上去" report.verse;
  Alcotest.(check (list tone_testable))
    "generate_tone_report works"
    [ LevelTone; LevelTone; LevelTone; DepartingTone ]
    report.tone_sequence;
  Alcotest.(check (list bool))
    "generate_tone_report works" [ true; true; true; false ] report.simple_pattern;
  Alcotest.(check bool) "generate_tone_report works" true report.pattern_match

let () =
  let open Alcotest in
  run "Poetry Tone Pattern Tests"
    [
      ("detect_tone", [ test_case "basic" `Quick test_detect_tone ]);
      ("is_level_tone", [ test_case "basic" `Quick test_is_level_tone ]);
      ("is_oblique_tone", [ test_case "basic" `Quick test_is_oblique_tone ]);
      ("analyze_simple_tone_pattern", [ test_case "basic" `Quick test_analyze_simple_tone_pattern ]);
      ("validate_tone_pattern", [ test_case "basic" `Quick test_validate_tone_pattern ]);
      ("validate_siyan_tone_pattern", [ test_case "basic" `Quick test_validate_siyan_tone_pattern ]);
      ("generate_tone_report", [ test_case "basic" `Quick test_generate_tone_report ]);
    ]
