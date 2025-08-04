(** 诗词艺术引擎测试模块 *)
open Alcotest
open Yyocamlc_lib.Poetry_core.Types

(** 测试艺术性维度类型 *)
let test_artistic_dimensions () =
  (* 测试艺术性维度枚举 *)
  let dimensions =
    [
      RhymeHarmony;
      TonalBalance;
      Parallelism;
      Imagery;
      Rhythm;
    ]
  in
  check int "艺术性维度数量" 5 (List.length dimensions)

(** 测试评估等级类型 *)
let test_evaluation_grades () =
  let grades = [Excellent; Good; Fair; Poor] in
  check int "评估等级数量" 4 (List.length grades)

(** 测试诗词形式类型 *)  
let test_poetry_forms () =
  let forms = [QiYanJueJu; WuYanLuShi; SiYanPianTi; ModernPoetry] in
  check int "诗词形式数量" 4 (List.length forms)

let test_suite =
  [
    ("test_artistic_dimensions", `Quick, test_artistic_dimensions);
    ("test_evaluation_grades", `Quick, test_evaluation_grades);
    ("test_poetry_forms", `Quick, test_poetry_forms);
  ]

let () = run "诗词艺术引擎测试" [ ("Poetry Artistic Engine", test_suite) ]