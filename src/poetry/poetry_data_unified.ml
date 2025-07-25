(* 诗词数据统一加载器 - 整合所有数据加载功能
   整合原有的多个数据加载器模块，提供统一的数据加载接口
   
   整合前：8个独立的数据加载器，功能重复，接口不一致
   整合后：1个统一加载器，接口统一，功能完整
   
   古云：一以贯之，方显大道。数据加载，当有统纲。
*)

open Poetry_core_types

(* 数据源类型定义 *)
type data_source =
  | JsonFile of string
  | FallbackData
  | StaticData of (string * rhyme_group_data) list

type data_source_entry = {
  name : string;
  source : data_source;
  priority : int;
  description : string;
}

(* 错误类型定义 *)
type data_error =
  | FileNotFound of string
  | ParseError of string
  | InvalidData of string
  | CacheError of string

exception DataError of data_error

let format_error = function
  | FileNotFound file -> Printf.sprintf "数据文件未找到: %s" file
  | ParseError msg -> Printf.sprintf "数据解析失败: %s" msg
  | InvalidData msg -> Printf.sprintf "数据格式无效: %s" msg
  | CacheError msg -> Printf.sprintf "缓存错误: %s" msg

(* 统一缓存模块 *)
module UnifiedCache = struct
  type cache_entry = { data : rhyme_data_file; timestamp : float; source_name : string }

  let cache_ttl = 600.0 (* 10分钟缓存 *)
  let cache_store = ref []

  let is_entry_valid entry =
    let current_time = Unix.time () in
    current_time -. entry.timestamp < cache_ttl

  let get source_name =
    try
      let entry = List.find (fun e -> e.source_name = source_name) !cache_store in
      if is_entry_valid entry then Some entry.data else None
    with Not_found -> None

  let set source_name data =
    let entry = { data; timestamp = Unix.time (); source_name } in
    cache_store := entry :: List.filter (fun e -> e.source_name <> source_name) !cache_store

  let clear () = cache_store := []
end

(* 文件工具模块 *)
module FileUtils = struct
  let get_project_root () =
    let rec find_root dir =
      let dune_project = Filename.concat dir "dune-project" in
      if Sys.file_exists dune_project then dir
      else
        let parent = Filename.dirname dir in
        if parent = dir then Sys.getcwd () else find_root parent
    in
    find_root (Sys.getcwd ())

  let safe_read_file filename =
    try
      let ic = open_in filename in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content
    with
    | Sys_error msg -> raise (DataError (FileNotFound msg))
    | _ -> raise (DataError (FileNotFound ("读取文件失败: " ^ filename)))

  let resolve_relative_path relative_path =
    let project_root = get_project_root () in
    Filename.concat project_root relative_path
end

(* JSON解析模块 *)
module JsonParser = struct
  let clean_string s =
    let s = String.trim s in
    let len = String.length s in
    if len = 0 then ""
    else
      let s = if s.[0] = '"' && len > 1 then String.sub s 1 (len - 1) else s in
      let s_len = String.length s in
      let s = if s_len > 0 && s.[s_len - 1] = ',' then String.sub s 0 (s_len - 1) else s in
      if String.length s > 0 && s.[String.length s - 1] = '"' then
        String.sub s 0 (String.length s - 1)
      else s

  type parse_state = {
    mutable current_group : string option;
    mutable current_category : string;
    mutable current_chars : string list;
    mutable result : (string * rhyme_group_data) list;
    mutable in_characters : bool;
    mutable depth : int;
  }

  let create_state () =
    {
      current_group = None;
      current_category = "";
      current_chars = [];
      result = [];
      in_characters = false;
      depth = 0;
    }

  let finalize_group state =
    match state.current_group with
    | Some name ->
        let group_data =
          { category = state.current_category; characters = List.rev state.current_chars }
        in
        state.result <- (name, group_data) :: state.result;
        state.current_group <- None;
        state.current_chars <- []
    | None -> ()

  let parse_simple_json content =
    try
      let lines = String.split_on_char '\n' content in
      let state = create_state () in

      List.iter
        (fun line ->
          let trimmed = String.trim line in

          (* 更新深度 *)
          String.iter
            (function
              | '{' | '[' -> state.depth <- state.depth + 1
              | '}' | ']' -> state.depth <- state.depth - 1
              | _ -> ())
            trimmed;

          (* 处理字符数组 *)
          if String.contains trimmed '[' && Str.string_match (Str.regexp ".*characters.*") line 0
          then state.in_characters <- true
          else if String.contains trimmed ']' && state.in_characters then
            state.in_characters <- false (* 处理键值对 *)
          else if String.contains trimmed ':' && not state.in_characters then
            let parts = String.split_on_char ':' trimmed in
            if List.length parts >= 2 then
              let key = clean_string (List.hd parts) in
              let value = clean_string (List.nth parts 1) in

              if key = "category" then state.current_category <- value
              else if key <> "characters" && key <> "metadata" && state.depth > 1 then (
                finalize_group state;
                state.current_group <- Some key;
                state.current_category <- "" (* 处理字符数据 *))
              else if state.in_characters then
                let char_data = clean_string trimmed in
                if char_data <> "" then state.current_chars <- char_data :: state.current_chars)
        lines;

      finalize_group state;
      List.rev state.result
    with exn -> raise (DataError (ParseError (Printexc.to_string exn)))
end

