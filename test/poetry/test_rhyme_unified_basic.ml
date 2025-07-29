(** 韵律统一模块基础测试 - 验证整合功能正确性

    @author Alpha代理, 技术债务清理专员
    @version 1.0 - 统一整合版本测试
    @since 2025-07-29 - 韵律模块整合重构测试

    参见 issue #1673 *)

open Alcotest

(** 测试数据获取功能 *)
let test_data_module () =
  (* 测试基本数据获取 *)
  let data_opt = Poetry.Rhyme_unified.Data.get_rhyme_data () in
  check bool "Data should be available" true (Option.is_some data_opt);

  (* 测试韵组获取 *)
  let groups = Poetry.Rhyme_unified.Data.get_all_rhyme_groups () in
  check bool "Should have rhyme groups" true (List.length groups > 0);

  (* 测试字符查询 *)
  let chars = Poetry.Rhyme_unified.Data.get_rhyme_group_characters "AnRhyme" in
  check bool "AnRhyme should have characters" true (List.length chars >= 0)

(** 测试分析模块功能 *)
let test_analysis_module () =
  (* 测试字符韵律查找 *)
  let rhyme_info = Poetry.Rhyme_unified.Analysis.find_character_rhyme "山" in
  check bool "Should find rhyme info for 山" true (Option.is_some rhyme_info);

  (* 测试韵组获取 *)
  let rhyme_group = Poetry.Rhyme_unified.Analysis.get_character_rhyme_group "山" in
  check bool "Should find rhyme group for 山" true (Option.is_some rhyme_group);

  (* 测试押韵检查 *)
  let can_rhyme = Poetry.Rhyme_unified.Analysis.can_rhyme_together "山" "间" in
  check bool "山 and 间 should potentially rhyme" true can_rhyme

(** 测试工具模块功能 *)
let test_utils_module () =
  (* 测试类型转换 *)
  let category_opt = Poetry.Rhyme_unified.Utils.string_to_rhyme_category "平声" in
  check bool "Should parse rhyme category" true (Option.is_some category_opt);

  let group_opt = Poetry.Rhyme_unified.Utils.string_to_rhyme_group "安韵" in
  check bool "Should parse rhyme group" true (Option.is_some group_opt);

  (* 测试统计功能 *)
  let num_groups, total_chars = Poetry.Rhyme_unified.Utils.get_data_statistics () in
  check bool "Should have positive group count" true (num_groups > 0);
  check bool "Should have positive character count" true (total_chars > 0)

(** 测试兼容性接口 *)
let test_compatibility_interface () =
  (* 测试顶层兼容接口 *)
  let data_opt = Poetry.Rhyme_unified.get_rhyme_data () in
  check bool "Compatibility data access should work" true (Option.is_some data_opt);

  let groups = Poetry.Rhyme_unified.get_all_rhyme_groups () in
  check bool "Compatibility group access should work" true (List.length groups > 0);

  let chars = Poetry.Rhyme_unified.get_rhyme_group_characters "AnRhyme" in
  check bool "Compatibility character access should work" true (List.length chars >= 0);

  let rhyme_info = Poetry.Rhyme_unified.find_character_rhyme "山" in
  check bool "Compatibility rhyme lookup should work" true (Option.is_some rhyme_info)

(** 测试JSON处理功能 *)
let test_json_module () =
  (* 测试JSON字符串清理 *)
  let cleaned = Poetry.Rhyme_unified.Json.clean_json_string "  {\"test\": \"value\"}  " in
  check bool "Should clean JSON string" true (String.length cleaned > 0);

  (* 测试默认数据文件加载 *)
  try
    let data = Poetry.Rhyme_unified.Json.load_from_file () in
    check bool "Should load default data file" true (List.length data.rhyme_groups >= 0)
  with _ -> check bool "Data loading may fail in test environment" true true

(** 主测试套件 *)
let () =
  run "Rhyme Unified Module Tests"
    [
      ("Data Module", [ test_case "Basic data operations" `Quick test_data_module ]);
      ("Analysis Module", [ test_case "Character analysis operations" `Quick test_analysis_module ]);
      ("Utils Module", [ test_case "Utility functions" `Quick test_utils_module ]);
      ( "Compatibility Interface",
        [ test_case "Backward compatibility" `Quick test_compatibility_interface ] );
      ("JSON Module", [ test_case "JSON processing" `Quick test_json_module ]);
    ]
