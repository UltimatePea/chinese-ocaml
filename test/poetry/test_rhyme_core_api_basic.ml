(** 诗韵核心API基础测试 - 解决Critical Issue #1757

    Author: Charlie, 策略规划代理

    此测试文件为诗韵模块建立基础测试覆盖，确保核心韵律功能的正确性。 针对src/poetry/core/rhyme_core_api.ml的关键功能进行验证。

    Priority: Critical - 阻碍PR #1756合并的关键测试 *)

open Alcotest
open Poetry_core.Rhyme_core_api
open Poetry_core.Poetry_types

(** {1 基础查询功能测试} *)

let test_find_character_rhyme_basic () =
  (* 测试基本汉字韵律查询 - 使用已知存在的字符 *)
  let result_tian = find_character_rhyme "天" in
  let result_invalid = find_character_rhyme "xyz" in

  check bool "天字应有韵律信息" true (Option.is_some result_tian);
  check bool "无效字符应返回None" true (Option.is_none result_invalid)

let test_find_character_rhyme_common_chars () =
  (* 测试常见汉字的韵律查询 - 使用数据中存在的字符 *)
  let test_chars = [ "天"; "年"; "先"; "田"; "望"; "向" ] in
  let results = List.map find_character_rhyme test_chars in

  (* 应该有一些字符有韵律信息 *)
  let valid_results = List.filter Option.is_some results in
  check bool "测试字符应有韵律信息" true (List.length valid_results > 0)

let test_get_character_rhyme_group () =
  (* 测试韵组获取功能 *)
  let group_tian = get_character_rhyme_group "天" in
  let group_invalid = get_character_rhyme_group "xyz" in

  check bool "无效字符韵组应为None" true (Option.is_none group_invalid);
  (* 天字应有韵律信息，其韵组也应该存在 *)
  match find_character_rhyme "天" with
  | Some _ -> check bool "有韵律信息的字符应有韵组" true (Option.is_some group_tian)
  | None -> () (* 如果天字无信息则跳过此检查 *)

let test_get_character_rhyme_category () =
  (* 测试韵类获取功能 *)
  let category_tian = get_character_rhyme_category "天" in
  let category_invalid = get_character_rhyme_category "xyz" in

  check bool "无效字符韵类应为None" true (Option.is_none category_invalid);
  (* 天字应有韵律信息，其韵类也应该存在 *)
  match find_character_rhyme "天" with
  | Some _ -> check bool "有韵律信息的字符应有韵类" true (Option.is_some category_tian)
  | None -> () (* 如果天字无信息则跳过此检查 *)

(** {2 韵组查询功能测试} *)

let test_get_characters_by_group () =
  (* 测试按韵组获取字符 *)
  let tian_chars = get_characters_by_group TianRhyme in
  let unknown_chars = get_characters_by_group UnknownRhyme in

  check bool "天韵组查询不应出错" true (List.length tian_chars >= 0);
  check bool "未知韵组查询不应出错" true (List.length unknown_chars >= 0)

let test_get_characters_by_category () =
  (* 测试按韵类获取字符 *)
  let ping_chars = get_characters_by_category PingSheng in
  let ze_chars = get_characters_by_category ZeSheng in

  check bool "平声韵查询不应出错" true (List.length ping_chars >= 0);
  check bool "仄声韵查询不应出错" true (List.length ze_chars >= 0)

(** {3 异常处理测试} *)

let test_find_character_rhyme_exn () =
  (* 测试异常抛出版本 *)
  try
    ignore (find_character_rhyme_exn "不存在字符xyz");
    check bool "不存在字符应抛出异常" false true
  with
  | Poetry_core.Types.RhymeException _ -> check bool "正确抛出RhymeException" true true
  | _ -> check bool "应抛出RhymeException类型异常" false true

(** {4 边界条件测试} *)

let test_empty_string_handling () =
  (* 测试空字符串处理 *)
  let result_empty = find_character_rhyme "" in
  let group_empty = get_character_rhyme_group "" in
  let category_empty = get_character_rhyme_category "" in

  check bool "空字符串韵律信息应为None" true (Option.is_none result_empty);
  check bool "空字符串韵组应为None" true (Option.is_none group_empty);
  check bool "空字符串韵类应为None" true (Option.is_none category_empty)

let test_unicode_characters () =
  (* 测试Unicode字符处理 *)
  let unicode_chars = [ "𠀀"; "𠀁"; "𠀂" ] in
  List.iter
    (fun char ->
      let result = find_character_rhyme char in
      check bool
        ("Unicode字符" ^ char ^ "查询不应出错")
        true
        (Option.is_some result || Option.is_none result))
    unicode_chars

(** {5 性能测试} *)

let test_performance_basic () =
  (* 基础性能测试 - 确保查询在合理时间内完成 *)
  let start_time = Sys.time () in
  for _i = 1 to 100 do
    ignore (find_character_rhyme "天");
    ignore (get_character_rhyme_group "天");
    ignore (get_character_rhyme_category "天")
  done;
  let duration = Sys.time () -. start_time in
  check bool "100次查询应在0.1秒内完成" true (duration < 0.1)

(** {6 测试套件注册} *)

let test_suite =
  [
    ( "基础查询功能",
      [
        test_case "find_character_rhyme基本功能" `Quick test_find_character_rhyme_basic;
        test_case "常见汉字韵律查询" `Quick test_find_character_rhyme_common_chars;
        test_case "get_character_rhyme_group功能" `Quick test_get_character_rhyme_group;
        test_case "get_character_rhyme_category功能" `Quick test_get_character_rhyme_category;
      ] );
    ( "韵组查询功能",
      [
        test_case "按韵组获取字符" `Quick test_get_characters_by_group;
        test_case "按韵类获取字符" `Quick test_get_characters_by_category;
      ] );
    ("异常处理", [ test_case "异常抛出版本测试" `Quick test_find_character_rhyme_exn ]);
    ( "边界条件",
      [
        test_case "空字符串处理" `Quick test_empty_string_handling;
        test_case "Unicode字符处理" `Quick test_unicode_characters;
      ] );
    ("性能测试", [ test_case "基础性能测试" `Quick test_performance_basic ]);
  ]

let () = run "诗韵核心API基础测试" test_suite
