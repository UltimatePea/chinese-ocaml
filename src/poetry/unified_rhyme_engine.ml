(** 统一韵律引擎 - 核心功能整合 Phase 2.2
    
    此模块整合了以下分散的韵律模块功能：
    - rhyme_core_unified.ml (90行) - 兼容性重导出 
    - rhyme_api_core.ml (416行) - 核心API函数
    - unified_rhyme_core.ml (301行) - 统一数据类型
    - rhyme_matching.ml (58行) - 韵律匹配算法
    - rhyme_validation.ml (221行) - 韵律验证逻辑
    
    总计整合: 1086行 → 单一统一引擎
    
    Author: Alpha, 主要工作代理
    @version 1.0 - Phase 2.2 核心引擎统一版本
    @since 2025-07-30
    @fix_issue #1755 *)

open Poetry_core.Poetry_types

(** {1 统一韵律数据类型定义} *)

type unified_rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  frequency : float;
}

type unified_rhyme_group = {
  group_id : rhyme_group;
  group_name : string;
  entries : unified_rhyme_entry list;
  description : string;
}

type database_stats = {
  total_characters : int;
  total_groups : int;
  ping_sheng_count : int;
  ze_sheng_count : int;
  ru_sheng_count : int;
}

type unified_rhyme_database = {
  version : string;
  groups : unified_rhyme_group list;
  index : (string, unified_rhyme_entry) Hashtbl.t;
  stats : database_stats;
}

(** {2 向后兼容类型重导出} - 保持现有API兼容 *)

type rhyme_data_entry = Rhyme_core_types.rhyme_data_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}

type rhyme_group_data = Rhyme_core_types.rhyme_group_data = {
  group_name : rhyme_group;
  group_description : string;
  entries : rhyme_data_entry list;
  example_poems : string list;
}

(** {3 核心韵律查找和检测功能} *)

(** 统一的韵律信息查找函数 整合自 rhyme_api_core.ml 和 rhyme_matching.ml 的重复实现

    @param char 要查找的字符
    @return 韵类和韵组的组合，如果未找到则返回None *)
let find_rhyme_info char =
  Unified_rhyme_data.load_rhyme_data_to_cache ();
  Rhyme_cache.lookup_rhyme_global char

(** 检测字符的韵类 统一的韵类检测函数，替代多处重复实现

    @param char 要检测的字符
    @return 韵类，如果无法检测则返回PingSheng作为默认值 *)
let detect_rhyme_category char =
  match find_rhyme_info char with Some (category, _) -> category | None -> PingSheng (* 默认为平声 *)

(** 检测字符的韵组 统一的韵组检测函数，替代多处重复实现

    @param char 要检测的字符
    @return 韵组，如果无法检测则返回UnknownRhyme *)
let detect_rhyme_group char =
  match find_rhyme_info char with Some (_, group) -> group | None -> UnknownRhyme

(** 字符韵类检测 - 兼容 rhyme_matching.ml 接口 *)
let detect_rhyme_category_by_string char_str =
  if String.length char_str > 0 then detect_rhyme_category char_str else PingSheng

(** 获取韵组包含的所有字符

    @param group 韵组
    @return 字符列表 *)
let get_rhyme_characters group =
  Unified_rhyme_data.load_rhyme_data_to_cache ();
  match Rhyme_cache.lookup_rhyme_group_chars_global group with Some chars -> chars | None -> []

(** {4 韵律匹配算法} - 整合自 rhyme_matching.ml *)

(** 检查两个字符是否押韵

    @param char1 第一个字符
    @param char2 第二个字符
    @return 是否押韵 *)
let check_rhyme_match char1 char2 =
  let group1 = detect_rhyme_group char1 in
  let group2 = detect_rhyme_group char2 in
  match (group1, group2) with UnknownRhyme, _ | _, UnknownRhyme -> false | _ -> group1 = group2

(** 检查字符列表是否形成有效的韵脚模式

    @param chars 字符列表
    @return 韵律匹配结果 *)
let validate_rhyme_pattern chars =
  let groups = List.map detect_rhyme_group chars in
  let valid_groups = List.filter (fun g -> g <> UnknownRhyme) groups in
  if List.length valid_groups < 2 then false
  else
    let first_group = List.hd valid_groups in
    List.for_all (fun g -> g = first_group) valid_groups

(** {5 韵律验证功能} - 整合自 rhyme_validation.ml *)

(** 提取诗句韵脚的辅助函数 - 避免依赖循环 *)
let extract_rhyme_ending verse =
  let chars = String.to_seqi verse |> Seq.map (fun (_, c) -> String.make 1 c) |> List.of_seq in
  match List.rev chars with
  | [] -> None
  | last_char :: _ -> if String.length last_char > 0 then Some last_char.[0] else None

(** 字符韵律检测辅助函数 *)
let detect_rhyme_group_char char = detect_rhyme_group (String.make 1 char)

let detect_rhyme_category_char char = detect_rhyme_category (String.make 1 char)

(** 分析诗句字符的韵律信息

    @param verse 诗句
    @return 字符韵律分析结果列表 *)
let analyze_verse_chars verse =
  let char_list = List.of_seq (String.to_seq verse) in
  List.map
    (fun char ->
      let category = detect_rhyme_category_char char in
      let group = detect_rhyme_group_char char in
      (char, category, group))
    char_list

(** 提取诗句的韵脚和韵组信息

    @param verses 诗句列表
    @return (韵脚字符列表, 韵组列表) *)
