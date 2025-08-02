(** 骆言Poetry模块统一API接口 - Papa现代化架构
 *
 * 这是Poetry模块现代化的核心统一接口，按照Papa技术执行路线图设计。
 * 提供标准化、高性能、易用的诗词编程功能接口。
 *
 * Author: Whisky, PR Worker
 * Issue: #2114 Papa技术执行总路线图：骆言项目现代化实施方案
 * Phase: 1 - Poetry架构整合与标准化
 * @version 2.0.0 - Papa现代化版本
 * @since 2025-08-02
 *)

(** {1 核心配置类型} *)

type rhyme_config = {
  accuracy: [`High | `Medium | `Fast];
  cache_enabled: bool;
  tone_strict: bool;
  batch_optimization: bool;
}
(** 韵律分析配置
 * - accuracy: 准确度级别 (High: 最高精度, Medium: 平衡, Fast: 快速)
 * - cache_enabled: 是否启用智能缓存
 * - tone_strict: 严格声调匹配
 * - batch_optimization: 批量处理优化
 *)

type artistic_config = {
  style: [`Classical | `Modern | `Free];
  strictness: [`Strict | `Moderate | `Relaxed];
  cultural_context: [`Tang | `Song | `Yuan | `Ming | `Qing | `Contemporary];
  parallel_evaluation: bool;
}
(** 艺术评估配置
 * - style: 诗词风格类型
 * - strictness: 评估严格程度
 * - cultural_context: 文化历史语境
 * - parallel_evaluation: 并行化评估
 *)

type performance_config = {
  max_cache_size: int;
  preload_common_data: bool;
  async_processing: bool;
  memory_optimization: bool;
}
(** 性能优化配置 *)

type unified_config = {
  rhyme: rhyme_config;
  artistic: artistic_config;
  performance: performance_config;
  debug_mode: bool;
  compatibility_mode: bool;
}
(** 统一配置类型 *)

(** {2 核心数据类型} *)

type rhyme_analysis_result = {
  character: string;
  category: Poetry_core.Poetry_types.rhyme_category;
  group: Poetry_core.Poetry_types.rhyme_group;
  confidence: float;  (** 置信度 0.0-1.0 *)
  alternatives: (Poetry_core.Poetry_types.rhyme_group * float) list;  (** 候选韵组 *)
  processing_time_ms: float;
}
(** 韵律分析结果 *)

type batch_rhyme_result = {
  results: rhyme_analysis_result list;
  total_processing_time_ms: float;
  cache_hit_rate: float;
  success_rate: float;
}
(** 批量韵律分析结果 *)

type artistic_evaluation_result = {
  overall_score: float;  (** 总体分数 0.0-1.0 *)
  dimensions: {
    rhyme_harmony: float;      (** 韵律和谐度 *)
    tonal_balance: float;      (** 声调平衡 *)
    imagery_depth: float;      (** 意象深度 *)
    emotional_resonance: float; (** 情感共鸣 *)
    structural_beauty: float;   (** 结构美感 *)
    cultural_authenticity: float; (** 文化真实性 *)
  };
  suggestions: string list;   (** 改进建议 *)
  processing_metadata: {
    evaluation_time_ms: float;
    algorithms_used: string list;
    confidence_level: float;
  };
}
(** 艺术评估结果 *)

type unified_result = {
  rhyme_analysis: batch_rhyme_result;
  artistic_evaluation: artistic_evaluation_result;
  meta: {
    total_time_ms: float;
    api_version: string;
    processing_nodes: int;
  };
}
(** 统一处理结果 *)

(** {1 统一韵律分析API} *)

module Rhyme : sig
  (** 韵律分析核心模块 - 高性能、统一接口 *)

  val analyze : rhyme_config -> string -> rhyme_analysis_result
  (** 分析单个字符的韵律信息
   * 
   * 使用现代化的分析引擎，支持多级缓存和智能优化
   * 
   * @param config 韵律分析配置
   * @param character 要分析的汉字
   * @return 详细的韵律分析结果
   * 
   * @example
   *   let config = {accuracy = `High; cache_enabled = true; tone_strict = true; batch_optimization = false} in
   *   let result = Rhyme.analyze config "春" in
   *   Printf.printf "韵类: %s, 置信度: %.2f\n" 
   *     (show_rhyme_category result.category) result.confidence
   *)

  val batch_analyze : rhyme_config -> string list -> batch_rhyme_result
  (** 批量分析韵律信息
   * 
   * 利用并行处理和智能缓存，大幅提升批量处理性能
   * 
   * @param config 韵律分析配置  
   * @param characters 汉字列表
   * @return 批量分析结果，包含性能指标
   * 
   * @example
   *   let poem_chars = ["春"; "眠"; "不"; "觉"; "晓"] in
   *   let result = Rhyme.batch_analyze config poem_chars in
   *   Printf.printf "缓存命中率: %.1f%%, 处理时间: %.2fms\n"
   *     (result.cache_hit_rate *. 100.0) result.total_processing_time_ms
   *)

  val check_rhyme_match : rhyme_config -> string -> string -> bool * float
  (** 检查韵律匹配
   * 
   * @param config 配置
   * @param char1 第一个字符
   * @param char2 第二个字符
   * @return (是否匹配, 匹配置信度)
   *)

  val find_rhyming_candidates : rhyme_config -> string -> string list
  (** 查找候选押韵字
   * 
   * @param config 配置
   * @param character 参考字符
   * @return 可能押韵的字符列表，按相似度排序
   *)

  val validate_rhyme_pattern : rhyme_config -> string list -> bool * string list
  (** 验证韵脚模式
   * 
   * @param config 配置  
   * @param rhyme_ending_chars 韵脚字符列表
   * @return (是否有效, 问题描述列表)
   *)
