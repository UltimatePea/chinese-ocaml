(* 数据加载器缓存管理模块接口 *)

val get_cached : string -> 'a option
(** 获取缓存数据 *)

val set_cache : string -> 'a -> unit
(** 设置缓存数据 *)

val clear_cache : unit -> unit
(** 清空缓存 *)

val cache_size : unit -> int
(** 获取缓存大小 *)
