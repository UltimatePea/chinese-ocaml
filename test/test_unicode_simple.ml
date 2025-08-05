(** Unicode字符处理增强功能简化测试

    验证核心Unicode功能的基本测试：
    - 中文字符识别
    - UTF-8字符计数
    - 字符分类功能

    Author: Whisky, PR Worker Issue: #1847 - Unicode字符处理优化

    @since 2025-07-31 *)

open Unicode.Unicode_constants_enhanced
open Unicode.Utf8_utils_enhanced

(** 基础功能测试 *)
let test_basic_functions () =
  Printf.printf "=== Unicode字符处理基础功能测试 ===\n";

  (* 测试中文标点符号识别 *)
  let punctuation_chars = [ "，"; "。"; "："; "；"; "（"; "）" ] in
  Printf.printf "\n1. 测试中文标点符号识别:\n";
  List.iter
    (fun char ->
      match UnifiedCharDefinitions.find_by_char char with
      | Some def -> Printf.printf "  字符 '%s': 类别=%s ✅\n" char def.category
      | None -> Printf.printf "  字符 '%s': 未找到定义 ❌\n" char)
    punctuation_chars;

  (* 测试UTF-8字符计数 *)
  Printf.printf "\n2. 测试UTF-8字符计数:\n";
  let test_strings = [ ("hello", 5); ("你好", 2); ("hello世界", 7) ] in
  List.iter
    (fun (input, expected) ->
      let actual = UTF8Processing.count_utf8_chars input in
      let result = if actual = expected then "✅" else "❌" in
      Printf.printf "  '%s': 期望=%d, 实际=%d %s\n" input expected actual result)
    test_strings;

  (* 测试字符分类 *)
  Printf.printf "\n3. 测试字符分类:\n";
  let test_chars = [ "一"; "，"; "→"; "『"; "◎" ] in
  List.iter
    (fun char ->
      let category = CharacterDetection.classify_unicode_char char in
      Printf.printf "  字符 '%s': 分类=%s\n" char category)
    test_chars;

  (* 测试性能统计 *)
  Printf.printf "\n4. 性能统计信息:\n";
  let total, by_category = Statistics.get_char_statistics () in
  Printf.printf "  总字符定义数: %d\n" total;
  Printf.printf "  各类别统计:\n";
  Hashtbl.iter (fun category count -> Printf.printf "    %s: %d个\n" category count) by_category;

  Printf.printf "\n✅ 基础功能测试完成！\n"

(** 中文编程示例测试 *)
let test_chinese_programming () =
  Printf.printf "\n=== 中文编程示例测试 ===\n";

  let examples = [ "让「变量」= 123"; "假如「条件」那么「执行」"; "输出『你好，世界！』" ] in

  List.iter
    (fun example ->
      Printf.printf "\n示例: %s\n" example;
      let char_list = UTF8Processing.utf8_string_to_char_list example in
      let char_count = List.length char_list in
      Printf.printf "  字符数: %d\n" char_count;

      (* 分析字符分布 *)
      let categories = List.map CharacterDetection.classify_unicode_char char_list in
      let category_counts = Hashtbl.create 8 in
      List.iter
        (fun category ->
          let count = try Hashtbl.find category_counts category with Not_found -> 0 in
          Hashtbl.replace category_counts category (count + 1))
        categories;

      Printf.printf "  字符类别分布: ";
      Hashtbl.iter (fun category count -> Printf.printf "%s(%d) " category count) category_counts;
      Printf.printf "\n")
    examples;

  Printf.printf "\n✅ 中文编程示例测试完成！\n"

(** 错误处理测试 *)
let test_error_handling () =
  Printf.printf "\n=== 错误处理测试 ===\n";

  (* 测试UTF-8验证 *)
  let test_strings = [ ("正常中文", "有效"); ("Mixed中英文", "有效") ] in

  List.iter
    (fun (input, expected_type) ->
      let errors = UTF8Processing.validate_utf8_string input in
      let is_valid = errors = [] in
      let result_type = if is_valid then "有效" else "无效" in
      let match_result = if result_type = expected_type then "✅" else "❌" in
      Printf.printf "  字符串 '%s': %s %s\n" input result_type match_result)
    test_strings;

  Printf.printf "\n✅ 错误处理测试完成！\n"

(** 主测试函数 *)
let run_tests () =
  Printf.printf "🧪 骆言Unicode字符处理增强功能测试\n";
  Printf.printf "=====================================\n";

  test_basic_functions ();
  test_chinese_programming ();
  test_error_handling ();

  Printf.printf "\n🎉 所有测试完成！\n";
  Printf.printf "\n📊 最终统计:\n";
  Statistics.print_statistics ()

(** 程序入口点 *)
let () = run_tests ()
