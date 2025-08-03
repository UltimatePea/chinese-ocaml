(** 诗词艺术评估统一引擎接口
 *
 * 提供统一的诗词艺术评估API，整合所有评估维度到一个模块中。
 * 
 * @author Whisky, PR Worker - 诗词艺术评估模块整合实施
 * @version 1.0 - 模块整合版本
 * @since 2025-08-03
 * @fix_issue #2000 Poetry艺术评估模块整合实施
 *)

(** {1 核心类型定义} *)

(** 评价维度枚举 *)
type evaluation_dimension =
  | RhymeHarmony       (** 韵律和谐度 *)
  | TonalBalance       (** 声调平衡度 *)
  | MetricalForm       (** 格律形式 *)
  | Parallelism        (** 对仗工整度 *)
  | Imagery            (** 意象深度 *)
  | Rhythm             (** 节奏感 *)
  | Elegance           (** 典雅性 *)
  | ContentDepth       (** 内容深度 *)
  | FormBeauty         (** 形式美感 *)
  | SoundHarmony       (** 声音和谐 *)
  | ContextMood        (** 意境营造 *)
  | EmotionExpression  (** 情感表达 *)
  | Innovation         (** 创新性 *)
  | Overall            (** 整体评价 *)

(** 单项评分结果 *)
type dimension_score = {
  dimension : evaluation_dimension;  (** 评价维度 *)
  score : float;                    (** 分数 (0.0-1.0) *)
  confidence : float;               (** 置信度 (0.0-1.0) *)
  details : string;                 (** 详细说明 *)
}

(** 综合评价结果 *)
type evaluation_result = {
  dimension_scores : dimension_score list;  (** 各维度分数 *)
  overall_score : float;                   (** 总体平均分 *)
  weighted_score : float;                  (** 加权分数 *)
  evaluation_time : float;                 (** 评估耗时(秒) *)
  metadata : (string * string) list;      (** 元数据 *)
}

(** 评价配置 *)
type evaluation_config = {
  weights : (evaluation_dimension * float) list;  (** 各维度权重 *)
  enable_cache : bool;                            (** 是否启用缓存 *)
  detailed_analysis : bool;                       (** 是否详细分析 *)
  custom_standards : (string * float) list option; (** 自定义标准 *)
}

(** {1 配置和常量} *)

(** 默认评分权重配置 *)
val default_weights : (evaluation_dimension * float) list

(** 默认评分：当无法评分时的默认分数 *)
val default_evaluation_score : float

(** 默认配置 *)
val default_config : evaluation_config

(** {1 核心评估函数} *)

(** 评价韵律和谐度
    @param verse 待评价的诗句
    @return 韵律和谐度评分结果 *)
val evaluate_rhyme_harmony : string -> dimension_score

(** 评价声调平衡度
    @param verse 待评价的诗句
    @param expected_pattern 期望的平仄模式（可选）
    @return 声调平衡度评分结果 *)
val evaluate_tonal_balance : string -> string option -> dimension_score

(** 评价对仗工整度
    @param left_verse 左联
    @param right_verse 右联
    @return 对仗工整度评分结果 *)
val evaluate_parallelism : string -> string -> dimension_score

(** 评价意象深度
    @param verse 待评价的诗句
    @return 意象深度评分结果 *)
val evaluate_imagery : string -> dimension_score

(** 评价形式美感
    @param verse 待评价的诗句
    @return 形式美感评分结果 *)
val evaluate_form_beauty : string -> dimension_score

(** {1 统一评估接口} *)

(** 评估单个诗句的所有维度
    @param config 评估配置（可选，默认使用default_config）
    @param verse 待评价的诗句
    @return 综合评价结果 *)
val evaluate_single_verse : ?config:evaluation_config -> string -> evaluation_result

(** 评估对联（左右两句）
    @param config 评估配置（可选，默认使用default_config）
    @param left_verse 左联
    @param right_verse 右联
    @return 综合评价结果 *)
val evaluate_couplet : ?config:evaluation_config -> string -> string -> evaluation_result

(** {1 工具函数} *)

(** 提取指定维度的分数
    @param evaluation 评价结果
    @param dimension 目标维度
    @return 对应维度的分数，如果未找到则返回默认分数 *)
val extract_dimension_score : evaluation_result -> evaluation_dimension -> float

(** {1 兼容性接口} *)

(** 兼容旧版本的evaluate_rhyme_harmony函数
    @param verse 待评价的诗句
    @return 韵律和谐度分数 (0.0-1.0) *)
val evaluate_rhyme_harmony_compat : string -> float

(** 兼容旧版本的evaluate_tonal_balance函数
    @param verse 待评价的诗句
    @param expected_pattern 期望的平仄模式
    @return 声调平衡度分数 (0.0-1.0) *)
val evaluate_tonal_balance_compat : string -> string -> float

(** 兼容旧版本的evaluate_parallelism函数
    @param left_verse 左联
    @param right_verse 右联
    @return 对仗工整度分数 (0.0-1.0) *)
val evaluate_parallelism_compat : string -> string -> float