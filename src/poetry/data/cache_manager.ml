(** 缓存管理模块 - 统一的诗词数据缓存机制
 
    从原 poetry_data_loader.ml 中提取的缓存管理功能，提供高效的数据缓存和查询能力。

    @author 骆言诗词编程团队 - Phase 15 超长文件重构
    @version 1.0
    @since 2025-07-21 *)

(** {1 缓存状态管理} *)

(** 缓存的统一数据库 *)
let cached_database = ref None

(** {1 数据库构建和缓存} *)

(** 合并多个数据源，去除重复项 *)
let merge_data_sources sources =
  let all_data =
    List.fold_left
      (fun acc entry ->
        let data = Data_source_manager.load_from_source entry.Data_source_manager.source in
        data @ acc)
      [] sources
  in

  (* 去除重复项：按字符去重，保留优先级最高的数据源 *)
  let char_map = Hashtbl.create 1000 in
  List.iter
    (fun (char, category, group) ->
      if not (Hashtbl.mem char_map char) then 
        Hashtbl.add char_map char (char, category, group))
    all_data;

  Hashtbl.fold (fun _char data acc -> data :: acc) char_map []

(** 构建统一数据库 *)
let build_unified_database () =
  let sorted_sources = Data_source_manager.get_sorted_sources () in
  merge_data_sources sorted_sources

(** 获取统一数据库 (带缓存) *)
let get_unified_database () =
  match !cached_database with
  | Some db -> db
  | None ->
      let db = build_unified_database () in
      cached_database := Some db;
      db

(** {1 缓存管理操作} *)

(** 清除所有缓存 *)
let clear_cache () = 
  cached_database := None

(** 重新加载数据库 *)
let reload_database () =
  clear_cache ();
  ignore (get_unified_database ())

(** 检查缓存是否已加载 *)
let is_cache_loaded () =
  !cached_database <> None

(** 强制刷新缓存 *)
let force_refresh_cache () =
  cached_database := Some (build_unified_database ())

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
  List.filter_map
    (fun (char, category, g) -> if g = group then Some (char, category, g) else None)
    db

(** 按韵类查询字符 *)
let get_chars_by_rhyme_category category =
  let db = get_unified_database () in
  List.filter_map
    (fun (char, cat, group) -> if cat = category then Some (char, cat, group) else None)
    db

(** {1 统计信息} *)

(** 获取数据库统计信息 *)
let get_database_stats () =
  let db = get_unified_database () in
  let total_chars = List.length db in
  let groups =
    List.fold_left (fun acc (_, _, group) -> if List.mem group acc then acc else group :: acc) [] db
  in
  let categories =
    List.fold_left
      (fun acc (_, category, _) -> if List.mem category acc then acc else category :: acc)
      [] db
  in
  (total_chars, List.length groups, List.length categories)

(** 获取缓存状态信息 *)
let get_cache_info () =
  let is_loaded = is_cache_loaded () in
  let size = if is_loaded then 
    let db = get_unified_database () in
    List.length db
  else 0
  in
  (is_loaded, size)

(** {1 数据完整性验证} *)

(** 数据完整性验证 *)
let validate_database () =
  let db = get_unified_database () in
  let errors = ref [] in

  (* 检查重复字符 *)
  let char_counts = Hashtbl.create 1000 in
  List.iter
    (fun (char, _, _) ->
      let count = try Hashtbl.find char_counts char with Not_found -> 0 in
      Hashtbl.replace char_counts char (count + 1))
    db;

  Hashtbl.iter
    (fun char count ->
      if count > 1 then 
        errors := Printf.sprintf "重复字符: %s (出现%d次)" char count :: !errors)
    char_counts;

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
  let total, _, _ = get_database_stats () in
  total