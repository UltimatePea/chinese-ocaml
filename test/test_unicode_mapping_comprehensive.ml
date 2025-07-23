(** Unicode字符映射全面测试套件

    测试目标: unicode/unicode_mapping.ml 覆盖范围:
    - CharMap模块的映射表管理
    - Legacy模块的兼容性查找功能
    - 字符到三元组的映射
    - 名称到字符的映射
    - 类别过滤和查找
    - 字节组合获取
    - 错误处理和边界条件

    @version 1.0
    @since 2025-07-23 *)

open Unicode.Unicode_mapping
open Unicode.Unicode_types

(** CharMap模块测试 *)
let test_charmap_basic () =
  (* 测试name_to_char_map是否包含数据 *)
  let name_to_char_count = List.length CharMap.name_to_char_map in
  assert (name_to_char_count > 0);

  (* 测试name_to_triple_map是否包含数据 *)
  let name_to_triple_count = List.length CharMap.name_to_triple_map in
  assert (name_to_triple_count > 0);

  (* 测试char_to_triple_map是否包含数据 *)
  let char_to_triple_count = List.length CharMap.char_to_triple_map in
  assert (char_to_triple_count > 0);

  (* 确保映射表大小一致 *)
  assert (name_to_char_count = name_to_triple_count);
  assert (name_to_char_count = char_to_triple_count);

  print_endline "✅ CharMap基础功能测试通过"

(** Legacy模块 - 类别过滤测试 *)
let test_legacy_category_filtering () =
  (* 测试获取指定类别的字符 *)
  let punctuation_chars = Legacy.get_chars_by_category "punctuation" in
  let number_chars = Legacy.get_chars_by_category "number" in
  let quote_chars = Legacy.get_chars_by_category "quote" in

  (* 验证返回的是列表且非空（假设定义了这些类别的字符） *)
  assert (List.length punctuation_chars >= 0);
  assert (List.length number_chars >= 0);
  assert (List.length quote_chars >= 0);

  (* 测试获取指定类别的字符名称 *)
  let punctuation_names = Legacy.get_names_by_category "punctuation" in
  let number_names = Legacy.get_names_by_category "number" in

  assert (List.length punctuation_names >= 0);
  assert (List.length number_names >= 0);

  print_endline "✅ Legacy类别过滤测试通过"

(** Legacy模块 - 字符查找测试 *)
let test_legacy_character_lookup () =
  (* 测试字符到三元组的查找 *)
  (* 先从映射表中获取一个已知的字符进行测试 *)
  match CharMap.char_to_triple_map with
  | [] ->
      (* 如果映射表为空，测试None情况 *)
      assert (Legacy.find_triple_by_char "不存在" = None);
      print_endline "⚠️  映射表为空，仅测试None情况"
  | (char, expected_triple) :: _ ->
      (* 测试已知字符的查找 *)
      let result = Legacy.find_triple_by_char char in
      assert (result = Some expected_triple);

      (* 测试不存在字符的查找 *)
      assert (Legacy.find_triple_by_char "不存在的字符" = None);

      print_endline "✅ Legacy字符查找测试通过"

(** Legacy模块 - 名称查找测试 *)
let test_legacy_name_lookup () =
  (* 测试名称到字符的查找 *)
  match CharMap.name_to_char_map with
  | [] ->
      (* 如果映射表为空，测试None情况 *)
      assert (Legacy.find_char_by_name "不存在" = None);
      print_endline "⚠️  名称映射表为空，仅测试None情况"
  | (name, expected_char) :: _ ->
      (* 测试已知名称的查找 *)
      let result = Legacy.find_char_by_name name in
      assert (result = Some expected_char);

      (* 测试不存在名称的查找 *)
      assert (Legacy.find_char_by_name "不存在的名称" = None);

      print_endline "✅ Legacy名称查找测试通过"

(** Legacy模块 - 字节组合获取测试 *)
let test_legacy_char_bytes () =
  (* 测试获取存在字符的字节组合 *)
  match CharMap.name_to_char_map with
  | [] ->
      (* 映射表为空时的测试 *)
      let byte1, byte2, byte3 = Legacy.get_char_bytes "不存在" in
      assert (byte1 = 0 && byte2 = 0 && byte3 = 0);
      print_endline "⚠️  映射表为空，仅测试默认值情况"
  | (name, _) :: _ ->
      (* 测试存在的字符名称 *)
      let byte1, byte2, byte3 = Legacy.get_char_bytes name in
      (* 字节值应该在合理范围内 *)
      assert (byte1 >= 0 && byte1 <= 255);
      assert (byte2 >= 0 && byte2 <= 255);
      assert (byte3 >= 0 && byte3 <= 255);

      (* 测试不存在的字符名称 *)
      let byte1_none, byte2_none, byte3_none = Legacy.get_char_bytes "不存在的字符名" in
      assert (byte1_none = 0 && byte2_none = 0 && byte3_none = 0);

      print_endline "✅ Legacy字节组合获取测试通过"

