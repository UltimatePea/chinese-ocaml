(** 诗词艺术评价指标计算模块 - Phase 1-C 模块化重构
 *
 * 此模块实现评价指标计算功能和质量判定算法
 * 从原始 artistic_evaluators.ml 中提取的指标相关功能
 *
 * @author Whisky, PR Worker - Phase 1-C 模块化重构
 * @refactors Issue #2171 - Phase 1-C 代码重构现代化
 *)

open Artistic_core
open Artistic_config

(** {1 评价指标计算} *)

(** 艺术水平评价指标 *)
let determine_artistic_level overall_score =
  if overall_score >= ThresholdConfig.master_level_threshold then
    `Master
  else if overall_score >= ThresholdConfig.advanced_level_threshold then
    `Advanced
  else if overall_score >= ThresholdConfig.intermediate_level_threshold then
    `Intermediate
  else
    `Beginner

(** {1 质量等级计算} *)

type quality_scores = {
  rhyme_harmony : float;
  tonal_balance : float;
  parallelism : float;
  imagery : float;
  rhythm : float;
  elegance : float;
}

(** 计算综合质量等级 *)
let determine_overall_grade scores =
  let avg_score = 
    (scores.rhyme_harmony +. scores.tonal_balance +. scores.parallelism +. 
     scores.imagery +. scores.rhythm +. scores.elegance) /. 6.0
  in
  if avg_score >= ThresholdConfig.excellent_threshold then
    `Excellent
  else if avg_score >= ThresholdConfig.good_threshold then
    `Good
  else if avg_score >= ThresholdConfig.fair_threshold then
    `Fair
  else
    `Poor

(** {1 分数计算} *)

(** 综合分数 *)
let calculate_comprehensive_score dimension_scores =
  let weights = WeightConfig.all_weights in
  let scores = List.map (fun ds -> ds.score) dimension_scores in
  Artistic_core.calculate_weighted_score scores weights

(** 平均置信度 *)
let calculate_average_confidence dimension_scores =
  let confidences = List.map (fun ds -> ds.confidence) dimension_scores in
  let sum = List.fold_left (+.) 0.0 confidences in
  if List.length confidences > 0 then
    sum /. float_of_int (List.length confidences)
  else
    0.0

(** {1 批量评价指标} *)

(** 批量质量分析 *)
let batch_quality_analysis dimension_scores =
  let comprehensive_score = calculate_comprehensive_score dimension_scores in
  let avg_confidence = calculate_average_confidence dimension_scores in
  let artistic_level = determine_artistic_level comprehensive_score in
  
  (comprehensive_score, avg_confidence, artistic_level)

(** 评价等级分布分析 *)
let analyze_grade_distribution evaluations =
  let grades = List.map (fun eval -> eval.quality_grade) evaluations in
  let count_grade grade = List.length (List.filter (fun g -> g = grade) grades) in
  
  let excellent_count = count_grade `Excellent in
  let good_count = count_grade `Good in
  let fair_count = count_grade `Fair in
  let poor_count = count_grade `Poor in
  
  (excellent_count, good_count, fair_count, poor_count)

(** {1 维度评分统计} *)

(** 获取最高分维度 *)
let get_highest_scoring_dimension dimension_scores =
  List.fold_left (fun acc ds -> 
    match acc with
    | None -> Some ds
    | Some best -> if ds.score > best.score then Some ds else Some best
  ) None dimension_scores

(** 获取最低分维度 *)
let get_lowest_scoring_dimension dimension_scores =
  List.fold_left (fun acc ds -> 
    match acc with
    | None -> Some ds
    | Some worst -> if ds.score < worst.score then Some ds else Some worst
  ) None dimension_scores

(** 计算维度方差 *)
let calculate_dimension_variance dimension_scores =
  let scores = List.map (fun ds -> ds.score) dimension_scores in
  let avg = List.fold_left (+.) 0.0 scores /. float_of_int (List.length scores) in
  let variance = List.fold_left (fun acc score -> 
    acc +. ((score -. avg) ** 2.0)
  ) 0.0 scores in
  variance /. float_of_int (List.length scores)

(** {1 兼容性指标} *)

(** 生成兼容的评价分数结构 *)
let create_legacy_scores rhyme tonal parallelism imagery rhythm elegance =
  { rhyme_harmony = rhyme; tonal_balance = tonal; parallelism; imagery; rhythm; elegance }

(** 从dimension_scores提取legacy格式 *)
let extract_legacy_scores dimension_scores =
  let get_score dim = 
    match List.find_opt (fun ds -> ds.dimension = dim) dimension_scores with
    | Some ds -> ds.score
    | None -> default_evaluation_score
  in
  {
    rhyme_harmony = get_score RhymeHarmony;
    tonal_balance = get_score TonalBalance;
    parallelism = get_score Parallelism;
    imagery = get_score Imagery;
    rhythm = get_score Rhythm;
    elegance = get_score Elegance;
  }