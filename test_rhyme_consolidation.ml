(** 韵律模块整合验证测试

    验证新的统一韵律模块的功能完整性和性能表现

    Author: Whisky, PR Worker Issue: #1999 - Poetry韵律模块统一整合实施 *)

open Poetry_rhyme

let test_basic_functionality () =
  Printf.printf "=== 韵律模块基础功能测试 ===\n";

  (* 测试字符查询 *)
  let test_chars = [ "春"; "花"; "山"; "水"; "风"; "雪" ] in
  List.iter
    (fun char ->
      match Rhyme_data.lookup_character char with
      | Rhyme_types.Found rhyme_char ->
          Printf.printf "字符 '%s': %s韵, %s\n" char
            (Rhyme_types.string_of_rhyme_group rhyme_char.rhyme_group)
            (Rhyme_types.string_of_tone_category rhyme_char.tone)
      | Rhyme_types.NotFound _ -> Printf.printf "字符 '%s': 未找到\n" char
      | Rhyme_types.MultipleMatches matches ->
          Printf.printf "字符 '%s': 多个匹配 (%d个)\n" char (List.length matches))
    test_chars;

  (* 测试韵组查询 *)
  Printf.printf "\n=== 韵组数据测试 ===\n";
  let test_groups = [ Rhyme_types.AnRhyme; Rhyme_types.FengRhyme; Rhyme_types.HuaRhyme ] in
  List.iter
    (fun group ->
      match Rhyme_data.lookup_group group with
      | Some group_data ->
          Printf.printf "%s: %d个字符 (平声: %d, 仄声: %d)\n" group_data.group_name
            (List.length group_data.all_characters)
            (List.length group_data.ping_sheng_chars)
            (List.length group_data.ze_sheng_chars)
      | None -> Printf.printf "%s: 数据缺失\n" (Rhyme_types.string_of_rhyme_group group))
    test_groups

let test_performance () =
  Printf.printf "\n=== 性能基准测试 ===\n";
  let total_time, queries_per_sec, hit_rate = Rhyme_query.run_benchmark 1000 in
  Printf.printf "基准测试结果:\n";
  Printf.printf "- 总时间: %.4f秒\n" total_time;
  Printf.printf "- 查询速度: %.0f 查询/秒\n" queries_per_sec;
  Printf.printf "- 缓存命中率: %.1f%%\n" (hit_rate *. 100.0)

let test_compatibility () =
  Printf.printf "\n=== 兼容性验证测试 ===\n";
  let is_compatible = Rhyme_compatibility.verify_compatibility () in
  Printf.printf "兼容性验证: %s\n" (if is_compatible then "✓ 通过" else "✗ 失败");

  let compat_report = Rhyme_compatibility.get_compatibility_report () in
  Printf.printf "%s\n" compat_report

let test_data_integrity () =
  Printf.printf "\n=== 数据完整性验证 ===\n";
  let is_valid, issues = Rhyme_data.validate_data_integrity () in
  Printf.printf "数据完整性: %s\n" (if is_valid then "✓ 完整" else "✗ 存在问题");

  if not is_valid then (
    Printf.printf "发现的问题:\n";
    List.iter (Printf.printf "- %s\n") issues);

  let stats = Rhyme_data.get_statistics () in
  Printf.printf "\n统计信息:\n";
  Printf.printf "- 总字符数: %d\n" stats.total_characters;
  Printf.printf "- 总韵组数: %d\n" stats.total_groups;
  Printf.printf "- 平声字符: %d\n" stats.ping_sheng_count;
  Printf.printf "- 仄声字符: %d\n" stats.ze_sheng_count;
  Printf.printf "- 最多字符韵组: %s\n" (Rhyme_types.string_of_rhyme_group stats.most_frequent_group);
  Printf.printf "- 最少字符韵组: %s\n" (Rhyme_types.string_of_rhyme_group stats.least_frequent_group)

let () =
  Printf.printf "Poetry韵律模块整合验证\n";
  Printf.printf "==========================\n\n";

  test_basic_functionality ();
  test_performance ();
  test_compatibility ();
  test_data_integrity ();

  Printf.printf "\n=== 验证完成 ===\n"
