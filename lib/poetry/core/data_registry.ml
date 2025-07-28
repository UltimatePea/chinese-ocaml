(** 数据注册中心 - 统一数据访问接口
    
    此模块提供Poetry模块所有数据的统一访问入点，
    整合原先分散在多个模块中的数据访问逻辑。
    
    替代模块：
    - unified_rhyme_registry.ml (510行)
    - poetry_data_unified.ml (527行) 
    - poetry_rhyme_data.ml (286行)
    - rhyme_data.ml (265行)
    
    Author: Alpha, 主工作代理
    @version 1.0 - Poetry重构统一版本
    @since 2025-07-28 - Fix #1561 *)

(** {1 导入依赖模块} *)

module Database = Poetry_data.Rhyme_database

(** {1 注册中心类型定义} *)

type registry_stats = {
  total_groups : int;
  total_characters : int;
  loaded_modules : string list;
  last_update : float;
}

type data_source = 
  | PrimaryDatabase     (* 主数据库 *)
  | CacheLayer         (* 缓存层 *)
  | ExternalSource of string  (* 外部数据源 *)

(** {1 全局注册中心状态} *)

let registry_state = ref {
  total_groups = 0;
  total_characters = 0;
  loaded_modules = [];
  last_update = 0.0;
}

let data_cache = ref (Hashtbl.create 100)

(** {1 数据注册接口} *)

(** 初始化注册中心 *)
let initialize_registry () =
  let groups = Database.all_rhyme_groups in
  let total_groups = List.length groups in
  let total_characters = List.length (Database.get_all_entries ()) in
  registry_state := {
    total_groups;
    total_characters;
    loaded_modules = ["rhyme_database"];
    last_update = Unix.time ();
  };
  Printf.printf "数据注册中心已初始化：%d个韵组，%d个字符\n" 
    total_groups total_characters

(** 注册新的数据源 *)
let register_data_source source_name data_loader =
  let current = !registry_state in
  registry_state := {
    current with 
    loaded_modules = source_name :: current.loaded_modules;
    last_update = Unix.time ();
  }

(** {1 统一数据访问接口} *)

(** 查找字符的韵律信息 - 带缓存 *)
let find_character_info character =
  let cache = !data_cache in
  match Hashtbl.find_opt cache character with
  | Some info -> Some info
  | None ->
      let info = Database.find_rhyme_info character in
      (match info with
       | Some entry -> Hashtbl.add cache character entry
       | None -> ());
      info

(** 检查两字符是否同韵 - 优化版本 *)
let check_rhyme_match char1 char2 =
  if char1 = char2 then true
  else
    match find_character_info char1, find_character_info char2 with
    | Some entry1, Some entry2 -> entry1.group = entry2.group
    | _ -> false

(** 获取韵组所有字符 - 带缓存 *)
let get_group_characters group =
  let cache_key = Printf.sprintf "group_%s" 
    (match group with
     | Database.An -> "an"
     | Database.En -> "en" 
     | Database.In -> "in"
     | Database.Un -> "un"
     | Database.Ang -> "ang"
     | Database.Eng -> "eng"
     | Database.Ing -> "ing"
     | Database.Ong -> "ong"
     | Database.Er -> "er"
     | Database.CustomGroup s -> s) in
  
  let cache = !data_cache in
  match Hashtbl.find_opt cache cache_key with
  | Some (Database.{ character; _ } as entry) -> [entry]
  | None ->
      let characters = Database.get_characters_by_group group in
      let entries = Database.get_entries_by_group group in
      List.iter (fun entry -> 
        Hashtbl.add cache entry.character entry) entries;
      entries

(** 批量查询字符韵组信息 *)
let batch_query_rhyme_groups characters =
  List.map (fun char ->
    match find_character_info char with
    | Some entry -> Some (char, entry.group, entry.category)
    | None -> None
  ) characters
  |> List.filter_map (fun x -> x)

(** {1 高级查询接口} *)

(** 查找所有同韵字符 *)
let find_rhyming_characters target_char =
  match find_character_info target_char with
  | Some entry ->
      let group_entries = Database.get_entries_by_group entry.group in
      List.map (fun e -> e.character) group_entries
  | None -> []

(** 按声调类别筛选字符 *)
let filter_by_category characters category =
  List.filter (fun char ->
    match find_character_info char with
    | Some entry -> entry.category = category
    | None -> false
  ) characters

(** 获取韵组统计信息 *)
let get_group_statistics group =
  let entries = Database.get_entries_by_group group in
  let ping_count = List.length (List.filter (fun e -> e.category = Database.PingSheng) entries) in
  let ze_count = List.length (List.filter (fun e -> e.category = Database.ZeSheng) entries) in
  let ru_count = List.length (List.filter (fun e -> e.category = Database.RuSheng) entries) in
  (List.length entries, ping_count, ze_count, ru_count)

(** {1 性能优化接口} *)

(** 预加载常用韵组到缓存 *)
let preload_common_groups () =
  let common_groups = [Database.An; Database.En; Database.In; Database.Un] in
  List.iter (fun group ->
    let entries = Database.get_entries_by_group group in
    List.iter (fun entry ->
      Hashtbl.add (!data_cache) entry.character entry
    ) entries
  ) common_groups

(** 清理缓存 *)
let clear_cache () =
  Hashtbl.clear (!data_cache)

(** 获取缓存统计 *)
let get_cache_stats () =
  let cache = !data_cache in
  let size = Hashtbl.length cache in
  let memory_usage = size * 64 in (* 估算每个条目64字节 *)
  (size, memory_usage)

(** {1 数据验证和诊断} *)

(** 验证数据完整性 *)
let validate_data_integrity () =
  try
    let is_valid = Database.validate_database () in
    let stats = !registry_state in
    Printf.printf "数据完整性验证%s\n" (if is_valid then "通过" else "失败");
    Printf.printf "注册模块：%s\n" (String.concat ", " stats.loaded_modules);
    is_valid
  with e -> 
    Printf.printf "验证过程出错：%s\n" (Printexc.to_string e);
    false

(** 生成诊断报告 *)
let generate_diagnostic_report () =
  let stats = !registry_state in
  let cache_size, cache_memory = get_cache_stats () in
  Printf.sprintf {|
=== 数据注册中心诊断报告 ===
注册状态：
  - 韵组总数：%d
  - 字符总数：%d  
  - 已加载模块：%s
  - 最后更新：%s

缓存状态：
  - 缓存条目：%d
  - 内存使用：%d字节

数据源：主数据库 (rhyme_database.ml)
状态：正常运行
|}
    stats.total_groups
    stats.total_characters
    (String.concat ", " stats.loaded_modules)
    (string_of_float stats.last_update)
    cache_size
    cache_memory

(** {1 兼容性接口} *)

(** 兼容旧版本的韵律查询接口 *)
module Legacy = struct
  
  (** 兼容 rhyme_core_unified.ml 的接口 *)
  let find_rhyme_entry = find_character_info
  
  (** 兼容 unified_rhyme_registry.ml 的接口 *)
  let lookup_character = find_character_info
  
  (** 兼容 poetry_rhyme_data.ml 的接口 *)
  let get_rhyme_data = find_character_info
  
  (** 兼容检查接口 *)
  let is_same_rhyme = check_rhyme_match
  
end

(** {1 模块初始化} *)

(** 模块加载时自动初始化 *)
let () = 
  initialize_registry ();
  preload_common_groups ()