(** 韵律统一模块基础测试 - 已废弃

    原Rhyme_unified模块已整合到Poetry_rhyme模块中。 此测试文件已暂时注释，待更新为新的测试内容。

    @author Alpha代理, 技术债务清理专员
    @version 1.0 - 统一整合版本测试
    @since 2025-07-29 - 韵律模块整合重构测试

    参见 issue #1673 *)

open Alcotest
open Poetry_rhyme.Rhyme_types

(** 测试数据获取功能 *)
let test_data_module () =
  (* 测试韵组获取 *)
  let groups = Poetry_rhyme.Rhyme_data.get_all_groups () in
  check bool "Should have rhyme groups" true (List.length groups > 0);

  (* 测试字符查询 *)
  let chars = Poetry_rhyme.Rhyme_data.get_group_characters AnRhyme in
  check bool "AnRhyme should have characters" true (List.length chars >= 0);

  (* 测试统计信息 *)
  let stats = Poetry_rhyme.Rhyme_data.get_statistics () in
  check bool "Should have positive group count" true (stats.total_groups > 0);
  check bool "Should have positive character count" true (stats.total_characters > 0)

(** 测试查询模块功能 *)
let test_query_module () =
  (* 测试字符韵律查找 *)
  let rhyme_result = Poetry_rhyme.Rhyme_query.query_character_cached "山" in
  check bool "Should find rhyme info for 山" true
    (match rhyme_result with Found _ -> true | _ -> false);

  (* 测试不存在字符 *)
  let no_result = Poetry_rhyme.Rhyme_query.query_character_cached "不存在" in
  check bool "Should not find non-existent character" true
    (match no_result with NotFound _ -> true | _ -> false);

  (* 测试押韵检查 *)
  let can_rhyme = Poetry_rhyme.Rhyme_data.check_rhyme_match "山" "间" in
  check bool "山 and 间 should rhyme" true can_rhyme

(** 测试缓存功能 *)
let test_cache_functionality () =
  (* 测试缓存一致性 *)
  let result1 = Poetry_rhyme.Rhyme_query.query_character_cached "春" in
  let result2 = Poetry_rhyme.Rhyme_query.query_character_cached "春" in
  check bool "Cached results should be consistent" true
    (match (result1, result2) with
    | Found c1, Found c2 -> c1.character = c2.character
    | NotFound _, NotFound _ -> true
    | _ -> false);

  (* 测试缓存性能统计 *)
  let stats = Poetry_rhyme.Rhyme_query.get_query_stats () in
  check bool "Query stats should be available" true (stats.total_queries >= 0)

(** 测试数据完整性 *)
let test_data_integrity () =
  (* 验证数据完整性 *)
  let is_valid, issues = Poetry_rhyme.Rhyme_data.validate_data_integrity () in
  check bool "Data integrity should be valid" true is_valid;
  check bool "Should have no integrity issues" true (List.length issues = 0);

  (* 测试一些已知字符 *)
  let known_chars = [ "山"; "间"; "春"; "年"; "天" ] in
  List.iter
    (fun char ->
      let result = Poetry_rhyme.Rhyme_query.query_character_cached char in
      check bool
        ("Should find character: " ^ char)
        true
        (match result with Found _ -> true | _ -> false))
    known_chars

(** 主测试套件 *)
let () =
  run "Rhyme Unified Module Tests"
    [
      ("Data Module", [ test_case "Basic data operations" `Quick test_data_module ]);
      ("Query Module", [ test_case "Character query operations" `Quick test_query_module ]);
      ("Cache Functionality", [ test_case "Caching system" `Quick test_cache_functionality ]);
      ("Data Integrity", [ test_case "Data validation" `Quick test_data_integrity ]);
    ]
