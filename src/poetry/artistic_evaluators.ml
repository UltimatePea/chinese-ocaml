(* 诗词艺术性评价器模块 - 兼容性层 (模块化重构版)
   
   此模块现在提供基本的兼容性实现，等待完全迁移到新的模块化架构。
   原有功能通过 src/poetry/evaluators/ 中的专门化模块提供。
   
   @compatibility_layer_for modularized evaluators architecture
   @author Alpha, 主要工作代理 - 模块化重构完成
   @version 3.0 (模块化重构版本)
   @since 2025-07-30
   @fix_issue #1770 完成统一艺术引擎模块化重构
*)

(** 评价韵律和谐度：检查诗句的音韵是否和谐
    @param verse 待评价的诗句
    @return 韵律和谐度分数 (0.0-1.0)
    使用新的模块化架构 *)
let evaluate_rhyme_harmony verse = 
  let open Poetry_evaluators.Artistic_evaluation_engine in
  let evaluation = evaluate_single_verse verse in
  (* 从维度评分中提取韵律和谐度分数 *)
  match List.find_opt (fun score -> 
    score.Poetry_evaluators.Evaluator_types.dimension = Poetry_evaluators.Evaluator_types.RhymeHarmony
  ) evaluation.dimension_scores with
  | Some score -> score.score
  | None -> 0.5 (* 默认分数如果未找到对应评价器 *)

(** 评价声调平衡度：检查平仄搭配是否合理
    @param verse 待评价的诗句
    @param expected_pattern 期望的平仄模式
    @return 声调平衡度分数 (0.0-1.0)
    使用新的模块化架构 *)
let evaluate_tonal_balance verse _expected_pattern =
  let open Poetry_evaluators.Artistic_evaluation_engine in
  let evaluation = evaluate_single_verse verse in
  (* 从维度评分中提取声调平衡度分数 *)
  match List.find_opt (fun score -> 
    score.Poetry_evaluators.Evaluator_types.dimension = Poetry_evaluators.Evaluator_types.TonalBalance
  ) evaluation.dimension_scores with
  | Some score -> score.score
  | None -> 0.5

(** 评价对仗工整度：检查对仗的工整程度
    @param left_verse 左联
    @param right_verse 右联
    @return 对仗工整度分数 (0.0-1.0)
    使用新的模块化架构 *)
let evaluate_parallelism left_verse right_verse =
  let open Poetry_evaluators.Artistic_evaluation_engine in
  let evaluation = evaluate_multiple_verses [left_verse; right_verse] in
  (* 从维度评分中提取对仗工整度分数 *)
  match List.find_opt (fun score -> 
    score.Poetry_evaluators.Evaluator_types.dimension = Poetry_evaluators.Evaluator_types.Parallelism
  ) evaluation.dimension_scores with
  | Some score -> score.score
  | None -> 0.5

(** 评价意象深度：通过关键词分析评价意象的深度
    @param verse 待评价的诗句
    @return 意象深度分数 (0.0-1.0)
    使用新的模块化架构 *)
let evaluate_imagery verse = 
  let open Poetry_evaluators.Artistic_evaluation_engine in
  let evaluation = evaluate_single_verse verse in
  (* 从维度评分中提取意象深度分数 *)
  match List.find_opt (fun score -> 
    score.Poetry_evaluators.Evaluator_types.dimension = Poetry_evaluators.Evaluator_types.Imagery
  ) evaluation.dimension_scores with
  | Some score -> score.score
  | None -> 0.5

(** 评价节奏感：基于字数和声调变化评价节奏
    @param verse 待评价的诗句
    @return 节奏感分数 (0.0-1.0)
    使用新的模块化架构 *)
let evaluate_rhythm verse = 
  let open Poetry_evaluators.Artistic_evaluation_engine in
  let evaluation = evaluate_single_verse verse in
  (* 从维度评分中提取节奏感分数 *)
  match List.find_opt (fun score -> 
    score.Poetry_evaluators.Evaluator_types.dimension = Poetry_evaluators.Evaluator_types.Rhythm
  ) evaluation.dimension_scores with
  | Some score -> score.score
  | None -> 0.5

(** 评价雅致程度：基于用词和意境的雅致程度
    @param verse 待评价的诗句
    @return 雅致程度分数 (0.0-1.0)
    使用新的模块化架构 *)
let evaluate_elegance verse = 
  let open Poetry_evaluators.Artistic_evaluation_engine in
  let evaluation = evaluate_single_verse verse in
  (* 从维度评分中提取雅致程度分数 *)
  match List.find_opt (fun score -> 
    score.Poetry_evaluators.Evaluator_types.dimension = Poetry_evaluators.Evaluator_types.Elegance
  ) evaluation.dimension_scores with
  | Some score -> score.score
  | None -> 0.5

type evaluation_scores = {
  rhyme_harmony : float;
  tonal_balance : float;
  parallelism : float;
  imagery : float;
  rhythm : float;
  elegance : float;
}
(** 兼容性类型定义：评价分数记录 *)

(** 确定整体评级：根据各项得分确定整体等级
    @param scores 各项评价分数
    @return 整体评级 *)
let determine_overall_grade scores =
  (* 基于各项评分计算整体等级，保持与接口定义一致 *)
  let avg_score =
    (scores.rhyme_harmony +. scores.tonal_balance +. scores.parallelism +. scores.imagery
   +. scores.rhythm +. scores.elegance)
    /. 6.0
  in
  if avg_score >= 0.85 then `Excellent
  else if avg_score >= 0.70 then `Good
  else if avg_score >= 0.55 then `Fair
  else `Poor

(** 多维度评价：提供完整的艺术性评价
    @param verses 诗句列表
    @return 艺术性评价结果
    使用新的模块化架构 *)
let multi_dimension_evaluation verses = 
  (* 直接调用新的模块化评价引擎 *)
  let open Poetry_evaluators.Artistic_evaluation_engine in
  evaluate_multiple_verses verses

(** 快速艺术性检查：提供快速的艺术性判断
    @param verses 诗句列表
    @return (是否合格, 建议列表)
    使用新的模块化架构 *)
let quick_artistic_check verses = 
  let open Poetry_evaluators.Artistic_evaluation_engine in
  let evaluation = evaluate_multiple_verses verses in
  let is_qualified = evaluation.overall_score >= 0.6 in
  let suggestions = evaluation.improvement_suggestions in
  (is_qualified, suggestions)

(** 模块化重构完成提示 *)
let () =
  if false then (* 防止在正常使用中打印 *)
    Printf.eprintf "[INFO] artistic_evaluators.ml 已更新为调用新的模块化架构\n%!"