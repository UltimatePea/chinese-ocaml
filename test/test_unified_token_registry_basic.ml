(** 骆言统一Token注册系统基础测试

    本测试模块提供对 unified_token_registry.ml 的基础测试覆盖。

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
  TokenRegistry.clear ();
  ()

(** ==================== 基础功能测试 ==================== *)

(** 测试映射条目的创建 *)
let test_mapping_entry_creation () =
  let entry = create_test_entry "测试" (Unified_token_core.IdentifierToken "测试") 1 "标识符" true in

  check string "源字符串正确" "测试" entry.source;
  check int "优先级正确" 1 entry.priority;
  check string "分类正确" "标识符" entry.category;
  check bool "启用状态正确" true entry.enabled;
  ()

(** 测试单个映射的注册和查找 *)
let test_single_mapping_registration () =
  cleanup_registry ();

  let entry = create_test_entry "让" Unified_token_core.LetKeyword 1 "关键字" true in
  TokenRegistry.register_mapping entry;

  let lookup_result = TokenRegistry.find_mapping "让" in
  (match lookup_result with
  | Some found_entry ->
      check string "查找结果源字符串" "让" found_entry.source;
      check bool "查找结果启用状态" true found_entry.enabled
  | None -> fail "应该能找到注册的映射");
  ()

(** 测试多个映射的注册 *)
let test_multiple_mapping_registration () =
  cleanup_registry ();

  let entries =
    [
      create_test_entry "如果" Unified_token_core.LetKeyword 1 "控制结构" true;
      create_test_entry "那么" Unified_token_core.LetKeyword 1 "控制结构" true;
      create_test_entry "否则" Unified_token_core.LetKeyword 1 "控制结构" true;
    ]
  in

  List.iter TokenRegistry.register_mapping entries;

  (* 验证所有映射都能被找到 *)
  List.iter
    (fun entry ->
      let lookup_result = TokenRegistry.find_mapping entry.source in
      match lookup_result with
      | Some found_entry -> check string ("查找" ^ entry.source) entry.source found_entry.source
      | None -> fail ("无法找到映射: " ^ entry.source))
    entries;
  ()

(** 测试优先级影响查找结果 *)
let test_priority_based_lookup () =
  cleanup_registry ();

  (* 注册同一个源字符串的多个映射，不同优先级 *)
  let high_priority_entry = create_test_entry "测试" Unified_token_core.LetKeyword 1 "关键字" true in
  let low_priority_entry =
    create_test_entry "测试" (Unified_token_core.IdentifierToken "identifier") 3 "标识符" true
  in

  TokenRegistry.register_mapping low_priority_entry;
  TokenRegistry.register_mapping high_priority_entry;

  let lookup_result = TokenRegistry.find_mapping "测试" in
  (match lookup_result with
  | Some found_entry ->
      (* 应该返回高优先级的条目 *)
      check int "应该返回高优先级条目" 1 found_entry.priority
  | None -> fail "应该找到优先级最高的映射");
  ()

(** ==================== 状态管理测试 ==================== *)

(** 测试启用和禁用映射 *)
let test_enable_disable_mappings () =
  cleanup_registry ();

  let disabled_entry = create_test_entry "禁用" Unified_token_core.LetKeyword 1 "测试" false in
  let enabled_entry = create_test_entry "启用" Unified_token_core.LetKeyword 1 "测试" true in

  TokenRegistry.register_mapping disabled_entry;
  TokenRegistry.register_mapping enabled_entry;

  (* 查找禁用的映射应该返回None或者found_entry.enabled为false *)
  let disabled_result = TokenRegistry.find_mapping "禁用" in
  (match disabled_result with
  | None -> check bool "禁用的映射正确返回None" true true
  | Some found_entry -> check bool "禁用的映射状态正确" false found_entry.enabled);

  (* 查找启用的映射 *)
  let enabled_result = TokenRegistry.find_mapping "启用" in
  (match enabled_result with
  | Some found_entry -> check bool "启用的映射应该被找到" true found_entry.enabled
  | None -> fail "启用的映射应该能被找到");
  ()

(** ==================== 批量操作测试 ==================== *)

(** 测试批量注册映射 *)
let test_batch_registration () =
  cleanup_registry ();

  let batch_entries =
    [
      create_test_entry "第一" Unified_token_core.LetKeyword 1 "测试" true;
      create_test_entry "第二" (Unified_token_core.IdentifierToken "operator") 2 "测试" true;
      create_test_entry "第三" (Unified_token_core.IdentifierToken "delimiter") 3 "测试" true;
      create_test_entry "第四" (Unified_token_core.IdentifierToken "identifier") 1 "测试" true;
    ]
  in

  TokenRegistry.register_batch batch_entries;

  (* 验证所有条目都已注册 *)
  List.iter
    (fun entry ->
      let lookup_result = TokenRegistry.find_mapping entry.source in
      check bool ("批量注册验证: " ^ entry.source) true (lookup_result <> None))
    batch_entries;
  ()

(** 测试批量清理功能 *)
let test_batch_cleanup () =
  cleanup_registry ();

  let test_entries =
    [
      create_test_entry "清理1" Unified_token_core.LetKeyword 1 "测试" true;
      create_test_entry "清理2" (Unified_token_core.IdentifierToken "operator") 2 "测试" true;
    ]
  in

  List.iter TokenRegistry.register_mapping test_entries;

  (* 验证条目已存在 *)
  List.iter
    (fun entry ->
      let lookup_result = TokenRegistry.find_mapping entry.source in
      check bool ("清理前验证: " ^ entry.source) true (lookup_result <> None))
    test_entries;

  (* 清理所有映射 *)
  TokenRegistry.clear ();

  (* 验证条目已被清理 *)
  List.iter
    (fun entry ->
      let lookup_result = TokenRegistry.find_mapping entry.source in
      check bool ("清理后验证: " ^ entry.source) true (lookup_result = None))
    test_entries;
  ()

(** ==================== 边界情况测试 ==================== *)

(** 测试空字符串处理 *)
let test_empty_string_handling () =
  cleanup_registry ();

  (* 测试空字符串作为源 *)
  let empty_source_entry =
    create_test_entry "" (Unified_token_core.IdentifierToken "identifier") 1 "空字符串" true
  in
  TokenRegistry.register_mapping empty_source_entry;

  let empty_query = TokenRegistry.find_mapping "" in
  (* 不管结果如何都是可以接受的，只要不崩溃 *)
  ignore empty_query;
  check bool "空字符串处理不崩溃" true true;
  ()

(** 测试长字符串处理 *)
let test_long_string_handling () =
  cleanup_registry ();

  let long_string = String.make 100 'a' in
  let long_entry =
    create_test_entry long_string (Unified_token_core.IdentifierToken "identifier") 1 "长字符串" true
  in

  TokenRegistry.register_mapping long_entry;

  let long_lookup = TokenRegistry.find_mapping long_string in
  check bool "长字符串处理" true (long_lookup <> None);
  ()

(** ==================== 性能测试 ==================== *)

(** 测试大量映射的稳定性 *)
let test_large_scale_stability () =
  cleanup_registry ();

  (* 注册多个映射 *)
  for i = 1 to 50 do
    let entry =
      create_test_entry
        ("测试" ^ string_of_int i)
        (Unified_token_core.IdentifierToken "identifier") 1 "性能测试" true
    in
    TokenRegistry.register_mapping entry
  done;

  (* 测试查找稳定性 *)
  for i = 1 to 10 do
    let query = "测试" ^ string_of_int (i * 5) in
    let result = TokenRegistry.find_mapping query in
    check bool ("大规模查找: " ^ query) true (result <> None)
  done;

  check bool "大规模稳定性测试完成" true true;
  ()

(** ==================== 测试套件定义 ==================== *)

let basic_functionality_tests =
  [
    test_case "映射条目创建测试" `Quick test_mapping_entry_creation;
    test_case "单个映射注册测试" `Quick test_single_mapping_registration;
    test_case "多个映射注册测试" `Quick test_multiple_mapping_registration;
    test_case "优先级查找测试" `Quick test_priority_based_lookup;
  ]

let state_management_tests = [ test_case "启用禁用映射测试" `Quick test_enable_disable_mappings ]

let batch_operation_tests =
  [
    test_case "批量注册测试" `Quick test_batch_registration; test_case "批量清理测试" `Quick test_batch_cleanup;
  ]

let edge_case_tests =
  [
    test_case "空字符串处理测试" `Quick test_empty_string_handling;
    test_case "长字符串处理测试" `Quick test_long_string_handling;
  ]

let performance_tests = [ test_case "大规模稳定性测试" `Quick test_large_scale_stability ]

(** 主测试运行器 *)
let () =
  run "Unified_token_registry 基础测试"
    [
      ("基础功能", basic_functionality_tests);
      ("状态管理", state_management_tests);
      ("批量操作", batch_operation_tests);
      ("边界情况", edge_case_tests);
      ("性能测试", performance_tests);
    ]
