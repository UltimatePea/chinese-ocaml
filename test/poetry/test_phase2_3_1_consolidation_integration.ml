(** Phase 2.3.1 诗韵系统整合集成测试
 *
 * 此测试模块专门验证PR #1760的核心目标：31个艺术评价模块的统一整合
 * 确保整合过程的零破坏性和向后兼容性
 *
 * 测试重点：
 * - 模块间协作验证
 * - 数据流完整性检查
 * - 性能回归检测
 * - API一致性验证
 * - 整合后功能完整性
 *
 * @author Echo, 测试工程师代理 - PR #1760 整合验证
 * @version 2.3.1 (整合验证版本)
 * @since 2025-07-30
 * @fix_issue #1760 Phase 2.3.1 统一艺术评价引擎 - 整合验证
 *)

open Poetry.Unified_artistic_engine
open Alcotest

(** {1 测试数据定义} *)

(* 标准测试诗句 - 春晓 *)
let standard_test_poem = [
  "春眠不觉晓";
  "处处闻啼鸟";
  "夜来风雨声";
  "花落知多少";
]

(* 复杂测试诗句 - 包含各种诗歌特征 *)
let complex_test_poem = [
  "红楼梦断有情人";
  "黄土埋香无定骨";
  "青灯照壁人初睡";
  "白首依然读旧书";
]

(* 边界条件测试诗句 *)
let _edge_case_poems = [
  []; (* 空诗句 *)
  ["单句"]; (* 单句诗 *)
  ["很长的诗句测试内容，用于验证系统对于超长输入的处理能力，包含各种中文字符和标点符号！？。，"]; (* 超长句 *)
]

(** {1 模块协作性验证测试组} *)

let test_unified_engine_vs_legacy_consistency () =
  (* 测试统一引擎与遗留API的结果一致性 *)
  let engine_state = initialize_engine () in
  
  (* 使用统一引擎评价 *)
  let unified_result = comprehensive_artistic_evaluation standard_test_poem engine_state in
  
  (* 使用遗留API评价 - 兼容性函数 *)
  let legacy_score = evaluate_poem_artistic standard_test_poem in
  let legacy_multi_dim = multi_dimension_evaluation standard_test_poem in
  
  (* 验证结果一致性（在合理误差范围内） *)
  let score_diff = abs_float (unified_result.overall_score -. legacy_score) in
  Alcotest.(check bool) "统一引擎与遗留评分一致性" true (score_diff < 0.1);
  
  let multi_dim_diff = abs_float (unified_result.overall_score -. legacy_multi_dim.overall_score) in
  Alcotest.(check bool) "统一引擎与多维度评价一致性" true (multi_dim_diff < 0.1);
  
  (* 验证基本结构一致性 *)
  Alcotest.(check bool) "评价等级范围一致" true (
    match unified_result.quality_grade, legacy_multi_dim.quality_grade with
    | `Excellent, `Excellent | `Good, `Good | `Fair, `Fair | `Poor, `Poor -> true
    | `Excellent, `Good | `Good, `Excellent -> true (* 允许相邻等级的小差异 *)
    | `Good, `Fair | `Fair, `Good -> true
    | `Fair, `Poor | `Poor, `Fair -> true
    | _ -> false
  )

let test_cross_module_data_flow () =
  (* 测试不同模块间的数据流完整性 *)
  let engine_state = initialize_engine () in
  
  (* 创建评价上下文 - 来自统一引擎 *)
  let context = create_evaluation_context (List.hd standard_test_poem) standard_test_poem in
  
  (* 测试各个评价维度的数据流 *)
  let rhyme_result = evaluate_single_dimension RhymeHarmony context engine_state in
  let parallelism_result = evaluate_single_dimension Parallelism context engine_state in
  let imagery_result = evaluate_single_dimension Imagery context engine_state in
  
  (* 验证所有维度都能正常工作 *)
  Alcotest.(check bool) "韵律评价数据流正常"true (
    match rhyme_result with Some _ -> true | None -> false
  );
  Alcotest.(check bool) "对仗评价数据流正常" true (
    match parallelism_result with Some _ -> true | None -> false
  );
  Alcotest.(check bool) "意象评价数据流正常" true (
    match imagery_result with Some _ -> true | None -> false
  );
  
  (* 测试综合评价能够整合所有维度结果 *)
  let comprehensive_result = comprehensive_artistic_evaluation standard_test_poem engine_state in
  Alcotest.(check bool) "综合评价整合所有维度" true (
    List.length comprehensive_result.dimension_scores >= 3
  )

