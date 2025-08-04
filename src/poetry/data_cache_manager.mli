(** 数据缓存管理器 - 模块化重构后的统一入口接口 *)

(* 首先导入类型 *)
open Poetry_cache_management.Cache_management_types

(* 重新导出所有缓存管理功能 *)
include module type of Poetry_cache_management.Cache_management_consolidated

(* 兼容性类型覆盖 *)
val initialize :
  ?max_size_mb:float ->
  ?max_entries:int ->
  ?default_strategy:cache_strategy ->
  ?enable_statistics:bool ->
  unit ->
  unit
