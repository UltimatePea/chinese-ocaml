(** 韵律数据统一注册中心

    此模块提供统一的韵组数据注册和访问接口，从rhyme_data_builder.ml重构提取。 目标是提供清晰的模块化接口，同时保持完全的向后兼容性。

    Author: Alpha, 主要工作代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-28 - Fix #1588 韵律数据构建器模块化重构计划 *)

(* Rhyme_core_types import removed - now using unified data structure *)

(** {1 韵组数据统一集合} *)

(** 所有韵组数据的统一集合 - 使用unified_rhyme_groups_data *)
let all_rhyme_groups = Unified_rhyme_groups_data.get_all_rhyme_data ()

(** {2 辅助查询函数} *)

(** 根据字符查找韵律信息 *)
let get_rhyme_by_char char =
  let rec search_in_tuples = function
    | [] -> None
    | (ch, category, group) :: rest ->
        if ch = char then Some (category, group)
        else search_in_tuples rest
  in
  search_in_tuples all_rhyme_groups

(** 获取指定韵组的所有字符 *)
let get_chars_by_rhyme_group group =
  List.fold_left (fun acc (ch, _, gr) ->
    if gr = group then ch :: acc else acc
  ) [] all_rhyme_groups |> List.rev

(** 获取韵组数量统计 *)
let get_rhyme_group_count () = 
  let unique_groups = List.fold_left (fun acc (_, _, gr) ->
    if List.mem gr acc then acc else gr :: acc
  ) [] all_rhyme_groups in
  List.length unique_groups

(** 获取总字符数量统计 *)
let get_total_character_count () = List.length all_rhyme_groups
