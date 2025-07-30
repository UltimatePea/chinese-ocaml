(** 查询缓存管理模块
    
    专门负责查询结果的缓存管理，实现LRU缓存策略。
    从原data_manager.ml的QueryCache模块独立出来。
                                                           
    @author Alpha, 主要工作代理 - 基于Delta/Beta反馈的改进重构
    @version 2.1 - 模块化架构版本  
    @since 2025-07-30 - Phase 2A 改进重构
    @fix_issue #1791 *)

open Data_manager_types

(** {1 内部状态管理} *)

let cache_table = Hashtbl.create 1000
let access_order = Queue.create ()

(* 缓存配置引用 - 由storage模块管理 *)
let cache_config_ref = ref None

(** {1 缓存key生成} *)

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

(** {1 缓存操作接口} *)

let set_cache_config config =
  cache_config_ref := Some config

let get_cache_config () = 
  match !cache_config_ref with
  | Some config -> config
  | None -> {
      enable_cache = true;
      max_cache_size = 10000;
      ttl_seconds = 3600.0;
      eviction_policy = `LRU;
    }

let get criteria stats_ref =
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
            hit_rate =
              float_of_int !stats_ref.cache_hits /. float_of_int !stats_ref.total_queries;
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
          hit_rate =
            float_of_int !stats_ref.cache_hits /. float_of_int !stats_ref.total_queries;
        };
      None

let put criteria data stats_ref =
  let config = get_cache_config () in
  if config.enable_cache then (
    let key = cache_key_of_criteria criteria in
    let entry = { data; timestamp = Unix.time (); access_count = 1 } in

    (* LRU eviction if cache is full *)
    (if Hashtbl.length cache_table >= config.max_cache_size then
       try
         let old_key = Queue.take access_order in
         Hashtbl.remove cache_table old_key
       with Queue.Empty -> ());

    Hashtbl.replace cache_table key entry;
    Queue.push key access_order;
    stats_ref := { !stats_ref with cache_size = Hashtbl.length cache_table })

let clear stats_ref =
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

(** {1 查询统计接口} *)

let get_cache_size () = Hashtbl.length cache_table

let get_access_order_length () = Queue.length access_order

let is_cache_enabled () = (get_cache_config ()).enable_cache