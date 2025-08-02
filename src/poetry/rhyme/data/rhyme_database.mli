(** 骆言韵律数据库统一模块接口 - Phase 1整合版本
    
    Author: Whisky, PR Worker
    Date: 2025-08-02
    Issue: #2084 Poetry模块架构整合计划
    *)

open Poetry_core.Poetry_types

(** {1 统一韵律数据结构} *)

type database_stats = {
  total_characters: int;
  total_groups: int;
  ping_sheng_count: int;
  ze_sheng_count: int;
  ru_sheng_count: int;
}

type rhyme_entry = {
  character: string;
  category: rhyme_category;
  group: rhyme_group;
  frequency: float;
  variants: string list;
  pronunciation: string option;
}

type rhyme_group_definition = {
  group_id: rhyme_group;
  group_name: string;
  description: string;
  representative_chars: string list;
  entries: rhyme_entry list;
}

type rhyme_database = {
  version: string;
  groups: rhyme_group_definition list;
  character_index: (string, rhyme_entry) Hashtbl.t;
  group_index: (rhyme_group, rhyme_group_definition) Hashtbl.t;
  metadata: (string * string) list;
}

(** {2 数据库访问} *)

val get_database : unit -> rhyme_database
(** [get_database ()] 获取全局韵律数据库实例 *)

(** {3 查询接口} *)

val find_character_rhyme : string -> rhyme_entry option
(** [find_character_rhyme character] 查找字符的韵律信息 *)

val find_group_definition : rhyme_group -> rhyme_group_definition option
(** [find_group_definition group] 查找韵组定义 *)

val get_all_characters_in_group : rhyme_group -> string list
(** [get_all_characters_in_group group] 获取指定韵组的所有字符 *)

val get_all_rhyme_groups : unit -> rhyme_group list
(** [get_all_rhyme_groups ()] 获取所有韵组列表 *)

(** {4 统计和分析} *)

val get_database_stats : unit -> database_stats
(** [get_database_stats ()] 获取数据库统计信息 *)

(** {5 向后兼容接口} *)

val get_all_rhyme_data : unit -> (string * rhyme_category * rhyme_group) list
(** [get_all_rhyme_data ()] 兼容旧版本的数据获取接口 *)

val get_rhyme_data_simple : unit -> (string * rhyme_category * rhyme_group) list
(** [get_rhyme_data_simple ()] 简化版本的数据获取接口 *)

val get_version : unit -> string
(** [get_version ()] 获取数据库版本 *)

val rebuild_indices : unit -> unit
(** [rebuild_indices ()] 重建数据库索引 *)

(** {6 数据导出功能} *)

val export_to_json : unit -> string
(** [export_to_json ()] 导出数据库信息为JSON格式 *)

val print_database_summary : unit -> unit
(** [print_database_summary ()] 打印数据库摘要信息 *)