(** 诗词艺术评估配置模块接口
 *
 * 此模块包含诗词艺术评估系统的所有配置参数，包括评分权重、
 * 阈值设置、分析参数、报告配置和系统设置等。
 *
 * 主要功能：
 * - 各维度评分权重配置
 * - 评价等级阈值设置
 * - 韵律分析参数配置
 * - 形式美分析配置
 * - 文本分析参数
 * - 评价器通用配置
 * - 报告生成配置
 * - 系统运行参数
 *
 * @author Whisky, PR Worker
 *)

(** 默认评分：当找不到对应评价器时的默认分数 *)
val default_evaluation_score : float

(** {1 权重配置模块} *)

module WeightConfig : sig
  (** 韵律和谐度权重 *)
  val rhyme_harmony_weight : float
  
  (** 声调平衡权重 *)
  val tonal_balance_weight : float
  
  (** 形式美感权重 *)
  val form_beauty_weight : float
  
  (** 对仗工整权重 *)
  val parallelism_weight : float
  
  (** 意象丰富权重 *)
  val imagery_weight : float
  
  (** 节奏韵律权重 *)
  val rhythm_weight : float
  
  (** 典雅程度权重 *)
  val elegance_weight : float
  
  (** 内容深度权重 *)
  val content_depth_weight : float
  
  (** 所有权重的列表 *)
  val all_weights : float list
end

(** {1 阈值配置模块} *)

module ThresholdConfig : sig
  (** 优秀评价阈值 *)
  val excellent_threshold : float
  
  (** 良好评价阈值 *)
  val good_threshold : float
  
  (** 一般评价阈值 *)
  val fair_threshold : float
  
  (** 较差评价阈值 *)
  val poor_threshold : float
  
  (** 大师级别阈值 *)
  val master_level_threshold : float
  
  (** 高级水平阈值 *)
  val advanced_level_threshold : float
  
  (** 中级水平阈值 *)
  val intermediate_level_threshold : float
  
  (** 初级水平阈值 *)
  val beginner_level_threshold : float
end

(** {1 韵律分析配置模块} *)

module RhymeConfig : sig
  (** 韵律分析所需的最少诗句数 *)
  val min_verses_for_analysis : int
  
  (** 韵律分析所需的最少韵字数 *)
  val min_rhyme_chars_for_analysis : int
  
  (** 最佳韵律多样性下限 *)
  val optimal_rhyme_diversity_min : float
  
  (** 最佳韵律多样性上限 *)
  val optimal_rhyme_diversity_max : float
  
  (** 可接受韵律多样性下限 *)
  val acceptable_rhyme_diversity_min : float
  
  (** 可接受韵律多样性上限 *)
  val acceptable_rhyme_diversity_max : float
end

(** {1 形式美分析配置模块} *)

module FormConfig : sig
  (** 完美诗句数量列表（如绝句4句，律诗8句） *)
  val perfect_verse_counts : int list
  
  (** 良好诗句数量阈值 *)
  val good_verse_threshold : int
  
  (** 长度差异惩罚系数 *)
  val length_variance_penalty : float
  
  (** 结构完美评分 *)
  val structural_perfect_score : float
  
  (** 结构良好评分 *)
  val structural_good_score : float
  
  (** 结构一般评分 *)
  val structural_fair_score : float
end

(** {1 文本分析配置模块} *)

module TextConfig : sig
  (** 最大建议数量 *)
  val max_suggestions_count : int
  
  (** 最小置信度阈值 *)
  val min_confidence_threshold : float
  
  (** 是否启用UTF-8字符检测 *)
  val utf8_char_detection_enabled : bool
  
  (** 标点符号字符列表 *)
  val punctuation_chars : string list
end

(** {1 评价器配置模块} *)

module EvaluatorConfig : sig
  (** 韵律分析所需最少诗句数 *)
  val min_verses_for_rhyme_analysis : int
  
  (** 对仗分析所需最少诗句数 *)
  val min_verses_for_parallelism : int
  
  (** 形式美分析所需最少诗句数 *)
  val min_verses_for_form_beauty : int
  
  (** 默认最少诗句数 *)
  val default_min_verses : int
  
  (** 默认置信度因子 *)
  val default_confidence_factor : float
  
  (** 高置信度因子 *)
  val high_confidence_factor : float
  
  (** 中等置信度因子 *)
  val medium_confidence_factor : float
  
  (** 低置信度因子 *)
  val low_confidence_factor : float
  
  (** 获取维度所需的最少适用诗句数
      @param dimension 评价维度
      @return 最少诗句数 *)
  val get_min_applicable_verses : 'a -> int
end

(** {1 报告配置模块} *)

module ReportConfig : sig
  (** 最大优势项目数量 *)
  val max_strengths_count : int
  
  (** 最大劣势项目数量 *)
  val max_weaknesses_count : int
  
  (** 最大建议数量 *)
  val max_suggestions_count : int
  
  (** 是否包含元数据 *)
  val include_metadata : bool
  
  (** 是否包含置信度评分 *)
  val include_confidence_scores : bool
  
  (** 是否启用详细反馈 *)
  val detailed_feedback_enabled : bool
end

(** {1 系统配置模块} *)

module SystemConfig : sig
  (** 是否启用缓存 *)
  val enable_caching : bool
  
  (** 缓存生存时间（秒） *)
  val cache_ttl_seconds : int
  
  (** 最大缓存条目数 *)
  val max_cache_entries : int
  
  (** 是否启用性能监控 *)
  val enable_performance_monitoring : bool
  
  (** 是否记录评价详情 *)
  val log_evaluation_details : bool
  
  (** 是否启用并行评价 *)
  val parallel_evaluation_enabled : bool
end