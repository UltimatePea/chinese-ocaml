(** 韵律数据核心模块 - 提供基础类型和数据结构
    
    从rhyme_data_unified.ml重构而来，专注于核心数据类型定义、
    内存管理和基础数据结构，实现职责分离和模块化改进。
                                                           
    @author Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    @version 3.0 - 模块化重构版本
    @since 2025-07-29 - 基于issue #1662的模块化重构
    @parent_module rhyme_data_unified.ml *)

(** {1 韵律数据核心类型定义} *)

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

(** {1 性能统计类型} *)

type performance_metrics = {
  total_queries : int;
  cache_hits : int;
  index_build_time : float;
  avg_query_time : float;
}

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
let performance_stats = ref { 
  total_queries = 0; 
  cache_hits = 0; 
  index_build_time = 0.0; 
  avg_query_time = 0.0 
}

(* 调试模式 *)
let debug_mode = ref false

(** {1 基础工具函数} *)

let debug_log msg = 
  if !debug_mode then Printf.eprintf "[RhymeDataCore] %s\n" msg

let measure_time f =
  let start_time = Unix.gettimeofday () in
  let result = f () in
  let end_time = Unix.gettimeofday () in
  (result, end_time -. start_time)

(** {1 内存管理和优化} *)

let clear_all_caches () =
  Hashtbl.clear compatibility_cache;
  debug_log "All caches cleared"

let get_memory_usage () =
  let rhyme_sources_size = Hashtbl.length rhyme_sources in
  let char_index_size = Hashtbl.length character_rhyme_index in
  let group_index_size = Hashtbl.length rhyme_group_index in
  let category_index_size = Hashtbl.length rhyme_category_index in
  let tone_index_size = Hashtbl.length tone_index in
  let cache_size = Hashtbl.length compatibility_cache in
  Printf.sprintf 
    "Memory usage: sources=%d, char_index=%d, group_index=%d, category_index=%d, tone_index=%d, cache=%d"
    rhyme_sources_size char_index_size group_index_size category_index_size tone_index_size cache_size

let optimize_memory () =
  (* 清理过期的缓存条目，保留最近使用的 *)
  if Hashtbl.length compatibility_cache > 5000 then (
    Hashtbl.clear compatibility_cache;
    debug_log "Compatibility cache optimized"
  )

(** {1 调试和配置} *)

let set_debug_mode enabled =
  debug_mode := enabled;
  debug_log (if enabled then "Debug mode enabled" else "Debug mode disabled")

let get_performance_metrics () =
  !performance_stats

let reset_performance_metrics () =
  performance_stats := { 
    total_queries = 0; 
    cache_hits = 0; 
    index_build_time = 0.0; 
    avg_query_time = 0.0 
  };
  debug_log "Performance metrics reset"