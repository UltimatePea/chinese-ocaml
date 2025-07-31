(** 统一韵律数据库 - Phase 2.1 深度整合核心模块
    
    将所有分散的韵律数据整合为单一、高效、现代化的数据库系统。
    这是韵律模块整合Phase 2.1的核心基础设施。
    
    整合目标:
    - consolidated_rhyme_data_group1.ml (4个韵组) → 统一数据库
    - consolidated_rhyme_data_group2.ml (4个韵组) → 统一数据库
    - consolidated_rhyme_data_group3.ml (3个韵组) → 统一数据库
    - 各种分散的rhyme_data模块 → 统一访问接口
    
    @author Whisky, PR Worker
    @version 1.0 - 韵律模块深度整合Phase 2.1
    @since 2025-07-31
    @github_issue #1903
    @consolidation_target 84个韵律模块 → 45个模块 *)

open Poetry_core.Rhyme_core_types

(** {1 核心数据类型定义} *)

(** 韵律数据来源标识 *)
type rhyme_source = 
  | Traditional_Poetry   (** 传统诗词韵律 *)
  | Modern_Poetry       (** 现代诗词韵律 *)
  | Classical_Texts     (** 古典文献韵律 *)
  | Dialect_Variant     (** 方言变体韵律 *)

(** 增强的韵律数据条目 *)
type enhanced_rhyme_entry = {
  character: string;                    (** 字符 *)
  pinyin: string;                      (** 拼音 *)
  tone: int;                           (** 声调 1-4 *)
  rhyme_group: rhyme_group;            (** 韵组分类 *)
  rhyme_category: rhyme_category;      (** 韵律类别 *)
  source: rhyme_source;                (** 数据来源 *)
  frequency: float;                    (** 使用频率 0.0-1.0 *)
  variants: string list;               (** 变体字符 *)
  examples: string list;               (** 诗词例句 *)
  metadata: (string * string) list;   (** 扩展元数据 *)
}

(** 数据库索引结构 *)
type database_indices = {
  char_index: (string, enhanced_rhyme_entry) Hashtbl.t;     (** 字符快速索引 *)
  group_index: (rhyme_group, enhanced_rhyme_entry list) Hashtbl.t; (** 韵组索引 *)
  tone_index: (int, enhanced_rhyme_entry list) Hashtbl.t;   (** 声调索引 *)
  category_index: (rhyme_category, enhanced_rhyme_entry list) Hashtbl.t; (** 类别索引 *)
}

(** 数据库元数据 *)
type database_metadata = {
  total_entries: int;                  (** 总条目数 *)
  last_updated: float;                 (** 最后更新时间 *)
  version: string;                     (** 数据库版本 *)
  sources: rhyme_source list;          (** 数据来源列表 *)
  group_distribution: (rhyme_group * int) list; (** 韵组分布统计 *)
  category_distribution: (rhyme_category * int) list; (** 类别分布统计 *)
}

(** 统一韵律数据库 *)
type unified_rhyme_database = {
  entries: enhanced_rhyme_entry array; (** 主数据数组 *)
  indices: database_indices;           (** 索引结构 *)
  metadata: database_metadata;         (** 元数据 *)
}

(** {2 数据库构建函数} *)

(** 从基础数据创建增强条目 *)
let create_enhanced_entry character category group ?(pinyin="") ?(tone=1) 
    ?(source=Traditional_Poetry) ?(frequency=1.0) ?(variants=[]) ?(examples=[]) ?(metadata=[]) () =
  {
    character;
    pinyin = if pinyin = "" then character else pinyin;
    tone;
    rhyme_group = group;
    rhyme_category = category;
    source;
    frequency;
    variants;
    examples;
    metadata;
  }

