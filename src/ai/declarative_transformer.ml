(* 声明式编程风格转换器 *)

(* 转换建议类型 *)
type transformation_suggestion = {
  original_code: string;           (* 原始代码 *)
  transformed_code: string;        (* 转换后代码 *)
  transformation_type: string;     (* 转换类型 *)
  confidence: float;               (* 置信度 0.0-1.0 *)
  explanation: string;             (* 转换说明 *)
  category: string;                (* 转换分类 *)
}

(* 命令式模式类型 *)
type imperative_pattern = {
  name: string;                    (* 模式名称 *)
  keywords: string list;           (* 关键识别词 *)
  pattern_regex: string;           (* 模式正则表达式 *)
  declarative_template: string;    (* 声明式模板 *)
  description: string;             (* 模式描述 *)
  examples: (string * string) list; (* 转换示例：(命令式, 声明式) *)
}

(* 预定义的命令式模式库 *)
let imperative_patterns = [
  {
    name = "循环累加模式";
    keywords = ["对于"; "每个"; "在"; "中"; "做"; "累加"; "总和"];
    pattern_regex = "对于[ ]*每个[ ]*\\([^ ]+\\)[ ]*在[ ]*\\([^ ]+\\)[ ]*中[ ]*做.*累加\\|总和";
    declarative_template = "从「{列表}」中「所有{元素}」的「{操作}」";
    description = "将循环累加转换为声明式集合操作";
    examples = [
      ("对于 每个 数字 在 列表 中 做 总和 := !总和 + 数字",
       "从「列表」中「所有数字」的「总和」");
      ("对于 每个 元素 在 数组 中 做 累加器 := !累加器 * 元素",
       "从「数组」中「所有元素」的「乘积」");
    ];
  };

  {
    name = "循环过滤模式";
    keywords = ["对于"; "每个"; "如果"; "那么"; "添加"; "过滤"];
    pattern_regex = "对于[ ]*每个[ ]*\\([^ ]+\\)[ ]*在[ ]*\\([^ ]+\\)[ ]*中[ ]*做.*如果.*那么.*添加";
    declarative_template = "从「{列表}」中「满足{条件}的{元素}」";
    description = "将循环过滤转换为声明式过滤操作";
    examples = [
      ("对于 每个 数字 在 列表 中 做 如果 数字 > 0 那么 添加 数字",
       "从「列表」中「满足 > 0 的数字」");
      ("对于 每个 项 在 数据 中 做 如果 有效 项 那么 收集 项",
       "从「数据」中「满足有效的项」");
    ];
  };

  {
    name = "循环映射模式";
    keywords = ["对于"; "每个"; "转换"; "映射"; "应用"];
    pattern_regex = "对于[ ]*每个[ ]*\\([^ ]+\\)[ ]*在[ ]*\\([^ ]+\\)[ ]*中[ ]*做.*转换\\|映射\\|应用";
    declarative_template = "从「{列表}」中「每个{元素}」应用「{函数}」";
    description = "将循环映射转换为声明式映射操作";
    examples = [
      ("对于 每个 数字 在 列表 中 做 结果 := 数字 * 2",
       "从「列表」中「每个数字」应用「乘以2」");
      ("对于 每个 字符串 在 文本列表 中 做 转换为大写",
       "从「文本列表」中「每个字符串」应用「转换为大写」");
    ];
  };

  {
    name = "引用更新模式";
    keywords = ["引用"; ":="; "更新"; "修改"];
    pattern_regex = "\\([^ ]+\\)[ ]*:=[ ]*.*";
    declarative_template = "让「{变量}」被更新为「{新值}」";
    description = "将引用更新转换为声明式赋值";
    examples = [
      ("计数器 := !计数器 + 1", "让「计数器」被更新为「计数器 + 1」");
      ("状态 := 新状态", "让「状态」被更新为「新状态」");
    ];
  };

  {
    name = "命令式条件模式";
    keywords = ["如果"; "那么"; "执行"; "设置"; "调用"];
    pattern_regex = "如果[ ]*\\([^那]+\\)[ ]*那么[ ]*\\([^否]+\\)";
    declarative_template = "当「{条件}」时「{操作}」";
    description = "将命令式条件转换为声明式条件表达";
    examples = [
      ("如果 x > 0 那么 设置 结果 为 x", "当「x > 0」时「结果 = x」");
      ("如果 文件存在 那么 执行 读取操作", "当「文件存在」时「执行读取操作」");
    ];
  };

  {
    name = "递归累加器模式";
    keywords = ["递归"; "辅助"; "累加器"; "尾递归"];
    pattern_regex = "让[ ]*辅助.*=[ ]*函数.*累加器";
    declarative_template = "通过「{操作}」处理「{数据}」得到「{结果}」";
    description = "将尾递归累加器转换为声明式处理表达";
    examples = [
      ("让 辅助 = 函数 累加器 列表 → 匹配 列表 与 | [] → 累加器",
       "通过「累加」处理「列表」得到「最终结果」");
    ];
  };
]

