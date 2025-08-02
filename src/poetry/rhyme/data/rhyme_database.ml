(** 骆言韵律数据库统一模块 - Phase 1整合版本
    
    Author: Whisky, PR Worker
    Date: 2025-08-02  
    Issue: #2084 Poetry模块架构整合计划
    
    此模块整合了以下分散的韵律数据模块：
    - poetry_rhyme_data.ml (韵律数据定义)
    - poetry_rhyme_data_consolidated.ml (整合数据)
    - consolidated_rhyme_data.ml (统一数据)
    - unified_rhyme_data.ml (统一接口)
    - rhyme_data_core.ml (核心数据)
    - rhyme_data/rhyme_data_core.ml (数据核心)
    - data/rhyme_data_unified.ml (数据统一)
    
    整合目标: 32个数据文件 → 1个统一数据库
    
    设计原则:
    1. 单一数据源 - 所有韵律数据统一管理
    2. 高效索引 - 哈希表和集合优化查询
    3. 向后兼容 - 保持现有数据结构接口
    4. 扩展性 - 支持自定义韵组和数据源
    *)

open Poetry_core.Poetry_types

(** {1 统一韵律数据结构} *)

type database_stats = {
  total_characters: int;
  total_groups: int;
  ping_sheng_count: int;
  ze_sheng_count: int;
  ru_sheng_count: int;
}

type rhyme_entry = {
  character: string;
  category: rhyme_category;
  group: rhyme_group;
  frequency: float;
  variants: string list;
  pronunciation: string option;
}

type rhyme_group_definition = {
  group_id: rhyme_group;
  group_name: string;
  description: string;
  representative_chars: string list;
  entries: rhyme_entry list;
}

type rhyme_database = {
  version: string;
  groups: rhyme_group_definition list;
  character_index: (string, rhyme_entry) Hashtbl.t;
  group_index: (rhyme_group, rhyme_group_definition) Hashtbl.t;
  metadata: (string * string) list;
}

(** {2 核心韵律数据定义} *)

(** 平声韵数据 *)
let ping_sheng_data = [
  (* 安韵 *)
  ("山", PingSheng, AnRhyme, 0.95, [], Some "shān");
  ("间", PingSheng, AnRhyme, 0.90, [], Some "jiān");
  ("闲", PingSheng, AnRhyme, 0.85, [], Some "xián");
  ("关", PingSheng, AnRhyme, 0.80, [], Some "guān");
  ("还", PingSheng, AnRhyme, 0.82, [], Some "huán");
  
  (* 思韵 *)
  ("时", PingSheng, SiRhyme, 0.95, [], Some "shí");
  ("诗", PingSheng, SiRhyme, 0.90, [], Some "shī");
  ("知", PingSheng, SiRhyme, 0.88, [], Some "zhī");
  ("期", PingSheng, SiRhyme, 0.85, [], Some "qī");
  ("时", PingSheng, SiRhyme, 0.93, [], Some "shí");
  
  (* 天韵 *)
  ("天", PingSheng, TianRhyme, 0.95, [], Some "tiān");
  ("年", PingSheng, TianRhyme, 0.90, [], Some "nián");
  ("先", PingSheng, TianRhyme, 0.88, [], Some "xiān");
  ("田", PingSheng, TianRhyme, 0.85, [], Some "tián");
  ("边", PingSheng, TianRhyme, 0.82, [], Some "biān");
]

