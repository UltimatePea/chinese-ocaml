(** 韵律数据查询和兼容性分析 - 技术债务清理Phase 1b
    
    从rhyme_data_unified.ml中提取的查询逻辑和兼容性分析功能，作为独立模块
    提供高效的韵律数据查询和分析接口。
                                                           
    @author Alpha, 主要工作代理 - Phase 1b 大文件拆分
    @version 1.0 - 拆分版本
    @since 2025-07-28 - 技术债务清理Phase 1b
    @extracted_from rhyme_data_unified.ml *)

open Rhyme_data_types

(** {1 韵律查询实现} *)

let query_rhyme_data query =
  let result, query_time =
    Rhyme_data_index.measure_time (fun () ->
        let stats = Rhyme_data_index.get_performance_stats () in
        Rhyme_data_index.set_performance_stats
          { stats with total_queries = stats.total_queries + 1 };

        match query with
        | QueryByCharacter char -> (
            match Rhyme_data_index.get_character_data char with
            | Some item -> RhymeSuccess [ item ]
            | None -> RhymeSuccess [])
        | QueryByRhymeGroup group -> (
            match Rhyme_data_index.get_characters_by_group group with
            | Some char_list ->
                let items =
                  List.filter_map Rhyme_data_index.get_character_data char_list
                in
                RhymeSuccess items
            | None -> RhymeSuccess [])
        | QueryByRhymeCategory category -> (
            match Rhyme_data_index.get_characters_by_category category with
            | Some char_list ->
                let items =
                  List.filter_map Rhyme_data_index.get_character_data char_list
                in
                RhymeSuccess items
            | None -> RhymeSuccess [])
        | QueryByTone tone -> (
            match Rhyme_data_index.get_items_by_tone tone with
            | Some items -> RhymeSuccess items
            | None -> RhymeSuccess [])
        | QueryBySource source -> (
            let rhyme_sources = Rhyme_data_index.get_rhyme_sources () in
            match Hashtbl.find_opt rhyme_sources source with
            | Some (loader, _, _, _) -> loader ()
            | None -> RhymeError "Source not found")
        | QueryBySimilarSound char -> (
            (* 简化实现：查找同韵组的字符 *)
            match Rhyme_data_index.get_character_data char with
            | Some item -> (
                match Rhyme_data_index.get_characters_by_group item.rhyme_group with
                | Some char_list ->
                    let similar_items =
                      List.filter_map
                        (fun c ->
                          if c <> char then Rhyme_data_index.get_character_data c else None)
                        char_list
                    in
                    RhymeSuccess similar_items
                | None -> RhymeSuccess [])
            | None -> RhymeSuccess [])
        | RhymeCompatibilityQuery (char1, char2) ->
            let is_compatible =
              match
                ( Rhyme_data_index.get_character_data char1,
                  Rhyme_data_index.get_character_data char2 )
              with
              | Some item1, Some item2 -> item1.rhyme_group = item2.rhyme_group
              | _ -> false
            in
            if is_compatible then RhymeSuccess [ char1; char2 ] |> ignore;
            RhymeSuccess [])
  in

  (* 更新平均查询时间 *)
  let stats = Rhyme_data_index.get_performance_stats () in
  let total = stats.total_queries in
  let current_avg = stats.avg_query_time in
  let new_avg =
    ((current_avg *. float_of_int (total - 1)) +. (query_time *. 1000.0)) /. float_of_int total
  in
  Rhyme_data_index.set_performance_stats { stats with avg_query_time = new_avg };

  result

let find_rhyme_character char =
  match Rhyme_data_index.get_character_data char with
  | Some item -> RhymeSuccess (Some item)
  | None -> RhymeSuccess None

let find_rhyme_group_characters group =
  match Rhyme_data_index.get_characters_by_group group with
  | Some char_list -> RhymeSuccess char_list
  | None -> RhymeSuccess []

let find_characters_by_tone tone =
  match Rhyme_data_index.get_items_by_tone tone with
  | Some items -> RhymeSuccess items
  | None -> RhymeSuccess []

(** {1 韵律兼容性和分析} *)

let check_rhyme_compatibility char1 char2 =
  let cache_key = if char1 < char2 then char1 ^ "|" ^ char2 else char2 ^ "|" ^ char1 in

  let compatibility_cache = Rhyme_data_index.get_compatibility_cache () in
  match Hashtbl.find_opt compatibility_cache cache_key with
  | Some result ->
      let stats = Rhyme_data_index.get_performance_stats () in
      Rhyme_data_index.set_performance_stats
        { stats with cache_hits = stats.cache_hits + 1 };
      RhymeSuccess result
  | None ->
      let result =
        match
          ( Rhyme_data_index.get_character_data char1,
            Rhyme_data_index.get_character_data char2 )
        with
        | Some item1, Some item2 -> item1.rhyme_group = item2.rhyme_group
        | _ -> false
      in
      Hashtbl.replace compatibility_cache cache_key result;
      RhymeSuccess result

let find_rhyming_characters char ?(max_results = -1) () =
  match Rhyme_data_index.get_character_data char with
  | Some item -> (
      match Rhyme_data_index.get_characters_by_group item.rhyme_group with
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
      match Rhyme_data_index.get_character_data char with
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
  (* 通过已有接口获取统计信息 *)
  let total_chars = 
    match Rhyme_data_index.get_character_data "测试" with
    | Some _ | None -> 0 (* 简化实现，实际需要更好的统计方法 *)
  in
  let rhyme_groups = 0 in (* 简化实现 *)
  let rhyme_categories = 0 in (* 简化实现 *)
  let data_sources = Hashtbl.length (Rhyme_data_index.get_rhyme_sources ()) in
  let conflicts = 0 in
  (* 简化实现，实际应该计算冲突数 *)
  RhymeSuccess (total_chars, rhyme_groups, rhyme_categories, data_sources, conflicts)