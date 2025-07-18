(** 骆言中文编程最佳实践检查器 - 帮助AI代理写出更地道的中文代码 *)

module RF = String_processing_utils.ReportFormatting
module BH = String_processing_utils.BufferHelpers

(** 最佳实践违规类型 *)
type practice_violation =
  | MixedLanguage of string * string * string (* 混用中英文：位置 * 中文部分 * 英文部分 *)
  | ImproperWordOrder of string * string * string (* 不当语序：位置 * 当前 * 建议 *)
  | Unidiomatic of string * string * string (* 不地道表达：位置 * 当前 * 建议 *)
  | InconsistentStyle of string * string * string (* 风格不一致：位置 * 当前风格 * 推荐风格 *)
  | ModernizationSuggestion of string * string * string (* 现代化建议：位置 * 古雅体 * 现代表达 *)

(** 违规严重度 *)
type severity =
  | Error (* 错误：必须修复 *)
  | Warning (* 警告：建议修复 *)
  | Info (* 信息：可选改进 *)
  | Style (* 风格：编码风格建议 *)

type practice_check_result = {
  violation : practice_violation;
  severity : severity;
  message : string;
  suggestion : string;
  confidence : float;
  ai_friendly : bool; (* 是否对AI友好 *)
}
(** 最佳实践检查结果 *)

(** 中英文混用模式检测 *)
let detect_mixed_language_patterns code =
  let violations = ref [] in

  (* 检测常见的中英文混用问题 *)
  let mixed_patterns =
    [
      (* 英文关键字混入中文代码 *)
      ("if.*那么", "if条件判断", "如果条件判断", Error);
      ("for.*循环", "for循环结构", "循环结构", Warning);
      ("function.*函数", "function函数定义", "函数定义", Warning);
      ("return.*返回", "return返回语句", "返回语句", Warning);
      (* 变量名混用 *)
      ("让.*[a-zA-Z]+.*=", "变量名使用英文", "使用中文变量名", Style);
      ("函数.*[a-zA-Z]+.*→", "函数名使用英文", "使用中文函数名", Style);
      (* 注释混用 *)
      ("//.*[一-龯]", "英文注释符配中文", "使用中文注释符「」", Info);
      ("/\\*.*[一-龯]", "英文注释符配中文", "使用中文注释符「」", Info);
    ]
  in

  List.iter
    (fun (pattern, current, suggestion, sev) ->
      if
        try
          let _ = Str.search_forward (Str.regexp pattern) code 0 in
          true
        with Not_found -> false
      then
        violations :=
          {
            violation = MixedLanguage ("代码中", current, suggestion);
            severity = sev;
            message = Printf.sprintf "检测到中英文混用: %s" current;
            suggestion = Printf.sprintf "建议改为: %s" suggestion;
            confidence = 0.8;
            ai_friendly = true;
          }
          :: !violations)
    mixed_patterns;

  !violations

(** 中文语序检查 *)
let check_chinese_word_order code =
  let violations = ref [] in

  (* 检查中文语序问题 *)
  let word_order_patterns =
    [
      (* 动宾语序 *)
      ("计算.*的.*值", "动宾分离", "值的计算", Info);
      ("获取.*的.*长度", "动宾分离", "长度的获取", Info);
      (* 修饰语位置 *)
      ("非常.*快速.*的", "修饰语冗余", "快速的", Style);
      ("最.*重要.*的", "修饰语冗余", "重要的", Style);
      (* 条件表达式语序 *)
      ("如果.*的话.*那么", "条件表达式冗余", "如果...那么", Warning);
      ("当.*的时候", "时间表达式冗余", "当...时", Warning);
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
            violation = ImproperWordOrder ("语序检查", issue, suggestion);
            severity = sev;
            message = Printf.sprintf "语序问题: %s" issue;
            suggestion = Printf.sprintf "建议语序: %s" suggestion;
            confidence = 0.7;
            ai_friendly = true;
          }
          :: !violations)
    word_order_patterns;

  !violations

(** 地道性检查 *)
let check_idiomatic_chinese code =
  let violations = ref [] in

  (* 检查不地道的中文表达 *)
  let idiomatic_patterns =
    [
      (* 计算机术语地道化 *)
      ("数据结构", "技术术语", "数据架构", Info);
      ("算法实现", "技术术语", "算法设计", Info);
      ("程序逻辑", "技术术语", "程序思路", Info);
      (* 动作表达地道化 *)
      ("执行操作", "动作表达", "进行操作", Style);
      ("进行计算", "动作表达", "计算", Style);
      ("完成任务", "动作表达", "完成工作", Style);
      (* 条件表达地道化 *)
      ("如果条件满足", "条件表达", "如果满足条件", Warning);
      ("当情况发生", "条件表达", "当发生情况", Warning);
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
            violation = Unidiomatic ("地道性检查", issue, suggestion);
            severity = sev;
            message = Printf.sprintf "不够地道的表达: %s" pattern;
            suggestion = Printf.sprintf "更地道的表达: %s" suggestion;
            confidence = 0.6;
            ai_friendly = true;
          }
          :: !violations)
    idiomatic_patterns;

  !violations

(** 编程风格一致性检查 *)
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

(** 古雅体适用性检查 *)
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

(** AI代理编程特征检查 *)
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

(** 综合最佳实践检查 *)
let comprehensive_practice_check code =
  let all_violations = ref [] in

  (* 执行所有检查 *)
  let checks =
    [
      detect_mixed_language_patterns;
      check_chinese_word_order;
      check_idiomatic_chinese;
      check_style_consistency;
      check_classical_style_appropriateness;
      check_ai_friendly_patterns;
    ]
  in
  let new_violations =
    List.fold_left
      (fun acc check ->
        let violations = check code in
        List.rev_append violations acc)
      [] checks
  in
  all_violations := List.rev_append new_violations !all_violations;

  (* 按严重度排序 *)
  let severity_order = function Error -> 0 | Warning -> 1 | Style -> 2 | Info -> 3 in

  List.sort
    (fun a b -> compare (severity_order a.severity) (severity_order b.severity))
    !all_violations

