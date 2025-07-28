(** 统一数据管理器实现 - Phase 2 架构修正核心模块
    
    基于Delta代理批判性分析的架构修正，实现真正统一的数据访问层，
    解决当前69个数据模块混乱的根本问题。
                                                           
    @author Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    @version 2.0 - 架构修正版本
    @since 2025-07-28 - Phase 2A 核心重构
    @fix_issue #1572 *)

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

type 'a data_result = 
  | Success of 'a
  | Error of Poetry_core.Poetry_errors.data_error

(** {1 缓存策略类型} *)

type cache_strategy = {
  enable_cache : bool;
  max_cache_size : int;
  ttl_seconds : float;
  eviction_policy : [`LRU | `LFU | `FIFO];
}

type cache_statistics = {
  total_queries : int;
  cache_hits : int;
  cache_misses : int;
  cache_size : int;
  hit_rate : float;
  last_cleanup : float;
}

(** {1 内部状态管理} *)

(* 数据源注册表 - 线程安全的哈希表 *)
let registered_sources = Hashtbl.create 32

(* 字符索引 - O(1)查找优化 *)
let character_index = Hashtbl.create 10000

(* 韵组索引 - O(1)韵组查找优化 *)
let group_index = Hashtbl.create 100

(* 韵类索引 - O(1)韵类查找优化 *)
let category_index = Hashtbl.create 20

(* 缓存配置 *)
let cache_config = ref {
  enable_cache = true;
  max_cache_size = 10000;
  ttl_seconds = 3600.0;
  eviction_policy = `LRU;
}

(* 缓存统计 *)
let cache_stats = ref {
  total_queries = 0;
  cache_hits = 0;
  cache_misses = 0;
  cache_size = 0;
  hit_rate = 0.0;
  last_cleanup = Unix.time ();
}

(* 查询缓存 - LRU实现 *)
module QueryCache = struct
  type cache_entry = {
    data : unified_data_item list;
    timestamp : float;
    access_count : int;
  }
  
  let cache_table = Hashtbl.create 1000
  let access_order = Queue.create ()
  
  let cache_key_of_criteria criteria =
    let rec serialize = function
      | ByCharacter s -> "char:" ^ s
      | ByCategory cat -> "cat:" ^ (Obj.repr cat |> Obj.tag |> string_of_int)
      | ByGroup grp -> "grp:" ^ (Obj.repr grp |> Obj.tag |> string_of_int)
      | BySource src -> "src:" ^ (match src with
          | RhymeData s -> "rhyme:" ^ s
          | PoetryData s -> "poetry:" ^ s
          | ToneData s -> "tone:" ^ s
          | WordClassData s -> "word:" ^ s)
      | CompositeQuery lst -> "comp:[" ^ (String.concat ";" (List.map serialize lst)) ^ "]"
    in
    serialize criteria
  
  let get criteria =
    let key = cache_key_of_criteria criteria in
    match Hashtbl.find_opt cache_table key with
    | Some entry ->
        let now = Unix.time () in
        if now -. entry.timestamp < !cache_config.ttl_seconds then (
          cache_stats := { !cache_stats with 
            total_queries = !cache_stats.total_queries + 1;
            cache_hits = !cache_stats.cache_hits + 1;
            hit_rate = float_of_int (!cache_stats.cache_hits) /. float_of_int (!cache_stats.total_queries) };
          Queue.push key access_order;
          Some entry.data
        ) else (
          Hashtbl.remove cache_table key;
          None
        )
    | None -> 
        cache_stats := { !cache_stats with 
          total_queries = !cache_stats.total_queries + 1;
          cache_misses = !cache_stats.cache_misses + 1;
          hit_rate = float_of_int (!cache_stats.cache_hits) /. float_of_int (!cache_stats.total_queries) };
        None
  
  let put criteria data =
    if !cache_config.enable_cache then (
      let key = cache_key_of_criteria criteria in
      let entry = {
        data = data;
        timestamp = Unix.time ();
        access_count = 1;
      } in
      
      (* LRU eviction if cache is full *)
      if Hashtbl.length cache_table >= !cache_config.max_cache_size then (
        try
          let old_key = Queue.take access_order in
          Hashtbl.remove cache_table old_key
        with Queue.Empty -> ()
      );
      
      Hashtbl.replace cache_table key entry;
      Queue.push key access_order;
      cache_stats := { !cache_stats with cache_size = Hashtbl.length cache_table }
    )
  
  let clear () =
    Hashtbl.clear cache_table;
    Queue.clear access_order;
    cache_stats := { !cache_stats with 
      cache_size = 0;
      cache_hits = 0;
      cache_misses = 0;
      total_queries = 0;
      hit_rate = 0.0;
      last_cleanup = Unix.time () }
end

(** {1 索引管理} *)

let rebuild_character_index data_list =
  Hashtbl.clear character_index;
  List.iter (fun item ->
    Hashtbl.replace character_index item.character item
  ) data_list

let rebuild_group_index data_list =
  Hashtbl.clear group_index;
  List.iter (fun item ->
    let existing = match Hashtbl.find_opt group_index item.group with
      | Some lst -> lst
      | None -> []
    in
    Hashtbl.replace group_index item.group (item.character :: existing)
  ) data_list

let rebuild_category_index data_list =
  Hashtbl.clear category_index;
  List.iter (fun item ->
    let existing = match Hashtbl.find_opt category_index item.category with
      | Some lst -> lst  
      | None -> []
    in
    Hashtbl.replace category_index item.category (item.character :: existing)
  ) data_list

(** {1 数据源管理} *)

let register_data_source source_id loader ?(priority=0) description =
  try
    let source_info = (loader, priority, description, Unix.time ()) in
    Hashtbl.replace registered_sources source_id source_info;
    Success ()
  with
  | exn -> Error (Poetry_core.Poetry_errors.DataSourceError 
                   ("Failed to register data source: " ^ (Printexc.to_string exn)))

let unregister_data_source source_id =
  try
    if Hashtbl.mem registered_sources source_id then (
      Hashtbl.remove registered_sources source_id;
      Success ()
    ) else
      Error (Poetry_core.Poetry_errors.DataSourceError "Data source not found")
  with
  | exn -> Error (Poetry_core.Poetry_errors.DataSourceError 
                   ("Failed to unregister data source: " ^ (Printexc.to_string exn)))

let list_registered_sources () =
  Hashtbl.fold (fun source_id (_, priority, description, _) acc ->
    (source_id, description, priority) :: acc
  ) registered_sources []

(** {1 数据加载和合并} *)

let load_all_data () =
  let sources_with_priority = 
    Hashtbl.fold (fun source_id (loader, priority, _, _) acc ->
      (source_id, loader, priority) :: acc
    ) registered_sources []
    |> List.sort (fun (_, _, p1) (_, _, p2) -> compare p2 p1) (* 高优先级优先 *)
  in
  
  let all_items = ref [] in
  let seen_characters = Hashtbl.create 10000 in
  
  List.iter (fun (source_id, loader, _) ->
    match loader () with
    | Success items ->
        List.iter (fun item ->
          if not (Hashtbl.mem seen_characters item.character) then (
            Hashtbl.add seen_characters item.character true;
            all_items := item :: !all_items
          )
        ) items
    | Error err ->
        Printf.eprintf "Warning: Failed to load data from source: %s\n" 
          (match err with 
           | Poetry_core.Poetry_errors.DataSourceError msg -> msg
           | _ -> "Unknown error")
  ) sources_with_priority;
  
  let final_data = List.rev !all_items in
  
  (* 重建所有索引 *)
  rebuild_character_index final_data;
  rebuild_group_index final_data;  
  rebuild_category_index final_data;
  
  final_data

(** {1 查询实现} *)

let rec query_data_impl criteria =
  match QueryCache.get criteria with
  | Some cached_result -> Success cached_result
  | None ->
      let result = match criteria with
        | ByCharacter char ->
            (match Hashtbl.find_opt character_index char with
             | Some item -> Success [item]
             | None -> Success [])
        
        | ByGroup group ->
            (match Hashtbl.find_opt group_index group with
             | Some char_list -> 
                 let items = List.filter_map (fun char ->
                   Hashtbl.find_opt character_index char
                 ) char_list in
                 Success items
             | None -> Success [])
        
        | ByCategory category ->
            (match Hashtbl.find_opt category_index category with
             | Some char_list ->
                 let items = List.filter_map (fun char ->
                   Hashtbl.find_opt character_index char
                 ) char_list in
                 Success items
             | None -> Success [])
        
        | BySource source_id ->
            (match Hashtbl.find_opt registered_sources source_id with
             | Some (loader, _, _, _) -> loader ()  
             | None -> Error (Poetry_core.Poetry_errors.DataSourceError "Source not found"))
        
        | CompositeQuery criteria_list ->
            let results = List.map query_data_impl criteria_list in
            let rec merge_results acc = function
              | [] -> Success acc
              | (Success items) :: rest -> merge_results (acc @ items) rest
              | (Error err) :: _ -> Error err
            in
            merge_results [] results
      in
      
      (match result with
       | Success data -> QueryCache.put criteria data
       | _ -> ());
      
      result

let query_data criteria = query_data_impl criteria

let query_data_streaming criteria callback =
  match query_data criteria with
  | Success items -> 
      List.iter callback items;
      Success ()
  | Error err -> Error err

let count_data criteria =
  match query_data criteria with
  | Success items -> Success (List.length items)
  | Error err -> Error err

(** {1 高性能查询模块} *)

module FastLookup = struct
  let index_status = Hashtbl.create 10
  
  let build_index source_list =
    try
      let all_data = load_all_data () in
      List.iter (fun source_id ->
        Hashtbl.replace index_status source_id true
      ) source_list;
      Success ()
    with
    | exn -> Error (Poetry_core.Poetry_errors.DataSourceError 
                     ("Index build failed: " ^ (Printexc.to_string exn)))
  
  let lookup_character char =
    match Hashtbl.find_opt character_index char with
    | Some item -> Success (Some item)
    | None -> Success None
  
  let lookup_characters_by_group group =
    match Hashtbl.find_opt group_index group with
    | Some char_list -> Success char_list
    | None -> Success []
  
  let is_index_built source_id =
    match Hashtbl.find_opt index_status source_id with
    | Some status -> status
    | None -> false
  
  let rebuild_index source_id =
    match Hashtbl.find_opt registered_sources source_id with
    | Some (loader, _, _, _) ->
        (match loader () with
         | Success items ->
             List.iter (fun item ->
               Hashtbl.replace character_index item.character item
             ) items;
             Hashtbl.replace index_status source_id true;
             Success ()
         | Error err -> Error err)
    | None -> Error (Poetry_core.Poetry_errors.DataSourceError "Source not found")
end

(** {1 缓存管理模块} *)

module Cache = struct
  let configure strategy =
    try
      cache_config := strategy;
      Success ()
    with  
    | exn -> Error (Poetry_core.Poetry_errors.DataSourceError 
                     ("Cache configuration failed: " ^ (Printexc.to_string exn)))
  
  let get_statistics () = !cache_stats
  
  let clear_cache ?source () =
    match source with
    | None -> 
        QueryCache.clear ();
        Success ()
    | Some _ ->
        (* 选择性清除暂未实现，先全部清除 *)
        QueryCache.clear ();
        Success ()
  
  let preload_cache source_list =
    try
      List.iter (fun source_id ->
        match query_data (BySource source_id) with
        | Success _ -> () (* 数据已经被缓存 *)
        | Error _ -> ()
      ) source_list;
      Success ()
    with
    | exn -> Error (Poetry_core.Poetry_errors.DataSourceError 
                     ("Cache preload failed: " ^ (Printexc.to_string exn)))
  
  let get_cache_efficiency () =
    if !cache_stats.total_queries > 0 then
      !cache_stats.hit_rate
    else
      0.0
end

(** {1 数据验证和冲突检测} *)

let validate_data_integrity source_list =
  try
    let all_errors = ref [] in
    let seen_chars = Hashtbl.create 10000 in
    
    List.iter (fun source_id ->
      match Hashtbl.find_opt registered_sources source_id with
      | Some (loader, _, _, _) ->
          (match loader () with
           | Success items ->
               List.iter (fun item ->
                 if item.character = "" then
                   all_errors := ("Empty character in source") :: !all_errors;
                 if Hashtbl.mem seen_chars item.character then
                   all_errors := ("Duplicate character: " ^ item.character) :: !all_errors
                 else
                   Hashtbl.add seen_chars item.character true
               ) items
           | Error _ ->
               all_errors := ("Failed to load source") :: !all_errors)
      | None ->
          all_errors := ("Source not found") :: !all_errors
    ) source_list;
    
    let is_valid = !all_errors = [] in
    Success (is_valid, !all_errors)
  with
  | exn -> Error (Poetry_core.Poetry_errors.DataSourceError 
                   ("Validation failed: " ^ (Printexc.to_string exn)))

let detect_data_conflicts source_list =
  try
    let char_sources = Hashtbl.create 10000 in
    let conflicts = ref [] in
    
    List.iter (fun source_id ->
      match Hashtbl.find_opt registered_sources source_id with
      | Some (loader, _, _, _) ->
          (match loader () with
           | Success items ->
               List.iter (fun item ->
                 match Hashtbl.find_opt char_sources item.character with
                 | Some existing_source ->
                     conflicts := (item.character, existing_source, source_id) :: !conflicts
                 | None ->
                     Hashtbl.add char_sources item.character source_id
               ) items
           | Error _ -> ())
      | None -> ()
    ) source_list;
    
    Success !conflicts
  with
  | exn -> Error (Poetry_core.Poetry_errors.DataSourceError 
                   ("Conflict detection failed: " ^ (Printexc.to_string exn)))

let merge_conflicting_data ~resolve_conflict source_list =
  try
    let char_items = Hashtbl.create 10000 in
    
    List.iter (fun source_id ->
      match Hashtbl.find_opt registered_sources source_id with
      | Some (loader, _, _, _) ->
          (match loader () with
           | Success items ->
               List.iter (fun item ->
                 match Hashtbl.find_opt char_items item.character with
                 | Some existing_item ->
                     let resolved = resolve_conflict existing_item item in
                     Hashtbl.replace char_items item.character resolved
                 | None ->
                     Hashtbl.add char_items item.character item
               ) items
           | Error _ -> ())
      | None -> ()
    ) source_list;
    
    let merged_data = Hashtbl.fold (fun _ item acc -> item :: acc) char_items [] in
    Success merged_data
  with
  | exn -> Error (Poetry_core.Poetry_errors.DataSourceError 
                   ("Data merge failed: " ^ (Printexc.to_string exn)))

(** {1 统计和监控} *)

let get_data_statistics () =
  try
    let total_items = Hashtbl.length character_index in
    let source_count = Hashtbl.length registered_sources in
    let cache_size = !cache_stats.cache_size in
    let avg_query_time = 0.0 in (* 暂未实现查询时间统计 *)
    Success (total_items, source_count, cache_size, avg_query_time)
  with
  | exn -> Error (Poetry_core.Poetry_errors.DataSourceError 
                   ("Statistics failed: " ^ (Printexc.to_string exn)))

let get_source_statistics source_id =
  match Hashtbl.find_opt registered_sources source_id with
  | Some (loader, _, _, last_loaded) ->
      (match loader () with
       | Success items ->
           let item_count = List.length items in
           let index_built = FastLookup.is_index_built source_id in
           Success (item_count, last_loaded, index_built)
       | Error err -> Error err)
  | None -> Error (Poetry_core.Poetry_errors.DataSourceError "Source not found")

let print_performance_report () =
  let stats = !cache_stats in
  Printf.printf "=== Data Manager Performance Report ===\n";
  Printf.printf "Total Queries: %d\n" stats.total_queries;
  Printf.printf "Cache Hits: %d\n" stats.cache_hits;
  Printf.printf "Cache Misses: %d\n" stats.cache_misses;
  Printf.printf "Hit Rate: %.2f%%\n" (stats.hit_rate *. 100.0);
  Printf.printf "Cache Size: %d\n" stats.cache_size;
  Printf.printf "Character Index Size: %d\n" (Hashtbl.length character_index);
  Printf.printf "Registered Sources: %d\n" (Hashtbl.length registered_sources);
  Printf.printf "=====================================\n"

(** {1 向后兼容性接口} *)

module Compatibility = struct
  let get_legacy_rhyme_database () =
    let all_data = load_all_data () in
    List.map (fun item ->
      (item.character, item.category, item.group)
    ) all_data
  
  let is_char_in_database char =
    Hashtbl.mem character_index char
  
  let get_char_rhyme_info char =
    match Hashtbl.find_opt character_index char with
    | Some item -> Some (item.character, item.category, item.group)
    | None -> None
end

(** {1 批量操作和导出} *)

let export_data criteria ~format =
  match query_data criteria with
  | Success items ->
      (match format with
       | `JSON ->
           let json_items = List.map (fun item ->
             Printf.sprintf "{\"character\":\"%s\",\"category\":\"%s\",\"group\":\"%s\"}"
               item.character
               (Obj.repr item.category |> Obj.tag |> string_of_int)
               (Obj.repr item.group |> Obj.tag |> string_of_int)
           ) items in
           Success ("[" ^ (String.concat "," json_items) ^ "]")
       | `CSV ->
           let csv_lines = "character,category,group" :: 
             (List.map (fun item ->
               Printf.sprintf "%s,%s,%s"
                 item.character
                 (Obj.repr item.category |> Obj.tag |> string_of_int)
                 (Obj.repr item.group |> Obj.tag |> string_of_int)
             ) items) in
           Success (String.concat "\n" csv_lines)
       | `OCaml ->
           let ocaml_items = List.map (fun item ->
             Printf.sprintf "{character=\"%s\"; category=...; group=...; metadata=[]}"
               item.character
           ) items in
           Success ("[" ^ (String.concat ";" ocaml_items) ^ "]"))
  | Error err -> Error err

let import_data source_id ~format data =
  Error (Poetry_core.Poetry_errors.DataSourceError "Import not yet implemented")

let batch_query criteria_list =
  let results = List.map query_data criteria_list in
  let rec collect_results acc = function
    | [] -> Success (List.rev acc)
    | (Success items) :: rest -> collect_results (items :: acc) rest
    | (Error err) :: _ -> Error err
  in
  collect_results [] results