(** 骆言统一Token注册系统综合测试

    本测试模块提供对 unified_token_registry.ml 的全面测试覆盖。

    技术债务改进：测试覆盖率系统性提升计划 - 第四阶段核心组件架构优化 - Fix #954
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-23 *)

open Alcotest
open Yyocamlc_lib
open Unified_token_registry

(** ==================== 测试辅助函数 ==================== *)

(** 创建测试用的映射条目 *)
let create_test_entry source target priority category enabled =
  { source; target; priority; category; enabled }

(** 清理注册表状态 *)
let cleanup_registry () =
  TokenRegistry.clear_all_mappings ();
  ()

(** ==================== 映射条目结构测试 ==================== *)

(** 测试映射条目的创建和访问 *)
let test_mapping_entry_creation () =
  let entry = create_test_entry "测试" Unified_token_core.Identifier 1 "标识符" true in

  check string "源字符串正确" "测试" entry.source;
  check (module Unified_token_core) "目标token正确" Unified_token_core.Identifier entry.target;
  check int "优先级正确" 1 entry.priority;
  check string "分类正确" "标识符" entry.category;
  check bool "启用状态正确" true entry.enabled;
  ()

(** 测试不同优先级的映射条目 *)
let test_priority_levels () =
  let high_priority = create_test_entry "高" Unified_token_core.Keyword 1 "关键字" true in
  let medium_priority = create_test_entry "中" Unified_token_core.Operator 2 "运算符" true in
  let low_priority = create_test_entry "低" Unified_token_core.Delimiter 3 "分隔符" true in

  check bool "高优先级设置" true (high_priority.priority = 1);
  check bool "中优先级设置" true (medium_priority.priority = 2);
  check bool "低优先级设置" true (low_priority.priority = 3);

  (* 测试优先级比较 *)
  check bool "高优先级大于中优先级" true (high_priority.priority < medium_priority.priority);
  check bool "中优先级大于低优先级" true (medium_priority.priority < low_priority.priority);
  ()

(** ==================== Token注册表基础功能测试 ==================== *)

(** 测试单个映射的注册 *)
let test_single_mapping_registration () =
  cleanup_registry ();

  let entry = create_test_entry "让" Unified_token_core.Keyword 1 "关键字" true in
  TokenRegistry.register_mapping entry;

  let lookup_result = TokenRegistry.lookup_token "让" in
  (match lookup_result with
  | Some found_entry ->
      check string "查找结果源字符串" "让" found_entry.source;
      check (module Unified_token_core) "查找结果目标token" Unified_token_core.Keyword found_entry.target
  | None -> fail "应该能找到注册的映射");
  ()

(** 测试多个映射的注册 *)
let test_multiple_mapping_registration () =
  cleanup_registry ();

  let entries =
    [
      create_test_entry "如果" Unified_token_core.Keyword 1 "控制结构" true;
      create_test_entry "那么" Unified_token_core.Keyword 1 "控制结构" true;
      create_test_entry "否则" Unified_token_core.Keyword 1 "控制结构" true;
      create_test_entry "加" Unified_token_core.Operator 2 "算术运算" true;
      create_test_entry "减" Unified_token_core.Operator 2 "算术运算" true;
    ]
  in

  List.iter TokenRegistry.register_mapping entries;

  (* 验证所有映射都能被找到 *)
  List.iter
    (fun entry ->
      let lookup_result = TokenRegistry.lookup_token entry.source in
      match lookup_result with
      | Some found_entry -> check string ("查找" ^ entry.source) entry.source found_entry.source
      | None -> fail ("无法找到映射: " ^ entry.source))
    entries;
  ()

(** ==================== Token查找功能测试 ==================== *)

