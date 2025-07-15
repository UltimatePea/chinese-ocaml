(* 编程模式匹配库 *)

(* 编程模式类型 *)
type programming_pattern = {
  name : string; (* 模式名称 *)
  keywords : string list; (* 关键词 *)
  template : string; (* 代码模板 *)
  description : string; (* 描述 *)
  category : string; (* 分类 *)
  complexity : int; (* 复杂度 1-5 *)
  examples : string list; (* 示例 *)
}

(* 模式匹配结果 *)
type pattern_match = {
  pattern : programming_pattern; (* 匹配的模式 *)
  confidence : float; (* 匹配置信度 *)
  extracted_params : (string * string) list; (* 提取的参数 *)
}

(* 预定义编程模式库 *)
let pattern_library =
  [
    {
      name = "递归函数模式";
      keywords = [ "递归"; "函数"; "调用自己" ];
      template = "递归 让 「{函数名}」 = 函数 {参数} →\n  匹配 {参数} 与\n  ｜ {基础情况} → {基础结果}\n  ｜ _ → {递归表达式}";
      description = "定义递归函数的标准模式";
      category = "函数定义";
      complexity = 3;
      examples = [ "阶乘计算"; "斐波那契数列"; "树遍历"; "列表处理" ];
    };
    {
      name = "列表处理模式";
      keywords = [ "列表"; "头"; "尾"; "空列表" ];
      template = "匹配 {列表} 与\n｜ [] → {空列表处理}\n｜ 头 :: 尾 → {元素处理}";
      description = "处理列表数据结构的标准模式";
      category = "数据处理";
      complexity = 2;
      examples = [ "列表求和"; "列表过滤"; "列表映射"; "列表长度计算" ];
    };
    {
      name = "条件分支模式";
      keywords = [ "如果"; "那么"; "否则"; "条件" ];
      template = "如果 {条件} 那么 {真分支} 否则 {假分支}";
      description = "条件判断的标准模式";
      category = "控制流";
      complexity = 1;
      examples = [ "数值比较"; "状态检查"; "有效性验证"; "范围判断" ];
    };
    {
      name = "模式匹配模式";
      keywords = [ "匹配"; "与"; "模式" ];
      template = "匹配 {表达式} 与\n｜ {模式1} → {结果1}\n｜ {模式2} → {结果2}\n｜ _ → {默认结果}";
      description = "使用模式匹配处理不同情况";
      category = "控制流";
      complexity = 2;
      examples = [ "选项类型处理"; "变体类型匹配"; "复合数据解构"; "错误处理" ];
    };
    {
      name = "累加器模式";
      keywords = [ "累加"; "累积"; "状态"; "辅助函数" ];
      template =
        "让 辅助函数 = 函数 {累加器} {剩余输入} →\n\
        \  匹配 {剩余输入} 与\n\
        \  ｜ {结束条件} → {累加器}\n\
        \  ｜ _ → 辅助函数 {更新累加器} {缩减输入}\n\
         于 辅助函数 {初始累加器} {输入}";
      description = "使用累加器优化递归的模式";
      category = "性能优化";
      complexity = 4;
      examples = [ "尾递归求和"; "列表反转"; "累积计算"; "状态机实现" ];
    };
    {
      name = "高阶函数模式";
      keywords = [ "函数"; "作为参数"; "返回函数"; "组合" ];
      template = "让 {高阶函数名} = 函数 {函数参数} {其他参数} →\n  {函数参数} {应用}";
      description = "将函数作为参数或返回值的模式";
      category = "函数式编程";
      complexity = 3;
      examples = [ "映射函数"; "过滤函数"; "折叠函数"; "函数组合" ];
    };
    {
      name = "数据变换模式";
      keywords = [ "映射"; "转换"; "变换"; "处理" ];
      template =
        "让 {变换函数} = 函数 {转换器} {数据} →\n\
        \  匹配 {数据} 与\n\
        \  ｜ [] → []\n\
        \  ｜ 元素 :: 其余 → {转换器} 元素 :: {变换函数} {转换器} 其余";
      description = "数据变换和映射的标准模式";
      category = "数据处理";
      complexity = 2;
      examples = [ "类型转换"; "数据清洗"; "格式变换"; "结构调整" ];
    };
    {
      name = "错误处理模式";
      keywords = [ "错误"; "异常"; "选项"; "结果" ];
      template = "匹配 {可能出错的操作} 与\n｜ 无 → {错误处理}\n｜ 有 {值} → {成功处理}";
      description = "安全处理可能失败的操作";
      category = "错误处理";
      complexity = 2;
      examples = [ "文件读取"; "网络请求"; "类型转换"; "数据验证" ];
    };
    {
      name = "分治算法模式";
      keywords = [ "分治"; "分割"; "合并"; "递归" ];
      template =
        "让 {分治函数} = 函数 {输入} →\n\
        \  如果 {基础情况} 那么 {直接解决}\n\
        \  否则\n\
        \    让 {子问题1} = {分割1} {输入} 以及\n\
        \    让 {子问题2} = {分割2} {输入} 于\n\
        \    {合并} ({分治函数} {子问题1}) ({分治函数} {子问题2})";
      description = "分治算法的经典模式";
      category = "算法设计";
      complexity = 4;
      examples = [ "归并排序"; "快速排序"; "二分查找"; "大整数乘法" ];
    };
    {
      name = "状态机模式";
      keywords = [ "状态"; "转换"; "事件"; "状态机" ];
      template =
        "让 {状态机} = 函数 {当前状态} {事件} →\n\
        \  匹配 ({当前状态}, {事件}) 与\n\
        \  ｜ ({状态1}, {事件1}) → {新状态1}\n\
        \  ｜ ({状态2}, {事件2}) → {新状态2}\n\
        \  ｜ _ → {当前状态}";
      description = "有限状态机的实现模式";
      category = "系统设计";
      complexity = 3;
      examples = [ "解析器状态"; "游戏状态"; "协议状态"; "用户界面状态" ];
    };
  ]