(** 仄声韵数据 *)
let ze_sheng_data = [
  (* 望韵 *)
  ("望", QuSheng, WangRhyme, 0.95, [], Some "wàng");
  ("放", QuSheng, WangRhyme, 0.90, [], Some "fàng");
  ("向", QuSheng, WangRhyme, 0.88, [], Some "xiàng");
  ("响", QuSheng, WangRhyme, 0.85, [], Some "xiǎng");
  
  (* 去韵 *)
  ("去", QuSheng, QuRhyme, 0.95, [], Some "qù");
  ("路", QuSheng, QuRhyme, 0.90, [], Some "lù");
  ("度", QuSheng, QuRhyme, 0.88, [], Some "dù");
  ("步", QuSheng, QuRhyme, 0.85, [], Some "bù");
  
  (* 鱼韵 *)
  ("鱼", PingSheng, YuRhyme, 0.95, [], Some "yú");
  ("书", PingSheng, YuRhyme, 0.90, [], Some "shū");
  ("居", PingSheng, YuRhyme, 0.88, [], Some "jū");
  ("渠", PingSheng, YuRhyme, 0.85, [], Some "qú");
  
  (* 花韵 *)
  ("花", PingSheng, HuaRhyme, 0.95, [], Some "huā");
  ("霞", PingSheng, HuaRhyme, 0.90, [], Some "xiá");
  ("家", PingSheng, HuaRhyme, 0.88, [], Some "jiā");
  ("沙", PingSheng, HuaRhyme, 0.85, [], Some "shā");
]

(** 入声韵数据 *)
let ru_sheng_data = [
  (* 月韵 *)
  ("月", RuSheng, YueRhyme, 0.95, [], Some "yuè");
  ("雪", RuSheng, XueRhyme, 0.90, [], Some "xuě");
  ("节", RuSheng, YueRhyme, 0.88, [], Some "jié");
  ("切", RuSheng, YueRhyme, 0.85, [], Some "qiē");
  
  (* 江韵 *)
  ("江", PingSheng, JiangRhyme, 0.95, [], Some "jiāng");
  ("窗", PingSheng, JiangRhyme, 0.90, [], Some "chuāng");
  ("双", PingSheng, JiangRhyme, 0.88, [], Some "shuāng");
  ("庄", PingSheng, JiangRhyme, 0.85, [], Some "zhuāng");
]

(** {3 统一数据源} *)

let all_rhyme_data = ping_sheng_data @ ze_sheng_data @ ru_sheng_data

let create_rhyme_entry (char, category, group, freq, variants, pronunciation) = {
  character = char;
  category;
  group;
  frequency = freq;
  variants;
  pronunciation;
}

(** {4 韵组定义} *)

let create_rhyme_group group_id group_name description =
  let entries = List.filter_map (fun data ->
    let entry = create_rhyme_entry data in
    if entry.group = group_id then Some entry else None
  ) all_rhyme_data in
  
  let representative_chars = 
    List.map (fun entry -> entry.character) entries 
    |> List.sort_uniq String.compare
    |> (fun chars -> 
        let rec take n lst acc =
          if n <= 0 || lst = [] then List.rev acc
          else take (n-1) (List.tl lst) (List.hd lst :: acc)
        in
        take 5 chars [])
  in
  
  {
    group_id;
    group_name;
    description;
    representative_chars;
    entries;
  }

let rhyme_groups = [
  create_rhyme_group AnRhyme "安韵" "平声韵组，含山、间、闲等字";
  create_rhyme_group SiRhyme "思韵" "平声韵组，含时、诗、知等字";
  create_rhyme_group TianRhyme "天韵" "平声韵组，含天、年、先等字";
  create_rhyme_group WangRhyme "望韵" "去声韵组，含望、放、向等字";
  create_rhyme_group QuRhyme "去韵" "去声韵组，含去、路、度等字";
  create_rhyme_group YuRhyme "鱼韵" "平声韵组，含鱼、书、居等字";
  create_rhyme_group HuaRhyme "花韵" "平声韵组，含花、霞、家等字";
  create_rhyme_group YueRhyme "月韵" "入声韵组，含月、节等字";
  create_rhyme_group XueRhyme "雪韵" "入声韵组，含雪等字";
  create_rhyme_group JiangRhyme "江韵" "平声韵组，含江、窗、双等字";
]

(** {5 数据库构建和索引} *)

