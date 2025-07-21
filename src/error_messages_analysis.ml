(** 错误消息智能分析模块 - Error Message Analysis Module *)

module CF = String_processing_utils.CollectionFormatting
module RF = String_processing_utils.ReportFormatting

type error_analysis = {
  error_type : string;
  error_message : string;
  context : string option;
  suggestions : string list;
  fix_hints : string list;
  confidence : float;
}
(** 错误分析类型定义 *)

(** 智能变量名相似度计算 *)
let levenshtein_distance s1 s2 =
  let len1 = String.length s1 and len2 = String.length s2 in
  let matrix = Array.make_matrix (len1 + 1) (len2 + 1) 0 in
  for i = 0 to len1 do
    matrix.(i).(0) <- i
  done;
  for j = 0 to len2 do
    matrix.(0).(j) <- j
  done;
  for i = 1 to len1 do
    for j = 1 to len2 do
      let cost = if s1.[i - 1] = s2.[j - 1] then 0 else 1 in
      matrix.(i).(j) <-
        min
          (min (matrix.(i - 1).(j) + 1) (* 删除 *) (matrix.(i).(j - 1) + 1)) (* 插入 *)
          (matrix.(i - 1).(j - 1) + cost)
      (* 替换 *)
    done
  done;
  matrix.(len1).(len2)

(** 计算相似度分数 *)
let calculate_similarity_score target_var var =
  let distance = levenshtein_distance target_var var in
  let max_len = max (String.length target_var) (String.length var) in
  1.0 -. (float_of_int distance /. float_of_int max_len)

(** 寻找相似变量名 *)
let find_similar_variables target_var available_vars =
  let similarities =
    List.map
      (fun var ->
        let similarity = calculate_similarity_score target_var var in
        (var, similarity))
      available_vars
  in
  let sorted = List.sort (fun (_, s1) (_, s2) -> compare s2 s1) similarities in
  List.filter (fun (_, similarity) -> similarity > 0.6) sorted

(** 提取前N个元素的辅助函数 *)
let take_n n lst =
  let rec take n lst =
    if n <= 0 then [] else match lst with [] -> [] | h :: t -> h :: take (n - 1) t
  in
  take n lst

(** 生成未定义变量建议 *)
let generate_undefined_variable_suggestions available_vars similar_vars =
  match similar_vars with
  | [] when List.length available_vars = 0 -> [ "当前作用域中没有可用变量，检查是否需要先定义变量" ]
  | [] ->
      [
        "检查变量名拼写是否正确";
        "确认变量是否在当前作用域中定义";
        "可用变量: " ^ CF.join_chinese (take_n 5 available_vars);
      ]
  | (best_match, score) :: others when score > 0.8 ->
      [
        RF.similarity_suggestion best_match score;
        "或检查其他相似变量: " ^ CF.join_chinese (List.map fst (take_n 3 others));
      ]
  | similar ->
      let mapped_similar =
        List.map
          (fun (var, score) -> "  " ^ RF.similarity_suggestion var score)
          (take_n 5 similar)
      in
      "可能的相似变量:" :: mapped_similar

(** 生成未定义变量修复提示 *)
let generate_undefined_variable_fix_hints var_name similar_vars =
  match similar_vars with
  | (best_match, score) :: _ when score > 0.8 -> [ RF.suggestion_line var_name best_match ]
  | _ -> [ Unified_formatter.General.format_variable_definition var_name ]

(** 分析未定义变量错误 *)
let analyze_undefined_variable var_name available_vars =
  let similar_vars = find_similar_variables var_name available_vars in
  let suggestions = generate_undefined_variable_suggestions available_vars similar_vars in
  let fix_hints = generate_undefined_variable_fix_hints var_name similar_vars in
  {
    error_type = "undefined_variable";
    error_message = Unified_formatter.ErrorMessages.undefined_variable var_name;
    context = Some (Unified_formatter.General.format_context_info (List.length available_vars) "变量");
    suggestions;
    fix_hints;
    confidence = (if List.length similar_vars > 0 then 0.9 else 0.7);
  }

(** 生成类型不匹配建议 *)
let generate_type_mismatch_suggestions expected_type actual_type =
  match (expected_type, actual_type) with
  | "整数类型", "字符串类型" -> [ "尝试将字符串转换为整数: 转换为整数 「字符串值」"; "检查是否误用了字符串字面量而非数字" ]
  | "字符串类型", "整数类型" -> [ "尝试将整数转换为字符串: 转换为字符串 数字值"; "检查是否需要字符串插值" ]
  | "列表类型", _ -> [ "检查是否遗漏了方括号: [元素1; 元素2]"; "确认是否需要将单个值包装为列表" ]
  | _, "列表类型" -> [ "检查是否需要从列表中提取元素"; "考虑使用列表访问操作" ]
  | "函数类型", _ -> [ "检查是否遗漏了函数调用的参数"; "确认变量是否是函数" ]
  | _, "函数类型" -> [ "检查是否误将函数当作值使用"; "确认是否需要调用函数" ]
  | _ -> [ "检查表达式的类型是否正确"; "考虑是否需要类型转换" ]

