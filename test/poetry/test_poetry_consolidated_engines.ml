(** 诗词统一引擎测试模块 *)
open Alcotest
open Poetry_types.Poetry_types_consolidated

(** 测试基础类型正确性 *)
let test_basic_types () =
  let dimensions = [RhymeHarmony; TonalBalance; Parallelism] in
  check int "基础艺术维度数量" 3 (List.length dimensions)

(** 测试诗词形式分类 *)
let test_poetry_classification () =
  let classical_forms = [QiYanJueJu; WuYanLuShi; SiYanPianTi] in
  let modern_forms = [ModernPoetry] in
  check int "古典诗词形式数量" 3 (List.length classical_forms);
  check int "现代诗词形式数量" 1 (List.length modern_forms)

(** 测试评估等级体系 *)
let test_grading_system () =
  let all_grades = [Excellent; Good; Average; Fair; Poor] in
  check int "评估等级总数" 5 (List.length all_grades)

let test_suite =
  [
    ("test_basic_types", `Quick, test_basic_types);
    ("test_poetry_classification", `Quick, test_poetry_classification);
    ("test_grading_system", `Quick, test_grading_system);
  ]

let () = run "诗词统一引擎测试" [ ("Poetry Consolidated Engines", test_suite) ]