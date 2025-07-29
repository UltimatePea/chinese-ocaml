(** 韵律查询引擎模块 - 提供高效的韵律数据查询功能

    从rhyme_data_unified.ml重构而来，专注于查询操作实现、 索引管理和查询优化，实现高性能的韵律数据检索。

    @author Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    @version 3.0 - 模块化重构版本
    @since 2025-07-29 - 基于issue #1662的模块化重构

    重构自 rhyme_data_unified.ml *)

open Rhyme_data_core

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

(** {1 核心查询实现} *)

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

(** {1 便捷查询函数} *)

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

(** {1 查询优化和缓存} *)

let clear_query_cache () =
  clear_all_caches ();
  debug_log "Query cache cleared"

let optimize_indexes () =
  (* 优化索引结构，移除空项 *)
  let optimize_hashtbl tbl =
    let to_remove = ref [] in
    Hashtbl.iter (fun k v -> match v with [] -> to_remove := k :: !to_remove | _ -> ()) tbl;
    List.iter (Hashtbl.remove tbl) !to_remove
  in

  optimize_hashtbl rhyme_group_index;
  optimize_hashtbl rhyme_category_index;
  debug_log "Indexes optimized"
