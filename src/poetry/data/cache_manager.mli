(** 缓存管理模块接口 - 统一的诗词数据缓存机制

    @author 骆言诗词编程团队 - Phase 15 超长文件重构
    @version 1.0
    @since 2025-07-21 *)

(** {1 数据库构建和缓存} *)

val merge_data_sources :
  Data_source_manager.data_source_entry list ->
  (string
  * Rhyme_groups.Rhyme_group_types.rhyme_category
  * Rhyme_groups.Rhyme_group_types.rhyme_group)
  list
(** 合并多个数据源，去除重复项 *)

val build_unified_database :
  unit ->
  (string
  * Rhyme_groups.Rhyme_group_types.rhyme_category
  * Rhyme_groups.Rhyme_group_types.rhyme_group)
  list
(** 构建统一数据库 *)

val get_unified_database :
  unit ->
  (string
  * Rhyme_groups.Rhyme_group_types.rhyme_category
  * Rhyme_groups.Rhyme_group_types.rhyme_group)
  list
(** 获取统一数据库 (带缓存) *)

(** {1 缓存管理操作} *)

val clear_cache : unit -> unit
(** 清除所有缓存 *)

val reload_database : unit -> unit
(** 重新加载数据库 *)

val is_cache_loaded : unit -> bool
(** 检查缓存是否已加载 *)

val force_refresh_cache : unit -> unit
(** 强制刷新缓存 *)

(** {1 查询接口} *)

val is_char_in_database : string -> bool
(** 检查字符是否在数据库中 *)

val get_char_rhyme_info :
  string ->
  (string
  * Rhyme_groups.Rhyme_group_types.rhyme_category
  * Rhyme_groups.Rhyme_group_types.rhyme_group)
  option
(** 获取字符的韵律信息 *)

val get_chars_by_rhyme_group :
  Rhyme_groups.Rhyme_group_types.rhyme_group ->
  (string
  * Rhyme_groups.Rhyme_group_types.rhyme_category
  * Rhyme_groups.Rhyme_group_types.rhyme_group)
  list
(** 按韵组查询字符 *)

val get_chars_by_rhyme_category :
  Rhyme_groups.Rhyme_group_types.rhyme_category ->
  (string
  * Rhyme_groups.Rhyme_group_types.rhyme_category
  * Rhyme_groups.Rhyme_group_types.rhyme_group)
  list
(** 按韵类查询字符 *)

(** {1 统计信息} *)

val get_database_stats : unit -> int * int * int
(** 获取数据库统计信息 *)

val get_cache_info : unit -> bool * int
(** 获取缓存状态信息 *)

(** {1 数据完整性验证} *)

val validate_database : unit -> bool * string list
(** 数据完整性验证 *)

(** {1 向后兼容性接口} *)

val get_expanded_rhyme_database :
  unit ->
  (string
  * Rhyme_groups.Rhyme_group_types.rhyme_category
  * Rhyme_groups.Rhyme_group_types.rhyme_group)
  list
(** 获取扩展韵律数据库 - 兼容原 expanded_rhyme_data.ml 接口 *)

val is_in_expanded_rhyme_database : string -> bool
(** 检查字符是否在扩展韵律数据库中 - 兼容原接口 *)

val get_expanded_char_list : unit -> string list
(** 获取扩展韵律字符列表 - 兼容原接口 *)

val expanded_rhyme_char_count : unit -> int
(** 扩展韵律字符总数 - 兼容原接口 *)
