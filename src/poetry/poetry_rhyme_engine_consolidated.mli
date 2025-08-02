(** Poetry Rhyme Engine Consolidated Module Interface - Issue #1999
 * 
 * 韵律匹配和查询引擎统一模块接口
 * Author: Whisky, PR Worker
 *)

open Poetry_core_consolidated

(** {1 引擎状态管理类型} *)

type engine_state = {
  initialized: bool;
  data_loaded: bool;
  cache_enabled: bool;
  performance_mode: bool;
}

type query_stats = {
  total_queries: int;
  cache_hits: int;
  cache_misses: int;
  avg_query_time: float;
}

(** {1 引擎初始化和配置} *)

(** 初始化引擎 *)
val initialize_engine : ?performance_mode:bool -> unit -> unit

(** 检查引擎是否已初始化 *)
val is_initialized : unit -> bool

(** 启用性能模式 *)
val enable_performance_mode : unit -> unit

(** 禁用缓存 *)
val disable_cache : unit -> unit

(** {1 韵律查询引擎} *)

(** 高性能韵律查询 *)
val find_rhyme_info_fast : string -> rhyme_info option

(** 批量韵律查询 *)
val batch_find_rhyme_info : string list -> (string * rhyme_info option) list

(** 查找同韵字符 *)
val find_rhyme_group_chars : rhyme_group -> string list

(** {1 韵律匹配引擎} *)

(** 韵律匹配质量评分 *)
val calculate_rhyme_quality : rhyme_info -> rhyme_info -> float

(** 高级韵律匹配 *)
val advanced_rhyme_match : string -> string -> rhyme_match_result

(** 验证诗词整体韵律 *)
val validate_poem_rhyme : string list -> (int * rhyme_match_result) list

(** {1 建议生成引擎} *)

(** 生成韵律改进建议 *)
val suggest_rhyme_improvements : string list -> string list

(** {1 性能监控} *)

(** 获取查询统计信息 *)
val get_query_stats : unit -> query_stats

(** 获取引擎状态 *)
val get_engine_state : unit -> engine_state

(** 重置统计信息 *)
val reset_stats : unit -> unit

(** 打印性能报告 *)
val print_performance_report : unit -> unit

(** {1 兼容性层} *)

val query_rhyme_compat : string -> rhyme_info option
val match_rhyme_compat : string -> string -> bool

(** 清理引擎 *)
val cleanup_engine : unit -> unit