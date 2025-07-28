(** 统一韵律数据管理器实现 - Phase 2 架构修正韵律数据专用模块
    
    整合所有分散的韵律数据模块，提供统一的韵律数据访问接口，
    解决当前15个rhyme_data模块职责重叠的问题。
                                                           
    @author Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    @version 2.0 - 架构修正版本
    @since 2025-07-28 - Phase 2A 韵律数据统一
    @fix_issue #1572 *)

(** {1 韵律数据核心类型} *)

type rhyme_data_item = {
  character : string;
  rhyme_group : Poetry_core.Json_core.rhyme_group;
  rhyme_category : Poetry_core.Json_core.rhyme_category;
  tone : [ `PingSheng | `ShangSheng | `QuSheng | `RuSheng ];
  phonetic_info : (string * string) list;
  source_priority : int;
}

type rhyme_source =
  | AnYunData
  | FengRhymeData
  | HuaRhymeData
  | YuRhymeData
  | HuiRhymeData
  | JiangRhymeData
  | YueRhymeData
  | UnifiedRhymeDatabase
  | ExpandedRhymeData
  | RhymeDataEngine
  | CustomSource of string

type rhyme_query =
  | QueryByCharacter of string
  | QueryByRhymeGroup of Poetry_core.Json_core.rhyme_group
  | QueryByRhymeCategory of Poetry_core.Json_core.rhyme_category
  | QueryByTone of [ `PingSheng | `ShangSheng | `QuSheng | `RuSheng ]
  | QueryBySource of rhyme_source
  | QueryBySimilarSound of string
  | RhymeCompatibilityQuery of string * string

type 'a rhyme_result = RhymeSuccess of 'a | RhymeError of string | RhymeWarning of 'a * string

(** {1 内部状态管理} *)

(* 韵律数据源注册表 *)
let rhyme_sources = Hashtbl.create 16

(* 高性能索引 - 解决Delta指出的O(n)性能问题 *)
let character_rhyme_index = Hashtbl.create 20000
let rhyme_group_index = Hashtbl.create 200
let rhyme_category_index = Hashtbl.create 50
let tone_index = Hashtbl.create 4

(* 韵律兼容性缓存 *)
let compatibility_cache = Hashtbl.create 10000

(* 性能统计 *)
let performance_stats =
  ref { total_queries = 0; cache_hits = 0; index_build_time = 0.0; avg_query_time = 0.0 }

(* 调试模式 *)
let debug_mode = ref false

(** {1 辅助函数} *)

let debug_log msg = if !debug_mode then Printf.eprintf "[RhymeDataUnified] %s\n" msg

let measure_time f =
  let start_time = Unix.gettimeofday () in
  let result = f () in
  let end_time = Unix.gettimeofday () in
  (result, end_time -. start_time)

(** {1 索引构建和管理} *)

let rebuild_character_index data_list =
  debug_log "Rebuilding character index...";
  Hashtbl.clear character_rhyme_index;
  List.iter (fun item -> Hashtbl.replace character_rhyme_index item.character item) data_list;
  debug_log (Printf.sprintf "Character index built with %d items" (List.length data_list))

let rebuild_group_index data_list =
  debug_log "Rebuilding rhyme group index...";
  Hashtbl.clear rhyme_group_index;
  List.iter
    (fun item ->
      let existing =
        match Hashtbl.find_opt rhyme_group_index item.rhyme_group with
        | Some lst -> lst
        | None -> []
      in
      Hashtbl.replace rhyme_group_index item.rhyme_group (item.character :: existing))
    data_list

let rebuild_category_index data_list =
  debug_log "Rebuilding rhyme category index...";
  Hashtbl.clear rhyme_category_index;
  List.iter
    (fun item ->
      let existing =
        match Hashtbl.find_opt rhyme_category_index item.rhyme_category with
        | Some lst -> lst
        | None -> []
      in
      Hashtbl.replace rhyme_category_index item.rhyme_category (item.character :: existing))
    data_list

let rebuild_tone_index data_list =
  debug_log "Rebuilding tone index...";
  Hashtbl.clear tone_index;
  List.iter
    (fun item ->
      let existing =
        match Hashtbl.find_opt tone_index item.tone with Some lst -> lst | None -> []
      in
      Hashtbl.replace tone_index item.tone (item :: existing))
    data_list

let rebuild_all_indexes () =
  let all_data, build_time =
    measure_time (fun () ->
        let sources_with_priority =
          Hashtbl.fold
            (fun source (loader, priority, _, _) acc -> (source, loader, priority) :: acc)
            rhyme_sources []
          |> List.sort (fun (_, _, p1) (_, _, p2) -> compare p2 p1)
        in

        let all_items = ref [] in
        let seen_characters = Hashtbl.create 20000 in

        List.iter
          (fun (source, loader, _) ->
            match loader () with
            | RhymeSuccess items ->
                List.iter
                  (fun item ->
                    if not (Hashtbl.mem seen_characters item.character) then (
                      Hashtbl.add seen_characters item.character true;
                      all_items := item :: !all_items))
                  items
            | RhymeError err -> debug_log (Printf.sprintf "Failed to load from source: %s" err)
            | RhymeWarning (items, warn) ->
                debug_log (Printf.sprintf "Warning loading source: %s" warn);
                List.iter
                  (fun item ->
                    if not (Hashtbl.mem seen_characters item.character) then (
                      Hashtbl.add seen_characters item.character true;
                      all_items := item :: !all_items))
                  items)
          sources_with_priority;

        List.rev !all_items)
  in

  rebuild_character_index all_data;
  rebuild_group_index all_data;
  rebuild_category_index all_data;
  rebuild_tone_index all_data;

  performance_stats := { !performance_stats with index_build_time = build_time };
  debug_log (Printf.sprintf "All indexes rebuilt in %.4f seconds" build_time)

(** {1 韵律数据源管理} *)

let register_rhyme_source source loader ?(priority = 0) description =
  try
    let source_info = (loader, priority, description, Unix.time ()) in
    Hashtbl.replace rhyme_sources source source_info;
    rebuild_all_indexes ();
    RhymeSuccess ()
  with exn -> RhymeError ("Failed to register rhyme source: " ^ Printexc.to_string exn)

let get_available_sources () =
  Hashtbl.fold
    (fun source (_, priority, description, _) acc -> (source, description, priority) :: acc)
    rhyme_sources []

let remove_rhyme_source source =
  try
    if Hashtbl.mem rhyme_sources source then (
      Hashtbl.remove rhyme_sources source;
      rebuild_all_indexes ();
      RhymeSuccess ())
    else RhymeError "Rhyme source not found"
  with exn -> RhymeError ("Failed to remove rhyme source: " ^ Printexc.to_string exn)

(** {1 韵律查询实现} *)

let query_rhyme_data query =
  let result, query_time =
    measure_time (fun () ->
        performance_stats :=
          { !performance_stats with total_queries = !performance_stats.total_queries + 1 };

        match query with
        | QueryByCharacter char -> (
            match Hashtbl.find_opt character_rhyme_index char with
            | Some item -> RhymeSuccess [ item ]
            | None -> RhymeSuccess [])
        | QueryByRhymeGroup group -> (
            match Hashtbl.find_opt rhyme_group_index group with
            | Some char_list ->
                let items =
                  List.filter_map
                    (fun char -> Hashtbl.find_opt character_rhyme_index char)
                    char_list
                in
                RhymeSuccess items
            | None -> RhymeSuccess [])
        | QueryByRhymeCategory category -> (
            match Hashtbl.find_opt rhyme_category_index category with
            | Some char_list ->
                let items =
                  List.filter_map
                    (fun char -> Hashtbl.find_opt character_rhyme_index char)
                    char_list
                in
                RhymeSuccess items
            | None -> RhymeSuccess [])
        | QueryByTone tone -> (
            match Hashtbl.find_opt tone_index tone with
            | Some items -> RhymeSuccess items
            | None -> RhymeSuccess [])
        | QueryBySource source -> (
            match Hashtbl.find_opt rhyme_sources source with
            | Some (loader, _, _, _) -> loader ()
            | None -> RhymeError "Source not found")
        | QueryBySimilarSound char -> (
            (* 简化实现：查找同韵组的字符 *)
            match Hashtbl.find_opt character_rhyme_index char with
            | Some item -> (
                match Hashtbl.find_opt rhyme_group_index item.rhyme_group with
                | Some char_list ->
                    let similar_items =
                      List.filter_map
                        (fun c ->
                          if c <> char then Hashtbl.find_opt character_rhyme_index c else None)
                        char_list
                    in
                    RhymeSuccess similar_items
                | None -> RhymeSuccess [])
            | None -> RhymeSuccess [])
        | RhymeCompatibilityQuery (char1, char2) ->
            let is_compatible =
              match
                ( Hashtbl.find_opt character_rhyme_index char1,
                  Hashtbl.find_opt character_rhyme_index char2 )
              with
              | Some item1, Some item2 -> item1.rhyme_group = item2.rhyme_group
              | _ -> false
            in
            if is_compatible then RhymeSuccess [ char1; char2 ] |> ignore;
            RhymeSuccess [])
  in

  (* 更新平均查询时间 *)
  let total = !performance_stats.total_queries in
  let current_avg = !performance_stats.avg_query_time in
  let new_avg =
    ((current_avg *. float_of_int (total - 1)) +. (query_time *. 1000.0)) /. float_of_int total
  in
  performance_stats := { !performance_stats with avg_query_time = new_avg };

  result

let find_rhyme_character char =
  match Hashtbl.find_opt character_rhyme_index char with
  | Some item -> RhymeSuccess (Some item)
  | None -> RhymeSuccess None

let find_rhyme_group_characters group =
  match Hashtbl.find_opt rhyme_group_index group with
  | Some char_list -> RhymeSuccess char_list
  | None -> RhymeSuccess []

let find_characters_by_tone tone =
  match Hashtbl.find_opt tone_index tone with
  | Some items -> RhymeSuccess items
  | None -> RhymeSuccess []

(** {1 韵律兼容性和分析} *)

let check_rhyme_compatibility char1 char2 =
  let cache_key = if char1 < char2 then char1 ^ "|" ^ char2 else char2 ^ "|" ^ char1 in

  match Hashtbl.find_opt compatibility_cache cache_key with
  | Some result ->
      performance_stats :=
        { !performance_stats with cache_hits = !performance_stats.cache_hits + 1 };
      RhymeSuccess result
  | None ->
      let result =
        match
          ( Hashtbl.find_opt character_rhyme_index char1,
            Hashtbl.find_opt character_rhyme_index char2 )
        with
        | Some item1, Some item2 -> item1.rhyme_group = item2.rhyme_group
        | _ -> false
      in
      Hashtbl.replace compatibility_cache cache_key result;
      RhymeSuccess result

let find_rhyming_characters char ?(max_results = -1) () =
  match Hashtbl.find_opt character_rhyme_index char with
  | Some item -> (
      match Hashtbl.find_opt rhyme_group_index item.rhyme_group with
      | Some char_list ->
          let rhyming_chars = List.filter (fun c -> c <> char) char_list in
          let limited_results =
            if max_results > 0 then
              let rec take n lst acc =
                if n <= 0 || lst = [] then List.rev acc
                else take (n - 1) (List.tl lst) (List.hd lst :: acc)
              in
              take max_results rhyming_chars []
            else rhyming_chars
          in
          RhymeSuccess limited_results
      | None -> RhymeSuccess [])
  | None -> RhymeSuccess []

let analyze_rhyme_pattern char_list =
  let group_map = Hashtbl.create 20 in

  List.iter
    (fun char ->
      match Hashtbl.find_opt character_rhyme_index char with
      | Some item ->
          let existing =
            match Hashtbl.find_opt group_map item.rhyme_group with Some lst -> lst | None -> []
          in
          Hashtbl.replace group_map item.rhyme_group (char :: existing)
      | None -> ())
    char_list;

  let patterns =
    Hashtbl.fold (fun group chars acc -> (group, List.rev chars) :: acc) group_map []
  in

  RhymeSuccess patterns

let suggest_rhyme_alternatives char =
  match find_rhyming_characters char ~max_results:10 () with
  | RhymeSuccess rhyming_chars ->
      let alternatives = List.map (fun c -> (c, 0.9)) rhyming_chars in
      RhymeSuccess alternatives
  | RhymeError err -> RhymeError err
  | RhymeWarning (chars, warn) -> RhymeWarning (List.map (fun c -> (c, 0.9)) chars, warn)

(** {1 韵律数据统计和验证} *)

let get_rhyme_statistics () =
  let total_chars = Hashtbl.length character_rhyme_index in
  let rhyme_groups = Hashtbl.length rhyme_group_index in
  let rhyme_categories = Hashtbl.length rhyme_category_index in
  let data_sources = Hashtbl.length rhyme_sources in
  let conflicts = 0 in
  (* 简化实现，实际应该计算冲突数 *)
  RhymeSuccess (total_chars, rhyme_groups, rhyme_categories, data_sources, conflicts)

let validate_rhyme_data () =
  let errors = ref [] in

  (* 检查空字符 *)
  Hashtbl.iter
    (fun char _ -> if char = "" then errors := "Empty character found" :: !errors)
    character_rhyme_index;

  (* 检查索引一致性 *)
  Hashtbl.iter
    (fun group char_list ->
      List.iter
        (fun char ->
          if not (Hashtbl.mem character_rhyme_index char) then
            errors :=
              Printf.sprintf "Character %s in group index but not in character index" char
              :: !errors)
        char_list)
    rhyme_group_index;

  let is_valid = !errors = [] in
  RhymeSuccess (is_valid, !errors)

let find_data_conflicts () =
  (* 简化实现 - 实际应该检查不同数据源间的冲突 *)
  RhymeSuccess []

let resolve_conflicts_automatically () =
  (* 简化实现 - 实际应该基于优先级解决冲突 *)
  let resolved = Hashtbl.fold (fun char item acc -> (char, item) :: acc) character_rhyme_index [] in
  RhymeSuccess resolved

(** {1 高性能查询优化} *)

module FastRhyme = struct
  let build_rhyme_index source_list =
    try
      rebuild_all_indexes ();
      RhymeSuccess ()
    with exn -> RhymeError ("Index build failed: " ^ Printexc.to_string exn)

  let lookup_character_fast char = Hashtbl.find_opt character_rhyme_index char

  let lookup_rhyme_group_fast group =
    match Hashtbl.find_opt rhyme_group_index group with Some char_list -> char_list | None -> []

  let is_rhyme_compatible_fast char1 char2 =
    match (lookup_character_fast char1, lookup_character_fast char2) with
    | Some item1, Some item2 -> item1.rhyme_group = item2.rhyme_group
    | _ -> false

  let rebuild_index () =
    try
      rebuild_all_indexes ();
      RhymeSuccess ()
    with exn -> RhymeError ("Index rebuild failed: " ^ Printexc.to_string exn)

  let get_index_status () =
    Hashtbl.fold
      (fun source (_, _, _, last_update) acc ->
        let has_index = Hashtbl.length character_rhyme_index > 0 in
        (source, has_index, last_update) :: acc)
      rhyme_sources []
end

(** {1 传统韵律系统支持} *)

module TraditionalRhyme = struct
  let get_ping_sheng_characters () =
    match Hashtbl.find_opt tone_index `PingSheng with
    | Some items -> RhymeSuccess (List.map (fun item -> item.character) items)
    | None -> RhymeSuccess []

  let get_ze_sheng_characters () =
    let ze_tones = [ `ShangSheng; `QuSheng; `RuSheng ] in
    let all_ze_chars =
      List.fold_left
        (fun acc tone ->
          match Hashtbl.find_opt tone_index tone with
          | Some items -> acc @ List.map (fun item -> item.character) items
          | None -> acc)
        [] ze_tones
    in
    RhymeSuccess all_ze_chars

  let classify_tone char =
    match Hashtbl.find_opt character_rhyme_index char with
    | Some item -> RhymeSuccess (Some item.tone)
    | None -> RhymeSuccess None

  let check_ping_ze_pattern char_list =
    let patterns =
      List.map
        (fun char ->
          match classify_tone char with
          | RhymeSuccess (Some `PingSheng) -> `Ping
          | RhymeSuccess (Some _) -> `Ze
          | _ -> `Ze (* 默认为仄 *))
        char_list
    in
    RhymeSuccess patterns

  let suggest_ping_ze_correction char_list =
    (* 简化实现 *)
    RhymeSuccess []
end

(** {1 现代韵律系统支持} *)

module ModernRhyme = struct
  let get_modern_rhyme_mapping char =
    (* 简化实现 - 实际需要现代韵律映射表 *)
    find_rhyming_characters char ~max_results:5 ()

  let check_modern_rhyme_compatibility char1 char2 =
    match check_rhyme_compatibility char1 char2 with
    | RhymeSuccess true -> RhymeSuccess 1.0
    | RhymeSuccess false -> RhymeSuccess 0.0
    | RhymeError err -> RhymeError err
    | RhymeWarning (result, warn) -> RhymeWarning (if result then 1.0 else (0.0, warn))

  let convert_traditional_to_modern group = find_rhyme_group_characters group
end

(** {1 导入导出功能} *)

let export_rhyme_data query ~format =
  match query_rhyme_data query with
  | RhymeSuccess items -> (
      match format with
      | `JSON ->
          let json_items =
            List.map
              (fun item ->
                Printf.sprintf "{\"character\":\"%s\",\"tone\":\"%s\"}" item.character
                  (match item.tone with
                  | `PingSheng -> "PingSheng"
                  | `ShangSheng -> "ShangSheng"
                  | `QuSheng -> "QuSheng"
                  | `RuSheng -> "RuSheng"))
              items
          in
          RhymeSuccess ("[" ^ String.concat "," json_items ^ "]")
      | `CSV ->
          let csv_lines =
            "character,tone,rhyme_group"
            :: List.map
                 (fun item ->
                   Printf.sprintf "%s,%s,%s" item.character
                     (match item.tone with
                     | `PingSheng -> "PingSheng"
                     | `ShangSheng -> "ShangSheng"
                     | `QuSheng -> "QuSheng"
                     | `RuSheng -> "RuSheng")
                     (Obj.repr item.rhyme_group |> Obj.tag |> string_of_int))
                 items
          in
          RhymeSuccess (String.concat "\n" csv_lines)
      | `XML ->
          let xml_items =
            List.map
              (fun item ->
                Printf.sprintf "<item><character>%s</character><tone>%s</tone></item>"
                  item.character
                  (match item.tone with
                  | `PingSheng -> "PingSheng"
                  | `ShangSheng -> "ShangSheng"
                  | `QuSheng -> "QuSheng"
                  | `RuSheng -> "RuSheng"))
              items
          in
          RhymeSuccess ("<rhyme_data>" ^ String.concat "" xml_items ^ "</rhyme_data>")
      | `YAML ->
          let yaml_items =
            List.map
              (fun item ->
                Printf.sprintf "- character: %s\n  tone: %s" item.character
                  (match item.tone with
                  | `PingSheng -> "PingSheng"
                  | `ShangSheng -> "ShangSheng"
                  | `QuSheng -> "QuSheng"
                  | `RuSheng -> "RuSheng"))
              items
          in
          RhymeSuccess (String.concat "\n" yaml_items))
  | RhymeError err -> RhymeError err
  | RhymeWarning (items, warn) -> RhymeWarning ("Export completed with warnings", warn)

let import_rhyme_data source ~format data = RhymeError "Import functionality not yet implemented"

let backup_rhyme_data () =
  let all_items = Hashtbl.fold (fun _ item acc -> item :: acc) character_rhyme_index [] in
  let json_items =
    List.map
      (fun item ->
        Printf.sprintf "{\"character\":\"%s\",\"tone\":\"%s\"}" item.character
          (match item.tone with
          | `PingSheng -> "PingSheng"
          | `ShangSheng -> "ShangSheng"
          | `QuSheng -> "QuSheng"
          | `RuSheng -> "RuSheng"))
      all_items
  in
  RhymeSuccess ("[" ^ String.concat "," json_items ^ "]")

let restore_rhyme_data backup_data = RhymeError "Restore functionality not yet implemented"

(** {1 向后兼容性接口} *)

module Compatibility = struct
  let get_expanded_rhyme_database () =
    Hashtbl.fold
      (fun _ item acc -> (item.character, item.rhyme_category, item.rhyme_group) :: acc)
      character_rhyme_index []

  let is_in_expanded_rhyme_database char = Hashtbl.mem character_rhyme_index char

  let get_an_yun_data () =
    (* 简化实现 - 兼容an_yun_data.ml *)
    Hashtbl.fold
      (fun _ item acc -> (item.character, "default_category", "default_group") :: acc)
      character_rhyme_index []

  let get_feng_rhyme_data () =
    (* 简化实现 - 兼容feng_rhyme_data.ml *)
    Hashtbl.fold
      (fun _ item acc -> (item.character, "default_info") :: acc)
      character_rhyme_index []

  let get_unified_database () = get_expanded_rhyme_database ()
end

(** {1 调试和监控} *)

let print_rhyme_report () =
  Printf.printf "=== Rhyme Data Unified Report ===\n";
  Printf.printf "Total Characters: %d\n" (Hashtbl.length character_rhyme_index);
  Printf.printf "Rhyme Groups: %d\n" (Hashtbl.length rhyme_group_index);
  Printf.printf "Rhyme Categories: %d\n" (Hashtbl.length rhyme_category_index);
  Printf.printf "Data Sources: %d\n" (Hashtbl.length rhyme_sources);
  Printf.printf "Total Queries: %d\n" !performance_stats.total_queries;
  Printf.printf "Cache Hits: %d\n" !performance_stats.cache_hits;
  Printf.printf "Average Query Time: %.4f ms\n" !performance_stats.avg_query_time;
  Printf.printf "Index Build Time: %.4f seconds\n" !performance_stats.index_build_time;
  Printf.printf "===================================\n"

let get_memory_usage () =
  let char_index_size = Hashtbl.length character_rhyme_index * 100 in
  (* 估算 *)
  let group_index_size = Hashtbl.length rhyme_group_index * 50 in
  let category_index_size = Hashtbl.length rhyme_category_index * 50 in
  let cache_size = Hashtbl.length compatibility_cache * 20 in
  char_index_size + group_index_size + category_index_size + cache_size

let optimize_memory () =
  Hashtbl.clear compatibility_cache;
  debug_log "Memory optimization completed - cleared compatibility cache"

let set_debug_mode enabled =
  debug_mode := enabled;
  debug_log (if enabled then "Debug mode enabled" else "Debug mode disabled")

let get_performance_metrics () =
  let stats = !performance_stats in
  (stats.avg_query_time, stats.index_build_time *. 1000.0, stats.total_queries, stats.cache_hits)
