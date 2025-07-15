(* AI代码生成助手 - AI Code Generator Assistant *)

(* 辅助函数 *)
let rec list_take n = function [] -> [] | h :: t when n > 0 -> h :: list_take (n - 1) t | _ -> []

(* 生成请求类型 *)
type generation_request = {
  description : string; (* 自然语言描述 *)
  context : string option; (* 上下文代码 *)
  target_type : generation_target; (* 生成目标类型 *)
  constraints : generation_constraint list; (* 生成约束 *)
}

(* 生成目标类型 *)
and generation_target =
  | Function (* 函数生成 *)
  | Algorithm of algorithm_type (* 算法实现 *)
  | DataProcessing of data_operation list (* 数据处理 *)
  | PatternApplication (* 模式应用 *)

(* 算法类型 *)
and algorithm_type =
  | Sorting (* 排序算法 *)
  | Searching (* 搜索算法 *)
  | Recursive (* 递归算法 *)
  | Mathematical (* 数学算法 *)

(* 数据操作类型 *)
and data_operation =
  | Filter (* 过滤 *)
  | Map (* 映射 *)
  | Reduce (* 归约 *)
  | Sort (* 排序 *)
  | Group (* 分组 *)

(* 生成约束 *)
and generation_constraint =
  | MaxComplexity of int (* 最大复杂度 *)
  | PreferRecursive (* 偏好递归 *)
  | PreferIterative (* 偏好迭代 *)
  | MustInclude of string list (* 必须包含的关键字 *)
  | AvoidFeatures of string list (* 避免的特性 *)

(* 生成结果 *)
type generation_result = {
  generated_code : string; (* 生成的代码 *)
  explanation : string; (* 解释说明 *)
  confidence : float; (* 置信度 0.0-1.0 *)
  alternatives : generation_alternative list; (* 替代方案 *)
  quality_metrics : quality_metrics; (* 质量指标 *)
}

(* 替代方案 *)
and generation_alternative = {
  alt_code : string; (* 替代代码 *)
  alt_description : string; (* 方案描述 *)
  alt_confidence : float; (* 置信度 *)
}

(* 质量指标 *)
and quality_metrics = {
  syntax_correctness : float; (* 语法正确性 *)
  chinese_compliance : float; (* 中文编程规范符合度 *)
  readability : float; (* 可读性 *)
  efficiency : float; (* 效率预估 *)
}

(* 代码模板定义 *)
type code_template = {
  name : string;
  pattern : string list;
  template : string;
  explanation : string;
  category : string;
  complexity : int;
}

