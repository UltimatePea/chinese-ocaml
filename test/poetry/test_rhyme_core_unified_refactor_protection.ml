(** 韵律核心统一模块重构保护测试
    
    为Issue #1576技术债务清理计划中的rhyme_core_unified.ml拆分提供测试保护。
    该文件当前856行，需要拆分为3-4个模块，本测试确保拆分过程中功能完整性。
    
    Author: Echo, 测试工程师代理
    目标: 100%覆盖率保护 rhyme_core_unified.ml 重构过程
    *)

open Alcotest
open Yyocamlc_lib.Poetry_types_consolidated

(** {1 测试数据准备} *)

let test_characters = ["春"; "花"; "秋"; "月"; "江"; "南"; "北"; "河"]
let test_an_rhyme_chars = ["安"; "干"; "观"; "寒"; "宽"; "兰"; "难"; "盘"]
let test_feng_rhyme_chars = ["风"; "东"; "中"; "空"; "红"; "公"; "蒙"; "功"]

(** {1 韵律数据条目创建测试} *)

let test_make_entry () =
  let entry = Yyocamlc_lib.Rhyme_core_unified.make_entry 
    "春" Ping_sheng An_rhyme ~variants:["椿"] ~frequency:0.8 () in
  check string "character" "春" entry.character;
  check bool "category" true (entry.category = Ping_sheng);
  check bool "group" true (entry.group = An_rhyme);
  check (list string) "variants" ["椿"] entry.variants;
  check (float 0.1) "frequency" 0.8 entry.usage_frequency

let test_make_group_entries () =
  let entries = Yyocamlc_lib.Rhyme_core_unified.make_group_entries 
    Ping_sheng An_rhyme test_an_rhyme_chars in
  check int "entries_count" 8 (List.length entries);
  let first_entry = List.hd entries in
  check string "first_character" "安" first_entry.character;
  check bool "first_category" true (first_entry.category = Ping_sheng);
  check bool "first_group" true (first_entry.group = An_rhyme)

(** {2 统一韵律数据访问测试} *)

let test_an_rhyme_data_access () =
  let an_data = Yyocamlc_lib.Rhyme_core_unified.an_rhyme_data in
  check bool "an_group_name" true (an_data.group_name = An_rhyme);
  check bool "an_entries_not_empty" true (List.length an_data.entries > 0);
  check bool "an_description_not_empty" true (String.length an_data.group_description > 0);
  
  (* 验证安韵组包含预期字符 *)
  let chars_in_entries = List.map (fun e -> e.character) an_data.entries in
  List.iter (fun char ->
    check bool ("an_contains_" ^ char) true (List.mem char chars_in_entries)
  ) ["安"; "干"; "寒"; "宽"]

let test_feng_rhyme_data_access () =
  let feng_data = Yyocamlc_lib.Rhyme_core_unified.feng_rhyme_data in  
  check bool "feng_group_name" true (feng_data.group_name = Feng_rhyme);
  check bool "feng_entries_not_empty" true (List.length feng_data.entries > 0);
  
  (* 验证风韵组包含预期字符 *)
  let chars_in_entries = List.map (fun e -> e.character) feng_data.entries in
  List.iter (fun char ->
    check bool ("feng_contains_" ^ char) true (List.mem char chars_in_entries)
  ) ["风"; "东"; "中"; "空"]

(** {3 韵组查找功能测试} *)

let test_find_rhyme_group () =
  (* 测试安韵查找 *)
  match Yyocamlc_lib.Rhyme_core_unified.find_rhyme_group "安" with
  | Some group -> check bool "find_an_group" true (group = An_rhyme)
  | None -> fail "Should find An_rhyme for character 安"
  
  (* 测试风韵查找 *)  
  match Yyocamlc_lib.Rhyme_core_unified.find_rhyme_group "风" with
  | Some group -> check bool "find_feng_group" true (group = Feng_rhyme)
  | None -> fail "Should find Feng_rhyme for character 风"
  
  (* 测试不存在字符 *)
  match Yyocamlc_lib.Rhyme_core_unified.find_rhyme_group "xyz" with
  | Some _ -> fail "Should not find rhyme group for invalid character"
  | None -> check bool "find_invalid_none" true true