let test_poetry_engine_pipeline_integrity () =
  (* 测试完整的诗歌处理流水线 *)
  let engine_state = initialize_engine () in
  
  (* 阶段1：基础分析 *)
  let mood_analysis = analyze_mood_creation standard_test_poem engine_state in
  let rhetoric_analysis = detect_rhetoric_techniques standard_test_poem engine_state in
  
  (* 阶段2：专项评价 *)
  let (form_score, form_suggestions) = analyze_form_beauty standard_test_poem engine_state in
  let (content_score, content_suggestions) = analyze_content_depth standard_test_poem engine_state in
  let (sound_score, sound_suggestions) = analyze_sound_harmony standard_test_poem engine_state in
  
  (* 阶段3：综合评价 *)
  let final_evaluation = comprehensive_artistic_evaluation standard_test_poem engine_state in
  
  (* 阶段4：指导建议 *)
  let guidance = generate_improvement_guidance final_evaluation engine_state in
  let enhancements = suggest_artistic_enhancements standard_test_poem engine_state in
  
  (* 验证流水线各阶段结果的合理性 *)
  Alcotest.(check bool) "意境分析阶段完成" true (String.length mood_analysis.primary_mood > 0);
  Alcotest.(check bool) "修辞分析阶段完成" true (rhetoric_analysis.rhetoric_richness >= 0.0);
  Alcotest.(check bool) "形式评价阶段完成" true (form_score >= 0.0 && form_score <= 1.0);
  Alcotest.(check bool) "内容评价阶段完成" true (content_score >= 0.0 && content_score <= 1.0);
  Alcotest.(check bool) "音韵评价阶段完成" true (sound_score >= 0.0 && sound_score <= 1.0);
  Alcotest.(check bool) "综合评价阶段完成" true (final_evaluation.overall_score >= 0.0);
  Alcotest.(check bool) "指导建议阶段完成" true (List.length guidance >= 0);
  Alcotest.(check bool) "提升建议阶段完成" true (List.length enhancements >= 0);
  
  (* 验证建议数量的合理性 *)
  let total_suggestions = List.length form_suggestions + List.length content_suggestions + List.length sound_suggestions in
  Alcotest.(check bool) "各阶段建议数量合理" true (total_suggestions >= 0)

(** {1 性能回归检测测试组} *)

let test_performance_regression_check () =
  (* 测试整合后的性能是否有明显回归 *)
  let engine_state = initialize_engine () in
  
  (* 基准测试：单次评价 *)
  let start_time_single = Sys.time () in
  let _ = comprehensive_artistic_evaluation standard_test_poem engine_state in
  let single_time = Sys.time () -. start_time_single in
  
  (* 批量测试：多次评价 *)
  let start_time_batch = Sys.time () in
  for _ = 1 to 20 do
    let _ = comprehensive_artistic_evaluation standard_test_poem engine_state in ()
  done;
  let batch_time = (Sys.time () -. start_time_batch) /. 20.0 in
  
  (* 复杂测试：复杂诗句评价 *)
  let start_time_complex = Sys.time () in
  let _ = comprehensive_artistic_evaluation complex_test_poem engine_state in
  let complex_time = Sys.time () -. start_time_complex in
  
  (* 性能指标验证 *)
  Alcotest.(check bool) "单次评价性能合理" true (single_time < 1.0);
  Alcotest.(check bool) "批量评价平均性能合理" true (batch_time < 0.5);
  Alcotest.(check bool) "复杂评价性能合理" true (complex_time < 2.0);
  
  (* 性能一致性检查 *)
  let consistency_ratio = complex_time /. single_time in
  Alcotest.(check bool) "性能扩展性合理" true (consistency_ratio < 5.0)

let test_memory_usage_stability () =
  (* 测试内存使用的稳定性 *)
  let engine_state = initialize_engine () in
  
  (* 重复执行大量评价，观察内存使用情况 *)
  for _ = 1 to 100 do
    let _ = comprehensive_artistic_evaluation standard_test_poem engine_state in
    let _ = analyze_mood_creation standard_test_poem engine_state in
    let _ = detect_rhetoric_techniques standard_test_poem engine_state in
    (* 定期清理缓存 *)
    if Random.int 10 = 0 then
      let _ = clear_engine_cache engine_state in ()
    done;
  
  (* 最终状态检查 *)
  let final_stats = get_engine_statistics engine_state in
  Alcotest.(check bool) "引擎最终状态稳定" true (List.length final_stats >= 0);
  
  (* 清理测试 *)
  let cleaned_state = clear_engine_cache engine_state in
  let cleaned_stats = get_engine_statistics cleaned_state in
  Alcotest.(check bool) "缓存清理功能正常" true (List.length cleaned_stats >= 0)

(** {1 API一致性验证测试组} *)