(* 预定义函数模板库 *)
let function_templates : code_template list =
  [
    {
      name = "斐波那契数列";
      pattern = [ "斐波那契"; "fibonacci"; "数列" ];
      template =
        "递归 让 「斐波那契」 = 函数 n →\n\
        \  匹配 n 与\n\
        \  ｜ 0 → 0\n\
        \  ｜ 1 → 1\n\
        \  ｜ _ → 「斐波那契」 (n - 1) + 「斐波那契」 (n - 2)";
      explanation = "计算斐波那契数列第n项的递归实现";
      category = "数学函数";
      complexity = 2;
    };
    {
      name = "阶乘计算";
      pattern = [ "阶乘"; "factorial"; "factorial"; "乘积" ];
      template = "递归 让 「阶乘」 = 函数 n →\n  匹配 n 与\n  ｜ 0 ｜ 1 → 1\n  ｜ _ → n * 「阶乘」 (n - 1)";
      explanation = "计算自然数阶乘的递归实现";
      category = "数学函数";
      complexity = 1;
    };
    {
      name = "快速排序";
      pattern = [ "快速排序"; "quicksort"; "排序"; "sort" ];
      template =
        "递归 让 「快速排序」 = 函数 列表 →\n\
        \  匹配 列表 与\n\
        \  ｜ [] → []\n\
        \  ｜ 基准 :: 其余 →\n\
        \    让 小的 = 从「其余」中「过滤出」(x → x < 基准) 以及\n\
        \    让 大的 = 从「其余」中「过滤出」(x → x >= 基准) 于\n\
        \    「快速排序」 小的 @ [基准] @ 「快速排序」 大的";
      explanation = "实现快速排序算法，将列表分割后递归排序";
      category = "排序算法";
      complexity = 3;
    };
    {
      name = "列表求和";
      pattern = [ "求和"; "sum"; "总和"; "加和" ];
      template = "从「列表」中「所有数字」的「总和」";
      explanation = "计算列表中所有数字的总和，使用声明式语法";
      category = "列表操作";
      complexity = 1;
    };
    {
      name = "列表过滤";
      pattern = [ "过滤"; "filter"; "筛选"; "选择" ];
      template = "从「列表」中「过滤出」(条件函数)";
      explanation = "根据给定条件过滤列表元素";
      category = "列表操作";
      complexity = 1;
    };
    {
      name = "列表映射";
      pattern = [ "映射"; "map"; "转换"; "变换" ];
      template = "从「列表」中「映射为」(转换函数)";
      explanation = "将函数应用到列表的每个元素";
      category = "列表操作";
      complexity = 1;
    };
    {
      name = "二分查找";
      pattern = [ "二分查找"; "binary search"; "查找"; "搜索" ];
      template =
        "递归 让 「二分查找」 = 函数 目标 列表 开始 结束 →\n\
        \  如果 开始 > 结束 那么 无\n\
        \  否则\n\
        \    让 中点 = (开始 + 结束) / 2 以及\n\
        \    让 中值 = 列表索引 中点 于\n\
        \    匹配 比较 目标 中值 与\n\
        \    ｜ 0 → 有 中点\n\
        \    ｜ 负数 → 「二分查找」 目标 列表 开始 (中点 - 1)\n\
        \    ｜ _ → 「二分查找」 目标 列表 (中点 + 1) 结束";
      explanation = "在有序列表中进行二分查找";
      category = "搜索算法";
      complexity = 3;
    };
    {
      name = "计算平均值";
      pattern = [ "平均值"; "average"; "均值"; "平均数" ];
      template =
        "让 「计算平均值」 = 函数 列表 →\n  让 总和 = 从「列表」中「所有数字」的「总和」 以及\n  让 长度 = 从「列表」中「计算长度」 于\n  总和 / 长度";
      explanation = "计算数字列表的算术平均值";
      category = "数学函数";
      complexity = 1;
    };
    {
      name = "最大值查找";
      pattern = [ "最大值"; "maximum"; "最大"; "max" ];
      template =
        "递归 让 「找最大值」 = 函数 列表 →\n\
        \  匹配 列表 与\n\
        \  ｜ [] → 异常 \"空列表无最大值\"\n\
        \  ｜ [单个] → 单个\n\
        \  ｜ 头 :: 尾 → 让 尾最大 = 「找最大值」 尾 于\n\
        \                如果 头 > 尾最大 那么 头 否则 尾最大";
      explanation = "查找列表中的最大值";
      category = "数学函数";
      complexity = 2;
    };
    {
      name = "字符串反转";
      pattern = [ "反转"; "reverse"; "倒序"; "逆序" ];
      template =
        "递归 让 「反转字符串」 = 函数 字符串 →\n  匹配 字符串长度 与\n  ｜ 0 ｜ 1 → 字符串\n  ｜ _ → 「反转字符串」 (字符串子串 1) + 字符串首字符";
      explanation = "将字符串或列表反转";
      category = "字符串操作";
      complexity = 2;
    };
  ]