let extract_verse_rhyme_info verses =
  let rhyme_endings = List.filter_map extract_rhyme_ending verses in
  let rhyme_groups = List.map detect_rhyme_group_char rhyme_endings in
  (rhyme_endings, rhyme_groups)

(** 验证诗句列表的韵律一致性

    @param verses 诗句列表
    @return 韵律验证结果 *)
let validate_verses_rhyme verses =
  let _rhyme_endings, rhyme_groups = extract_verse_rhyme_info verses in
  if List.length rhyme_groups < 2 then false
  else
    let valid_groups = List.filter (fun g -> g <> UnknownRhyme) rhyme_groups in
    if List.length valid_groups < 2 then false
    else
      let first_group = List.hd valid_groups in
      List.for_all (fun g -> g = first_group) valid_groups

(** {6 兼容性接口} - 保持向后兼容 *)

(** 重导出构建辅助函数以保持API兼容性 *)
let make_entry = Rhyme_data_builder.make_entry

let make_group_entries = Rhyme_data_builder.make_group_entries

(** 重导出所有韵组数据以保持现有代码兼容 *)
let an_rhyme_data = Rhyme_data_builder.an_rhyme_data

let si_rhyme_data = Rhyme_data_builder.si_rhyme_data
let tian_rhyme_data = Rhyme_data_builder.tian_rhyme_data
let wang_rhyme_data = Rhyme_data_builder.wang_rhyme_data
let qu_rhyme_data = Rhyme_data_builder.qu_rhyme_data
let yu_rhyme_data = Rhyme_data_builder.yu_rhyme_data
let hua_rhyme_data = Rhyme_data_builder.hua_rhyme_data
let feng_rhyme_data = Rhyme_data_builder.feng_rhyme_data
let yue_rhyme_data = Rhyme_data_builder.yue_rhyme_data
let jiang_rhyme_data = Rhyme_data_builder.jiang_rhyme_data
let hui_rhyme_data = Rhyme_data_builder.hui_rhyme_data

(** 所有韵组数据的统一集合 *)
let all_rhyme_groups =
  [
    an_rhyme_data;
    si_rhyme_data;
    tian_rhyme_data;
    wang_rhyme_data;
    qu_rhyme_data;
    yu_rhyme_data;
    hua_rhyme_data;
    feng_rhyme_data;
    yue_rhyme_data;
    jiang_rhyme_data;
    hui_rhyme_data;
  ]

(** {7 统一引擎状态管理} *)

(** 引擎版本信息 *)
let engine_version = "2.2.0-unified"

(** 引擎统计信息 *)
let get_engine_stats () =
  let total_groups = List.length all_rhyme_groups in
  let total_chars =
    List.fold_left (fun acc group -> acc + List.length group.entries) 0 all_rhyme_groups
  in
  let ping_count =
    List.fold_left
      (fun acc group ->
        acc + List.length (List.filter (fun entry -> entry.category = PingSheng) group.entries))
      0 all_rhyme_groups
  in
  {
    total_characters = total_chars;
    total_groups;
    ping_sheng_count = ping_count;
    ze_sheng_count = total_chars - ping_count;
    ru_sheng_count = 0;
    (* 简化统计 *)
  }

(** 引擎健康检查 *)
let engine_health_check () =
  try
    let stats = get_engine_stats () in
    stats.total_characters > 0 && stats.total_groups > 0
  with _ -> false

(** {8 附加功能函数} - 为其他模块提供的兼容函数 *)

type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}
(** 韵律分析报告类型 - 兼容性定义 *)

(** 生成韵律报告 - 兼容性函数 *)
let generate_rhyme_report verse =
  let rhyme_ending = extract_rhyme_ending verse in
  let rhyme_group =
    match rhyme_ending with Some char -> detect_rhyme_group_char char | None -> UnknownRhyme
  in
  let rhyme_category =
    match rhyme_ending with Some char -> detect_rhyme_category_char char | None -> PingSheng
  in
  let char_analysis = analyze_verse_chars verse in
  { verse; rhyme_ending; rhyme_group; rhyme_category; char_analysis }

(** 获取韵组数据 - 兼容性函数 *)
let get_rhyme_group_data group = List.find_opt (fun g -> g.group_name = group) all_rhyme_groups

(** 查找押韵字符 - 兼容性函数 - 接受 char 类型 *)
let find_rhyming_characters char =
  let char_str = String.make 1 char in
  let group = detect_rhyme_group char_str in
  get_rhyme_characters group

(** 获取所有条目 - 兼容性函数 *)
let get_all_entries () = List.fold_left (fun acc group -> acc @ group.entries) [] all_rhyme_groups

(** 简单押韵检查 - 兼容性函数 *)
let check_rhyme char1 char2 =
  let str1 = String.make 1 char1 in
  let str2 = String.make 1 char2 in
  check_rhyme_match str1 str2

(** 按韵类获取字符 - 兼容性函数 *)
let get_chars_by_category category =
  let all_entries = get_all_entries () in
  List.filter_map
    (fun entry -> if entry.category = category then Some entry.character else None)
    all_entries

(** 获取所有韵组 - 兼容性函数 *)
let get_all_groups () = List.map (fun group -> group.group_name) all_rhyme_groups

(** 安全查找韵律信息 - 兼容性函数 *)
let safe_find_rhyme_info char_str = try Some (find_rhyme_info char_str) with _ -> None

(** 查找字符韵律信息 - 兼容性函数 *)
let find_char_rhyme_info char_str = find_rhyme_info char_str
