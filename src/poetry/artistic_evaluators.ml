(* 诗词艺术性评价器模块 - 兼容性层 (Phase 2.3.1)
   
   此模块已转换为unified_artistic_engine的兼容性层。
   原有功能现在通过统一艺术评价引擎提供，保持向后兼容。
   
   @deprecated 建议迁移到 Unified_artistic_engine 模块
   @compatibility_layer_for unified_artistic_engine.ml
   @author Alpha, 主要工作代理 - Phase 2.3.1 兼容性层实现
   @version 2.3.1 (兼容性层版本)
   @since 2025-07-30
*)

(* 兼容性导入：根据需要导入类型 *)

(* 兼容性层：重导出统一引擎功能 *)

(** 评价韵律和谐度：检查诗句的音韵是否和谐
    @param verse 待评价的诗句
    @return 韵律和谐度分数 (0.0-1.0)
    @deprecated 建议使用 Unified_artistic_engine.evaluate_rhyme_harmony 替代 *)
let evaluate_rhyme_harmony verse = Unified_artistic_engine.evaluate_rhyme_harmony verse

(** 评价声调平衡度：检查平仄搭配是否合理
    @param verse 待评价的诗句
    @param expected_pattern 期望的平仄模式
    @return 声调平衡度分数 (0.0-1.0)
    @deprecated 建议使用 Unified_artistic_engine.evaluate_tonal_balance 替代 *)
let evaluate_tonal_balance verse expected_pattern =
  Unified_artistic_engine.evaluate_tonal_balance verse expected_pattern

(** 评价对仗工整度：检查对仗的工整程度
    @param left_verse 左联
    @param right_verse 右联
    @return 对仗工整度分数 (0.0-1.0)
    @deprecated 建议使用 Unified_artistic_engine.evaluate_parallelism 替代 *)
let evaluate_parallelism left_verse right_verse =
  Unified_artistic_engine.evaluate_parallelism left_verse right_verse

(** 评价意象深度：通过关键词分析评价意象的深度
    @param verse 待评价的诗句
    @return 意象深度分数 (0.0-1.0)
    @deprecated 建议使用 Unified_artistic_engine.evaluate_imagery 替代 *)
let evaluate_imagery verse = Unified_artistic_engine.evaluate_imagery verse

(** 评价节奏感：基于字数和声调变化评价节奏
    @param verse 待评价的诗句
    @return 节奏感分数 (0.0-1.0)
    @deprecated 建议使用 Unified_artistic_engine.evaluate_rhythm 替代 *)
let evaluate_rhythm verse = Unified_artistic_engine.evaluate_rhythm verse

(** 评价雅致程度：基于用词和意境的雅致程度
    @param verse 待评价的诗句
    @return 雅致程度分数 (0.0-1.0)
    @deprecated 建议使用 Unified_artistic_engine.evaluate_elegance 替代 *)
let evaluate_elegance verse = Unified_artistic_engine.evaluate_elegance verse

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
    @return 整体评级
    @deprecated 建议使用 Unified_artistic_engine.determine_overall_grade 替代 *)
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
    @deprecated 建议使用 Unified_artistic_engine.multi_dimension_evaluation 替代 *)
let multi_dimension_evaluation verses = Unified_artistic_engine.multi_dimension_evaluation verses

(** 快速艺术性检查：提供快速的艺术性判断
    @param verses 诗句列表
    @return (是否合格, 建议列表)
    @deprecated 建议使用 Unified_artistic_engine.quick_artistic_check 替代 *)
let quick_artistic_check verses = Unified_artistic_engine.quick_artistic_check verses

(** 兼容性提示：建议用户迁移到新的统一引擎 *)
let () =
  if false then (* 防止在正常使用中打印 *)
    Printf.eprintf "[DEPRECATED] artistic_evaluators.ml 已转为兼容性层，建议迁移至 Unified_artistic_engine\n%!"
