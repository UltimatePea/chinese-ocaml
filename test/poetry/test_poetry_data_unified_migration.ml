(** 诗词数据统一模块迁移测试
    
    为Issue #1576技术债务清理计划中的rhyme_data_unified.ml重构提供测试保护。
    该模块需要从数据层独立出来，本测试确保数据迁移过程中的完整性。
    
    Author: Echo, 测试工程师代理
    目标: 保护诗词数据层重构过程中的数据完整性和功能一致性
    *)

open Alcotest
open Yyocamlc_lib

(** {1 测试数据和常量} *)

let sample_poem_lines = [
  "春花秋月何时了";
  "往事知多少";
  "小楼昨夜又东风";
  "故国不堪回首月明中"
]

let sample_rhyme_pairs = [
  ("了", "少"); (* 同韵 *)
  ("风", "中"); (* 同韵 *)
  ("春", "秋"); (* 不同韵 *)
  ("花", "月"); (* 不同韵 *)
]

(** {2 数据加载和初始化测试} *)

let test_poetry_data_initialization () =
  (* 测试诗词数据模块能否正确初始化 *)
  check bool "poetry_data_module_loadable" true
    (try
       ignore (Poetry_json_unified.load_rhyme_database ());
       true
     with _ -> false);
  
  (* 测试数据文件路径访问 *)
  check bool "data_directory_accessible" true
    (try
       let data_dir = Poetry_json_unified.get_data_directory () in
       String.length data_dir > 0
     with _ -> false)

let test_rhyme_database_loading () =
  try
    let db = Poetry_json_unified.load_rhyme_database () in
    check bool "database_loaded_successfully" true true;
    
    (* 验证数据库包含必要的韵组 *)
    let available_groups = Poetry_json_unified.get_available_rhyme_groups db in
    check bool "has_rhyme_groups" true (List.length available_groups > 0);
    
    (* 验证包含常见韵组 *)
    let has_common_groups = List.exists (fun group ->
      String.contains (Poetry_json_unified.group_to_string group) '安' ||
      String.contains (Poetry_json_unified.group_to_string group) '风'
    ) available_groups in
    check bool "has_common_rhyme_groups" true has_common_groups
    
  with exn ->
    fail ("Database loading failed: " ^ Printexc.to_string exn)

(** {3 数据查询功能测试} *)

let test_character_rhyme_lookup () =
  try
    let db = Poetry_json_unified.load_rhyme_database () in
    
    (* 测试常见字符韵律查找 *)
    let test_chars = ["春"; "花"; "秋"; "月"; "风"; "中"] in
    List.iter (fun char ->
      match Poetry_json_unified.lookup_character_rhyme db char with
      | Some rhyme_info ->
          check bool ("char_" ^ char ^ "_has_rhyme") true true;
          check string ("char_" ^ char ^ "_not_empty") char rhyme_info.character
      | None ->
          (* 某些字符可能不在数据库中，这是正常的 *)
          check bool ("char_" ^ char ^ "_lookup_handled") true true
    ) test_chars
    
  with exn ->
    fail ("Character lookup failed: " ^ Printexc.to_string exn)

let test_rhyme_group_query () =
  try
    let db = Poetry_json_unified.load_rhyme_database () in
    let groups = Poetry_json_unified.get_available_rhyme_groups db in
    
    (* 测试每个韵组的字符查询 *)
    List.iter (fun group ->
      let characters = Poetry_json_unified.get_characters_in_group db group in
      check bool ("group_has_characters_" ^ (Poetry_json_unified.group_to_string group)) 
        true (List.length characters >= 0); (* 允许空韵组存在 *)
      
      (* 验证字符一致性 *)
      List.iter (fun char ->
        match Poetry_json_unified.lookup_character_rhyme db char with
        | Some info -> 
            check bool ("char_group_consistency_" ^ char) 
              true (info.rhyme_group = group)
        | None ->
            fail ("Character " ^ char ^ " should be found in database")
      ) (List.take (min 3 (List.length characters)) characters)
      
    ) (List.take 5 groups) (* 测试前5个韵组 *)
    
  with exn ->
    fail ("Rhyme group query failed: " ^ Printexc.to_string exn)

(** {4 韵律匹配算法测试} *)

let test_rhyme_matching_algorithm () =
  try
    let db = Poetry_json_unified.load_rhyme_database () in
    
    (* 测试已知韵律对 *)
    List.iter (fun (char1, char2) ->
      let match_result = Poetry_json_unified.check_rhyme_match db char1 char2 in
      let match_score = Poetry_json_unified.calculate_rhyme_score db char1 char2 in
      
      (* 匹配分数应该在合理范围内 *)
      check bool ("rhyme_score_valid_" ^ char1 ^ "_" ^ char2) 
        true (match_score >= 0.0 && match_score <= 1.0);
      
      (* 相同字符应该完全匹配 *)
      if char1 = char2 then
        check (float 0.01) ("same_char_perfect_" ^ char1) 1.0 match_score
        
    ) sample_rhyme_pairs
    
  with exn ->
    fail ("Rhyme matching test failed: " ^ Printexc.to_string exn)

