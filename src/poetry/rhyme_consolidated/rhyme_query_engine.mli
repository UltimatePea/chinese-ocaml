(** 韵律查询引擎接口 - O(1)查询优化
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_core_unified

(** {1 缓存管理} *)

val initialize_cache : unit -> unit
val is_cache_initialized : unit -> bool
val ensure_cache_initialized : unit -> unit

(** {1 优化查询接口} *)

val query_character : string -> rhyme_query_result
val query_group_characters : rhyme_group -> string list
val query_category_characters : rhyme_category -> string list
val check_rhyme_match : string -> string -> bool
val batch_query_characters : string list -> rhyme_character_info list

(** {1 性能监控} *)

val get_cache_hit_rate : unit -> float
val get_detailed_cache_stats : unit -> float * int * int
val print_performance_stats : unit -> unit

(** {1 性能基准测试} *)

val benchmark_query_performance : int -> float
val benchmark_performance : int -> float

(** {1 缓存管理接口} *)

val preload_cache : unit -> unit
val refresh_cache : unit -> unit
val get_cache_stats : unit -> float * int * int

(** {1 高级查询功能} *)

val fuzzy_query_character : string -> rhyme_character_info list
val query_group_by_frequency : rhyme_group -> rhyme_character_info list
val query_common_characters : unit -> rhyme_character_info list