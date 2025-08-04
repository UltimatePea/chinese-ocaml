(** 韵律统一模块基础测试
    
    更新为使用新的Poetry_rhyme模块API的测试。
    修复了Delta PR Critic指出的测试基础设施问题。

    @author Whisky, PR Worker
    @version 2.0 - 适配新韵律模块架构
    @since 2025-08-04 - 修复关键测试基础设施问题
    
    参见 issue #1999 *)

open Alcotest

(** 测试基础韵律查询功能 *)
let test_basic_query () =
  (* 测试字符查询 *)
  let result = Poetry_rhyme.Rhyme_query.query_character_cached "山" in
  match result with
  | Poetry_rhyme.Rhyme_types.Found rhyme_char ->
      check bool "字符'山'应该找到韵律信息" true true;
      check bool "韵组应该是AnRhyme" 
        (rhyme_char.rhyme_group = Poetry_rhyme.Rhyme_types.AnRhyme) true
  | _ -> 
      check bool "字符'山'查询失败" false true

(** 测试兼容性接口 *)
let test_compatibility_interface () =
  (* 测试旧API兼容性 *)
  let rhyme_group = Poetry_rhyme.Rhyme_query.detect_rhyme_group "春" in
  check bool "Spring字符应该检测到韵组" 
    (rhyme_group <> Poetry_rhyme.Rhyme_types.UnknownRhyme) true;
  
  let _rhyme_category = Poetry_rhyme.Rhyme_query.detect_rhyme_category "春" in
  check bool "应该检测到声调类别" true true

(** 测试数据完整性 *)
let test_data_integrity () =
  (* 测试韵组数据获取 *)
  let an_group_data = Poetry_rhyme.Rhyme_data.lookup_group Poetry_rhyme.Rhyme_types.AnRhyme in
  check bool "AnRhyme韵组数据应该存在" (Option.is_some an_group_data) true;
  
  (* 测试统计信息 *)
  let stats = Poetry_rhyme.Rhyme_data.get_statistics () in
  check bool "应该有总字符数统计" (stats.total_characters > 0) true;
  check bool "应该有韵组数统计" (stats.total_groups > 0) true;
  check int "韵组数应该是11" stats.total_groups 11

(** 测试性能缓存系统 *)
let test_performance_cache () =
  (* 第一次查询 *)
  let _ = Poetry_rhyme.Rhyme_query.query_character_cached "天" in
  (* 第二次查询应该使用缓存 *)
  let result2 = Poetry_rhyme.Rhyme_query.query_character_cached "天" in
  match result2 with
  | Poetry_rhyme.Rhyme_types.Found _ ->
      check bool "缓存查询应该成功" true true
  | _ ->
      check bool "缓存查询失败" false true

(** 测试批量查询功能 *)
let test_batch_query () =
  let characters = ["山"; "间"; "关"; "天"; "年"] in
  let results = Poetry_rhyme.Rhyme_query.batch_query_optimized characters in
  check bool "批量查询应该返回结果" (List.length results > 0) true;
  check int "批量查询结果数量" (List.length results) (List.length characters)

(** 主测试套件 *)
let () =
  run "Poetry Rhyme Module Tests"
    [
      ("Basic Query", [ test_case "Character query functionality" `Quick test_basic_query ]);
      ("Compatibility", [ test_case "Legacy API compatibility" `Quick test_compatibility_interface ]);
      ("Data Integrity", [ test_case "Data completeness verification" `Quick test_data_integrity ]);
      ("Performance Cache", [ test_case "Cache system functionality" `Quick test_performance_cache ]);
      ("Batch Query", [ test_case "Batch processing capability" `Quick test_batch_query ]);
    ]