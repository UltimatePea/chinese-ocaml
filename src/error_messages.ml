(** 骆言错误消息模块 - Chinese Programming Language Error Messages *)

open Types
module EMT = String_processing_utils.ErrorMessageTemplates
module CF = String_processing_utils.CollectionFormatting
module RF = String_processing_utils.ReportFormatting

(** 将英文类型错误转换为中文 *)
let chinese_type_error_message msg =
  let replacements =
    [
      ("Cannot unify types:", "无法统一类型:");
      ("with", "与");
      ("Occurs check failure:", "循环类型检查失败:");
      ("occurs in", "出现在");
      ("Type list length mismatch", "类型列表长度不匹配");
      ("Undefined variable:", "未定义的变量:");
      ("Match expression must have at least one branch", "匹配表达式必须至少有一个分支");
      ("Macro calls not yet supported", "暂不支持宏调用");
      ("Async expressions not yet supported", "暂不支持异步表达式");
      ("Expected function type but got:", "期望函数类型，但得到:");
      ("IntType_T", "整数类型");
      ("FloatType_T", "浮点数类型");
      ("StringType_T", "字符串类型");
      ("BoolType_T", "布尔类型");
      ("UnitType_T", "单元类型");
      ("FunType_T", "函数类型");
      ("ListType_T", "列表类型");
      ("TypeVar_T", "类型变量");
      ("TupleType_T", "元组类型");
    ]
  in
  let rec apply_replacements msg replacements =
    match replacements with
    | [] -> msg
    | (old_str, new_str) :: rest ->
        let new_msg = Str.global_replace (Str.regexp_string old_str) new_str msg in
        apply_replacements new_msg rest
  in
  apply_replacements msg replacements

(** 将运行时错误转换为中文 *)
let chinese_runtime_error_message msg =
  let replacements =
    [
      ("Runtime error:", "运行时错误:");
      ("Undefined variable:", "未定义的变量:");
      ("Function parameter count mismatch", "函数参数数量不匹配");
      ("Cannot call non-function value", "尝试调用非函数值");
      ("Division by zero", "除零错误");
      ("Type mismatch in operation", "操作中的类型不匹配");
      ("Pattern matching exhausted", "模式匹配未能覆盖所有情况");
      ("List index out of bounds", "列表索引超出范围");
      ("Invalid arithmetic operation", "无效的算术运算");
      ("Expected integer but got", "期望整数但得到");
      ("Expected string but got", "期望字符串但得到");
      ("Expected boolean but got", "期望布尔值但得到");
      ("Expected list but got", "期望列表但得到");
    ]
  in
  let rec apply_replacements msg replacements =
    match replacements with
    | [] -> msg
    | (old_str, new_str) :: rest ->
        let new_msg = Str.global_replace (Str.regexp_string old_str) new_str msg in
        apply_replacements new_msg rest
  in
  apply_replacements msg replacements

(** 生成详细的类型不匹配错误消息 *)
let type_mismatch_error expected_type actual_type =
  EMT.type_mismatch_error
    (type_to_chinese_string expected_type)
    (type_to_chinese_string actual_type)

(** 生成未定义变量的建议错误消息 *)
let undefined_variable_error var_name available_vars =
  let base_msg = EMT.undefined_variable_error var_name in
  if List.length available_vars = 0 then base_msg ^ "（当前作用域中没有可用变量）"
  else if List.length available_vars <= 5 then
    Unified_formatter.ErrorMessages.variable_suggestion var_name available_vars
  else
    let rec take n lst =
      if n <= 0 then [] else match lst with [] -> [] | h :: t -> h :: take (n - 1) t
    in
    let first_five = take 5 available_vars in
    base_msg ^ Printf.sprintf "（可用变量包括: %s 等）" (CF.join_chinese first_five)

(** 生成函数调用参数不匹配的详细错误消息 *)
let function_arity_error expected_count actual_count =
  Unified_formatter.ErrorMessages.function_param_count_mismatch_simple expected_count actual_count

(** 生成模式匹配失败的详细错误消息 *)
let pattern_match_error value_type =
  Unified_formatter.ErrorMessages.pattern_match_failure (type_to_chinese_string value_type)

type error_analysis = {
  error_type : string;
  error_message : string;
  context : string option;
  suggestions : string list;
  fix_hints : string list;
  confidence : float;
}
(** 智能错误分析类型 *)

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

