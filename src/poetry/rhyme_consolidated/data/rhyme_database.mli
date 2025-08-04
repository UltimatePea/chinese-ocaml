(** 骆言诗词韵律数据库接口 - 统一韵律数据管理
    
    Author: Whisky, PR Worker - Issue #2084 Phase 2 韵律系统整合
    Date: 2025-08-04
    
    本模块接口定义了统一的韵律数据管理功能。 *)

open Poetry_types_unified.Unified_poetry_types

(** === 数据查询接口 === *)

(** 查找字符的韵律信息 *)
val find_character : string -> rhyme_data_item option

(** 获取指定韵组的所有字符 *)
val get_group_chars : rhyme_group -> rhyme_data_item list

(** 获取所有韵组信息：(韵组, 描述, 字符数量) *)
val get_all_groups : unit -> (rhyme_group * string * int) list

(** 获取数据库统计信息：(韵组数, 字符总数, 平均置信度) *)
val get_stats : unit -> (int * int * float)

(** === 数据导出接口 === *)

(** 导出为JSON兼容格式 *)
val export_json : unit -> rhyme_data_file

(** === 缓存管理接口 === *)

(** 从缓存获取字符信息 *)
val get_cached_char : string -> rhyme_data_item option

(** 清空所有缓存 *)
val clear_cache : unit -> unit