(* 中文操作词映射 *)
let operation_mapping = [
  ("加", "总和");
  ("乘", "乘积");
  ("连接", "连接");
  ("合并", "合并");
  ("计数", "计数");
  ("最大", "最大值");
  ("最小", "最小值");
  ("平均", "平均值");
]

(* 检查字符串是否匹配模式 *)
let matches_pattern (code: string) (pattern: imperative_pattern) : bool =
  try
    let regex = Str.regexp pattern.pattern_regex in
    Str.string_match regex code 0
  with _ -> false

(* 提取模式中的关键信息 *)
let extract_pattern_info (code: string) (_pattern: imperative_pattern) : (string * string) list =
  let params = ref [] in

  (* 提取列表名 *)
  let list_regex = Str.regexp "在[ ]*\\([^ ]+\\)[ ]*中" in
  if Str.string_match list_regex code 0 then (
    let list_name = Str.matched_group 1 code in
    params := ("列表", list_name) :: !params
  );

  (* 提取元素名 *)
  let element_regex = Str.regexp "每个[ ]*\\([^ ]+\\)" in
  if Str.string_match element_regex code 0 then (
    let element_name = Str.matched_group 1 code in
    params := ("元素", element_name) :: !params
  );

  (* 提取操作类型 *)
  let operation = ref "处理" in
  List.iter (fun (op, name) ->
    if String.contains code (String.get op 0) then
      operation := name
  ) operation_mapping;
  params := ("操作", !operation) :: !params;

  (* 提取条件（如果存在） *)
  let condition_regex = Str.regexp "如果[ ]*\\([^那]+\\)[ ]*那么" in
  if Str.string_match condition_regex code 0 then (
    let condition = Str.matched_group 1 code in
    params := ("条件", String.trim condition) :: !params
  );

  (* 提取函数（如果存在） *)
  let function_regex = Str.regexp "应用[ ]*\\([^ ]+\\)\\|转换[ ]*\\([^ ]+\\)" in
  if Str.string_match function_regex code 0 then (
    try
      let func = Str.matched_group 1 code in
      params := ("函数", func) :: !params
    with _ ->
      try
        let func = Str.matched_group 2 code in
        params := ("函数", func) :: !params
      with _ -> ()
  );

  !params

(* 应用模板替换 *)
let apply_template_substitution (template: string) (params: (string * string) list) : string =
  let result = ref template in
  List.iter (fun (key, value) ->
    let placeholder = "{" ^ key ^ "}" in
    result := Str.global_replace (Str.regexp_string placeholder) value !result
  ) params;

  (* 清理未替换的占位符 *)
  result := Str.global_replace (Str.regexp "{[^}]+}") "..." !result;
  !result

(* 计算转换置信度 *)
let calculate_confidence (code: string) (pattern: imperative_pattern) : float =
  let keyword_matches = ref 0 in
  let total_keywords = List.length pattern.keywords in

  List.iter (fun keyword ->
    if String.contains code (String.get keyword 0) then
      incr keyword_matches
  ) pattern.keywords;

  let keyword_score = float_of_int !keyword_matches /. float_of_int total_keywords in

  (* 基于代码长度的调整 *)
  let length_penalty = if String.length code > 100 then 0.9 else 1.0 in

  (* 基于模式匹配质量的调整 *)
  let pattern_match_score = if matches_pattern code pattern then 1.0 else 0.5 in

  keyword_score *. length_penalty *. pattern_match_score

(* 生成转换建议 *)
let generate_transformation_suggestion (code: string) (pattern: imperative_pattern) : transformation_suggestion =
  let params = extract_pattern_info code pattern in
  let transformed = apply_template_substitution pattern.declarative_template params in
  let confidence = calculate_confidence code pattern in

  {
    original_code = code;
    transformed_code = transformed;
    transformation_type = pattern.name;
    confidence = confidence;
    explanation = pattern.description;
    category = "声明式转换";
  }

(* 识别并建议转换 *)
let analyze_and_suggest (code: string) : transformation_suggestion list =
  let suggestions = ref [] in

  List.iter (fun pattern ->
    if matches_pattern code pattern ||
       List.exists (fun keyword -> String.contains code (String.get keyword 0)) pattern.keywords then (
      let suggestion = generate_transformation_suggestion code pattern in
      if suggestion.confidence > 0.3 then
        suggestions := suggestion :: !suggestions
    )
  ) imperative_patterns;

  (* 按置信度排序 *)
  List.sort (fun s1 s2 -> compare s2.confidence s1.confidence) !suggestions

(* 应用转换建议 *)
let apply_transformation (_original_code: string) (suggestion: transformation_suggestion) : string =
  suggestion.transformed_code