let test_get_rhyme_characters () =
  let an_chars = Yyocamlc_lib.Rhyme_core_unified.get_rhyme_characters An_rhyme in
  check bool "an_chars_not_empty" true (List.length an_chars > 0);
  check bool "an_chars_contains_安" true (List.mem "安" an_chars);
  
  let feng_chars = Yyocamlc_lib.Rhyme_core_unified.get_rhyme_characters Feng_rhyme in
  check bool "feng_chars_not_empty" true (List.length feng_chars > 0);
  check bool "feng_chars_contains_风" true (List.mem "风" feng_chars)

(** {4 韵律匹配功能测试} *)

let test_check_rhyme_match () =
  (* 测试相同韵组匹配 *)
  let result1 = Yyocamlc_lib.Rhyme_core_unified.check_rhyme_match "安" "干" in
  check bool "same_rhyme_match" true result1;
  
  let result2 = Yyocamlc_lib.Rhyme_core_unified.check_rhyme_match "风" "东" in  
  check bool "same_rhyme_match_feng" true result2;
  
  (* 测试不同韵组不匹配 *)
  let result3 = Yyocamlc_lib.Rhyme_core_unified.check_rhyme_match "安" "风" in
  check bool "different_rhyme_no_match" false result3

let test_get_rhyme_score () =
  (* 测试相同韵组高分数 *)
  let score1 = Yyocamlc_lib.Rhyme_core_unified.get_rhyme_score "安" "干" in
  check bool "same_rhyme_high_score" true (score1 > 0.8);
  
  (* 测试不同韵组低分数 *)
  let score2 = Yyocamlc_lib.Rhyme_core_unified.get_rhyme_score "安" "风" in
  check bool "different_rhyme_low_score" true (score2 < 0.3);
  
  (* 测试相同字符满分 *)
  let score3 = Yyocamlc_lib.Rhyme_core_unified.get_rhyme_score "安" "安" in
  check (float 0.01) "same_char_perfect_score" 1.0 score3

(** {5 韵律数据统计功能测试} *)

let test_get_all_rhyme_groups () =
  let all_groups = Yyocamlc_lib.Rhyme_core_unified.get_all_rhyme_groups () in
  check bool "all_groups_not_empty" true (List.length all_groups > 0);
  check bool "contains_an_rhyme" true (List.mem An_rhyme all_groups);
  check bool "contains_feng_rhyme" true (List.mem Feng_rhyme all_groups)

let test_get_rhyme_group_stats () =
  let an_stats = Yyocamlc_lib.Rhyme_core_unified.get_rhyme_group_stats An_rhyme in
  check bool "an_stats_positive_count" true (an_stats.total_characters > 0);
  check bool "an_stats_valid_frequency" true (an_stats.average_frequency > 0.0);
  
  let feng_stats = Yyocamlc_lib.Rhyme_core_unified.get_rhyme_group_stats Feng_rhyme in
  check bool "feng_stats_positive_count" true (feng_stats.total_characters > 0)

(** {6 错误处理和边界情况测试} *)

let test_empty_string_handling () =
  match Yyocamlc_lib.Rhyme_core_unified.find_rhyme_group "" with
  | Some _ -> fail "Should not find rhyme group for empty string"
  | None -> check bool "empty_string_none" true true

let test_invalid_unicode_handling () =
  (* 测试无效Unicode字符 *)
  match Yyocamlc_lib.Rhyme_core_unified.find_rhyme_group "�" with
  | Some _ -> fail "Should not find rhyme group for invalid unicode"
  | None -> check bool "invalid_unicode_none" true true

let test_very_long_string_handling () =
  let long_string = String.make 1000 'x' in
  match Yyocamlc_lib.Rhyme_core_unified.find_rhyme_group long_string with
  | Some _ -> fail "Should not find rhyme group for very long string"
  | None -> check bool "long_string_none" true true

(** {7 性能基准测试} *)

let test_rhyme_lookup_performance () =
  (* 测试大量查找的性能 *)
  let start_time = Unix.gettimeofday () in
  for i = 1 to 1000 do
    let char = List.nth test_characters (i mod (List.length test_characters)) in
    ignore (Yyocamlc_lib.Rhyme_core_unified.find_rhyme_group char)
  done;
  let end_time = Unix.gettimeofday () in
  let duration = end_time -. start_time in
  check bool "performance_under_1s" true (duration < 1.0)

