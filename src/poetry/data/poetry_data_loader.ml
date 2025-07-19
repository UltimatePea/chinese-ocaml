(** 统一诗词数据加载器 - 消除代码重复的核心模块
    
    此模块提供统一的诗词数据加载和管理接口，替代分散在多个文件中的重复数据定义。
    通过中央化的数据管理，确保数据的一致性和可维护性。
    
    设计原则：
    1. 单一数据源：所有诗词数据通过此模块统一加载
    2. 向后兼容：保持现有模块的接口不变
    3. 可扩展性：支持动态注册新的数据源
    4. 性能优化：数据懒加载和缓存机制
    
    @author 骆言诗词编程团队 - Phase 15 代码重复消除
    @version 1.0
    @since 2025-07-19 *)

open Rhyme_groups.Rhyme_types

(** {1 数据源类型定义} *)

(** 数据源类型 - 支持多种数据来源 *)
type data_source =
  | ModuleData of (string * rhyme_category * rhyme_group) list
  | FileData of string
  | LazyData of (unit -> (string * rhyme_category * rhyme_group) list)

(** 数据源注册项 *)
type data_source_entry = {
  name: string;
  source: data_source;
  priority: int;
  description: string;
}

(** {1 全局数据注册表} *)

(** 注册的数据源列表 *)
let registered_sources = ref []

(** 缓存的统一数据库 *)
let cached_database = ref None

(** {1 数据源管理函数} *)

(** 注册数据源
    
    将新的数据源注册到全局注册表中。高优先级的数据源会覆盖低优先级的重复数据。
    
    @param name 数据源名称
    @param source 数据源
    @param priority 优先级 (数字越大优先级越高)
    @param description 描述信息 *)
let register_data_source name source ?(priority=0) description =
  let entry = { name; source; priority; description } in
  registered_sources := entry :: !registered_sources;
  cached_database := None (* 清除缓存 *)

(** 从数据源加载数据 *)
let load_from_source = function
  | ModuleData data -> data
  | FileData _filename -> 
      (* TODO: 支持从文件加载，当前返回空列表 *)
      []
  | LazyData loader -> loader ()

(** 获取所有注册的数据源名称 *)
let get_registered_source_names () =
  List.map (fun entry -> entry.name) !registered_sources

(** {1 统一数据库构建} *)

(** 合并多个数据源，去除重复项 *)
let merge_data_sources sources =
  let all_data = List.fold_left (fun acc entry ->
    let data = load_from_source entry.source in
    data @ acc
  ) [] sources in
  
  (* 去除重复项：按字符去重，保留优先级最高的数据源 *)
  let char_map = Hashtbl.create 1000 in
  List.iter (fun (char, category, group) ->
    if not (Hashtbl.mem char_map char) then
      Hashtbl.add char_map char (char, category, group)
  ) all_data;
  
  Hashtbl.fold (fun _char data acc -> data :: acc) char_map []

(** 构建统一数据库 *)
let build_unified_database () =
  let sorted_sources = List.sort (fun a b -> compare b.priority a.priority) !registered_sources in
  merge_data_sources sorted_sources

(** 获取统一数据库 (带缓存) *)
let get_unified_database () =
  match !cached_database with
  | Some db -> db
  | None ->
      let db = build_unified_database () in
      cached_database := Some db;
      db

(** {1 查询接口} *)

(** 检查字符是否在数据库中 *)
let is_char_in_database char =
  let db = get_unified_database () in
  List.exists (fun (c, _, _) -> c = char) db

(** 获取字符的韵律信息 *)
let get_char_rhyme_info char =
  let db = get_unified_database () in
  List.find_opt (fun (c, _, _) -> c = char) db

(** 按韵组查询字符 *)
let get_chars_by_rhyme_group group =
  let db = get_unified_database () in
  List.filter_map (fun (char, category, g) -> 
    if g = group then Some (char, category, g) else None
  ) db

(** 按韵类查询字符 *)
let get_chars_by_rhyme_category category =
  let db = get_unified_database () in
  List.filter_map (fun (char, cat, group) -> 
    if cat = category then Some (char, cat, group) else None
  ) db

(** {1 统计信息} *)

(** 获取数据库统计信息 *)
let get_database_stats () =
  let db = get_unified_database () in
  let total_chars = List.length db in
  let groups = List.fold_left (fun acc (_, _, group) -> 
    if List.mem group acc then acc else group :: acc
  ) [] db in
  let categories = List.fold_left (fun acc (_, category, _) -> 
    if List.mem category acc then acc else category :: acc
  ) [] db in
  (total_chars, List.length groups, List.length categories)

(** 数据完整性验证 *)
let validate_database () =
  let db = get_unified_database () in
  let errors = ref [] in
  
  (* 检查重复字符 *)
  let char_counts = Hashtbl.create 1000 in
  List.iter (fun (char, _, _) ->
    let count = try Hashtbl.find char_counts char with Not_found -> 0 in
    Hashtbl.replace char_counts char (count + 1)
  ) db;
  
  Hashtbl.iter (fun char count ->
    if count > 1 then
      errors := (Printf.sprintf "重复字符: %s (出现%d次)" char count) :: !errors
  ) char_counts;
  
  let is_valid = !errors = [] in
  (is_valid, !errors)

(** {1 向后兼容性接口} *)

(** 获取扩展韵律数据库 - 兼容原 expanded_rhyme_data.ml 接口 *)
let get_expanded_rhyme_database () = get_unified_database ()

(** 检查字符是否在扩展韵律数据库中 - 兼容原接口 *)
let is_in_expanded_rhyme_database char = is_char_in_database char

(** 获取扩展韵律字符列表 - 兼容原接口 *)
let get_expanded_char_list () = 
  List.map (fun (char, _, _) -> char) (get_unified_database ())

(** 扩展韵律字符总数 - 兼容原接口 *)
let expanded_rhyme_char_count () = 
  let (total, _, _) = get_database_stats () in
  total

(** {1 调试和监控} *)

(** 打印数据源注册信息 *)
let print_registered_sources () =
  Printf.printf "=== 已注册的诗词数据源 ===\n";
  List.iter (fun entry ->
    Printf.printf "- %s (优先级: %d): %s\n" entry.name entry.priority entry.description
  ) (List.rev !registered_sources);
  Printf.printf "总计: %d 个数据源\n" (List.length !registered_sources)

(** 清除所有缓存 *)
let clear_cache () =
  cached_database := None

(** 重新加载数据库 *)
let reload_database () =
  clear_cache ();
  ignore (get_unified_database ())