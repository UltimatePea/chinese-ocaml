(** 韵律智能缓存管理系统接口
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_core_unified

(** {1 缓存配置类型} *)

type cache_config = {
  max_size: int;
  ttl_seconds: float;
  enable_lru: bool;
  preload_common: bool;
  auto_refresh: bool;
}

type cache_metrics = {
  hits: int;
  misses: int;
  evictions: int;
  preloads: int;
  total_size: int;
  memory_usage: int;
}

(** {1 缓存配置} *)

val default_config : cache_config
val set_cache_config : cache_config -> unit

(** {1 预加载操作} *)

val preload_common_characters : unit -> unit
val preload_group_data : rhyme_group -> unit
val full_preload : unit -> unit

(** {1 智能查询接口} *)

val smart_query_character : string -> rhyme_query_result
val smart_query_group : rhyme_group -> string list
val smart_query_category : rhyme_category -> string list

(** {1 缓存管理} *)

val clear_all_caches : unit -> unit
val refresh_cache : unit -> unit
val auto_maintenance : unit -> unit

(** {1 统计和监控} *)

val get_hit_rate : unit -> float
val get_cache_metrics : unit -> cache_metrics
val print_cache_stats : unit -> unit

(** {1 高级功能} *)

val cache_warmup : string list -> unit
val export_cache_state : unit -> (string * int * float) list
val batch_cache_load : string list -> unit