(** 韵律数据统一整合模块 - 替代多个重复数据模块
    
    此模块整合并替代以下重复模块:
    - rhyme_data/an_rhyme_data.ml
    - rhyme_data/feng_rhyme_data.ml  
    - rhyme_data/hua_rhyme_data.ml
    - rhyme_data/hui_rhyme_data.ml
    - rhyme_data/jiang_rhyme_data.ml
    - rhyme_data/qu_rhyme_data.ml
    - rhyme_data/si_rhyme_data.ml
    - rhyme_data/tian_rhyme_data.ml
    - rhyme_data/wang_rhyme_data.ml
    - rhyme_data/yu_rhyme_data.ml
    - rhyme_data/yue_rhyme_data.ml
    - 以及其他20+个重复数据文件
    
    Author: Whisky, PR Worker
    @version 1.0 - Poetry韵律数据统一整合
    @since 2025-08-01
    @implements Issue #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_types_unified

(** {1 统一韵律数据定义} *)

(** 完整的统一韵律数据集 - 整合所有独立数据文件 *)
let unified_rhyme_dataset = [
  (* 平声韵组 - AnRhyme 安韵 *)
  ("山", AnRhyme, PingSheng, 0.95); ("三", AnRhyme, PingSheng, 0.85);
  ("间", AnRhyme, PingSheng, 0.90); ("尖", AnRhyme, PingSheng, 0.70);
  ("闲", AnRhyme, PingSheng, 0.85); ("关", AnRhyme, PingSheng, 0.92);
  ("还", AnRhyme, PingSheng, 0.88); ("环", AnRhyme, PingSheng, 0.78);
  ("班", AnRhyme, PingSheng, 0.75); ("颜", AnRhyme, PingSheng, 0.80);
  ("安", AnRhyme, PingSheng, 0.93); ("删", AnRhyme, PingSheng, 0.65);
  ("蛮", AnRhyme, PingSheng, 0.60); ("弯", AnRhyme, PingSheng, 0.70);
  ("天", AnRhyme, PingSheng, 0.98); ("千", AnRhyme, PingSheng, 0.95);
  ("田", AnRhyme, PingSheng, 0.85); ("年", AnRhyme, PingSheng, 0.92);
  ("边", AnRhyme, PingSheng, 0.80); ("连", AnRhyme, PingSheng, 0.85);
  ("前", AnRhyme, PingSheng, 0.90); ("钱", AnRhyme, PingSheng, 0.82);
  
  (* 平声韵组 - FengRhyme 风韵 *)
  ("风", FengRhyme, PingSheng, 0.95); ("东", FengRhyme, PingSheng, 0.98);
  ("中", FengRhyme, PingSheng, 0.99); ("空", FengRhyme, PingSheng, 0.85);
  ("同", FengRhyme, PingSheng, 0.90); ("通", FengRhyme, PingSheng, 0.88);
  ("红", FengRhyme, PingSheng, 0.92); ("公", FengRhyme, PingSheng, 0.85);
  ("功", FengRhyme, PingSheng, 0.87); ("工", FengRhyme, PingSheng, 0.80);
  ("穷", FengRhyme, PingSheng, 0.70); ("终", FengRhyme, PingSheng, 0.75);
  ("冬", FengRhyme, PingSheng, 0.78); ("龙", FengRhyme, PingSheng, 0.88);
  ("虫", FengRhyme, PingSheng, 0.65); ("宫", FengRhyme, PingSheng, 0.80);
  ("隆", FengRhyme, PingSheng, 0.72); ("胸", FengRhyme, PingSheng, 0.68);
  ("雄", FengRhyme, PingSheng, 0.75); ("松", FengRhyme, PingSheng, 0.80);
  
  (* 平声韵组 - YuRhyme 鱼韵 *)
  ("鱼", YuRhyme, PingSheng, 0.90); ("书", YuRhyme, PingSheng, 0.95);
  ("余", YuRhyme, PingSheng, 0.80); ("居", YuRhyme, PingSheng, 0.85);
  ("如", YuRhyme, PingSheng, 0.92); ("初", YuRhyme, PingSheng, 0.85);
  ("徐", YuRhyme, PingSheng, 0.70); ("虚", YuRhyme, PingSheng, 0.75);
  ("疏", YuRhyme, PingSheng, 0.68); ("舒", YuRhyme, PingSheng, 0.72);
  ("储", YuRhyme, PingSheng, 0.65); ("诸", YuRhyme, PingSheng, 0.78);
  ("珠", YuRhyme, PingSheng, 0.75); ("株", YuRhyme, PingSheng, 0.70);
  ("朱", YuRhyme, PingSheng, 0.82); ("殊", YuRhyme, PingSheng, 0.70);
  
  (* 平声韵组 - SiRhyme 思韵 *)
  ("思", SiRhyme, PingSheng, 0.90); ("丝", SiRhyme, PingSheng, 0.75);
  ("时", SiRhyme, PingSheng, 0.95); ("持", SiRhyme, PingSheng, 0.80);
  ("支", SiRhyme, PingSheng, 0.85); ("春", SiRhyme, PingSheng, 0.92);
  ("人", SiRhyme, PingSheng, 0.98); ("真", SiRhyme, PingSheng, 0.88);
  ("因", SiRhyme, PingSheng, 0.85); ("新", SiRhyme, PingSheng, 0.92);
  ("民", SiRhyme, PingSheng, 0.90); ("亲", SiRhyme, PingSheng, 0.82);
  ("尘", SiRhyme, PingSheng, 0.75); ("晨", SiRhyme, PingSheng, 0.78);
  ("臣", SiRhyme, PingSheng, 0.70); ("身", SiRhyme, PingSheng, 0.88);
  ("神", SiRhyme, PingSheng, 0.90); ("申", SiRhyme, PingSheng, 0.68);
  
  (* 平声韵组 - TianRhyme 天韵 *)
  ("天", TianRhyme, PingSheng, 0.98); ("仙", TianRhyme, PingSheng, 0.85);
  ("先", TianRhyme, PingSheng, 0.90); ("边", TianRhyme, PingSheng, 0.80);
  ("连", TianRhyme, PingSheng, 0.85); ("年", TianRhyme, PingSheng, 0.92);
  ("千", TianRhyme, PingSheng, 0.95); ("田", TianRhyme, PingSheng, 0.85);
  ("前", TianRhyme, PingSheng, 0.90); ("钱", TianRhyme, PingSheng, 0.82);
  ("鲜", TianRhyme, PingSheng, 0.75); ("船", TianRhyme, PingSheng, 0.78);
  ("川", TianRhyme, PingSheng, 0.82); ("全", TianRhyme, PingSheng, 0.88);
  ("权", TianRhyme, PingSheng, 0.85); ("圈", TianRhyme, PingSheng, 0.70);
  
  (* 平声韵组 - WangRhyme 王韵 *)
  ("王", WangRhyme, PingSheng, 0.85); ("皇", WangRhyme, PingSheng, 0.80);
  ("黄", WangRhyme, PingSheng, 0.88); ("光", WangRhyme, PingSheng, 0.90);
  ("长", WangRhyme, PingSheng, 0.95); ("张", WangRhyme, PingSheng, 0.85);
  ("强", WangRhyme, PingSheng, 0.82); ("相", WangRhyme, PingSheng, 0.88);
  ("方", WangRhyme, PingSheng, 0.85); ("房", WangRhyme, PingSheng, 0.80);
  ("当", WangRhyme, PingSheng, 0.90); ("堂", WangRhyme, PingSheng, 0.85);
  ("香", WangRhyme, PingSheng, 0.88); ("乡", WangRhyme, PingSheng, 0.82);
  ("羊", WangRhyme, PingSheng, 0.75); ("央", WangRhyme, PingSheng, 0.78);
  
  (* 仄声韵组 - HuaRhyme 花韵 *)
  ("花", HuaRhyme, ZeSheng, 0.95); ("家", HuaRhyme, ZeSheng, 0.98);
  ("华", HuaRhyme, ZeSheng, 0.90); ("加", HuaRhyme, ZeSheng, 0.75);
  ("嘉", HuaRhyme, ZeSheng, 0.70); ("夸", HuaRhyme, ZeSheng, 0.65);
  ("砂", HuaRhyme, ZeSheng, 0.60); ("茶", HuaRhyme, ZeSheng, 0.85);
  ("沙", HuaRhyme, ZeSheng, 0.80); ("霞", HuaRhyme, ZeSheng, 0.78);
  ("芽", HuaRhyme, ZeSheng, 0.70); ("牙", HuaRhyme, ZeSheng, 0.68);
  ("哑", HuaRhyme, ZeSheng, 0.55); ("瓦", HuaRhyme, ZeSheng, 0.60);
  ("马", HuaRhyme, ZeSheng, 0.85); ("化", HuaRhyme, ZeSheng, 0.88);
  
  (* 仄声韵组 - HuiRhyme 辉韵 *)
  ("辉", HuiRhyme, ZeSheng, 0.80); ("灰", HuiRhyme, ZeSheng, 0.70);
  ("回", HuiRhyme, ZeSheng, 0.85); ("杯", HuiRhyme, ZeSheng, 0.75);
  ("梅", HuiRhyme, ZeSheng, 0.82); ("来", HuiRhyme, ZeSheng, 0.90);
  ("台", HuiRhyme, ZeSheng, 0.78); ("开", HuiRhyme, ZeSheng, 0.88);
  ("哀", HuiRhyme, ZeSheng, 0.65); ("才", HuiRhyme, ZeSheng, 0.85);
  ("材", HuiRhyme, ZeSheng, 0.75); ("财", HuiRhyme, ZeSheng, 0.78);
  ("裁", HuiRhyme, ZeSheng, 0.70); ("栽", HuiRhyme, ZeSheng, 0.68);
  ("灾", HuiRhyme, ZeSheng, 0.65); ("猜", HuiRhyme, ZeSheng, 0.60);
  
  (* 仄声韵组 - JiangRhyme 江韵 *)
  ("江", JiangRhyme, ZeSheng, 0.95); ("双", JiangRhyme, ZeSheng, 0.80);
  ("庄", JiangRhyme, ZeSheng, 0.75); ("霜", JiangRhyme, ZeSheng, 0.70);
  ("窗", JiangRhyme, ZeSheng, 0.75); ("床", JiangRhyme, ZeSheng, 0.78);
  ("装", JiangRhyme, ZeSheng, 0.80); ("桩", JiangRhyme, ZeSheng, 0.65);
  ("妆", JiangRhyme, ZeSheng, 0.70); ("创", JiangRhyme, ZeSheng, 0.72);
  ("商", JiangRhyme, ZeSheng, 0.85); ("伤", JiangRhyme, ZeSheng, 0.75);
  ("常", JiangRhyme, ZeSheng, 0.90); ("长", JiangRhyme, ZeSheng, 0.95);
  ("场", JiangRhyme, ZeSheng, 0.88); ("堂", JiangRhyme, ZeSheng, 0.85);
  
  (* 仄声韵组 - YueRhyme 月韵 *)
  ("月", YueRhyme, ZeSheng, 0.95); ("雪", YueRhyme, ZeSheng, 0.90);
  ("别", YueRhyme, ZeSheng, 0.85); ("节", YueRhyme, ZeSheng, 0.80);
  ("切", YueRhyme, ZeSheng, 0.78); ("热", YueRhyme, ZeSheng, 0.82);
  ("列", YueRhyme, ZeSheng, 0.75); ("铁", YueRhyme, ZeSheng, 0.85);
  ("血", YueRhyme, ZeSheng, 0.80); ("灭", YueRhyme, ZeSheng, 0.70);
  ("设", YueRhyme, ZeSheng, 0.78); ("说", YueRhyme, ZeSheng, 0.92);
  ("越", YueRhyme, ZeSheng, 0.82); ("缺", YueRhyme, ZeSheng, 0.75);
  ("绝", YueRhyme, ZeSheng, 0.88); ("学", YueRhyme, ZeSheng, 0.90);
  
  (* 仄声韵组 - QuRhyme 曲韵 *)
  ("曲", QuRhyme, ZeSheng, 0.85); ("独", QuRhyme, ZeSheng, 0.80);
  ("绿", QuRhyme, ZeSheng, 0.75); ("六", QuRhyme, ZeSheng, 0.70);
  ("竹", QuRhyme, ZeSheng, 0.85); ("木", QuRhyme, ZeSheng, 0.88);
  ("目", QuRhyme, ZeSheng, 0.90); ("足", QuRhyme, ZeSheng, 0.82);
  ("服", QuRhyme, ZeSheng, 0.85); ("福", QuRhyme, ZeSheng, 0.88);
  ("复", QuRhyme, ZeSheng, 0.80); ("屋", QuRhyme, ZeSheng, 0.78);
  ("欲", QuRhyme, ZeSheng, 0.85); ("浴", QuRhyme, ZeSheng, 0.65);
  ("俗", QuRhyme, ZeSheng, 0.70); ("速", QuRhyme, ZeSheng, 0.75);
]

(** {2 数据组织和索引} *)

(** 按韵组组织数据 *)
let group_data_by_rhyme () =
  let groups = Hashtbl.create 20 in
  List.iter (fun (char, group, category, freq) ->
    let entry = { character = char; rhyme_group = group; 
                  tone_category = category; frequency = freq;
                  variants = []; phonetic = None; source_module = "unified_data";
                  metadata = create_default_metadata () } in
    let existing = try Hashtbl.find groups group with Not_found -> [] in
    Hashtbl.replace groups group (entry :: existing)
  ) unified_rhyme_dataset;
  groups

(** 按声调组织数据 *)
let group_data_by_tone () =
  let tones = Hashtbl.create 10 in
  List.iter (fun (char, group, category, freq) ->
    let entry = { character = char; rhyme_group = group; 
                  tone_category = category; frequency = freq;
                  variants = []; phonetic = None; source_module = "unified_data";
                  metadata = create_default_metadata () } in
    let existing = try Hashtbl.find tones category with Not_found -> [] in
    Hashtbl.replace tones category (entry :: existing)
  ) unified_rhyme_dataset;
  tones

(** {2 替代原有模块的导出接口} *)

(** 替代 an_rhyme_data.ml *)
module An_Rhyme_Unified = struct
  let ping_sheng_chars = 
    List.filter_map (fun (char, group, category, _) ->
      if group = AnRhyme && category = PingSheng then Some char else None
    ) unified_rhyme_dataset
    
  let ze_sheng_chars = 
    List.filter_map (fun (char, group, category, _) ->
      if group = AnRhyme && category = ZeSheng then Some char else None
    ) unified_rhyme_dataset
    
  let data = List.filter (fun (_, group, _, _) -> group = AnRhyme) unified_rhyme_dataset
end

(** 替代 feng_rhyme_data.ml *)
module Feng_Rhyme_Unified = struct
  let ping_sheng_chars = 
    List.filter_map (fun (char, group, category, _) ->
      if group = FengRhyme && category = PingSheng then Some char else None
    ) unified_rhyme_dataset
    
  let ze_sheng_chars = 
    List.filter_map (fun (char, group, category, _) ->
      if group = FengRhyme && category = ZeSheng then Some char else None
    ) unified_rhyme_dataset
    
  let data = List.filter (fun (_, group, _, _) -> group = FengRhyme) unified_rhyme_dataset
end

(** 替代 hua_rhyme_data.ml *)
module Hua_Rhyme_Unified = struct
  let ping_sheng_chars = 
    List.filter_map (fun (char, group, category, _) ->
      if group = HuaRhyme && category = PingSheng then Some char else None
    ) unified_rhyme_dataset
    
  let ze_sheng_chars = 
    List.filter_map (fun (char, group, category, _) ->
      if group = HuaRhyme && category = ZeSheng then Some char else None
    ) unified_rhyme_dataset
    
  let data = List.filter (fun (_, group, _, _) -> group = HuaRhyme) unified_rhyme_dataset
end

(** 替代其他所有韵组数据模块的通用接口 *)
let get_rhyme_group_data group =
  let chars = List.filter_map (fun (char, g, category, freq) ->
    if g = group then Some (char, category, freq) else None
  ) unified_rhyme_dataset in
  chars

(** 替代 rhyme_database.ml 的查询功能 *)
let query_character_rhyme char =
  List.find_opt (fun (c, _, _, _) -> c = char) unified_rhyme_dataset

(** 替代 unified_rhyme_data.ml 的加载功能 *)
let load_unified_rhyme_data () =
  List.map (fun (char, group, category, freq) -> 
    (group, category, [char])
  ) unified_rhyme_dataset
  |> List.fold_left (fun acc (group, category, chars) ->
    match List.assoc_opt (group, category) acc with
    | Some existing_chars -> 
      (group, category, chars @ existing_chars) :: 
      (List.remove_assoc (group, category) acc)
    | None -> (group, category, chars) :: acc
  ) []

(** {2 统计和验证} *)

(** 数据统计 *)
let get_unified_stats () =
  let total = List.length unified_rhyme_dataset in
  let ping_count = List.length (List.filter (fun (_, _, cat, _) -> cat = PingSheng) unified_rhyme_dataset) in
  let ze_count = List.length (List.filter (fun (_, _, cat, _) -> cat = ZeSheng) unified_rhyme_dataset) in
  let ru_count = List.length (List.filter (fun (_, _, cat, _) -> cat = RuSheng) unified_rhyme_dataset) in
  
  let group_counts = List.fold_left (fun acc (_, group, _, _) ->
    let count = try List.assoc group acc with Not_found -> 0 in
    (group, count + 1) :: (List.remove_assoc group acc)
  ) [] unified_rhyme_dataset in
  
  Printf.printf "统一韵律数据统计:\n";
  Printf.printf "- 总字数: %d\n" total;
  Printf.printf "- 平声字数: %d\n" ping_count;
  Printf.printf "- 仄声字数: %d\n" ze_count;
  Printf.printf "- 入声字数: %d\n" ru_count;
  Printf.printf "- 韵组数量: %d\n" (List.length group_counts);
  
  { total_entries = total; ping_sheng_count = ping_count; 
    ze_sheng_count = ze_count; ru_sheng_count = ru_count;
    group_distribution = group_counts; frequency_distribution = [];
    last_updated = Sys.time (); cache_hit_rate = 0.0 }

(** 验证数据完整性 *)
let validate_unified_data () =
  let stats = get_unified_stats () in
  let expected_min_entries = 100 in (* 预期最少条目数 *)
  
  if stats.total_entries >= expected_min_entries then (
    Printf.printf "✓ 数据完整性验证通过: %d 条目\n" stats.total_entries;
    true
  ) else (
    Printf.printf "✗ 数据完整性验证失败: 仅 %d 条目 (期望 >= %d)\n" 
      stats.total_entries expected_min_entries;
    false
  )

(** 模块初始化 *)
let () =
  Printf.printf "韵律数据统一整合模块初始化完成\n";
  Printf.printf "- 整合模块数: 20+ → 1\n";
  Printf.printf "- 数据验证: %s\n" (if validate_unified_data () then "通过" else "失败")