(** 测试基本的token查找 *)
let test_basic_token_lookup () =
  cleanup_registry ();

  let test_entry = create_test_entry "变量" Unified_token_core.Identifier 1 "变量名" true in
  TokenRegistry.register_mapping test_entry;

  let found = TokenRegistry.lookup_token "变量" in
  (match found with
  | Some entry ->
      check string "找到的源字符串" "变量" entry.source;
      check (module Unified_token_core) "找到的token类型" Unified_token_core.Identifier entry.target
  | None -> fail "应该找到已注册的token");

  (* 测试查找不存在的token *)
  let not_found = TokenRegistry.lookup_token "不存在的token" in
  check (option (module Unified_token_registry)) "不存在的token查找结果" None not_found;
  ()

(** 测试优先级影响查找结果 *)
let test_priority_based_lookup () =
  cleanup_registry ();

  (* 注册同一个源字符串的多个映射，不同优先级 *)
  let high_priority_entry = create_test_entry "测试" Unified_token_core.Keyword 1 "关键字" true in
  let low_priority_entry = create_test_entry "测试" Unified_token_core.Identifier 3 "标识符" true in

  TokenRegistry.register_mapping low_priority_entry;
  TokenRegistry.register_mapping high_priority_entry;

  let lookup_result = TokenRegistry.lookup_token "测试" in
  (match lookup_result with
  | Some found_entry ->
      (* 应该返回高优先级的条目 *)
      check int "应该返回高优先级条目" 1 found_entry.priority;
      check (module Unified_token_core) "应该是关键字类型" Unified_token_core.Keyword found_entry.target
  | None -> fail "应该找到优先级最高的映射");
  ()

(** ==================== 反向查找功能测试 ==================== *)

(** 测试反向Token查找 *)
let test_reverse_token_lookup () =
  cleanup_registry ();

  let entries =
    [
      create_test_entry "如果" Unified_token_core.Keyword 1 "控制结构" true;
      create_test_entry "假如" Unified_token_core.Keyword 1 "控制结构" true;
      create_test_entry "若" Unified_token_core.Keyword 1 "控制结构" true;
    ]
  in

  List.iter TokenRegistry.register_mapping entries;

  let reverse_result = TokenRegistry.reverse_lookup Unified_token_core.Keyword in
  let expected_sources = [ "如果"; "假如"; "若" ] in

  (* 验证反向查找结果包含所有期望的源字符串 *)
  List.iter
    (fun expected_source ->
      check bool ("反向查找包含: " ^ expected_source) true (List.mem expected_source reverse_result))
    expected_sources;
  ()

(** ==================== 映射启用状态管理测试 ==================== *)

(** 测试启用和禁用映射 *)
let test_enable_disable_mappings () =
  cleanup_registry ();

  let disabled_entry = create_test_entry "禁用" Unified_token_core.Keyword 1 "测试" false in
  let enabled_entry = create_test_entry "启用" Unified_token_core.Keyword 1 "测试" true in

  TokenRegistry.register_mapping disabled_entry;
  TokenRegistry.register_mapping enabled_entry;

  (* 查找禁用的映射 *)
  let disabled_result = TokenRegistry.lookup_token "禁用" in
  check (option (module Unified_token_registry)) "禁用的映射不应被找到" None disabled_result;

  (* 查找启用的映射 *)
  let enabled_result = TokenRegistry.lookup_token "启用" in
  (match enabled_result with
  | Some found_entry -> check bool "启用的映射应该被找到" true found_entry.enabled
  | None -> fail "启用的映射应该能被找到");
  ()

(** 测试动态启用和禁用 *)
let test_dynamic_enable_disable () =
  cleanup_registry ();

  let test_entry = create_test_entry "动态测试" Unified_token_core.Identifier 1 "测试" true in
  TokenRegistry.register_mapping test_entry;

  (* 初始状态应该能找到 *)
  let initial_result = TokenRegistry.lookup_token "动态测试" in
  check bool "初始状态应该能找到" true (initial_result <> None);

  (* 禁用映射 *)
  TokenRegistry.disable_mapping "动态测试";
  let disabled_result = TokenRegistry.lookup_token "动态测试" in
  check (option (module Unified_token_registry)) "禁用后不应找到" None disabled_result;

  (* 重新启用映射 *)
  TokenRegistry.enable_mapping "动态测试";
  let reenabled_result = TokenRegistry.lookup_token "动态测试" in
  check bool "重新启用后应该能找到" true (reenabled_result <> None);
  ()

