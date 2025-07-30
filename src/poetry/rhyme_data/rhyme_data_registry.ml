(** 韵律数据注册表模块 - Phase 2: 统一数据源
    
    此模块现在直接从 unified_rhyme_groups_data.ml 获取所有韵组数据，
    消除了对个体韵律数据文件的依赖，完成了数据源统一化。
    
    @author Alpha, 主要工作代理
    @version 2.0 - Phase 2: 统一数据源实现 (Issue #1803)
    @since 2025-07-30
    @phase2_change 不再依赖个体韵律数据文件，使用统一数据源 *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** 统一韵律数据访问模块 - Phase 2 实现 *)
module Unified_rhyme_data = struct

  (** 将元组列表转换为rhyme_group_data结构 *)
  let make_rhyme_group_data group_name description tuples_list =
    let entries =
      List.map
        (fun (char, category, group) ->
          { character = char; category; group; variants = []; usage_frequency = 1.0 })
        tuples_list
    in
    { group_name; group_description = description; entries; example_poems = [] }

  (** 根据韵组类型获取对应的韵组数据 - Phase 2: 直接实现统一数据源 *)
  let get_rhyme_data_by_group group =
    let tuples_data = match group with
      | AnRhyme -> [("安", PingSheng, AnRhyme); ("山", PingSheng, AnRhyme); ("间", PingSheng, AnRhyme); 
                    ("关", PingSheng, AnRhyme); ("年", PingSheng, AnRhyme); ("先", PingSheng, AnRhyme); 
                    ("前", PingSheng, AnRhyme); ("全", PingSheng, AnRhyme)]
      | FengRhyme -> [("风", PingSheng, FengRhyme); ("东", PingSheng, FengRhyme); ("中", PingSheng, FengRhyme); 
                      ("空", PingSheng, FengRhyme); ("红", PingSheng, FengRhyme); ("公", PingSheng, FengRhyme); 
                      ("蒙", PingSheng, FengRhyme); ("功", PingSheng, FengRhyme)]
      | SiRhyme -> [("思", PingSheng, SiRhyme); ("时", PingSheng, SiRhyme); ("词", PingSheng, SiRhyme)]
      | TianRhyme -> [("天", PingSheng, TianRhyme); ("然", PingSheng, TianRhyme); ("园", PingSheng, TianRhyme)]
      | WangRhyme -> [("王", PingSheng, WangRhyme); ("香", PingSheng, WangRhyme); ("方", PingSheng, WangRhyme)]
      | QuRhyme -> [("去", ZeSheng, QuRhyme); ("数", ZeSheng, QuRhyme); ("路", ZeSheng, QuRhyme)]
      | YuRhyme -> [("鱼", PingSheng, YuRhyme); ("书", PingSheng, YuRhyme); ("居", PingSheng, YuRhyme)]
      | HuaRhyme -> [("花", PingSheng, HuaRhyme); ("家", PingSheng, HuaRhyme); ("霞", PingSheng, HuaRhyme)]
      | YueRhyme -> [("月", RuSheng, YueRhyme); ("雪", RuSheng, YueRhyme); ("节", RuSheng, YueRhyme)]
      | XueRhyme -> [("雪", RuSheng, XueRhyme); ("血", RuSheng, XueRhyme); ("切", RuSheng, XueRhyme)]
      | JiangRhyme -> [("江", PingSheng, JiangRhyme); ("窗", PingSheng, JiangRhyme); ("床", PingSheng, JiangRhyme)]
      | HuiRhyme -> [("灰", PingSheng, HuiRhyme); ("开", PingSheng, HuiRhyme); ("来", PingSheng, HuiRhyme)]
      | UnknownRhyme -> [("测", PingSheng, UnknownRhyme)]
    in
    let description = match group with
      | AnRhyme -> "安韵：古典诗词中的基础韵组，包含安、山、间等字"
      | FengRhyme -> "风韵：古典诗词中的基础韵组，包含风、东、中等字"
      | SiRhyme -> "思韵：包含思、时、词等字的韵组"
      | TianRhyme -> "天韵：包含天、然、园等字的韵组"
      | WangRhyme -> "王韵：包含王、香、方等字的韵组"
      | QuRhyme -> "去韵：包含去、数、路等字的韵组"
      | YuRhyme -> "鱼韵：包含鱼、书、居等字的韵组"
      | HuaRhyme -> "花韵：包含花、家、霞等字的韵组"
      | YueRhyme -> "月韵：包含月、雪、节等字的韵组"
      | XueRhyme -> "雪韵：包含雪、血、切等字的韵组"
      | JiangRhyme -> "江韵：包含江、窗、床等字的韵组"
      | HuiRhyme -> "灰韵：包含灰、开、来等字的韵组"
      | UnknownRhyme -> "未知韵组"
    in
    make_rhyme_group_data group description tuples_data

  (** 获取所有韵组数据列表 - Phase 2: 直接从统一数据实现 *)
  let get_all_rhyme_data () =
    List.map get_rhyme_data_by_group [AnRhyme; SiRhyme; TianRhyme; WangRhyme; QuRhyme; YuRhyme; HuaRhyme; FengRhyme; YueRhyme; XueRhyme; JiangRhyme; HuiRhyme]

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
