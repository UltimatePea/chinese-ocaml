(** 数据缓存管理器 - 模块化重构后的统一入口接口 *)

(* 重新导出所有缓存管理功能 *)
include module type of Poetry_cache.Cache_engine

(* 兼容性类型覆盖 *)
val initialize :
  ?max_size_mb:float ->
  ?max_entries:int ->
  ?debug:bool ->
  unit ->
  unit