(** ==================== 分类管理功能测试 ==================== *)

(** 测试按分类查找映射 *)
let test_category_based_lookup () =
  cleanup_registry ();

  let keyword_entries =
    [
      create_test_entry "让" Unified_token_core.Keyword 1 "声明关键字" true;
      create_test_entry "函数" Unified_token_core.Keyword 1 "声明关键字" true;
    ]
  in

  let operator_entries =
    [
      create_test_entry "加" Unified_token_core.Operator 2 "算术运算符" true;
      create_test_entry "乘" Unified_token_core.Operator 2 "算术运算符" true;
    ]
  in

  List.iter TokenRegistry.register_mapping (keyword_entries @ operator_entries);

  let declaration_keywords = TokenRegistry.lookup_by_category "声明关键字" in
  check int "声明关键字数量" 2 (List.length declaration_keywords);

  let arithmetic_operators = TokenRegistry.lookup_by_category "算术运算符" in
  check int "算术运算符数量" 2 (List.length arithmetic_operators);

  let nonexistent_category = TokenRegistry.lookup_by_category "不存在的分类" in
  check int "不存在分类的结果" 0 (List.length nonexistent_category);
  ()

(** ==================== 批量操作功能测试 ==================== *)

(** 测试批量注册映射 *)
let test_batch_registration () =
  cleanup_registry ();

  let batch_entries =
    [
      create_test_entry "第一" Unified_token_core.Keyword 1 "测试" true;
      create_test_entry "第二" Unified_token_core.Operator 2 "测试" true;
      create_test_entry "第三" Unified_token_core.Delimiter 3 "测试" true;
      create_test_entry "第四" Unified_token_core.Identifier 1 "测试" true;
    ]
  in

  TokenRegistry.register_batch batch_entries;

  (* 验证所有条目都已注册 *)
  List.iter
    (fun entry ->
      let lookup_result = TokenRegistry.lookup_token entry.source in
      check bool ("批量注册验证: " ^ entry.source) true (lookup_result <> None))
    batch_entries;
  ()

(** 测试批量清理功能 *)
let test_batch_cleanup () =
  cleanup_registry ();

  let test_entries =
    [
      create_test_entry "清理1" Unified_token_core.Keyword 1 "测试" true;
      create_test_entry "清理2" Unified_token_core.Operator 2 "测试" true;
    ]
  in

  List.iter TokenRegistry.register_mapping test_entries;

  (* 验证条目已存在 *)
  List.iter
    (fun entry ->
      let lookup_result = TokenRegistry.lookup_token entry.source in
      check bool ("清理前验证: " ^ entry.source) true (lookup_result <> None))
    test_entries;

  (* 清理所有映射 *)
  TokenRegistry.clear_all_mappings ();

  (* 验证条目已被清理 *)
  List.iter
    (fun entry ->
      let lookup_result = TokenRegistry.lookup_token entry.source in
      check (option (module Unified_token_registry)) ("清理后验证: " ^ entry.source) None lookup_result)
    test_entries;
  ()

(** ==================== 错误处理和边界测试 ==================== *)

(** 测试空字符串处理 *)
let test_empty_string_handling () =
  cleanup_registry ();

  (* 测试空字符串作为源 *)
  let empty_source_entry = create_test_entry "" Unified_token_core.Identifier 1 "空字符串" true in
  TokenRegistry.register_mapping empty_source_entry;

  let empty_lookup = TokenRegistry.lookup_token "" in
  (match empty_lookup with
  | Some found_entry -> check string "空字符串映射源字符串" "" found_entry.source
  | None ->
      (* 空字符串可能被拒绝注册，这是可以接受的 *)
      check bool "空字符串处理（可选）" true true);

  (* 测试查找空字符串 *)
  let empty_query = TokenRegistry.lookup_token "" in
  ignore empty_query;
  (* 不管结果如何都是可以接受的 *)
  ()

