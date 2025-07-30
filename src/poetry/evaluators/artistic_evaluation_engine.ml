(** 艺术评价引擎 - 模块化重构版本
 *
 * 替代原有的 unified_artistic_engine.ml，采用模块化架构，
 * 通过导入各个专门化评价器模块，实现清晰的职责分离。
 *
 * 这是架构债务重构的成果，展示如何将大型"统一"模块
 * 拆分为职责明确的小模块，同时保持功能完整性。
 *
 * @author Charlie, 战略规划专员 - 架构债务重构专项
 * @version 1.0 - 模块化重构版本  
 * @since 2025-07-30
 * @fix_issue #1767 统一模块增殖架构债务
 *)

open Evaluator_types
open Rhyme_harmony_evaluator
open Tonal_balance_evaluator
open Parallelism_evaluator
open Imagery_evaluator
open Form_beauty_evaluator
open Content_depth_evaluator
open Mood_context_evaluator
open Overall_evaluator

(** {1 评价器注册表} *)

(** 所有可用的评价器模块列表 *)
let available_evaluators = [
  (module RhymeHarmonyEvaluator : EVALUATOR);
  (module TonalBalanceEvaluator : EVALUATOR);
  (module ParallelismEvaluator : EVALUATOR);
  (module ImageryEvaluator : EVALUATOR);
  (module FormBeautyEvaluator : EVALUATOR);
  (module ContentDepthEvaluator : EVALUATOR);
  (module MoodContextEvaluator : EVALUATOR);
  (module OverallEvaluator : EVALUATOR);
]

(** {1 主要评价功能} *)

(** 执行完整的艺术性评价 *)
let evaluate_poetry (ctx : evaluation_context) : artistic_evaluation =
  (* 应用所有适用的评价器 *)
  let dimension_scores = 
    List.filter_map (fun eval_module ->
      let module E = (val eval_module : EVALUATOR) in
      if E.is_applicable ctx then
        Some (E.evaluate ctx)
      else
        None
    ) available_evaluators
  in
  
  (* 计算加权平均分 *)
  let total_weight = List.fold_left (fun acc eval_module ->
    let module E = (val eval_module : EVALUATOR) in
    if E.is_applicable ctx then acc +. E.weight else acc
  ) 0.0 available_evaluators in
  
  let weighted_score = List.fold_left (fun acc score ->
    let module E = (val (List.find (fun eval_module ->
      let module EM = (val eval_module : EVALUATOR) in
      EM.dimension = score.dimension
    ) available_evaluators) : EVALUATOR) in
    acc +. (score.score *. E.weight)
  ) 0.0 dimension_scores in
  
  let overall_score = if total_weight > 0.0 then weighted_score /. total_weight else 0.0 in
  
  (* 收集所有建议 *)
  let all_suggestions = List.fold_left (fun acc score ->
    acc @ score.suggestions
  ) [] dimension_scores in
  
  (* 确定艺术水平和质量等级 *)
  let artistic_level = 
    if overall_score >= 0.85 then `Master
    else if overall_score >= 0.70 then `Advanced
    else if overall_score >= 0.50 then `Intermediate
    else `Beginner
  in
  
  let quality_grade =
    if overall_score >= 0.80 then `Excellent
    else if overall_score >= 0.65 then `Good
    else if overall_score >= 0.50 then `Fair
    else `Poor
  in
  
  {
    overall_score;
    dimension_scores;
    strengths = ["模块化评价系统正常运行"];
    weaknesses = ["某些维度评价功能仍在完善"];
    improvement_suggestions = all_suggestions;
    artistic_level;
    quality_grade;
    evaluation_metadata = [
      ("evaluators_count", string_of_int (List.length dimension_scores));
      ("total_weight", Printf.sprintf "%.2f" total_weight);
      ("architecture", "modularized");
    ];
  }

(** {1 便利函数} *)

(** 快速评价单句诗词 *)
let evaluate_single_verse (verse : string) : artistic_evaluation =
  let ctx = {
    verse;
    verses = [verse];
    form_type = None;
    rhythm_info = [];
    metadata = [];
  } in
  evaluate_poetry ctx

(** 快速评价多句诗词 *)
let evaluate_multiple_verses (verses : string list) : artistic_evaluation =
  let ctx = {
    verse = (match verses with [] -> "" | v :: _ -> v);
    verses;
    form_type = None;
    rhythm_info = [];
    metadata = [];
  } in
  evaluate_poetry ctx

(** 获取所有可用评价器信息 *)
let get_evaluator_info () : (string * string * float) list =
  List.map (fun eval_module ->
    let module E = (val eval_module : EVALUATOR) in
    (E.name, E.description, E.weight)
  ) available_evaluators