(** 生成成功报告 *)
let generate_success_report buffer =
  Buffer.add_string buffer "🎉 恭喜！您的代码符合所有中文编程最佳实践！\n";
  Buffer.add_string buffer "✅ 语言使用纯正\n";
  Buffer.add_string buffer "✅ 语序规范标准\n";
  Buffer.add_string buffer "✅ 表达地道自然\n";
  Buffer.add_string buffer "✅ 风格保持一致\n";
  Buffer.add_string buffer "✅ AI代理友好\n"

(** 统计违规数量 *)
let count_violations_by_severity violations =
  let error_count = List.length (List.filter (fun v -> v.severity = Error) violations) in
  let warning_count = List.length (List.filter (fun v -> v.severity = Warning) violations) in
  let style_count = List.length (List.filter (fun v -> v.severity = Style) violations) in
  let info_count = List.length (List.filter (fun v -> v.severity = Info) violations) in
  (error_count, warning_count, style_count, info_count)

(** 生成统计报告 *)
let generate_stats_report buffer (error_count, warning_count, style_count, info_count) =
  Buffer.add_string buffer "📊 检查结果统计:\n";
  BH.add_stats_batch buffer
    [
      ("🚨", "错误", error_count);
      ("⚠️", "警告", warning_count);
      ("🎨", "风格", style_count);
      ("💡", "提示", info_count);
    ];
  Buffer.add_string buffer "\n"

(** 获取严重性图标 *)
let get_severity_icon severity =
  match severity with
  | Error -> "🚨"
  | Warning -> "⚠️"
  | Style -> "🎨"
  | Info -> "💡"

(** 获取严重性文本 *)
let get_severity_text severity =
  match severity with
  | Error -> "错误"
  | Warning -> "警告"
  | Style -> "风格"
  | Info -> "提示"

(** 生成单个违规详细信息 *)
let generate_violation_detail buffer i violation =
  let severity_icon = get_severity_icon violation.severity in
  let severity_text = get_severity_text violation.severity in
  let ai_indicator = if violation.ai_friendly then " [AI友好]" else "" in

  Buffer.add_string buffer
    (Printf.sprintf "%d. %s [%s] %s%s\n" (i + 1) severity_icon severity_text
       violation.message ai_indicator);
  Buffer.add_string buffer (Printf.sprintf "   💡 建议: %s\n" violation.suggestion);
  Buffer.add_string buffer
    (Printf.sprintf "   🎯 置信度: %.0f%%\n\n" (violation.confidence *. 100.0))

(** 生成违规详细报告 *)
let generate_violation_details buffer violations =
  Buffer.add_string buffer "📝 详细检查结果:\n\n";
  List.iteri (generate_violation_detail buffer) violations

(** 生成改进建议 *)
let generate_improvement_suggestions buffer (error_count, warning_count, style_count, info_count) =
  Buffer.add_string buffer "🛠️ 总体改进建议:\n";
  if error_count > 0 then Buffer.add_string buffer "   1. 优先修复所有错误级别的问题，这些会影响AI代理的理解\n";
  if warning_count > 0 then Buffer.add_string buffer "   2. 处理警告级别的问题，提升代码的地道性\n";
  if style_count > 0 then Buffer.add_string buffer "   3. 统一编程风格，保持代码一致性\n";
  if info_count > 0 then Buffer.add_string buffer "   4. 考虑信息级别的建议，进一步优化表达\n"

(** 生成最佳实践报告 - 重构后的主函数 *)
let generate_practice_report violations =
  let buffer = Buffer.create (Constants.BufferSizes.large_buffer ()) in
  
  Buffer.add_string buffer "📋 中文编程最佳实践检查报告\n\n";
  
  if List.length violations = 0 then
    generate_success_report buffer
  else (
    let counts = count_violations_by_severity violations in
    generate_stats_report buffer counts;
    generate_violation_details buffer violations;
    generate_improvement_suggestions buffer counts);
  
  Buffer.contents buffer

(** 测试中文编程最佳实践检查器 *)
let test_chinese_best_practices () =
  Printf.printf "=== 中文编程最佳实践检查器测试 ===\n\n";

  let test_codes =
    [
      (* 测试1: 中英文混用 *)
      "if 年龄 > 18 那么 return \"成年人\" else \"未成年人\"";
      (* 测试2: 语序问题 *)
      "计算列表的长度的函数";
      (* 测试3: 不地道表达 *)
      "执行操作来进行计算程序逻辑";
      (* 测试4: 风格不一致 *)
      "让「用户名」= 张三// 用户姓名\n让 年龄 =25";
      (* 测试5: 过度古雅体 *)
      "设年龄为十八岁，若其大于十八者，则成年矣";
      (* 测试6: AI不友好表达 *)
      "处理这个数据，操作那个结果";
      (* 测试7: 良好的代码 *)
      "让「用户年龄」= 18\n如果「用户年龄」> 成年标准 那么「成年人」否则「未成年人」";
    ]
  in

  List.iteri
    (fun i code ->
      Printf.printf "🔍 测试案例 %d:\n" (i + 1);
      Printf.printf "代码: %s\n\n" code;

      let violations = comprehensive_practice_check code in
      let report = generate_practice_report violations in
      Printf.printf "%s\n" report;
      Printf.printf "%s\n" (String.make 80 '-'))
    test_codes;

  Printf.printf "🎉 中文编程最佳实践检查器测试完成！\n"
