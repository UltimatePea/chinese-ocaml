(* 数据加载器统计模块接口 *)

val increment_load : unit -> unit
(** 增加统计计数 *)

val increment_cache_hit : unit -> unit
val increment_cache_miss : unit -> unit
val increment_error : unit -> unit

val reset_stats : unit -> unit
(** 重置统计信息 *)

val get_stats : unit -> int * int * int * int
(** 获取统计信息 *)

val cache_hit_rate : unit -> float
(** 计算缓存命中率 *)

val print_stats : unit -> unit
(** 打印统计信息 *)

val generate_report : unit -> string
(** 生成统计报告 *)
