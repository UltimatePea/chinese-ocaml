(* Simple test for the new modular evaluators architecture *)
open Poetry_evaluators.Artistic_evaluation_engine

let () =
  Printf.printf "=== 模块化评价器架构测试 ===\n";

  (* 测试单句评价 *)
  let single_result = evaluate_single_verse "春风又绿江南岸" in
  Printf.printf "单句评价 - 总分: %.2f\n" single_result.overall_score;
  Printf.printf "评价维度数: %d\n" (List.length single_result.dimension_scores);

  (* 测试多句评价 *)
  let verses = [ "春风又绿江南岸"; "明月何时照我还" ] in
  let multi_result = evaluate_multiple_verses verses in
  Printf.printf "多句评价 - 总分: %.2f\n" multi_result.overall_score;

  (* 显示评价器信息 *)
  let eval_info = get_evaluator_info () in
  Printf.printf "可用评价器数量: %d\n" (List.length eval_info);

  Printf.printf "=== 模块化架构测试完成 ===\n"