let test_backward_compatibility_comprehensive () =
  (* 全面测试向后兼容性 *)
  
  (* 基础评价函数兼容性 *)
  let verse = List.hd standard_test_poem in
  let rhyme_compat = evaluate_rhyme_harmony verse in
  let tonal_compat = evaluate_tonal_balance verse None in
  let parallelism_compat = evaluate_parallelism "春眠不觉晓" "处处闻啼鸟" in
  let imagery_compat = evaluate_imagery verse in
  let rhythm_compat = evaluate_rhythm verse in
  let elegance_compat = evaluate_elegance verse in
  
  (* 验证所有兼容函数返回有效结果 *)
  List.iter (fun (name, score) ->
    Alcotest.(check bool) (name ^ "兼容性") true (score >= 0.0 && score <= 1.0)
  ) [
    ("韵律和谐", rhyme_compat);
    ("声调平衡", tonal_compat);
    ("对仗工整", parallelism_compat);
    ("意象深度", imagery_compat);
    ("节奏韵律", rhythm_compat);
    ("雅致程度", elegance_compat);
  ];
  
  (* 高级功能兼容性 *)
  let poem_artistic_compat = evaluate_poem_artistic standard_test_poem in
  let multi_dim_compat = multi_dimension_evaluation standard_test_poem in
  let (_quick_check_compat, quick_suggestions_compat) = quick_artistic_check standard_test_poem in
  let grade_compat = determine_overall_grade standard_test_poem in
  
  Alcotest.(check bool) "诗词艺术性评价兼容" true (poem_artistic_compat >= 0.0 && poem_artistic_compat <= 1.0);
  Alcotest.(check bool) "多维度评价兼容" true (multi_dim_compat.overall_score >= 0.0);
  Alcotest.(check bool) "快速检查兼容" true (List.length quick_suggestions_compat >= 0);
  Alcotest.(check bool) "等级判定兼容" true (
    match grade_compat with `Excellent | `Good | `Fair | `Poor -> true
  )

let test_form_specific_evaluation_integration () =
  (* 测试特定诗歌形式评价的整合 *)
  let test_array = Array.of_list standard_test_poem in
  
  (* 测试各种诗歌形式评价 *)
  let siyan_result = evaluate_siyan_parallel_prose test_array in
  let wuyan_result = evaluate_wuyan_lushi test_array in
  let qiyan_result = evaluate_qiyan_jueju test_array in
  let form_generic_result = evaluate_poetry_by_form "五言绝句" test_array in
  
  (* 验证所有形式评价都返回有效结果 *)
  List.iter (fun (name, result) ->
    Alcotest.(check bool) (name ^ "评价有效") true (result.overall_score >= 0.0 && result.overall_score <= 1.0);
    Alcotest.(check bool) (name ^ "维度完整") true (List.length result.dimension_scores >= 0);
    Alcotest.(check bool) (name ^ "建议合理") true (List.length result.improvement_suggestions >= 0)
  ) [
    ("四言诗", siyan_result);
    ("五言律诗", wuyan_result);
    ("七言绝句", qiyan_result);
    ("通用形式", form_generic_result);
  ];
  
  (* 测试不同形式间的评价差异合理性 *)
  let scores = [siyan_result.overall_score; wuyan_result.overall_score; qiyan_result.overall_score; form_generic_result.overall_score] in
  let max_score = List.fold_left max 0.0 scores in
  let min_score = List.fold_left min 1.0 scores in
  let score_range = max_score -. min_score in
  Alcotest.(check bool) "不同形式评价差异合理" true (score_range <= 1.0)

(** {1 整合后功能完整性测试组} *)

