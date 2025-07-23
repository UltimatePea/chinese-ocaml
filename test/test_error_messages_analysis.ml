(** 错误消息分析模块测试套件

    验证error_messages_analysis.ml模块的智能错误分析功能 包括字符串相似度计算、错误分析、建议生成和修复提示

    创建目的：提升错误处理模块测试覆盖率至60%以上 Fix #925 第三阶段 *)

open Alcotest
open Yyocamlc_lib.Error_messages_analysis

(** 测试辅助函数 *)
(* let create_test_analysis error_type message suggestions fix_hints confidence =
  { error_type; error_message = message; context = Some "测试上下文"; 
    suggestions; fix_hints; confidence } *)

(** 测试字符串编辑距离计算 *)
let test_levenshtein_distance () =
  Printf.printf "测试字符串编辑距离计算...\n";

  (* 测试相同字符串 *)
  let dist_same = levenshtein_distance "hello" "hello" in
  check int "相同字符串的编辑距离应为0" 0 dist_same;

  (* 测试完全不同的字符串 *)
  let dist_diff = levenshtein_distance "abc" "xyz" in
  check int "完全不同字符串的编辑距离应为3" 3 dist_diff;

  (* 测试单字符替换 *)
  let dist_replace = levenshtein_distance "cat" "bat" in
  check int "单字符替换的编辑距离应为1" 1 dist_replace;

  (* 测试插入字符 *)
  let dist_insert = levenshtein_distance "cat" "cats" in
  check int "插入单字符的编辑距离应为1" 1 dist_insert;

  (* 测试删除字符 *)
  let dist_delete = levenshtein_distance "cats" "cat" in
  check int "删除单字符的编辑距离应为1" 1 dist_delete;

  (* 测试空字符串对比 *)
  let dist_empty = levenshtein_distance "" "abc" in
  check int "空字符串对比的编辑距离应为目标字符串长度" 3 dist_empty;

  Printf.printf "字符串编辑距离计算测试完成\n"

(** 测试相似度分数计算 *)
let test_similarity_score () =
  Printf.printf "测试相似度分数计算...\n";

  (* 测试完全相同的字符串 *)
  let score_same = calculate_similarity_score "hello" "hello" in
  check bool "相同字符串的相似度应为1.0" true (abs_float (score_same -. 1.0) < 0.001);

  (* 测试完全不同的字符串 *)
  let score_diff = calculate_similarity_score "abc" "xyz" in
  check bool "完全不同字符串的相似度应为0.0" true (abs_float score_diff < 0.001);

  (* 测试部分相似的字符串 *)
  let score_partial = calculate_similarity_score "hello" "hallo" in
  check bool "部分相似字符串的相似度应在0-1之间" true (score_partial > 0.0 && score_partial < 1.0);

  (* 测试中文变量名相似度 *)
  let score_chinese = calculate_similarity_score "变量名" "变量明" in
  check bool "中文变量名相似度应大于0.5" true (score_chinese > 0.5);

  Printf.printf "相似度分数计算测试完成\n"

(** 测试相似变量查找 *)
let test_find_similar_variables () =
  Printf.printf "测试相似变量查找...\n";

  let available_vars = [ "username"; "user_name"; "userName"; "userinfo"; "password"; "email" ] in
  let target_var = "usename" in

  (* 测试查找相似变量 *)
  let similar_vars = find_similar_variables target_var available_vars in
  check bool "应找到相似变量" true (List.length similar_vars > 0);

  (* 检查最相似的变量 *)
  let most_similar = List.hd similar_vars in
  check bool "最相似变量应有较高相似度" true (snd most_similar > 0.6);

  (* 测试没有相似变量的情况 *)
  let no_similar = find_similar_variables "xyz" [ "abc"; "def"; "ghi" ] in
  check int "没有相似变量时应返回空列表" 0 (List.length no_similar);

  (* 测试空可用变量列表 *)
  let empty_similar = find_similar_variables "test" [] in
  check int "空可用变量列表应返回空结果" 0 (List.length empty_similar);

  Printf.printf "相似变量查找测试完成\n"

(** 测试take_n辅助函数 *)
let test_take_n_helper () =
  Printf.printf "测试take_n辅助函数...\n";

  let test_list = [ 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 ] in

  (* 测试正常情况 *)
  let take_3 = take_n 3 test_list in
  check int "取前3个元素应返回3个元素" 3 (List.length take_3);
  check (list int) "取前3个元素应为[1;2;3]" [ 1; 2; 3 ] take_3;

  (* 测试边界情况 - 取0个元素 *)
  let take_0 = take_n 0 test_list in
  check int "取0个元素应返回空列表" 0 (List.length take_0);

  (* 测试边界情况 - 取超过列表长度的元素 *)
  let take_more = take_n 15 test_list in
  check int "取超过列表长度的元素应返回完整列表" 10 (List.length take_more);

  (* 测试空列表 *)
  let take_empty = take_n 5 [] in
  check int "对空列表取元素应返回空列表" 0 (List.length take_empty);

  Printf.printf "take_n辅助函数测试完成\n"

(** 测试未定义变量分析 *)
let test_undefined_variable_analysis () =
  Printf.printf "测试未定义变量分析...\n";

  let available_vars = [ "username"; "userinfo"; "password"; "email" ] in
  let var_name = "usename" in

  (* 测试未定义变量分析 *)
  let analysis = analyze_undefined_variable var_name available_vars in

  check string "错误类型应为undefined_variable" "undefined_variable" analysis.error_type;
  check bool "应有错误消息" true (String.length analysis.error_message > 0);
  check bool "应有上下文信息" true (analysis.context <> None);
  check bool "应有建议" true (List.length analysis.suggestions > 0);
  check bool "应有修复提示" true (List.length analysis.fix_hints > 0);
  check bool "置信度应在合理范围" true (analysis.confidence >= 0.0 && analysis.confidence <= 1.0);

  (* 测试没有相似变量的情况 *)
  let no_similar_analysis = analyze_undefined_variable "xyz" [ "abc"; "def" ] in
  check bool "没有相似变量时也应有建议" true (List.length no_similar_analysis.suggestions > 0);

  (* 测试空可用变量列表 *)
  let empty_vars_analysis = analyze_undefined_variable "test" [] in
  check bool "空变量列表时应有相应建议" true (List.length empty_vars_analysis.suggestions > 0);

  Printf.printf "未定义变量分析测试完成\n"

(** 测试类型不匹配分析 *)
let test_type_mismatch_analysis () =
  Printf.printf "测试类型不匹配分析...\n";

  (* 测试整数类型和字符串类型的不匹配 *)
  let int_str_analysis = analyze_type_mismatch "整数类型" "字符串类型" in
  check string "错误类型应为type_mismatch" "type_mismatch" int_str_analysis.error_type;
  check bool "应有具体的类型转换建议" true (List.length int_str_analysis.suggestions > 0);
  check bool "应有修复提示" true (List.length int_str_analysis.fix_hints > 0);

  (* 测试字符串类型和整数类型的不匹配 *)
  let str_int_analysis = analyze_type_mismatch "字符串类型" "整数类型" in
  check bool "字符串到整数转换应有相应建议" true (List.length str_int_analysis.suggestions > 0);

  (* 测试列表类型不匹配 *)
  let list_analysis = analyze_type_mismatch "列表类型" "整数类型" in
  check bool "列表类型不匹配应有相应建议" true (List.length list_analysis.suggestions > 0);

  (* 测试函数类型不匹配 *)
  let func_analysis = analyze_type_mismatch "函数类型" "整数类型" in
  check bool "函数类型不匹配应有相应建议" true (List.length func_analysis.suggestions > 0);

  (* 测试通用类型不匹配 *)
  let generic_analysis = analyze_type_mismatch "自定义类型" "其他类型" in
  check bool "通用类型不匹配应有基本建议" true (List.length generic_analysis.suggestions > 0);

  Printf.printf "类型不匹配分析测试完成\n"

(** 测试函数参数错误分析 *)
let test_function_arity_analysis () =
  Printf.printf "测试函数参数错误分析...\n";

  (* 测试参数过少的情况 *)
  let too_few_analysis = analyze_function_arity 3 1 "test_function" in
  check string "错误类型应为function_arity" "function_arity" too_few_analysis.error_type;
  check bool "参数过少应有相应建议" true (List.length too_few_analysis.suggestions > 0);
  check bool "应有添加参数的修复提示" true (List.length too_few_analysis.fix_hints > 0);

  (* 测试参数过多的情况 *)
  let too_many_analysis = analyze_function_arity 2 5 "another_function" in
  check bool "参数过多应有相应建议" true (List.length too_many_analysis.suggestions > 0);
  check bool "应有移除参数的修复提示" true
    (List.exists
       (fun hint ->
         try
           ignore (Str.search_forward (Str.regexp "移除\\|减少") hint 0);
           true
         with Not_found -> false)
       too_many_analysis.fix_hints);

  (* 测试参数匹配的边界情况 *)
  let exact_match_analysis = analyze_function_arity 0 0 "no_param_function" in
  check bool "参数匹配时也应有合理的处理" true (exact_match_analysis.confidence > 0.0);

  Printf.printf "函数参数错误分析测试完成\n"

(** 测试模式匹配错误分析 *)
let test_pattern_match_analysis () =
  Printf.printf "测试模式匹配错误分析...\n";

  let missing_patterns = [ "Some _"; "None" ] in

  (* 测试模式匹配错误分析 *)
  let analysis = analyze_pattern_match_error missing_patterns in
  check string "错误类型应为pattern_match" "pattern_match" analysis.error_type;
  check bool "应有模式匹配建议" true (List.length analysis.suggestions > 0);
  check bool "应有添加分支的修复提示" true (List.length analysis.fix_hints > 0);

  (* 测试空缺失模式列表 *)
  let empty_patterns_analysis = analyze_pattern_match_error [] in
  check bool "空缺失模式列表也应有建议" true (List.length empty_patterns_analysis.suggestions > 0);
  check bool "应有通配符模式建议" true
    (List.exists (fun hint -> String.contains hint '_') empty_patterns_analysis.fix_hints);

  Printf.printf "模式匹配错误分析测试完成\n"

(** 测试智能错误分析主函数 *)
let test_intelligent_error_analysis () =
  Printf.printf "测试智能错误分析主函数...\n";

  (* 测试未定义变量错误 *)
  let undef_analysis =
    intelligent_error_analysis "undefined_variable" [ "test_var"; "var1;var2;var3" ] (Some "测试上下文")
  in
  check string "未定义变量错误类型应正确" "undefined_variable" undef_analysis.error_type;

  (* 测试类型不匹配错误 *)
  let type_analysis =
    intelligent_error_analysis "type_mismatch" [ "整数类型"; "字符串类型" ] (Some "类型检查")
  in
  check string "类型不匹配错误类型应正确" "type_mismatch" type_analysis.error_type;

  (* 测试函数参数错误 *)
  let arity_analysis =
    intelligent_error_analysis "function_arity" [ "3"; "1"; "test_func" ] (Some "函数调用")
  in
  check string "函数参数错误类型应正确" "function_arity" arity_analysis.error_type;

  (* 测试模式匹配错误 *)
  let pattern_analysis =
    intelligent_error_analysis "pattern_match" [ "Some _"; "None" ] (Some "匹配表达式")
  in
  check string "模式匹配错误类型应正确" "pattern_match" pattern_analysis.error_type;

  (* 测试未知错误类型 *)
  let unknown_analysis =
    intelligent_error_analysis "unknown_error" [ "detail1"; "detail2" ] (Some "未知上下文")
  in
  check string "未知错误类型应正确处理" "unknown_error" unknown_analysis.error_type;
  check bool "未知错误应有默认建议" true (List.length unknown_analysis.suggestions > 0);

  Printf.printf "智能错误分析主函数测试完成\n"

(** 测试错误详情解析函数 *)
let test_error_details_parsing () =
  Printf.printf "测试错误详情解析函数...\n";

  (* 测试未定义变量详情解析 *)
  let var_name, available_vars =
    parse_undefined_variable_details [ "test_var"; "var1;var2;var3" ]
  in
  check string "变量名应正确解析" "test_var" var_name;
  check int "可用变量数量应正确" 3 (List.length available_vars);

  (* 测试类型不匹配详情解析 *)
  let expected, actual = parse_type_mismatch_details [ "整数类型"; "字符串类型" ] in
  check string "期望类型应正确解析" "整数类型" expected;
  check string "实际类型应正确解析" "字符串类型" actual;

  (* 测试函数参数详情解析 *)
  let exp_str, act_str, func_name = parse_function_arity_details [ "3"; "1"; "test_function" ] in
  check string "期望参数数量应正确解析" "3" exp_str;
  check string "实际参数数量应正确解析" "1" act_str;
  check string "函数名应正确解析" "test_function" func_name;

  (* 测试边界情况 - 不完整的详情 *)
  let _, empty_vars = parse_undefined_variable_details [ "only_var" ] in
  check int "不完整详情应正确处理" 0 (List.length empty_vars);

  Printf.printf "错误详情解析函数测试完成\n"

(** 测试边界条件和异常情况 *)
let test_edge_cases () =
  Printf.printf "测试边界条件和异常情况...\n";

  (* 测试极长字符串的相似度计算 *)
  let long_str1 = String.make 100 'a' in
  let long_str2 = String.make 101 'a' in
  let long_similarity = calculate_similarity_score long_str1 long_str2 in
  check bool "极长字符串相似度应在合理范围" true (long_similarity >= 0.0 && long_similarity <= 1.0);

  (* 测试Unicode字符串处理 *)
  let unicode_similarity = calculate_similarity_score "测试变量" "测试变数" in
  check bool "Unicode字符串相似度应正确计算" true (unicode_similarity > 0.5);

  (* 测试大量可用变量的情况 *)
  let many_vars = Array.to_list (Array.init 100 (fun i -> "var" ^ string_of_int i)) in
  let many_similar = find_similar_variables "var50" many_vars in
  check bool "大量变量中应能找到相似变量" true (List.length many_similar > 0);

  (* 测试默认错误分析的创建 *)
  let default_analysis = create_default_error_analysis "custom_error" (Some "自定义上下文") in
  check string "默认分析错误类型应正确" "custom_error" default_analysis.error_type;
  check bool "默认分析应有合理的置信度" true (default_analysis.confidence >= 0.0);

  Printf.printf "边界条件和异常情况测试完成\n"

(** 错误消息分析模块测试套件 *)
let () =
  run "Error_messages_analysis模块测试"
    [
      ("编辑距离计算", [ test_case "字符串编辑距离" `Quick test_levenshtein_distance ]);
      ("相似度计算", [ test_case "相似度分数计算" `Quick test_similarity_score ]);
      ("相似变量查找", [ test_case "相似变量查找" `Quick test_find_similar_variables ]);
      ("辅助函数", [ test_case "take_n辅助函数" `Quick test_take_n_helper ]);
      ("未定义变量分析", [ test_case "未定义变量分析" `Quick test_undefined_variable_analysis ]);
      ("类型不匹配分析", [ test_case "类型不匹配分析" `Quick test_type_mismatch_analysis ]);
      ("函数参数分析", [ test_case "函数参数错误分析" `Quick test_function_arity_analysis ]);
      ("模式匹配分析", [ test_case "模式匹配错误分析" `Quick test_pattern_match_analysis ]);
      ("智能分析主函数", [ test_case "智能错误分析" `Quick test_intelligent_error_analysis ]);
      ("详情解析", [ test_case "错误详情解析" `Quick test_error_details_parsing ]);
      ("边界条件", [ test_case "边界和异常情况" `Quick test_edge_cases ]);
    ]
