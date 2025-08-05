(** 整合艺术评价引擎迁移测试 - 验证新旧接口等价性
  
    测试consolidated_artistic_engine与原有模块功能等价性
    确保迁移不会破坏现有功能
    
    Author: Whisky, PR Worker - Issue #2179 迁移验证专家
    @test_issue #2179 - Poetry艺术评价模块整合
    @pr #2186
*)

open OUnit2

(** {1 测试数据} *)

let test_verse = "春眠不觉晓"
let test_verses = ["春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"]
let test_poem = String.concat "\n" test_verses

(** {1 核心评价函数等价性测试} *)

let test_rhyme_harmony_equivalence _ =
  let old_score = Poetry_artistic.Artistic_core.evaluate_rhyme_harmony test_verse in
  let new_score = Poetry_artistic.Consolidated_artistic_engine.Legacy_Core.evaluate_rhyme_harmony test_verse in
  assert_equal ~printer:string_of_float old_score new_score ~msg:"韵律和谐评价结果应相等"

let test_tonal_balance_equivalence _ =
  let old_score = Poetry_artistic.Artistic_core.evaluate_tonal_balance test_verse None in
  let new_score = Poetry_artistic.Consolidated_artistic_engine.Legacy_Core.evaluate_tonal_balance test_verse "" in
  assert_equal ~printer:string_of_float old_score new_score ~msg:"声调平衡评价结果应相等"

let test_imagery_equivalence _ =
  let old_score = Poetry_artistic.Artistic_core.evaluate_imagery test_verse in
  let new_score = Poetry_artistic.Consolidated_artistic_engine.Legacy_Core.evaluate_imagery test_verse in
  assert_equal ~printer:string_of_float old_score new_score ~msg:"意象评价结果应相等"

let test_rhythm_equivalence _ =
  let old_score = Poetry_artistic.Artistic_core.evaluate_rhythm test_verse in
  let new_score = Poetry_artistic.Consolidated_artistic_engine.Legacy_Core.evaluate_rhythm test_verse in
  assert_equal ~printer:string_of_float old_score new_score ~msg:"节奏评价结果应相等"

let test_elegance_equivalence _ =
  let old_score = Poetry_artistic.Artistic_core.evaluate_elegance test_verse in
  let new_score = Poetry_artistic.Consolidated_artistic_engine.Legacy_Core.evaluate_elegance test_verse in
  assert_equal ~printer:string_of_float old_score new_score ~msg:"雅致程度评价结果应相等"

let test_parallelism_equivalence _ =
  let left_verse = "春眠不觉晓" in
  let right_verse = "处处闻啼鸟" in
  let old_score = Poetry_artistic.Artistic_core.evaluate_parallelism left_verse right_verse in
  let new_score = Poetry_artistic.Consolidated_artistic_engine.Legacy_Core.evaluate_parallelism left_verse right_verse in
  assert_equal ~printer:string_of_float old_score new_score ~msg:"对仗评价结果应相等"

(** {1 统一引擎等价性测试} *)

let test_unified_comprehensive_evaluation_equivalence _ =
  let old_eval = Poetry_artistic.Artistic_engine_unified.comprehensive_artistic_evaluation test_poem in
  let new_eval = Poetry_artistic.Consolidated_artistic_engine.Legacy_Unified.comprehensive_artistic_evaluation test_poem in
  
  (* 比较总体分数 *)
  assert_equal ~printer:string_of_float 
    old_eval.overall_score new_eval.overall_score 
    ~msg:"统一引擎综合评价总分应相等";
  
  (* 比较维度分数数量 *)
  assert_equal ~printer:string_of_int
    (List.length old_eval.dimension_scores) (List.length new_eval.dimension_scores)
    ~msg:"维度分数数量应相等";
  
  (* 比较优势列表长度 *)
  assert_equal ~printer:string_of_int
    (List.length old_eval.strengths) (List.length new_eval.strengths)
    ~msg:"优势列表长度应相等"

