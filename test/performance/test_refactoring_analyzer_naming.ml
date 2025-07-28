(** 命名质量分析器模块测试

    测试覆盖refactoring_analyzer_naming.ml模块的所有核心功能 技术债务修复：提升关键编译器模块测试覆盖率 Fix #1617

    @author Alpha代理, 主要工作代理
    @version 1.0 - 首次实现完整测试覆盖
    @since 2025-07-28 Issue #1617 命名分析器测试覆盖改进 *)

open Alcotest
open Yyocamlc_lib.Refactoring_analyzer_naming
open Yyocamlc_lib.Refactoring_analyzer_types

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring str sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) str 0 in
    true
  with Not_found -> false

(** 测试英文命名检测功能 *)
let test_is_english_naming () =
  (* 正面测试：典型英文命名 *)
  check bool "英文变量名应被识别" true (is_english_naming "variable");
  check bool "驼峰命名应被识别" true (is_english_naming "variableName");
  check bool "下划线命名应被识别" true (is_english_naming "variable_name");
  check bool "大写开头应被识别" true (is_english_naming "Variable");
  check bool "单字母变量应被识别" true (is_english_naming "x");
  check bool "数字结尾应被识别" true (is_english_naming "var123");

  (* 负面测试：非英文命名 *)
  check bool "中文变量名不应被识别为英文" false (is_english_naming "变量");
  check bool "中英混用不应被识别为纯英文" false (is_english_naming "变量Name");
  check bool "数字开头不应被识别为有效英文" false (is_english_naming "123var");
  check bool "特殊字符不应被识别为英文" false (is_english_naming "var-name")

(** 测试中英文混用检测功能 *)
let test_is_mixed_naming () =
  (* 正面测试：中英文混用 *)
  check bool "中英混用应被检测" true (is_mixed_naming "变量Name");
  check bool "英中混用应被检测" true (is_mixed_naming "name变量");
  check bool "复杂混用应被检测" true (is_mixed_naming "获取Value值");

  (* 负面测试：非混用情况 *)
  check bool "纯中文不应被识别为混用" false (is_mixed_naming "变量名称");
  check bool "纯英文不应被识别为混用" false (is_mixed_naming "variableName");
  check bool "数字不影响混用检测" false (is_mixed_naming "variable123");
  check bool "空字符串不应被识别为混用" false (is_mixed_naming "")

(** 测试过短命名检测功能 *)
let test_is_too_short () =
  (* 正面测试：过短命名 *)
  check bool "单字母应被识别为过短" true (is_too_short "x");
  check bool "双字母应被识别为过短" true (is_too_short "id");
  check bool "空字符串应被识别为过短" true (is_too_short "");

  (* 例外情况：中文代词不应被视为过短 *)
  check bool "中文代词'我'不应被视为过短" false (is_too_short "我");
  check bool "中文代词'你'不应被视为过短" false (is_too_short "你");
  check bool "中文代词'他'不应被视为过短" false (is_too_short "他");
  check bool "中文代词'它'不应被视为过短" false (is_too_short "它");

  (* 负面测试：正常长度命名 *)
  check bool "三字符以上不应被识别为过短" false (is_too_short "name");
  check bool "中文变量名不应被识别为过短" false (is_too_short "变量名")

(** 测试无意义命名检测功能 *)
let test_is_meaningless_naming () =
  (* 正面测试：常见无意义命名 *)
  check bool "temp应被识别为无意义" true (is_meaningless_naming "temp");
  check bool "tmp应被识别为无意义" true (is_meaningless_naming "tmp");
  check bool "data应被识别为无意义" true (is_meaningless_naming "data");
  check bool "info应被识别为无意义" true (is_meaningless_naming "info");
  check bool "obj应被识别为无意义" true (is_meaningless_naming "obj");
  check bool "val应被识别为无意义" true (is_meaningless_naming "val");
  check bool "var应被识别为无意义" true (is_meaningless_naming "var");
  check bool "单字母x应被识别为无意义" true (is_meaningless_naming "x");
  check bool "单字母y应被识别为无意义" true (is_meaningless_naming "y");
  check bool "单字母z应被识别为无意义" true (is_meaningless_naming "z");

  (* 负面测试：有意义命名 *)
  check bool "有意义的英文名不应被识别" false (is_meaningless_naming "userName");
  check bool "有意义的中文名不应被识别" false (is_meaningless_naming "用户名称");
  check bool "具体的变量名不应被识别" false (is_meaningless_naming "count")

