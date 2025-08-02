(** 韵律查询统一引擎接口 - 整合多个查询模块
    
    Author: Whisky, PR Worker
    @version 1.0 - Poetry韵律查询统一整合
    @since 2025-08-01
    @implements Issue #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_types_unified

(** {1 高性能查询系统} *)

(** 查询统计类型 *)
type query_stats = {
  mutable total_queries: int;
  mutable cache_hits: int;
  mutable cache_misses: int;
  mutable query_time_total: float;
}

(** {2 核心查询函数 - O(1)优化} *)

(** O(1) 韵字查询 - 核心性能优化 *)
val lookup_character_rhyme : string -> (rhyme_group * rhyme_category) option

(** O(1) 韵字匹配检查 - 优化版本 *)
val characters_rhyme : string -> string -> bool

(** O(1) 韵组查询 - 缓存优化 *)
val lookup_rhyme_group : rhyme_group -> string list

(** 查找同韵字 - 高性能版本 *)
val find_rhyming_characters : string -> string list

(** {2 高级查询功能} *)

(** 按声调查询韵字 *)
val lookup_by_tone_category : rhyme_category -> (string * rhyme_group * float) list

(** 按频率排序的韵字查询 *)
val lookup_by_frequency_threshold : float -> (string * rhyme_group * rhyme_category * float) list

(** 模糊韵律匹配 - 支持变体字 *)
val fuzzy_rhyme_match : string -> float -> (string * float * float) list

(** {2 批量查询优化} *)

(** 批量韵字查询 - 减少系统调用 *)
val batch_lookup_characters : string list -> (string * (rhyme_group * rhyme_category)) list

(** 批量韵律匹配检查 *)
val batch_rhyme_check : (string * string) list -> ((string * string) * bool) list

(** {2 查询统计和性能监控} *)

(** 获取查询统计 *)
val get_query_statistics : unit -> query_stats

(** 获取缓存统计 *)
val get_cache_statistics : unit -> (int * int * int)

(** 清空缓存 - 内存管理 *)
val clear_cache : unit -> unit

(** {2 性能基准测试} *)

(** 查询性能基准测试 *)
val benchmark_query_performance : int -> float

(** 匹配性能基准测试 *)
val benchmark_matching_performance : int -> float

(** {2 向后兼容接口} *)

(** 兼容原有查询引擎接口 *)
module Legacy_Query_API : sig
  (** 兼容 rhyme_query_engine.ml *)
  val query_rhyme : string -> (rhyme_group * rhyme_category) option
  val find_rhyming_words : string -> string list
  
  (** 兼容 rhyme_lookup.ml *)
  val lookup_rhyme_info : string -> unified_rhyme_entry option
  
  (** 兼容 rhyme_matching.ml *)
  val check_rhyme_match : string -> string -> bool
  val batch_check_rhymes : (string * string) list -> ((string * string) * bool) list
  
  (** 兼容 rhyme_api_core.ml *)
  val api_lookup_rhyme : string -> (rhyme_group * rhyme_category) option
  val api_find_rhymes : string -> string list
  val api_check_match : string -> string -> bool
end

(** {2 预热和初始化} *)

(** 预热缓存 - 提升首次查询性能 *)
val warmup_cache : unit -> unit

(** {2 兼容性API函数} *)

(** 输入标准化 - 被兼容层使用 *)
val normalize_input : string -> string

(** 获取字符声调 - 被兼容层使用 *)  
val get_character_tone : string -> rhyme_category option

(** 验证韵律匹配 - 被兼容层使用 *)
val validate_rhyme_match : string -> string -> bool

(** 验证字符韵律 - 被兼容层使用 *)
val validate_character_rhyme : string -> bool

(** 计算韵律相似度 - 高级匹配功能 *)
val calculate_rhyme_similarity : string -> string -> float

(** 计算匹配分数 - 量化匹配质量 *)
val calculate_match_score : string -> string -> float