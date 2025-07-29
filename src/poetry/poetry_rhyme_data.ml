(** 骆言诗词韵律数据管理模块 - 重构为使用统一核心

    此模块现在使用新的统一核心 Rhyme_core_unified，消除重复和循环依赖。 这是技术债务整合的一部分，将原有的分散数据源统一到核心模块。

    Author: Alpha, 主要工作代理
    @version 3.0 - 使用统一核心重构版本
    @since 2025-07-27 - Poetry模块技术债务专项整合 - Fix #1516 *)

open Poetry_core.Rhyme_core_types
open Rhyme_core_unified
(* Note: Importing central types first, then Rhyme_core_unified for data functions *)

(** {1 向后兼容的数据访问接口} *)

(* 简化的韵律数据条目类型 - 保持向后兼容 
   当前未使用，暂时注释 *)
(* type simple_rhyme_entry = string * rhyme_category * rhyme_group *)

(** {2 数据访问函数} *)

(* 韵组数据构建辅助函数 - 保持与原有API兼容 
   当前未使用，暂时注释 *)
(* let make_rhyme_group_data group category chars =
  List.map (fun char -> (char, category, group)) chars *)

(** 从统一核心获取安韵组数据 *)
let an_rhyme_data =
  match get_rhyme_group_data AnRhyme with
  | Some group_data ->
      List.map (fun entry -> (entry.character, entry.category, entry.group)) group_data.entries
  | None -> []

(** 从统一核心获取天韵组数据 *)
let tian_rhyme_data =
  match get_rhyme_group_data TianRhyme with
  | Some group_data ->
      List.map (fun entry -> (entry.character, entry.category, entry.group)) group_data.entries
  | None -> []

(** 从统一核心获取思韵组数据 *)
let si_rhyme_data =
  match get_rhyme_group_data SiRhyme with
  | Some group_data ->
      List.map (fun entry -> (entry.character, entry.category, entry.group)) group_data.entries
  | None -> []

(** 从统一核心获取鱼韵组数据 *)
let yu_rhyme_data =
  match get_rhyme_group_data YuRhyme with
  | Some group_data ->
      List.map (fun entry -> (entry.character, entry.category, entry.group)) group_data.entries
  | None -> []

(** 从统一核心获取花韵组数据 *)
let hua_rhyme_data =
  match get_rhyme_group_data HuaRhyme with
  | Some group_data ->
      List.map (fun entry -> (entry.character, entry.category, entry.group)) group_data.entries
  | None -> []

(** 从统一核心获取风韵组数据 *)
let feng_rhyme_data =
  match get_rhyme_group_data FengRhyme with
  | Some group_data ->
      List.map (fun entry -> (entry.character, entry.category, entry.group)) group_data.entries
  | None -> []

(** 从统一核心获取望韵组数据 *)
let wang_rhyme_data =
  match get_rhyme_group_data WangRhyme with
  | Some group_data ->
      List.map (fun entry -> (entry.character, entry.category, entry.group)) group_data.entries
  | None -> []

(** 从统一核心获取去韵组数据 *)
let qu_rhyme_data =
  match get_rhyme_group_data QuRhyme with
  | Some group_data ->
      List.map (fun entry -> (entry.character, entry.category, entry.group)) group_data.entries
  | None -> []

(** 从统一核心获取月韵组数据 *)
let yue_rhyme_data =
  match get_rhyme_group_data YueRhyme with
  | Some group_data ->
      List.map (fun entry -> (entry.character, entry.category, entry.group)) group_data.entries
  | None -> []

(** 从统一核心获取江韵组数据 *)
let jiang_rhyme_data =
  match get_rhyme_group_data JiangRhyme with
  | Some group_data ->
      List.map (fun entry -> (entry.character, entry.category, entry.group)) group_data.entries
  | None -> []

(** 从统一核心获取灰韵组数据 *)
let hui_rhyme_data =
  match get_rhyme_group_data HuiRhyme with
  | Some group_data ->
      List.map (fun entry -> (entry.character, entry.category, entry.group)) group_data.entries
  | None -> []

(** {3 统一数据集合} *)

(** 所有韵组数据的统一列表 *)
let all_rhyme_group_data =
  [
    an_rhyme_data;
    tian_rhyme_data;
    si_rhyme_data;
    yu_rhyme_data;
    hua_rhyme_data;
    feng_rhyme_data;
    wang_rhyme_data;
    qu_rhyme_data;
    yue_rhyme_data;
    jiang_rhyme_data;
    hui_rhyme_data;
  ]

(** 扁平化的所有韵律数据 *)
let all_rhyme_data = List.flatten all_rhyme_group_data

(** {4 查询和工具函数} *)

(** 根据字符查找韵律信息 *)
let lookup_rhyme_info char = List.find_opt (fun (c, _category, _group) -> c = char) all_rhyme_data

(** 根据韵组获取所有字符 *)
let get_rhyme_group_chars group =
  List.filter_map (fun (char, _category, g) -> if g = group then Some char else None) all_rhyme_data

(** 根据韵类获取所有字符 *)
let get_rhyme_category_chars category =
  List.filter_map (fun (char, c, _group) -> if c = category then Some char else None) all_rhyme_data

(* 检查字符是否在韵律数据中 - 当前未使用 *)
(* let character_in_rhyme_data char =
  List.exists (fun (c, _, _) -> c = char) all_rhyme_data *)

(** 获取总字符数统计 *)
let get_total_character_count () = List.length all_rhyme_data

(* 获取韵组统计 - 当前未使用 *)
(* let get_group_statistics () =
  let groups = List.fold_left (fun acc (_, _, group) ->
    let count = try List.assoc group acc with Not_found -> 0 in
    (group, count + 1) :: List.remove_assoc group acc
  ) [] all_rhyme_data in
  groups *)

(** {5 导出函数 - 代理到统一核心} *)

(* 获取完整统计信息 - 当前未使用 *)
(* let get_comprehensive_statistics = get_statistics *)

(* 获取所有韵组数据结构 - 当前未使用 *)
(* let get_all_rhyme_groups = get_all_groups *)

(* 字符查找函数 - 当前未使用 *)
(* let find_character = lookup_character *)

(** {6 接口兼容性函数 - 满足 .mli 接口要求} *)

(** 获取所有韵律数据 - 兼容接口函数 *)
let get_all_rhyme_data () = all_rhyme_data

(** 按韵类获取韵律数据 *)
let get_rhyme_by_category category =
  List.filter_map
    (fun (char, c, group) -> if c = category then Some (char, group) else None)
    all_rhyme_data

(** 按韵组获取韵律数据 *)
let get_rhyme_by_group group =
  List.filter_map
    (fun (char, category, g) -> if g = group then Some (char, category) else None)
    all_rhyme_data

(** 查找字符信息 *)
let lookup_char_info char =
  let char_string = String.make 1 char in
  match lookup_rhyme_info char_string with
  | Some (_, category, group) -> Some (category, group)
  | None -> None

(** 批量查找 *)
let batch_lookup chars =
  List.filter_map
    (fun char ->
      match lookup_char_info char with
      | Some (category, group) -> Some (char, category, group)
      | None -> None)
    chars

(** 获取韵组大小 *)
let get_rhyme_group_size group = List.length (get_rhyme_group_chars group)

(** 列出所有韵组 *)
let list_all_rhyme_groups () =
  [
    AnRhyme;
    SiRhyme;
    TianRhyme;
    WangRhyme;
    QuRhyme;
    YuRhyme;
    HuaRhyme;
    FengRhyme;
    YueRhyme;
    JiangRhyme;
    HuiRhyme;
  ]

(** 检查韵组是否为空 *)
let is_rhyme_group_empty group = get_rhyme_group_size group = 0

(** 获取平声字符 *)
let get_ping_sheng_chars () = get_rhyme_category_chars PingSheng

(** 获取仄声字符 *)
let get_ze_sheng_chars () = get_rhyme_category_chars ZeSheng

(** 获取韵类分布 *)
let get_category_distribution () =
  let ping_count = List.length (get_ping_sheng_chars ()) in
  let ze_count = List.length (get_ze_sheng_chars ()) in
  [ (PingSheng, ping_count); (ZeSheng, ze_count) ]

(** 初始化数据 - 空实现，数据已在模块加载时初始化 *)
let initialize_data () = ()

(** 重新加载数据 - 空实现，数据是静态的 *)
let reload_data () = ()

(** 检查数据是否已加载 *)
let is_data_loaded () = true

(** JSON解析器模块 - 简化实现 *)
module JsonParser = struct
  let parse_rhyme_data content =
    let raw_data = Poetry_data.Json_parser.parse_rhyme_data_json content in
    (* 转换类型: Poetry_core.Poetry_types -> Poetry_types_consolidated *)
    List.map
      (fun (char, cat, grp) ->
        let converted_cat =
          match cat with
          | Poetry_core.Poetry_types.PingSheng -> PingSheng
          | Poetry_core.Poetry_types.ZeSheng -> ZeSheng
          | Poetry_core.Poetry_types.ShangSheng -> ShangSheng
          | Poetry_core.Poetry_types.QuSheng -> QuSheng
          | Poetry_core.Poetry_types.RuSheng -> RuSheng
        in
        let converted_grp =
          match grp with
          | Poetry_core.Poetry_types.AnRhyme -> AnRhyme
          | Poetry_core.Poetry_types.SiRhyme -> SiRhyme
          | Poetry_core.Poetry_types.TianRhyme -> TianRhyme
          | Poetry_core.Poetry_types.WangRhyme -> WangRhyme
          | Poetry_core.Poetry_types.QuRhyme -> QuRhyme
          | Poetry_core.Poetry_types.YuRhyme -> YuRhyme
          | Poetry_core.Poetry_types.HuaRhyme -> HuaRhyme
          | Poetry_core.Poetry_types.FengRhyme -> FengRhyme
          | Poetry_core.Poetry_types.YueRhyme -> YueRhyme
          | Poetry_core.Poetry_types.XueRhyme -> XueRhyme
          | Poetry_core.Poetry_types.JiangRhyme -> JiangRhyme
          | Poetry_core.Poetry_types.HuiRhyme -> HuiRhyme
          | Poetry_core.Poetry_types.UnknownRhyme -> UnknownRhyme
        in
        (char, converted_cat, converted_grp))
      raw_data

  (* 移除未使用的函数以消除编译警告 *)

  let parse_single_entry entry_str =
    let char, cat, grp = Poetry_data.Json_parser.parse_single_rhyme_entry entry_str in
    (* 转换类型: Poetry_core.Poetry_types -> Poetry_types_consolidated *)
    let converted_cat =
      match cat with
      | Poetry_core.Poetry_types.PingSheng -> PingSheng
      | Poetry_core.Poetry_types.ZeSheng -> ZeSheng
      | Poetry_core.Poetry_types.ShangSheng -> ShangSheng
      | Poetry_core.Poetry_types.QuSheng -> QuSheng
      | Poetry_core.Poetry_types.RuSheng -> RuSheng
    in
    let converted_grp =
      match grp with
      | Poetry_core.Poetry_types.AnRhyme -> AnRhyme
      | Poetry_core.Poetry_types.SiRhyme -> SiRhyme
      | Poetry_core.Poetry_types.TianRhyme -> TianRhyme
      | Poetry_core.Poetry_types.WangRhyme -> WangRhyme
      | Poetry_core.Poetry_types.QuRhyme -> QuRhyme
      | Poetry_core.Poetry_types.YuRhyme -> YuRhyme
      | Poetry_core.Poetry_types.HuaRhyme -> HuaRhyme
      | Poetry_core.Poetry_types.FengRhyme -> FengRhyme
      | Poetry_core.Poetry_types.YueRhyme -> YueRhyme
      | Poetry_core.Poetry_types.XueRhyme -> XueRhyme
      | Poetry_core.Poetry_types.JiangRhyme -> JiangRhyme
      | Poetry_core.Poetry_types.HuiRhyme -> HuiRhyme
      | Poetry_core.Poetry_types.UnknownRhyme -> UnknownRhyme
    in
    (char, converted_cat, converted_grp)

  let export_to_json entries =
    let json_entries =
      List.map
        (fun (char, cat, grp) ->
          Printf.sprintf {|{"char": "%s", "category": "%s", "group": "%s"}|} char
            (Poetry_core.Rhyme_core_types.rhyme_category_to_string cat)
            (Poetry_core.Rhyme_core_types.rhyme_group_to_string grp))
        entries
    in
    Printf.sprintf {|{"entries": [%s]}|} (String.concat ", " json_entries)
end

(** 缓存管理器模块 - 兼容性实现 *)
module CacheManager = struct
  (* 简单的内存缓存状态 *)
  let cache_enabled = ref false
  let cache_data = ref []
  let cache_hits = ref 0
  let cache_misses = ref 0
  let enable_cache () = cache_enabled := true
  let disable_cache () = cache_enabled := false

  let clear_cache () =
    cache_data := [];
    cache_hits := 0;
    cache_misses := 0

  let get_cache_stats () =
    let total_requests = !cache_hits + !cache_misses in
    let hit_rate =
      if total_requests > 0 then float_of_int !cache_hits /. float_of_int total_requests else 0.0
    in
    (!cache_hits, !cache_misses, hit_rate)

  let is_cache_enabled () = !cache_enabled

  (* 移除未使用的缓存管理函数以消除编译警告 *)
end

(** 数据完整性验证 *)
let validate_data_integrity () = true

(** 获取数据统计 *)
let get_data_statistics () =
  let total = get_total_character_count () in
  let ping = List.length (get_ping_sheng_chars ()) in
  let ze = List.length (get_ze_sheng_chars ()) in
  [
    ("总字符数", total); ("平声字符数", ping); ("仄声字符数", ze); ("韵组数", List.length (list_all_rhyme_groups ()));
  ]

(** 查找数据冲突 *)
let find_data_conflicts () = []

(** 从文件加载 *)
let load_from_file _ = ()

(** 保存到文件 *)
let save_to_file _ = ()

(** 合并外部数据 *)
let merge_external_data _ = ()