(** {1 诗体专门评价函数等价性测试} *)

let test_wuyan_lushi_equivalence _ =
  let old_engine_state = Poetry_artistic.Artistic_core.initialize_engine () in
  let old_eval = Poetry_artistic.Artistic_core.comprehensive_artistic_evaluation test_verses old_engine_state in
  let new_eval = Poetry_artistic.Consolidated_artistic_engine.Legacy_Core.evaluate_wuyan_lushi test_poem in
  
  (* 比较总体分数 (允许小幅误差) *)
  assert_bool "五言律诗评价分数应在合理范围内"
    (abs_float (old_eval.overall_score -. new_eval.overall_score) < 0.1)

let test_qiyan_jueju_equivalence _ =
  let old_engine_state = Poetry_artistic.Artistic_core.initialize_engine () in
  let old_eval = Poetry_artistic.Artistic_core.comprehensive_artistic_evaluation test_verses old_engine_state in
  let new_eval = Poetry_artistic.Consolidated_artistic_engine.Legacy_Core.evaluate_qiyan_jueju test_poem in
  
  (* 比较总体分数 (允许小幅误差) *)
  assert_bool "七言绝句评价分数应在合理范围内"
    (abs_float (old_eval.overall_score -. new_eval.overall_score) < 0.1)

(** {1 新功能特性测试} *)

let test_consolidated_engine_new_features _ =
  (* 测试新的统一接口 *)
  let context = Poetry_artistic.Consolidated_artistic_engine.{
    verse = test_verse;
    verses = test_verses;
    poem_type = Some "qiyan_jueju";
    author = Some "孟浩然";
    historical_context = Some "唐代";
    metadata = [("test", "migration")];
  } in
  
  let evaluation = Poetry_artistic.Consolidated_artistic_engine.evaluate_artistic_work
    (CoreEvaluation ComprehensiveEvaluation) context in
  
  (* 验证评价结果结构完整性 *)
  assert_bool "总体分数应在有效范围内" 
    (evaluation.overall_score >= 0.0 && evaluation.overall_score <= 1.0);
  assert_bool "维度分数列表不应为空"
    (List.length evaluation.dimension_scores > 0);
  assert_bool "元数据应包含版本信息"
    (List.exists (fun (k, _) -> k = "version") evaluation.evaluation_metadata)

let test_batch_evaluation _ =
  let context1 = Poetry_artistic.Consolidated_artistic_engine.{
    verse = "春眠不觉晓"; verses = ["春眠不觉晓"]; poem_type = None; 
    author = None; historical_context = None; metadata = [];
  } in
  let context2 = Poetry_artistic.Consolidated_artistic_engine.{
    verse = "处处闻啼鸟"; verses = ["处处闻啼鸟"]; poem_type = None;
    author = None; historical_context = None; metadata = [];
  } in
  
  let results = Poetry_artistic.Consolidated_artistic_engine.batch_evaluate_artistic_works
    (CoreEvaluation RhymeHarmonyEvaluation) [context1; context2] in
  
  assert_equal ~printer:string_of_int 2 (List.length results) ~msg:"批量评价应返回2个结果";
  List.iter (fun eval ->
    assert_bool "批量评价结果分数应在有效范围内"
      (eval.overall_score >= 0.0 && eval.overall_score <= 1.0)
  ) results

let test_performance_tracking _ =
  (* 启用性能跟踪 *)
  Poetry_artistic.Consolidated_artistic_engine.enable_artistic_performance_tracking true;
  
  (* 执行一些评价操作 *)
  let context = Poetry_artistic.Consolidated_artistic_engine.{
    verse = test_verse; verses = test_verses; poem_type = None;
    author = None; historical_context = None; metadata = [];
  } in
  let _ = Poetry_artistic.Consolidated_artistic_engine.evaluate_artistic_work
    (CoreEvaluation RhymeHarmonyEvaluation) context in
  
  (* 获取性能指标 *)
  let metrics = Poetry_artistic.Consolidated_artistic_engine.get_artistic_performance_metrics () in
  assert_bool "性能指标不应为空" (List.length metrics >= 0);
  
  (* 禁用性能跟踪 *)
  Poetry_artistic.Consolidated_artistic_engine.enable_artistic_performance_tracking false

