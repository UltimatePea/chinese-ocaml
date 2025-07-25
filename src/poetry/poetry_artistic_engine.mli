(** 诗词艺术性分析引擎 - 整合版本接口
 *
 * 此模块整合了原本分散在26个艺术性分析模块中的功能，提供统一的艺术性评价接口。
 *
 * 整合的原始模块包括：
 * - artistic_evaluation, artistic_evaluator_*, artistic_guidance
 * - artistic_types, artistic_soul_evaluation, evaluation_framework
 * - form_evaluators, parallelism_analysis 等
 *
 * @author 骆言编程团队 - 模块整合项目
 * @version 2.0 (整合版本)
 * @since 2025-07-25
 * @issue #1155 诗词模块整合优化
 *)

(** {1 核心类型定义} *)

(** 艺术性评价维度 *)
type artistic_dimension = 
  | Content          (** 内容深度：思想内容的丰富性和深度 *)
  | Form            (** 形式美感：结构、对仗等形式要素 *)
  | Sound           (** 音韵和谐：韵律、音调的和谐程度 *)
  | Context         (** 意境营造：意象、氛围的营造能力 *)
  | Emotion         (** 情感表达：情感传达的强度和真实性 *)
  | Innovation      (** 创新性：修辞手法和表达方式的创新 *)

(** 艺术性评价结果 *)
type artistic_evaluation = {
  overall_score: float;                    (** 总体分数 0.0-1.0 *)
  dimension_scores: (artistic_dimension * float) list; (** 各维度分数 *)
  strengths: string list;                  (** 优点列表 *)
  weaknesses: string list;                 (** 不足列表 *)
  improvement_suggestions: string list;    (** 改进建议 *)
  artistic_level: [`Beginner | `Intermediate | `Advanced | `Master]; (** 艺术水平等级 *)
}

(** 意境分析结果 *)
type mood_analysis = {
  primary_mood: string;        (** 主要意境类型 *)
  secondary_moods: string list; (** 次要意境元素 *)
  mood_intensity: float;       (** 意境强度 0.0-1.0 *)
  mood_coherence: float;       (** 意境连贯性 0.0-1.0 *)
}

(** 修辞手法检测结果 *)
type rhetoric_analysis = {
  detected_techniques: string list; (** 检测到的修辞手法列表 *)
  technique_examples: (string * string) list; (** 修辞手法及其具体例子 *)
  rhetoric_richness: float;    (** 修辞丰富度 0.0-1.0 *)
}

(** {1 核心艺术性分析功能} *)

(** 分析诗词内容深度
 * 
 * 整合了原 artistic_evaluator_content.ml 的功能
 * 
 * @param lines 诗句列表
 * @return (内容深度分数, 具体建议列表)
 * @example analyze_content_depth ["春眠不觉晓"] = (0.6, ["建议增加内容复杂性"])
 *)
val analyze_content_depth : string list -> float * string list

(** 分析诗词形式美感
 * 
 * 整合了原 artistic_evaluator_form.ml 的功能
 * 
 * @param lines 诗句列表
 * @return (形式美感分数, 具体建议列表)
 * @example analyze_form_beauty poem = (0.8, ["诗歌形式整齐"])
 *)
val analyze_form_beauty : string list -> float * string list

(** 分析音韵和谐度
 * 
 * 整合了原 artistic_evaluator_sound.ml 的功能
 * 
 * @param lines 诗句列表
 * @return (音韵和谐分数, 具体建议列表)
 * @example analyze_sound_harmony poem = (0.7, ["韵律和谐"])
 *)
val analyze_sound_harmony : string list -> float * string list

(** 分析意境营造
 * 
 * 整合了原 artistic_evaluator_context.ml 的功能
 * 
 * @param lines 诗句列表
 * @return 意境分析结果
 * @example analyze_mood_creation poem = {primary_mood="自然写意"; ...}
 *)
val analyze_mood_creation : string list -> mood_analysis

(** 检测修辞手法
 * 
 * 整合了原 artistic_soul_evaluation.ml 的部分功能
 * 
 * @param lines 诗句列表
 * @return 修辞手法分析结果
 * @example detect_rhetoric_techniques poem = {detected_techniques=["对仗"]; ...}
 *)
val detect_rhetoric_techniques : string list -> rhetoric_analysis

(** {1 综合艺术性评价功能} *)

(** 综合评价诗词艺术性
 * 
 * 整合了原 artistic_evaluation.ml 和 artistic_evaluator_comprehensive.ml 的功能
 * 提供全面的多维度艺术性分析
 * 
 * @param lines 诗句列表
 * @return 完整的艺术性评价结果
 * @example comprehensive_artistic_evaluation poem = {overall_score=0.75; artistic_level=`Advanced; ...}
 *)
val comprehensive_artistic_evaluation : string list -> artistic_evaluation

(** {1 艺术指导功能} *)

(** 生成个性化的艺术改进建议
 * 
 * 整合了原 artistic_guidance.ml 的功能
 * 根据评价结果生成针对性的改进指导
 * 
 * @param evaluation 艺术性评价结果
 * @return 个性化改进建议列表
 * @example generate_improvement_guidance eval_result = ["加强韵律"; "提升意境"]
 *)
val generate_improvement_guidance : artistic_evaluation -> string list

(** {1 向后兼容接口} *)

(** 兼容原 artistic_evaluation.ml 的评价函数
 * @deprecated 建议使用 comprehensive_artistic_evaluation 替代
 *)
val evaluate_poem_artistic : string list -> float

(** 兼容原 evaluation_framework.ml 的框架函数
 * @deprecated 建议使用 comprehensive_artistic_evaluation 替代
 *)
val quick_artistic_check : string list -> bool * string list

(** 兼容原 artistic_evaluators.ml 的多维度评价
 * @deprecated 建议使用 comprehensive_artistic_evaluation 替代
 *)
val multi_dimension_evaluation : string list -> artistic_evaluation