(* 自然语言意图分析器 *)
let analyze_generation_intent (description : string) : generation_target * string list =
  let desc_lower = String.lowercase_ascii description in
  let keywords = String.split_on_char ' ' desc_lower in

  (* 检查算法类型关键词 *)
  if List.exists (fun k -> List.mem k [ "排序"; "sort"; "快速排序"; "归并排序" ]) keywords then
    (Algorithm Sorting, keywords)
  else if List.exists (fun k -> List.mem k [ "查找"; "搜索"; "search"; "find"; "二分" ]) keywords then
    (Algorithm Searching, keywords)
  else if List.exists (fun k -> List.mem k [ "递归"; "recursive"; "斐波那契"; "阶乘" ]) keywords then
    (Algorithm Recursive, keywords)
  else if List.exists (fun k -> List.mem k [ "数学"; "计算"; "平均"; "最大"; "最小" ]) keywords then
    (Algorithm Mathematical, keywords) (* 检查数据处理操作 *)
  else if List.exists (fun k -> List.mem k [ "过滤"; "filter"; "筛选" ]) keywords then
    (DataProcessing [ Filter ], keywords)
  else if List.exists (fun k -> List.mem k [ "映射"; "map"; "转换"; "变换" ]) keywords then
    (DataProcessing [ Map ], keywords)
  else if List.exists (fun k -> List.mem k [ "求和"; "reduce"; "归约"; "统计" ]) keywords then
    (DataProcessing [ Reduce ], keywords)
  else if List.exists (fun k -> List.mem k [ "分组"; "group"; "聚合" ]) keywords then
    (DataProcessing [ Group ], keywords)
  (* 默认为函数生成 *)
    else (Function, keywords)

(* 模板匹配算法 *)
let match_templates (keywords : string list) (templates : code_template list) :
    (code_template * float) list =
  let calculate_match_score template =
    let pattern_matches =
      List.fold_left
        (fun acc pattern ->
          if
            List.exists
              (fun keyword ->
                try
                  let _ = Str.search_forward (Str.regexp_string pattern) keyword 0 in
                  true
                with Not_found -> false)
              keywords
          then acc + 1
          else acc)
        0 template.pattern
    in

    let score = float_of_int pattern_matches /. float_of_int (List.length template.pattern) in
    (template, score)
  in

  let scored_templates = List.map calculate_match_score templates in
  let filtered = List.filter (fun (_, score) -> score > 0.0) scored_templates in
  List.sort (fun (_, s1) (_, s2) -> compare s2 s1) filtered

(* 生成代码建议 *)
let generate_function_code (description : string) (_context : string option) : generation_result =
  let _target_type, keywords = analyze_generation_intent description in
  let matched_templates = match_templates keywords function_templates in

  match matched_templates with
  | (best_template, confidence) :: alternatives ->
      let alt_list =
        list_take 3
          (List.map
             (fun (t, c) ->
               { alt_code = t.template; alt_description = t.explanation; alt_confidence = c })
             alternatives)
      in

      {
        generated_code = best_template.template;
        explanation = best_template.explanation;
        confidence;
        alternatives = alt_list;
        quality_metrics =
          {
            syntax_correctness = 0.95;
            (* 模板都是语法正确的 *)
            chinese_compliance = 0.90;
            (* 使用中文编程规范 *)
            readability = 0.85;
            (* 代码可读性良好 *)
            efficiency = 0.80;
            (* 效率适中 *)
          };
      }
  | [] ->
      (* 没有匹配的模板，生成通用代码框架 *)
      let generic_code =
        Printf.sprintf "让 「%s」 = 函数 参数 →\n  (* TODO: 实现 %s *)\n  参数"
          (if String.length description > 20 then "新函数" else description)
          description
      in

      {
        generated_code = generic_code;
        explanation = "根据描述生成的通用函数框架，需要手动完善实现";
        confidence = 0.3;
        alternatives = [];
        quality_metrics =
          {
            syntax_correctness = 0.80;
            chinese_compliance = 0.70;
            readability = 0.60;
            efficiency = 0.50;
          };
      }

