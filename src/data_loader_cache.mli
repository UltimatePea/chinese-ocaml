(* 数据加载器缓存管理模块接口 *)

(** 获取缓存数据 *)
val get_cached : string -> 'a option

(** 设置缓存数据 *)
val set_cache : string -> 'a -> unit

(** 清空缓存 *)
val clear_cache : unit -> unit

(** 获取缓存大小 *)
val cache_size : unit -> int