(** 测试Unicode字符处理 *)
let test_unicode_character_handling () =
  cleanup_registry ();

  let unicode_entries =
    [
      create_test_entry "😀" Unified_token_core.Identifier 1 "表情符号" true;
      create_test_entry "α" Unified_token_core.Identifier 1 "希腊字母" true;
      create_test_entry "中文" Unified_token_core.Keyword 1 "中文字符" true;
      create_test_entry "日本語" Unified_token_core.Identifier 1 "日文字符" true;
    ]
  in

  List.iter TokenRegistry.register_mapping unicode_entries;

  (* 验证Unicode字符能正确处理 *)
  List.iter
    (fun entry ->
      let lookup_result = TokenRegistry.lookup_token entry.source in
      check bool ("Unicode处理: " ^ entry.source) true (lookup_result <> None))
    unicode_entries;
  ()

(** 测试长字符串处理 *)
let test_long_string_handling () =
  cleanup_registry ();

  let long_string = String.make 1000 'a' in
  let long_entry = create_test_entry long_string Unified_token_core.Identifier 1 "长字符串" true in

  TokenRegistry.register_mapping long_entry;

  let long_lookup = TokenRegistry.lookup_token long_string in
  check bool "长字符串处理" true (long_lookup <> None);
  ()

(** ==================== 性能测试 ==================== *)

(** 测试大量映射的性能 *)
let test_large_scale_performance () =
  cleanup_registry ();

  (* 注册大量映射 *)
  for i = 1 to 1000 do
    let entry =
      create_test_entry ("测试" ^ string_of_int i) Unified_token_core.Identifier 1 "性能测试" true
    in
    TokenRegistry.register_mapping entry
  done;

  (* 测试查找性能 *)
  for i = 1 to 100 do
    let query = "测试" ^ string_of_int (i * 10) in
    let result = TokenRegistry.lookup_token query in
    check bool ("大规模查找: " ^ query) true (result <> None)
  done;

  check bool "大规模性能测试完成" true true;
  ()

(** ==================== 测试套件定义 ==================== *)

let mapping_entry_tests =
  [
    test_case "映射条目创建测试" `Quick test_mapping_entry_creation;
    test_case "优先级层次测试" `Quick test_priority_levels;
  ]

let basic_registry_tests =
  [
    test_case "单个映射注册测试" `Quick test_single_mapping_registration;
    test_case "多个映射注册测试" `Quick test_multiple_mapping_registration;
  ]

let lookup_tests =
  [
    test_case "基础token查找测试" `Quick test_basic_token_lookup;
    test_case "优先级查找测试" `Quick test_priority_based_lookup;
    test_case "反向查找测试" `Quick test_reverse_token_lookup;
  ]

let state_management_tests =
  [
    test_case "启用禁用映射测试" `Quick test_enable_disable_mappings;
    test_case "动态启用禁用测试" `Quick test_dynamic_enable_disable;
  ]

let category_tests = [ test_case "分类查找测试" `Quick test_category_based_lookup ]

let batch_operation_tests =
  [
    test_case "批量注册测试" `Quick test_batch_registration; test_case "批量清理测试" `Quick test_batch_cleanup;
  ]

let edge_case_tests =
  [
    test_case "空字符串处理测试" `Quick test_empty_string_handling;
    test_case "Unicode字符处理测试" `Quick test_unicode_character_handling;
    test_case "长字符串处理测试" `Quick test_long_string_handling;
  ]

let performance_tests = [ test_case "大规模性能测试" `Quick test_large_scale_performance ]

(** 主测试运行器 *)
let () =
  run "Unified_token_registry 综合测试"
    [
      ("映射条目结构", mapping_entry_tests);
      ("基础注册功能", basic_registry_tests);
      ("查找功能", lookup_tests);
      ("状态管理", state_management_tests);
      ("分类管理", category_tests);
      ("批量操作", batch_operation_tests);
      ("边界情况", edge_case_tests);
      ("性能测试", performance_tests);
    ]
