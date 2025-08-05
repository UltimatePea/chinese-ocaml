(** 诗词艺术评估引擎统一模块接口 - Issue #2000 整合实施
 *
 * 此文件提供诗词艺术评估的统一接口，整合了多个分散的艺术评估模块。
 *
 * @consolidation_issue #2000  
 * @author Whisky, PR Worker
 *)

(** {1 核心艺术性分析类型} *)

(** 艺术性评价维度 *)
type artistic_dimension =
  | Content  (** 内容深度 *)
  | Form  (** 形式美感 *)
  | Sound  (** 音韵和谐 *)
  | Context  (** 意境营造 *)
  | Emotion  (** 情感表达 *)
  | Innovation  (** 创新性 *)

type artistic_evaluation = {
  overall_score : float;  (** 总体分数 0.0-1.0 *)
  dimension_scores : (artistic_dimension * float) list;  (** 各维度分数 *)
  strengths : string list;  (** 优点列表 *)
  weaknesses : string list;  (** 不足列表 *)
  improvement_suggestions : string list;  (** 改进建议 *)
  artistic_level : [ `Beginner | `Intermediate | `Advanced | `Master ];  (** 艺术水平 *)
}
(** 艺术性评价结果 *)

type mood_analysis = {
  primary_mood : string;  (** 主要意境 *)
  secondary_moods : string list;  (** 次要意境 *)
  mood_intensity : float;  (** 意境强度 *)
  mood_coherence : float;  (** 意境连贯性 *)
}
(** 意境分析结果 *)

type rhetoric_analysis = {
  detected_techniques : string list;  (** 检测到的修辞手法 *)
  technique_examples : (string * string) list;  (** 手法及其例子 *)
  rhetoric_richness : float;  (** 修辞丰富度 *)
}
(** 修辞手法检测结果 *)

type evaluation_dimension =
  | RhymeHarmony
  | TonalBalance
  | Parallelism
  | ImageryDepth
  | FormBeauty
  | ContentDepth
  | MoodContext

type 'a query_result = Found of 'a | NotFound | Error of string

(** {1 评价标准管理} *)

val get_standard_weights : unit -> (evaluation_dimension * float) list query_result
(** 获取标准评价权重 *)

val validate_evaluation_criteria : evaluation_dimension -> string -> bool query_result
(** 验证评价标准 *)

(** {1 艺术性评分计算} *)

val calculate_artistic_score : string -> (evaluation_dimension * float) list query_result
(** 计算艺术性分数 *)

(** {1 单维度艺术性评价函数} *)

val evaluate_rhyme_harmony : string -> float
(** 评价韵律和谐度：检查诗句的音韵是否和谐 *)

val evaluate_tonal_balance : string -> string -> float
(** 评价声调平衡度：检查平仄搭配是否合理 *)

val evaluate_parallelism : string -> string -> float
(** 评价对仗工整度：检查对仗的工整程度 *)

val evaluate_imagery : string -> float
(** 评价意象深度：分析诗句中意象的丰富程度和深度 *)

val evaluate_rhythm : string -> float
(** 评价节奏韵律：分析诗句的节奏感 *)

val evaluate_elegance : string -> float
(** 评价雅致程度：评估用词的雅致和文学价值 *)

(** {1 综合艺术性评价函数} *)

val comprehensive_artistic_evaluation : string -> artistic_evaluation
(** 综合艺术性评价：对诗词进行全面的艺术性评估 *)

val determine_overall_grade : artistic_evaluation -> string
(** 确定整体评级：根据评价结果确定诗词的艺术等级 *)

(** {1 诗词形式专项评价函数} *)

val evaluate_siyan_parallel_prose : string -> float
(** 评价四言骈文 *)

val evaluate_wuyan_lushi : string -> float
(** 评价五言律诗 *)

val evaluate_qiyan_jueju : string -> float
(** 评价七言绝句 *)

val evaluate_poetry_by_form : string -> string -> float
(** 根据诗词形式进行专项评价 *)

(** {1 分析和指导功能} *)

val generate_improvement_suggestions : artistic_evaluation -> string list
(** 生成改进建议：基于评价结果生成具体的改进建议 *)

val analyze_mood : string -> mood_analysis
(** 意境分析 *)

val analyze_rhetoric : string -> rhetoric_analysis
(** 修辞分析 *)

val provide_artistic_guidance : string -> artistic_evaluation -> string list
(** 艺术指导建议 *)

val evaluate_poetic_soul : string -> float
(** 诗魂评估：评估诗词的精神内核和文化底蕴 *)

(** {1 查询接口} *)

val query_artistic_elements : string -> string -> string query_result
(** 艺术性查询 *)

val standard_artistic_evaluation :
  string -> artistic_evaluation * mood_analysis * rhetoric_analysis * float
(** 标准艺术评价接口 *)