(* 生成算法实现 *)
let generate_algorithm_code (algorithm_type : algorithm_type) (description : string) :
    generation_result =
  let templates =
    List.filter
      (fun t ->
        match algorithm_type with
        | Sorting -> t.category = "排序算法"
        | Searching -> t.category = "搜索算法"
        | Recursive ->
            List.exists
              (fun pattern ->
                try
                  let _ = Str.search_forward (Str.regexp_string pattern) description 0 in
                  true
                with Not_found -> false)
              [ "递归"; "斐波那契"; "阶乘" ]
        | Mathematical -> t.category = "数学函数")
      function_templates
  in

  match templates with
  | template :: _ ->
      {
        generated_code = template.template;
        explanation = template.explanation;
        confidence = 0.85;
        alternatives = [];
        quality_metrics =
          {
            syntax_correctness = 0.95;
            chinese_compliance = 0.90;
            readability = 0.85;
            efficiency = 0.90;
          };
      }
  | [] -> generate_function_code description None

(* 生成数据处理代码 *)
let generate_data_processing_code (operations : data_operation list) (_description : string) :
    generation_result =
  let operation_templates =
    [
      (Filter, "从「列表」中「过滤出」(条件函数)", "根据条件过滤列表元素");
      (Map, "从「列表」中「映射为」(转换函数)", "将函数应用到每个元素");
      (Reduce, "从「列表」中「所有元素」的「总和」", "归约列表中的所有元素");
      (Sort, "从「列表」中「排序」", "对列表进行排序");
      (Group, "从「列表」中「按条件分组」", "根据条件将元素分组");
    ]
  in

  let generate_single_operation op =
    match List.find_opt (fun (o, _, _) -> o = op) operation_templates with
    | Some (_, template, explanation) -> (template, explanation)
    | None -> ("(* 未知操作 *)", "未知的数据操作")
  in

  let templates, explanations = List.split (List.map generate_single_operation operations) in
  let combined_code = String.concat "\n" templates in
  let combined_explanation = String.concat "；" explanations in

  {
    generated_code = combined_code;
    explanation = combined_explanation;
    confidence = 0.80;
    alternatives = [];
    quality_metrics =
      {
        syntax_correctness = 0.90;
        chinese_compliance = 0.95;
        readability = 0.90;
        efficiency = 0.85;
      };
  }

(* 主生成函数 *)
let generate_function (request : generation_request) : generation_result =
  match request.target_type with
  | Function -> generate_function_code request.description request.context
  | Algorithm alg_type -> generate_algorithm_code alg_type request.description
  | DataProcessing operations -> generate_data_processing_code operations request.description
  | PatternApplication -> (
      (* 集成现有的模式匹配系统 *)
      let matches = Pattern_matching.find_best_patterns request.description 1 in
      match matches with
      | match_result :: _ ->
          {
            generated_code = Pattern_matching.generate_code_from_pattern match_result;
            explanation = match_result.pattern.description;
            confidence = match_result.confidence;
            alternatives = [];
            quality_metrics =
              {
                syntax_correctness = 0.85;
                chinese_compliance = 0.80;
                readability = 0.75;
                efficiency = 0.70;
              };
          }
      | [] -> generate_function_code request.description request.context)

(* 智能代码生成接口 *)
let intelligent_code_generation (description : string) ?(context : string option = None)
    ?(constraints : generation_constraint list = []) () : generation_result =
  let target_type, _ = analyze_generation_intent description in
  let request = { description; context; target_type; constraints } in
  generate_function request

(* 批量生成多个候选方案 *)
let generate_multiple_candidates (description : string) (count : int) : generation_result list =
  let base_result = intelligent_code_generation description () in
  let variations =
    [
      (* 递归版本 *)
      intelligent_code_generation (description ^ " 使用递归实现") ~constraints:[ PreferRecursive ] ();
      (* 声明式版本 *)
      intelligent_code_generation (description ^ " 使用声明式风格") ();
      (* 简化版本 *)
      intelligent_code_generation (description ^ " 简单实现") ~constraints:[ MaxComplexity 2 ] ();
    ]
  in

  let all_results = base_result :: variations in
  list_take count (List.sort (fun r1 r2 -> compare r2.confidence r1.confidence) all_results)