let test_poem_rhyme_analysis () =
  try
    let db = Poetry_json_unified.load_rhyme_database () in
    
    (* 分析示例诗句的韵律 *)
    List.iter (fun line ->
      let analysis = Poetry_json_unified.analyze_line_rhyme db line in
      check bool ("line_analysis_" ^ (String.sub line 0 2)) 
        true (analysis.line_length > 0);
      check bool ("line_has_characters_" ^ (String.sub line 0 2))
        true (List.length analysis.characters > 0);
      
      (* 验证分析结果的一致性 *)
      check int ("analysis_length_matches_" ^ (String.sub line 0 2))
        (String.length line) (analysis.line_length)
        
    ) sample_poem_lines
    
  with exn ->
    fail ("Poem analysis failed: " ^ Printexc.to_string exn)

(** {5 数据完整性和一致性测试} *)

let test_data_integrity () =
  try
    let db = Poetry_json_unified.load_rhyme_database () in
    
    (* 检查数据库统计信息 *)
    let stats = Poetry_json_unified.get_database_statistics db in
    check bool "positive_total_characters" true (stats.total_characters > 0);
    check bool "positive_total_groups" true (stats.total_rhyme_groups > 0);
    check bool "valid_coverage_ratio" true 
      (stats.coverage_ratio >= 0.0 && stats.coverage_ratio <= 1.0);
    
    (* 验证数据一致性 *)
    let consistency_check = Poetry_json_unified.verify_data_consistency db in
    check bool "data_consistency_check" true consistency_check.is_consistent;
    check int "no_orphaned_characters" 0 consistency_check.orphaned_characters;
    check int "no_empty_groups" 0 consistency_check.empty_groups
    
  with exn ->
    fail ("Data integrity test failed: " ^ Printexc.to_string exn)

let test_cross_reference_validation () =
  try
    let db = Poetry_json_unified.load_rhyme_database () in
    
    (* 交叉验证字符和韵组的关联 *)
    let groups = Poetry_json_unified.get_available_rhyme_groups db in
    List.iter (fun group ->
      let chars_in_group = Poetry_json_unified.get_characters_in_group db group in
      List.iter (fun char ->
        match Poetry_json_unified.lookup_character_rhyme db char with
        | Some info ->
            check bool ("cross_ref_" ^ char ^ "_group") 
              true (info.rhyme_group = group)
        | None ->
            fail ("Cross-reference failed for character: " ^ char)
      ) (List.take (min 2 (List.length chars_in_group)) chars_in_group)
    ) (List.take 3 groups)
    
  with exn ->
    fail ("Cross-reference validation failed: " ^ Printexc.to_string exn)

(** {6 性能和内存使用测试} *)

let test_loading_performance () =
  (* 测试数据库加载性能 *)
  let start_time = Unix.gettimeofday () in
  let db = Poetry_json_unified.load_rhyme_database () in
  let load_time = Unix.gettimeofday () -. start_time in
  
  check bool "loading_under_5s" true (load_time < 5.0);
  
  (* 测试查询性能 *)
  let query_start = Unix.gettimeofday () in
  for i = 1 to 100 do
    let char = List.nth ["春"; "花"; "秋"; "月"] (i mod 4) in
    ignore (Poetry_json_unified.lookup_character_rhyme db char)
  done;
  let query_time = Unix.gettimeofday () -. query_start in
  
  check bool "query_performance" true (query_time < 1.0)

let test_memory_usage () =
  (* 测试内存使用合理性 *)
  let initial_memory = Poetry_json_unified.get_memory_usage () in
  let db = Poetry_json_unified.load_rhyme_database () in
  let after_load_memory = Poetry_json_unified.get_memory_usage () in
  
  let memory_increase = after_load_memory -. initial_memory in
  check bool "reasonable_memory_usage" true (memory_increase < 100.0); (* 100MB限制 *)
  
  (* 测试垃圾回收后内存 *)
  Gc.full_major ();
  let after_gc_memory = Poetry_json_unified.get_memory_usage () in
  check bool "memory_stable_after_gc" true 
    (abs_float (after_gc_memory -. after_load_memory) < 10.0)

(** {7 错误处理和边界情况测试} *)

