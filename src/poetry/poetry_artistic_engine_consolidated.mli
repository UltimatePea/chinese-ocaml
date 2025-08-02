(** Poetry Artistic Engine Consolidated Module Interface - Issue #1999
 * 
 * 诗词艺术性评价引擎统一模块接口
 * Author: Whisky, PR Worker
 *)

open Poetry_core_consolidated

(** {1 艺术性评价类型定义} *)

type artistic_dimension = 
  | ContentDepth
  | FormBeauty
  | ImageryVividness
  | MoodContext
  | ParallelismQuality
  | RhymeHarmony
  | TonalBalance

type artistic_analysis = {
  dimension: artistic_dimension;
  score: float;
  details: string;
  suggestions: string list;
}

type comprehensive_artistic_evaluation = {
  overall_score: float;
  dimension_scores: (evaluation_dimension * float) list;
  detailed_analysis: artistic_analysis list;
  artistic_highlights: string list;
  improvement_areas: string list;
}

type imagery_type = 
  | Natural
  | Human
  | Emotional
  | Historical
  | Seasonal

type imagery_element = {
  element_type: imagery_type;
  keywords: string list;
  emotional_tone: float;
  frequency: int;
}

(** {1 意象分析引擎} *)

(** 检测诗句中的意象元素 *)
val detect_imagery_elements : string -> imagery_element list

(** 分析诗词整体意象 *)
val analyze_poem_imagery : string list -> imagery_element list

(** {1 艺术性分析引擎} *)

(** 内容深度评价 *)
val evaluate_content_depth : string list -> artistic_analysis

(** 形式美感评价 *)
val evaluate_form_beauty : string list -> artistic_analysis

(** 意象生动性评价 *)
val evaluate_imagery_vividness : string list -> artistic_analysis

(** 意境氛围评价 *)
val evaluate_mood_context : string list -> artistic_analysis

(** {1 综合艺术性评价引擎} *)

(** 综合诗词艺术性评价 *)
val comprehensive_artistic_evaluation : string list -> comprehensive_artistic_evaluation

(** 生成改进指导建议 *)
val generate_improvement_guidance : comprehensive_artistic_evaluation -> string list

(** {1 兼容性函数} *)

(** 兼容旧的艺术性评价接口 *)
val evaluate_poem_artistic_compat : string list -> evaluation_result

(** 简化的艺术性评分 *)
val quick_artistic_score : string list -> float