(* 数据源注册表 *)
module SourceRegistry = struct
  let registered_sources = ref []

  let register name source ?(priority = 0) description =
    let entry = { name; source; priority; description } in
    registered_sources := entry :: List.filter (fun e -> e.name <> name) !registered_sources;
    (* 按优先级排序 *)
    registered_sources := List.sort (fun a b -> compare b.priority a.priority) !registered_sources

  let get_all () = !registered_sources

  let get_by_name name =
    try Some (List.find (fun e -> e.name = name) !registered_sources) with Not_found -> None

  let get_names () = List.map (fun e -> e.name) !registered_sources
end

(* 数据加载核心模块 *)
module Loader = struct
  let load_from_json_file filename =
    let full_path =
      if Filename.is_relative filename then FileUtils.resolve_relative_path filename else filename
    in
    let content = FileUtils.safe_read_file full_path in
    let rhyme_groups = JsonParser.parse_simple_json content in
    { rhyme_groups; metadata = [] }

  let load_from_source source =
    match source with
    | JsonFile filename -> load_from_json_file filename
    | FallbackData ->
        let fallback_groups =
          [
            ("安韵", { category = "平声"; characters = [ "安"; "看"; "山" ] });
            ("思韵", { category = "仄声"; characters = [ "思"; "之"; "子" ] });
            ("天韵", { category = "平声"; characters = [ "天"; "年"; "先" ] });
            ("望韵", { category = "去声"; characters = [ "望"; "放"; "向" ] });
          ]
        in
        { rhyme_groups = fallback_groups; metadata = [] }
    | StaticData groups -> { rhyme_groups = groups; metadata = [] }

  let load_from_entry entry =
    match UnifiedCache.get entry.name with
    | Some cached_data -> cached_data
    | None ->
        let data = load_from_source entry.source in
        UnifiedCache.set entry.name data;
        data

  let load_from_name source_name =
    match SourceRegistry.get_by_name source_name with
    | Some entry -> load_from_entry entry
    | None -> raise (DataError (InvalidData ("数据源未注册: " ^ source_name)))
end

(* 降级数据处理 *)
module Fallback = struct
  let default_sources =
    [ { name = "fallback"; source = FallbackData; priority = -100; description = "降级数据源" } ]

  let register_defaults () =
    List.iter
      (fun entry ->
        SourceRegistry.register entry.name entry.source ~priority:entry.priority entry.description)
      default_sources

  let use_fallback_data () =
    Printf.eprintf "警告: 使用降级韵律数据\n%!";
    Loader.load_from_source FallbackData
end

(* 统一数据库类型定义 *)
type unified_database = {
  char_to_rhyme : (string, rhyme_category * rhyme_group) Hashtbl.t;
  rhyme_groups : (string * rhyme_group_data) list;
  source_info : string list;
}

(* 数据库构建和查询 *)
module Database = struct
  let build_database sources =
    let char_table = Hashtbl.create 1000 in
    let all_groups = ref [] in
    let source_names = ref [] in

    List.iter
      (fun source_name ->
        try
          let data = Loader.load_from_name source_name in
          source_names := source_name :: !source_names;
          List.iter
            (fun (group_name, group_data) ->
              all_groups := (group_name, group_data) :: !all_groups;
              let rhyme_category = string_to_rhyme_category group_data.category in
              let rhyme_group = string_to_rhyme_group group_name in
              List.iter
                (fun char ->
                  if not (Hashtbl.mem char_table char) then
                    Hashtbl.add char_table char (rhyme_category, rhyme_group))
                group_data.characters)
            data.rhyme_groups
        with exn -> Printf.eprintf "加载数据源 %s 失败: %s\n" source_name (Printexc.to_string exn))
      sources;

    {
      char_to_rhyme = char_table;
      rhyme_groups = List.rev !all_groups;
      source_info = List.rev !source_names;
    }

  let lookup_char database char =
    try Some (Hashtbl.find database.char_to_rhyme char) with Not_found -> None

  let get_statistics database =
    let total_chars = Hashtbl.length database.char_to_rhyme in
    let total_groups = List.length database.rhyme_groups in
    (total_groups, total_chars)
end

(* 主要API接口 *)

(* 初始化：注册默认数据源 *)
let () = Fallback.register_defaults ()

(* 数据源管理 *)
let register_source = SourceRegistry.register
let get_registered_sources = SourceRegistry.get_all
let get_source_names = SourceRegistry.get_names

(* 数据加载 *)
let load_data source_name = Loader.load_from_name source_name
let load_data_safe source_name = try load_data source_name with _ -> Fallback.use_fallback_data ()

(* 统一数据库 *)
let cached_database = ref None

let build_unified_database () =
  let source_names = get_source_names () in
  let database = Database.build_database source_names in
  cached_database := Some database;
  database

let get_unified_database () =
  match !cached_database with Some db -> db | None -> build_unified_database ()

(* 字符查询 *)
let lookup_char char =
  let database = get_unified_database () in
  Database.lookup_char database char

(* 统计信息 *)
let get_statistics () =
  let database = get_unified_database () in
  Database.get_statistics database

(* 缓存管理 *)
let clear_cache = UnifiedCache.clear

let refresh_data () =
  cached_database := None;
  UnifiedCache.clear ()

(* 标准数据源注册 *)
let register_standard_sources () =
  register_source "rhyme_data" (JsonFile "data/poetry/rhyme_groups/rhyme_data.json") ~priority:100
    "主要韵律数据";
  register_source "tone_data" (JsonFile "data/poetry/tone_data.json") ~priority:90 "声调数据";
  register_source "expanded_rhyme" (JsonFile "data/poetry/expanded_rhyme_data.json") ~priority:80
    "扩展韵律数据"

(* 初始化标准数据源 *)
let () = register_standard_sources ()
