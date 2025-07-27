(** 韵律数据处理工具模块 - 简化版本
    
    修复 Issue #1463 架构问题的最小化实现：
    - 消除全局状态和缓存复杂性
    - 简化为纯函数式设计
    - 移除过度工程化
    
    @author Alpha, 主工作代理
    @version 1.0 - 最小可行版本  
    @since 2025-07-27 - Fix #1463 *)

open Printf

(** Common patterns helpers *)
let print_warning msg = Printf.eprintf "[WARNING] %s\n" msg
let print_debug_info msg = Printf.eprintf "[DEBUG] %s\n" msg

let find_data_file file_path =
  if Sys.file_exists file_path then Some file_path else None

let load_file_with_recovery file_path parser =
  try
    let content = 
      let ic = open_in file_path in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content
    in
    parser content
  with
  | exn ->
    print_warning (sprintf "文件加载失败 %s: %s" file_path (Printexc.to_string exn));
    None

let load_character_groups loader group_names =
  List.map loader group_names

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

(** 韵律文件配置信息 *)
type rhyme_file_config = {
  base_dir : string;
  file_extension : string;
  default_encoding : string;
}

(** JSON韵律数据结构 *)
type json_rhyme_data = {
  characters : string list;
  category : rhyme_category;
  group : rhyme_group;
  metadata : (string * string) list;
}

(** ======================================================================== 
    字符串转换函数 - 统一重复的转换逻辑
    ======================================================================== *)

(** 韵律分类转字符串 *)
let string_of_rhyme_category = function
  | PingSheng -> "平声"
  | ZeSheng -> "仄声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

(** 韵律组转字符串 *)
let string_of_rhyme_group = function
  | AnRhyme -> "安韵"     | SiRhyme -> "思韵"
  | TianRhyme -> "天韵"   | WangRhyme -> "望韵"
  | QuRhyme -> "去韵"     | YuRhyme -> "鱼韵"
  | HuaRhyme -> "花韵"    | FengRhyme -> "风韵"
  | YueRhyme -> "月韵"    | XueRhyme -> "雪韵"
  | JiangRhyme -> "江韵"  | HuiRhyme -> "灰韵"
  | UnknownRhyme -> "未知"

(** ======================================================================== 
    文件配置和路径处理 - 消除重复的文件处理逻辑
    ======================================================================== *)

(** 默认韵律文件配置 *)
let default_rhyme_config = {
  base_dir = "data/rhyme";
  file_extension = ".json";
  default_encoding = "utf-8";
}

(** 构建韵律数据文件路径 *)
let build_rhyme_file_path config category group =
  let category_str = string_of_rhyme_category category in
  let group_str = string_of_rhyme_group group in
  sprintf "%s/%s_%s%s" config.base_dir category_str group_str config.file_extension

(** 查找韵律数据文件 - 使用通用文件查找模式 *)
let find_rhyme_data_file config category group =
  let file_path = build_rhyme_file_path config category group in
  find_data_file file_path

(** ======================================================================== 
    JSON数据处理 - 统一JSON解析和错误处理
    ======================================================================== *)

(** 解析JSON韵律数据 - 简化的占位符实现 *)
let parse_json_rhyme_data _json_content =
  (* 简化的占位符实现 - 实际项目中可以扩展 *)
  {
    characters = [];
    category = PingSheng;
    group = UnknownRhyme;
    metadata = [];
  }

(** 安全加载JSON文件 *)
let safe_load_json_file file_path =
  load_file_with_recovery file_path (fun content -> 
    Some (parse_json_rhyme_data content)
  )

(** ======================================================================== 
    字符组数据处理工具 - 优化版本
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

(** ======================================================================== 
    韵律数据创建和验证 - 简化版本
    ======================================================================== *)

(** 创建韵律条目 *)
let create_rhyme_entries characters category group =
  List.map (fun char -> {
    character = char;
    category = category;
    group = group;
    tone_info = None;
    usage_notes = None;
  }) characters

(** 验证韵律条目 *)
let validate_rhyme_entry entry =
  let character_valid = String.length entry.character > 0 in
  let category_valid = match entry.category with
    | PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng -> true
  in
  character_valid && category_valid

(** 组装韵律数据 *)
let assemble_rhyme_data character_groups category group =
  List.concat (List.map (fun chars -> create_rhyme_entries chars category group) character_groups)

(** ======================================================================== 
    简化数据处理 - 移除缓存复杂性
    ======================================================================== *)

(** ======================================================================== 
    韵律数据分析和匹配 - 简化版本
    ======================================================================== *)

(** 简单的韵律匹配器 - 使用List.find而非复杂哈希表 *)
let create_rhyme_matcher (entries : rhyme_entry list) : (string -> rhyme_group option) =
  fun character ->
    try
      let entry = List.find (fun e -> e.character = character) entries in
      Some entry.group
    with Not_found -> None

(** 简单的韵律验证器 *)
let create_rhyme_validator (entries : rhyme_entry list) : (string -> bool) =
  fun character ->
    List.exists (fun e -> e.character = character) entries

(** 韵律数据分析 *)
let analyze_rhyme_data (entries : rhyme_entry list) : string =
  let total_count = List.length entries in
  let category_counts = ref [] in
  List.iter (fun (entry : rhyme_entry) ->
    let category_str = string_of_rhyme_category entry.category in
    let current = try List.assoc category_str !category_counts with Not_found -> 0 in
    category_counts := (category_str, current + 1) :: (List.remove_assoc category_str !category_counts)
  ) (entries : rhyme_entry list);
  sprintf "韵律数据分析: 总计%d个条目" total_count

(** ======================================================================== 
    高级韵律数据操作工具 - 简化版本
    ======================================================================== *)

(** 批量加载韵律文件 *)
let batch_load_rhyme_files config category_group_pairs =
  List.fold_left (fun acc (category, group) ->
    match find_rhyme_data_file config category group with
    | Some file_path -> 
        (match safe_load_json_file file_path with
         | Some data -> data :: acc
         | None -> acc)
    | None -> acc
  ) [] category_group_pairs

(** 简化的韵律数据加载器 - 无缓存 *)
let load_rhyme_data config category group =
  print_debug_info (sprintf "加载韵律数据: %s/%s" 
    (string_of_rhyme_category category) (string_of_rhyme_group group));
  let data = batch_load_rhyme_files config [(category, group)] in
  List.concat (List.map (fun json_data -> 
    create_rhyme_entries json_data.characters category group
  ) data)

(** 性能报告 *)
let performance_report config =
  let config_info = sprintf "韵律配置: 基础目录=%s" 
    config.base_dir in
  sprintf "韵律系统性能报告:\n%s" config_info

(** 简单缓存创建函数 - 提供基本的内存缓存功能 *)
let create_simple_cache capacity =
  let cache = Hashtbl.create capacity in
  let access_count = ref 0 in
  let hit_count = ref 0 in
  
  let get key =
    incr access_count;
    try 
      let value = Hashtbl.find cache key in
      incr hit_count;
      Some value
    with Not_found -> None
  in
  
  let put key value =
    if Hashtbl.length cache >= capacity then (
      (* 简单的LRU: 清空一半的缓存 *)
      let keys_to_remove = Hashtbl.fold (fun k _ acc -> k :: acc) cache [] in
      let remove_count = capacity / 2 in
      List.iteri (fun i key -> 
        if i < remove_count then Hashtbl.remove cache key
      ) keys_to_remove
    );
    Hashtbl.replace cache key value
  in
  
  let stats () = (!access_count, !hit_count) in
  
  (get, put, stats)