(** 生成类型不匹配修复提示 *)
let generate_type_mismatch_fix_hints expected_type actual_type =
  match (expected_type, actual_type) with
  | "整数类型", "字符串类型" -> [ "添加类型转换: (转换为整数 值)" ]
  | "字符串类型", "整数类型" -> [ "添加类型转换: (转换为字符串 值)" ]
  | _ -> [ "检查并修正表达式类型" ]

(** 分析类型不匹配错误 *)
let analyze_type_mismatch expected_type actual_type =
  let type_suggestions = generate_type_mismatch_suggestions expected_type actual_type in
  let fix_hints = generate_type_mismatch_fix_hints expected_type actual_type in
  {
    error_type = "type_mismatch";
    error_message = Unified_formatter.ErrorMessages.type_mismatch expected_type actual_type;
    context = Some "类型系统检查";
    suggestions = type_suggestions;
    fix_hints;
    confidence = 0.85;
  }

(** 生成函数参数错误建议 *)
let generate_function_arity_suggestions expected_count actual_count function_name =
  if actual_count < expected_count then
    [
      Unified_formatter.ErrorMessages.function_needs_params function_name expected_count
        actual_count;
      "检查是否遗漏了参数";
      "确认函数调用的参数顺序";
    ]
  else
    [
      Unified_formatter.ErrorMessages.function_excess_params function_name expected_count
        actual_count;
      "检查是否提供了多余的参数";
      "确认是否调用了正确的函数";
    ]

(** 生成函数参数错误修复提示 *)
let generate_function_arity_fix_hints expected_count actual_count =
  if actual_count < expected_count then
    [ Printf.sprintf "添加缺失的 %d 个参数" (expected_count - actual_count) ]
  else [ Printf.sprintf "移除多余的 %d 个参数" (actual_count - expected_count) ]

(** 分析函数参数错误 *)
let analyze_function_arity expected_count actual_count function_name =
  let suggestions = generate_function_arity_suggestions expected_count actual_count function_name in
  let fix_hints = generate_function_arity_fix_hints expected_count actual_count in
  {
    error_type = "function_arity";
    error_message = Printf.sprintf "函数参数数量不匹配: 期望 %d 个，提供了 %d 个" expected_count actual_count;
    context = Some (Printf.sprintf "函数: %s" function_name);
    suggestions;
    fix_hints;
    confidence = 0.95;
  }

(** 生成模式匹配错误建议 *)
let generate_pattern_match_suggestions missing_patterns =
  let mapped_patterns =
    List.map (fun pattern -> Printf.sprintf "缺少模式: %s" pattern) missing_patterns
  in
  let base_suggestions = [ "模式匹配必须覆盖所有可能的情况"; "考虑添加通配符模式 _ 作为默认情况" ] in
  base_suggestions @ mapped_patterns

(** 生成模式匹配错误修复提示 *)
let generate_pattern_match_fix_hints missing_patterns =
  if List.length missing_patterns > 0 then
    List.map (fun pattern -> Printf.sprintf "添加分支: ｜ %s → 结果" pattern) missing_patterns
  else [ "添加通配符分支: ｜ _ → 默认结果" ]

(** 分析模式匹配错误 *)
let analyze_pattern_match_error missing_patterns =
  let suggestions = generate_pattern_match_suggestions missing_patterns in
  let fix_hints = generate_pattern_match_fix_hints missing_patterns in
  {
    error_type = "pattern_match";
    error_message = "模式匹配不完整";
    context = Some "模式匹配表达式";
    suggestions;
    fix_hints;
    confidence = 0.8;
  }

(** 解析未定义变量错误详情 *)
let parse_undefined_variable_details error_details =
  match error_details with
  | [ var; vars ] -> (var, String.split_on_char ';' vars)
  | [ var ] -> (var, [])
  | _ -> ("未知变量", [])

(** 解析类型不匹配错误详情 *)
let parse_type_mismatch_details error_details =
  match error_details with [ exp; act ] -> (exp, act) | _ -> ("未知类型", "未知类型")

(** 解析函数参数错误详情 *)
let parse_function_arity_details error_details =
  match error_details with
  | [ exp; act; name ] -> (exp, act, name)
  | [ exp; act ] -> (exp, act, "函数")
  | _ -> ("0", "0", "未知函数")

(** 创建默认错误分析 *)
let create_default_error_analysis error_type context =
  {
    error_type;
    error_message = "未知错误类型";
    context;
    suggestions = [ "查看文档或使用调试模式获取更多信息" ];
    fix_hints = [ "检查代码语法和逻辑" ];
    confidence = 0.5;
  }

(** 智能错误分析主函数 *)
let intelligent_error_analysis error_type error_details context =
  match error_type with
  | "undefined_variable" ->
      let var_name, available_vars = parse_undefined_variable_details error_details in
      analyze_undefined_variable var_name available_vars
  | "type_mismatch" ->
      let expected, actual = parse_type_mismatch_details error_details in
      analyze_type_mismatch expected actual
  | "function_arity" ->
      let expected_str, actual_str, func_name = parse_function_arity_details error_details in
      let expected_count = try int_of_string expected_str with _ -> 0 in
      let actual_count = try int_of_string actual_str with _ -> 0 in
      analyze_function_arity expected_count actual_count func_name
  | "pattern_match" ->
      let missing_patterns = match error_details with patterns -> patterns in
      analyze_pattern_match_error missing_patterns
  | _ ->
      create_default_error_analysis error_type context
