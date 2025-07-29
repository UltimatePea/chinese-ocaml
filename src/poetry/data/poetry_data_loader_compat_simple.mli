(** 诗词数据加载器兼容层接口 - Phase 2.2: 简化向后兼容性保证
    
    此模块提供与原始poetry_data_loader完全一致的接口，
    通过直接重新导出Data_source_manager的功能来实现兼容性。
    
    @author Alpha, 技术债务清理专员
    @version 2.2 - Phase 2.2 简化兼容层
    @since 2025-07-29
    @fix_issue #1732 *)

(** {1 直接重新导出Data_source_manager接口} *)

include module type of Data_source_manager

(** {1 补充兼容性接口} *)

val get_expanded_rhyme_database : unit -> (string * rhyme_category * rhyme_group) list
(** 获取扩展韵律数据库 - 兼容原 expanded_rhyme_data.ml 接口 *)

val is_in_expanded_rhyme_database : string -> bool
(** 检查字符是否在扩展韵律数据库中 - 兼容原接口 *)

val get_expanded_char_list : unit -> string list
(** 获取扩展韵律字符列表 - 兼容原接口 *)

val expanded_rhyme_char_count : unit -> int
(** 扩展韵律字符总数 - 兼容原接口 *)

val print_registered_sources : unit -> unit
(** 打印数据源注册信息 *)

val clear_cache : unit -> unit
(** 清除所有缓存 *)

val reload_database : unit -> unit
(** 重新加载数据库 *)

val is_char_in_database : string -> bool
(** 检查字符是否在数据库中 *)

val get_char_rhyme_info : string -> (string * rhyme_category * rhyme_group) option
(** 获取字符的韵律信息 *)

val get_chars_by_rhyme_group : rhyme_group -> (string * rhyme_category * rhyme_group) list
(** 按韵组查询字符 *)

val get_chars_by_rhyme_category : rhyme_category -> (string * rhyme_category * rhyme_group) list
(** 按韵类查询字符 *)

val get_database_stats : unit -> int * int * int
(** 获取数据库统计信息 *)

val validate_database : unit -> bool * string list
(** 数据完整性验证 *)

val get_cache_info : unit -> bool * int
(** 获取缓存状态信息 *)

val force_refresh_cache : unit -> unit
(** 强制刷新缓存 *)
