(** 韵律引擎核心模块接口
 * 
 * 提供统一的韵律分析、匹配、验证和查询功能
 *)

open Poetry_core.Poetry_types

(** {1 韵律引擎类型定义} *)

type rhyme_performance_stats = {
  query_count : int;
  cache_hit_rate : float;
  average_response_time : float;
}

type rhyme_engine_config = {
  enable_cache : bool;
  max_cache_size : int;
  strict_mode : bool;
}

type rhyme_engine_info = {
  version : string;
  total_entries : int;
  cache_l1_size : int;
  cache_l2_size : int;
  performance_stats : rhyme_performance_stats;
  config : rhyme_engine_config;
  health_status : bool;
}

type rhyme_engine = {
  info : rhyme_engine_info;
  category_index : (rhyme_category, string list) Hashtbl.t;
  group_index : (rhyme_group, string list) Hashtbl.t;
  char_cache : (string, rhyme_category * rhyme_group) Hashtbl.t;
  mutable initialized : bool;
}

(** {1 引擎管理} *)

val create_engine : unit -> rhyme_engine
val initialize_engine : rhyme_engine -> unit
val cleanup_engine : rhyme_engine -> unit

(** {1 核心功能} *)

val find_char_rhyme : rhyme_engine -> string -> (rhyme_category * rhyme_group) option
val check_rhyme_compatibility : rhyme_engine -> string -> string -> bool
val analyze_verse_pattern : rhyme_engine -> string list -> (rhyme_category * rhyme_group) option list
val validate_poem_rhyme : rhyme_engine -> string list -> bool

(** {1 查询功能} *)

val find_chars_by_category : rhyme_engine -> rhyme_category -> string list
val find_chars_by_group : rhyme_engine -> rhyme_group -> string list
val find_rhyming_chars : rhyme_engine -> string -> string list

(** {1 状态和诊断} *)

(** 基础信息访问函数 - 修复unused字段警告 *)
val get_engine_version : rhyme_engine_info -> string
val get_total_entries : rhyme_engine_info -> int
val get_cache_sizes : rhyme_engine_info -> int * int

(** 性能和配置访问函数 - 修复unused字段警告 *)
val get_performance_stats : rhyme_engine_info -> rhyme_performance_stats
val get_engine_config : rhyme_engine_info -> rhyme_engine_config
val is_engine_healthy : rhyme_engine_info -> bool

(** 索引和状态访问函数 - 修复unused字段警告 *)
val get_category_index : rhyme_engine -> (rhyme_category, string list) Hashtbl.t
val is_engine_initialized : rhyme_engine -> bool

val get_engine_info : rhyme_engine -> rhyme_engine_info
val print_engine_status : rhyme_engine -> unit
val check_engine_health : rhyme_engine -> bool
val get_engine_statistics : rhyme_engine -> string

(** {1 全局引擎} *)

val get_global_engine : unit -> rhyme_engine

(** {1 简化接口} *)

val simple_rhyme_check : string -> string -> bool
val simple_analyze_verse : string -> (rhyme_category * rhyme_group) option
val simple_find_rhyming_chars : string -> string list