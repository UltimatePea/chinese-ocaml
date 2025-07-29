(** 统一韵律数据管理器 - 模块协调层

    重构后的统一接口，协调各个专门化模块，提供向后兼容的API。 这是韵律数据系统的主要入口点，负责模块间的协调和统一接口导出。

    @author Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    @version 3.0 - 模块化重构版本
    @since 2025-07-29 - 基于issue #1662的模块化重构

    重构自 rhyme_data_unified.ml *)

(** {1 模块导入} *)

open Rhyme_data_core
open Rhyme_query_engine
open Rhyme_analysis
open Rhyme_data_management

(** {1 统一接口导出 - 保持向后兼容性} *)

(* 重新导出核心类型 *)
type rhyme_data_item = Rhyme_data_core.rhyme_data_item
type rhyme_source = Rhyme_data_core.rhyme_source
type rhyme_query = Rhyme_data_core.rhyme_query
type 'a rhyme_result = 'a Rhyme_data_core.rhyme_result

(* 重新导出查询功能 *)
let query_rhyme_data = Rhyme_query_engine.query_rhyme_data
let find_rhyme_character = Rhyme_query_engine.find_rhyme_character
let find_rhyme_group_characters = Rhyme_query_engine.find_rhyme_group_characters
let find_characters_by_tone = Rhyme_query_engine.find_characters_by_tone
let rebuild_all_indexes = Rhyme_query_engine.rebuild_all_indexes

(* 重新导出分析功能 *)
let check_rhyme_compatibility = Rhyme_analysis.check_rhyme_compatibility
let find_rhyming_characters = Rhyme_analysis.find_rhyming_characters
let analyze_rhyme_pattern = Rhyme_analysis.analyze_rhyme_pattern
let suggest_rhyme_alternatives = Rhyme_analysis.suggest_rhyme_alternatives

(* 重新导出管理功能 *)
let register_rhyme_source = Rhyme_data_management.register_rhyme_source
let get_available_sources = Rhyme_data_management.get_available_sources
let remove_rhyme_source = Rhyme_data_management.remove_rhyme_source
let export_rhyme_data = Rhyme_data_management.export_rhyme_data
let import_rhyme_data = Rhyme_data_management.import_rhyme_data
let backup_rhyme_data = Rhyme_data_management.backup_rhyme_data
let restore_rhyme_data = Rhyme_data_management.restore_rhyme_data
let get_rhyme_statistics = Rhyme_data_management.get_rhyme_statistics
let validate_rhyme_data = Rhyme_data_management.validate_rhyme_data
let find_data_conflicts = Rhyme_data_management.find_data_conflicts
let resolve_conflicts_automatically = Rhyme_data_management.resolve_conflicts_automatically

(* 重新导出核心配置功能 *)
let set_debug_mode = Rhyme_data_core.set_debug_mode
let get_performance_metrics = Rhyme_data_core.get_performance_metrics
let get_memory_usage = Rhyme_data_core.get_memory_usage
let optimize_memory = Rhyme_data_core.optimize_memory

(** {1 高性能查询优化模块} *)

module FastRhyme = struct
  let build_rhyme_index source_list =
    try
      rebuild_all_indexes ();
      RhymeSuccess ()
    with exn -> RhymeError ("Index build failed: " ^ Printexc.to_string exn)

  let query_character char =
    match find_rhyme_character char with
    | RhymeSuccess (Some item) -> RhymeSuccess item
    | RhymeSuccess None -> RhymeError "Character not found"
    | error -> error

  let batch_query_characters char_list =
    let results =
      List.map
        (fun char ->
          match find_rhyme_character char with
          | RhymeSuccess (Some item) -> (char, Some item)
          | _ -> (char, None))
        char_list
    in
    RhymeSuccess results
end

(** {1 传统韵律系统支持} *)

module TraditionalRhyme = struct
  let get_ping_ze_pattern char_list =
    let patterns =
      List.map
        (fun char ->
          match find_rhyme_character char with
          | RhymeSuccess (Some item) -> (
              match item.tone with
              | `PingSheng -> (char, "平")
              | `ShangSheng | `QuSheng | `RuSheng -> (char, "仄"))
          | _ -> (char, "未知"))
        char_list
    in
    RhymeSuccess patterns

  let check_ping_ze_compatibility char1 char2 =
    match (find_rhyme_character char1, find_rhyme_character char2) with
    | RhymeSuccess (Some item1), RhymeSuccess (Some item2) ->
        let is_compatible =
          match (item1.tone, item2.tone) with
          | `PingSheng, (`ShangSheng | `QuSheng | `RuSheng) -> true
          | (`ShangSheng | `QuSheng | `RuSheng), `PingSheng -> true
          | _ -> false
        in
        RhymeSuccess is_compatible
    | _ -> RhymeError "One or both characters not found"

  let analyze_meter_pattern char_list =
    match get_ping_ze_pattern char_list with
    | RhymeSuccess patterns ->
        let meter = List.map (fun (_, pattern) -> pattern) patterns in
        RhymeSuccess (String.concat "" meter)
    | error -> error
end

(** {1 现代韵律系统支持} *)

module ModernRhyme = struct
  let get_sound_similarity char1 char2 =
    match check_rhyme_compatibility char1 char2 with
    | RhymeSuccess true -> RhymeSuccess 1.0
    | RhymeSuccess false -> (
        (* 基于声调相似性的简化计算 *)
        match (find_rhyme_character char1, find_rhyme_character char2) with
        | RhymeSuccess (Some item1), RhymeSuccess (Some item2) ->
            let tone_similarity = if item1.tone = item2.tone then 0.5 else 0.0 in
            RhymeSuccess tone_similarity
        | _ -> RhymeSuccess 0.0)
    | error -> error

  let suggest_modern_alternatives char = suggest_rhyme_alternatives char
end

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

let get_performance_metrics_detailed () =
  let stats = !performance_stats in
  (stats.avg_query_time, stats.index_build_time *. 1000.0, stats.total_queries, stats.cache_hits)