(** {1 缓存功能测试} *)

let test_cache_functionality _ =
  (* 清理缓存 *)
  Poetry_artistic.Consolidated_artistic_engine.clear_artistic_cache ();
  
  let context = Poetry_artistic.Consolidated_artistic_engine.{
    verse = test_verse; verses = test_verses; poem_type = None;
    author = None; historical_context = None; metadata = [];
  } in
  
  (* 第一次评价 (无缓存) *)
  let result1 = Poetry_artistic.Consolidated_artistic_engine.evaluate_artistic_work
    (CoreEvaluation RhymeHarmonyEvaluation) context in
  
  (* 第二次评价 (有缓存) *)  
  let result2 = Poetry_artistic.Consolidated_artistic_engine.evaluate_artistic_work
    (CoreEvaluation RhymeHarmonyEvaluation) context in
  
  (* 验证缓存结果一致性 *)
  assert_equal ~printer:string_of_float 
    result1.overall_score result2.overall_score 
    ~msg:"缓存结果应与原始结果相同"

(** {1 已迁移模块功能测试} *)

let test_migrated_poetry_forms_evaluation _ =
  let verses = [|"春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"|] in
  
  (* 测试已迁移的函数是否正常工作 *)
  let wuyan_result = Poetry_forms_evaluation.evaluate_wuyan_lushi verses in
  assert_bool "五言律诗评价应返回有效结果"
    (wuyan_result.overall_grade <> Poetry_types.Poetry_types_consolidated.Poor);
  
  let qiyan_result = Poetry_forms_evaluation.evaluate_qiyan_jueju verses in
  assert_bool "七言绝句评价应返回有效结果"
    (qiyan_result.overall_grade <> Poetry_types.Poetry_types_consolidated.Poor);
  
  let parallel_result = Poetry_forms_evaluation.evaluate_siyan_parallel_prose verses in
  assert_bool "四言骈文评价应返回有效结果"
    (parallel_result.overall_grade <> Poetry_types.Poetry_types_consolidated.Poor)

(** {1 测试套件} *)

let suite = 
  "Consolidated Artistic Engine Migration Tests" >::: [
    (* 核心函数等价性测试 *)
    "test_rhyme_harmony_equivalence" >:: test_rhyme_harmony_equivalence;
    "test_tonal_balance_equivalence" >:: test_tonal_balance_equivalence;
    "test_imagery_equivalence" >:: test_imagery_equivalence;
    "test_rhythm_equivalence" >:: test_rhythm_equivalence;
    "test_elegance_equivalence" >:: test_elegance_equivalence;
    "test_parallelism_equivalence" >:: test_parallelism_equivalence;
    
    (* 统一引擎等价性测试 *)
    "test_unified_comprehensive_evaluation_equivalence" >:: test_unified_comprehensive_evaluation_equivalence;
    
    (* 诗体专门评价等价性测试 *)
    "test_wuyan_lushi_equivalence" >:: test_wuyan_lushi_equivalence;
    "test_qiyan_jueju_equivalence" >:: test_qiyan_jueju_equivalence;
    
    (* 新功能特性测试 *)
    "test_consolidated_engine_new_features" >:: test_consolidated_engine_new_features;
    "test_batch_evaluation" >:: test_batch_evaluation;
    "test_performance_tracking" >:: test_performance_tracking;
    "test_cache_functionality" >:: test_cache_functionality;
    
    (* 已迁移模块功能测试 *)
    "test_migrated_poetry_forms_evaluation" >:: test_migrated_poetry_forms_evaluation;
  ]

let () = run_test_tt_main suite