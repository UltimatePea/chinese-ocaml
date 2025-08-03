(** 统一数据管理器 - 整合版本
    
    将原本分离的data_manager_*模块整合为单一模块，减少文件数量
    同时保持所有功能完整性。
                                                           
    @author Whisky, PR Worker - Issue #2084 诗词模块整合
    @version 4.0 - 整合版本  
    @since 2025-08-03 - 文件整合Phase 1
    @fix_issue #2084 *)

(** {1 核心数据类型定义} *)

type unified_data_item = {
  character : string;
  category : Poetry_core.Json_core.rhyme_category;
  group : Poetry_core.Json_core.rhyme_group;
  metadata : (string * string) list;
}

type data_source_id =
  | RhymeData of string
  | PoetryData of string
  | ToneData of string
  | WordClassData of string

type query_criteria =
  | ByCharacter of string
  | ByCategory of Poetry_core.Json_core.rhyme_category
  | ByGroup of Poetry_core.Json_core.rhyme_group
  | BySource of data_source_id
  | CompositeQuery of query_criteria list

type data_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string * string

type 'a data_result = Success of 'a | Error of data_error

type cache_strategy = {
  enable_cache : bool;
  max_cache_size : int;
  ttl_seconds : float;
  eviction_policy : [ `LRU | `LFU | `FIFO ];
}

type cache_statistics = {
  total_queries : int;
  cache_hits : int;
  cache_misses : int;
  cache_size : int;
  hit_rate : float;
  last_cleanup : float;
}

type cache_entry = { 
  data : unified_data_item list; 
  timestamp : float; 
}

(** {1 内部存储和索引管理} *)

(* 字符索引 - O(1)查找优化 *)
let character_index = Hashtbl.create 10000

(* 韵组索引 - O(1)韵组查找优化 *)
let group_index = Hashtbl.create 100

(* 韵类索引 - O(1)韵类查找优化 *)
let category_index = Hashtbl.create 20

(* 索引状态跟踪 *)
let index_status = Hashtbl.create 10

(* 缓存配置 *)
let cache_config =
  ref { enable_cache = true; max_cache_size = 10000; ttl_seconds = 3600.0; eviction_policy = `LRU }

(* 缓存统计 *)
let cache_stats =
  ref
    {
      total_queries = 0;
      cache_hits = 0;
      cache_misses = 0;
      cache_size = 0;
      hit_rate = 0.0;
      last_cleanup = Unix.time ();
    }

(* 数据源注册表 *)
let registered_sources : (data_source_id, (unit -> unified_data_item list data_result) * int * string * float) Hashtbl.t = 
  Hashtbl.create 32

(* 查询缓存 *)
let query_cache = Hashtbl.create (!cache_config).max_cache_size

(** {1 索引构建和维护} *)

let rebuild_character_index data_list =
  Hashtbl.clear character_index;
  List.iter (fun item -> Hashtbl.replace character_index item.character item) data_list

let rebuild_group_index data_list =
  Hashtbl.clear group_index;
  List.iter
    (fun item ->
      let existing =
        match Hashtbl.find_opt group_index item.group with Some lst -> lst | None -> []
      in
      Hashtbl.replace group_index item.group (item.character :: existing))
    data_list

let rebuild_category_index data_list =
  Hashtbl.clear category_index;
  List.iter
    (fun item ->
      let existing =
        match Hashtbl.find_opt category_index item.category with Some lst -> lst | None -> []
      in
      Hashtbl.replace category_index item.category (item.character :: existing))
    data_list

let rebuild_all_indexes data_list =
  rebuild_character_index data_list;
  rebuild_group_index data_list;
  rebuild_category_index data_list

(** {1 快速查找接口} *)

let lookup_character char =
  match Hashtbl.find_opt character_index char with
  | Some item -> Success (Some item)
  | None -> Success None

let lookup_characters_by_group group =
  match Hashtbl.find_opt group_index group with
  | Some char_list -> Success char_list
  | None -> Success []

let lookup_characters_by_category category =
  match Hashtbl.find_opt category_index category with
  | Some char_list -> Success char_list
  | None -> Success []

(** {1 缓存管理} *)

let hash_criteria = function
  | ByCharacter s -> Hashtbl.hash ("char", s)
  | ByCategory c -> Hashtbl.hash ("category", c)
  | ByGroup g -> Hashtbl.hash ("group", g) 
  | BySource s -> Hashtbl.hash ("source", s)
  | CompositeQuery _ -> Hashtbl.hash ("composite", Random.int 1000)

let cache_get criteria =
  if not (!cache_config).enable_cache then None
  else
    let key = hash_criteria criteria in
    match Hashtbl.find_opt query_cache key with
    | Some entry when Unix.time () -. entry.timestamp < (!cache_config).ttl_seconds ->
        cache_stats := { !cache_stats with cache_hits = !cache_stats.cache_hits + 1 };
        Some entry.data
    | _ -> None

let cache_set criteria data =
  if (!cache_config).enable_cache then
    let key = hash_criteria criteria in
    let entry = { data; timestamp = Unix.time () } in
    Hashtbl.replace query_cache key entry;
    cache_stats := { !cache_stats with cache_size = Hashtbl.length query_cache }

(** {1 核心查询API} *)

let rec query_data criteria =
  cache_stats := { !cache_stats with total_queries = !cache_stats.total_queries + 1 };
  
  (* 尝试从缓存获取 *)
  match cache_get criteria with
  | Some cached_data -> Success cached_data
  | None ->
      cache_stats := { !cache_stats with cache_misses = !cache_stats.cache_misses + 1 };
      (* 缓存未命中，执行实际查询 *)
      let result = match criteria with
        | ByCharacter char -> 
            (match lookup_character char with
             | Success (Some item) -> Success [item]
             | Success None -> Success []
             | Error err -> Error err)
        | ByCategory category ->
            (match lookup_characters_by_category category with
             | Success char_list -> 
                 let rec convert_chars acc = function
                   | [] -> Success (List.rev acc)
                   | c :: rest ->
                       (match lookup_character c with
                        | Success (Some item) -> convert_chars (item :: acc) rest
                        | Success None -> 
                            Error (ValidationError ("character", "字符 '" ^ c ^ "' 不存在于索引中"))
                        | Error err -> Error err)
                 in
                 convert_chars [] char_list
             | Error err -> Error err)
        | ByGroup group ->
            (match lookup_characters_by_group group with
             | Success char_list ->
                 let rec convert_chars acc = function
                   | [] -> Success (List.rev acc)
                   | c :: rest ->
                       (match lookup_character c with
                        | Success (Some item) -> convert_chars (item :: acc) rest
                        | Success None -> 
                            Error (ValidationError ("character", "字符 '" ^ c ^ "' 不存在于索引中"))
                        | Error err -> Error err)
                 in
                 convert_chars [] char_list
             | Error err -> Error err)
        | BySource source_id ->
            (match Hashtbl.find_opt registered_sources source_id with
             | Some (loader, _, _, _) -> loader ()
             | None -> Error (FileNotFound "Source not registered"))
        | CompositeQuery criteria_list ->
            let rec process_queries acc = function
              | [] -> Success (List.flatten (List.rev acc))
              | crit :: rest ->
                  (match query_data crit with
                   | Success items -> process_queries (items :: acc) rest
                   | Error err -> Error err)
            in
            process_queries [] criteria_list
      in
      (* 将结果缓存 *)
      (match result with
       | Success data -> cache_set criteria data; result
       | Error _ -> result)

(** {1 数据源管理} *)

let register_source source_id loader priority description =
  let timestamp = Unix.time () in
  Hashtbl.replace registered_sources source_id (loader, priority, description, timestamp);
  Success ()

let get_registered_source source_id =
  Hashtbl.find_opt registered_sources source_id

let get_all_registered_sources () =
  Hashtbl.fold (fun source_id (_, priority, desc, ts) acc -> 
    (source_id, priority, desc, ts) :: acc
  ) registered_sources []

(** {1 配置管理} *)

let configure strategy =
  try
    cache_config := strategy;
    Success ()
  with exn ->
    Error (ValidationError ("cache_config", "Cache configuration failed: " ^ Printexc.to_string exn))

let get_cache_config () = !cache_config

let get_statistics () = 
  let current_stats = !cache_stats in
  let hit_rate = 
    if current_stats.total_queries > 0 then
      float_of_int current_stats.cache_hits /. float_of_int current_stats.total_queries
    else 0.0
  in
  { current_stats with hit_rate }

(** {1 索引管理} *)

let build_index source_list load_all_data_fn =
  try
    let all_data = load_all_data_fn () in
    rebuild_all_indexes all_data;
    List.iter (fun source_id -> Hashtbl.replace index_status source_id true) source_list;
    Success ()
  with exn ->
    Error (ValidationError ("index_build", "Index build failed: " ^ Printexc.to_string exn))

let is_index_built source_id =
  match Hashtbl.find_opt index_status source_id with Some status -> status | None -> false

let rebuild_index source_id =
  match get_registered_source source_id with
  | Some (loader, _, _, _) -> (
      match loader () with
      | Success items ->
          List.iter (fun item -> Hashtbl.replace character_index item.character item) items;
          Hashtbl.replace index_status source_id true;
          Success ()
      | Error err -> Error err)
  | None -> Error (FileNotFound "Source not found")

let get_index_statistics () =
  let char_count = Hashtbl.length character_index in
  let group_count = Hashtbl.length group_index in
  let category_count = Hashtbl.length category_index in
  (char_count, group_count, category_count)

(** {1 向后兼容性接口} *)

let get_legacy_rhyme_database load_all_data_fn =
  let all_data = load_all_data_fn () in
  List.map (fun item -> (item.character, item.category, item.group)) all_data

let is_char_in_database char =
  match lookup_character char with
  | Success (Some _) -> true
  | Success None -> false
  | Error _ -> false

let get_char_rhyme_info char =
  match lookup_character char with
  | Success (Some item) -> Some (item.character, item.category, item.group)
  | Success None -> None
  | Error _ -> None

let convert_to_legacy_format items =
  List.map (fun item -> (item.character, item.category, item.group)) items

let convert_from_legacy_format legacy_items =
  List.map 
    (fun (character, category, group) -> 
      { character; category; group; metadata = [] }) 
    legacy_items

let legacy_query_by_character char =
  match lookup_character char with
  | Success (Some item) -> Some [item]
  | Success None -> Some []
  | Error _ -> None

let legacy_query_by_group group =
  match lookup_characters_by_group group with
  | Success char_list ->
      let items = List.filter_map 
        (fun char -> match lookup_character char with
         | Success (Some item) -> Some item
         | _ -> None) 
        char_list in
      Some items
  | Error _ -> None

let legacy_query_by_category category =
  match lookup_characters_by_category category with
  | Success char_list ->
      let items = List.filter_map 
        (fun char -> match lookup_character char with
         | Success (Some item) -> Some item
         | _ -> None) 
        char_list in
      Some items
  | Error _ -> None

let legacy_error_to_string = function
  | FileNotFound msg -> msg
  | ParseError (file, msg) -> file ^ ": " ^ msg  
  | ValidationError (dtype, msg) -> dtype ^ ": " ^ msg