(** 创建基础测试数据 - Phase 2.1 第一阶段实现 *)
let create_basic_rhyme_data () =
  (* 创建一些基础的韵律数据用于测试和演示 *)
  let basic_entries = [
    (* 天韵组数据 *)
    create_enhanced_entry "天" PingSheng TianRhyme ~pinyin:"tiān" ~tone:1 
      ~examples:["天高云淡，望断南飞雁"] ();
    create_enhanced_entry "年" PingSheng TianRhyme ~pinyin:"nián" ~tone:2
      ~examples:["千里莺啼绿映红"] ();
    create_enhanced_entry "先" PingSheng TianRhyme ~pinyin:"xiān" ~tone:1
      ~examples:["先天下之忧而忧"] ();
      
    (* 月韵组数据 *)
    create_enhanced_entry "月" PingSheng YueRhyme ~pinyin:"yuè" ~tone:4
      ~examples:["明月松间照，清泉石上流"] ();
    create_enhanced_entry "说" PingSheng YueRhyme ~pinyin:"shuō" ~tone:1
      ~examples:["千里莺啼绿映红"] ();
    create_enhanced_entry "雪" PingSheng YueRhyme ~pinyin:"xuě" ~tone:3
      ~examples:["但愿人长久，千里共婵娟"] ();
      
    (* 风韵组数据 *)
    create_enhanced_entry "风" PingSheng FengRhyme ~pinyin:"fēng" ~tone:1
      ~examples:["大江东去，浪淘尽"] ();
    create_enhanced_entry "东" PingSheng FengRhyme ~pinyin:"dōng" ~tone:1
      ~examples:["千里快哉风"] ();
    create_enhanced_entry "中" PingSheng FengRhyme ~pinyin:"zhōng" ~tone:1
      ~examples:["中流击水，浪遏飞舟"] ();
      
    (* 花韵组数据 *)
    create_enhanced_entry "花" PingSheng HuaRhyme ~pinyin:"huā" ~tone:1
      ~examples:["落红不是无情物，化作春泥更护花"] ();
    create_enhanced_entry "家" PingSheng HuaRhyme ~pinyin:"jiā" ~tone:1
      ~examples:["人面桃花相映红"] ();
    create_enhanced_entry "茶" PingSheng HuaRhyme ~pinyin:"chá" ~tone:2
      ~examples:["茶花满路香如雪"] ();
      
    (* 仄声韵律数据 *)
    create_enhanced_entry "变" ZeSheng TianRhyme ~pinyin:"biàn" ~tone:4
      ~examples:["变法维新志不移"] ();
    create_enhanced_entry "绝" ZeSheng YueRhyme ~pinyin:"jué" ~tone:2
      ~examples:["绝句诗中见功力"] ();
    create_enhanced_entry "动" ZeSheng FengRhyme ~pinyin:"dòng" ~tone:4
      ~examples:["一动不如一静"] ();
    create_enhanced_entry "下" ZeSheng HuaRhyme ~pinyin:"xià" ~tone:4
      ~examples:["下笔如有神"] ();
  ] in
  basic_entries

(** 构建数据库索引 *)
let build_indices entries =
  let char_index = Hashtbl.create 2048 in
  let group_index = Hashtbl.create 32 in
  let tone_index = Hashtbl.create 8 in
  let category_index = Hashtbl.create 8 in
  
  Array.iter (fun entry ->
    (* 字符索引 *)
    Hashtbl.replace char_index entry.character entry;
    
    (* 韵组索引 *)
    let group_entries = 
      try Hashtbl.find group_index entry.rhyme_group
      with Not_found -> [] in
    Hashtbl.replace group_index entry.rhyme_group (entry :: group_entries);
    
    (* 声调索引 *)
    let tone_entries = 
      try Hashtbl.find tone_index entry.tone
      with Not_found -> [] in
    Hashtbl.replace tone_index entry.tone (entry :: tone_entries);
    
    (* 类别索引 *)
    let category_entries = 
      try Hashtbl.find category_index entry.rhyme_category
      with Not_found -> [] in
    Hashtbl.replace category_index entry.rhyme_category (entry :: category_entries);
  ) entries;
  
  { char_index; group_index; tone_index; category_index }

(** 计算数据库元数据 *)
let calculate_metadata entries =
  let total_entries = Array.length entries in
  let last_updated = Unix.gettimeofday () in
  let version = "1.0-unified" in
  let sources = [Traditional_Poetry] in
  
  (* 计算韵组分布 *)
  let group_counts = Hashtbl.create 32 in
  let category_counts = Hashtbl.create 8 in
  
  Array.iter (fun entry ->
    (* 韵组统计 *)
    let group_count = 
      try Hashtbl.find group_counts entry.rhyme_group
      with Not_found -> 0 in
    Hashtbl.replace group_counts entry.rhyme_group (group_count + 1);
    
    (* 类别统计 *)
    let category_count = 
      try Hashtbl.find category_counts entry.rhyme_category
      with Not_found -> 0 in
    Hashtbl.replace category_counts entry.rhyme_category (category_count + 1);
  ) entries;
  
  let group_distribution = Hashtbl.fold (fun k v acc -> (k, v) :: acc) group_counts [] in
  let category_distribution = Hashtbl.fold (fun k v acc -> (k, v) :: acc) category_counts [] in
  
  {
    total_entries;
    last_updated;
    version;
    sources;
    group_distribution;
    category_distribution;
  }

