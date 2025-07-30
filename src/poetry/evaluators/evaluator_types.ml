(** 艺术评价器类型定义模块
 *
 * 从 unified_artistic_engine.ml 中提取的核心类型定义，
 * 实现类型的统一管理和模块间的清晰依赖关系。
 *
 * @author Charlie, 战略规划专员 - 架构债务重构专项
 * @version 1.0 - 模块化重构版本  
 * @since 2025-07-30
 * @fix_issue #1767 统一模块增殖架构债务
 *)

(** {1 评价维度定义} *)

type evaluation_dimension =
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

(** {1 评价结果类型} *)

type dimension_score = {
  dimension : evaluation_dimension;
  score : float;
  max_possible : float;
  confidence : float;
  details : string option;
  suggestions : string list;
}

type artistic_evaluation = {
  overall_score : float;
  dimension_scores : dimension_score list;
  strengths : string list;
  weaknesses : string list;
  improvement_suggestions : string list;
  artistic_level : [ `Beginner | `Intermediate | `Advanced | `Master ];
  quality_grade : [ `Excellent | `Good | `Fair | `Poor ];
  evaluation_metadata : (string * string) list;
}

type mood_analysis = {
  primary_mood : string;
  secondary_moods : string list;
  mood_intensity : float;
  mood_coherence : float;
  mood_techniques : string list;
}

type rhetoric_analysis = {
  detected_techniques : string list;
  technique_examples : (string * string) list;
  rhetoric_richness : float;
  technique_effectiveness : (string * float) list;
}

type evaluation_context = {
  verse : string;
  verses : string list;
  form_type : string option;
  rhythm_info : (string * string) list;
  metadata : (string * string) list;
}

(** {1 评价器接口定义} *)

type engine_state = {
  cache : (string, artistic_evaluation) Hashtbl.t;
  evaluation_count : int;
  start_time : float;
}

exception ArtisticEngineError of string

module type EVALUATOR = sig
  val dimension : evaluation_dimension
  val name : string
  val description : string
  val weight : float
  val evaluate : evaluation_context -> dimension_score
  val is_applicable : evaluation_context -> bool
  val required_context : string list
end
