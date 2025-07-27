(** 韵律数据统一重构模块 - 重构为使用统一核心

    此模块现在使用新的统一核心 Rhyme_core_unified，消除重复和循环依赖。
    这是技术债务整合的一部分，将原有的分散数据源统一到核心模块。

    Author: Alpha, 主要工作代理
    @version 2.0 - 使用统一核心重构版本  
    @since 2025-07-27 - Poetry模块技术债务专项整合 - Fix #1516 *)

open Poetry_types_consolidated
open Rhyme_core_unified

(** {1 向后兼容的统一数据访问} *)

(** 数据来源标记 - 保留用于追踪数据源 *)
type data_source =
  | RhymeData  (** 来自 rhyme_data.ml *)
  | UnifiedRhyme  (** 来自 unified_rhyme_data.ml *)
  | PoetryRhyme  (** 来自 poetry_rhyme_data.ml *)
  | ExpandedRhyme  (** 来自 expanded_rhyme_data.ml *)
  | DatabaseRhyme  (** 来自 rhyme_database.ml *)

type consolidated_rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  source : data_source;
}
(** 统一韵律数据条目 *)

type database_statistics = {
  total_entries : int;
  ping_sheng_count : int;
  ze_sheng_count : int;
  ru_sheng_count : int;
  group_distribution : (rhyme_group * int) list;
  source_distribution : (data_source * int) list;
}
(** 数据库统计信息 *)

type consolidated_rhyme_database = {
  entries : consolidated_rhyme_entry list;
  index : (string, rhyme_category * rhyme_group) Hashtbl.t;
  stats : database_statistics;
}
(** 统一韵律数据库 *)

(** {2 数据转换和访问函数} *)

(** 从统一核心转换数据条目 *)
let convert_from_unified_core (entry : Rhyme_core_unified.rhyme_data_entry) =
  {
    character = entry.character;
    category = entry.category;
    group = entry.group;
    source = UnifiedRhyme;
  }

(** 构建统一数据库 *)
let build_consolidated_database () =
  let unified_entries = get_all_entries () in
  let consolidated_entries = List.map convert_from_unified_core unified_entries in
  
  (* 构建索引 *)
  let index = Hashtbl.create 2048 in
  List.iter (fun entry ->
    Hashtbl.add index entry.character (entry.category, entry.group)
  ) consolidated_entries;
  
  (* 计算统计信息 *)
  let total_entries = List.length consolidated_entries in
  let ping_sheng_count = List.length (get_chars_by_category PingSheng) in
  let ze_sheng_count = List.length (get_chars_by_category ZeSheng) in
  let ru_sheng_count = 0 in (* 当前数据中没有入声 *)
  
  let group_counts = List.fold_left (fun acc (group_data : Rhyme_core_unified.rhyme_group_data) ->
    let count = List.length group_data.entries in
    (group_data.group_name, count) :: acc
  ) [] (get_all_groups ()) in
  
  let source_distribution = [(UnifiedRhyme, total_entries)] in
  
  let stats = {
    total_entries;
    ping_sheng_count;
    ze_sheng_count;
    ru_sheng_count;
    group_distribution = group_counts;
    source_distribution;
  } in
  
  {
    entries = consolidated_entries;
    index;
    stats;
  }

(** 全局数据库实例 - 延迟初始化 *)
let database = ref None

(** 获取统一数据库 *)
let get_database () =
  match !database with
  | Some db -> db
  | None ->
      let db = build_consolidated_database () in
      database := Some db;
      db

(** {3 向后兼容的访问函数} *)

(** 查找字符的韵律信息 *)
let lookup_character char =
  let db = get_database () in
  List.find_opt (fun entry -> entry.character = char) db.entries

(** 获取韵组的所有字符 *)
let get_group_characters group =
  let db = get_database () in
  List.filter_map (fun entry ->
    if entry.group = group then Some entry.character else None
  ) db.entries

(** 获取韵类的所有字符 *)
let get_category_characters category =
  let db = get_database () in
  List.filter_map (fun entry ->
    if entry.category = category then Some entry.character else None
  ) db.entries

(** 获取所有数据条目 *)
let get_all_consolidated_entries () =
  (get_database ()).entries

(** 获取统计信息 *)
let get_database_statistics () =
  (get_database ()).stats

(** 检查字符是否存在 *)
let character_exists char =
  let db = get_database () in
  Hashtbl.mem db.index char

(** 快速查找字符的韵类和韵组 *)
let quick_lookup char =
  let db = get_database () in
  Hashtbl.find_opt db.index char

(** {4 导出函数} *)

(** 获取所有韵组数据 - 代理到统一核心 *)
let get_all_rhyme_groups = get_all_groups

(** 获取统计报告 *)
let get_statistics_report () =
  let stats = get_database_statistics () in
  Printf.sprintf
    "统一韵律数据库统计:\n\
     - 总字符数: %d\n\
     - 平声字符: %d\n\
     - 仄声字符: %d\n\
     - 韵组数量: %d\n\
     - 数据来源: 统一核心模块"
    stats.total_entries
    stats.ping_sheng_count
    stats.ze_sheng_count
    (List.length stats.group_distribution)

(** {5 额外兼容性函数} *)

(** 查找韵律信息 *)
let find_rhyme_info char_string =
  match lookup_character char_string with
  | Some entry -> Some (entry.category, entry.group)
  | None -> None

(** 获取所有韵律数据 *)
let get_all_rhyme_data () = 
  get_all_consolidated_entries ()

(** 获取数据库统计 *)
let get_database_stats () = 
  get_database_statistics ()

(** 按韵组获取条目 *)
let get_entries_by_group group = 
  let db = get_database () in
  List.filter (fun entry -> entry.group = group) db.entries

(** 按韵类获取条目 *)
let get_entries_by_category category = 
  let db = get_database () in
  List.filter (fun entry -> entry.category = category) db.entries

(** 打印数据库信息 *)
let print_database_info () =
  print_endline (get_statistics_report ())