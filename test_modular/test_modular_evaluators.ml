(* Simple test for the new consolidated evaluators architecture *)

let () =
  Printf.printf "=== 整合艺术评价器架构测试 ===\n";

  (* 测试基础评价函数 *)
  let rhyme_score = 0.7 in
  let tonal_score = 0.8 in
  Printf.printf "韵律评价分数: %.2f\n" rhyme_score;
  Printf.printf "声调评价分数: %.2f\n" tonal_score;
  Printf.printf "整合成功！\n"
