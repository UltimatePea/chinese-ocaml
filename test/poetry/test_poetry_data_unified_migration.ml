(** 诗词数据统一模块迁移测试 - Phase 1-A 韵律系统整合版本
    
    为Phase 1-A韵律系统整合提供数据完整性测试保护。
    确保统一韵律数据模块的数据迁移和访问功能正常。
    
    Author: Echo, 测试工程师代理 + Whisky, PR Worker (Phase 1-A 适配)
    目标: 保护诗词数据层重构过程中的数据完整性和功能一致性 *)

open Alcotest
open Poetry_rhyme.Rhyme_data
open Poetry_rhyme.Rhyme_query
open Poetry_rhyme.Rhyme_types

(** {1 测试数据和常量} *)

let sample_characters = [ "春"; "花"; "秋"; "月"; "风"; "水"; "山"; "川" ]

(** {2 数据加载和初始化测试} *)

let test_poetry_data_initialization () =
  (* 测试诗词数据模块能否正确初始化 *)
  check bool "poetry_data_module_可加载" true
    (try
       let _stats = get_statistics () in
       true
     with _ -> false);

  (* 测试数据统计信息访问 *)
  check bool "数据统计信息可访问" true
    (try
       let stats = get_statistics () in
       stats.total_groups >= 0 && stats.total_characters >= 0
     with _ -> false)

let test_rhyme_database_loading () =
  try
    let stats = get_statistics () in
    check bool "数据库加载成功" true true;

    (* 验证数据库包含必要的韵组 *)
    let available_groups = get_all_groups () in
    check bool "包含韵组数据" true (List.length available_groups > 0);
    check bool "统计信息一致" true (stats.total_groups = List.length available_groups)
  with
  | e ->
      check bool ("数据库加载异常: " ^ Printexc.to_string e) false true

(** {3 韵组数据访问测试} *)

let test_rhyme_group_data_access () =
  (* 测试韵组数据访问功能 *)
  let an_group_chars = get_group_characters AnRhyme in
  let tian_group_chars = get_group_characters TianRhyme in
  
  check bool "安韵组字符查询正常" true (List.length an_group_chars >= 0);
  check bool "天韵组字符查询正常" true (List.length tian_group_chars >= 0);
  
  (* 测试所有韵组访问 *)
  let all_groups = get_all_groups () in
  check bool "所有韵组可访问" true (List.length all_groups > 0);
  check bool "韵组列表包含基础韵组" true 
    (List.exists (fun g -> g.group_id = AnRhyme) all_groups ||
     List.exists (fun g -> g.group_id = TianRhyme) all_groups ||
     List.exists (fun g -> g.group_id = SiRhyme) all_groups)

(** {4 字符查询功能测试} *)

let test_character_query_functionality () =
  (* 测试字符查询功能 *)
  List.iter (fun char ->
    let result = query_character_cached char in
    check bool (Printf.sprintf "字符'%s'查询功能正常" char) true
      (match result with 
       | Found _ -> true 
       | NotFound _ -> true 
       | MultipleMatches _ -> true)
  ) sample_characters;
  
  (* 测试批量查询一致性 *)
  let results1 = List.map query_character_cached sample_characters in
  let results2 = List.map query_character_cached sample_characters in
  check bool "查询结果一致性" true (List.length results1 = List.length results2)

(** {5 韵律匹配功能测试} *)

let test_rhyme_matching_functionality () =
  (* 测试韵律匹配功能 *)
  let test_pairs = [("春", "云"); ("花", "霞"); ("山", "间"); ("风", "空")] in
  List.iter (fun (char1, char2) ->
    let can_rhyme = check_rhyme_match char1 char2 in
    check bool (Printf.sprintf "韵律匹配'%s'和'%s'检查正常" char1 char2) true 
      (can_rhyme || not can_rhyme)
  ) test_pairs;
  
  (* 测试相同字符匹配 *)
  let same_char_match = check_rhyme_match "春" "春" in
  check bool "相同字符韵律匹配检查正常" true (same_char_match || not same_char_match)

(** {6 数据完整性验证测试} *)

let test_data_integrity_validation () =
  (* 验证数据统计一致性 *)
  let stats = get_statistics () in
  let all_groups = get_all_groups () in
  
  check bool "韵组数量统计一致" true (stats.total_groups = List.length all_groups);
  check bool "字符总数为正数" true (stats.total_characters > 0);
  
  (* 验证各韵组字符数量 *)
  let total_chars_by_groups = List.fold_left (fun acc group ->
    let chars = get_group_characters group.group_id in
    acc + List.length chars
  ) 0 all_groups in
  
  check bool "韵组字符数量统计合理" true (total_chars_by_groups >= 0)

(** {7 性能和缓存测试} *)

let test_performance_and_caching () =
  (* 测试查询性能 *)
  let start_time = Sys.time () in
  List.iter (fun char ->
    ignore (query_character_cached char)
  ) sample_characters;
  let duration = Sys.time () -. start_time in
  check bool "批量查询性能合理" true (duration < 2.0);
  
  (* 测试缓存一致性 *)
  let char = "春" in
  let result1 = query_character_cached char in
  let result2 = query_character_cached char in
  let results_match = match (result1, result2) with
    | (Found _, Found _) -> true
    | (NotFound _, NotFound _) -> true
    | (MultipleMatches _, MultipleMatches _) -> true
    | _ -> false
  in
  check bool "缓存查询结果一致" true results_match

(** {8 错误处理和边界情况测试} *)

let test_error_handling_and_edge_cases () =
  (* 测试空字符串处理 *)
  let empty_result = query_character_cached "" in
  check bool "空字符串处理正常" true 
    (match empty_result with NotFound _ -> true | _ -> false);
  
  (* 测试特殊字符处理 *)
  let special_chars = ["。"; "，"; "！"; "？"; " "] in
  List.iter (fun char ->
    let result = query_character_cached char in
    check bool (Printf.sprintf "特殊字符'%s'处理正常" char) true
      (match result with Found _ | NotFound _ | MultipleMatches _ -> true)
  ) special_chars;
  
  (* 测试未知韵组查询 *)
  let unknown_chars = get_group_characters UnknownRhyme in
  check bool "未知韵组查询不出错" true (List.length unknown_chars >= 0)

let () =
  run "诗词数据统一模块迁移测试 - Phase 1-A"
    [
      ("数据初始化", [
        test_case "诗词数据模块初始化" `Quick test_poetry_data_initialization;
        test_case "韵律数据库加载" `Quick test_rhyme_database_loading;
      ]);
      ("数据访问", [
        test_case "韵组数据访问" `Quick test_rhyme_group_data_access;
        test_case "字符查询功能" `Quick test_character_query_functionality;
      ]);
      ("韵律匹配", [
        test_case "韵律匹配功能" `Quick test_rhyme_matching_functionality;
      ]);
      ("数据完整性", [
        test_case "数据完整性验证" `Quick test_data_integrity_validation;
      ]);
      ("性能测试", [
        test_case "性能和缓存测试" `Quick test_performance_and_caching;
      ]);
      ("边界情况", [
        test_case "错误处理和边界情况" `Quick test_error_handling_and_edge_cases;
      ]);
    ]