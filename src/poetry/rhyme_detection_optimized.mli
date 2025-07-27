(** Phase 5.2 中文字符处理性能优化 - 增强韵律检测模块接口
    
    实施Issue #1473的核心优化目标：
    1. 韵律检测缓存系统 - 提升50%+性能
    2. 批量字符处理优化 - 减少20%+处理时间  
    3. 缓存命中率监控 - 达到90%+命中率
    4. 内存使用优化 - 保持稳定或改善10%
    
    Author: Alpha, 主工作代理
    Fix #1473 - Phase 5.2 中文字符处理性能优化 *)

open Rhyme_types

(** {1 增强韵律缓存模块} *)

module ChineseRhymeCache : sig
  type rhyme_performance_cache
  (** 高性能韵律缓存实例类型 *)
  
  val create_performance_cache : 
    ?char_capacity:int -> ?class_capacity:int -> ?group_capacity:int -> unit -> rhyme_performance_cache
  (** 创建高性能缓存实例 *)
  
  val get_rhyme_with_stats : rhyme_performance_cache -> string -> (rhyme_category * rhyme_group) option
  (** 高性能韵律查找 - 支持缓存命中率监控 *)
  
  val get_rhyme_class : rhyme_performance_cache -> string -> rhyme_category
  (** 高性能韵母分类查找 *)
  
  val get_rhyme_group : rhyme_performance_cache -> string -> rhyme_group
  (** 高性能韵组查找 *)
  
  val get_cache_performance_stats : rhyme_performance_cache -> int * int * int * float
  (** 缓存性能统计 (命中数, 未命中数, 总请求数, 命中率) *)
  
  val reset_performance_stats : rhyme_performance_cache -> unit
  (** 重置性能统计 *)
  
  val cache_performance_report : rhyme_performance_cache -> string
  (** 缓存性能报告 *)
end

(** {2 批量字符处理优化模块} *)

module BatchCharacterProcessor : sig
  type char_analysis_info = {
    char_str: string;
    is_chinese: bool;
    rhyme_category: rhyme_category option;
    rhyme_group: rhyme_group option;
  }
  (** 字符分析信息类型 *)
  
  type batch_analysis_result = {
    char_analyses: char_analysis_info list;
    processing_time_ms: float;
    cache_hit_rate: float;
  }
  (** 批量字符分析结果 *)
  
  val analyze_characters_batch : 
    ChineseRhymeCache.rhyme_performance_cache -> string list -> batch_analysis_result
  (** 批量分析字符 - 核心性能优化函数 *)
end

(** {3 中文标点符号快速识别优化} *)

module ChinesePunctuationOptimized : sig
  val is_chinese_punctuation_fast : string -> bool
  (** 快速中文标点符号识别 - O(1)复杂度 *)
  
  val convert_fullwidth_to_halfwidth_fast : string -> string
  (** 快速全角半角转换 - O(1)复杂度 *)
  
  val batch_punctuation_analysis : string list -> (string * bool * string) list
  (** 批量标点符号识别 *)
end

(** {4 简化高性能接口} *)

val find_rhyme_info_optimized : string -> (rhyme_category * rhyme_group) option
(** 简化的高性能韵律查找接口 *)

val detect_rhyme_category_optimized : string -> rhyme_category
(** 简化的高性能韵母分类检测 *)

val detect_rhyme_group_optimized : string -> rhyme_group
(** 简化的高性能韵组检测 *)

val analyze_characters_batch_optimized : string list -> BatchCharacterProcessor.batch_analysis_result
(** 批量字符处理接口 *)

val get_global_cache_stats : unit -> int * int * int * float
(** 获取全局缓存性能统计 *)

val generate_performance_report : unit -> string
(** 生成性能优化报告 *)

(** {5 向后兼容性接口} *)

val find_rhyme_info_by_string : string -> (rhyme_category * rhyme_group) option
(** 兼容原有API的优化版本 *)

val detect_rhyme_category_by_string : string -> rhyme_category
(** 兼容原有API的优化版本 *)

val detect_rhyme_group_by_string : string -> rhyme_group
(** 兼容原有API的优化版本 *)

val validate_performance_improvements : unit -> (string * float * string * bool) list
(** Phase 5.2性能优化验证函数 *)

(** 
    Phase 5.2 性能优化实施完成摘要:
    
    ✅ 韵律检测缓存系统 - 多级缓存，支持性能监控
    ✅ 批量字符处理优化 - 减少重复计算，提升吞吐量  
    ✅ 中文标点符号快速识别 - O(1)复杂度查找表
    ✅ 全角半角字符转换优化 - 预编译映射表
    ✅ 缓存命中率监控 - 实时统计和报告
    ✅ 向后兼容性保证 - 保持现有API不变
    
    预期性能提升:
    - 韵律检测: 50%+ 性能提升
    - 字符处理: 20%+ 时间减少  
    - 缓存命中率: 90%+ 目标
    - 内存使用: 稳定或改善10%
*)