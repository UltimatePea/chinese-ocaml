(** 韵律数据综合整合模块接口 - Issue #2084 Poetry模块架构整合

    整合了consolidated_rhyme_data和unified_rhyme_data的所有功能：
    - 统一数据库访问和统计
    - JSON数据加载和缓存管理
    - 向后兼容的查询接口

    Author: Whisky, PR Worker - Issue #2084 Poetry架构整合执行
    @version 3.0 - 综合整合版本 (consolidated + unified)
    @since 2025-08-04 - Poetry模块架构整合计划 - Fix #2084 *)

open Poetry_core.Poetry_types

(** {1 数据类型定义} *)

(** 数据来源标记 *)
type data_source =
  | RhymeData  (** 来自 rhyme_data.ml *)
  | UnifiedRhyme  (** 来自 unified_rhyme_data.ml *)
  | PoetryRhyme  (** 来自 poetry_rhyme_data.ml *)
  | ExpandedRhyme  (** 来自 expanded_rhyme_data.ml *)
  | DatabaseRhyme  (** 来自 rhyme_database.ml *)

type consolidated_rhyme_entry = {
  character : string;  (** 汉字字符 *)
  category : rhyme_category;  (** 韵类（平仄入） *)
  group : rhyme_group;  (** 韵组 *)
  source : data_source;  (** 数据来源 *)
}
(** 统一韵律数据条目 *)

type database_statistics = {
  total_entries : int;  (** 总条目数 *)
  ping_sheng_count : int;  (** 平声字数 *)
  ze_sheng_count : int;  (** 仄声字数 *)
  ru_sheng_count : int;  (** 入声字数 *)
  group_distribution : (rhyme_group * int) list;  (** 韵组分布 *)
  source_distribution : (data_source * int) list;  (** 数据源分布 *)
}
(** 数据库统计信息 *)

type consolidated_rhyme_database = {
  entries : consolidated_rhyme_entry list;  (** 所有数据条目 *)
  index : (string, rhyme_category * rhyme_group) Hashtbl.t;  (** 字符查询索引 *)
  stats : database_statistics;  (** 统计信息 *)
}
(** 统一韵律数据库 *)

(** {2 核心API接口} *)

val find_rhyme_info : string -> (rhyme_category * rhyme_group) option
(** 查找字符的韵律信息
    @param character 要查询的汉字
    @return Some (category, group) 如果找到，None 如果未找到 *)

val get_all_rhyme_data : unit -> consolidated_rhyme_entry list
(** 获取所有韵律数据
    @return 所有韵律数据条目的列表 *)

val get_database_stats : unit -> database_statistics
(** 获取数据库统计信息
    @return 数据库统计信息 *)

(** {2 筛选查询接口} *)

val get_entries_by_group : rhyme_group -> consolidated_rhyme_entry list
(** 按韵组获取数据
    @param group 韵组
    @return 属于该韵组的所有条目 *)

val get_entries_by_category : rhyme_category -> consolidated_rhyme_entry list
(** 按韵类获取数据
    @param category 韵类
    @return 属于该韵类的所有条目 *)

(** {2 调试和诊断} *)

val print_database_info : unit -> unit
(** 打印数据库统计信息 *)

(** {2 JSON数据加载接口 - 整合自unified_rhyme_data.ml} *)

val load_rhyme_data_to_cache : unit -> unit
(** 加载韵律数据到缓存 *)

val get_rhyme_group_chars : rhyme_group -> string list option
(** 获取指定韵组的字符集
    @param group 韵组
    @return Some chars 如果找到，None 如果未找到 *)

val get_all_rhyme_groups : unit -> (rhyme_group * rhyme_category) list
(** 获取所有韵组列表
    @return (韵组, 韵类)对的列表 *)

val get_json_data_stats : unit -> int * int
(** 获取JSON数据统计信息
    @return (总字符数, 总韵组数) *)

(** {3 错误处理} *)

type rhyme_data_error = JsonFileNotFound of string

exception RhymeDataError of rhyme_data_error
