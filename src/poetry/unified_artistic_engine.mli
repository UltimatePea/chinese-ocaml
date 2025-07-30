(** 统一艺术评价引擎 - Phase 2.3.1 核心整合
 *
 * 此模块整合了原本分散在31个艺术评价模块中的功能，建立统一的艺术性评价体系。
 * 结合了poetry_artistic_engine.mli的综合功能和analysis/artistic_evaluator.mli的插件架构。
 *
 * 整合的原始模块包括：
 * - artistic_evaluation, artistic_evaluators, artistic_core_evaluators
 * - artistic_evaluator_*, form_evaluators, artistic_form_evaluators  
 * - evaluation_framework, poetry_evaluation_engine 等31个模块
 *
 * 技术原则：零破坏性、向后兼容、插件化架构、统一类型系统
 *
 * @author Alpha, 主要工作代理 - Phase 2.3.1 艺术评价系统整合
 * @version 2.3.1 (统一整合版本)
 * @since 2025-07-30  
 * @fix_issue #1759 Phase 2.3 艺术评价系统整合优化
 *)

(** {1 统一类型定义系统} *)

(** 艺术性评价维度 - 整合所有原始类型定义 *)
type evaluation_dimension = 
  | RhymeHarmony  (** 韵律和谐度 *)
  | TonalBalance  (** 声调平衡 *)
  | MetricalForm  (** 格律形式 *)
  | Parallelism   (** 对仗工整 *)
  | Imagery       (** 意象营造 *)
  | Rhythm        (** 节奏韵律 *)
  | Elegance      (** 雅致程度 *)
  | ContentDepth  (** 内容深度 *)
  | FormBeauty    (** 形式美感 *)
  | SoundHarmony  (** 音韵和谐 *)
  | ContextMood   (** 意境营造 *)
  | EmotionExpression (** 情感表达 *)
  | Innovation    (** 创新性 *)
  | Overall       (** 综合评价 *)

type dimension_score = {
  dimension : evaluation_dimension;
  score : float;           (** 分数 0.0-1.0 *)
  max_possible : float;    (** 该维度最高可能分数 *)
  confidence : float;      (** 评价置信度 0.0-1.0 *)
  details : string option; (** 详细分析说明 *)
  suggestions : string list; (** 针对性改进建议 *)
}
(** 单个维度评价结果 *)

type artistic_evaluation = {
  overall_score : float;                           (** 总体分数 0.0-1.0 *)
  dimension_scores : dimension_score list;         (** 各维度详细评分 *)
  strengths : string list;                         (** 优点分析 *)
  weaknesses : string list;                        (** 不足分析 *)
  improvement_suggestions : string list;           (** 综合改进建议 *)
  artistic_level : [ `Beginner | `Intermediate | `Advanced | `Master ]; (** 艺术水平等级 *)
  quality_grade : [ `Excellent | `Good | `Fair | `Poor ]; (** 质量等级 *)
  evaluation_metadata : (string * string) list;   (** 评价元数据 *)
}
(** 统一艺术性评价结果 - 整合所有原始结果类型 *)

type mood_analysis = {
  primary_mood : string;      (** 主要意境类型 *)
  secondary_moods : string list; (** 次要意境元素 *)
  mood_intensity : float;     (** 意境强度 0.0-1.0 *)
  mood_coherence : float;     (** 意境连贯性 0.0-1.0 *)
  mood_techniques : string list; (** 意境营造技法 *)
}
(** 意境分析结果 *)

type rhetoric_analysis = {
  detected_techniques : string list;          (** 检测到的修辞手法 *)
  technique_examples : (string * string) list; (** 修辞手法与具体例子的对应 *)
  rhetoric_richness : float;                  (** 修辞丰富度 0.0-1.0 *)
  technique_effectiveness : (string * float) list; (** 各种修辞手法的有效性评分 *)
}
(** 修辞手法分析结果 *)

type evaluation_context = {
  verse : string;              (** 主要诗句 *)
  verses : string list;        (** 完整诗句列表 *)
  form_type : string option;   (** 诗歌形式类型 *)
  rhythm_info : (string * string) list; (** 韵律信息 *)
  metadata : (string * string) list;    (** 额外元数据 *)
}
(** 评价上下文信息 *)

(** {1 插件化评价器接口} *)

(** 评价器模块签名 - 参考analysis/artistic_evaluator.mli设计 *)
module type EVALUATOR = sig
  val dimension : evaluation_dimension
  val name : string
  val description : string  
  val weight : float
  val evaluate : evaluation_context -> dimension_score
  val is_applicable : evaluation_context -> bool
  val required_context : string list