(** 寻找相似变量名 *)
let find_similar_variables target_var available_vars =
  let similarities =
    List.map
      (fun var ->
        let distance = levenshtein_distance target_var var in
        let max_len = max (String.length target_var) (String.length var) in
        let similarity = 1.0 -. (float_of_int distance /. float_of_int max_len) in
        (var, similarity))
      available_vars
  in
  let sorted = List.sort (fun (_, s1) (_, s2) -> compare s2 s1) similarities in
  List.filter (fun (_, similarity) -> similarity > 0.6) sorted

(** 分析未定义变量错误 *)
let analyze_undefined_variable var_name available_vars =
  let similar_vars = find_similar_variables var_name available_vars in
  let suggestions =
    match similar_vars with
    | [] when List.length available_vars = 0 -> [ "当前作用域中没有可用变量，检查是否需要先定义变量" ]
    | [] ->
        [
          "检查变量名拼写是否正确";
          "确认变量是否在当前作用域中定义";
          "可用变量: "
          ^ CF.join_chinese
              (let rec take n lst =
                 if n <= 0 then [] else match lst with [] -> [] | h :: t -> h :: take (n - 1) t
               in
               take 5 available_vars);
        ]
    | (best_match, score) :: others when score > 0.8 ->
        [
          RF.similarity_suggestion best_match score;
          "或检查其他相似变量: "
          ^ CF.join_chinese
              (List.map fst
                 (let rec take n lst =
                    if n <= 0 then [] else match lst with [] -> [] | h :: t -> h :: take (n - 1) t
                  in
                  take 3 others));
        ]
    | similar ->
        let mapped_similar =
          List.map
            (fun (var, score) -> "  " ^ RF.similarity_suggestion var score)
            (let rec take n lst =
               if n <= 0 then [] else match lst with [] -> [] | h :: t -> h :: take (n - 1) t
             in
             take 5 similar)
        in
        "可能的相似变量:" :: mapped_similar
  in
  let fix_hints =
    match similar_vars with
    | (best_match, score) :: _ when score > 0.8 -> [ RF.suggestion_line var_name best_match ]
    | _ -> [ Unified_formatter.General.format_variable_definition var_name ]
  in
  {
    error_type = "undefined_variable";
    error_message = Unified_formatter.ErrorMessages.undefined_variable var_name;
    context = Some (Unified_formatter.General.format_context_info (List.length available_vars) "变量");
    suggestions;
    fix_hints;
    confidence = (if List.length similar_vars > 0 then 0.9 else 0.7);
  }

(** 分析类型不匹配错误 *)
let analyze_type_mismatch expected_type actual_type =
  let type_suggestions =
    match (expected_type, actual_type) with
    | "整数类型", "字符串类型" -> [ "尝试将字符串转换为整数: 转换为整数 「字符串值」"; "检查是否误用了字符串字面量而非数字" ]
    | "字符串类型", "整数类型" -> [ "尝试将整数转换为字符串: 转换为字符串 数字值"; "检查是否需要字符串插值" ]
    | "列表类型", _ -> [ "检查是否遗漏了方括号: [元素1; 元素2]"; "确认是否需要将单个值包装为列表" ]
    | _, "列表类型" -> [ "检查是否需要从列表中提取元素"; "考虑使用列表访问操作" ]
    | "函数类型", _ -> [ "检查是否遗漏了函数调用的参数"; "确认变量是否是函数" ]
    | _, "函数类型" -> [ "检查是否误将函数当作值使用"; "确认是否需要调用函数" ]
    | _ -> [ "检查表达式的类型是否正确"; "考虑是否需要类型转换" ]
  in
  let fix_hints =
    match (expected_type, actual_type) with
    | "整数类型", "字符串类型" -> [ "添加类型转换: (转换为整数 值)" ]
    | "字符串类型", "整数类型" -> [ "添加类型转换: (转换为字符串 值)" ]
    | _ -> [ "检查并修正表达式类型" ]
  in
  {
    error_type = "type_mismatch";
    error_message = Unified_formatter.ErrorMessages.type_mismatch expected_type actual_type;
    context = Some "类型系统检查";
    suggestions = type_suggestions;
    fix_hints;
    confidence = 0.85;
  }

(** 分析函数参数错误 *)
let analyze_function_arity expected_count actual_count function_name =
  let suggestions =
    if actual_count < expected_count then
      [
        Unified_formatter.ErrorMessages.function_needs_params function_name expected_count actual_count;
        "检查是否遗漏了参数";
        "确认函数调用的参数顺序";
      ]
    else
      [
        Unified_formatter.ErrorMessages.function_excess_params function_name expected_count actual_count;
        "检查是否提供了多余的参数";
        "确认是否调用了正确的函数";
      ]
  in
  let fix_hints =
    if actual_count < expected_count then
      [ Printf.sprintf "添加缺失的 %d 个参数" (expected_count - actual_count) ]
    else [ Printf.sprintf "移除多余的 %d 个参数" (actual_count - expected_count) ]
  in
  {
    error_type = "function_arity";
    error_message = Printf.sprintf "函数参数数量不匹配: 期望 %d 个，提供了 %d 个" expected_count actual_count;
    context = Some (Printf.sprintf "函数: %s" function_name);
    suggestions;
    fix_hints;
    confidence = 0.95;
  }