end

(** {2 统一艺术评估API} *)

module Artistic : sig
  (** 艺术评估核心模块 - 多维度、智能化评估 *)

  val evaluate : artistic_config -> string list -> artistic_evaluation_result
  (** 评估诗词艺术质量
   * 
   * 使用多维度评估算法，综合考虑韵律、意象、情感等因素
   * 
   * @param config 艺术评估配置
   * @param poem_lines 诗词行列表
   * @return 详细的艺术评估结果
   * 
   * @example
   *   let config = {style = `Classical; strictness = `Moderate; 
   *                 cultural_context = `Tang; parallel_evaluation = true} in
   *   let poem = ["春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"] in
   *   let result = Artistic.evaluate config poem in
   *   Printf.printf "总分: %.2f, 韵律和谐度: %.2f\n" 
   *     result.overall_score result.dimensions.rhyme_harmony
   *)

  val analyze_structure : artistic_config -> string list -> 
    [`Five_character | `Seven_character | `Irregular | `Unknown] * float
  (** 分析诗词结构
   * 
   * @param config 配置
   * @param poem_lines 诗词行
   * @return (诗词类型, 结构规范度)
   *)

  val suggest_improvements : artistic_config -> string list -> string list
  (** 提供改进建议
   * 
   * @param config 配置
   * @param poem_lines 诗词行
   * @return 具体的改进建议列表
   *)

  val compare_poems : artistic_config -> string list -> string list -> 
    [`First_better | `Second_better | `Similar] * float
  (** 比较两首诗词质量
   * 
   * @param config 配置
   * @param poem1 第一首诗
   * @param poem2 第二首诗  
   * @return (比较结果, 差异度分数)
   *)
end

(** {3 高级综合API} *)

module Unified : sig
  (** 统一处理API - 一站式诗词分析 *)

  val analyze_poem : unified_config -> string list -> unified_result
  (** 综合分析诗词
   * 
   * 同时进行韵律分析和艺术评估，提供完整的诗词质量报告
   * 
   * @param config 统一配置
   * @param poem_lines 诗词行列表
   * @return 综合分析结果
   * 
   * @example
   *   let config = {
   *     rhyme = {accuracy = `High; cache_enabled = true; tone_strict = true; batch_optimization = true};
   *     artistic = {style = `Classical; strictness = `Moderate; cultural_context = `Tang; parallel_evaluation = true};
   *     performance = {max_cache_size = 10000; preload_common_data = true; async_processing = true; memory_optimization = true};
   *     debug_mode = false;
   *     compatibility_mode = false;
   *   } in
   *   let poem = ["春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"] in
   *   let result = Unified.analyze_poem config poem in
   *   Printf.printf "处理时间: %.2fms, 总体分数: %.2f\n"
   *     result.meta.total_time_ms result.artistic_evaluation.overall_score
   *)

  val create_default_config : unit -> unified_config
  (** 创建默认配置
   * 
   * 提供经过优化的默认配置，适合大多数使用场景
   * 
   * @return 默认统一配置
   *)

  val create_high_performance_config : unit -> unified_config
  (** 创建高性能配置
   * 
   * 针对性能优化的配置，适合批量处理场景
   *)

  val create_high_accuracy_config : unit -> unified_config  
  (** 创建高精度配置
   * 
   * 针对准确性优化的配置，适合精细分析场景
   *)
end

(** {4 缓存与性能管理API} *)

module Cache : sig
  (** 智能缓存管理模块 *)

  val preload_data : performance_config -> unit
  (** 预加载数据到缓存
   * 
   * 在程序启动时调用，可显著提升后续查询性能
   * 
   * @param config 性能配置
   *)

  val clear_cache : unit -> unit
  (** 清理所有缓存 *)

  val get_cache_stats : unit -> {
    hit_rate: float;
    total_requests: int;
    memory_usage_bytes: int;
    cache_entries: int;
  }
  (** 获取缓存统计信息 *)

  val optimize_cache : unit -> unit
  (** 优化缓存性能 *)
end

(** {5 兼容性与迁移支持} *)

module Compatibility : sig
  (** 向后兼容性支持模块 *)

  val legacy_find_rhyme_info : string -> 
    (Poetry_core.Poetry_types.rhyme_category * Poetry_core.Poetry_types.rhyme_group) option
  (** 兼容旧版 poetry_recommended_api.find_rhyme_info *)

  val legacy_evaluate_poem : string list -> {
    score : float;
    rhyme_quality : float;
    artistic_quality : float;
    form_compliance : float;
    recommendations : string list;
  }
  (** 兼容旧版 poetry_recommended_api.evaluate_poem *)

  val legacy_check_rhyme_match : string -> string -> bool
  (** 兼容旧版 poetry_recommended_api.check_rhyme_match *)

  val create_migration_guide : unit -> string list
  (** 生成迁移指南 *)
end

(** {6 调试与诊断API} *)

module Debug : sig
  (** 调试和诊断工具模块 *)

  val enable_performance_profiling : bool -> unit
  (** 启用性能分析 *)

  val get_performance_report : unit -> string
  (** 获取性能报告 *)

  val validate_api_health : unit -> bool * string list
  (** API健康检查 *)

  val benchmark_operations : unified_config -> int -> {
    rhyme_analysis_avg_ms: float;
    artistic_eval_avg_ms: float;
    memory_usage_mb: float;
    throughput_ops_per_sec: float;
  }
  (** 性能基准测试 *)
end

(** {7 扩展API框架} *)

module Extension : sig
  (** 扩展功能框架 - 为未来功能预留接口 *)

  type custom_analyzer = string -> string list -> float
  (** 自定义分析器类型 *)

  val register_custom_analyzer : string -> custom_analyzer -> unit
  (** 注册自定义分析器 *)

  val apply_custom_analysis : string -> string list -> float option
  (** 应用自定义分析 *)
end

(** {8 模块状态与版本信息} *)

val get_api_version : unit -> string
(** 获取API版本信息 *)

val get_module_info : unit -> {
  version: string;
  build_date: string;
  features: string list;
  dependencies: string list;
}
(** 获取模块详细信息 *)

val initialize : ?config:unified_config -> unit -> unit
(** 初始化Poetry统一API模块
 * 
 * 建议在程序开始时调用，进行必要的初始化工作
 * 
 * @param config 可选的初始化配置
 *)

val shutdown : unit -> unit
(** 关闭Poetry统一API模块，清理资源 *)

(** {9 向前兼容性保证}
 *
 * 本统一API设计遵循以下兼容性原则：
 *
 * 1. **向后兼容**: 现有的poetry_recommended_api功能通过Compatibility模块提供
 * 2. **渐进迁移**: 提供明确的迁移路径和工具
 * 3. **性能优化**: 新API在保持功能的基础上提供更好的性能
 * 4. **扩展性**: 预留扩展接口，支持未来功能添加
 * 
 * 迁移建议：
 * - 新项目直接使用Unified模块
 * - 现有项目可通过Compatibility模块无缝过渡
 * - 性能敏感应用使用Rhyme/Artistic专门模块
 * - 调试和分析使用Debug模块
 *)