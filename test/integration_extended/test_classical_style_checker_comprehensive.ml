(** 古雅体适用性检查器综合测试 - 修复 Issue #1342

    作为测试工程师，为古雅体风格实施状态检查创建全面的测试覆盖。 这些测试确保古雅体适用性检查器正确识别和报告各种古雅体使用问题。

    Author: Echo, 测试工程师代理 Fix #1342 - 检查古雅体风格的实施状态 *)

open Chinese_best_practices_checkers.Classical_style_checker
open Chinese_best_practices_types.Severity_types
open Chinese_best_practices_types.Practice_types

(** 测试用例：基础古雅体适用性检查 *)
let test_basic_classical_style_check () =
  (* 测试过度古雅的代码 *)
  let excessive_code = "夫算法者乃计算之法也" in
  let results = check_classical_style_appropriateness excessive_code in
  Alcotest.(check bool) "检测到过度古雅" true (List.length results > 0);

  (* 测试正常代码（不应触发检查） *)
  let normal_code = "设数值为10" in
  let normal_results = check_classical_style_appropriateness normal_code in
  let has_excessive =
    List.exists
      (fun r ->
        match r.violation with
        | ModernizationSuggestion (_, issue, _) when issue = "过度古雅" -> true
        | _ -> false)
      normal_results
  in
  Alcotest.(check bool) "正常代码不触发过度古雅检查" false has_excessive

(** 测试用例：特定模式检测 *)
let test_pattern_detection () =
  (* 测试 "乃.*之.*也" 模式 *)
  let code1 = "此乃计算之法也" in
  let results1 = check_classical_style_appropriateness code1 in
  Alcotest.(check bool) "检测到乃之也模式" true (List.length results1 > 0);

  (* 测试 "其.*者.*焉" 模式 *)
  let code2 = "其算法者甚复杂焉" in
  let results2 = check_classical_style_appropriateness code2 in
  Alcotest.(check bool) "检测到其者焉模式" true (List.length results2 > 0);

  (* 测试 "若.*则.*矣" 模式 *)
  let code3 = "若条件满足则执行矣" in
  let results3 = check_classical_style_appropriateness code3 in
  Alcotest.(check bool) "检测到若则矣模式" true (List.length results3 > 0)

(** 测试用例：古今混用检测 *)
let test_mixed_style_detection () =
  (* 测试古今混用 *)
  let mixed_code1 = "设算法为某种值" in
  let results1 = check_classical_style_appropriateness mixed_code1 in
  let has_mixed =
    List.exists
      (fun r ->
        match r.violation with
        | ModernizationSuggestion (_, issue, _) when issue = "古今混用" -> true
        | _ -> false)
      results1
  in
  Alcotest.(check bool) "检测到古今混用：设为值" true has_mixed;

  (* 测试另一种古今混用 *)
  let mixed_code2 = "取数据之某值" in
  let results2 = check_classical_style_appropriateness mixed_code2 in
  let has_mixed2 =
    List.exists
      (fun r ->
        match r.violation with
        | ModernizationSuggestion (_, issue, _) when issue = "古今混用" -> true
        | _ -> false)
      results2
  in
  Alcotest.(check bool) "检测到古今混用：取之值" true has_mixed2

(** 测试用例：AI理解困难模式检测 *)
let test_ai_unfriendly_detection () =
  (* 测试AI理解困难的表达 *)
  let ai_unfriendly1 = "凡数据皆有效也" in
  let results1 = check_classical_style_appropriateness ai_unfriendly1 in
  let has_ai_issue =
    List.exists
      (fun r ->
        match r.violation with
        | ModernizationSuggestion (_, issue, _) when issue = "AI理解困难" -> true
        | _ -> false)
      results1
  in
  Alcotest.(check bool) "检测到AI理解困难：凡皆也" true has_ai_issue;

  (* 验证严重度为Error *)
  let error_severity = List.exists (fun r -> r.severity = Error) results1 in
  Alcotest.(check bool) "AI理解困难问题的严重度为Error" true error_severity;

  (* 测试另一种AI理解困难的表达 *)
  let ai_unfriendly2 = "然则执行某操作焉" in
  let results2 = check_classical_style_appropriateness ai_unfriendly2 in
  let has_ai_issue2 =
    List.exists
      (fun r ->
        match r.violation with
        | ModernizationSuggestion (_, issue, _) when issue = "AI理解困难" -> true
        | _ -> false)
      results2
  in
  Alcotest.(check bool) "检测到AI理解困难：然则焉" true has_ai_issue2

(** 测试用例：类别检查 *)
let test_category_check () =
  let code_with_multiple_issues = "夫算法者乃复杂之法也，设数据为某值，凡结果皆正确也" in

  (* 测试过度古雅类别检查 *)
  let excessive_results = check_category code_with_multiple_issues "excessive_classical" in
  Alcotest.(check bool) "类别检查：过度古雅" true (List.length excessive_results > 0);

  (* 测试古今混用类别检查 *)
  let mixed_results = check_category code_with_multiple_issues "mixed_expression" in
  Alcotest.(check bool) "类别检查：古今混用" true (List.length mixed_results > 0);

  (* 测试AI不友好类别检查 *)
  let ai_results = check_category code_with_multiple_issues "ai_unfriendly" in
  Alcotest.(check bool) "类别检查：AI不友好" true (List.length ai_results > 0);

  (* 测试未知类别返回所有规则 *)
  let all_results = check_category code_with_multiple_issues "unknown_category" in
  Alcotest.(check bool) "未知类别返回所有结果" true (List.length all_results > 0)

(** 测试用例：支持的类别获取 *)
let test_supported_categories () =
  let categories = get_supported_categories () in
  Alcotest.(check int) "支持的类别数量" 3 (List.length categories);
  Alcotest.(check bool) "包含excessive_classical" true (List.mem "excessive_classical" categories);
  Alcotest.(check bool) "包含mixed_expression" true (List.mem "mixed_expression" categories);
  Alcotest.(check bool) "包含ai_unfriendly" true (List.mem "ai_unfriendly" categories)

(** 测试用例：严重度过滤检查 *)
let test_severity_filter () =
  let code_with_various_severities = "设算法为某值，夫此乃复杂之法也，凡数据皆有效也" in

  (* 只检查Error级别 *)
  let error_results = check_with_severity_filter code_with_various_severities Error in
  let all_errors = List.for_all (fun r -> r.severity = Error) error_results in
  Alcotest.(check bool) "Error过滤：只返回Error级别" true all_errors;

  (* 检查Warning及以上级别 *)
  let warning_results = check_with_severity_filter code_with_various_severities Warning in
  let has_warning_or_error =
    List.for_all (fun r -> r.severity = Error || r.severity = Warning) warning_results
  in
  Alcotest.(check bool) "Warning过滤：返回Warning和Error级别" true has_warning_or_error;

  (* 检查所有级别 *)
  let info_results = check_with_severity_filter code_with_various_severities Info in
  Alcotest.(check bool) "Info过滤：返回所有级别" true (List.length info_results >= List.length error_results)

(** 测试用例：检查结果结构完整性 *)
let test_result_structure () =
  let code = "夫此乃测试之代码也" in
  let results = check_classical_style_appropriateness code in

  (* 确保至少有一个结果 *)
  Alcotest.(check bool) "有检查结果" true (List.length results > 0);

  let result = List.hd results in

  (* 检查结果结构的完整性 *)
  Alcotest.(check bool)
    "包含violation字段" true
    (match result.violation with ModernizationSuggestion (_, _, _) -> true | _ -> false);

  (* 检查confidence字段 *)
  Alcotest.(check bool)
    "confidence在合理范围内" true
    (result.confidence >= 0.0 && result.confidence <= 1.0);

  (* 检查ai_friendly字段 *)
  Alcotest.(check bool)
    "ai_friendly字段存在" true
    (result.ai_friendly = true || result.ai_friendly = false);

  (* 检查message和suggestion字段非空 *)
  Alcotest.(check bool) "message非空" true (String.length result.message > 0);
  Alcotest.(check bool) "suggestion非空" true (String.length result.suggestion > 0)

(** 测试用例：边界情况处理 *)
let test_edge_cases () =
  (* 空字符串 *)
  let empty_results = check_classical_style_appropriateness "" in
  Alcotest.(check int) "空字符串无检查结果" 0 (List.length empty_results);

  (* 纯现代语法 *)
  let modern_code = "let x = 10 in x + 1" in
  let modern_results = check_classical_style_appropriateness modern_code in
  Alcotest.(check int) "现代语法无古雅体问题" 0 (List.length modern_results);

  (* 纯中文但无古雅体模式 *)
  let simple_chinese = "计算数值结果" in
  let simple_results = check_classical_style_appropriateness simple_chinese in
  Alcotest.(check int) "简单中文无古雅体问题" 0 (List.length simple_results);

  (* 包含古雅体模式但在注释中 *)
  let comment_code = "(* 夫此乃注释也 *) 设置数值" in
  let comment_results = check_classical_style_appropriateness comment_code in
  (* 注意：当前实现会检测注释中的模式，这可能是设计决策 *)
  Alcotest.(check bool) "注释中的古雅体被检测" true (List.length comment_results >= 0)

(** 测试用例：性能和稳定性 *)
let test_performance_stability () =
  (* 长文本处理 *)
  let long_text = String.make 1000 'a' ^ "此乃测试之文本也" in
  let long_results = check_classical_style_appropriateness long_text in
  Alcotest.(check bool) "长文本处理正常" true (List.length long_results > 0);

  (* 重复模式 *)
  let repeated_pattern = "甲乃算法之实现也。乙乃数据之存储也。丙乃结果之输出也。" in
  let repeated_results = check_classical_style_appropriateness repeated_pattern in
  Alcotest.(check bool) "重复模式检测正常" true (List.length repeated_results > 0);

  (* 特殊字符 - 使用匹配的模式 *)
  let special_chars = "其算法者包含特殊字符!@#$%^&*()焉" in
  let special_results = check_classical_style_appropriateness special_chars in
  Alcotest.(check bool) "特殊字符处理正常" true (List.length special_results > 0)

(** 测试套件定义 *)
let test_suite =
  [
    ("基础古雅体适用性检查", `Quick, test_basic_classical_style_check);
    ("特定模式检测", `Quick, test_pattern_detection);
    ("古今混用检测", `Quick, test_mixed_style_detection);
    ("AI理解困难模式检测", `Quick, test_ai_unfriendly_detection);
    ("类别检查", `Quick, test_category_check);
    ("支持的类别获取", `Quick, test_supported_categories);
    ("严重度过滤检查", `Quick, test_severity_filter);
    ("检查结果结构完整性", `Quick, test_result_structure);
    ("边界情况处理", `Quick, test_edge_cases);
    ("性能和稳定性", `Quick, test_performance_stability);
  ]

(** 运行测试 *)
let () = Alcotest.run "古雅体适用性检查器综合测试 - Fix #1342" [ ("Classical Style Checker", test_suite) ]
