(* 诗词艺术性评价模块测试 *)

open Alcotest
open Poetry_types.Poetry_types_consolidated

let test_artistic_dimension_types () =
  let dimensions = [RhymeHarmony; TonalBalance; Parallelism; Imagery] in
  check int "艺术维度列表长度" 4 (List.length dimensions)

let test_evaluation_grade_types () =
  let grades = [Excellent; Good; Average; Fair; Poor] in
  check int "评估等级列表长度" 5 (List.length grades)

let test_poetry_form_types () =
  let forms = [QiYanJueJu; WuYanLuShi; SiYanPianTi] in
  check int "诗词形式列表长度" 3 (List.length forms)

let () =
  let open Alcotest in
  run "Artistic Evaluation Tests"
    [
      ("artistic_dimension_types", [ test_case "basic" `Quick test_artistic_dimension_types ]);
      ("evaluation_grade_types", [ test_case "basic" `Quick test_evaluation_grade_types ]);
      ("poetry_form_types", [ test_case "basic" `Quick test_poetry_form_types ]);
    ]