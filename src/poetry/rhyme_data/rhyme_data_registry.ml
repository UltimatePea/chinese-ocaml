(** 韵律数据注册表模块 - Phase 1: 整合数据源
    
    此模块现在使用整合后的韵组数据模块，消除了对个体韵律数据文件的依赖，
    实现了Poetry模块整合Phase 1的目标。
    
    原个体模块整合:
    - tian_rhyme_data.ml, yue_rhyme_data.ml, feng_rhyme_data.ml, hua_rhyme_data.ml → consolidated_rhyme_data_group1.ml
    - qu_rhyme_data.ml, wang_rhyme_data.ml, hui_rhyme_data.ml, si_rhyme_data.ml → consolidated_rhyme_data_group2.ml  
    - yu_rhyme_data.ml, jiang_rhyme_data.ml, an_rhyme_data.ml → consolidated_rhyme_data_group3.ml
    
    @author Whisky, Technical Implementation Agent
    @version 3.0 - Phase 1: 整合数据源实现 (Phase 1: 194→170)
    @since 2025-07-31
    @consolidation_change 使用3个整合后的韵组数据模块替代11个个体模块 *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(* 导入整合后的韵组数据模块 *)
module Group1 = Consolidated_rhyme_data_group1
module Group2 = Consolidated_rhyme_data_group2  
module Group3 = Consolidated_rhyme_data_group3

(** 结构化韵律数据定义 - 分离数据与逻辑 *)
module Rhyme_data_definitions = struct
  (** 韵组数据记录类型 *)
  type rhyme_group_def = {
    group : rhyme_group;
    description : string;
    characters : (string * rhyme_category) list;
  }

  (** 标准化韵组数据定义 - 基于《平水韵》标准 *)
  let rhyme_group_definitions = [
    { group = AnRhyme; description = "安韵：古典诗词中的基础韵组，包含安、山、间等字";
      characters = [("安", PingSheng); ("山", PingSheng); ("间", PingSheng); 
                    ("关", PingSheng); ("年", PingSheng); ("先", PingSheng); 
                    ("前", PingSheng); ("全", PingSheng)] };
    { group = FengRhyme; description = "风韵：古典诗词中的基础韵组，包含风、东、中等字";
      characters = [("风", PingSheng); ("东", PingSheng); ("中", PingSheng); 
                    ("空", PingSheng); ("红", PingSheng); ("公", PingSheng); 
                    ("蒙", PingSheng); ("功", PingSheng)] };
    { group = SiRhyme; description = "思韵：包含思、时、词等字的韵组";
      characters = [("思", PingSheng); ("时", PingSheng); ("词", PingSheng)] };
    { group = TianRhyme; description = "天韵：包含天、然、园等字的韵组";
      characters = [("天", PingSheng); ("然", PingSheng); ("园", PingSheng)] };
    { group = WangRhyme; description = "王韵：包含王、香、方等字的韵组";
      characters = [("王", PingSheng); ("香", PingSheng); ("方", PingSheng)] };
    { group = QuRhyme; description = "去韵：包含去、数、路等字的韵组";
      characters = [("去", ZeSheng); ("数", ZeSheng); ("路", ZeSheng)] };
    { group = YuRhyme; description = "鱼韵：包含鱼、书、居等字的韵组";
      characters = [("鱼", PingSheng); ("书", PingSheng); ("居", PingSheng)] };
    { group = HuaRhyme; description = "花韵：包含花、家、霞等字的韵组";
      characters = [("花", PingSheng); ("家", PingSheng); ("霞", PingSheng)] };
    { group = YueRhyme; description = "月韵：包含月、雪、节等字的韵组";
      characters = [("月", RuSheng); ("雪", RuSheng); ("节", RuSheng)] };
    { group = XueRhyme; description = "雪韵：包含血、切、别等字的韵组";
      characters = [("血", RuSheng); ("切", RuSheng); ("别", RuSheng)] };
    { group = JiangRhyme; description = "江韵：包含江、窗、床等字的韵组";
      characters = [("江", PingSheng); ("窗", PingSheng); ("床", PingSheng)] };
    { group = HuiRhyme; description = "灰韵：包含灰、开、来等字的韵组";
      characters = [("灰", PingSheng); ("开", PingSheng); ("来", PingSheng)] };
    { group = UnknownRhyme; description = "未知韵组";
      characters = [("测", PingSheng)] };
  ]

  (** 根据韵组查找定义 *)
  let find_rhyme_group_def group =
    List.find_opt (fun def -> def.group = group) rhyme_group_definitions
end

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

  (** 根据韵组类型获取对应的韵组数据 - 使用结构化数据定义 *)
  let get_rhyme_data_by_group group =
    match Rhyme_data_definitions.find_rhyme_group_def group with
    | Some def ->
        let tuples_data = List.map (fun (char, category) -> (char, category, group)) def.characters in
        make_rhyme_group_data group def.description tuples_data
    | None ->
        (* 兜底处理：返回空韵组 *)
        make_rhyme_group_data group "未知韵组" []

  (** 获取所有韵组数据列表 - Phase 1: 从整合的数据模块获取 *)
  let get_all_rhyme_data () =
    Group1.get_all_consolidated_rhyme_groups_1 () @
    Group2.get_all_consolidated_rhyme_groups_2 () @
    Group3.get_all_consolidated_rhyme_groups_3 ()

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

  (** 数据验证：检查字符重复和一致性 *)
  let validate_rhyme_data () =
    let all_groups = get_all_rhyme_data () in
    let all_chars = ref [] in
    let duplicates = ref [] in
    let issues = ref [] in
    
    (* 收集所有字符并检查重复 *)
    List.iter (fun group ->
      List.iter (fun entry ->
        let char = entry.character in
        if List.mem char !all_chars then (
          duplicates := char :: !duplicates;
          issues := (Printf.sprintf "字符重复: '%s' 出现在多个韵组中" char) :: !issues
        ) else (
          all_chars := char :: !all_chars
        )
      ) group.entries
    ) all_groups;
    
    (* 检查韵组完整性 *)
    List.iter (fun group ->
      if List.length group.entries = 0 then
        issues := (Printf.sprintf "韵组 %s 为空" group.group_description) :: !issues
    ) all_groups;
    
    let is_valid = List.length !issues = 0 in
    (is_valid, List.rev !issues, List.sort_uniq String.compare !duplicates)

  (** 运行数据验证并打印结果 *)
  let check_data_integrity () =
    let (is_valid, issues, duplicates) = validate_rhyme_data () in
    if is_valid then
      Printf.printf "✓ 韵律数据验证通过：无重复或错误\n"
    else (
      Printf.printf "✗ 韵律数据验证失败：\n";
      List.iter (fun issue -> Printf.printf "  - %s\n" issue) issues;
      if List.length duplicates > 0 then (
        Printf.printf "重复字符: [%s]\n" (String.concat "; " duplicates)
      )
    );
    is_valid
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

(* 数据验证函数 *)
let validate_rhyme_data = Unified_rhyme_data.validate_rhyme_data
let check_data_integrity = Unified_rhyme_data.check_data_integrity
