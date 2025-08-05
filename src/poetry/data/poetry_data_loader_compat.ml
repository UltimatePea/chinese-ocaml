(** 诗词数据加载器兼容层实现 - Phase 2.2: 向后兼容性保证
    
    此模块代理所有原始poetry_data_loader的接口到consolidated_data_loader，
    确保现有代码无需任何修改即可使用新的统一架构。
    
    @author Alpha, 技术债务清理专员
    @version 2.2 - Phase 2.2 兼容层
    @since 2025-07-29
    @fix_issue #1732 *)

open Consolidated_data_loader

(** {1 类型重新导出} *)

type data_source = Data_source_manager.data_source
type data_source_entry = Data_source_manager.data_source_entry
(* 使用完全限定名称以避免名称冲突 *)

(* 类型别名以匹配接口声明 *)
type rhyme_category = string
type rhyme_group = string

(** {1 内部兼容性状态管理} *)

(** 数据源注册表 - 保持与原始模块兼容 *)
let registered_sources : (string, data_source_entry) Hashtbl.t = Hashtbl.create 16

(** 数据库缓存 - 兼容原始缓存机制 *)
let unified_database_cache = ref None

(** {1 兼容性工具函数} *)

(** 转换韵类到字符串 *)
let convert_rhyme_category category =
  match category with
  | Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng -> "平声"
  | Yyocamlc_lib.Poetry_core.Poetry_types.ZeSheng -> "仄声"
  | Yyocamlc_lib.Poetry_core.Poetry_types.ShangSheng -> "上声"
  | Yyocamlc_lib.Poetry_core.Poetry_types.QuSheng -> "去声"
  | Yyocamlc_lib.Poetry_core.Poetry_types.RuSheng -> "入声"

let convert_rhyme_group group =
  match group with
  | Yyocamlc_lib.Poetry_core.Poetry_types.AnRhyme -> "安韵"
  | Yyocamlc_lib.Poetry_core.Poetry_types.FengRhyme -> "风韵"
  | Yyocamlc_lib.Poetry_core.Poetry_types.YuRhyme -> "鱼韵"
  | Yyocamlc_lib.Poetry_core.Poetry_types.YueRhyme -> "月韵"
  | Yyocamlc_lib.Poetry_core.Poetry_types.SiRhyme -> "思韵"
  | Yyocamlc_lib.Poetry_core.Poetry_types.TianRhyme -> "天韵"
  | Yyocamlc_lib.Poetry_core.Poetry_types.WangRhyme -> "王韵"
  | Yyocamlc_lib.Poetry_core.Poetry_types.QuRhyme -> "曲韵"
  | Yyocamlc_lib.Poetry_core.Poetry_types.HuaRhyme -> "花韵"
  | Yyocamlc_lib.Poetry_core.Poetry_types.JiangRhyme -> "江韵"
  | Yyocamlc_lib.Poetry_core.Poetry_types.HuiRhyme -> "回韵"
  | Yyocamlc_lib.Poetry_core.Poetry_types.UnknownRhyme -> "未知韵"

(** 转换综合数据库格式到兼容格式 *)
let convert_comprehensive_database comprehensive_data =
  List.map
    (fun (char, category, group) ->
      (char, convert_rhyme_category category, convert_rhyme_group group))
    comprehensive_data

(** {1 数据源管理实现} *)

let register_data_source name source ?(priority = 0) description =
  let entry =
    {
      Data_source_manager.name;
      Data_source_manager.source;
      Data_source_manager.priority;
      Data_source_manager.description;
    }
  in
  Hashtbl.replace registered_sources name entry;
  Printf.printf "数据源已注册: %s (优先级: %d)\n" name priority

let get_registered_source_names () =
  Hashtbl.fold (fun name _ acc -> name :: acc) registered_sources []

(** {1 统一数据库接口实现} *)

let get_unified_database () =
  match !unified_database_cache with
  | Some cached_data -> cached_data
  | None -> (
      try
        let comprehensive_data = get_unified_database () in
        let converted_data = convert_comprehensive_database comprehensive_data in
        unified_database_cache := Some converted_data;
        converted_data
      with e ->
        Printf.printf "警告: 统一数据库加载失败，使用空数据库: %s\n" (Printexc.to_string e);
        [])

(** {1 查询接口实现} *)

let is_char_in_database char = is_char_in_database char

let get_char_rhyme_info char =
  match get_char_rhyme_info char with
  | Some (c, category, group) -> Some (c, convert_rhyme_category category, convert_rhyme_group group)
  | None -> None

let get_chars_by_rhyme_group target_group =
  let database = get_unified_database () in
  List.filter (fun (_, _, group) -> group = target_group) database

let get_chars_by_rhyme_category target_category =
  let database = get_unified_database () in
  List.filter (fun (_, category, _) -> category = target_category) database

(** {1 统计信息实现} *)

let get_database_stats () =
  let database = get_unified_database () in
  let char_count = List.length database in

  (* 计算唯一韵组数量 *)
  let unique_groups =
    List.fold_left
      (fun acc (_, _, group) -> if List.mem group acc then acc else group :: acc)
      [] database
  in
  let group_count = List.length unique_groups in

  (* 计算唯一韵类数量 *)
  let unique_categories =
    List.fold_left
      (fun acc (_, category, _) -> if List.mem category acc then acc else category :: acc)
      [] database
  in
  let category_count = List.length unique_categories in

  (char_count, group_count, category_count)

let validate_database () =
  try
    let is_valid, errors = validate_all_data_integrity () in
    (is_valid, errors)
  with e -> (false, [ "数据完整性验证异常: " ^ Printexc.to_string e ])

(** {1 向后兼容性接口实现} *)

let get_expanded_rhyme_database () = get_unified_database ()
let is_in_expanded_rhyme_database char = is_char_in_database char

let get_expanded_char_list () =
  let database = get_unified_database () in
  List.map (fun (char, _, _) -> char) database

let expanded_rhyme_char_count () =
  let char_count, _, _ = get_database_stats () in
  char_count

(** {1 调试和监控实现} *)

let print_registered_sources () =
  Printf.printf "\n=== 已注册数据源 ===\n";
  if Hashtbl.length registered_sources = 0 then Printf.printf "暂无注册的数据源\n"
  else
    Hashtbl.iter
      (fun name entry ->
        Printf.printf "数据源: %s\n" name;
        Printf.printf "  优先级: %d\n" entry.Data_source_manager.priority;
        Printf.printf "  描述: %s\n" entry.Data_source_manager.description)
      registered_sources;
  Printf.printf "===================\n\n"

let clear_cache () =
  unified_database_cache := None;
  Consolidated_data_loader.clear_cache ();
  Printf.printf "诗词数据加载器缓存已清理\n"

let reload_database () =
  clear_cache ();
  let _ = get_unified_database () in
  Printf.printf "数据库已重新加载\n"

(** {1 高级功能接口实现} *)

let load_rhyme_data_from_file filename =
  try
    (* 使用consolidated模块加载JSON文件 *)
    let json_data = load_data (ExternalizedData (CustomJsonData filename)) in

    (* 解析JSON为韵律数据格式 *)
    let json_list = Yojson.Safe.Util.to_list json_data in
    List.map
      (fun json ->
        let char = Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "char" json) in
        let category_str = Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "category" json) in
        let group_str = Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "group" json) in

        let category = category_str in
        let group = group_str in

        (char, category, group))
      json_list
  with e ->
    Printf.printf "韵律数据文件加载失败: %s\n" (Printexc.to_string e);
    []