(* 代码质量评估 *)
let evaluate_generated_code (code : string) : quality_metrics =
  let lines = String.split_on_char '\n' code in
  let total_lines = List.length lines in
  let non_empty_lines = List.length (List.filter (fun line -> String.trim line <> "") lines) in

  (* 语法正确性评估（简化） *)
  let syntax_score =
    if
      (try
         let _ = Str.search_forward (Str.regexp_string "让") code 0 in
         true
       with Not_found -> false)
      &&
      try
        let _ = Str.search_forward (Str.regexp_string "函数") code 0 in
        true
      with Not_found -> false
    then 0.9
    else if
      (try
         let _ = Str.search_forward (Str.regexp_string "匹配") code 0 in
         true
       with Not_found -> false)
      &&
      try
        let _ = Str.search_forward (Str.regexp_string "与") code 0 in
        true
      with Not_found -> false
    then 0.9
    else 0.7
  in

  (* 中文编程规范符合度 *)
  let chinese_score =
    let chinese_keywords = [ "让"; "函数"; "匹配"; "与"; "如果"; "那么"; "否则" ] in
    let found_keywords =
      List.filter
        (fun kw ->
          try
            let _ = Str.search_forward (Str.regexp_string kw) code 0 in
            true
          with Not_found -> false)
        chinese_keywords
    in
    float_of_int (List.length found_keywords) /. float_of_int (List.length chinese_keywords)
  in

  (* 可读性评估 *)
  let readability_score =
    if total_lines > 0 then min 1.0 (float_of_int non_empty_lines /. float_of_int total_lines)
    else 0.5
  in

  (* 效率预估（基于复杂度） *)
  let efficiency_score =
    if
      try
        let _ = Str.search_forward (Str.regexp_string "递归") code 0 in
        true
      with Not_found -> false
    then 0.7
    else if
      (try
         let _ = Str.search_forward (Str.regexp_string "从") code 0 in
         true
       with Not_found -> false)
      &&
      try
        let _ = Str.search_forward (Str.regexp_string "中") code 0 in
        true
      with Not_found -> false
    then 0.9
    else 0.8
  in

  {
    syntax_correctness = syntax_score;
    chinese_compliance = chinese_score;
    readability = readability_score;
    efficiency = efficiency_score;
  }

(* 代码优化建议 *)
let suggest_optimizations (code : string) : string list =
  let suggestions = ref [] in

  (* 检查递归优化 *)
  if
    (try
       let _ = Str.search_forward (Str.regexp_string "递归") code 0 in
       true
     with Not_found -> false)
    && not
         (try
            let _ = Str.search_forward (Str.regexp_string "尾递归") code 0 in
            true
          with Not_found -> false)
  then suggestions := "考虑使用尾递归优化性能" :: !suggestions;

  (* 检查声明式风格 *)
  if
    (try
       let _ = Str.search_forward (Str.regexp_string "对于") code 0 in
       true
     with Not_found -> false)
    ||
    try
      let _ = Str.search_forward (Str.regexp_string "循环") code 0 in
      true
    with Not_found -> false
  then suggestions := "考虑使用声明式语法提高可读性" :: !suggestions;

  (* 检查错误处理 *)
  if
    (not
       (try
          let _ = Str.search_forward (Str.regexp_string "匹配") code 0 in
          true
        with Not_found -> false))
    &&
    try
      let _ = Str.search_forward (Str.regexp_string "列表") code 0 in
      true
    with Not_found -> false
  then suggestions := "添加空列表的错误处理" :: !suggestions;

  (* 检查变量命名 *)
  if
    (try
       let _ = Str.search_forward (Str.regexp_string "x") code 0 in
       true
     with Not_found -> false)
    ||
    try
      let _ = Str.search_forward (Str.regexp_string "y") code 0 in
      true
    with Not_found -> false
  then suggestions := "使用更有意义的中文变量名" :: !suggestions;

  !suggestions