(** 构建统一韵律数据库 *)
let build_unified_database () =
  (* 使用基础测试数据 - Phase 2.1 第一阶段实现 *)
  let all_entries = create_basic_rhyme_data () in
  
  (* 去重处理 *)
  let unique_entries = 
    List.fold_left (fun acc entry ->
      if List.exists (fun e -> e.character = entry.character) acc
      then acc
      else entry :: acc
    ) [] all_entries in
  
  let entries_array = Array.of_list unique_entries in
  let indices = build_indices entries_array in
  let metadata = calculate_metadata entries_array in
  
  { entries = entries_array; indices; metadata }

(** {3 全局数据库实例} *)

(** 数据库单例 - 延迟初始化 *)
let database_instance = ref None

(** 获取统一数据库实例 *)
let get_database () =
  match !database_instance with
  | Some db -> db
  | None ->
      let db = build_unified_database () in
      database_instance := Some db;
      db

(** {4 查询接口} *)

(** 根据字符查找韵律信息 *)
let lookup_character char =
  let db = get_database () in
  try Some (Hashtbl.find db.indices.char_index char)
  with Not_found -> None

(** 根据韵组获取所有字符 *)
let get_characters_by_group group =
  let db = get_database () in
  try 
    let entries = Hashtbl.find db.indices.group_index group in
    List.map (fun entry -> entry.character) entries
  with Not_found -> []

(** 根据声调获取所有字符 *)
let get_characters_by_tone tone =
  let db = get_database () in
  try 
    let entries = Hashtbl.find db.indices.tone_index tone in
    List.map (fun entry -> entry.character) entries
  with Not_found -> []

(** 根据韵律类别获取所有字符 *)
let get_characters_by_category category =
  let db = get_database () in
  try 
    let entries = Hashtbl.find db.indices.category_index category in
    List.map (fun entry -> entry.character) entries
  with Not_found -> []

(** 检查两个字符是否同韵 *)
let are_characters_rhyming char1 char2 =
  match lookup_character char1, lookup_character char2 with
  | Some entry1, Some entry2 -> 
      entry1.rhyme_group = entry2.rhyme_group
  | _ -> false

(** 查找与指定字符同韵的所有字符 *)
let find_rhyming_characters char =
  match lookup_character char with
  | Some entry -> get_characters_by_group entry.rhyme_group
  | None -> []

(** {5 统计和管理接口} *)

(** 获取数据库统计信息 *)
let get_database_statistics () =
  let db = get_database () in
  db.metadata

(** 打印数据库信息 *)
let print_database_info () =
  let stats = get_database_statistics () in
  Printf.printf "统一韵律数据库信息:\n";
  Printf.printf "- 总字符数: %d\n" stats.total_entries;
  Printf.printf "- 数据库版本: %s\n" stats.version;
  Printf.printf "- 最后更新: %s\n" (string_of_float stats.last_updated);
  Printf.printf "- 韵组分布:\n";
  List.iter (fun (group, count) ->
    Printf.printf "  * %s: %d字符\n" (rhyme_group_to_string group) count
  ) stats.group_distribution;
  Printf.printf "- 类别分布:\n";
  List.iter (fun (category, count) ->
    Printf.printf "  * %s: %d字符\n" (rhyme_category_to_string category) count
  ) stats.category_distribution

(** 获取所有韵律条目 *)
let get_all_entries () =
  let db = get_database () in
  Array.to_list db.entries

(** 数据库健康检查 *)
let health_check () =
  let db = get_database () in
  let total_indexed = 
    Hashtbl.fold (fun _ _ acc -> acc + 1) db.indices.char_index 0 in
  let expected_total = Array.length db.entries in
  
  if total_indexed = expected_total then
    Printf.printf "✅ 数据库健康检查通过: %d/%d 条目已索引\n" total_indexed expected_total
  else
    Printf.printf "⚠️ 数据库索引不一致: %d/%d 条目已索引\n" total_indexed expected_total

(** {6 向后兼容接口} *)

(** 兼容原有的rhyme_data访问模式 *)
module Compatibility = struct
  
  (** 兼容consolidated_rhyme_data.ml的接口 *)
  let find_rhyme_info char = 
    match lookup_character char with
    | Some entry -> Some (entry.rhyme_category, entry.rhyme_group)
    | None -> None
  
  (** 兼容rhyme_data_core.ml的接口 *)
  let get_rhyme_entry char =
    lookup_character char
  
  (** 兼容各种group数据访问 *)
  let get_chars_by_rhyme_group = get_characters_by_group
  let get_chars_by_category = get_characters_by_category
  
  (** 兼容检查函数 *)
  let is_char_in_database = function char ->
    match lookup_character char with
    | Some _ -> true
    | None -> false
end