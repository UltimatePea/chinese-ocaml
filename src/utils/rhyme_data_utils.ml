(** 韵律数据处理统一工具模块 - 消除Poetry/Rhyme系统重复代码
    
    本模块统一了诗词韵律系统中的重复模式：
    - 韵律数据文件加载和解析
    - JSON数据处理和错误恢复
    - 字符组数据组装和验证
    - 韵律类型转换和映射
    
    Phase 7 技术债务清理 - 韵律系统重复消除
    
    @author Beta, 代码审查代理
    @version 1.0
    @since 2025-07-27 - Fix #1429 *)

open Common_patterns
open Printf

(** ======================================================================== 
    韵律数据类型定义 - 统一各模块中重复的类型定义
    ======================================================================== *)

(** 韵律分类 *)
type rhyme_category =
  | PingSheng  (* 平声韵 *)
  | ZeSheng    (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng    (* 去声韵 *)
  | RuSheng    (* 入声韵 *)

(** 韵律组 *)
type rhyme_group =
  | AnRhyme     (* 安韵组 *)
  | SiRhyme     (* 思韵组 *)
  | TianRhyme   (* 天韵组 *)
  | WangRhyme   (* 望韵组 *)
  | QuRhyme     (* 去韵组 *)
  | YuRhyme     (* 鱼韵组 *)
  | HuaRhyme    (* 花韵组 *)
  | FengRhyme   (* 风韵组 *)
  | YueRhyme    (* 月韵组 *)
  | XueRhyme    (* 雪韵组 *)
  | JiangRhyme  (* 江韵组 *)
  | HuiRhyme    (* 灰韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(** 韵律数据条目 *)
type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  tone_info : string option;
  usage_notes : string option;
}

(** ======================================================================== 
    数据文件查找和加载工具 - 消除重复的文件查找逻辑
    ======================================================================== *)

(** 韵律数据文件路径配置 *)
type rhyme_file_config = {
  base_path : string;
  ping_sheng_path : string;
  ze_sheng_path : string;
  fallback_paths : string list;
}

(** 默认韵律文件配置 *)
let default_rhyme_config = {
  base_path = "data/poetry/rhyme_groups/";
  ping_sheng_path = "ping_sheng/";
  ze_sheng_path = "ze_sheng/";
  fallback_paths = [
    "data/poetry/";
    "src/poetry/data/";
    "./poetry_data/";
  ];
}

(** 构建文件路径 *)
let rec build_rhyme_file_path config category group =
  let category_path = match category with
    | PingSheng -> config.ping_sheng_path
    | ZeSheng | ShangSheng | QuSheng | RuSheng -> config.ze_sheng_path
  in
  let group_name = match group with
    | FengRhyme -> "feng_rhyme_data.json"
    | YueRhyme -> "yue_rhyme_data.json"
    | JiangRhyme -> "jiang_rhyme_data.json"
    | HuiRhyme -> "hui_rhyme_data.json"
    | HuaRhyme -> "hua_rhyme_data.json"
    | YuRhyme -> "yu_rhyme_data.json"
    | _ -> sprintf "%s_rhyme_data.json" (string_of_rhyme_group group)
  in
  config.base_path ^ category_path ^ group_name

(** 韵律组名称转换 *)
and string_of_rhyme_group = function
  | AnRhyme -> "an"
  | SiRhyme -> "si"
  | TianRhyme -> "tian"
  | WangRhyme -> "wang"
  | QuRhyme -> "qu"
  | YuRhyme -> "yu"
  | HuaRhyme -> "hua"
  | FengRhyme -> "feng"
  | YueRhyme -> "yue"
  | XueRhyme -> "xue"
  | JiangRhyme -> "jiang"
  | HuiRhyme -> "hui"
  | UnknownRhyme -> "unknown"

(** 查找韵律数据文件 *)
let find_rhyme_data_file config category group =
  let primary_path = build_rhyme_file_path config category group in
  match find_data_file_with_candidates [primary_path] with
  | Some path -> Some path
  | None ->
      (* 尝试回退路径 *)
      let group_file = sprintf "%s_rhyme_data.json" (string_of_rhyme_group group) in
      let fallback_candidates = List.map (fun base -> base ^ group_file) config.fallback_paths in
      find_data_file_with_candidates fallback_candidates

(** ======================================================================== 
    JSON数据解析工具 - 统一JSON解析和错误处理
    ======================================================================== *)

(** JSON韵律数据结构 *)
type json_rhyme_data = {
  name : string;
  category : string;
  characters : string list;
  metadata : (string * string) list;
}

(** 解析JSON韵律数据 *)
let parse_json_rhyme_data json =
  try
    let open Yojson.Basic.Util in
    let name = json |> member "name" |> to_string in
    let category = json |> member "category" |> to_string in
    let characters = json |> member "characters" |> to_list |> List.map to_string in
    let metadata = 
      try
        json |> member "metadata" |> to_assoc |> List.map (fun (k, v) -> (k, to_string v))
      with _ -> []
    in
    Ok { name; category; characters; metadata }
  with exn ->
    Error (sprintf "JSON解析失败: %s" (Printexc.to_string exn))

(** 批量加载JSON韵律文件 *)
let rec batch_load_rhyme_files config category_group_pairs =
  let load_single (category, group) =
    match find_rhyme_data_file config category group with
    | None -> 
        print_warning (sprintf "未找到韵律文件: %s/%s" 
          (string_of_rhyme_category category) (string_of_rhyme_group group));
        []
    | Some file_path ->
        match safe_json_parse file_path with
        | Ok json ->
            (match parse_json_rhyme_data json with
             | Ok data -> [data]
             | Error msg -> 
                 print_warning (sprintf "解析韵律文件失败 %s: %s" file_path msg);
                 [])
        | Error msg -> 
            print_warning (sprintf "读取韵律文件失败 %s: %s" file_path msg);
            []
  in
  List.concat (List.map load_single category_group_pairs)

(** 韵律分类名称转换 *)
and string_of_rhyme_category = function
  | PingSheng -> "ping_sheng"
  | ZeSheng -> "ze_sheng"
  | ShangSheng -> "shang_sheng"
  | QuSheng -> "qu_sheng"
  | RuSheng -> "ru_sheng"

(** ======================================================================== 
    字符组数据处理工具 - 统一字符组加载和组装
    ======================================================================== *)

(** 字符组加载器类型 *)
type character_group_loader = string -> string list

(** 创建字符组加载器 *)
let create_character_group_loader base_loader =
  fun group_name ->
    try base_loader group_name
    with exn ->
      print_warning (sprintf "加载字符组失败 %s: %s" group_name (Printexc.to_string exn));
      []

(** 统一的字符组加载模式 *)
let load_rhyme_character_groups loader group_names =
  load_character_groups loader group_names

(** 创建韵律条目 *)
let create_rhyme_entries characters category group =
  List.map (fun char -> {
    character = char;
    category = category;
    group = group;
    tone_info = None;
    usage_notes = None;
  }) characters

(** 组装韵律数据 *)
let assemble_rhyme_data character_groups category group =
  List.concat (List.map (fun chars -> create_rhyme_entries chars category group) character_groups)

(** ======================================================================== 
    韵律数据验证和清理工具
    ======================================================================== *)

(** 验证韵律条目 *)
let validate_rhyme_entry entry =
  let character_valid = String.length entry.character > 0 in
  let category_valid = match entry.category with
    | PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng -> true
  in
  character_valid && category_valid

(** 清理重复的韵律条目 *)
let deduplicate_rhyme_entries entries =
  let seen = Hashtbl.create 128 in
  List.filter (fun entry ->
    let key = (entry.character, entry.category, entry.group) in
    if Hashtbl.mem seen key then false
    else (Hashtbl.add seen key true; true)
  ) entries

(** 韵律数据统计 *)
let analyze_rhyme_data entries =
  let total_count = List.length entries in
  sprintf "韵律数据分析: 总计%d个条目" total_count

(** ======================================================================== 
    韵律数据缓存和性能优化
    ======================================================================== *)

(** 韵律数据缓存 *)
module RhymeCache = struct
  type cache_entry = {
    data : rhyme_entry list;
    timestamp : float;
    file_path : string;
  }
  
  let cache = Hashtbl.create 32
  
  let get_cached category group =
    let key = (category, group) in
    match Hashtbl.find_opt cache key with
    | Some entry -> Some entry.data
    | None -> None
  
  let store_cached category group data file_path =
    let entry = {
      data = data;
      timestamp = Unix.time ();
      file_path = file_path;
    } in
    Hashtbl.replace cache (category, group) entry
  
  let clear_cache () = Hashtbl.clear cache
  
  let cache_info () =
    sprintf "韵律缓存: %d个条目" (Hashtbl.length cache)
end

(** 带缓存的韵律数据加载器 *)
let load_rhyme_data_with_cache config category group =
  match RhymeCache.get_cached category group with
  | Some data -> 
      print_debug_info (sprintf "使用缓存的韵律数据: %s/%s" 
        (string_of_rhyme_category category) (string_of_rhyme_group group));
      data
  | None ->
      print_debug_info (sprintf "加载韵律数据: %s/%s" 
        (string_of_rhyme_category category) (string_of_rhyme_group group));
      let data = batch_load_rhyme_files config [(category, group)] in
      let entries = List.concat (List.map (fun json_data -> 
        create_rhyme_entries json_data.characters category group
      ) data) in
      RhymeCache.store_cached category group entries "";
      entries

(** ======================================================================== 
    高级韵律数据操作工具
    ======================================================================== *)

(** 韵律匹配器 *)
let create_rhyme_matcher entries =
  let char_to_group = Hashtbl.create 256 in
  List.iter (fun entry ->
    Hashtbl.replace char_to_group entry.character entry.group
  ) entries;
  fun character ->
    try Some (Hashtbl.find char_to_group character)
    with Not_found -> None

(** 韵律验证器 *)
let create_rhyme_validator entries =
  let valid_chars = Hashtbl.create 256 in
  List.iter (fun entry ->
    Hashtbl.replace valid_chars entry.character true
  ) entries;
  fun character ->
    Hashtbl.mem valid_chars character

(** 韵律分析报告 *)
let generate_rhyme_report entries =
  let analysis = analyze_rhyme_data entries in
  let validation_results = List.map validate_rhyme_entry entries in
  let valid_count = List.length (List.filter (fun x -> x) validation_results) in
  let invalid_count = List.length entries - valid_count in
  
  sprintf "%s\n验证结果: %d个有效条目，%d个无效条目" 
    analysis valid_count invalid_count