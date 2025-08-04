(** 韵组管理器 - 从rhyme_core_unified.ml重构提取

    此模块包含韵组数据处理、统计分析和管理功能。

    重构目标:
    - 分离数据管理逻辑以降低主文件复杂度
    - 提供韵组操作的专门接口
    - 优化数据访问和统计性能

    Author: Alpha, 主要工作代理
    @version 1.0 - 重构提取版本
    @since 2025-07-28 - 基于Issue #1585的科学技术债务重构计划 *)

open Rhyme_core_types
(* open Rhyme_data_builder  -- 🔧 已移除(Issue #1999): 使用整合后的 Consolidated_rhyme_data 模块 *)
open Consolidated_rhyme_data

(** {1 韵组数据处理} *)

(** 类型转换函数 - 将consolidated_rhyme_entry转换为rhyme_data_entry *)
let convert_to_rhyme_data_entry entry =
  { Rhyme_core_types.character = entry.Consolidated_rhyme_data.character;
    category = entry.category;
    group = entry.group;
    variants = [];  (* 简化处理 *)
    usage_frequency = 1.0  (* 默认频率 *)
  }

(** 扁平化的所有韵律数据条目 - 使用整合后的数据源 *)
let all_rhyme_entries_lazy =
  lazy (List.map convert_to_rhyme_data_entry (get_all_rhyme_data ()))

(** 扁平化的所有韵律数据条目 - 对外接口保持兼容性 *)
let all_rhyme_entries = Lazy.force all_rhyme_entries_lazy

(* 韵组查询哈希表已移除 - 直接使用Consolidated_rhyme_data的O(1)查询 *)

(** {2 韵组操作接口} *)

(** 根据韵组获取所有数据 - 使用整合后的API *)
let get_rhyme_group_data group = 
  let entries = get_entries_by_group group in
  if entries = [] then None 
  else 
    let converted_entries = List.map convert_to_rhyme_data_entry entries in
    let group_data = {
      Rhyme_core_types.group_name = group;
      group_description = Printf.sprintf "%s韵组" (match group with 
        | AnRhyme -> "安韵" | SiRhyme -> "思韵" | TianRhyme -> "天韵" 
        | WangRhyme -> "王韵" | QuRhyme -> "去韵" | YuRhyme -> "鱼韵"
        | HuaRhyme -> "花韵" | FengRhyme -> "风韵" | YueRhyme -> "月韵"
        | XueRhyme -> "雪韵" | JiangRhyme -> "江韵" | HuiRhyme -> "灰韵"
        | UnknownRhyme -> "未知韵");
      entries = converted_entries;
      example_poems = [];  (* 简化处理 *)
    } in
    Some group_data

(** 根据韵类获取所有字符 *)
let get_chars_by_category category =
  let entries : Rhyme_core_types.rhyme_data_entry list = Lazy.force all_rhyme_entries_lazy in
  List.filter_map
    (fun (entry : Rhyme_core_types.rhyme_data_entry) -> 
      if entry.category = category then Some entry.character else None)
    entries

(** 根据韵组获取所有字符 *)
let get_chars_by_group group =
  let entries : Rhyme_core_types.rhyme_data_entry list = Lazy.force all_rhyme_entries_lazy in
  List.filter_map
    (fun (entry : Rhyme_core_types.rhyme_data_entry) -> 
      if entry.group = group then Some entry.character else None)
    entries

(** 获取统计信息 - 缓存统计结果以提升性能 *)
let get_statistics =
  let cached_stats = ref None in
  fun () ->
    match !cached_stats with
    | Some stats -> stats
    | None ->
        let all_entries = Lazy.force all_rhyme_entries_lazy in
        let total_entries = List.length all_entries in
        let all_groups = get_all_rhyme_groups () in
        let total_groups = List.length all_groups in
        let ping_sheng_count = List.length (get_chars_by_category PingSheng) in
        let ze_sheng_count = List.length (get_chars_by_category ZeSheng) in
        let stats =
          Printf.sprintf "韵律数据统计: 总计 %d 个字符，%d 个韵组，平声 %d 字，仄声 %d 字" total_entries total_groups
            ping_sheng_count ze_sheng_count
        in
        cached_stats := Some stats;
        stats

(** {3 向后兼容性接口} *)

(** 获取所有韵组列表 - 使用整合后的API返回rhyme_group_data列表*)
let get_all_groups () = 
  let groups = get_all_rhyme_groups () in
  List.map (fun (group, _category) ->
    match get_rhyme_group_data group with
    | Some group_data -> group_data
    | None -> {
        Rhyme_core_types.group_name = group;
        group_description = Printf.sprintf "%s韵组" (match group with 
          | UnknownRhyme -> "未知韵" | _ -> "韵组");
        entries = [];
        example_poems = [];
      }
  ) groups

(** 获取所有数据条目 *)
let get_all_entries () = Lazy.force all_rhyme_entries_lazy

(** 获取所有韵组名称列表 - 使用整合后的API *)
let get_all_rhyme_groups () = 
  let groups = Consolidated_rhyme_data.get_all_rhyme_groups () in
  List.map fst groups  (* 返回韵组名称列表 *)

(** 为保持兼容性而提供的遗留接口函数 *)
let get_legacy_rhyme_data () = Lazy.force all_rhyme_entries_lazy
