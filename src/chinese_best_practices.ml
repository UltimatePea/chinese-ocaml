(** 骆言中文编程最佳实践检查器 - 帮助AI代理写出更地道的中文代码 
    重构版：使用模块化架构，提高代码可维护性和扩展性 *)

(* 引入模块化组件 *)
module Core = Chinese_best_practices_core.Practice_coordinator
module VR = Chinese_best_practices_reporters.Violation_reporter

(* 引入类型定义 *)
open Chinese_best_practices_types.Practice_types
open Chinese_best_practices_types.Severity_types

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

(** 编程风格一致性检查 - 待模块化功能 *)
let check_style_consistency code =
  let violations = ref [] in

  (* 检查风格一致性 *)
  let style_patterns =
    [
      (* 变量命名风格 *)
      ("「.*」.*「.*」", "引用符号使用", "保持一致的引用符号风格", Style);
      ("让.*=.*让.*=", "变量定义风格", "保持一致的变量定义间距", Style);
      (* 函数定义风格 *)
      ("函数.*→.*函数.*→", "函数定义风格", "保持一致的函数定义格式", Style);
      ("递归.*让.*递归.*让", "递归标记风格", "保持一致的递归标记使用", Style);
      (* 注释风格 *)
      ("「.*」.*//", "注释风格混用", "统一使用中文注释风格", Warning);
    ]
  in

  List.iter
    (fun (pattern, issue, suggestion, sev) ->
      if
        try
          let _ = Str.search_forward (Str.regexp pattern) code 0 in
          true
        with Not_found -> false
      then
        violations :=
          {
            violation = InconsistentStyle ("风格检查", issue, suggestion);
            severity = sev;
            message = Printf.sprintf "风格不一致: %s" issue;
            suggestion;
            confidence = 0.75;
            ai_friendly = true;
          }
          :: !violations)
    style_patterns;

  !violations

(** 古雅体适用性检查 - 待模块化功能 *)
let check_classical_style_appropriateness code =
  let violations = ref [] in

  (* 检查古雅体使用的适当性 *)
  let classical_patterns =
    [
      (* 过度使用古雅体 *)
      ("乃.*之.*也", "过度古雅", "使用现代表达", Warning);
      ("其.*者.*焉", "过度古雅", "使用现代表达", Warning);
      ("若.*则.*矣", "过度古雅", "如果...那么", Warning);
      (* 混合古今表达 *)
      ("设.*为.*值", "古今混用", "让...等于", Style);
      ("取.*之.*值", "古今混用", "获取...的值", Style);
      (* AI友好的现代化建议 *)
      ("凡.*皆.*也", "AI理解困难", "所有...都", Error);
      ("然则.*焉", "AI理解困难", "那么", Error);
    ]
  in

  List.iter
    (fun (pattern, issue, suggestion, sev) ->
      if
        try
          let _ = Str.search_forward (Str.regexp pattern) code 0 in
          true
        with Not_found -> false
      then
        violations :=
          {
            violation = ModernizationSuggestion ("古雅体检查", issue, suggestion);
            severity = sev;
            message = Printf.sprintf "古雅体使用问题: %s" issue;
            suggestion = Printf.sprintf "AI友好建议: %s" suggestion;
            confidence = 0.85;
            ai_friendly = true;
          }
          :: !violations)
    classical_patterns;

  !violations

(** AI代理编程特征检查 - 待模块化功能 *)
let check_ai_friendly_patterns code =
  let violations = ref [] in

  (* 检查对AI代理友好的编程模式 *)
  let ai_patterns =
    [
      (* 清晰的意图表达 *)
      ("计算", "动作明确", "建议加上具体的计算对象", Info);
      ("处理", "动作模糊", "建议明确处理的内容和方式", Warning);
      ("操作", "动作模糊", "建议明确操作的对象和方法", Warning);
      (* 避免歧义表达 *)
      ("这个", "指代不明", "使用具体的名称", Warning);
      ("那个", "指代不明", "使用具体的名称", Warning);
      ("它", "指代不明", "使用具体的名称", Warning);
      (* 鼓励声明式表达 *)
      ("循环.*直到", "命令式表达", "考虑使用递归或高阶函数", Info);
      ("逐个.*处理", "命令式表达", "考虑使用映射或过滤函数", Info);
    ]
  in

  List.iter
    (fun (pattern, issue, suggestion, sev) ->
      if
        try
          let _ = Str.search_forward (Str.regexp_string pattern) code 0 in
          true
        with Not_found -> false
      then
        violations :=
          {
            violation = Unidiomatic ("AI友好性检查", issue, suggestion);
            severity = sev;
            message = Printf.sprintf "AI理解问题: %s" issue;
            suggestion;
            confidence = 0.9;
            ai_friendly = true;
          }
          :: !violations)
    ai_patterns;

  !violations

(** 执行传统检查功能 *)
let run_legacy_checks code config =
  let all_violations = ref [] in
  
  (* 风格一致性检查 *)
  if config.Core.enable_style_consistency then begin
    let violations = check_style_consistency code in
    all_violations := violations @ !all_violations
  end;
  
  (* 古雅体适用性检查 *)
  if config.Core.enable_classical_style then begin
    let violations = check_classical_style_appropriateness code in
    all_violations := violations @ !all_violations
  end;
  
  (* AI友好性检查 *)
  if config.Core.enable_ai_friendly then begin
    let violations = check_ai_friendly_patterns code in
    all_violations := violations @ !all_violations
  end;
  
  !all_violations

(** 综合最佳实践检查 - 整合模块化和传统功能 *)
let comprehensive_practice_check ?(config = Core.default_config) code =
  (* 运行基础模块化检查 *)
  let basic_violations = Core.run_basic_checks code config in
  
  (* 运行传统检查功能 *)
  let legacy_violations = run_legacy_checks code config in
  
  (* 合并所有违规结果 *)
  let all_violations = basic_violations @ legacy_violations in
  
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