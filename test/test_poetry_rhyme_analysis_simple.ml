(* 音韵分析模块测试 - 简化版本 *)

open Poetry.Rhyme_analysis

let test_basic () =
  let report = generate_rhyme_report "平安" in
  Alcotest.(check string) "报告测试" "平安" report.verse

let () =
  let open Alcotest in
  run "Poetry Rhyme Analysis Tests" [
    "basic", [test_case "basic test" `Quick test_basic];
  ]