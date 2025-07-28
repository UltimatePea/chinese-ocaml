(** 统一艺术性评价器模块接口
    
    整合所有艺术性评价功能的统一接口。
    提供全面的诗词艺术性评价能力，消除原有模块间的功能重复。
    
    Author: Beta, 代码审查代理
    版本: 统一重构版 v1.0 *)

(** {1 核心评价器模块} *)

(** 声律层面评价器 *)
module RhymeEvaluator : Artistic_evaluator_types.EVALUATOR
module ToneEvaluator : Artistic_evaluator_types.EVALUATOR

(** 形式层面评价器 *)
module ParallelismEvaluator : Artistic_evaluator_types.EVALUATOR
module RhythmEvaluator : Artistic_evaluator_types.EVALUATOR
module EleganceEvaluator : Artistic_evaluator_types.EVALUATOR

(** 内容层面评价器 *)
module ImageryEvaluator : Artistic_evaluator_types.EVALUATOR

(** {1 统一综合评价器} *)

(** 综合评价报告类型 *)
type comprehensive_report = {
  overall_score : float;
  individual_results : Artistic_evaluator_types.evaluation_result list;
  suggestions : string list;
  evaluation_timestamp : float;
  evaluator_version : string;
}

module UnifiedEvaluator : sig
  (** 执行全维度评价 *)
  val evaluate_all_dimensions : Artistic_evaluator_types.evaluation_context -> Artistic_evaluator_types.evaluation_result list

  (** 计算加权综合评分 *)
  val calculate_weighted_score : Artistic_evaluator_types.evaluation_result list -> float

  (** 生成综合评价报告 *)
  val generate_comprehensive_report : Artistic_evaluator_types.evaluation_context -> comprehensive_report
end

(** {1 便捷评价接口} *)

(** 快速评价单个诗句 *)
val quick_evaluate_verse : string -> comprehensive_report

(** 评价多句诗词 *)
val evaluate_poem : string list -> comprehensive_report list

(** 比较两首诗的艺术性
    @return 1 如果第一首更优，-1 如果第二首更优，0 如果相当 *)
val compare_poems : string list -> string list -> int

(** {1 向后兼容性接口} *)

(** 创建评价上下文 *)
val create_evaluation_context : string -> Artistic_evaluator_types.evaluation_context

(** 获取字符声调 *)
val get_char_tone : char -> Tone_data.tone_type

(** 传统单维度评价接口 *)
val evaluate_rhyme : Artistic_evaluator_types.evaluation_context -> Artistic_evaluator_types.evaluation_result
val evaluate_tone : Artistic_evaluator_types.evaluation_context -> Artistic_evaluator_types.evaluation_result
val evaluate_parallelism : Artistic_evaluator_types.evaluation_context -> Artistic_evaluator_types.evaluation_result
val evaluate_rhythm : Artistic_evaluator_types.evaluation_context -> Artistic_evaluator_types.evaluation_result
val evaluate_elegance : Artistic_evaluator_types.evaluation_context -> Artistic_evaluator_types.evaluation_result
val evaluate_imagery : Artistic_evaluator_types.evaluation_context -> Artistic_evaluator_types.evaluation_result

(** {1 高级分析功能} *)

(** 艺术性弱点分析结果 *)
type weakness_analysis = Artistic_evaluator_types.evaluation_dimension * float * string list

(** 分析诗词的艺术性弱点 *)
val analyze_weaknesses : comprehensive_report -> weakness_analysis list

(** 生成改进建议 *)
val generate_improvement_suggestions : comprehensive_report -> string list

(** 艺术性发展趋势 *)
type artistic_trend = [ `Improving | `Declining | `Stable | `Insufficient_Data ]

(** 艺术性趋势分析 - 分析诗人的艺术发展轨迹 *)
val analyze_artistic_trends : string list list -> artistic_trend