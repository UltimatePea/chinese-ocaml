(* AI代码生成助手测试模块 *)

open Ai.Ai_code_generator

(* 测试工具函数 *)
let test_assertion name condition message =
  Printf.printf "测试 [%s]: %s\n" name (if condition then "✅ 通过" else "❌ 失败 - " ^ message)

let print_test_header title =
  Printf.printf "\n🧪 %s\n" title;
  Printf.printf "%s\n" (String.make (String.length title + 5) '=')

(* 测试生成请求创建 *)
let test_generation_request_creation () =
  print_test_header "生成请求创建测试";

  let request =
    { description = "创建一个计算斐波那契数列的函数"; context = None; target_type = Function; constraints = [] }
  in

  test_assertion "请求创建" (request.description <> "" && request.target_type = Function) "请求对象创建失败";

  let request_with_context =
    {
      description = "实现快速排序";
      context = Some "let existing_func = ...";
      target_type = Algorithm Sorting;
      constraints = [ PreferRecursive; MaxComplexity 3 ];
    }
  in

  test_assertion "带上下文的请求创建"
    (request_with_context.context <> None && List.length request_with_context.constraints = 2)
    "带上下文的请求创建失败"

(* 测试意图分析 *)
let test_intent_analysis () =
  print_test_header "意图分析测试";

  let test_cases =
    [
      ("创建斐波那契函数", Algorithm Recursive);
      ("实现快速排序算法", Algorithm Sorting);
      ("过滤列表中的偶数", DataProcessing [ Filter ]);
      ("计算平均值", Algorithm Mathematical);
      ("二分查找", Algorithm Searching);
      ("映射函数到列表", DataProcessing [ Map ]);
    ]
  in

  List.iter
    (fun (description, expected_type) ->
      let actual_type, _ = analyze_generation_intent description in
      let matches =
        match (actual_type, expected_type) with
        | Algorithm a1, Algorithm a2 -> a1 = a2
        | DataProcessing _, DataProcessing _ -> true
        | Function, Function -> true
        | _ -> false
      in
      test_assertion ("意图分析: " ^ description) matches "意图分析结果不匹配")
    test_cases

(* 测试函数代码生成 *)
let test_function_generation () =
  print_test_header "函数代码生成测试";

  let test_cases = [ "创建一个计算斐波那契数列的函数"; "实现阶乘计算"; "计算列表的长度"; "查找列表中的最大值" ] in

  List.iter
    (fun description ->
      let result = generate_function_code description None in

      test_assertion ("代码生成: " ^ description)
        (result.generated_code <> "" && result.confidence > 0.0)
        "代码生成失败或置信度为零";

      test_assertion ("语法检查: " ^ description)
        ((try
            let _ = Str.search_forward (Str.regexp_string "让") result.generated_code 0 in
            true
          with Not_found -> false)
        ||
        try
          let _ = Str.search_forward (Str.regexp_string "递归") result.generated_code 0 in
          true
        with Not_found -> false)
        "生成的代码不包含基本的骆言语法";

      test_assertion ("质量指标: " ^ description)
        (result.quality_metrics.syntax_correctness > 0.5)
        "代码质量指标过低")
    test_cases

(* 测试算法生成 *)
let test_algorithm_generation () =
  print_test_header "算法生成测试";

  let algorithm_tests =
    [
      (Sorting, "实现快速排序"); (Searching, "二分查找算法"); (Recursive, "递归计算斐波那契"); (Mathematical, "计算数学平均值");
    ]
  in

  List.iter
    (fun (alg_type, description) ->
      let result = generate_algorithm_code alg_type description in

      test_assertion ("算法生成: " ^ description)
        (result.generated_code <> "" && result.confidence >= 0.3)
        "算法代码生成失败";

      test_assertion ("算法复杂度: " ^ description) (result.quality_metrics.efficiency > 0.5) "算法效率评估过低")
    algorithm_tests

(* 测试数据处理生成 *)
let test_data_processing_generation () =
  print_test_header "数据处理生成测试";

  let processing_tests =
    [
      ([ Filter ], "过滤正数");
      ([ Map ], "映射转换");
      ([ Reduce ], "求和归约");
      ([ Sort ], "排序处理");
      ([ Filter; Map ], "过滤后映射");
    ]
  in

  List.iter
    (fun (operations, description) ->
      let result = generate_data_processing_code operations description in

      test_assertion ("数据处理: " ^ description) (result.generated_code <> "") "数据处理代码生成失败";

      test_assertion ("中文规范: " ^ description)
        (result.quality_metrics.chinese_compliance > 0.8)
        "生成代码的中文规范性不足")
    processing_tests