(** 测试单个命名质量分析功能 *)
let test_analyze_naming_quality () =
  (* 测试英文命名建议 *)
  let english_suggestions = analyze_naming_quality "variable" in
  check int "英文命名应生成一个建议" 1 (List.length english_suggestions);
  let suggestion = List.hd english_suggestions in
  check bool "应包含建议使用中文命名信息" true (contains_substring suggestion.message "中");
  check bool "置信度应合理" true (suggestion.confidence >= 0.5);

  (* 测试中英混用建议 *)
  let mixed_suggestions = analyze_naming_quality "变量Name" in
  check int "中英混用应生成一个建议" 1 (List.length mixed_suggestions);
  let mixed_suggestion = List.hd mixed_suggestions in
  check bool "应包含避免混用信息" true (contains_substring mixed_suggestion.message "混");

  (* 测试过短命名建议 *)
  let short_suggestions = analyze_naming_quality "x" in
  check int "过短命名应生成三个建议" 3 (List.length short_suggestions);

  (* 测试无意义命名建议 *)
  let meaningless_suggestions = analyze_naming_quality "temp" in
  check int "无意义命名应生成两个建议" 2 (List.length meaningless_suggestions);

  (* 测试好的中文命名 *)
  let good_suggestions = analyze_naming_quality "用户名称" in
  check int "好的中文命名不应生成建议" 0 (List.length good_suggestions)

(** 测试批量命名分析功能 *)
let test_analyze_multiple_names () =
  let names = [ "variable"; "变量Name"; "x"; "temp"; "用户名称" ] in
  let suggestions = analyze_multiple_names names in

  (* 应该有多个建议 *)
  check bool "批量分析应生成多个建议" true (List.length suggestions > 4);

  (* 测试空列表情况 *)
  let empty_suggestions = analyze_multiple_names [] in
  check int "空列表应不生成建议" 0 (List.length empty_suggestions);

  (* 测试单个好命名 *)
  let single_good = analyze_multiple_names [ "用户名称" ] in
  check int "单个好命名应不生成建议" 0 (List.length single_good)

(** 测试命名统计功能 *)
let test_get_naming_statistics () =
  (* 创建各种类型的建议用于测试 *)
  let english_suggestion =
    {
      suggestion_type = NamingImprovement "建议使用中文命名";
      message = "英文命名建议";
      confidence = 0.75;
      location = Some "test";
      suggested_fix = Some "fix";
    }
  in
  let mixed_suggestion =
    {
      suggestion_type = NamingImprovement "避免中英文混用";
      message = "混用建议";
      confidence = 0.80;
      location = Some "test";
      suggested_fix = Some "fix";
    }
  in
  let short_suggestion =
    {
      suggestion_type = NamingImprovement "名称过短";
      message = "过短建议";
      confidence = 0.70;
      location = Some "test";
      suggested_fix = Some "fix";
    }
  in
  let meaningless_suggestion =
    {
      suggestion_type = NamingImprovement "避免无意义命名";
      message = "无意义建议";
      confidence = 0.85;
      location = Some "test";
      suggested_fix = Some "fix";
    }
  in
  let non_naming_suggestion =
    {
      suggestion_type = PerformanceHint "性能提示";
      message = "非命名建议";
      confidence = 0.60;
      location = Some "test";
      suggested_fix = Some "fix";
    }
  in

  let suggestions =
    [
      english_suggestion;
      mixed_suggestion;
      short_suggestion;
      meaningless_suggestion;
      non_naming_suggestion;
    ]
  in
  let english_count, mixed_count, short_count, meaningless_count =
    get_naming_statistics suggestions
  in

  check int "英文命名统计应正确" 1 english_count;
  check int "混用命名统计应正确" 1 mixed_count;
  check int "过短命名统计应正确" 1 short_count;
  check int "无意义命名统计应正确" 1 meaningless_count;

  (* 测试空列表统计 *)
  let e, m, s, ml = get_naming_statistics [] in
  check int "空列表英文统计" 0 e;
  check int "空列表混用统计" 0 m;
  check int "空列表过短统计" 0 s;
  check int "空列表无意义统计" 0 ml