let test_rhyme_matching_performance () =
  (* 测试大量匹配的性能 *)
  let start_time = Unix.gettimeofday () in
  for i = 1 to 500 do
    let char1 = List.nth test_an_rhyme_chars (i mod (List.length test_an_rhyme_chars)) in
    let char2 = List.nth test_feng_rhyme_chars (i mod (List.length test_feng_rhyme_chars)) in
    ignore (Yyocamlc_lib.Rhyme_core_unified.check_rhyme_match char1 char2)
  done;
  let end_time = Unix.gettimeofday () in
  let duration = end_time -. start_time in
  check bool "matching_performance_under_1s" true (duration < 1.0)

(** {8 模块拆分准备测试} *)

(** 测试当前模块的所有导出函数，确保拆分后接口保持一致 *)
let test_current_module_interface () =
  (* 验证所有关键函数可调用 *)
  check bool "make_entry_callable" true 
    (try ignore (Yyocamlc_lib.Rhyme_core_unified.make_entry "测" Ping_sheng An_rhyme ()); true
     with _ -> false);
  
  check bool "find_rhyme_group_callable" true
    (try ignore (Yyocamlc_lib.Rhyme_core_unified.find_rhyme_group "测"); true
     with _ -> false);
     
  check bool "check_rhyme_match_callable" true
    (try ignore (Yyocamlc_lib.Rhyme_core_unified.check_rhyme_match "安" "干"); true
     with _ -> false);
     
  check bool "get_rhyme_score_callable" true
    (try ignore (Yyocamlc_lib.Rhyme_core_unified.get_rhyme_score "安" "干"); true
     with _ -> false)

let test_data_consistency () =
  (* 验证数据一致性，确保拆分时不丢失数据 *)
  let all_groups = Yyocamlc_lib.Rhyme_core_unified.get_all_rhyme_groups () in
  List.iter (fun group ->
    let chars = Yyocamlc_lib.Rhyme_core_unified.get_rhyme_characters group in
    check bool ("group_" ^ (string_of_int (Hashtbl.hash group)) ^ "_has_chars") 
      true (List.length chars > 0);
    
    (* 验证每个字符都能找到对应的韵组 *)
    List.iter (fun char ->
      match Yyocamlc_lib.Rhyme_core_unified.find_rhyme_group char with
      | Some found_group -> 
          check bool ("char_" ^ char ^ "_group_consistent") true (found_group = group)
      | None ->
          fail ("Character " ^ char ^ " should have rhyme group " ^ (string_of_int (Hashtbl.hash group)))
    ) (List.take (min 5 (List.length chars)) chars)  (* 测试前5个字符 *)
  ) all_groups

(** {9 测试套件定义} *)

let rhyme_core_unified_tests = [
  (* 基础功能测试 *)
  test_case "make_entry creates correct entry" `Quick test_make_entry;
  test_case "make_group_entries creates correct entries" `Quick test_make_group_entries;
  
  (* 数据访问测试 *)
  test_case "an_rhyme_data access" `Quick test_an_rhyme_data_access;
  test_case "feng_rhyme_data access" `Quick test_feng_rhyme_data_access;
  
  (* 查找功能测试 *)
  test_case "find_rhyme_group functionality" `Quick test_find_rhyme_group;
  test_case "get_rhyme_characters functionality" `Quick test_get_rhyme_characters;
  
  (* 匹配功能测试 *)
  test_case "check_rhyme_match functionality" `Quick test_check_rhyme_match;
  test_case "get_rhyme_score functionality" `Quick test_get_rhyme_score;
  
  (* 统计功能测试 *)
  test_case "get_all_rhyme_groups functionality" `Quick test_get_all_rhyme_groups;
  test_case "get_rhyme_group_stats functionality" `Quick test_get_rhyme_group_stats;
  
  (* 错误处理测试 *)
  test_case "empty string handling" `Quick test_empty_string_handling;
  test_case "invalid unicode handling" `Quick test_invalid_unicode_handling;
  test_case "very long string handling" `Quick test_very_long_string_handling;
  
  (* 性能测试 *)
  test_case "rhyme lookup performance" `Slow test_rhyme_lookup_performance;
  test_case "rhyme matching performance" `Slow test_rhyme_matching_performance;
  
  (* 模块拆分准备测试 *)
  test_case "current module interface" `Quick test_current_module_interface;
  test_case "data consistency" `Quick test_data_consistency;
]

(** 主测试运行器 *)
let () =
  run "Rhyme Core Unified Refactor Protection" [
    "rhyme_core_unified", rhyme_core_unified_tests;
  ]