let build_character_index entries =
  let index = Hashtbl.create (List.length entries) in
  List.iter (fun entry ->
    Hashtbl.add index entry.character entry
  ) entries;
  index

let build_group_index groups =
  let index = Hashtbl.create (List.length groups) in
  List.iter (fun group ->
    Hashtbl.add index group.group_id group
  ) groups;
  index

let create_database () =
  let all_entries = List.map create_rhyme_entry all_rhyme_data in
  {
    version = "1.0.0-phase1-consolidated";
    groups = rhyme_groups;
    character_index = build_character_index all_entries;
    group_index = build_group_index rhyme_groups;
    metadata = [
      ("total_characters", string_of_int (List.length all_entries));
      ("total_groups", string_of_int (List.length rhyme_groups));
      ("created_by", "Whisky, PR Worker");
      ("created_date", "2025-08-02");
      ("consolidation_phase", "Phase 1");
    ];
  }

(** {6 全局数据库实例} *)

let global_database = lazy (create_database ())

let get_database () = Lazy.force global_database

(** {7 查询接口} *)

let find_character_rhyme character =
  let db = get_database () in
  try
    Some (Hashtbl.find db.character_index character)
  with Not_found -> None

let find_group_definition group =
  let db = get_database () in
  try
    Some (Hashtbl.find db.group_index group)
  with Not_found -> None

let get_all_characters_in_group group =
  match find_group_definition group with
  | Some group_def -> List.map (fun entry -> entry.character) group_def.entries
  | None -> []

let get_all_rhyme_groups () =
  let db = get_database () in
  List.map (fun group -> group.group_id) db.groups

(** {8 统计和分析} *)

let get_database_stats () =
  let db = get_database () in
  let total_chars = Hashtbl.length db.character_index in
  let ping_count = ref 0 in
  let ze_count = ref 0 in
  let ru_count = ref 0 in
  
  Hashtbl.iter (fun _ entry ->
    match entry.category with
    | PingSheng -> incr ping_count
    | ZeSheng | ShangSheng | QuSheng -> incr ze_count  
    | RuSheng -> incr ru_count
  ) db.character_index;
  
  ({
    total_characters = total_chars;
    total_groups = List.length db.groups;
    ping_sheng_count = !ping_count;
    ze_sheng_count = !ze_count;
    ru_sheng_count = !ru_count;
  } : database_stats)

(** {9 向后兼容接口} *)

(** 兼容旧版本的数据获取接口 *)
let get_all_rhyme_data () =
  List.map (fun (char, category, group, _freq, _, _) ->
    (char, category, group)
  ) all_rhyme_data

let get_rhyme_data_simple () =
  List.map (fun entry ->
    (entry.character, entry.category, entry.group)
  ) (List.map create_rhyme_entry all_rhyme_data)

(** 兼容函数 - 获取数据库版本 *)
let get_version () = (get_database ()).version

(** 兼容函数 - 重建索引 *)
let rebuild_indices () =
  (* 重新创建数据库实例 *)
  ignore (create_database ())

(** {10 数据导出功能} *)

let export_to_json () =
  let db = get_database () in
  Printf.sprintf {|{
  "version": "%s",
  "total_characters": %d,
  "total_groups": %d,
  "consolidation_info": "Phase 1 - 32个数据文件整合为1个统一数据库"
}|} db.version (Hashtbl.length db.character_index) (List.length db.groups)

let print_database_summary () =
  let stats = get_database_stats () in
  Printf.printf "=== 骆言韵律数据库统计 ===\n";
  Printf.printf "总字符数: %d\n" stats.total_characters;
  Printf.printf "韵组数: %d\n" stats.total_groups;
  Printf.printf "平声字符: %d\n" stats.ping_sheng_count;
  Printf.printf "仄声字符: %d\n" stats.ze_sheng_count;
  Printf.printf "入声字符: %d\n" stats.ru_sheng_count;
  Printf.printf "数据库版本: %s\n" (get_version ())