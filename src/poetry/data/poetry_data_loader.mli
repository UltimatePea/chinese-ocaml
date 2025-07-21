(** 统一诗词数据加载器接口 - 消除代码重复的核心模块

    此模块提供统一的诗词数据加载和管理接口，替代分散在多个文件中的重复数据定义。

    @author 骆言诗词编程团队 - Phase 15 代码重复消除
    @version 1.0
    @since 2025-07-19 *)

open Rhyme_groups.Rhyme_group_types

(** {1 数据源类型定义} *)

(** 数据源类型 - 支持多种数据来源 *)
type data_source =
  | ModuleData of (string * rhyme_category * rhyme_group) list
  | FileData of string
  | LazyData of (unit -> (string * rhyme_category * rhyme_group) list)

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