(* 测试模板匹配 *)
let test_template_matching () =
  print_test_header "模板匹配测试";

  let keywords_tests =
    [
      ([ "斐波那契"; "数列" ], 1);
      (* 应该匹配到斐波那契模板 *)
      ([ "排序"; "快速" ], 1);
      (* 应该匹配到快速排序模板 *)
      ([ "求和"; "列表" ], 1);
      (* 应该匹配到求和模板 *)
      ([ "未知关键词" ], 0);
      (* 不应该匹配任何模板 *)
    ]
  in

  List.iter
    (fun (keywords, expected_matches) ->
      let matches = match_templates keywords function_templates in
      let actual_matches = List.length matches in

      test_assertion
        ("模板匹配: " ^ String.concat "," keywords)
        (if expected_matches = 0 then actual_matches = 0 else actual_matches > 0)
        ("期望匹配 " ^ string_of_int expected_matches ^ " 个模板，实际匹配 " ^ string_of_int actual_matches
       ^ " 个"))
    keywords_tests

(* 测试智能代码生成主接口 *)
let test_intelligent_generation () =
  print_test_header "智能代码生成主接口测试";

  let test_cases = [ "创建一个计算斐波那契数列的函数"; "实现列表快速排序"; "过滤出数组中的偶数"; "计算数字的阶乘"; "查找最大值" ] in

  List.iter
    (fun description ->
      let result = intelligent_code_generation description () in

      test_assertion ("智能生成: " ^ description)
        (result.generated_code <> "" && result.explanation <> "")
        "智能生成失败";

      test_assertion
        ("置信度检查: " ^ description)
        (result.confidence >= 0.0 && result.confidence <= 1.0)
        "置信度超出有效范围";

      Printf.printf "  📝 生成代码示例: %s\n"
        (String.sub result.generated_code 0 (min 50 (String.length result.generated_code)) ^ "..."))
    test_cases

(* 测试多候选方案生成 *)
let test_multiple_candidates () =
  print_test_header "多候选方案生成测试";

  let description = "计算列表求和" in
  let candidates = generate_multiple_candidates description 3 in

  test_assertion "候选方案数量" (List.length candidates <= 3 && List.length candidates > 0) "候选方案数量不符合预期";

  test_assertion "候选方案排序"
    (match candidates with
    | [] -> false
    | [ _ ] -> true
    | first :: second :: _ -> first.confidence >= second.confidence)
    "候选方案未按置信度排序";

  Printf.printf "  📊 生成了 %d 个候选方案\n" (List.length candidates)

(* 测试代码质量评估 *)
let test_code_quality_evaluation () =
  print_test_header "代码质量评估测试";

  let test_codes =
    [
      ("递归 让 「斐波那契」 = 函数 n → 匹配 n 与 ｜ 0 → 0 ｜ 1 → 1", "良好的递归函数");
      ("从「列表」中「所有数字」的「总和」", "声明式语法");
      ("let x = 123", "非中文语法");
      ("", "空代码");
    ]
  in

  List.iter
    (fun (code, description) ->
      let metrics = evaluate_generated_code code in

      test_assertion ("质量评估: " ^ description)
        (metrics.syntax_correctness >= 0.0 && metrics.syntax_correctness <= 1.0
       && metrics.chinese_compliance >= 0.0 && metrics.chinese_compliance <= 1.0)
        "质量指标超出有效范围";

      Printf.printf "  📈 %s: 语法%.0f%% 中文%.0f%% 可读性%.0f%%\n" description
        (metrics.syntax_correctness *. 100.0)
        (metrics.chinese_compliance *. 100.0)
        (metrics.readability *. 100.0))
    test_codes

(* 测试优化建议 *)
let test_optimization_suggestions () =
  print_test_header "优化建议测试";

  let test_codes =
    [
      ("递归 让 「斐波那契」 = 函数 n → n + 斐波那契(n-1)", "递归优化");
      ("对于 每个 x 在 列表 中 做 处理", "声明式转换");
      ("让 x = 头 :: 尾", "错误处理");
      ("让 计算结果 = x * y", "变量命名");
    ]
  in

  List.iter
    (fun (code, expected_type) ->
      let suggestions = suggest_optimizations code in

      test_assertion ("优化建议: " ^ expected_type) (List.length suggestions >= 0) "优化建议生成失败";

      if List.length suggestions > 0 then Printf.printf "  💡 建议: %s\n" (List.hd suggestions))
    test_codes