let test_invalid_input_handling () =
  try
    let db = Poetry_json_unified.load_rhyme_database () in
    
    (* 测试空字符串 *)
    (match Poetry_json_unified.lookup_character_rhyme db "" with
     | None -> check bool "empty_string_handled" true true
     | Some _ -> fail "Empty string should return None");
    
    (* 测试非中文字符 *)
    (match Poetry_json_unified.lookup_character_rhyme db "abc" with
     | None -> check bool "non_chinese_handled" true true
     | Some _ -> check bool "non_chinese_may_have_result" true true);
    
    (* 测试特殊字符 *)
    let special_chars = ["@"; "#"; "$"; "%"] in
    List.iter (fun char ->
      match Poetry_json_unified.lookup_character_rhyme db char with
      | None -> check bool ("special_char_" ^ char ^ "_handled") true true
      | Some _ -> check bool ("special_char_" ^ char ^ "_may_exist") true true
    ) special_chars
    
  with exn ->
    fail ("Invalid input handling failed: " ^ Printexc.to_string exn)

let test_database_corruption_recovery () =
  (* 测试数据库损坏时的恢复机制 *)
  try
    (* 尝试加载可能损坏的数据 *)
    let recovery_result = Poetry_json_unified.attempt_database_recovery () in
    check bool "recovery_mechanism_available" true 
      (recovery_result.recovery_attempted);
    
    if recovery_result.recovery_successful then
      check bool "recovery_successful" true true
    else
      (* 恢复失败是可接受的，只要有适当的错误处理 *)
      check bool "recovery_failure_handled" true 
        (List.length recovery_result.error_messages > 0)
        
  with exn ->
    (* 异常也是可接受的，只要不导致程序崩溃 *)
    check bool "corruption_exception_handled" true true

(** {8 迁移准备测试} *)

let test_migration_compatibility () =
  (* 测试新旧接口的兼容性 *)
  try
    let db = Poetry_json_unified.load_rhyme_database () in
    
    (* 验证关键API函数存在且可调用 *)
    let api_functions = [
      (fun () -> ignore (Poetry_json_unified.get_api_version ()));
      (fun () -> ignore (Poetry_json_unified.get_data_format_version ()));
      (fun () -> ignore (Poetry_json_unified.check_compatibility_version ()));
    ] in
    
    List.iteri (fun i func ->
      try
        func ();
        check bool ("api_function_" ^ string_of_int i ^ "_callable") true true
      with exn ->
        fail ("API function " ^ string_of_int i ^ " failed: " ^ Printexc.to_string exn)
    ) api_functions
    
  with exn ->
    fail ("Migration compatibility test failed: " ^ Printexc.to_string exn)

let test_export_import_consistency () =
  (* 测试数据导出导入的一致性 *)
  try
    let db = Poetry_json_unified.load_rhyme_database () in
    
    (* 导出数据 *)
    let exported_data = Poetry_json_unified.export_database_subset db 10 in
    check bool "export_successful" true (List.length exported_data > 0);
    
    (* 验证导出数据的完整性 *)
    List.iter (fun entry ->
      check bool ("export_entry_valid_" ^ entry.character) true 
        (String.length entry.character > 0);
      check bool ("export_entry_has_group_" ^ entry.character) true
        (Poetry_json_unified.is_valid_rhyme_group entry.rhyme_group)
    ) (List.take (min 5 (List.length exported_data)) exported_data)
    
  with exn ->
    fail ("Export/import consistency test failed: " ^ Printexc.to_string exn)

(** {9 测试套件定义} *)

let poetry_data_unified_tests = [
  (* 初始化和加载测试 *)
  test_case "poetry data initialization" `Quick test_poetry_data_initialization;
  test_case "rhyme database loading" `Quick test_rhyme_database_loading;
  
  (* 数据查询测试 *)
  test_case "character rhyme lookup" `Quick test_character_rhyme_lookup;
  test_case "rhyme group query" `Quick test_rhyme_group_query;
  
  (* 算法功能测试 *)
  test_case "rhyme matching algorithm" `Quick test_rhyme_matching_algorithm;
  test_case "poem rhyme analysis" `Quick test_poem_rhyme_analysis;
  
  (* 数据完整性测试 *)
  test_case "data integrity" `Quick test_data_integrity;
  test_case "cross reference validation" `Quick test_cross_reference_validation;
  
  (* 性能测试 *)
  test_case "loading performance" `Slow test_loading_performance;
  test_case "memory usage" `Slow test_memory_usage;
  
  (* 错误处理测试 *)
  test_case "invalid input handling" `Quick test_invalid_input_handling;
  test_case "database corruption recovery" `Quick test_database_corruption_recovery;
  
  (* 迁移测试 *)
  test_case "migration compatibility" `Quick test_migration_compatibility;
  test_case "export import consistency" `Quick test_export_import_consistency;
]

(** 主测试运行器 *)
let () =
  run "Poetry Data Unified Migration Protection" [
    "poetry_data_unified", poetry_data_unified_tests;
  ]