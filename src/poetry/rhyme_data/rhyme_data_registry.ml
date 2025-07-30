(** 韵律数据注册表模块 - 统一访问接口
    
    此模块提供统一的韵组数据访问接口，整合所有模块化的韵组数据，
    并保持与原始unified_rhyme_groups_data.ml的向后兼容性。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构
    @since 2025-07-30
    @replaces unified_rhyme_groups_data.ml *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(* 所有韵组数据模块通过直接引用访问 *)
(* open statements removed to avoid unused warnings *)

(** 统一韵律数据访问模块 *)
module Unified_rhyme_data = struct
  
  (** 根据韵组类型获取对应的韵组数据 *)
  let get_rhyme_data_by_group = function
    | AnRhyme -> An_rhyme_data.an_rhyme_data
    | SiRhyme -> Si_rhyme_data.si_rhyme_data
    | TianRhyme -> Tian_rhyme_data.tian_rhyme_data
    | WangRhyme -> Wang_rhyme_data.wang_rhyme_data
    | QuRhyme -> Qu_rhyme_data.qu_rhyme_data
    | YuRhyme -> Yu_rhyme_data.yu_rhyme_data
    | HuaRhyme -> Hua_rhyme_data.hua_rhyme_data
    | FengRhyme -> Feng_rhyme_data.feng_rhyme_data
    | YueRhyme -> Yue_rhyme_data.yue_rhyme_data
    | XueRhyme -> Yue_rhyme_data.yue_rhyme_data (* XueRhyme使用与YueRhyme相同的数据 *)
    | JiangRhyme -> Jiang_rhyme_data.jiang_rhyme_data
    | HuiRhyme -> Hui_rhyme_data.hui_rhyme_data
    | UnknownRhyme ->
        { group_name = UnknownRhyme; group_description = "未知韵组"; entries = []; example_poems = [] }

  (** 获取所有韵组数据列表 *)
  let get_all_rhyme_data () =
    [
      An_rhyme_data.an_rhyme_data;
      Si_rhyme_data.si_rhyme_data;
      Tian_rhyme_data.tian_rhyme_data;
      Wang_rhyme_data.wang_rhyme_data;
      Qu_rhyme_data.qu_rhyme_data;
      Yu_rhyme_data.yu_rhyme_data;
      Hua_rhyme_data.hua_rhyme_data;
      Feng_rhyme_data.feng_rhyme_data;
      Yue_rhyme_data.yue_rhyme_data;
      Jiang_rhyme_data.jiang_rhyme_data;
      Hui_rhyme_data.hui_rhyme_data;
    ]

  (** 获取韵组统计信息 *)
  let get_rhyme_stats () =
    let all_groups = get_all_rhyme_data () in
    let total_entries =
      List.fold_left (fun acc group -> acc + List.length group.entries) 0 all_groups
    in
    let ping_sheng_count =
      List.fold_left
        (fun acc group ->
          acc + List.length (List.filter (fun entry -> entry.category = PingSheng) group.entries))
        0 all_groups
    in
    let ze_sheng_count = total_entries - ping_sheng_count in
    (total_entries, ping_sheng_count, ze_sheng_count)
end

(** {1 向后兼容性接口} *)

(* 重新导出所有数据以保持向后兼容性 *)
let an_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group AnRhyme
let si_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group SiRhyme
let tian_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group TianRhyme
let wang_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group WangRhyme
let qu_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group QuRhyme
let yu_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group YuRhyme
let hua_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group HuaRhyme
let feng_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group FengRhyme
let yue_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group YueRhyme
let jiang_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group JiangRhyme
let hui_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group HuiRhyme

(* 统一访问函数 *)
let get_all_rhyme_data = Unified_rhyme_data.get_all_rhyme_data
let get_rhyme_data_by_group = Unified_rhyme_data.get_rhyme_data_by_group
let get_rhyme_stats = Unified_rhyme_data.get_rhyme_stats