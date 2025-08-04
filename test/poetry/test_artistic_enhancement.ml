open Alcotest
open Poetry_types.Poetry_types_consolidated

let test_poetry_forms () =
  let forms = [ QiYanJueJu; WuYanLuShi; SiYanPianTi; ModernPoetry ] in
  check int "诗词形式数量" 4 (List.length forms)

let test_artistic_dimensions () =
  let dimensions = [ RhymeHarmony; TonalBalance; Parallelism; Imagery ] in
  check int "艺术维度数量" 4 (List.length dimensions)

let test_evaluation_grades () =
  let grades = [ Excellent; Good; Average; Fair; Poor ] in
  check int "评估等级数量" 5 (List.length grades)

let suite =
  [
    ( "诗词艺术性评价测试",
      [
        ("test_poetry_forms", `Quick, test_poetry_forms);
        ("test_artistic_dimensions", `Quick, test_artistic_dimensions);
        ("test_evaluation_grades", `Quick, test_evaluation_grades);
      ] );
  ]

let () = run "诗词艺术性评价测试" suite