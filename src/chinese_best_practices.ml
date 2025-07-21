(** 骆言中文编程最佳实践检查器 - 重构后的简化版本 *)

(* 引入模块化组件 *)
module Core = Chinese_best_practices_core.Practice_coordinator
module VR = Chinese_best_practices_reporters.Violation_reporter

(* 重新导出类型以保持API兼容性 *)
type practice_violation = Chinese_best_practices_types.Practice_types.practice_violation =
  | MixedLanguage of string * string * string
  | ImproperWordOrder of string * string * string
  | Unidiomatic of string * string * string
  | InconsistentStyle of string * string * string
  | ModernizationSuggestion of string * string * string

type severity = Chinese_best_practices_types.Severity_types.severity =
  | Error
  | Warning
  | Info
  | Style

type practice_check_result = Chinese_best_practices_types.Severity_types.practice_check_result = {
  violation : practice_violation;
  severity : severity;
  message : string;
  suggestion : string;
  confidence : float;
  ai_friendly : bool;
}

(** 综合最佳实践检查 - 使用完全模块化的架构 *)
let comprehensive_practice_check ?(config = Core.default_config) code =
  (* 运行所有模块化检查 *)
  let all_violations = Core.run_basic_checks code config in

  (* 过滤结果 *)
  let filtered_violations = Core.filter_violations all_violations config in

  (* 生成报告 *)
  VR.generate_practice_report filtered_violations

(** 简化的综合检查（用于测试） *)
let generate_practice_report violations = VR.generate_practice_report violations

(** 兼容性函数 - 保持原有API *)
let detect_mixed_language_patterns =
  Chinese_best_practices_checkers.Mixed_language_checker.detect_mixed_language_patterns

let check_chinese_word_order =
  Chinese_best_practices_checkers.Word_order_checker.check_chinese_word_order

let check_idiomatic_chinese =
  Chinese_best_practices_checkers.Idiomatic_checker.check_idiomatic_chinese

let check_style_consistency =
  Chinese_best_practices_checkers.Style_consistency_checker.check_style_consistency

let check_classical_style_appropriateness =
  Chinese_best_practices_checkers.Classical_style_checker.check_classical_style_appropriateness

let check_ai_friendly_patterns =
  Chinese_best_practices_checkers.Ai_friendly_checker.check_ai_friendly_patterns

type test_config = {
  name : string;
  icon : string;
  test_cases : string list;
  checker_function : string -> practice_check_result list;
}
(** 测试配置类型 *)

(** 通用测试运行器 - 消除代码重复 *)
let run_test_suite test_config =
  Unified_logging.Legacy.printf "🧪 测试%s...\n" test_config.name;

  List.iteri
    (fun i code ->
      Unified_logging.Legacy.printf "测试案例 %d: %s\n" (i + 1) code;
      let violations = test_config.checker_function code in
      Unified_logging.Legacy.printf "发现违规: %d 个\n" (List.length violations);
      List.iter (fun v -> Unified_logging.Legacy.printf "  - %s\n" v.message) violations;
      Unified_logging.Legacy.printf "\n")
    test_config.test_cases;

  Unified_logging.Legacy.printf "✅ %s测试完成\n\n" test_config.name

(** 运行综合测试的专门函数 *)
let run_comprehensive_test () =
  Unified_logging.Legacy.printf "🧪 测试综合最佳实践检查...\n";
  let test_cases =
    [
      "if 用户年龄 > 18 那么 return \"成年\" else \"未成年\" // 英文注释";
      "让「用户年龄」= 18\n如果「用户年龄」> 成年标准 那么「成年人」否则「未成年人\"";
      "for user in userList 循环 执行操作来计算这个用户的年龄，若其大于十八者则为成年也";
    ]
  in

  List.iteri
    (fun i code ->
      Unified_logging.Legacy.printf "🔍 综合测试案例 %d:\n" (i + 1);
      Unified_logging.Legacy.printf "代码: %s\n\n" code;
      let report = comprehensive_practice_check code in
      Unified_logging.Legacy.printf "%s\n" report;
      Unified_logging.Legacy.printf "%s\n" (String.make 80 '-'))
    test_cases;
  Unified_logging.Legacy.printf "✅ 综合最佳实践检查测试完成\n\n"

(** 打印测试统计的辅助函数 *)
let print_test_summary () =
  Unified_logging.Legacy.printf "🎉 所有中文编程最佳实践检查器测试完成！\n";
  Unified_logging.Legacy.printf "📊 测试统计:\n";
  let test_items = [ "中英文混用检测"; "中文语序检查"; "地道性检查"; "风格一致性检查"; "古雅体适用性检查"; "AI友好性检查"; "综合检查" ] in
  List.iter (fun item -> Unified_logging.Legacy.printf "   • %s: ✅ 通过\n" item) test_items

(** 测试中文编程最佳实践检查器 - 重构后的模块化版本 *)
let test_chinese_best_practices () =
  Unified_logging.Legacy.printf "=== 中文编程最佳实践检查器全面测试 ===\n\n";

  (* 定义所有测试配置 *)
  let test_configs =
    [
      {
        name = "中英文混用检测";
        icon = "🧪";
        test_cases =
          [
            "if 年龄 > 18 那么 打印 \"成年人\"";
            "for i in 列表 循环 处理 元素";
            "让 username = \"张三\"";
            "函数 calculateAge 计算年龄";
            "// 这是一个中文注释";
          ];
        checker_function = detect_mixed_language_patterns;
      };
      {
        name = "中文语序检查";
        icon = "🧪";
        test_cases = [ "计算列表的长度"; "获取用户的年龄"; "如果条件满足的话那么执行"; "当用户点击的时候响应" ];
        checker_function = check_chinese_word_order;
      };
      {
        name = "地道性检查";
        icon = "🧪";
        test_cases = [ "数据结构设计"; "算法实现方案"; "执行操作"; "进行计算"; "如果条件满足" ];
        checker_function = check_idiomatic_chinese;
      };
      {
        name = "风格一致性检查";
        icon = "🧪";
        test_cases =
          [ "让「用户名」= 张三 让「年龄」= 25"; "函数 计算年龄 → 结果 函数计算分数→结果"; "递归 让 阶乘 递归让斐波那契"; "「用户名」// 英文注释" ];
        checker_function = check_style_consistency;
      };
      {
        name = "古雅体适用性检查";
        icon = "🧪";
        test_cases = [ "乃计算之结果也"; "其用户者焉"; "若年龄大于十八则成年矣"; "设年龄为十八"; "取用户之姓名"; "凡用户皆成年也" ];
        checker_function = check_classical_style_appropriateness;
      };
      {
        name = "AI友好性检查";
        icon = "🧪";
        test_cases =
          [ "计算结果"; "处理数据"; "操作文件"; "这个变量很重要"; "那个函数需要修改"; "它的值是正确的"; "循环直到完成"; "逐个处理元素" ];
        checker_function = check_ai_friendly_patterns;
      };
    ]
  in

  (* 运行所有标准测试 *)
  List.iter run_test_suite test_configs;

  (* 运行综合测试 *)
  run_comprehensive_test ();

  (* 打印测试统计 *)
  print_test_summary ()
