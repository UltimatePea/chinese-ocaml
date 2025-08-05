(** 统一韵律核心数据模块测试 - 修复版本

    这个测试模块验证修复后的韵律数据模块的正确性， 确保所有数据完整性问题都得到解决。

    Author: Charlie, 规划代理
    @version 2.0 - 修复版：响应Issue #1801质量问题
    @since 2025-07-30 - Fix #1801 系统性质量问题修复 *)

open OUnit2
open Poetry.Unified_rhyme_core_fixed
open Yyocamlc_lib.Poetry_core.Poetry_types

(** {1 数据完整性测试} *)

let test_no_duplicate_characters _ =
  let integrity_report = run_integrity_check () in
  assert_equal [] integrity_report.duplicate_characters ~printer:(String.concat "; ")
    ~msg:"应该没有重复字符"

let test_no_classification_errors _ =
  let integrity_report = run_integrity_check () in
  assert_equal [] integrity_report.classification_errors ~printer:(String.concat "; ")
    ~msg:"应该没有分类错误"

let test_integrity_status_pass _ =
  let integrity_report = run_integrity_check () in
  assert_equal "PASS" integrity_report.integrity_status ~msg:"数据完整性检查应该通过"

(** {1 性能测试} *)

let test_character_lookup_performance _ =
  (* 测试O(1)查找性能 *)
  let start_time = Sys.time () in
  for i = 1 to 10000 do
    ignore (find_character_rhyme "思");
    ignore (find_character_rhyme "安");
    ignore (find_character_rhyme "天")
  done;
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  assert_bool (Printf.sprintf "30000次查找耗时%.4fs，应该小于0.1s" duration) (duration < 0.1)

(** {1 功能正确性测试} *)

let test_find_character_rhyme_basic _ =
  (* 测试基本字符查找 *)
  assert_equal (Some (SiRhyme, PingSheng)) (find_character_rhyme "思") ~msg:"应该找到'思'字在思韵平声";
  assert_equal (Some (AnRhyme, PingSheng)) (find_character_rhyme "安") ~msg:"应该找到'安'字在安韵平声";
  assert_equal None (find_character_rhyme "不存在") ~msg:"不存在的字符应该返回None"

let test_are_rhyme_matched _ =
  (* 测试韵律匹配 *)
  assert_bool "同韵组字符应该匹配" (are_rhyme_matched "思" "丝");
  assert_bool "同韵组字符应该匹配" (are_rhyme_matched "安" "山");
  assert_bool "不同韵组字符不应该匹配" (not (are_rhyme_matched "思" "安"));
  assert_bool "不存在字符不应该匹配" (not (are_rhyme_matched "思" "不存在"))

let test_rhyme_group_data_access _ =
  (* 测试韵组数据访问 *)
  match get_rhyme_group_data SiRhyme with
  | Some data ->
      assert_bool "思韵组应该包含'思'字" (List.mem "思" data.ping_sheng_chars);
      assert_bool "思韵组应该包含'尽'字" (List.mem "尽" data.ze_sheng_chars)
  | None -> assert_failure "应该能找到思韵组数据"

(** {1 特定修复验证测试} *)

let test_an_rhyme_no_duplicates _ =
  (* 验证安韵组修复：无重复的"班"、"团"、"关" *)
  match get_rhyme_group_data AnRhyme with
  | Some data ->
      let count_char char list =
        List.fold_left (fun acc c -> if c = char then acc + 1 else acc) 0 list
      in
      assert_equal 1 (count_char "班" data.ping_sheng_chars) ~msg:"'班'字应该只出现一次";
      assert_equal 1 (count_char "团" data.ping_sheng_chars) ~msg:"'团'字应该只出现一次";
      assert_equal 1 (count_char "关" data.ping_sheng_chars) ~msg:"'关'字应该只出现一次"
  | None -> assert_failure "应该能找到安韵组数据"

let test_si_rhyme_proper_classification _ =
  (* 验证思韵组修复：ze_sheng和qu_sheng不再完全重复 *)
  match get_rhyme_group_data SiRhyme with
  | Some data ->
      let ze_set = List.sort_uniq String.compare data.ze_sheng_chars in
      let qu_set = List.sort_uniq String.compare data.qu_sheng_chars in
      assert_bool "ze_sheng和qu_sheng不应该完全相同" (ze_set <> qu_set);
      (* 验证一些预期的分类 *)
      assert_bool "ze_sheng应该包含'尽'" (List.mem "尽" data.ze_sheng_chars);
      assert_bool "qu_sheng应该包含'信'" (List.mem "信" data.qu_sheng_chars)
  | None -> assert_failure "应该能找到思韵组数据"

let test_jiang_wang_rhyme_distinction _ =
  (* 验证江韵组和王韵组的区分 *)
  match (get_rhyme_group_data JiangRhyme, get_rhyme_group_data WangRhyme) with
  | Some jiang_data, Some wang_data ->
      let jiang_chars = jiang_data.ping_sheng_chars in
      let wang_chars = wang_data.ping_sheng_chars in
      assert_bool "江韵组应该包含'江'" (List.mem "江" jiang_chars);
      assert_bool "王韵组应该包含'王'" (List.mem "王" wang_chars);
      (* 验证没有完全重复的内容 *)
      assert_bool "江韵组和王韵组不应该完全相同" (jiang_chars <> wang_chars)
  | _ -> assert_failure "应该能找到江韵组和王韵组数据"

(** {1 统计信息测试} *)

let test_statistics _ =
  let stats = get_statistics () in
  assert_bool "应该有合理数量的韵组" (stats.total_groups > 0);
  assert_bool "应该有合理数量的字符" (stats.total_characters > 100);
  assert_equal "O(1) 哈希表查找" stats.performance_info;
  assert_equal "已修复所有重复和分类错误" stats.data_integrity

let test_total_character_count _ =
  let count = get_total_character_count () in
  assert_bool "应该统计出合理的字符数量" (count > 100 && count < 2000);
  (* 验证与统计信息一致 *)
  let stats = get_statistics () in
  assert_equal stats.total_characters count

(** {1 边界条件测试} *)

let test_empty_string_lookup _ = assert_equal None (find_character_rhyme "") ~msg:"空字符串应该返回None"

let test_whitespace_lookup _ = assert_equal None (find_character_rhyme " ") ~msg:"空格字符应该返回None"

let test_special_characters _ =
  assert_equal None (find_character_rhyme "!") ~msg:"特殊字符应该返回None";
  assert_equal None (find_character_rhyme "123") ~msg:"数字应该返回None"

(** {1 回归测试} *)

let test_backward_compatibility _ =
  (* 确保修复后的API向后兼容 *)
  let test_chars = [ "思"; "安"; "天"; "风"; "鱼"; "华"; "江"; "月"; "回"; "秋" ] in
  List.iter
    (fun char ->
      match find_character_rhyme char with
      | Some (group, category) -> assert_bool (Printf.sprintf "字符'%s'应该能找到有效的韵组和声调" char) true
      | None -> assert_failure (Printf.sprintf "字符'%s'应该能找到韵组信息" char))
    test_chars

(** {1 测试套件} *)

let suite =
  "统一韵律核心数据模块测试（修复版）"
  >::: [
         (* 数据完整性测试 *)
         "test_no_duplicate_characters" >:: test_no_duplicate_characters;
         "test_no_classification_errors" >:: test_no_classification_errors;
         "test_integrity_status_pass" >:: test_integrity_status_pass;
         (* 性能测试 *)
         "test_character_lookup_performance" >:: test_character_lookup_performance;
         (* 功能正确性测试 *)
         "test_find_character_rhyme_basic" >:: test_find_character_rhyme_basic;
         "test_are_rhyme_matched" >:: test_are_rhyme_matched;
         "test_rhyme_group_data_access" >:: test_rhyme_group_data_access;
         (* 特定修复验证测试 *)
         "test_an_rhyme_no_duplicates" >:: test_an_rhyme_no_duplicates;
         "test_si_rhyme_proper_classification" >:: test_si_rhyme_proper_classification;
         "test_jiang_wang_rhyme_distinction" >:: test_jiang_wang_rhyme_distinction;
         (* 统计信息测试 *)
         "test_statistics" >:: test_statistics;
         "test_total_character_count" >:: test_total_character_count;
         (* 边界条件测试 *)
         "test_empty_string_lookup" >:: test_empty_string_lookup;
         "test_whitespace_lookup" >:: test_whitespace_lookup;
         "test_special_characters" >:: test_special_characters;
         (* 回归测试 *)
         "test_backward_compatibility" >:: test_backward_compatibility;
       ]

let () = run_test_tt_main suite
