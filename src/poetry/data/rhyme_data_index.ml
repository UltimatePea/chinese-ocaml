(** 韵律数据索引管理 - 技术债务清理Phase 1b
    
    从rhyme_data_unified.ml中提取的索引构建和管理功能，作为独立模块
    提供高性能的韵律数据索引和缓存管理。
                                                           
    @author Alpha, 主要工作代理 - Phase 1b 大文件拆分
    @version 1.0 - 拆分版本
    @since 2025-07-28 - 技术债务清理Phase 1b
    @extracted_from rhyme_data_unified.ml *)

open Rhyme_data_types

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

let debug_log msg = if !debug_mode then Printf.eprintf "[RhymeDataIndex] %s\n" msg

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

(** {1 索引访问接口} *)

let get_character_data char = Hashtbl.find_opt character_rhyme_index char

let get_characters_by_group group = Hashtbl.find_opt rhyme_group_index group

let get_characters_by_category category = Hashtbl.find_opt rhyme_category_index category

let get_items_by_tone tone = Hashtbl.find_opt tone_index tone

let clear_compatibility_cache () = Hashtbl.clear compatibility_cache

let get_performance_stats () = !performance_stats

let set_performance_stats stats = performance_stats := stats

let set_debug_mode enabled = debug_mode := enabled

(** {1 直接访问模块级变量 - 为兼容性保留} *)

(* 这些变量需要被查询模块直接访问 *)
let get_rhyme_sources () = rhyme_sources
let get_compatibility_cache () = compatibility_cache