end

(** {1 核心评价器模块实现} *)

module RhymeHarmonyEvaluator : EVALUATOR
(** 韵律和谐度评价器 - 整合rhyme_* 相关功能 *)

module TonalBalanceEvaluator : EVALUATOR  
(** 声调平衡评价器 - 整合声调分析功能 *)

module ParallelismEvaluator : EVALUATOR
(** 对仗评价器 - 整合parallelism_analysis.ml功能 *)

module ImageryEvaluator : EVALUATOR
(** 意象评价器 - 整合意象分析功能 *)

module FormBeautyEvaluator : EVALUATOR
(** 形式美感评价器 - 整合form_evaluators.ml功能 *)

module ContentDepthEvaluator : EVALUATOR
(** 内容深度评价器 - 整合内容分析功能 *)

module MoodContextEvaluator : EVALUATOR
(** 意境营造评价器 - 整合context相关功能 *)

module OverallEvaluator : EVALUATOR
(** 综合评价器 - 整合comprehensive相关功能 *)

(** {1 引擎状态管理} *)

type unified_artistic_engine_state
(** 统一艺术评价引擎状态 - 不透明类型 *)

exception ArtisticEngineError of string
(** 艺术评价引擎异常 *)

val initialize_engine : unit -> unified_artistic_engine_state
(** 初始化统一艺术评价引擎
 * @return 初始化的引擎状态 *)

val register_evaluator : 
  evaluation_dimension -> (module EVALUATOR) -> unified_artistic_engine_state -> unified_artistic_engine_state
(** 注册自定义评价器
 * @param dimension 评价维度
 * @param evaluator_module 评价器模块
 * @param engine_state 当前引擎状态
 * @return 更新后的引擎状态 *)

(** {1 核心评价功能} *)

val create_evaluation_context : string -> string list -> evaluation_context
(** 创建评价上下文
 * @param verse 主要诗句
 * @param verses 完整诗句列表  
 * @return 评价上下文 *)

val evaluate_single_dimension : 
  evaluation_dimension -> evaluation_context -> unified_artistic_engine_state -> dimension_score option
(** 单维度评价
 * @param dimension 评价维度
 * @param context 评价上下文
 * @param engine_state 引擎状态
 * @return 维度评价结果（如果适用）
 * @raise ArtisticEngineError 当评价失败时 *)

val comprehensive_artistic_evaluation : 
  string list -> unified_artistic_engine_state -> artistic_evaluation
(** 综合艺术性评价 - 主要接口函数
 * 
 * 整合了以下原始函数的功能：
 * - artistic_evaluation.ml: evaluate_poem_artistic
 * - artistic_evaluators.ml: multi_dimension_evaluation  
 * - poetry_artistic_engine.ml: comprehensive_artistic_evaluation
 * - analysis/artistic_evaluator.ml: evaluate_comprehensive
 *
 * @param verses 诗句列表
 * @param engine_state 引擎状态
 * @return 完整的艺术性评价结果
 * @raise ArtisticEngineError 当评价失败时 *)

(** {1 专项分析功能} *)

val analyze_mood_creation : string list -> unified_artistic_engine_state -> mood_analysis
(** 意境营造分析
 * 整合了artistic_evaluator_context.ml的功能
 * @param verses 诗句列表
 * @param engine_state 引擎状态
 * @return 意境分析结果 *)

val detect_rhetoric_techniques : string list -> unified_artistic_engine_state -> rhetoric_analysis  
(** 修辞手法检测
 * 整合了artistic_soul_evaluation.ml的部分功能
 * @param verses 诗句列表
 * @param engine_state 引擎状态
 * @return 修辞手法分析结果 *)

val analyze_form_beauty : string list -> unified_artistic_engine_state -> float * string list
(** 形式美感分析
 * 整合了form_evaluators.ml和artistic_form_evaluators.ml的功能
 * @param verses 诗句列表
 * @param engine_state 引擎状态
 * @return (形式美感分数, 具体建议列表) *)

val analyze_content_depth : string list -> unified_artistic_engine_state -> float * string list
(** 内容深度分析  
 * 整合了artistic_evaluator_content.ml的功能
 * @param verses 诗句列表
 * @param engine_state 引擎状态
 * @return (内容深度分数, 具体建议列表) *)

val analyze_sound_harmony : string list -> unified_artistic_engine_state -> float * string list
(** 音韵和谐分析
 * 整合了artistic_evaluator_sound.ml的功能
 * @param verses 诗句列表
 * @param engine_state 引擎状态
 * @return (音韵和谐分数, 具体建议列表) *)