let load_from_source source =
  (* 代理到Data_source_manager的实现 *)
  try Data_source_manager.load_from_source source
  with e ->
    Printf.printf "数据源加载失败: %s\n" (Printexc.to_string e);
    []

let build_unified_database () = get_unified_database ()

let merge_data_sources entries =
  (* 合并多个数据源的数据 *)
  let all_data =
    List.fold_left
      (fun acc entry ->
        let source_data = load_from_source entry.Data_source_manager.source in
        acc @ source_data)
      [] entries
  in

  (* 去除重复项 (基于字符) *)
  let rec remove_duplicates = function
    | [] -> []
    | (char, category, group) :: rest ->
        let filtered_rest = List.filter (fun (c, _, _) -> c <> char) rest in
        (char, category, group) :: remove_duplicates filtered_rest
  in
  remove_duplicates all_data

let get_cache_info () =
  let is_cached = match !unified_database_cache with Some _ -> true | None -> false in
  let cache_size = if is_cached then 1 else 0 in
  (is_cached, cache_size)

let force_refresh_cache () =
  clear_cache ();
  let _ = get_unified_database () in
  warm_cache [ PoetryData UnifiedDatabase ];
  Printf.printf "诗词数据缓存已强制刷新\n"

let find_data_source name = try Some (Hashtbl.find registered_sources name) with Not_found -> None

let remove_data_source name =
  try
    Hashtbl.remove registered_sources name;
    Printf.printf "数据源已删除: %s\n" name;
    true
  with e ->
    Printf.printf "删除数据源失败: %s\n" (Printexc.to_string e);
    false
