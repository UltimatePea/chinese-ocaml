(** 高性能韵律引擎接口 - Papa现代化核心组件
 *
 * 此模块提供O(1)韵律查询引擎，整合68个韵律模块至15-20个。
 * 实现Papa技术路线图的高性能韵律处理要求。
 *
 * Author: Whisky, PR Worker
 * Issue: #2114 Papa技术执行总路线图
 * Phase: 1 - Poetry架构整合与标准化
 * @version 2.0.0 - Papa现代化版本
 * @since 2025-08-02
 *)

(** {1 核心数据类型} *)

type rhyme_lookup_entry = {
  character: string;
  category: Poetry_core.Poetry_types.rhyme_category;
  group: Poetry_core.Poetry_types.rhyme_group;
  confidence: float;  (** 置信度 0.0-1.0 *)
  variants: string list;
  frequency: float;
}
(** 韵律查找条目，包含置信度和频率信息 *)

type rhyme_performance_stats = {
  total_queries: int;
  cache_hits: int;
  average_response_ms: float;
  last_optimization: string;
  memory_usage_bytes: int;
}
(** 性能统计数据 *)

type rhyme_engine_config = {
  enable_cache: bool;
  cache_size: int;
  enable_preload: bool;
  optimization_level: [`Fast | `Balanced | `Accurate];
  enable_batch_processing: bool;
  enable_parallel: bool;
}
(** 引擎配置选项 *)

type batch_rhyme_result = {
  results: rhyme_lookup_entry list;
  total_processing_time_ms: float;
  cache_hit_rate: float;
  success_rate: float;
}
(** 批量查询结果 *)

type rhyme_engine
(** 韵律引擎实例（抽象类型） *)

(** {2 引擎配置} *)

val create_default_config : unit -> rhyme_engine_config
(** 创建默认配置 - 平衡性能和准确性 *)

val create_high_performance_config : unit -> rhyme_engine_config
(** 创建高性能配置 - 优化查询速度 *)

val create_high_accuracy_config : unit -> rhyme_engine_config
(** 创建高精度配置 - 优化查询准确性 *)

(** {3 引擎管理} *)

val create_engine : ?config:rhyme_engine_config -> unit -> rhyme_engine
(** 创建韵律引擎实例
 * 
 * @param config 可选配置，默认使用balanced配置
 * @return 初始化的韵律引擎
 *)

val initialize_engine : ?config:rhyme_engine_config -> unit -> rhyme_engine
(** 初始化并设置为全局默认引擎
 * 
 * @param config 可选配置
 * @return 初始化的引擎实例
 *)

val get_default_engine : unit -> rhyme_engine
(** 获取默认引擎实例，如不存在则自动创建 *)

val shutdown_engine : unit -> unit
(** 关闭引擎，清理资源 *)

(** {4 核心查询API - O(1)性能} *)

val fast_rhyme_query : rhyme_engine -> string -> rhyme_lookup_entry option
(** 快速韵律查询 - O(1)性能
 * 
 * 使用多级缓存和预计算哈希表实现O(1)查询性能
 * 
 * @param engine 韵律引擎实例
 * @param character 要查询的汉字
 * @return 韵律信息，如果未找到则返回None
 * 
 * @example
 *   let engine = create_engine () in
 *   match fast_rhyme_query engine "春" with
 *   | Some entry -> 
 *       Printf.printf "韵类: %s, 韵组: %s, 置信度: %.2f\n"
 *         (show_rhyme_category entry.category)
 *         (show_rhyme_group entry.group)
 *         entry.confidence
 *   | None -> Printf.printf "未找到韵律信息\n"
 *)

val batch_rhyme_query : rhyme_engine -> string list -> batch_rhyme_result
(** 批量韵律查询 - 优化批量处理性能
 * 
 * 利用批量优化和智能缓存提升大量查询的性能
 * 
 * @param engine 韵律引擎实例
 * @param characters 汉字列表
 * @return 批量查询结果，包含性能指标
 * 
 * @example
 *   let engine = create_engine () in
 *   let poem_chars = ["春"; "眠"; "不"; "觉"; "晓"] in
 *   let result = batch_rhyme_query engine poem_chars in
 *   Printf.printf "缓存命中率: %.1f%%, 总时间: %.2fms\n"
 *     (result.cache_hit_rate *. 100.0) result.total_processing_time_ms
 *)

(** {5 韵律匹配算法} *)

val check_rhyme_match : rhyme_engine -> string -> string -> bool * float
(** 检查两个字符是否押韵
 * 
 * @param engine 韵律引擎实例
 * @param char1 第一个字符
 * @param char2 第二个字符
 * @return (是否押韵, 匹配置信度)
 * 
 * @example
 *   let engine = create_engine () in
 *   let (matches, confidence) = check_rhyme_match engine "春" "人" in
 *   if matches then
 *     Printf.printf "押韵匹配，置信度: %.2f\n" confidence
 *)

val find_rhyming_candidates : rhyme_engine -> string -> int -> string list
(** 查找押韵候选字符
 * 
 * @param engine 韵律引擎实例
 * @param character 参考字符
 * @param limit 返回结果数量限制
 * @return 可能押韵的字符列表
 *)

(** {6 兼容性API} *)

val find_rhyme_info : rhyme_engine -> string -> 
  (Poetry_core.Poetry_types.rhyme_category * Poetry_core.Poetry_types.rhyme_group) option
(** 兼容旧版API：查找韵律信息
 * 
 * 兼容poetry_recommended_api.find_rhyme_info
 *)

val detect_rhyme_category : rhyme_engine -> string -> Poetry_core.Poetry_types.rhyme_category
(** 兼容旧版API：检测韵律类别
 * 
 * 兼容poetry_recommended_api.detect_rhyme_category
 *)

val detect_rhyme_group : rhyme_engine -> string -> Poetry_core.Poetry_types.rhyme_group
(** 检测韵律组
 * 
 * @param engine 韵律引擎实例
 * @param character 要检测的字符
 * @return 韵律组
 *)

(** {7 性能监控与优化} *)

val get_performance_stats : rhyme_engine -> rhyme_performance_stats
(** 获取性能统计信息 *)

val optimize_cache : rhyme_engine -> bool
(** 优化缓存性能
 * 
 * @param engine 韵律引擎实例
 * @return 是否执行了优化操作
 *)

val preload_common_data : rhyme_engine -> unit
(** 预加载常用数据到缓存 *)

val engine_health_check : rhyme_engine -> bool
(** 引擎健康检查
 * 
 * @param engine 韵律引擎实例
 * @return 引擎是否健康运行
 *)

(** {8 简化API - 自动使用默认引擎} *)

val simple_find_rhyme_info : string -> 
  (Poetry_core.Poetry_types.rhyme_category * Poetry_core.Poetry_types.rhyme_group) option
(** 简化的韵律信息查找
 * 
 * 自动使用默认引擎，兼容现有代码
 * 
 * @param character 要查询的字符
 * @return 韵律信息
 *)

val simple_check_rhyme_match : string -> string -> bool
(** 简化的押韵检查
 * 
 * 自动使用默认引擎
 * 
 * @param char1 第一个字符
 * @param char2 第二个字符
 * @return 是否押韵
 *)

val simple_batch_analyze : string list -> batch_rhyme_result
(** 简化的批量分析
 * 
 * 自动使用默认引擎
 * 
 * @param characters 字符列表
 * @return 批量分析结果
 *)

(** {9 使用指南}
 *
 * {2 基本使用模式}
 * 
 * 1. **简单使用** - 适合现有代码迁移:
 * {[
 *   (* 直接使用简化API *)
 *   let rhyme_info = simple_find_rhyme_info "春" in
 *   let matches = simple_check_rhyme_match "春" "人" in
 * ]}
 *
 * 2. **高性能使用** - 适合批量处理:
 * {[
 *   (* 创建高性能引擎 *)
 *   let config = create_high_performance_config () in
 *   let engine = create_engine ~config () in
 *   
 *   (* 批量查询 *)
 *   let poem_chars = ["春"; "眠"; "不"; "觉"; "晓"] in
 *   let result = batch_rhyme_query engine poem_chars in
 * ]}
 *
 * 3. **精确分析使用** - 适合学术研究:
 * {[
 *   (* 创建高精度引擎 *)
 *   let config = create_high_accuracy_config () in
 *   let engine = create_engine ~config () in
 *   
 *   (* 详细查询 *)
 *   match fast_rhyme_query engine "春" with
 *   | Some entry -> 
 *       Printf.printf "置信度: %.3f, 频率: %.3f\n" 
 *         entry.confidence entry.frequency
 *   | None -> (* 处理未找到的情况 *)
 * ]}
 *
 * {2 性能优化建议}
 * 
 * - 程序启动时调用 {!initialize_engine} 进行预加载
 * - 批量查询时使用 {!batch_rhyme_query} 而非多次单独查询
 * - 定期调用 {!optimize_cache} 优化缓存性能
 * - 使用 {!get_performance_stats} 监控查询性能
 *
 * {2 向后兼容性}
 * 
 * 本模块提供完整的向后兼容性：
 * - 所有现有poetry_recommended_api功能均可通过兼容性API使用
 * - 简化API允许零修改迁移现有代码
 * - 性能提升对现有代码透明
 *)