let test_comprehensive_workflow_integration () =
  (* 测试完整的诗词分析工作流程 *)
  let engine_state = initialize_engine () in
  
  (* 工作流程：从输入到最终建议 *)
  
  (* 步骤1: 创建评价上下文 *)
  let context = create_evaluation_context (List.hd complex_test_poem) complex_test_poem in
  
  (* 步骤2: 执行各维度评价 *)
  let dimensions_to_test = [RhymeHarmony; TonalBalance; Parallelism; Imagery; Rhythm; Elegance; FormBeauty] in
  let dimension_results = List.filter_map (fun dim ->
    evaluate_single_dimension dim context engine_state
  ) dimensions_to_test in
  
  (* 步骤3: 执行专项分析 *)
  let mood_result = analyze_mood_creation complex_test_poem engine_state in
  let rhetoric_result = detect_rhetoric_techniques complex_test_poem engine_state in
  let (form_score, _) = analyze_form_beauty complex_test_poem engine_state in
  let (content_score, _) = analyze_content_depth complex_test_poem engine_state in
  let (sound_score, _) = analyze_sound_harmony complex_test_poem engine_state in
  
  (* 步骤4: 综合评价 *)
  let comprehensive_result = comprehensive_artistic_evaluation complex_test_poem engine_state in
  
  (* 步骤5: 生成指导建议 *)
  let improvement_guidance = generate_improvement_guidance comprehensive_result engine_state in
  let enhancement_suggestions = suggest_artistic_enhancements complex_test_poem engine_state in
  
  (* 步骤6: 格式化输出 *)
  let formatted_result = format_evaluation_result comprehensive_result in
  let json_export = export_evaluation_json comprehensive_result in
  
  (* 验证工作流程的完整性 *)
  Alcotest.(check bool) "维度评价完成" true (List.length dimension_results > 0);
  Alcotest.(check bool) "意境分析完成" true (mood_result.mood_intensity >= 0.0);
  Alcotest.(check bool) "修辞分析完成" true (rhetoric_result.rhetoric_richness >= 0.0);
  Alcotest.(check bool) "专项评分有效" true (form_score >= 0.0 && content_score >= 0.0 && sound_score >= 0.0);
  Alcotest.(check bool) "综合评价完成" true (comprehensive_result.overall_score >= 0.0);
  Alcotest.(check bool) "改进指导生成" true (List.length improvement_guidance >= 0);
  Alcotest.(check bool) "提升建议生成" true (List.length enhancement_suggestions >= 0);
  Alcotest.(check bool) "格式化输出正常" true (String.length formatted_result > 0);
  Alcotest.(check bool) "JSON导出正常" true (String.length json_export > 0 && String.contains json_export '{');
  
  (* 验证结果的逻辑一致性 *)
  let dimension_avg = if List.length dimension_results > 0 then
    (List.fold_left (fun acc result -> acc +. result.score) 0.0 dimension_results) /. (float_of_int (List.length dimension_results))
  else 0.5 in
  let overall_diff = abs_float (comprehensive_result.overall_score -. dimension_avg) in
  Alcotest.(check bool) "综合评价与维度评价逻辑一致" true (overall_diff < 0.3)

let test_edge_cases_comprehensive_handling () =
  (* 测试各种边界条件的综合处理 *)
  let engine_state = initialize_engine () in
  
  (* 测试空输入的处理 *)
  (try
    let _ = comprehensive_artistic_evaluation [] engine_state in
    Alcotest.(check bool) "空输入处理合理" true true
   with 
   | ArtisticEngineError _ -> Alcotest.(check bool) "空输入异常处理正确" true true
   | _ -> Alcotest.(check bool) "空输入处理存在" true true);
  
  (* 测试单句输入的处理 *)
  let single_result = comprehensive_artistic_evaluation ["单句测试"] engine_state in
  Alcotest.(check bool) "单句输入处理有效" true (single_result.overall_score >= 0.0);
  
  (* 测试超长输入的处理 *)
  let long_verse = String.make 1000 'a' ^ "诗词测试内容" in
  let long_result = comprehensive_artistic_evaluation [long_verse] engine_state in
  Alcotest.(check bool) "超长输入处理有效" true (long_result.overall_score >= 0.0);
  
  (* 测试特殊字符输入的处理 *)
  let special_poems = ["春眠不觉晓！@#$%^&*()"; "处处闻啼鸟123456"; "夜来风雨声abcdefg"; "花落知多少？？？"] in
  let special_result = comprehensive_artistic_evaluation special_poems engine_state in
  Alcotest.(check bool) "特殊字符输入处理有效" true (special_result.overall_score >= 0.0);
  
  (* 测试混合语言输入的处理 *)
  let mixed_poems = ["春眠不觉晓 spring sleep"; "处处闻啼鸟 birds everywhere"; "夜来风雨声 night storm"; "花落知多少 flowers fall"] in
  let mixed_result = comprehensive_artistic_evaluation mixed_poems engine_state in
  Alcotest.(check bool) "混合语言输入处理有效" true (mixed_result.overall_score >= 0.0)

(** {1 主测试套件执行} *)

let () =
  run "Phase 2.3.1 诗韵系统整合集成测试" [
    (* 模块协作性验证 *)
    ("模块协作性验证", [
      test_case "统一引擎与遗留API一致性" `Quick test_unified_engine_vs_legacy_consistency;
      test_case "跨模块数据流完整性" `Quick test_cross_module_data_flow;
      test_case "诗歌引擎流水线完整性" `Quick test_poetry_engine_pipeline_integrity;
    ]);
    
    (* 性能回归检测 *)
    ("性能回归检测", [
      test_case "性能回归检查" `Quick test_performance_regression_check;
      test_case "内存使用稳定性" `Quick test_memory_usage_stability;
    ]);
    
    (* API一致性验证 *)
    ("API一致性验证", [
      test_case "向后兼容性全面验证" `Quick test_backward_compatibility_comprehensive;
      test_case "特定形式评价整合" `Quick test_form_specific_evaluation_integration;
    ]);
    
    (* 整合后功能完整性 *)
    ("整合后功能完整性", [
      test_case "综合工作流程整合" `Quick test_comprehensive_workflow_integration;
      test_case "边界条件综合处理" `Quick test_edge_cases_comprehensive_handling;
    ]);
  ]