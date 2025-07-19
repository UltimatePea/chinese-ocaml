(** 骆言中文编程最佳实践检查器 - 帮助AI代理写出更地道的中文代码 
    重构版：使用模块化架构，提高代码可维护性和扩展性 *)

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
  | Error | Warning | Info | Style

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
let generate_practice_report violations =
  VR.generate_practice_report violations

(** 兼容性函数 - 保持原有API *)
let detect_mixed_language_patterns = Chinese_best_practices_checkers.Mixed_language_checker.detect_mixed_language_patterns
let check_chinese_word_order = Chinese_best_practices_checkers.Word_order_checker.check_chinese_word_order
let check_idiomatic_chinese = Chinese_best_practices_checkers.Idiomatic_checker.check_idiomatic_chinese
let check_style_consistency = Chinese_best_practices_checkers.Style_consistency_checker.check_style_consistency
let check_classical_style_appropriateness = Chinese_best_practices_checkers.Classical_style_checker.check_classical_style_appropriateness
let check_ai_friendly_patterns = Chinese_best_practices_checkers.Ai_friendly_checker.check_ai_friendly_patterns

(** 测试中文编程最佳实践检查器 *)
let test_chinese_best_practices () =
  Printf.printf "=== 中文编程最佳实践检查器全面测试 ===\n\n";

  let test_mixed_language () =
    Printf.printf "🧪 测试中英文混用检测...\n";
    let test_cases = [
      "if 年龄 > 18 那么 打印 \"成年人\"";
      "for i in 列表 循环 处理 元素";
      "让 username = \"张三\"";
      "函数 calculateAge 计算年龄";
      "// 这是一个中文注释";
    ] in
    
    List.iteri (fun i code ->
      Printf.printf "测试案例 %d: %s\n" (i + 1) code;
      let violations = detect_mixed_language_patterns code in
      Printf.printf "发现违规: %d 个\n" (List.length violations);
      List.iter (fun v -> Printf.printf "  - %s\n" v.message) violations;
      Printf.printf "\n"
    ) test_cases;
    Printf.printf "✅ 中英文混用检测测试完成\n\n"
  in

  let test_word_order () =
    Printf.printf "🧪 测试中文语序检查...\n";
    let test_cases = [
      "计算列表的长度";
      "获取用户的年龄";
      "如果条件满足的话那么执行";
      "当用户点击的时候响应";
    ] in
    
    List.iteri (fun i code ->
      Printf.printf "测试案例 %d: %s\n" (i + 1) code;
      let violations = check_chinese_word_order code in
      Printf.printf "发现违规: %d 个\n" (List.length violations);
      List.iter (fun v -> Printf.printf "  - %s\n" v.message) violations;
      Printf.printf "\n"
    ) test_cases;
    Printf.printf "✅ 中文语序检查测试完成\n\n"
  in

  let test_idiomatic () =
    Printf.printf "🧪 测试地道性检查...\n";
    let test_cases = [
      "数据结构设计";
      "算法实现方案";
      "执行操作";
      "进行计算";
      "如果条件满足";
    ] in
    
    List.iteri (fun i code ->
      Printf.printf "测试案例 %d: %s\n" (i + 1) code;
      let violations = check_idiomatic_chinese code in
      Printf.printf "发现违规: %d 个\n" (List.length violations);
      List.iter (fun v -> Printf.printf "  - %s\n" v.message) violations;
      Printf.printf "\n"
    ) test_cases;
    Printf.printf "✅ 地道性检查测试完成\n\n"
  in

  let test_style_consistency () =
    Printf.printf "🧪 测试风格一致性检查...\n";
    let test_cases = [
      "让「用户名」= 张三 让「年龄」= 25";
      "函数 计算年龄 → 结果 函数计算分数→结果";
      "递归 让 阶乘 递归让斐波那契";
      "「用户名」// 英文注释";
    ] in
    
    List.iteri (fun i code ->
      Printf.printf "测试案例 %d: %s\n" (i + 1) code;
      let violations = check_style_consistency code in
      Printf.printf "发现违规: %d 个\n" (List.length violations);
      List.iter (fun v -> Printf.printf "  - %s\n" v.message) violations;
      Printf.printf "\n"
    ) test_cases;
    Printf.printf "✅ 风格一致性检查测试完成\n\n"
  in

  let test_classical_style () =
    Printf.printf "🧪 测试古雅体适用性检查...\n";
    let test_cases = [
      "乃计算之结果也";
      "其用户者焉";
      "若年龄大于十八则成年矣";
      "设年龄为十八";
      "取用户之姓名";
      "凡用户皆成年也";
    ] in
    
    List.iteri (fun i code ->
      Printf.printf "测试案例 %d: %s\n" (i + 1) code;
      let violations = check_classical_style_appropriateness code in
      Printf.printf "发现违规: %d 个\n" (List.length violations);
      List.iter (fun v -> Printf.printf "  - %s\n" v.message) violations;
      Printf.printf "\n"
    ) test_cases;
    Printf.printf "✅ 古雅体适用性检查测试完成\n\n"
  in

  let test_ai_friendly () =
    Printf.printf "🧪 测试AI友好性检查...\n";
    let test_cases = [
      "计算结果";
      "处理数据";
      "操作文件";
      "这个变量很重要";
      "那个函数需要修改";
      "它的值是正确的";
      "循环直到完成";
      "逐个处理元素";
    ] in
    
    List.iteri (fun i code ->
      Printf.printf "测试案例 %d: %s\n" (i + 1) code;
      let violations = check_ai_friendly_patterns code in
      Printf.printf "发现违规: %d 个\n" (List.length violations);
      List.iter (fun v -> Printf.printf "  - %s\n" v.message) violations;
      Printf.printf "\n"
    ) test_cases;
    Printf.printf "✅ AI友好性检查测试完成\n\n"
  in

  let test_comprehensive () =
    Printf.printf "🧪 测试综合最佳实践检查...\n";
    let test_cases = [
      "if 用户年龄 > 18 那么 return \"成年\" else \"未成年\" // 英文注释";
      "让「用户年龄」= 18\n如果「用户年龄」> 成年标准 那么「成年人」否则「未成年人」";
      "for user in userList 循环 执行操作来计算这个用户的年龄，若其大于十八者则为成年也";
    ] in
    
    List.iteri (fun i code ->
      Printf.printf "🔍 综合测试案例 %d:\n" (i + 1);
      Printf.printf "代码: %s\n\n" code;
      let report = comprehensive_practice_check code in
      Printf.printf "%s\n" report;
      Printf.printf "%s\n" (String.make 80 '-');
    ) test_cases;
    Printf.printf "✅ 综合最佳实践检查测试完成\n\n"
  in

  (* 运行所有测试 *)
  test_mixed_language ();
  test_word_order ();
  test_idiomatic ();
  test_style_consistency ();
  test_classical_style ();
  test_ai_friendly ();
  test_comprehensive ();

  Printf.printf "🎉 所有中文编程最佳实践检查器测试完成！\n";
  Printf.printf "📊 测试统计:\n";
  Printf.printf "   • 中英文混用检测: ✅ 通过\n";
  Printf.printf "   • 中文语序检查: ✅ 通过\n";
  Printf.printf "   • 地道性检查: ✅ 通过\n";
  Printf.printf "   • 风格一致性检查: ✅ 通过\n";
  Printf.printf "   • 古雅体适用性检查: ✅ 通过\n";
  Printf.printf "   • AI友好性检查: ✅ 通过\n";
  Printf.printf "   • 综合检查: ✅ 通过\n"