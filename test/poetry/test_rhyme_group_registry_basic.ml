(** 韵组注册表基础测试 - Issue #1773
    
    简化的韵组注册表测试，专注于核心功能验证：
    - 注册表基本操作
    - 韵组数据注册和检索
    - 基础统计功能
    
    @author Echo, 测试工程师代理
    @version 1.0 - 简化基础测试
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 Phase 2 *)

open Rhyme_groups_refactored.Rhyme_data_registry
open Rhyme_groups_refactored.Rhyme_group_builder
open Poetry_core.Types

(** {1 基础功能测试} *)

let test_registry_basic_operations () =
  (* 清理注册表 *)
  clear_registry ();

  (* 测试初始状态 *)
  let initial_count = get_registered_count () in
  Alcotest.(check int) "初始注册表应为空" 0 initial_count;

  (* 创建简单测试配置 *)
  let test_config =
    {
      group_type = AnRhyme;
      description = "测试安韵";
      ping_sheng_chars = [ "山"; "关" ];
      ze_sheng_chars = [ "产"; "满" ];
    }
  in

  (* 构建并注册韵组 *)
  let test_data = build_from_config test_config in
  register_rhyme_group test_data;

  (* 验证注册成功 *)
  let count_after_register = get_registered_count () in
  Alcotest.(check int) "注册后应有1个韵组" 1 count_after_register;

  (* 验证检索功能 *)
  let is_registered = is_registered AnRhyme in
  Alcotest.(check bool) "安韵应已注册" true is_registered;

  (* 验证数据检索 *)
  match get_rhyme_data_by_group AnRhyme with
  | Some data ->
      Alcotest.(check string) "韵组描述应匹配" "测试安韵" data.group_description;
      let entry_count = List.length data.entries in
      Alcotest.(check int) "应有4个数据条目" 4 entry_count
  | None -> Alcotest.fail "应能检索到韵组数据"

let test_multiple_rhyme_groups () =
  clear_registry ();

  (* 注册多个韵组 *)
  let configs =
    [
      {
        group_type = AnRhyme;
        description = "安韵";
        ping_sheng_chars = [ "山" ];
        ze_sheng_chars = [ "产" ];
      };
      {
        group_type = SiRhyme;
        description = "思韵";
        ping_sheng_chars = [ "思" ];
        ze_sheng_chars = [ "四" ];
      };
      {
        group_type = TianRhyme;
        description = "天韵";
        ping_sheng_chars = [ "天" ];
        ze_sheng_chars = [ "面" ];
      };
    ]
  in

  List.iter
    (fun config ->
      let data = build_from_config config in
      register_rhyme_group data)
    configs;

  (* 验证所有韵组已注册 *)
  let total_count = get_registered_count () in
  Alcotest.(check int) "应有3个韵组" 3 total_count;

  (* 验证各个韵组可检索 *)
  let all_registered = List.for_all (fun config -> is_registered config.group_type) configs in
  Alcotest.(check bool) "所有韵组应已注册" true all_registered

let test_registry_statistics () =
  clear_registry ();

  (* 注册测试韵组 *)
  let config =
    {
      group_type = WangRhyme;
      description = "王韵测试";
      ping_sheng_chars = [ "王"; "光" ];
      ze_sheng_chars = [ "望"; "亮"; "况" ];
    }
  in

  let data = build_from_config config in
  register_rhyme_group data;

  (* 验证统计功能 *)
  let total, _ping, _ze = get_rhyme_stats () in
  Alcotest.(check int) "总字符数应为5" 5 total

let test_duplicate_registration () =
  clear_registry ();

  (* 创建两个相同类型的韵组 *)
  let config1 =
    {
      group_type = QuRhyme;
      description = "第一个曲韵";
      ping_sheng_chars = [ "曲" ];
      ze_sheng_chars = [ "入" ];
    }
  in

  let config2 =
    {
      group_type = QuRhyme;
      description = "第二个曲韵";
      ping_sheng_chars = [ "局" ];
      ze_sheng_chars = [ "出" ];
    }
  in

  (* 注册第一个 *)
  register_rhyme_group (build_from_config config1);
  let count_after_first = get_registered_count () in
  Alcotest.(check int) "首次注册后应有1个韵组" 1 count_after_first;

  (* 注册第二个（相同类型） *)
  register_rhyme_group (build_from_config config2);
  let count_after_second = get_registered_count () in
  Alcotest.(check int) "重复注册后仍应有1个韵组" 1 count_after_second;

  (* 验证最后注册的被保留 *)
  match get_rhyme_data_by_group QuRhyme with
  | Some data -> Alcotest.(check string) "应保留最后注册的数据" "第二个曲韵" data.group_description
  | None -> Alcotest.fail "应能检索到韵组数据"

let test_registry_management () =
  clear_registry ();

  (* 注册一个韵组 *)
  let config =
    {
      group_type = YuRhyme;
      description = "鱼韵测试";
      ping_sheng_chars = [ "鱼" ];
      ze_sheng_chars = [ "语" ];
    }
  in

  register_rhyme_group (build_from_config config);

  (* 测试注销功能 *)
  let unregister_success = unregister_rhyme_group YuRhyme in
  Alcotest.(check bool) "注销已存在韵组应成功" true unregister_success;

  let count_after_unregister = get_registered_count () in
  Alcotest.(check int) "注销后应无韵组" 0 count_after_unregister;

  (* 测试注销不存在的韵组 *)
  let unregister_failure = unregister_rhyme_group UnknownRhyme in
  Alcotest.(check bool) "注销不存在韵组应失败" false unregister_failure

let test_safe_retrieval () =
  clear_registry ();

  (* 测试安全检索不存在的韵组 *)
  let safe_result = get_rhyme_data_by_group_safe UnknownRhyme in
  Alcotest.(check string) "安全检索应返回默认描述" "未知韵组" safe_result.group_description;

  (* 测试普通检索不存在的韵组 *)
  let normal_result = get_rhyme_data_by_group UnknownRhyme in
  Alcotest.(check bool) "普通检索不存在韵组应返回None" true (Option.is_none normal_result)

(** {1 测试套件} *)

let basic_tests =
  [
    ("注册表基本操作", `Quick, test_registry_basic_operations);
    ("多韵组注册", `Quick, test_multiple_rhyme_groups);
    ("注册表统计", `Quick, test_registry_statistics);
    ("重复注册处理", `Quick, test_duplicate_registration);
    ("注册表管理", `Quick, test_registry_management);
    ("安全检索", `Quick, test_safe_retrieval);
  ]

(** 主测试运行器 *)
let () = Alcotest.run "韵组注册表基础测试 - Issue #1773" [ ("基础功能", basic_tests) ]
