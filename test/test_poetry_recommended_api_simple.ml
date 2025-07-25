open Poetry.Poetry_recommended_api

let test_find_rhyme_info () =
  let result = find_rhyme_info "春" in
  Printf.printf "测试find_rhyme_info \"春\": %s\n"
    (match result with
     | Some (cat, grp) -> Printf.sprintf "韵类: %s, 韵组: %s" 
         (Poetry.Rhyme_types.rhyme_category_to_string cat)
         (Poetry.Rhyme_types.rhyme_group_to_string grp)
     | None -> "未找到");
  ()

let test_check_rhyme_match () =
  let result = check_rhyme_match "春" "人" in
  Printf.printf "测试check_rhyme_match \"春\" \"人\": %b\n" result;
  ()

let test_evaluate_poem () =
  let poem = ["春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"] in
  let result = evaluate_poem poem in
  Printf.printf "测试evaluate_poem:\n";
  Printf.printf "  总分: %.2f\n" result.score;
  Printf.printf "  韵律质量: %.2f\n" result.rhyme_quality;
  Printf.printf "  艺术质量: %.2f\n" result.artistic_quality;
  Printf.printf "  格律符合度: %.2f\n" result.form_compliance;
  List.iter (fun rec_str -> Printf.printf "  建议: %s\n" rec_str) result.recommendations;
  ()

let () =
  Printf.printf "=== Poetry Recommended API 简单测试 ===\n";
  test_find_rhyme_info ();
  test_check_rhyme_match ();
  test_evaluate_poem ();
  Printf.printf "=== 测试完成 ===\n"