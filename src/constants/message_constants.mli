(** 统计信息显示消息常量模块接口 *)

val performance_stats_header : string
(** 性能统计消息 *)

val infer_calls_format : string
val unify_calls_format : string
val subst_apps_format : string
val cache_hits_format : string
val cache_misses_format : string
val hit_rate_format : string
val cache_size_format : string

val debug_prefix : string
(** 通用消息模板 *)

val info_prefix : string
val warning_prefix : string
val error_prefix : string
val fatal_prefix : string

val compiling_file : string -> string
(** 编译过程消息 *)

val compilation_complete : string
val compilation_failed : string
val parsing_started : string
val parsing_complete : string
val type_checking_started : string
val type_checking_complete : string