(* 计算文本相似度 *)
let calculate_similarity (text1 : string) (text2 : string) : float =
  let words1 = String.split_on_char ' ' (String.lowercase_ascii text1) in
  let words2 = String.split_on_char ' ' (String.lowercase_ascii text2) in

  let intersection = List.filter (fun w -> List.mem w words2) words1 in
  let union_size = List.length words1 + List.length words2 - List.length intersection in

  if union_size = 0 then 1.0 else float_of_int (List.length intersection) /. float_of_int union_size

(* 检查关键词匹配 *)
let check_keyword_match (input : string) (keywords : string list) : float =
  let input_lower = String.lowercase_ascii input in
  let matches =
    List.filter
      (fun keyword ->
        String.contains input_lower (String.get (String.lowercase_ascii keyword) 0)
        || List.exists
             (fun word -> String.contains word (String.get keyword 0))
             (String.split_on_char ' ' input_lower))
      keywords
  in

  if List.length keywords = 0 then 0.0
  else float_of_int (List.length matches) /. float_of_int (List.length keywords)

(* 提取参数 *)
let extract_parameters (input : string) (_pattern : programming_pattern) : (string * string) list =
  (* 简化的参数提取 - 在实际应用中需要更复杂的解析 *)
  let params = ref [] in

  (* 提取函数名 *)
  let function_regex = Str.regexp "\\(函数\\|定义\\)[ ]*\\([^  \n]+\\)" in
  if Str.string_match function_regex input 0 then
    params := ("函数名", Str.matched_group 2 input) :: !params;

  (* 提取变量名 *)
  let var_regex = Str.regexp "让[ ]*\\([^  =\n]+\\)" in
  if Str.string_match var_regex input 0 then params := ("变量名", Str.matched_group 1 input) :: !params;

  !params

(* 匹配编程模式 *)
let match_pattern (input : string) (pattern : programming_pattern) : pattern_match =
  let keyword_score = check_keyword_match input pattern.keywords in
  let similarity_score = calculate_similarity input pattern.description in

  (* 综合计算置信度 *)
  let confidence = (keyword_score *. 0.7) +. (similarity_score *. 0.3) in

  let extracted_params = extract_parameters input pattern in

  { pattern; confidence; extracted_params }