(* 批量分析代码 *)
let analyze_code_block (code_lines: string list) : transformation_suggestion list =
  let all_suggestions = ref [] in

  List.iteri (fun i line ->
    let suggestions = analyze_and_suggest line in
    List.iter (fun s ->
      let enhanced_suggestion = {
        s with
        original_code = Printf.sprintf "第%d行: %s" (i + 1) s.original_code;
      } in
      all_suggestions := enhanced_suggestion :: !all_suggestions
    ) suggestions
  ) code_lines;

  List.rev !all_suggestions

(* 格式化转换建议 *)
let format_suggestion (suggestion: transformation_suggestion) : string =
  Printf.sprintf "🔄 转换建议 [%.0f%%置信度]
原始代码: %s
转换后: %s
转换类型: %s
说明: %s
分类: %s\n"
    (suggestion.confidence *. 100.0)
    suggestion.original_code
    suggestion.transformed_code
    suggestion.transformation_type
    suggestion.explanation
    suggestion.category

(* 批量格式化建议 *)
let format_suggestions (suggestions: transformation_suggestion list) : string =
  if List.length suggestions = 0 then
    "🔍 未发现可转换的命令式模式"
  else
    let formatted = List.mapi (fun i s ->
      Printf.sprintf "%d. %s" (i + 1) (format_suggestion s)
    ) suggestions in
    String.concat "\n" formatted

(* 生成转换报告 *)
let generate_transformation_report (suggestions: transformation_suggestion list) : string =
  let total = List.length suggestions in
  let high_confidence = List.length (List.filter (fun s -> s.confidence > 0.8) suggestions) in
  let medium_confidence = List.length (List.filter (fun s -> s.confidence > 0.5 && s.confidence <= 0.8) suggestions) in
  let low_confidence = total - high_confidence - medium_confidence in

  Printf.sprintf "📋 声明式编程风格转换报告
========================================

📊 转换建议统计:
   🚨 高置信度: %d 个
   ⚠️ 中置信度: %d 个
   💡 低置信度: %d 个
   📈 总计: %d 个建议

📝 详细建议:

%s

🛠️ 优先级建议:
   1. 优先处理高置信度建议，这些转换效果最佳
   2. 考虑中置信度建议，可以进一步提升代码声明式程度
   3. 低置信度建议仅作参考

---
🤖 Generated with 声明式编程风格转换器
"
    high_confidence
    medium_confidence
    low_confidence
    total
    (format_suggestions suggestions)

(* 智能代码分析 *)
let intelligent_analysis (code: string) : string =
  let lines = String.split_on_char '\n' code in
  let suggestions = analyze_code_block lines in
  generate_transformation_report suggestions

(* 检测特定的声明式模式机会 *)
let detect_declarative_opportunities (code: string) : string list =
  let opportunities = ref [] in

  (* 检测循环模式 *)
  if Str.string_match (Str.regexp ".*对于.*每个.*") code 0 then
    opportunities := "考虑使用集合操作替代显式循环" :: !opportunities;

  (* 检测引用模式 *)
  if String.contains code ':' && String.contains code '=' then
    opportunities := "考虑使用不可变数据结构" :: !opportunities;

  (* 检测累加器模式 *)
  if Str.string_match (Str.regexp ".*累.*辅.*") code 0 then
    opportunities := "考虑使用高阶函数替代累加器模式" :: !opportunities;

  (* 检测命令式条件 *)
  if Str.string_match (Str.regexp ".*设.*那.*") code 0 then
    opportunities := "考虑使用表达式而非语句" :: !opportunities;

  !opportunities

(* 测试转换器功能 *)
let test_declarative_transformer () =
  let test_cases = [
    "对于 每个 数字 在 列表 中 做 总和 := !总和 + 数字";
    "对于 每个 元素 在 数组 中 做 如果 元素 > 0 那么 添加 元素";
    "对于 每个 字符串 在 文本列表 中 做 转换为大写 字符串";
    "计数器 := !计数器 + 1";
    "如果 x > 0 那么 设置 结果 为 x";
    "让 辅助 = 函数 累加器 列表 → 匹配 列表 与 | [] → 累加器";
  ] in

  Printf.printf "🧪 开始声明式编程风格转换器测试...\n\n";

  List.iter (fun code ->
    Printf.printf "🔍 测试代码: %s\n" code;
    let suggestions = analyze_and_suggest code in
    if List.length suggestions > 0 then (
      Printf.printf "✅ 找到 %d 个转换建议:\n" (List.length suggestions);
      List.iteri (fun i s ->
        Printf.printf "   %d. %s → %s (%.0f%%)\n"
          (i + 1) s.transformation_type s.transformed_code (s.confidence *. 100.0)
      ) suggestions
    ) else (
      Printf.printf "❌ 未找到适用的转换\n"
    );
    Printf.printf "\n"
  ) test_cases;

  Printf.printf "🎉 声明式编程风格转换器测试完成！\n"