(** 测试命名质量报告生成功能 *)
let test_generate_naming_report () =
  (* 测试有问题的情况 *)
  let problematic_suggestions = analyze_multiple_names [ "variable"; "变量Name"; "x"; "temp" ] in
  let report = generate_naming_report problematic_suggestions in

  check bool "报告应包含标题" true (contains_substring report "📝");
  check bool "报告应包含统计信息" true (contains_substring report "📊");
  check bool "报告应包含英文命名统计" true (contains_substring report "🔤");
  check bool "报告应包含混用统计" true (contains_substring report "🔀");
  check bool "报告应包含过短统计" true (contains_substring report "📏");
  check bool "报告应包含无意义统计" true (contains_substring report "❓");
  check bool "报告应包含改进建议" true (contains_substring report "💡");

  (* 测试没有问题的情况 *)
  let good_suggestions = analyze_multiple_names [ "用户名称"; "数据库连接" ] in
  let good_report = generate_naming_report good_suggestions in
  check bool "好的命名应获得祝贺" true (contains_substring good_report "✅");
  check bool "好的命名应提及最佳实践" true (contains_substring good_report "最佳实践")

(** 测试中文字符处理边界条件 *)
let test_chinese_character_handling () =
  (* 测试复杂中文字符 *)
  check bool "繁体中文应被正确识别" false (is_english_naming "變量名稱");
  check bool "中文标点符号混用应被检测" true (is_mixed_naming "变量，Name");

  (* 测试空字符串和特殊情况 *)
  check bool "空字符串英文检测" false (is_english_naming "");
  check bool "空字符串混用检测" false (is_mixed_naming "");

  (* 测试Unicode字符边界 *)
  check bool "包含Unicode字符应被正确处理" false (is_english_naming "变量🔥");
  check bool "Unicode混用应被检测" true (is_mixed_naming "var🔥变量")

(** 测试建议类型分类正确性 *)
let test_suggestion_type_classification () =
  let english_suggestions = analyze_naming_quality "variable" in
  let english_suggestion = List.hd english_suggestions in
  (match english_suggestion.suggestion_type with
  | NamingImprovement improvement_type -> check string "英文命名建议类型应正确" "建议使用中文命名" improvement_type
  | _ -> check bool "英文命名建议应为NamingImprovement类型" false true);

  let mixed_suggestions = analyze_naming_quality "变量Name" in
  let mixed_suggestion = List.hd mixed_suggestions in
  match mixed_suggestion.suggestion_type with
  | NamingImprovement improvement_type -> check string "混用命名建议类型应正确" "避免中英文混用" improvement_type
  | _ -> check bool "混用命名建议应为NamingImprovement类型" false true

(** 测试套件定义 *)
let () =
  run "命名质量分析器测试"
    [
      ("英文命名检测", [ test_case "is_english_naming基础功能" `Quick test_is_english_naming ]);
      ("中英文混用检测", [ test_case "is_mixed_naming基础功能" `Quick test_is_mixed_naming ]);
      ("过短命名检测", [ test_case "is_too_short基础功能" `Quick test_is_too_short ]);
      ("无意义命名检测", [ test_case "is_meaningless_naming基础功能" `Quick test_is_meaningless_naming ]);
      ("命名质量分析", [ test_case "analyze_naming_quality基础功能" `Quick test_analyze_naming_quality ]);
      ("批量命名分析", [ test_case "analyze_multiple_names基础功能" `Quick test_analyze_multiple_names ]);
      ("命名统计功能", [ test_case "get_naming_statistics基础功能" `Quick test_get_naming_statistics ]);
      ("报告生成功能", [ test_case "generate_naming_report基础功能" `Quick test_generate_naming_report ]);
      ("中文字符处理", [ test_case "中文字符边界条件" `Quick test_chinese_character_handling ]);
      ("建议类型分类", [ test_case "建议类型正确性" `Quick test_suggestion_type_classification ]);
    ]
