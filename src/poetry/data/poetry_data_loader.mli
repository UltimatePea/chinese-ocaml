(** 统一诗词数据加载器接口 - 重构后的协调模块接口

    此模块现在作为协调中心，使用分离的子模块提供统一的诗词数据加载和管理接口。

    @author 骆言诗词编程团队 - Phase 15 超长文件重构
    @version 2.0
    @since 2025-07-21 *)

open Rhyme_groups.Rhyme_group_types

(** {1 重新导出的类型定义} *)

(** 从数据源管理器重新导出类型 *)
type data_source = Data_source_manager.data_source
type data_source_entry = Data_source_manager.data_source_entry

(** {1 数据源管理} *)

val register_data_source : string -> data_source -> ?priority:int -> string -> unit
(** 注册数据源

    @param name 数据源名称
    @param source 数据源
    @param priority 优先级 (可选，默认0，数字越大优先级越高)
    @param description 描述信息 *)

val get_registered_source_names : unit -> string list
(** 获取所有注册的数据源名称 *)

(** {1 统一数据库接口} *)

val get_unified_database : unit -> (string * rhyme_category * rhyme_group) list
(** 获取统一数据库 *)

(** {1 查询接口} *)

val is_char_in_database : string -> bool
(** 检查字符是否在数据库中 *)

val get_char_rhyme_info : string -> (string * rhyme_category * rhyme_group) option
(** 获取字符的韵律信息 *)

val get_chars_by_rhyme_group : rhyme_group -> (string * rhyme_category * rhyme_group) list
(** 按韵组查询字符 *)

val get_chars_by_rhyme_category : rhyme_category -> (string * rhyme_category * rhyme_group) list
(** 按韵类查询字符 *)

(** {1 统计信息} *)

val get_database_stats : unit -> int * int * int
(** 获取数据库统计信息
    @return (总字符数, 韵组数, 韵类数) *)

val validate_database : unit -> bool * string list
(** 数据完整性验证
    @return (是否有效, 错误列表) *)

(** {1 向后兼容性接口} *)

val get_expanded_rhyme_database : unit -> (string * rhyme_category * rhyme_group) list
(** 获取扩展韵律数据库 - 兼容原 expanded_rhyme_data.ml 接口 *)

val is_in_expanded_rhyme_database : string -> bool
(** 检查字符是否在扩展韵律数据库中 - 兼容原接口 *)

val get_expanded_char_list : unit -> string list
(** 获取扩展韵律字符列表 - 兼容原接口 *)

val expanded_rhyme_char_count : unit -> int
(** 扩展韵律字符总数 - 兼容原接口 *)

(** {1 调试和监控} *)

val print_registered_sources : unit -> unit
(** 打印数据源注册信息 *)

val clear_cache : unit -> unit
(** 清除所有缓存 *)

val reload_database : unit -> unit
(** 重新加载数据库 *)

(** {1 高级功能接口} *)

val load_rhyme_data_from_file : string -> (string * rhyme_category * rhyme_group) list
(** 从JSON文件加载韵律数据 *)

val load_from_source : data_source -> (string * rhyme_category * rhyme_group) list  
(** 从数据源加载数据 *)

val build_unified_database : unit -> (string * rhyme_category * rhyme_group) list
(** 构建统一数据库 *)

val merge_data_sources : data_source_entry list -> (string * rhyme_category * rhyme_group) list
(** 合并多个数据源，去除重复项 *)

val get_cache_info : unit -> bool * int
(** 获取缓存状态信息 *)

val force_refresh_cache : unit -> unit
(** 强制刷新缓存 *)

val find_data_source : string -> data_source_entry option
(** 查找指定名称的数据源 *)

val remove_data_source : string -> bool
(** 删除指定名称的数据源 *)
