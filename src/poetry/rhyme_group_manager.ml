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
open Rhyme_data_builder

(** {1 韵组数据处理} *)

(** 扁平化的所有韵律数据条目 - 内部使用延迟初始化优化性能 *)
let all_rhyme_entries_lazy =
  lazy
    (List.fold_left
       (fun acc group_data -> List.rev_append group_data.entries acc)
       [] all_rhyme_groups
    |> List.rev)

(** 扁平化的所有韵律数据条目 - 对外接口保持兼容性 *)
let all_rhyme_entries = Lazy.force all_rhyme_entries_lazy

(** 韵组查询哈希表 - 优化韵组查找性能 *)
let group_lookup_table =
  lazy
    (let table = Hashtbl.create 64 in
     List.iter
       (fun group_data -> Hashtbl.add table group_data.group_name group_data)
       all_rhyme_groups;
     table)

(** {2 韵组操作接口} *)

(** 根据韵组获取所有数据 - 优化为O(1)哈希查询 *)
let get_rhyme_group_data group = Hashtbl.find_opt (Lazy.force group_lookup_table) group

(** 根据韵类获取所有字符 *)
let get_chars_by_category category =
  List.filter_map
    (fun entry -> if entry.category = category then Some entry.character else None)
    (Lazy.force all_rhyme_entries_lazy)

(** 根据韵组获取所有字符 *)
let get_chars_by_group group =
  List.filter_map
    (fun entry -> if entry.group = group then Some entry.character else None)
    (Lazy.force all_rhyme_entries_lazy)

(** 获取统计信息 - 缓存统计结果以提升性能 *)
let get_statistics =
  let cached_stats = ref None in
  fun () ->
    match !cached_stats with
    | Some stats -> stats
    | None ->
        let all_entries = Lazy.force all_rhyme_entries_lazy in
        let total_entries = List.length all_entries in
        let total_groups = List.length all_rhyme_groups in
        let ping_sheng_count = List.length (get_chars_by_category PingSheng) in
        let ze_sheng_count = List.length (get_chars_by_category ZeSheng) in
        let stats =
          Printf.sprintf "韵律数据统计: 总计 %d 个字符，%d 个韵组，平声 %d 字，仄声 %d 字" total_entries total_groups
            ping_sheng_count ze_sheng_count
        in
        cached_stats := Some stats;
        stats

(** {3 向后兼容性接口} *)

(** 获取所有韵组列表 *)
let get_all_groups () = all_rhyme_groups

(** 获取所有数据条目 *)
let get_all_entries () = Lazy.force all_rhyme_entries_lazy

(** 获取所有韵组名称列表 *)
let get_all_rhyme_groups () = List.map (fun group_data -> group_data.group_name) all_rhyme_groups

(** 为保持兼容性而提供的遗留接口函数 *)
let get_legacy_rhyme_data () = Lazy.force all_rhyme_entries_lazy