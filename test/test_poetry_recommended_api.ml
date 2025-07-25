(** 测试诗词推荐API模块 *)

open Poetry_recommended_api

let test_basic_functionality () =
  (* 测试预加载功能 *)
  Printf.printf "测试预加载韵律数据...\n";
  preload_rhyme_data ();
  Printf.printf "预加载完成\n";
  
  (* 测试清理功能 *)
  Printf.printf "测试清理缓存...\n";
  cleanup_cache ();
  Printf.printf "清理完成\n";
  
  (* 测试简单诗词评价 *)
  Printf.printf "测试诗词评价API...\n";
  try
    let simple_poem = ["测试行一"; "测试行二"] in
    let result = evaluate_poem simple_poem in
    Printf.printf "评价结果: 总分=%.2f, 韵律=%.2f, 艺术=%.2f, 格律=%.2f\n"
      result.score result.rhyme_quality result.artistic_quality result.form_compliance;
    Printf.printf "建议数量: %d\n" (List.length result.recommendations)
  with
  | e -> Printf.printf "评价过程中出现错误: %s\n" (Printexc.to_string e)

let test_module_availability () =
  Printf.printf "测试模块可用性...\n";
  
  (* 测试各个核心函数是否可以调用 *)
  try
    let _ = find_rhyme_info "测" in
    Printf.printf "- find_rhyme_info: 可用\n";
  with e -> Printf.printf "- find_rhyme_info: 错误 %s\n" (Printexc.to_string e);
  
  try
    let _ = detect_rhyme_category "试" in
    Printf.printf "- detect_rhyme_category: 可用\n";
  with e -> Printf.printf "- detect_rhyme_category: 错误 %s\n" (Printexc.to_string e);
  
  try
    let _ = check_rhyme_match "测" "试" in
    Printf.printf "- check_rhyme_match: 可用\n";
  with e -> Printf.printf "- check_rhyme_match: 错误 %s\n" (Printexc.to_string e)

let run_tests () =
  Printf.printf "=== 测试诗词推荐API ===\n\n";
  
  Printf.printf "1. 测试基础功能:\n";
  test_basic_functionality ();
  
  Printf.printf "\n2. 测试模块可用性:\n";
  test_module_availability ();
  
  Printf.printf "\n=== 测试完成 ===\n"

let () = run_tests ()