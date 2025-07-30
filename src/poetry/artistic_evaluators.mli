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

val multi_dimension_evaluation :
  string list -> Poetry_evaluators.Evaluator_types.artistic_evaluation
(** 多维度评价 使用新的模块化架构 *)

val quick_artistic_check : string list -> bool * string list
(** 快速艺术性检查
    @deprecated 建议使用 Unified_artistic_engine.quick_artistic_check 替代 *)

(** {1 新模块化架构API - 向前兼容层} *)

(** 重新导出评价维度类型以便测试使用 *)
type evaluation_dimension = Poetry_evaluators.Evaluator_types.evaluation_dimension =
  | RhymeHarmony
  | TonalBalance
  | MetricalForm
  | Parallelism
  | Imagery
  | Rhythm
  | Elegance
  | ContentDepth
  | FormBeauty
  | SoundHarmony
  | ContextMood
  | EmotionExpression
  | Innovation
  | Overall

type dimension_score = Poetry_evaluators.Evaluator_types.dimension_score = {
  dimension : evaluation_dimension;
  score : float;
  max_possible : float;
  confidence : float;
  details : string option;
  suggestions : string list;
}
(** 重新导出关键记录类型 *)

type artistic_evaluation = Poetry_evaluators.Evaluator_types.artistic_evaluation = {
  overall_score : float;
  dimension_scores : dimension_score list;
  strengths : string list;
  weaknesses : string list;
  improvement_suggestions : string list;
  artistic_level : [ `Beginner | `Intermediate | `Advanced | `Master ];
  quality_grade : [ `Excellent | `Good | `Fair | `Poor ];
  evaluation_metadata : (string * string) list;
}

type mood_analysis = Poetry_evaluators.Evaluator_types.mood_analysis = {
  primary_mood : string;
  secondary_moods : string list;
  mood_intensity : float;
  mood_coherence : float;
  mood_techniques : string list;
}

type rhetoric_analysis = Poetry_evaluators.Evaluator_types.rhetoric_analysis = {
  detected_techniques : string list;
  technique_examples : (string * string) list;
  rhetoric_richness : float;
  technique_effectiveness : (string * float) list;
}

type evaluation_context = Poetry_evaluators.Evaluator_types.evaluation_context = {
  verse : string;
  verses : string list;
  form_type : string option;
  rhythm_info : (string * string) list;
  metadata : (string * string) list;
}

type engine_state = Poetry_evaluators.Evaluator_types.engine_state = {
  cache : (string, artistic_evaluation) Hashtbl.t;
  evaluation_count : int;
  start_time : float;
}

val initialize_engine : unit -> engine_state
(** 引擎状态管理 *)

val clear_engine_cache : engine_state -> engine_state
val get_engine_statistics : engine_state -> (string * string) list
val create_evaluation_context : string -> string list -> evaluation_context

val comprehensive_artistic_evaluation : string list -> engine_state -> artistic_evaluation
(** 核心评价功能 *)

val evaluate_single_dimension :
  evaluation_dimension -> evaluation_context -> engine_state -> dimension_score option

val analyze_mood_creation : string list -> engine_state -> mood_analysis
(** 专项分析功能 *)

val detect_rhetoric_techniques : string list -> engine_state -> rhetoric_analysis
val analyze_form_beauty : string list -> engine_state -> float * string list
val analyze_content_depth : string list -> engine_state -> float * string list
val analyze_sound_harmony : string list -> engine_state -> float * string list

val generate_improvement_guidance : artistic_evaluation -> engine_state -> string list
(** 艺术指导功能 *)

val suggest_artistic_enhancements : string list -> engine_state -> string list

val format_evaluation_result : artistic_evaluation -> string
(** 结果格式化功能 *)

val export_evaluation_json : artistic_evaluation -> string

exception ArtisticEngineError of string
(** 异常类型 *)

val evaluate_poem_artistic : string list -> float
(** 额外兼容性函数 *)

val evaluate_siyan_parallel_prose : string array -> artistic_evaluation
val evaluate_wuyan_lushi : string array -> artistic_evaluation
val evaluate_qiyan_jueju : string array -> artistic_evaluation
val evaluate_poetry_by_form : string -> string array -> artistic_evaluation
