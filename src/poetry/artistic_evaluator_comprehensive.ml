(* 诗词综合评价器模块 - 协调各个子评价器
   
   整合所有评价维度，提供统一的评价接口。
   承"诗有六义"之传统，综观各维度，得诗词之全貌。 *)

open Artistic_evaluator_types
open Artistic_evaluator_sound
open Artistic_evaluator_form
open Artistic_evaluator_content

(* 综合评价器 - 协调各个子评价器，提供完整评价体系 *)
module ComprehensiveEvaluator = struct
  (* 所有评价器的集合 - 涵盖诗词评价的六大维度
     按照传统诗学理论，从声律、形式、内容三个层面
     全面评估诗词的艺术价值 *)
  let evaluators =
    [
      (module RhymeEvaluator : EVALUATOR);
      (* 韵律 - 声律层面 *)
      (module ToneEvaluator : EVALUATOR);
      (* 声调 - 声律层面 *)
      (module ParallelismEvaluator : EVALUATOR);
      (* 对仗 - 形式层面 *)
      (module ImageryEvaluator : EVALUATOR);
      (* 意象 - 内容层面 *)
      (module RhythmEvaluator : EVALUATOR);
      (* 节奏 - 形式层面 *)
      (module EleganceEvaluator : EVALUATOR);
      (* 雅致 - 形式层面 *)
    ]

  (* 执行全维度评价 - 返回各维度的详细评价结果
     
     此函数遍历所有评价器，对同一诗句进行多维度分析，
     返回完整的评价报告。古云"诗有六义"，此正是其现代实现。 *)
  let evaluate_all context = List.map (fun (module E : EVALUATOR) -> E.evaluate context) evaluators

  (* 计算综合评分 - 各维度加权平均
     
     将各维度评分按一定权重计算综合分数：
     声律层面（韵律+声调）：40%
     形式层面（对仗+节奏+雅致）：40% 
     内容层面（意象）：20%
     
     权重设置体现传统诗学中声律为重的美学观念。 *)
  let calculate_overall_score results =
    let weights =
      [
        (Rhyme, 0.15);
        (* 韵律：15% *)
        (Tone, 0.25);
        (* 声调：25% - 格律之根本 *)
        (Parallelism, 0.15);
        (* 对仗：15% *)
        (Imagery, 0.20);
        (* 意象：20% - 诗之魂魄 *)
        (Rhythm, 0.15);
        (* 节奏：15% *)
        (Elegance, 0.10);
        (* 雅致：10% *)
      ]
    in

    let weighted_sum =
      List.fold_left2
        (fun acc result (_, weight) -> acc +. (result.score *. weight))
        0.0 results weights
    in
    weighted_sum

  (* 生成评价报告 - 提供人性化的评价说明 *)
  let generate_report context results =
    let overall_score = calculate_overall_score results in
    let grade =
      if overall_score >= 0.8 then "上品" else if overall_score >= 0.6 then "中品" else "下品"
    in

    let title =
      String.sub
        (Artistic_evaluator_context.get_verse context)
        0
        (min 10 (String.length (Artistic_evaluator_context.get_verse context)))
    in
    let details =
      String.concat "\n"
        (List.map
           (fun result ->
             let dim_name =
               match result.dimension with
               | Rhyme -> "韵律"
               | Tone -> "声调"
               | Parallelism -> "对仗"
               | Imagery -> "意象"
               | Rhythm -> "节奏"
               | Elegance -> "雅致"
             in
             Yyocamlc_lib.Unified_formatter.PoetryFormatting.format_dimension_score dim_name
               result.score)
           results)
    in
    Yyocamlc_lib.Unified_formatter.PoetryFormatting.format_evaluation_detailed_report title grade
      overall_score details
end
