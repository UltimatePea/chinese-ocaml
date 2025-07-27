(** JSON数据加载器 - 统一数据源加载
    
    此模块提供从JSON文件加载韵律数据的功能，支持：
    - 标准化JSON格式解析
    - 数据验证和错误处理
    - 批量数据加载
    - 增量数据更新
    
    技术债务修复：统一分散的JSON处理逻辑，建立标准化数据加载机制。
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (统一架构版)
    @since 2025-07-27
    @fix_issue #1501 *)

open Poetry_types.Rhyme_types
open Yojson.Safe.Util

(** {1 异常定义} *)

exception JsonLoaderError of string

(** {1 JSON解析辅助函数} *)

(** 解析韵类 *)
let parse_rhyme_category json =
  let category_str = json |> to_string in
  match string_to_rhyme_category category_str with
  | Some category -> category
  | None -> 
      raise (JsonLoaderError ("Unknown rhyme category: " ^ category_str))

(** 解析韵组 *)
let parse_rhyme_group json =
  let group_str = json |> to_string in
  match string_to_rhyme_group group_str with
  | Some group -> group
  | None ->
      raise (JsonLoaderError ("Unknown rhyme group: " ^ group_str))

(** 解析韵律数据项 *)
let parse_rhyme_data_item json source =
  try
    let character = json |> member "char" |> to_string in
    let tone_value = 
      try Some (json |> member "tone_value" |> to_int)
      with Type_error _ -> None
    in
    let frequency = 
      try Some (json |> member "frequency" |> to_float)
      with Type_error _ -> None
    in
    
    {
      character;
      category = PingSheng; (* 默认值，将被组级别的类别覆盖 *)
      group = UnknownRhyme;  (* 默认值，将被组级别的韵组覆盖 *)
      tone_value;
      frequency;
      source;
    }
  with
  | Type_error (msg, _) -> 
      raise (JsonLoaderError ("Failed to parse rhyme data item: " ^ msg))
  | Not_found -> 
      raise (JsonLoaderError "Missing required fields in rhyme data item")

(** 解析韵组数据 *)
let parse_rhyme_group_data json source =
  try
    let group = json |> member "group" |> parse_rhyme_group in
    let category = json |> member "category" |> parse_rhyme_category in
    let characters_json = json |> member "characters" |> to_list in
    
    let items = 
      characters_json
      |> List.map (fun char_json -> 
           let item = parse_rhyme_data_item char_json source in
           { item with category; group })
    in
    
    let metadata = 
      try
        json |> member "metadata" |> to_assoc 
        |> List.map (fun (k, v) -> (k, v |> to_string))
      with Type_error _ -> []
    in
    
    create_rhyme_group_data group items metadata
    
  with
  | Type_error (msg, _) -> 
      raise (JsonLoaderError ("Failed to parse rhyme group data: " ^ msg))
  | Not_found -> 
      raise (JsonLoaderError "Missing required fields in rhyme group data")

(** 解析韵律数据库 *)
let parse_rhyme_database json source =
  try
    let db_json = json |> member "rhyme_database" in
    let version = db_json |> member "version" |> to_string in
    let last_updated = db_json |> member "last_updated" |> to_string in
    let sources = 
      try db_json |> member "sources" |> to_list |> List.map to_string
      with Type_error _ -> [source]
    in
    let groups_json = db_json |> member "groups" |> to_list in
    
    let groups = 
      groups_json |> List.map (fun group_json -> 
        parse_rhyme_group_data group_json source)
    in
    
    {
      groups;
      version;
      last_updated;
      sources;
    }
    
  with
  | Type_error (msg, _) -> 
      raise (JsonLoaderError ("Failed to parse rhyme database: " ^ msg))
  | Not_found -> 
      raise (JsonLoaderError "Missing required fields in rhyme database")

(** {1 文件加载功能} *)

(** 从文件加载JSON *)
let load_json_from_file filename =
  try
    Yojson.Safe.from_file filename
  with
  | Sys_error msg -> 
      raise (JsonLoaderError ("Failed to read file " ^ filename ^ ": " ^ msg))
  | Yojson.Json_error msg -> 
      raise (JsonLoaderError ("Invalid JSON in file " ^ filename ^ ": " ^ msg))

(** 从字符串加载JSON *)
let load_json_from_string content =
  try
    Yojson.Safe.from_string content
  with
  | Yojson.Json_error msg -> 
      raise (JsonLoaderError ("Invalid JSON content: " ^ msg))

(** {1 主要加载函数} *)

(** 从JSON文件加载韵律数据库 *)
let load_rhyme_database_from_file filename =
  let json = load_json_from_file filename in
  parse_rhyme_database json filename

(** 从JSON字符串加载韵律数据库 *)
let load_rhyme_database_from_string content source =
  let json = load_json_from_string content in
  parse_rhyme_database json source

(** 批量加载多个JSON文件 *)
let load_multiple_files filenames =
  let load_single_file filename =
    try
      Some (load_rhyme_database_from_file filename)
    with JsonLoaderError msg ->
      Printf.eprintf "Warning: Failed to load %s: %s\n" filename msg;
      None
  in
  
  filenames
  |> List.map load_single_file
  |> List.filter_map (fun x -> x)

(** 合并多个韵律数据库 *)
let merge_databases databases =
  match databases with
  | [] -> create_empty_database ()
  | first :: _rest ->
      let all_groups = 
        databases
        |> List.map (fun db -> db.groups)
        |> List.flatten
      in
      
      let all_sources = 
        databases
        |> List.map (fun db -> db.sources)
        |> List.flatten
        |> List.sort_uniq String.compare
      in
      
      let latest_version = 
        databases
        |> List.map (fun db -> db.version)
        |> List.fold_left max first.version
      in
      
      let latest_update = 
        databases
        |> List.map (fun db -> db.last_updated)
        |> List.fold_left max first.last_updated
      in
      
      {
        groups = all_groups;
        version = latest_version;
        last_updated = latest_update;
        sources = all_sources;
      }

(** {1 验证功能} *)

(** 验证JSON格式 *)
let validate_json_format json =
  try
    let _ = json |> member "rhyme_database" in
    let db_json = json |> member "rhyme_database" in
    let _ = db_json |> member "version" |> to_string in
    let _ = db_json |> member "last_updated" |> to_string in
    let _ = db_json |> member "groups" |> to_list in
    true
  with
  | Type_error _ | Not_found -> false

(** 验证文件格式 *)
let validate_file_format filename =
  try
    let json = load_json_from_file filename in
    validate_json_format json
  with JsonLoaderError _ -> false

(** {1 示例数据生成} *)

(** 生成示例JSON结构 *)
let generate_sample_json () =
  `Assoc [
    ("rhyme_database", `Assoc [
      ("version", `String "2.0");
      ("last_updated", `String "2025-07-27");
      ("sources", `List [`String "平水韵"; `String "中华新韵"]);
      ("groups", `List [
        `Assoc [
          ("group", `String "花韵");
          ("category", `String "平声");
          ("characters", `List [
            `Assoc [
              ("char", `String "花");
              ("tone_value", `Int 1);
              ("frequency", `Float 0.95);
            ];
            `Assoc [
              ("char", `String "霞");
              ("tone_value", `Int 1);
              ("frequency", `Float 0.87);
            ];
          ]);
          ("metadata", `Assoc [
            ("description", `String "花霞家茶，春花秋月韵味深");
            ("usage", `String "适合描写自然美景和生活情趣");
          ]);
        ];
      ]);
    ]);
  ]

(** 生成示例JSON文件 *)
let create_sample_file filename =
  let sample_json = generate_sample_json () in
  let json_string = Yojson.Safe.pretty_to_string sample_json in
  let oc = open_out filename in
  output_string oc json_string;
  close_out oc

(** {1 实用工具} *)

(** 统计JSON数据库信息 *)
let analyze_json_database filename =
  try
    let database = load_rhyme_database_from_file filename in
    let total_groups = List.length database.groups in
    let total_items = 
      database.groups
      |> List.map (fun group -> List.length group.items)
      |> List.fold_left (+) 0
    in
    let group_stats = 
      database.groups
      |> List.map (fun group -> 
           (rhyme_group_to_string group.group, List.length group.items))
    in
    
    [
      ("total_groups", string_of_int total_groups);
      ("total_items", string_of_int total_items);
      ("version", database.version);
      ("last_updated", database.last_updated);
      ("sources", String.concat ", " database.sources);
    ] @ (List.map (fun (group, count) -> 
           ("group_" ^ group, string_of_int count)) group_stats)
    
  with JsonLoaderError msg ->
    [("error", msg)]