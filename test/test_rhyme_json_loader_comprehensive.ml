(** 韵律JSON加载器全面测试模块 - Phase 25 测试覆盖率提升

    本测试模块专门针对 poetry/rhyme_json_loader.ml 进行深度测试， 覆盖所有关键功能包括数据加载、错误处理、性能验证。

    测试覆盖范围：
    - JSON数据解析和验证
    - 韵律数据结构完整性
    - 错误处理和降级机制
    - 性能和内存使用
    - Unicode字符支持
    - 边界条件处理

    @author 骆言技术债务清理团队 - Phase 25
    @version 1.0
    @since 2025-07-20 Issue #678 核心模块测试覆盖率提升 *)

open Alcotest
open Poetry.Rhyme_json_loader

(** 测试数据和消息格式化模块 - 统一JSON加载器测试格式 *)
module Internal_formatter = struct
  let json_group_template i chars = Printf.sprintf {|"group_%d": {"category": "平声", "characters": %s}|} i chars
  let char_template i j = Printf.sprintf "\"%s\"" (Printf.sprintf "字%d_%d" i j)
  let json_parse_failure msg = Printf.sprintf "JSON解析失败: %s" msg
  let unexpected_exception exn = Printf.sprintf "意外异常: %s" (Printexc.to_string exn)
  let empty_json_failure exn = Printf.sprintf "空JSON处理失败: %s" (Printexc.to_string exn)
  let error_type_mismatch exn = Printf.sprintf "错误类型不匹配: %s" (Printexc.to_string exn)
  let should_produce_error desc = Printf.sprintf "%s 应该产生错误" desc
  let wrong_error_type desc exn = Printf.sprintf "%s 错误类型不正确: %s" desc (Printexc.to_string exn)
  let structure_validation_failure exn = Printf.sprintf "韵组结构验证失败: %s" (Printexc.to_string exn)
  let classification_test_failure exn = Printf.sprintf "韵类分类测试失败: %s" (Printexc.to_string exn)
  let uniqueness_test_failure exn = Printf.sprintf "字符唯一性测试失败: %s" (Printexc.to_string exn)
  let character_found_message char = Printf.sprintf "找到字符 %s" char
  let character_should_exist char = Printf.sprintf "字符 %s 应该存在" char
  let character_should_not_exist char = Printf.sprintf "字符 %s 不应该存在" char
  let character_rhyme_group char = Printf.sprintf "字符 %s 应属于鱼韵" char
  let rhyme_match_message char1 char2 should_match = 
    Printf.sprintf "%s 和 %s %s" char1 char2 (if should_match then "应该押韵" else "不应该押韵")
  let unicode_processing_message char = Printf.sprintf "Unicode字符 %s 被正确处理" char
  let unicode_test_failure exn = Printf.sprintf "Unicode测试失败: %s" (Printexc.to_string exn)
  let simplified_recognition simp = Printf.sprintf "简体字 %s 被识别" simp
  let traditional_recognition trad = Printf.sprintf "繁体字 %s 被识别" trad
  let traditional_simplified_failure exn = Printf.sprintf "繁简字符测试失败: %s" (Printexc.to_string exn)
  let large_data_failure exn = Printf.sprintf "大规模数据测试失败: %s" (Printexc.to_string exn)
  let query_performance_failure exn = Printf.sprintf "查询性能测试失败: %s" (Printexc.to_string exn)
  let memory_usage_failure exn = Printf.sprintf "内存使用测试失败: %s" (Printexc.to_string exn)
  let long_name_failure exn = Printf.sprintf "长字符名测试失败: %s" (Printexc.to_string exn)
  let special_char_failure exn = Printf.sprintf "特殊字符测试失败: %s" (Printexc.to_string exn)
  let error_recovery_failure exn = Printf.sprintf "错误恢复失败: %s" (Printexc.to_string exn)
  let long_rhyme_group_template i = 
    Printf.sprintf "looooooooooooooooooooooong_group_name_%d_with_many_characters_and_complex_structure" i
  let long_char_test_data long_char = 
    Printf.sprintf
      {|
    {
      "rhyme_groups": {
        "test": {
          "category": "平声",
          "characters": ["%s"]
        }
      }
    }
    |}
      long_char
end

(** 测试用的简单JSON数据 *)
let sample_rhyme_data =
  {|
{
  "rhyme_groups": {
    "fish_rhyme": {
      "category": "平声",
      "characters": ["鱼", "书", "居", "虚"]
    },
    "flower_rhyme": {
      "category": "平声", 
      "characters": ["花", "家", "沙", "茶"]
    },
    "moon_rhyme": {
      "category": "仄声",
      "characters": ["月", "雪", "节", "别"]
    }
  }
}
|}

(** 测试用的空JSON数据 *)
let empty_rhyme_data = {|
{
  "rhyme_groups": {}
}
|}

(** 测试用的无效JSON数据 *)
let invalid_json_data =
  {|
{
  "rhyme_groups": {
    "fish_rhyme": {
      // 缺少category字段
      "characters": ["鱼", "书"]
    }
  }
}
|}

(** 测试用的大规模数据 *)
let large_rhyme_data =
  {|
{
  "rhyme_groups": {
|}
  ^ String.concat ","
      (List.init 100 (fun i ->
           Internal_formatter.json_group_template i
             (String.concat ","
                (List.map (fun j -> Internal_formatter.char_template i j) (List.init 10 (fun j -> j))))))
  ^ {|
  }
}
|}

(** JSON解析功能测试 *)
module JsonParsingTests = struct
  (** 测试基本JSON解析 *)
  let test_basic_json_parsing () =
    try
      let data = parse_rhyme_json sample_rhyme_data in
      check bool "JSON解析成功" true true;
      (* 验证解析结果不为空 *)
      check bool "解析结果非空" true (data <> [])
    with
    | Json_parse_error msg -> fail (Internal_formatter.json_parse_failure msg)
    | exn -> fail (Internal_formatter.unexpected_exception (Printexc.to_string exn))

  (** 测试空JSON处理 *)
  let test_empty_json_handling () =
    try
      let data = parse_rhyme_json empty_rhyme_data in
      check bool "空JSON解析成功" true true;
      check int "空数据长度" 0 (List.length data)
    with exn -> fail (Internal_formatter.empty_json_failure (Printexc.to_string exn))

  (** 测试无效JSON错误处理 *)
  let test_invalid_json_error_handling () =
    try
      let _ = parse_rhyme_json invalid_json_data in
      fail "应该检测到无效JSON"
    with
    | Json_parse_error _ -> check bool "正确检测到JSON错误" true true
    | exn -> fail (Internal_formatter.error_type_mismatch (Printexc.to_string exn))

  (** 测试格式错误的JSON *)
  let test_malformed_json () =
    let malformed_cases =
      [ ("{", "不完整的JSON"); ("invalid json", "无效的JSON语法"); ("{\"key\"}", "缺少值的JSON"); ("", "空字符串") ]
    in
    List.iter
      (fun (json, desc) ->
        try
          let _ = parse_rhyme_json json in
          fail (Internal_formatter.should_produce_error desc)
        with
        | Json_parse_error _ -> ()
        | exn -> fail (Internal_formatter.wrong_error_type desc (Printexc.to_string exn)))
      malformed_cases
end

(** 韵律数据验证测试 *)
module RhymeDataValidationTests = struct
  (** 测试韵组数据结构 *)
  let test_rhyme_group_structure () =
    try
      let data = parse_rhyme_json sample_rhyme_data in
      (* 验证数据不为空 *)
      check bool "韵组数据非空" true (List.length data > 0);

      (* 验证每个韵组都有必要字段 *)
      List.iter
        (fun group_data ->
          check bool "韵组有category" true (group_data.category <> "");
          check bool "韵组有characters" true (List.length group_data.characters > 0))
        data
    with exn -> fail (Internal_formatter.structure_validation_failure (Printexc.to_string exn))

  (** 测试韵类分类 *)
  let test_rhyme_category_classification () =
    try
      let data = parse_rhyme_json sample_rhyme_data in
      let categories = List.map (fun d -> d.category) data in
      let unique_categories = List.sort_uniq String.compare categories in

      (* 验证有平声和仄声分类 *)
      check bool "包含平声分类" true (List.mem "平声" unique_categories);
      check bool "包含仄声分类" true (List.mem "仄声" unique_categories)
    with exn -> fail (Internal_formatter.classification_test_failure (Printexc.to_string exn))

  (** 测试字符唯一性 *)
  let test_character_uniqueness () =
    try
      let data = parse_rhyme_json sample_rhyme_data in
      let all_chars = List.concat (List.map (fun d -> d.characters) data) in
      let unique_chars = List.sort_uniq String.compare all_chars in

      (* 检查字符重复 *)
      check bool "字符无重复" true (List.length all_chars = List.length unique_chars)
    with exn -> fail (Internal_formatter.uniqueness_test_failure (Printexc.to_string exn))
end

(** 查询功能测试 *)
module QueryFunctionTests = struct
  (** 初始化测试数据 *)
  let setup_test_data () = try Some (parse_rhyme_json sample_rhyme_data) with _ -> None

  (** 测试字符查询功能 *)
  let test_character_lookup () =
    match setup_test_data () with
    | None -> fail "无法设置测试数据"
    | Some data ->
        let lookup_table = create_lookup_table data in

        (* 测试存在的字符 *)
        let test_chars = [ "鱼"; "书"; "花"; "月" ] in
        List.iter
          (fun char ->
            try
              let rhyme_info = lookup_character lookup_table char in
              check bool (Internal_formatter.character_found_message char) true (rhyme_info <> None)
            with Rhyme_data_not_found _ -> fail (Internal_formatter.character_should_exist char))
          test_chars;

        (* 测试不存在的字符 *)
        let non_existent_chars = [ "不存在"; "ABCD"; "123" ] in
        List.iter
          (fun char ->
            try
              let rhyme_info = lookup_character lookup_table char in
              check bool (Internal_formatter.character_should_not_exist char) true (rhyme_info = None)
            with Rhyme_data_not_found _ -> () (* 预期的异常 *))
          non_existent_chars

  (** 测试韵组查询 *)
  let test_rhyme_group_lookup () =
    match setup_test_data () with
    | None -> fail "无法设置测试数据"
    | Some data ->
        (* 测试根据字符查找韵组 *)
        let fish_rhyme_chars = [ "鱼"; "书"; "居"; "虚" ] in
        List.iter
          (fun char ->
            let found_group = find_rhyme_group_by_character data char in
            check bool (Internal_formatter.character_rhyme_group char) true (found_group <> None))
          fish_rhyme_chars

  (** 测试韵律匹配 *)
  let test_rhyme_matching () =
    match setup_test_data () with
    | None -> fail "无法设置测试数据"
    | Some data ->
        let lookup_table = create_lookup_table data in

        (* 测试同韵字符匹配 *)
        let rhyme_pairs =
          [
            ("鱼", "书", true);
            (* 同属鱼韵 *)
            ("花", "家", true);
            (* 同属花韵 *)
            ("鱼", "花", false);
            (* 不同韵 *)
            ("月", "雪", true);
            (* 同属月韵 *)
          ]
        in

        List.iter
          (fun (char1, char2, should_match) ->
            let matches = characters_rhyme lookup_table char1 char2 in
            let desc =
              Internal_formatter.rhyme_match_message char1 char2 should_match
            in
            check bool desc should_match matches)
          rhyme_pairs
end

(** Unicode和中文字符处理测试 *)
module UnicodeTests = struct
  (** 测试各种Unicode字符 *)
  let test_unicode_character_support () =
    let unicode_rhyme_data =
      {|
    {
      "rhyme_groups": {
        "unicode_test": {
          "category": "平声",
          "characters": ["春", "風", "詩", "詞", "🌸", "αβγ", "مرحبا"]
        }
      }
    }
    |}
    in

    try
      let data = parse_rhyme_json unicode_rhyme_data in
      check bool "Unicode数据解析成功" true true;

      let all_chars = List.concat (List.map (fun d -> d.characters) data) in
      let unicode_chars = [ "春"; "風"; "詩"; "詞"; "🌸"; "αβγ"; "مرحبا" ] in

      List.iter
        (fun char ->
          check bool (Internal_formatter.unicode_processing_message char) true (List.mem char all_chars))
        unicode_chars
    with exn -> fail (Internal_formatter.unicode_test_failure (Printexc.to_string exn))

  (** 测试繁简字符处理 *)
  let test_traditional_simplified_chinese () =
    let mixed_rhyme_data =
      {|
    {
      "rhyme_groups": {
        "mixed_chinese": {
          "category": "平声",
          "characters": ["诗", "詩", "词", "詞", "书", "書"]
        }
      }
    }
    |}
    in

    try
      let data = parse_rhyme_json mixed_rhyme_data in
      let lookup_table = create_lookup_table data in

      (* 测试繁简字符都能被正确处理 *)
      let char_pairs = [ ("诗", "詩"); ("词", "詞"); ("书", "書") ] in
      List.iter
        (fun (simp, trad) ->
          let simp_info = lookup_character lookup_table simp in
          let trad_info = lookup_character lookup_table trad in
          check bool (Internal_formatter.simplified_recognition simp) true (simp_info <> None);
          check bool (Internal_formatter.traditional_recognition trad) true (trad_info <> None))
        char_pairs
    with exn -> fail (Internal_formatter.traditional_simplified_failure (Printexc.to_string exn))
end

(** 性能和压力测试 *)
module PerformanceTests = struct
  (** 测试大规模数据处理 *)
  let test_large_data_processing () =
    let start_time = Sys.time () in

    try
      let data = parse_rhyme_json large_rhyme_data in
      let parse_time = Sys.time () -. start_time in

      (* 验证数据规模 *)
      check bool "大规模数据解析成功" true (List.length data > 50);

      (* 性能要求：解析时间应在合理范围内 *)
      check bool "解析性能合格" true (parse_time < 5.0);

      Printf.printf "大规模数据解析时间: %.6f 秒\n" parse_time
    with exn -> fail (Internal_formatter.large_data_failure (Printexc.to_string exn))

  (** 测试查询性能 *)
  let test_query_performance () =
    match
      JsonParsingTests.test_basic_json_parsing ();
      parse_rhyme_json sample_rhyme_data
    with
    | data ->
        let lookup_table = create_lookup_table data in
        let test_chars = [ "鱼"; "书"; "花"; "茶"; "月"; "雪" ] in

        let start_time = Sys.time () in

        (* 执行1000次查询 *)
        for _i = 1 to 1000 do
          List.iter (fun char -> ignore (lookup_character lookup_table char)) test_chars
        done;

        let query_time = Sys.time () -. start_time in
        let avg_query_time = query_time /. 6000.0 in

        (* 性能要求：平均查询时间应很快 *)
        check bool "查询性能合格" true (avg_query_time < 0.001);

        Printf.printf "1000次查询总时间: %.6f 秒\n" query_time;
        Printf.printf "平均单次查询时间: %.6f 秒\n" avg_query_time
    | exception exn -> fail (Internal_formatter.query_performance_failure (Printexc.to_string exn))

  (** 测试内存使用 *)
  let test_memory_usage () =
    let gc_stats_before = Gc.stat () in

    try
      (* 创建和销毁多个数据结构 *)
      for _i = 1 to 100 do
        let data = parse_rhyme_json sample_rhyme_data in
        let lookup_table = create_lookup_table data in
        ignore (lookup_character lookup_table "鱼")
      done;

      Gc.full_major ();
      let gc_stats_after = Gc.stat () in

      let memory_increase = gc_stats_after.live_words - gc_stats_before.live_words in

      (* 内存增长应该在合理范围内 *)
      check bool "内存使用合理" true (memory_increase < 100000);

      Printf.printf "内存增长: %d words\n" memory_increase
    with exn -> fail (Internal_formatter.memory_usage_failure (Printexc.to_string exn))
end

(** 边界条件和错误恢复测试 *)
module EdgeCaseTests = struct
  (** 测试极限字符串长度 *)
  let test_extreme_string_lengths () =
    (* 测试很长的字符名 *)
    let long_char = String.make 1000 'A' in
    let long_char_data = Internal_formatter.long_char_test_data long_char
    in

    try
      let data = parse_rhyme_json long_char_data in
      check bool "长字符名解析成功" true (List.length data = 1)
    with exn -> fail (Internal_formatter.long_name_failure (Printexc.to_string exn))

  (** 测试特殊字符处理 *)
  let test_special_characters () =
    let special_char_data =
      {|
    {
      "rhyme_groups": {
        "special": {
          "category": "平声",
          "characters": ["\"", "\\", "\n", "\t", "\r", "\\u0000"]
        }
      }
    }
    |}
    in

    try
      let data = parse_rhyme_json special_char_data in
      check bool "特殊字符解析成功" true (List.length data = 1)
    with exn -> fail (Internal_formatter.special_char_failure (Printexc.to_string exn))

  (** 测试错误恢复机制 *)
  let test_error_recovery () =
    (* 测试解析错误后系统是否能正常恢复 *)
    try
      let _ = parse_rhyme_json invalid_json_data in
      fail "应该产生解析错误"
    with Json_parse_error _ -> (
      (* 错误后再次尝试正常解析 *)
      try
        let data = parse_rhyme_json sample_rhyme_data in
        check bool "错误恢复后正常解析" true (List.length data > 0)
      with exn -> fail (Internal_formatter.error_recovery_failure (Printexc.to_string exn)))
end

(** 测试套件注册 *)
let test_suite =
  [
    ( "JSON解析功能",
      [
        test_case "基本JSON解析" `Quick JsonParsingTests.test_basic_json_parsing;
        test_case "空JSON处理" `Quick JsonParsingTests.test_empty_json_handling;
        test_case "无效JSON错误处理" `Quick JsonParsingTests.test_invalid_json_error_handling;
        test_case "格式错误JSON" `Quick JsonParsingTests.test_malformed_json;
      ] );
    ( "韵律数据验证",
      [
        test_case "韵组数据结构" `Quick RhymeDataValidationTests.test_rhyme_group_structure;
        test_case "韵类分类" `Quick RhymeDataValidationTests.test_rhyme_category_classification;
        test_case "字符唯一性" `Quick RhymeDataValidationTests.test_character_uniqueness;
      ] );
    ( "查询功能",
      [
        test_case "字符查询" `Quick QueryFunctionTests.test_character_lookup;
        test_case "韵组查询" `Quick QueryFunctionTests.test_rhyme_group_lookup;
        test_case "韵律匹配" `Quick QueryFunctionTests.test_rhyme_matching;
      ] );
    ( "Unicode支持",
      [
        test_case "Unicode字符支持" `Quick UnicodeTests.test_unicode_character_support;
        test_case "繁简字符处理" `Quick UnicodeTests.test_traditional_simplified_chinese;
      ] );
    ( "性能测试",
      [
        test_case "大规模数据处理" `Quick PerformanceTests.test_large_data_processing;
        test_case "查询性能" `Quick PerformanceTests.test_query_performance;
        test_case "内存使用" `Quick PerformanceTests.test_memory_usage;
      ] );
    ( "边界条件",
      [
        test_case "极限字符串长度" `Quick EdgeCaseTests.test_extreme_string_lengths;
        test_case "特殊字符处理" `Quick EdgeCaseTests.test_special_characters;
        test_case "错误恢复机制" `Quick EdgeCaseTests.test_error_recovery;
      ] );
  ]

(** 运行所有测试 *)
let () =
  Printf.printf "骆言韵律JSON加载器全面测试 - Phase 25\n";
  Printf.printf "======================================================\n";
  run "Rhyme JSON Loader Comprehensive Tests" test_suite
