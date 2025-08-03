(** 韵律模块整合验证测试
    
    验证新的整合韵律模块功能是否正常工作。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施 *)

#require "src/poetry/rhyme/dune";;
open Poetry_rhyme.Rhyme_types;;
open Poetry_rhyme.Rhyme_data;;
open Poetry_rhyme.Rhyme_query;;
open Poetry_rhyme.Rhyme_compatibility;;

(** 测试基础查询功能 *)
let test_basic_queries () =
  Printf.printf "=== 测试基础查询功能 ===\n";
  
  let test_chars = ["春"; "花"; "山"; "水"; "风"; "雪"] in
  List.iter (fun char ->
    match lookup_character char with
    | Found rhyme_char ->
        Printf.printf "字符 '%s': %s %s\n" 
          char 
          (string_of_rhyme_group rhyme_char.rhyme_group)
          (string_of_tone_category rhyme_char.tone)
    | NotFound _ ->
        Printf.printf "字符 '%s': 未找到\n" char
    | MultipleMatches chars ->
        Printf.printf "字符 '%s': 多个匹配 (%d个)\n" char (List.length chars)
  ) test_chars;
  Printf.printf "\n"

(** 测试韵组查询 *)
let test_group_queries () =
  Printf.printf "=== 测试韵组查询功能 ===\n";
  
  List.iter (fun group ->
    match lookup_group group with
    | Some group_data ->
        Printf.printf "韵组 %s: %d个字符 (平声: %d, 仄声: %d)\n"
          (string_of_rhyme_group group)
          (List.length group_data.all_characters)
          (List.length group_data.ping_sheng_chars)
          (List.length group_data.ze_sheng_chars)
    | None ->
        Printf.printf "韵组 %s: 未找到数据\n" (string_of_rhyme_group group)
  ) [AnRhyme; SiRhyme; TianRhyme; WangRhyme; QuRhyme];
  Printf.printf "\n"

(** 测试同韵查询 *)
let test_rhyme_matching () =
  Printf.printf "=== 测试同韵查询功能 ===\n";
  
  let test_pairs = [("春", "山"); ("花", "家"); ("风", "中")] in
  List.iter (fun (char1, char2) ->
    let is_match = check_rhyme_match char1 char2 in
    Printf.printf "'%s' 和 '%s' %s\n" 
      char1 char2 (if is_match then "同韵" else "不同韵")
  ) test_pairs;
  Printf.printf "\n"

(** 测试性能 *)
let test_performance () =
  Printf.printf "=== 测试查询性能 ===\n";
  
  let (total_time, qps, hit_rate) = run_benchmark 1000 in
  Printf.printf "性能测试结果:\n";
  Printf.printf "总时间: %.4f秒\n" total_time;
  Printf.printf "每秒查询数: %.0f\n" qps;
  Printf.printf "缓存命中率: %.1f%%\n" (hit_rate *. 100.0);
  Printf.printf "\n"

(** 测试数据完整性 *)
let test_data_integrity () =
  Printf.printf "=== 测试数据完整性 ===\n";
  
  let (is_valid, issues) = validate_data_integrity () in
  if is_valid then
    Printf.printf "✓ 数据完整性验证通过\n"
  else (
    Printf.printf "✗ 数据完整性验证失败:\n";
    List.iter (fun issue -> Printf.printf "  - %s\n" issue) issues
  );
  
  let stats = get_statistics () in
  Printf.printf "统计信息:\n";
  Printf.printf "总字符: %d, 总韵组: %d\n" stats.total_characters stats.total_groups;
  Printf.printf "平声: %d, 仄声: %d\n" stats.ping_sheng_count stats.ze_sheng_count;
  Printf.printf "\n"

(** 测试向后兼容性 *)
let test_compatibility () =
  Printf.printf "=== 测试向后兼容性 ===\n";
  
  (* 测试传统模块接口 *)
  Printf.printf "安韵组平声字符数: %d\n" (List.length An_rhyme_data.ping_sheng_chars);
  Printf.printf "思韵组仄声字符数: %d\n" (List.length Si_rhyme_data.ze_sheng_chars);
  
  (* 测试传统查询接口 *)
  (match Legacy_Query.rhyme_lookup "春" with
   | Legacy_Query.Found entry -> 
       Printf.printf "传统查询 '春': %s\n" (string_of_rhyme_group entry.group)
   | Legacy_Query.NotFound -> 
       Printf.printf "传统查询 '春': 未找到\n");
  
  let is_compatible = verify_compatibility () in
  Printf.printf "兼容性验证: %s\n" (if is_compatible then "✓ 通过" else "✗ 失败");
  Printf.printf "\n"

(** 主测试函数 *)
let run_all_tests () =
  Printf.printf "韵律模块整合功能验证测试\n";
  Printf.printf "=====================================\n\n";
  
  test_basic_queries ();
  test_group_queries ();
  test_rhyme_matching ();
  test_performance ();
  test_data_integrity ();
  test_compatibility ();
  
  Printf.printf "=====================================\n";
  Printf.printf "所有测试完成！\n"

(** 运行测试 *)
let () = run_all_tests ()