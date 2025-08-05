(** Poetry艺术评价引擎整合核心模块接口 - 基于PR #2175框架完成模块化重构
    
    整合多个重复的artistic_engine变体，提供统一的艺术评价接口。
    
    Author: Whisky, PR Worker - 基于PR #2175成功经验的艺术评价整合专家
    @version 1.0 - Phase 2.1-D
    @since 2025-08-05
    @fix_issue #2179 *)

(** {1 核心艺术评价类型} *)

type consolidated_artistic_type =
  | CoreEvaluation of core_subtype
  | UnifiedEngine of unified_subtype  
  | ConfigManagement of config_subtype
  | CacheManagement of cache_subtype
  | DataManagement of data_subtype
  | ReportingSystem of reporting_subtype
  | FilteringSystem of filtering_subtype
  | MetricsSystem of metrics_subtype
  | StandardsSystem of standards_subtype

and core_subtype =
  | RhymeHarmonyEvaluation
  | TonalBalanceEvaluation
  | ParallelismEvaluation
  | ImageryEvaluation
  | RhythmEvaluation
  | EleganceEvaluation
  | ComprehensiveEvaluation

and unified_subtype =
  | FormEvaluation
  | ContentEvaluation
  | SoundEvaluation
  | ContextEvaluation
  | EmotionEvaluation
  | InnovationEvaluation
  | QueryInterface

and config_subtype =
  | WeightConfiguration
  | ThresholdConfiguration
  | RhymeConfiguration
  | FormConfiguration
  | TextConfiguration
  | EvaluatorConfiguration
  | ReportConfiguration
  | SystemConfiguration

and cache_subtype =
  | EvaluationCache
  | ResultCache
  | ConfigCache

and data_subtype =
  | EvaluationData
  | MetadataManagement
  | ContextManagement

and reporting_subtype =
  | StandardReports
  | DetailedReports
  | ComparisonReports

and filtering_subtype =
  | QualityFilters
  | LevelFilters
  | TypeFilters

and metrics_subtype =
  | PerformanceMetrics
  | QualityMetrics
  | AnalysisMetrics

and standards_subtype =
  | EvaluationStandards
  | QualityStandards
  | FormStandards

(** {1 错误处理} *)

type consolidated_artistic_error =
  | CoreEvaluationError of string * string
  | UnifiedEngineError of string * string
  | ConfigError of string * string
  | CacheError of string * string
  | DataError of string * string
  | ReportingError of string * string
  | FilteringError of string * string
  | MetricsError of string * string
  | StandardsError of string * string
  | ConsolidatedArtisticError of string
  | CompatibilityError of string

exception ConsolidatedArtisticError of consolidated_artistic_error

val format_consolidated_artistic_error : consolidated_artistic_error -> string

(** {1 评价配置} *)

type consolidated_artistic_config = {
  enable_cache : bool;
  cache_size_limit : int;
  enable_fallback : bool;
  enable_performance_tracking : bool;
  timeout_ms : int;
  evaluation_precision : [`High | `Medium | `Low];
  concurrent_evaluation : bool;
}

val default_artistic_config : consolidated_artistic_config

(** {1 评价结果类型} *)

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

type evaluation_context = {
  verse : string;
  verses : string list;
  poem_type : string option;
  author : string option;
  historical_context : string option;
  metadata : (string * string) list;
}

(** {1 核心评价函数} *)

val evaluate_rhyme_harmony : string -> float
(** 评价韵律和谐度：检查诗句的音韵是否和谐 *)

val evaluate_tonal_balance : string -> string option -> float
(** 评价声调平衡度：检查平仄搭配是否合理 *)

val evaluate_imagery : string -> float
(** 评价意象深度：分析诗句中意象的丰富程度和深度 *)

val evaluate_rhythm : string -> float
(** 评价节奏韵律：分析诗句的节奏感 *)

val evaluate_elegance : string -> float
(** 评价雅致程度：评估用词的雅致和文学价值 *)

val evaluate_parallelism : string -> string -> float
(** 评价对仗工整度：检查对仗的工整程度 *)

(** {1 核心评价引擎接口} *)

val evaluate_artistic_work : ?config:consolidated_artistic_config -> 
  consolidated_artistic_type -> evaluation_context -> artistic_evaluation
(** 核心艺术评价功能：根据指定类型和上下文进行艺术评价 *)

val batch_evaluate_artistic_works : ?config:consolidated_artistic_config -> 
  consolidated_artistic_type -> evaluation_context list -> artistic_evaluation list
(** 批量艺术评价功能：对多个作品进行批量评价 *)

val comprehensive_artistic_evaluation_unified : string -> artistic_evaluation
(** 综合艺术性评价：对诗词进行全面的艺术性评估 *)

(** {1 工具函数} *)

val artistic_type_to_string : consolidated_artistic_type -> string
(** 将艺术评价类型转换为字符串描述 *)

val extract_final_char : string -> string option
(** 提取韵脚字符 - 复杂UTF-8字符处理算法 *)

val string_contains_substring : string -> string -> bool
(** 字符串包含检测 - UTF-8安全 *)

(** {1 缓存管理} *)

val warm_artistic_cache : consolidated_artistic_type list -> evaluation_context list -> unit
(** 预热艺术评价缓存 *)

val clear_artistic_cache : unit -> unit
(** 清理所有艺术评价缓存 *)

val get_artistic_cache_stats : unit -> (consolidated_artistic_type * bool * int) list
(** 获取艺术评价缓存统计信息 *)

(** {1 性能监控} *)

val get_artistic_performance_metrics : unit -> (consolidated_artistic_type * float * int) list
(** 获取艺术评价性能度量指标 *)

val enable_artistic_performance_tracking : bool -> unit
(** 启用或禁用艺术评价性能跟踪 *)

(** {1 向后兼容性接口} *)

(** 兼容artistic_core.ml接口 *)
module Legacy_Core : sig
  type engine_state = { 
    initialized : bool; 
    cache_size : int; 
    evaluation_count : int; 
    last_update : float; 
  }
  
  val initialize_engine : unit -> engine_state
  (** 初始化评价引擎 *)
  
  val create_evaluation_context : string -> string list -> evaluation_context
  (** 创建评价上下文 *)
  
  val comprehensive_artistic_evaluation : string list -> engine_state -> artistic_evaluation
  (** 综合艺术性评价：对诗词进行全面的艺术性评估 *)
  
  val evaluate_single_dimension : evaluation_dimension -> evaluation_context -> 
    engine_state -> dimension_score option
  (** 单维度评价函数 *)
  
  val evaluate_wuyan_lushi : string -> artistic_evaluation
  (** 评价五言律诗 *)
  
  val evaluate_qiyan_jueju : string -> artistic_evaluation
  (** 评价七言绝句 *)
  
  val evaluate_siyan_parallel_prose : string -> artistic_evaluation
  (** 评价四言骈文 *)
  
  val evaluate_poetry_by_form : string -> string -> artistic_evaluation
  (** 根据诗词形式进行专项评价 *)
  
  val evaluate_poem_artistic : string -> float
  (** 单一评价函数 - API兼容性 *)
  
  val multi_dimension_evaluation : string -> artistic_evaluation
  (** 兼容性函数：多维评价 *)
  
  val quick_artistic_check : string -> bool * string list
  (** 快速艺术性检查 *)
end

(** 兼容artistic_engine_unified.ml接口 *)
module Legacy_Unified : sig
  type artistic_dimension = Content | Form | Sound | Context | Emotion | Innovation
  
  type artistic_evaluation = {
    overall_score : float;
    dimension_scores : (artistic_dimension * float) list;
    strengths : string list;
    weaknesses : string list;
    improvement_suggestions : string list;
    artistic_level : [ `Beginner | `Intermediate | `Advanced | `Master ];
  }
  
  val comprehensive_artistic_evaluation : string -> artistic_evaluation
  (** 综合艺术性评价：对诗词进行全面的艺术性评估 *)
  
  val evaluate_rhyme_harmony : string -> float
  (** 评价韵律和谐度 *)
  
  val evaluate_tonal_balance : string -> string -> float
  (** 评价声调平衡度 *)
  
  val evaluate_parallelism : string -> string -> float
  (** 评价对仗工整度 *)
  
  val evaluate_imagery : string -> float
  (** 评价意象深度 *)
  
  val evaluate_rhythm : string -> float
  (** 评价节奏韵律 *)
  
  val evaluate_elegance : string -> float
  (** 评价雅致程度 *)
  
  val evaluate_siyan_parallel_prose : string -> float
  (** 评价四言骈文 *)
  
  val evaluate_wuyan_lushi : string -> float
  (** 评价五言律诗 *)
  
  val evaluate_qiyan_jueju : string -> float
  (** 评价七言绝句 *)
  
  val evaluate_poetry_by_form : string -> string -> float
  (** 根据诗词形式进行专项评价 *)
end

(** {1 调试和监控} *)

val print_artistic_status : unit -> unit
(** 打印整合艺术评价引擎状态信息 *)