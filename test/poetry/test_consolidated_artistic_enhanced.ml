(** 整合艺术评价引擎增强测试 - 验证Phase 2算法改进
  
    测试consolidated_artistic_engine的增强算法是否提供更好的评价质量
    
    Author: Whisky, PR Worker - Issue #2179 Phase 2 增强验证专家
    @test_issue #2179 - Poetry艺术评价模块整合 Phase 2
    @focus 算法质量验证，而非向后兼容性
*)

open Poetry_artistic.Consolidated_artistic_engine
module A = Alcotest

(** {1 测试数据} *)

let test_verse_high_quality = "春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。" (* 高质量诗句 *)
let test_verse_low_quality = "abc def ghi" (* 低质量文本 *)
let test_verses_poem = ["春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"]
(* let test_poem = String.concat "\n" test_verses_poem *)

(** {1 增强算法质量测试} *)

let test_enhanced_rhyme_harmony () =
  let high_score = evaluate_rhyme_harmony test_verse_high_quality in
  let low_score = evaluate_rhyme_harmony test_verse_low_quality in
  
  (* 高质量诗句应该获得更高分数 *)
  A.(check bool) "高质量诗句韵律和谐分数应高于低质量文本" true (high_score > low_score);
  
  (* 分数应在合理范围内 *)
  A.(check bool) "韵律和谐分数应在0-1范围内" true (high_score >= 0.0 && high_score <= 1.0);
  A.(check bool) "低质量文本分数应在0-1范围内" true (low_score >= 0.0 && low_score <= 1.0)

let test_enhanced_imagery_evaluation () =
  let nature_verse = "山花水鸟月风雨云雪" in  (* 丰富自然意象 *)
  let plain_verse = "今天天气很好" in  (* 普通描述 *)
  
  let nature_score = evaluate_imagery nature_verse in
  let plain_score = evaluate_imagery plain_verse in
  
  (* 自然意象丰富的诗句应该获得更高分数 *)
  A.(check bool) "丰富意象诗句应高于普通描述" true (nature_score > plain_score);
  
  (* 分数应在合理范围内 *)
  A.(check bool) "意象分数应在0-1范围内" true (nature_score >= 0.0 && nature_score <= 1.0)

let test_enhanced_elegance_evaluation () =
  let elegant_verse = "雅致清淡幽静深远高妙" in  (* 雅致词汇 *)
  let vulgar_verse = "俗低粗恶脏丑" in  (* 粗俗词汇 *)
  
  let elegant_score = evaluate_elegance elegant_verse in
  let vulgar_score = evaluate_elegance vulgar_verse in
  
  (* 雅致词汇应该获得更高分数 *)
  A.(check bool) "雅致词汇应高于粗俗词汇" true (elegant_score > vulgar_score);
  
  (* 雅致词汇应该获得较高分数（>0.7） *)
  A.(check bool) "雅致词汇应获得较高分数" true (elegant_score > 0.7)

let test_enhanced_rhythm_evaluation () =
  let standard_qiyan = "春眠不觉晓处处闻啼鸟夜来风雨声花落知多少" in  (* 标准七言长度 *)
  let irregular_length = "短" in  (* 不规范长度 *)
  
  let standard_score = evaluate_rhythm standard_qiyan in
  let irregular_score = evaluate_rhythm irregular_length in
  
  (* 标准长度应该获得更高分数 *)
  A.(check bool) "标准诗句长度应高于不规范长度" true (standard_score > irregular_score);
  
  (* 分数应在合理范围内 *)
  A.(check bool) "节奏分数应在0-1范围内" true (standard_score >= 0.0 && standard_score <= 1.0)

let test_enhanced_parallelism_evaluation () =
  let left_verse = "春眠不觉晓" in
  let right_verse = "处处闻啼鸟" in  (* 相同长度，语义对应 *)
  let mismatch_verse = "短" in  (* 长度不匹配 *)
  
  let good_score = evaluate_parallelism left_verse right_verse in
  let bad_score = evaluate_parallelism left_verse mismatch_verse in
  
  (* 匹配的对仗应该获得更高分数 *)
  A.(check bool) "匹配对仗应高于不匹配对仗" true (good_score > bad_score);
  
  (* 分数应在合理范围内 *)
  A.(check bool) "对仗分数应在0-1范围内" true (good_score >= 0.0 && good_score <= 1.0)

(** {1 综合评价增强测试} *)

