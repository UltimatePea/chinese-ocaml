(** 韵律数据统一注册中心
    
    此模块提供统一的韵组数据注册和访问接口，从rhyme_data_builder.ml重构提取。
    目标是提供清晰的模块化接口，同时保持完全的向后兼容性。
    
    Author: Alpha, 主要工作代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-28 - Fix #1588 韵律数据构建器模块化重构计划 *)

open Rhyme_core_types

(** {1 韵组数据统一集合} *)

(** 所有韵组数据的统一集合 - 从各个模块汇总 *)
let all_rhyme_groups =
  [
    (* 从 rhyme_groups_1_5.ml 导入前5个韵组 *)
    Rhyme_groups_1_5.an_rhyme_data;
    Rhyme_groups_1_5.si_rhyme_data;
    Rhyme_groups_1_5.tian_rhyme_data;
    Rhyme_groups_1_5.wang_rhyme_data;
    Rhyme_groups_1_5.qu_rhyme_data;
    
    (* 从 rhyme_groups_6_10.ml 导入第6-10个韵组 *)
    Rhyme_groups_6_10.yu_rhyme_data;
    Rhyme_groups_6_10.hua_rhyme_data;
    Rhyme_groups_6_10.feng_rhyme_data;
    Rhyme_groups_6_10.yue_rhyme_data;
    Rhyme_groups_6_10.jiang_rhyme_data;
    
    (* 从 rhyme_groups_11.ml 导入第11个韵组 *)
    Rhyme_groups_11.hui_rhyme_data;
  ]

(** {2 辅助查询函数} *)

(** 根据字符查找韵律信息 *)
let get_rhyme_by_char char =
  let rec search_in_groups = function
    | [] -> None
    | group :: rest ->
        let rec search_in_entries = function
          | [] -> search_in_groups rest
          | entry :: entries ->
              if entry.character = char then
                Some (entry.category, entry.group)
              else
                search_in_entries entries
        in
        search_in_entries group.entries
  in
  search_in_groups all_rhyme_groups

(** 获取指定韵组的所有字符 *)
let get_chars_by_rhyme_group group =
  let rec find_group = function
    | [] -> []
    | rhyme_group :: rest ->
        if rhyme_group.group_name = group then
          List.map (fun entry -> entry.character) rhyme_group.entries
        else
          find_group rest
  in
  find_group all_rhyme_groups

(** 获取韵组数量统计 *)
let get_rhyme_group_count () = List.length all_rhyme_groups

(** 获取总字符数量统计 *)
let get_total_character_count () =
  List.fold_left (fun acc group ->
    acc + List.length group.entries
  ) 0 all_rhyme_groups