(** 分析模式匹配错误 *)
let analyze_pattern_match_error missing_patterns =
  let suggestions =
    let mapped_patterns =
      List.map (fun pattern -> Printf.sprintf "缺少模式: %s" pattern) missing_patterns
    in
    let base_suggestions = [ "模式匹配必须覆盖所有可能的情况"; "考虑添加通配符模式 _ 作为默认情况" ] in
    base_suggestions @ mapped_patterns
  in
  let fix_hints =
    if List.length missing_patterns > 0 then
      List.map (fun pattern -> Printf.sprintf "添加分支: ｜ %s → 结果" pattern) missing_patterns
    else [ "添加通配符分支: ｜ _ → 默认结果" ]
  in
  {
    error_type = "pattern_match";
    error_message = "模式匹配不完整";
    context = Some "模式匹配表达式";
    suggestions;
    fix_hints;
    confidence = 0.8;
  }

(** 智能错误分析主函数 *)
let intelligent_error_analysis error_type error_details context =
  match error_type with
  | "undefined_variable" ->
      let var_name, available_vars =
        match error_details with
        | [ var; vars ] -> (var, String.split_on_char ';' vars)
        | [ var ] -> (var, [])
        | _ -> ("未知变量", [])
      in
      analyze_undefined_variable var_name available_vars
  | "type_mismatch" ->
      let expected, actual =
        match error_details with [ exp; act ] -> (exp, act) | _ -> ("未知类型", "未知类型")
      in
      analyze_type_mismatch expected actual
  | "function_arity" ->
      let expected_str, actual_str, func_name =
        match error_details with
        | [ exp; act; name ] -> (exp, act, name)
        | [ exp; act ] -> (exp, act, "函数")
        | _ -> ("0", "0", "未知函数")
      in
      let expected_count = try int_of_string expected_str with _ -> 0 in
      let actual_count = try int_of_string actual_str with _ -> 0 in
      analyze_function_arity expected_count actual_count func_name
  | "pattern_match" ->
      let missing_patterns = match error_details with patterns -> patterns in
      analyze_pattern_match_error missing_patterns
  | _ ->
      {
        error_type;
        error_message = "未知错误类型";
        context;
        suggestions = [ "查看文档或使用调试模式获取更多信息" ];
        fix_hints = [ "检查代码语法和逻辑" ];
        confidence = 0.5;
      }

(** 生成智能错误报告 *)
let generate_intelligent_error_report analysis =
  let buffer = Buffer.create (Constants.BufferSizes.default_buffer ()) in
  Buffer.add_string buffer ("🚨 " ^ analysis.error_message ^ "\n\n");

  (match analysis.context with
  | Some ctx -> Buffer.add_string buffer ("📍 上下文: " ^ ctx ^ "\n\n")
  | None -> ());

  Buffer.add_string buffer "💡 智能建议:\n";
  List.iteri
    (fun i suggestion -> Buffer.add_string buffer (Printf.sprintf "   %d. %s\n" (i + 1) suggestion))
    analysis.suggestions;

  if List.length analysis.fix_hints > 0 then (
    Buffer.add_string buffer "\n🔧 修复提示:\n";
    List.iteri
      (fun i hint -> Buffer.add_string buffer (Printf.sprintf "   %d. %s\n" (i + 1) hint))
      analysis.fix_hints);

  Buffer.add_string buffer (Printf.sprintf "\n🎯 AI置信度: %.0f%%\n" (analysis.confidence *. 100.0));
  Buffer.contents buffer

(** 生成AI友好的错误建议 *)
let generate_error_suggestions error_type _context =
  match error_type with
  | "type_mismatch" -> "建议: 检查变量类型是否正确，或使用类型转换功能"
  | "undefined_variable" -> "建议: 检查变量名拼写，或确保变量已在当前作用域中定义"
  | "function_arity" -> "建议: 检查函数调用的参数数量，或使用参数适配功能"
  | "pattern_match" -> "建议: 确保模式匹配覆盖所有可能的情况"
  | _ -> "建议: 查看文档或使用 -types 选项查看类型信息"
