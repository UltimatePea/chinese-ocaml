(** 统一诗词分析引擎接口 - Phase 2: 完整统一架构
    
    此模块是Poetry系统重构的核心成果，提供完整的诗词分析功能，
    整合韵律分析、艺术性评价和格律检查三大引擎。
    
    技术债务修复总结：消除了100+个重复模块，建立统一架构
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (Phase 2: 引擎层重构完成版)
    @since 2025-07-27
    @fix_issue #1501 *)

(* 简化类型引用 *)
(* 使用统一韵律模块 *)

(** {1 统一引擎类型定义} *)

type complete_poetry_analysis = {
  input_verses : string list;  (** 输入诗句 *)
  (* 韵律分析结果 *)
  rhythm_analysis : multi_verse_analysis;  (** 多句韵律分析 *)
  individual_analyses : verse_rhythm_analysis list;  (** 各句详细分析 *)
  (* 艺术性评价结果 *)
  artistic_evaluation : Poetry_artistic.Artistic_evaluators.artistic_evaluation;  (** 综合艺术性评价 *)
  (* 格律检查结果 *)
  form_recognition : Meter_types.form_recognition_result;  (** 诗体识别 *)
  meter_check : Meter_types.meter_check_result;  (** 格律检查 *)
  (* 综合信息 *)
  overall_score : float;  (** 综合质量评分 *)
  quality_summary : string;  (** 质量总结 *)
  improvement_suggestions : string list;  (** 改进建议 *)
  analysis_timestamp : float;  (** 分析时间戳 *)
}
(** 完整的诗词分析结果 *)

type unified_engine_state
(** 统一引擎状态 - 不透明类型 *)

exception UnifiedEngineError of string
(** 统一引擎异常 *)

(** {1 引擎初始化与管理} *)

val initialize_unified_engine : unit -> unified_engine_state
(** 初始化统一诗词分析引擎
    @return 初始化的统一引擎状态
    @raise UnifiedEngineError 当初始化失败时 *)

val load_database_to_unified_engine : rhyme_database -> unified_engine_state -> unified_engine_state
(** 加载韵律数据库到统一引擎
    @param database 韵律数据库
    @param unified_state 当前统一引擎状态
    @return 更新后的统一引擎状态
    @raise UnifiedEngineError 当数据库加载失败时 *)

(** {1 核心分析功能} *)

val analyze_poetry_complete :
  string list -> unified_engine_state -> complete_poetry_analysis * unified_engine_state
(** 执行完整的诗词分析
    @param verses 诗句列表
    @param unified_state 统一引擎状态
    @return (完整分析结果, 更新后的引擎状态)
    @raise UnifiedEngineError 当分析失败时 *)

(** {1 专项分析功能} *)

val analyze_rhythm_only : string list -> unified_engine_state -> multi_verse_analysis
(** 仅执行韵律分析
    @param verses 诗句列表
    @param unified_state 统一引擎状态
    @return 多句韵律分析结果 *)

val evaluate_artistic_only : string list -> unified_engine_state -> Poetry_artistic.Artistic_evaluators.artistic_evaluation
(** 仅执行艺术性评价
    @param verses 诗句列表
    @param unified_state 统一引擎状态
    @return 综合艺术性评价结果 *)

val check_meter_only :
  string list -> unified_engine_state -> Meter_types.form_recognition_result * Meter_types.meter_check_result
(** 仅执行格律检查
    @param verses 诗句列表
    @param unified_state 统一引擎状态
    @return (诗体识别结果, 格律检查结果) *)

(** {1 推荐和建议功能} *)

val get_rhythm_suggestions : string -> unified_engine_state -> string list
(** 获取韵律改进建议
    @param verse 诗句
    @param unified_state 统一引擎状态
    @return 改进建议列表 *)

val recommend_rhyme_characters : string -> unified_engine_state -> string list
(** 推荐相似韵律的字符
    @param character 基准字符
    @param unified_state 统一引擎状态
    @return 相似韵律字符列表 *)

val recommend_group_characters : rhyme_group -> unified_engine_state -> string list
(** 推荐特定韵组的字符
    @param group 韵组
    @param unified_state 统一引擎状态
    @return 韵组字符列表 *)

(** {1 统计和监控功能} *)

val get_unified_engine_statistics : unified_engine_state -> (string * string) list
(** 获取统一引擎统计信息
    @param unified_state 统一引擎状态
    @return 统计信息键值对列表 *)

val clear_unified_engine_cache : unified_engine_state -> unified_engine_state
(** 清理统一引擎缓存
    @param unified_state 统一引擎状态
    @return 清理缓存后的统一引擎状态 *)

val validate_unified_engine_state : unified_engine_state -> bool
(** 验证统一引擎状态
    @param unified_state 统一引擎状态
    @return 引擎状态是否有效 *)

(** {1 格式化和输出功能} *)

val format_complete_analysis : complete_poetry_analysis -> string
(** 格式化完整分析结果
    @param analysis 完整分析结果
    @return 格式化的详细报告 *)

val format_concise_analysis : complete_poetry_analysis -> string
(** 生成简洁分析报告
    @param analysis 完整分析结果
    @return 格式化的简洁报告 *)

(** {1 批处理功能} *)

val batch_analyze_poems :
  string list list -> unified_engine_state -> complete_poetry_analysis list * unified_engine_state
(** 批量分析多首诗词
    @param poem_lists 诗词列表的列表
    @param unified_state 统一引擎状态
    @return (分析结果列表, 更新后的引擎状态) *)

val format_batch_analysis_report : complete_poetry_analysis list -> string
(** 生成批量分析报告
    @param analyses 分析结果列表
    @return 格式化的批量分析报告 *)

(** {1 配置和定制功能} *)

type analysis_config = {
  rhythm_weight : float;  (** 韵律分析权重 *)
  artistic_weight : float;  (** 艺术性权重 *)
  meter_weight : float;  (** 格律检查权重 *)
  enable_caching : bool;  (** 是否启用缓存 *)
  max_cache_size : int;  (** 最大缓存大小 *)
}
(** 分析配置 *)

val default_config : analysis_config
(** 默认配置 *)

val analyze_with_config :
  string list ->
  analysis_config ->
  unified_engine_state ->
  complete_poetry_analysis * unified_engine_state
(** 使用自定义配置执行分析
    @param verses 诗句列表
    @param config 分析配置
    @param unified_state 统一引擎状态
    @return (完整分析结果, 更新后的引擎状态) *)