(* 生成解释文档 *)
let generate_code_explanation (code : string) (intent : string) : string =
  let algorithm_analysis =
    if
      try
        let _ = Str.search_forward (Str.regexp_string "递归") code 0 in
        true
      with Not_found -> false
    then "使用递归算法实现"
    else if
      try
        let _ = Str.search_forward (Str.regexp_string "匹配") code 0 in
        true
      with Not_found -> false
    then "使用模式匹配处理不同情况"
    else if
      try
        let _ = Str.search_forward (Str.regexp_string "从") code 0 in
        true
      with Not_found -> false
    then "使用声明式语法进行数据处理"
    else "使用函数式编程风格"
  in

  let complexity_analysis =
    let line_count = List.length (String.split_on_char '\n' code) in
    if line_count <= 3 then "简单实现，易于理解"
    else if line_count <= 8 then "中等复杂度，结构清晰"
    else "较复杂实现，包含多个逻辑分支"
  in

  Printf.sprintf "功能描述：%s\n算法特点：%s\n复杂度分析：%s\n使用建议：适用于%s的场景" intent algorithm_analysis
    complexity_analysis
    (if
       try
         let _ = Str.search_forward (Str.regexp_string "列表") intent 0 in
         true
       with Not_found -> false
     then "列表数据处理"
     else if
       try
         let _ = Str.search_forward (Str.regexp_string "数字") intent 0 in
         true
       with Not_found -> false
     then "数值计算"
     else "通用编程")

(* 测试AI代码生成助手 *)
let test_ai_code_generator () =
  let test_cases =
    [
      "创建一个计算斐波那契数列的函数";
      "实现快速排序算法对列表排序";
      "计算数字列表的平均值";
      "过滤出列表中的偶数";
      "查找列表中的最大值";
      "将字符串反转";
      "实现二分查找算法";
      "计算阶乘的递归函数";
    ]
  in

  Printf.printf "\n🚀 AI代码生成助手测试开始\n";
  Printf.printf "%s\n\n" (String.make 50 '=');

  List.iteri
    (fun i description ->
      Printf.printf "🧪 测试案例 %d: %s\n" (i + 1) description;
      Printf.printf "%s\n" (String.make 40 '-');

      let result = intelligent_code_generation description () in

      Printf.printf "📊 生成结果:\n";
      Printf.printf "置信度: %.0f%%\n" (result.confidence *. 100.0);
      Printf.printf "解释: %s\n\n" result.explanation;

      Printf.printf "📝 生成代码:\n```luoyan\n%s\n```\n\n" result.generated_code;

      Printf.printf "📈 质量指标:\n";
      Printf.printf "  语法正确性: %.0f%%\n" (result.quality_metrics.syntax_correctness *. 100.0);
      Printf.printf "  中文规范性: %.0f%%\n" (result.quality_metrics.chinese_compliance *. 100.0);
      Printf.printf "  可读性: %.0f%%\n" (result.quality_metrics.readability *. 100.0);
      Printf.printf "  效率预估: %.0f%%\n\n" (result.quality_metrics.efficiency *. 100.0);

      if List.length result.alternatives > 0 then (
        Printf.printf "🔄 替代方案:\n";
        List.iteri
          (fun j alt ->
            Printf.printf "  %d. %s (置信度: %.0f%%)\n" (j + 1) alt.alt_description
              (alt.alt_confidence *. 100.0))
          result.alternatives;
        Printf.printf "\n");

      let optimizations = suggest_optimizations result.generated_code in
      if List.length optimizations > 0 then (
        Printf.printf "💡 优化建议:\n";
        List.iteri (fun j suggestion -> Printf.printf "  %d. %s\n" (j + 1) suggestion) optimizations;
        Printf.printf "\n");

      let explanation = generate_code_explanation result.generated_code description in
      Printf.printf "📚 详细说明:\n%s\n\n" explanation;

      Printf.printf "%s\n\n" (String.make 50 '='))
    test_cases;

  Printf.printf "🎉 AI代码生成助手测试完成！\n"

(* 导出主要函数 *)
let () = ()