(** {1 艺术指导功能} *)

val generate_improvement_guidance : artistic_evaluation -> unified_artistic_engine_state -> string list
(** 生成个性化改进建议
 * 整合了artistic_guidance.ml的功能
 * @param evaluation 艺术性评价结果
 * @param engine_state 引擎状态
 * @return 个性化改进建议列表 *)

val suggest_artistic_enhancements : string list -> unified_artistic_engine_state -> string list
(** 艺术性提升建议
 * @param verses 诗句列表
 * @param engine_state 引擎状态
 * @return 提升建议列表 *)

(** {1 工具和统计功能} *)

val get_engine_statistics : unified_artistic_engine_state -> (string * string) list
(** 获取引擎统计信息
 * @param engine_state 引擎状态
 * @return 统计信息键值对列表 *)

val clear_engine_cache : unified_artistic_engine_state -> unified_artistic_engine_state
(** 清理引擎缓存
 * @param engine_state 引擎状态
 * @return 清理缓存后的引擎状态 *)

val format_evaluation_result : artistic_evaluation -> string
(** 格式化评价结果
 * @param evaluation 艺术性评价结果
 * @return 格式化的字符串表示 *)

val export_evaluation_json : artistic_evaluation -> string
(** 导出评价结果为JSON格式
 * @param evaluation 艺术性评价结果
 * @return JSON格式字符串 *)

(** {1 向后兼容接口层} *)

(** 以下函数提供与原始模块的向后兼容性，保证现有代码无需修改 *)

val evaluate_poem_artistic : string list -> float
(** 兼容artistic_evaluation.ml: evaluate_poem_artistic
 * @deprecated 建议使用 comprehensive_artistic_evaluation 替代 *)

val multi_dimension_evaluation : string list -> artistic_evaluation  
(** 兼容artistic_evaluators.ml: multi_dimension_evaluation
 * @deprecated 建议使用 comprehensive_artistic_evaluation 替代 *)

val quick_artistic_check : string list -> bool * string list
(** 兼容evaluation_framework.ml: quick_artistic_check
 * @deprecated 建议使用 comprehensive_artistic_evaluation 替代 *)

val evaluate_rhyme_harmony : string -> float
(** 兼容多个模块的韵律评价函数
 * @deprecated 建议使用 analyze_sound_harmony 替代 *)

val evaluate_tonal_balance : string -> bool list option -> float
(** 兼容多个模块的声调平衡评价函数
 * @deprecated 建议使用相应的维度评价函数替代 *)

val evaluate_parallelism : string -> string -> float
(** 兼容多个模块的对仗评价函数  
 * @deprecated 建议使用 evaluate_single_dimension Parallelism 替代 *)

val evaluate_imagery : string -> float
(** 兼容多个模块的意象评价函数
 * @deprecated 建议使用 evaluate_single_dimension Imagery 替代 *)

val evaluate_rhythm : string -> float
(** 兼容多个模块的节奏评价函数
 * @deprecated 建议使用 evaluate_single_dimension Rhythm 替代 *)

val evaluate_elegance : string -> float
(** 兼容多个模块的雅致评价函数
 * @deprecated 建议使用 evaluate_single_dimension Elegance 替代 *)

val determine_overall_grade : string list -> [ `Excellent | `Good | `Fair | `Poor ]
(** 兼容多个模块的等级判定函数
 * @deprecated 建议使用 comprehensive_artistic_evaluation 中的 quality_grade 替代 *)

(** {1 Form-Specific Compatibility Functions} *)

val evaluate_siyan_parallel_prose : string array -> artistic_evaluation
(** 兼容form_evaluators.ml等的四言诗评价
 * @deprecated 建议使用 comprehensive_artistic_evaluation 替代 *)

val evaluate_wuyan_lushi : string array -> artistic_evaluation  
(** 兼容form_evaluators.ml等的五言律诗评价
 * @deprecated 建议使用 comprehensive_artistic_evaluation 替代 *)

val evaluate_qiyan_jueju : string array -> artistic_evaluation
(** 兼容form_evaluators.ml等的七言绝句评价
 * @deprecated 建议使用 comprehensive_artistic_evaluation 替代 *)

val evaluate_poetry_by_form : string -> string array -> artistic_evaluation
(** 兼容多个模块的按形式评价功能
 * @deprecated 建议使用 comprehensive_artistic_evaluation 替代 *)