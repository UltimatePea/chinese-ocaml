(** 韵律查询引擎接口
    
    高性能的韵律查询接口，提供O(1)查询能力和智能缓存系统。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_types

(** {1 高性能查询接口} *)

(** 带缓存的字符查询 *)
val query_character_cached : string -> query_result

(** 带缓存的韵组查询 *)
val query_group_cached : rhyme_group -> rhyme_group_data option

(** 智能字符查询（支持异体字） *)
val smart_character_query : string -> query_result

(** 模糊查询（基于相似度） *)
val fuzzy_character_query : string -> float -> query_result

(** {1 批量查询优化} *)

(** 批量字符查询（带缓存优化） *)
val batch_query_optimized : string list -> query_result list

(** 并行批量查询（模拟并行处理） *)
val parallel_batch_query : string list -> query_result list

(** {1 高级查询功能} *)

(** 查询韵组内的同韵字符 *)
val find_rhyming_characters : string -> rhyme_character list

(** 查询相同声调的字符 *)
val find_same_tone_characters : string -> tone_category -> rhyme_character list

(** 韵律匹配度评分 *)
val calculate_rhyme_score : string -> string -> float

(** {1 查询统计和性能监控} *)

(** 查询统计信息 *)
type query_stats = {
  total_queries: int;
  cache_hits: int;
  cache_misses: int;
  average_response_time: float;
}

(** 获取查询统计 *)
val get_query_stats : unit -> query_stats

(** 获取缓存命中率 *)
val get_cache_hit_rate : unit -> float

(** 清空缓存 *)
val clear_cache : unit -> unit

(** {1 性能基准测试} *)

(** 执行性能基准测试，返回(总时间, 每秒查询数, 缓存命中率) *)
val run_benchmark : int -> float * float * float

(** 获取性能报告 *)
val get_performance_report : unit -> string

(** {1 简化的直接查询函数} *)

(** 直接查询字符韵组 - O(1)查询，无需复杂结果处理 *)
val lookup_character_rhyme_group : string -> rhyme_group

(** 直接查询字符声调 - O(1)查询，无需复杂结果处理 *)  
val lookup_character_tone : string -> tone_category

(** {1 兼容性函数} *)

(** 检测字符的韵组 - 兼容性函数 *)
val detect_rhyme_group : string -> rhyme_group

(** 检测字符的韵类 - 兼容性函数 *)
val detect_rhyme_category : string -> tone_category