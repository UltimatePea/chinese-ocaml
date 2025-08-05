(** 统一数据管理器 - 整合版本
    
    将原本分散在多个文件中的数据管理功能整合到单一模块中。
    这个整合遵循Poetry模块整合原则，减少文件数量。
    
    整合的模块包括:
    - data_manager_types.ml (类型定义)
    - data_manager_query.ml (查询缓存)  
    - data_manager_lookup.ml (索引查找)
    - data_manager_storage.ml (存储管理)
    - data_manager_compat.ml (兼容性接口)
                                                           
    @author Whisky, PR Worker - Poetry模块整合专员
    @version 4.0 - 整合版本
    @since 2025-08-04 - Poetry模块整合Phase 1
    @fix_issue #1999 *)

(** {1 核心数据类型定义} *)

type unified_data_item = {
  character : string;
  category : string;
  group : string;
  metadata : (string * string) list;
}

type data_source_id =
  | RhymeData of string
  | PoetryData of string
  | ToneData of string
  | WordClassData of string

type query_criteria =
  | ByCharacter of string
  | ByCategory of string
  | ByGroup of string
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

type cache_entry = { data : unified_data_item list; timestamp : float }

(** {1 内部状态管理} *)

(* 索引表 *)
let character_index = Hashtbl.create 10000
let group_index = Hashtbl.create 100
let category_index = Hashtbl.create 20

(* 缓存表 *)
let cache_table = Hashtbl.create 1000
let access_order = Queue.create ()

(* 数据源注册表 *)
let registered_sources = Hashtbl.create 50

(* 配置和统计 *)
let cache_config_ref = ref None

let stats_ref =
  ref
    {
      total_queries = 0;
      cache_hits = 0;
      cache_misses = 0;
      cache_size = 0;
      hit_rate = 0.0;
      last_cleanup = Unix.time ();
    }

(** {1 索引管理功能} *)

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

(** {1 查找功能} *)

let lookup_character character =
  match Hashtbl.find_opt character_index character with
  | Some item -> Success (Some item)
  | None -> Success None

let lookup_characters_by_group group =
  match Hashtbl.find_opt group_index group with Some chars -> Success chars | None -> Success []

let lookup_characters_by_category category =
  match Hashtbl.find_opt category_index category with
  | Some chars -> Success chars
  | None -> Success []

(** {1 缓存管理功能} *)

let get_cache_config () =
  match !cache_config_ref with
  | Some config -> config
  | None ->
      { enable_cache = true; max_cache_size = 10000; ttl_seconds = 3600.0; eviction_policy = `LRU }

let set_cache_config config = cache_config_ref := Some config

let cache_key_of_criteria criteria =
  let rec serialize = function
    | ByCharacter s -> "char:" ^ s
    | ByCategory cat -> "cat:" ^ (Obj.repr cat |> Obj.tag |> string_of_int)
    | ByGroup grp -> "grp:" ^ (Obj.repr grp |> Obj.tag |> string_of_int)
    | BySource src -> (
        "src:"
        ^
        match src with
        | RhymeData s -> "rhyme:" ^ s
        | PoetryData s -> "poetry:" ^ s
        | ToneData s -> "tone:" ^ s
        | WordClassData s -> "word:" ^ s)
    | CompositeQuery lst -> "comp:[" ^ String.concat ";" (List.map serialize lst) ^ "]"
  in
  serialize criteria

let get_from_cache criteria =
  let config = get_cache_config () in
  let key = cache_key_of_criteria criteria in
  match Hashtbl.find_opt cache_table key with
  | Some entry ->
      let now = Unix.time () in
      if now -. entry.timestamp < config.ttl_seconds then (
        stats_ref :=
          {
            !stats_ref with
            total_queries = !stats_ref.total_queries + 1;
            cache_hits = !stats_ref.cache_hits + 1;
            hit_rate = float_of_int !stats_ref.cache_hits /. float_of_int !stats_ref.total_queries;
          };
        Queue.push key access_order;
        Some entry.data)
      else (
        Hashtbl.remove cache_table key;
        None)
  | None ->
      stats_ref :=
        {
          !stats_ref with
          total_queries = !stats_ref.total_queries + 1;
          cache_misses = !stats_ref.cache_misses + 1;
          hit_rate = float_of_int !stats_ref.cache_hits /. float_of_int !stats_ref.total_queries;
        };
      None

let put_in_cache criteria data =
  let config = get_cache_config () in
  if config.enable_cache then (
    let key = cache_key_of_criteria criteria in
    let entry = { data; timestamp = Unix.time () } in

    (* LRU eviction if cache is full *)
    (if Hashtbl.length cache_table >= config.max_cache_size then
       try
         let old_key = Queue.take access_order in
         Hashtbl.remove cache_table old_key
       with Queue.Empty -> ());

    Hashtbl.replace cache_table key entry;
    Queue.push key access_order;
    stats_ref := { !stats_ref with cache_size = Hashtbl.length cache_table })

(** {1 数据源管理} *)

let register_data_source source_id loader validator metadata =
  Hashtbl.replace registered_sources source_id (loader, validator, metadata, Unix.time ())

let get_registered_source source_id = Hashtbl.find_opt registered_sources source_id
let list_registered_sources () = Hashtbl.fold (fun k _v acc -> k :: acc) registered_sources []
let get_registered_sources = list_registered_sources
let unregister_data_source source_id = Hashtbl.remove registered_sources source_id

(** {1 主要查询接口} *)

let rec query_data criteria =
  (* 尝试从缓存获取 *)
  match get_from_cache criteria with
  | Some cached_data -> Success cached_data
  | None -> (
      (* 缓存未命中，执行实际查询 *)
      let result =
        match criteria with
        | ByCharacter char -> (
            match lookup_character char with
            | Success (Some item) -> Success [ item ]
            | Success None -> Success []
            | Error err -> Error err)
        | ByCategory category -> (
            match lookup_characters_by_category category with
            | Success char_list ->
                let rec convert_chars acc = function
                  | [] -> Success (List.rev acc)
                  | c :: rest -> (
                      match lookup_character c with
                      | Success (Some item) -> convert_chars (item :: acc) rest
                      | Success None ->
                          Error (ValidationError ("character", "字符 '" ^ c ^ "' 不存在于索引中"))
                      | Error err -> Error err)
                in
                convert_chars [] char_list
            | Error err -> Error err)
        | ByGroup group -> (
            match lookup_characters_by_group group with
            | Success char_list ->
                let rec convert_chars acc = function
                  | [] -> Success (List.rev acc)
                  | c :: rest -> (
                      match lookup_character c with
                      | Success (Some item) -> convert_chars (item :: acc) rest
                      | Success None ->
                          Error (ValidationError ("character", "字符 '" ^ c ^ "' 不存在于索引中"))
                      | Error err -> Error err)
                in
                convert_chars [] char_list
            | Error err -> Error err)
        | BySource source_id -> (
            match get_registered_source source_id with
            | Some (loader, _, _, _) -> loader ()
            | None -> Error (FileNotFound "Source not found"))
        | CompositeQuery criteria_list ->
            let results = List.map query_data criteria_list in
            let rec collect_results acc = function
              | [] -> Success (List.flatten (List.rev acc))
              | Success items :: rest -> collect_results (items :: acc) rest
              | Error err :: _ -> Error err
            in
            collect_results [] results
      in
      (* 将结果放入缓存 *)
      match result with
      | Success data ->
          put_in_cache criteria data;
          result
      | Error _ -> result)

let batch_query criteria_list =
  let results = List.map query_data criteria_list in
  let rec collect_results acc = function
    | [] -> Success (List.rev acc)
    | Success items :: rest -> collect_results (items :: acc) rest
    | Error err :: _ -> Error err
  in
  collect_results [] results

(** {1 兼容性接口} *)

let get_char_rhyme_info character =
  match lookup_character character with
  | Success (Some item) -> Success (Some (item.group, item.category))
  | Success None -> Success None
  | Error err -> Error err

let legacy_query_by_character char =
  match lookup_character char with Success (Some item) -> Some item.group | _ -> None

let legacy_query_by_group group =
  match lookup_characters_by_group group with Success chars -> chars | Error _ -> []

(** {1 管理和统计接口} *)

let get_cache_statistics () = !stats_ref
let configure config = set_cache_config config
let configure_cache = configure

let clear_cache () =
  Hashtbl.clear cache_table;
  Queue.clear access_order;
  stats_ref :=
    {
      cache_size = 0;
      cache_hits = 0;
      cache_misses = 0;
      total_queries = 0;
      hit_rate = 0.0;
      last_cleanup = Unix.time ();
    }

let get_cache_size () = Hashtbl.length cache_table
let is_cache_enabled () = (get_cache_config ()).enable_cache

let get_index_statistics () =
  [
    ("character_index_size", string_of_int (Hashtbl.length character_index));
    ("group_index_size", string_of_int (Hashtbl.length group_index));
    ("category_index_size", string_of_int (Hashtbl.length category_index));
  ]

let rebuild_indexes data_list = rebuild_all_indexes data_list
let initialize_data_manager () = ()

let cleanup_data_manager () =
  clear_cache ();
  ()

let health_check () =
  let cache_enabled = is_cache_enabled () in
  let cache_size = get_cache_size () in
  let has_sources = List.length (list_registered_sources ()) > 0 in
  cache_enabled && cache_size >= 0 && has_sources

(** {1 直接查找接口} *)

let lookup_by_character = lookup_character
let lookup_by_group = lookup_characters_by_group
let lookup_by_category = lookup_characters_by_category

(** {1 向后兼容性接口} *)

let get_character_rhyme_info = get_char_rhyme_info
let find_rhyme_group = legacy_query_by_character
let find_characters_by_rhyme = legacy_query_by_group