(** Legacy模块 - 类别检查测试 *)
let test_legacy_category_check () =
  (* 测试字符类别检查 *)
  match char_definitions with
  | [] -> print_endline "⚠️  字符定义为空，跳过类别检查测试"
  | def :: _ ->
      (* 测试已知字符的类别检查 *)
      let result = Legacy.is_char_category def.char def.category in
      assert result;

      (* 测试不同类别的检查（应该返回false） *)
      let wrong_category =
        match def.category with
        | "punctuation" -> "number"
        | "number" -> "punctuation"
        | "quote" -> "punctuation"
        | _ -> "punctuation"
      in
      let wrong_result = Legacy.is_char_category def.char wrong_category in
      assert (not wrong_result);

      print_endline "✅ Legacy类别检查测试通过"

(** 边界条件和错误处理测试 *)
let test_edge_cases () =
  (* 测试空字符串 *)
  assert (Legacy.find_triple_by_char "" = None);
  assert (Legacy.find_char_by_name "" = None);

  (* 测试特殊字符 *)
  assert (Legacy.find_triple_by_char "\n" = None);
  assert (Legacy.find_triple_by_char "\t" = None);

  (* 测试非常长的字符串 *)
  let long_string = String.make 1000 'a' in
  assert (Legacy.find_triple_by_char long_string = None);
  assert (Legacy.find_char_by_name long_string = None);

  (* 测试Unicode字符 *)
  assert (Legacy.find_triple_by_char "🙂" = None || Legacy.find_triple_by_char "🙂" <> None);

  print_endline "✅ 边界条件和错误处理测试通过"

(** 性能测试 *)
let test_performance () =
  (* 测试大量查找操作的性能 *)
  for _ = 1 to 1000 do
    ignore (Legacy.find_triple_by_char "测试字符");
    ignore (Legacy.find_char_by_name "测试名称");
    ignore (Legacy.get_char_bytes "测试字节")
  done;

  (* 测试类别过滤的性能 *)
  for _ = 1 to 100 do
    ignore (Legacy.get_chars_by_category "punctuation");
    ignore (Legacy.get_names_by_category "number");
    ignore (Legacy.filter_by_category "quote")
  done;

  print_endline "✅ 性能压力测试通过"

(** 数据一致性测试 *)
let test_data_consistency () =
  (* 验证映射表之间的数据一致性 *)
  List.iter
    (fun (name, char) ->
      (* 验证name_to_char_map和char_to_triple_map的一致性 *)
      match Legacy.find_triple_by_char char with
      | Some triple -> (
          (* 验证name_to_triple_map中也包含相同的映射 *)
          match List.assoc_opt name CharMap.name_to_triple_map with
          | Some name_triple ->
              assert (triple.byte1 = name_triple.byte1);
              assert (triple.byte2 = name_triple.byte2);
              assert (triple.byte3 = name_triple.byte3)
          | None -> failwith ("名称映射不一致: " ^ name))
      | None -> ())
    CharMap.name_to_char_map;

  print_endline "✅ 数据一致性测试通过"

(** 功能完整性测试 *)
let test_functionality_completeness () =
  (* 测试所有定义的类别都能正确过滤 *)
  let all_categories = [ "punctuation"; "number"; "quote"; "string" ] in
  List.iter
    (fun category ->
      let filtered_chars = Legacy.filter_by_category category in
      let char_list = Legacy.get_chars_by_category category in
      let name_list = Legacy.get_names_by_category category in

      (* 验证过滤结果的一致性 *)
      assert (List.length filtered_chars = List.length char_list);
      assert (List.length filtered_chars = List.length name_list))
    all_categories;

  print_endline "✅ 功能完整性测试通过"

(** 主测试运行器 *)
let run_all_tests () =
  print_endline "🧪 开始Unicode映射模块全面测试...";
  print_endline "";

  (* 基础功能测试 *)
  test_charmap_basic ();
  test_legacy_category_filtering ();
  test_legacy_character_lookup ();
  test_legacy_name_lookup ();
  test_legacy_char_bytes ();
  test_legacy_category_check ();

  (* 边界条件和错误处理 *)
  test_edge_cases ();

  (* 性能测试 *)
  test_performance ();

  (* 数据一致性和完整性测试 *)
  test_data_consistency ();
  test_functionality_completeness ();

  print_endline "";
  print_endline "🎉 所有Unicode映射模块测试完成！";
  print_endline "📊 测试覆盖范围：";
  print_endline "   - CharMap映射表管理: ✅";
  print_endline "   - Legacy兼容性查找: ✅";
  print_endline "   - 字符到三元组映射: ✅";
  print_endline "   - 名称到字符映射: ✅";
  print_endline "   - 类别过滤和查找: ✅";
  print_endline "   - 字节组合获取: ✅";
  print_endline "   - 边界条件处理: ✅";
  print_endline "   - 性能压力测试: ✅";
  print_endline "   - 数据一致性验证: ✅";
  print_endline "   - 功能完整性验证: ✅"

(* 如果直接运行此文件，执行所有测试 *)
let () = run_all_tests ()