(* 查找最佳匹配模式 *)
let find_best_patterns (input : string) (max_results : int) : pattern_match list =
  let matches = List.map (match_pattern input) pattern_library in
  let sorted_matches = List.sort (fun m1 m2 -> compare m2.confidence m1.confidence) matches in

  (* 过滤低置信度的匹配 *)
  let filtered_matches = List.filter (fun m -> m.confidence > 0.1) sorted_matches in

  (* 返回前max_results个结果 *)
  let rec take n = function [] -> [] | h :: t when n > 0 -> h :: take (n - 1) t | _ -> [] in
  take max_results filtered_matches

(* 生成基于模式的代码 *)
let generate_code_from_pattern (pattern_match : pattern_match) : string =
  let template = pattern_match.pattern.template in
  let params = pattern_match.extracted_params in

  (* 替换模板中的参数 *)
  let rec replace_params template = function
    | [] -> template
    | (param_name, param_value) :: rest ->
        let placeholder = "{" ^ param_name ^ "}" in
        let new_template =
          Str.global_replace (Str.regexp_string placeholder) param_value template
        in
        replace_params new_template rest
  in

  let code = replace_params template params in

  (* 如果还有未替换的占位符，用默认值替换 *)
  let code_with_defaults = Str.global_replace (Str.regexp "{[^}]+}") "..." code in
  code_with_defaults

(* 分析代码意图 *)
let analyze_code_intent (code : string) : string =
  let matches = find_best_patterns code 3 in
  match matches with
  | [] -> "无法识别代码模式"
  | best_match :: _ ->
      Printf.sprintf "检测到 %s 模式 (置信度: %.0f%%)\n描述: %s" best_match.pattern.name
        (best_match.confidence *. 100.0) best_match.pattern.description

(* 推荐相关模式 *)
let recommend_related_patterns (current_pattern : programming_pattern) : programming_pattern list =
  let same_category =
    List.filter
      (fun p -> p.category = current_pattern.category && p.name <> current_pattern.name)
      pattern_library
  in

  let similar_complexity =
    List.filter
      (fun p ->
        abs (p.complexity - current_pattern.complexity) <= 1 && p.name <> current_pattern.name)
      pattern_library
  in

  (* 去重并限制数量 *)
  let combined = same_category @ similar_complexity in
  let unique =
    List.fold_left
      (fun acc p ->
        if List.exists (fun existing -> existing.name = p.name) acc then acc else p :: acc)
      [] combined
  in

  List.rev
    (if List.length unique > 3 then List.rev (List.tl (List.tl (List.rev unique))) else unique)

(* 格式化模式匹配结果 *)
let format_pattern_match (pattern_match : pattern_match) : string =
  let params_str =
    String.concat ", " (List.map (fun (k, v) -> k ^ "=" ^ v) pattern_match.extracted_params)
  in
  Printf.sprintf "模式: %s [%.0f%%]\n分类: %s (复杂度: %d)\n描述: %s\n参数: %s\n示例: %s"
    pattern_match.pattern.name
    (pattern_match.confidence *. 100.0)
    pattern_match.pattern.category pattern_match.pattern.complexity
    pattern_match.pattern.description
    (if params_str = "" then "无" else params_str)
    (String.concat ", " pattern_match.pattern.examples)

(* 测试模式匹配功能 *)
let test_pattern_matching () =
  let test_cases =
    [ "创建一个递归函数计算阶乘"; "处理列表中的每个元素"; "使用条件判断检查数值"; "匹配不同的情况并处理"; "实现快速排序算法"; "定义状态机处理事件" ]
  in

  List.iter
    (fun input ->
      Printf.printf "\n=== 模式匹配测试: %s ===\n" input;
      let matches = find_best_patterns input 3 in
      List.iteri
        (fun i m ->
          Printf.printf "\n%d. %s\n" (i + 1) (format_pattern_match m);
          Printf.printf "生成代码:\n%s\n" (generate_code_from_pattern m))
        matches;

      Printf.printf "\n--- 代码意图分析 ---\n";
      Printf.printf "%s\n" (analyze_code_intent input))
    test_cases