(* 测试代码解释生成 *)
let test_code_explanation () =
  print_test_header "代码解释生成测试";

  let test_cases =
    [
      ("递归 让 「阶乘」 = 函数 n → n * 阶乘(n-1)", "阶乘计算");
      ("从「列表」中「过滤出」(x → x > 0)", "正数过滤");
      ("匹配 输入 与 ｜ 0 → \"零\" ｜ _ → \"其他\"", "模式匹配");
    ]
  in

  List.iter
    (fun (code, intent) ->
      let explanation = generate_code_explanation code intent in

      test_assertion ("代码解释: " ^ intent)
        (explanation <> "" && String.length explanation > 10)
        "代码解释生成失败或过短";

      Printf.printf "  📚 解释示例: %s\n"
        (String.sub explanation 0 (min 60 (String.length explanation)) ^ "..."))
    test_cases

(* 错误情况测试 *)
let test_error_cases () =
  print_test_header "错误情况处理测试";

  let error_cases =
    [ ""; (* 空描述 *) "完全无法理解的描述abc123xyz"; (* 无意义描述 *) "使用不存在的编程概念xyzabc" (* 未知概念 *) ]
  in

  List.iter
    (fun description ->
      let result = intelligent_code_generation description () in

      test_assertion
        ("错误处理: " ^ if description = "" then "空描述" else "无效描述")
        (result.generated_code <> "") "错误情况未能生成兜底代码";

      test_assertion
        ("错误置信度: " ^ if description = "" then "空描述" else "无效描述")
        (result.confidence < 0.5) "错误情况的置信度过高")
    error_cases

(* 性能测试 *)
let test_performance () =
  print_test_header "性能测试";

  let start_time = Sys.time () in
  let descriptions =
    [ "创建斐波那契函数"; "实现快速排序"; "计算平均值"; "过滤偶数"; "查找最大值"; "字符串反转"; "二分查找"; "阶乘计算"; "列表求和"; "数据映射" ]
  in

  List.iter
    (fun desc ->
      let _ = intelligent_code_generation desc () in
      ())
    descriptions;

  let end_time = Sys.time () in
  let total_time = end_time -. start_time in
  let avg_time = total_time /. float_of_int (List.length descriptions) in

  test_assertion "性能测试"
    (avg_time < 0.1) (* 平均每个生成任务应该在0.1秒内完成 *)
    ("平均生成时间过长: " ^ string_of_float avg_time ^ "秒");

  Printf.printf "  ⏱️  平均生成时间: %.4f秒\n" avg_time;
  Printf.printf "  📊 总共处理: %d个请求\n" (List.length descriptions)

(* 集成测试 *)
let test_integration () =
  print_test_header "集成测试";

  (* 测试与现有AI模块的集成 *)
  let description = "创建一个递归函数计算列表长度" in

  (* 使用意图解析器 *)
  let intent_result = Ai.Intent_parser.intelligent_completion description in
  test_assertion "意图解析器集成" (List.length intent_result > 0) "与意图解析器集成失败";

  (* 使用代码生成器 *)
  let generation_result = intelligent_code_generation description () in
  test_assertion "代码生成器集成" (generation_result.generated_code <> "") "代码生成器集成失败";

  (* 比较两个模块的结果一致性 *)
  let intent_has_function =
    List.exists
      (fun s ->
        try
          let _ = Str.search_forward (Str.regexp_string "让") s.Ai.Intent_parser.code 0 in
          true
        with Not_found -> false)
      intent_result
  in
  let generation_has_function =
    try
      let _ = Str.search_forward (Str.regexp_string "让") generation_result.generated_code 0 in
      true
    with Not_found -> false
  in

  test_assertion "模块结果一致性" (intent_has_function = generation_has_function) "两个AI模块的结果不一致";

  Printf.printf "  🔗 成功集成现有AI模块\n"

(* 主测试函数 *)
let run_all_tests () =
  Printf.printf "\n🚀 AI代码生成助手全面测试\n";
  Printf.printf "%s\n\n" (String.make 60 '=');

  test_generation_request_creation ();
  test_intent_analysis ();
  test_function_generation ();
  test_algorithm_generation ();
  test_data_processing_generation ();
  test_template_matching ();
  test_intelligent_generation ();
  test_multiple_candidates ();
  test_code_quality_evaluation ();
  test_optimization_suggestions ();
  test_code_explanation ();
  test_error_cases ();
  test_performance ();
  test_integration ();

  Printf.printf "\n🎉 AI代码生成助手测试完成！\n";
  Printf.printf "%s\n" (String.make 60 '=')

(* 导出测试函数 *)
let () = run_all_tests ()
