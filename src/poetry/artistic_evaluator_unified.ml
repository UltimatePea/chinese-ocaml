(** 统一艺术性评价器模块 - 整合所有艺术性评价功能
    
    承古典诗学传统，建现代评价体系。
    此模块整合原有的多个艺术性评价器模块，消除功能重复，
    提供统一的诗词艺术性评价接口。
    
    Author: Beta, 代码审查代理  
    版本: 统一重构版 v1.0
    日期: 2025-07-28 *)

(* 导入核心类型和评价器模块 *)
open Artistic_evaluator_types
module Context = Artistic_evaluator_context
module Sound = Artistic_evaluator_sound  
module Form = Artistic_evaluator_form
module Content = Artistic_evaluator_content

(** {1 核心评价器模块重新导出} *)

(* 声律层面评价器 *)
module RhymeEvaluator = Sound.RhymeEvaluator
module ToneEvaluator = Sound.ToneEvaluator

(* 形式层面评价器 *)
module ParallelismEvaluator = Form.ParallelismEvaluator
module RhythmEvaluator = Form.RhythmEvaluator
module EleganceEvaluator = Form.EleganceEvaluator

(* 内容层面评价器 *)
module ImageryEvaluator = Content.ImageryEvaluator

(** {1 统一综合评价器} *)

(** 综合评价报告类型 *)
type comprehensive_report = {
  overall_score : float;
  individual_results : Artistic_evaluator_types.evaluation_result list;
  suggestions : string list;
  evaluation_timestamp : float;
  evaluator_version : string;
}

module UnifiedEvaluator = struct
  (** 所有评价器的注册表 - 涵盖诗词评价的全部维度 *)
  let all_evaluators = [
    (module RhymeEvaluator : EVALUATOR);    (* 韵律评价 *)
    (module ToneEvaluator : EVALUATOR);     (* 声调评价 *)
    (module ParallelismEvaluator : EVALUATOR); (* 对仗评价 *)
    (module RhythmEvaluator : EVALUATOR);   (* 节奏评价 *)
    (module EleganceEvaluator : EVALUATOR); (* 雅致评价 *)
    (module ImageryEvaluator : EVALUATOR);  (* 意象评价 *)
  ]

  (** 评价权重配置 - 体现传统诗学价值观 *)
  let evaluation_weights = [
    (Rhyme, 0.2);        (* 韵律：20% *)
    (Tone, 0.2);         (* 声调：20% *)
    (Parallelism, 0.15); (* 对仗：15% *)
    (Rhythm, 0.15);      (* 节奏：15% *)
    (Elegance, 0.15);    (* 雅致：15% *)
    (Imagery, 0.15);     (* 意象：15% *)
  ]

  (** 执行全维度评价 *)
  let evaluate_all_dimensions context =
    List.map (fun (module E : EVALUATOR) -> E.evaluate context) all_evaluators

  (** 计算加权综合评分 *)
  let calculate_weighted_score results =
    let weight_map = List.fold_left 
      (fun acc (dimension, weight) -> 
        match List.find_opt (fun r -> r.dimension = dimension) results with
        | Some result -> acc +. (result.score *. weight)
        | None -> acc
      ) 0.0 evaluation_weights
    in
    min 1.0 (max 0.0 weight_map)

  (** 生成综合评价报告 *)
  let generate_comprehensive_report context =
    let individual_results = evaluate_all_dimensions context in
    let overall_score = calculate_weighted_score individual_results in
    let suggestions = List.fold_left 
      (fun acc result -> 
        match result.details with 
        | Some detail -> acc @ [detail] 
        | None -> acc) [] individual_results
    in
    {
      overall_score;
      individual_results;
      suggestions;
      evaluation_timestamp = Unix.time ();
      evaluator_version = "unified_v1.0";
    }
end

(** {1 便捷评价接口} *)

(** 快速评价单个诗句 *)
let quick_evaluate_verse verse =
  let context = Context.create_evaluation_context verse in
  UnifiedEvaluator.generate_comprehensive_report context

(** 评价多句诗词 *)
let evaluate_poem verses = 
  List.map quick_evaluate_verse verses

(** 比较两首诗的艺术性 *)
let compare_poems poem1 poem2 =
  let eval1 = evaluate_poem poem1 in
  let eval2 = evaluate_poem poem2 in
  let avg_score poems = 
    let total = List.fold_left (fun acc r -> acc +. r.overall_score) 0.0 poems in
    total /. (float_of_int (List.length poems))
  in
  let score1 = avg_score eval1 in
  let score2 = avg_score eval2 in
  if score1 > score2 then 1
  else if score1 < score2 then -1
  else 0

(** {1 向后兼容性接口} *)

(* 保持原有接口名称 *)
let create_evaluation_context = Context.create_evaluation_context
let get_char_tone = Context.get_char_tone

(** 传统单维度评价接口 *)
let evaluate_rhyme context = RhymeEvaluator.evaluate context
let evaluate_tone context = ToneEvaluator.evaluate context  
let evaluate_parallelism context = ParallelismEvaluator.evaluate context
let evaluate_rhythm context = RhythmEvaluator.evaluate context
let evaluate_elegance context = EleganceEvaluator.evaluate context
let evaluate_imagery context = ImageryEvaluator.evaluate context

(** {1 高级分析功能} *)

(** 艺术性弱点分析结果 *)
type weakness_analysis = Artistic_evaluator_types.evaluation_dimension * float * string list

(** 艺术性发展趋势 *)
type artistic_trend = [ `Improving | `Declining | `Stable | `Insufficient_Data ]

(** 分析诗词的艺术性弱点 *)
let analyze_weaknesses evaluation_report =
  let weak_dimensions = List.filter 
    (fun result -> result.score < 0.6) 
    evaluation_report.individual_results
  in
  List.map (fun result -> 
    (result.dimension, result.score, match result.details with Some d -> [d] | None -> [])
  ) weak_dimensions

(** 生成改进建议 *)
let generate_improvement_suggestions evaluation_report =
  let weaknesses = analyze_weaknesses evaluation_report in
  let general_suggestions = [
    "注重声律配合，提升韵律美感";
    "加强对仗工整，体现形式美";
    "丰富意象选择，增强表达力";
  ] in
  let specific_suggestions = List.fold_left
    (fun acc (_, _, suggestions) -> acc @ suggestions) [] weaknesses
  in
  general_suggestions @ specific_suggestions |> List.sort_uniq String.compare

(** 艺术性趋势分析 - 分析诗人的艺术发展轨迹 *)
let analyze_artistic_trends poem_series =
  let evaluations = List.map evaluate_poem poem_series in
  let trend_data = List.mapi (fun i poems ->
    let avg_score = 
      let total = List.fold_left (fun acc r -> acc +. r.overall_score) 0.0 poems in
      total /. (float_of_int (List.length poems))
    in
    (i, avg_score)
  ) evaluations in
  
  (* 简单线性趋势分析 *)
  let n = List.length trend_data in
  if n < 2 then `Insufficient_Data
  else
    let first_score = snd (List.hd trend_data) in
    let last_score = snd (List.hd (List.rev trend_data)) in
    let improvement = last_score -. first_score in
    if improvement > 0.1 then `Improving
    else if improvement < -0.1 then `Declining  
    else `Stable