let test_comprehensive_evaluation_enhanced () =
  let context = {
    verse = List.hd test_verses_poem;
    verses = test_verses_poem;
    poem_type = Some "qiyan_jueju";
    author = Some "孟浩然";
    historical_context = Some "唐代";
    metadata = [("test", "enhanced")];
  } in
  
  let evaluation = evaluate_artistic_work
    (CoreEvaluation ComprehensiveEvaluation) context in
  
  (* 验证评价结果结构完整性 *)
  A.(check bool) "总体分数应在有效范围内" true 
    (evaluation.overall_score >= 0.0 && evaluation.overall_score <= 1.0);
  A.(check bool) "维度分数列表不应为空" true
    (List.length evaluation.dimension_scores > 0);
  A.(check bool) "元数据应包含增强版本信息" true
    (List.exists (fun (k, v) -> k = "version" && String.contains v 'v') evaluation.evaluation_metadata);
  A.(check bool) "应包含算法版本标记" true
    (List.exists (fun (k, v) -> k = "algorithm_version" && v = "phase2-enhanced") evaluation.evaluation_metadata)

let test_weighted_evaluation_system () =
  let context = {
    verse = "春眠不觉晓";
    verses = ["春眠不觉晓"; "处处闻啼鸟"];
    poem_type = None;
    author = None;
    historical_context = None;
    metadata = [];
  } in
  
  (* 测试不同评价类型 *)
  let rhyme_eval = evaluate_artistic_work
    (CoreEvaluation RhymeHarmonyEvaluation) context in
  let imagery_eval = evaluate_artistic_work
    (CoreEvaluation ImageryEvaluation) context in
  
  (* 专项评价应该有相应的维度分数 *)
  A.(check bool) "韵律专项评价应包含韵律维度" true
    (List.exists (fun ds -> ds.dimension = RhymeHarmony) rhyme_eval.dimension_scores);
  A.(check bool) "意象专项评价应包含意象维度" true
    (List.exists (fun ds -> ds.dimension = Imagery) imagery_eval.dimension_scores)

(** {1 性能和质量测试} *)

let test_evaluation_consistency () =
  let context = {
    verse = test_verse_high_quality;
    verses = test_verses_poem;
    poem_type = None;
    author = None;
    historical_context = None;
    metadata = [];
  } in
  
  (* 多次评价应该产生一致结果（由于缓存） *)
  let eval1 = evaluate_artistic_work
    (CoreEvaluation ComprehensiveEvaluation) context in
  let eval2 = evaluate_artistic_work
    (CoreEvaluation ComprehensiveEvaluation) context in
  
  A.(check (float 0.001)) "多次评价应产生一致结果" 
    eval1.overall_score eval2.overall_score

let test_batch_evaluation_quality () =
  let contexts = [
    {
      verse = "春眠不觉晓"; verses = ["春眠不觉晓"]; 
      poem_type = None; author = None; historical_context = None; metadata = [];
    };
    {
      verse = "处处闻啼鸟"; verses = ["处处闻啼鸟"]; 
      poem_type = None; author = None; historical_context = None; metadata = [];
    };
  ] in
  
  let results = batch_evaluate_artistic_works
    (CoreEvaluation RhymeHarmonyEvaluation) contexts in
  
  A.(check int) "批量评价应返回正确数量结果" 2 (List.length results);
  List.iter (fun eval ->
    A.(check bool) "批量评价结果分数应在有效范围内" true
      (eval.overall_score >= 0.0 && eval.overall_score <= 1.0)
  ) results

(** {1 测试套件} *)

let enhanced_algorithms_tests = [
  ("Enhanced rhyme harmony", `Quick, test_enhanced_rhyme_harmony);
  ("Enhanced imagery evaluation", `Quick, test_enhanced_imagery_evaluation);
  ("Enhanced elegance evaluation", `Quick, test_enhanced_elegance_evaluation);
  ("Enhanced rhythm evaluation", `Quick, test_enhanced_rhythm_evaluation);
  ("Enhanced parallelism evaluation", `Quick, test_enhanced_parallelism_evaluation);
]

let comprehensive_tests = [
  ("Comprehensive evaluation enhanced", `Quick, test_comprehensive_evaluation_enhanced);
  ("Weighted evaluation system", `Quick, test_weighted_evaluation_system);
]

let quality_tests = [
  ("Evaluation consistency", `Quick, test_evaluation_consistency);
  ("Batch evaluation quality", `Quick, test_batch_evaluation_quality);
]

let () = 
  A.run "Consolidated Artistic Engine - Phase 2 Enhanced Tests" [
    ("Enhanced algorithms", enhanced_algorithms_tests);
    ("Comprehensive evaluation", comprehensive_tests);
    ("Quality assurance", quality_tests);
  ]