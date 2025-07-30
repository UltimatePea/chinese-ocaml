(* 诗词艺术性评价器模块接口 - 兼容性层 (Phase 2.3.1)
   
   此模块已转换为unified_artistic_engine的兼容性层。
   原有功能现在通过统一艺术评价引擎提供，保持向后兼容。
   
   @deprecated 建议迁移到 Unified_artistic_engine 模块
   @compatibility_layer_for unified_artistic_engine.ml
   @author Alpha, 主要工作代理 - Phase 2.3.1 兼容性层接口
   @version 2.3.1 (兼容性层版本)
   @since 2025-07-30
*)

val evaluate_rhyme_harmony : string -> float
(** 评价韵律和谐度
    @deprecated 建议使用 Unified_artistic_engine.evaluate_rhyme_harmony 替代 *)

val evaluate_tonal_balance : string -> bool list option -> float
(** 评价声调平衡度
    @deprecated 建议使用 Unified_artistic_engine.evaluate_tonal_balance 替代 *)

val evaluate_parallelism : string -> string -> float
(** 评价对仗工整度
    @deprecated 建议使用 Unified_artistic_engine.evaluate_parallelism 替代 *)

val evaluate_imagery : string -> float
(** 评价意象深度
    @deprecated 建议使用 Unified_artistic_engine.evaluate_imagery 替代 *)

val evaluate_rhythm : string -> float
(** 评价节奏感
    @deprecated 建议使用 Unified_artistic_engine.evaluate_rhythm 替代 *)

val evaluate_elegance : string -> float
(** 评价雅致程度
    @deprecated 建议使用 Unified_artistic_engine.evaluate_elegance 替代 *)

(* 兼容性类型定义 *)
type evaluation_scores = {
  rhyme_harmony : float;
  tonal_balance : float;
  parallelism : float;
  imagery : float;
  rhythm : float;
  elegance : float;
}

val determine_overall_grade : evaluation_scores -> [ `Excellent | `Fair | `Good | `Poor ]
(** 确定整体评级
    @deprecated 建议使用 Unified_artistic_engine.determine_overall_grade 替代 *)

val multi_dimension_evaluation : string list -> Poetry_evaluators.Evaluator_types.artistic_evaluation
(** 多维度评价
    使用新的模块化架构 *)

val quick_artistic_check : string list -> bool * string list
(** 快速艺术性检查
    @deprecated 建议使用 Unified_artistic_engine.quick_artistic_check 替代 *)
