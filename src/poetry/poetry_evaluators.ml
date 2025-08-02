(** Poetry_evaluators stub module - Fix Issue #2055
 * 
 * 诗词评价器存根模块，解决编译依赖问题
 * Author: Whisky, PR Worker  
 * Date: 2025-08-02
 *)

module Evaluator_types = struct
  (** 评价维度定义 - 与 artistic_evaluators.mli 保持一致 *)
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

  type artistic_scores = {
    content_depth: float;
    imagery_quality: float;
    emotional_resonance: float;
    language_beauty: float;
  }

  type artistic_report = {
    overall_assessment : string;
    technical_analysis : string;
    artistic_merit : string;
    suggestions : string list;
    score_breakdown : (string * float) list;
  }

  type evaluation_context = {
    verse : string;
    verses : string list;
    form_type : string option;
    rhythm_info : (string * string) list;
    metadata : (string * string) list;
  }

  type engine_state = {
    cache : (string, artistic_evaluation) Hashtbl.t;
    evaluation_count : int;
    start_time : float;
  }
  
  type evaluation_grade = 
    | Excellent | Good | Fair | Poor
end