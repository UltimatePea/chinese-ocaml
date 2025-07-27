(** 韵律数据引擎 - 统一数据管理核心
    
    此模块提供Poetry系统的核心数据管理功能，包括：
    - 统一的数据加载和缓存
    - 高效的韵律查询和匹配
    - 数据源管理和更新
    - 性能优化和监控
    
    技术债务修复：统一分散的数据管理逻辑，建立高效的单一数据引擎。
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (统一架构版)
    @since 2025-07-27
    @fix_issue #1501 *)

open Poetry_types.Rhyme_types

(** {1 数据引擎类型定义} *)

type cache_statistics = {
  hits : int;  (** 缓存命中次数 *)
  misses : int;  (** 缓存未命中次数 *)
  total_queries : int;  (** 总查询次数 *)
  last_reset : float;  (** 上次重置时间 *)
}
(** 缓存统计信息 *)

type engine_state = {
  database : rhyme_database;  (** 韵律数据库 *)
  lookup_table : (string, rhyme_data_item) Hashtbl.t;  (** 字符查找表 *)
  group_index : (rhyme_group, rhyme_data_item list) Hashtbl.t;  (** 韵组索引 *)
  category_index : (rhyme_category, rhyme_data_item list) Hashtbl.t;  (** 韵类索引 *)
  cache_stats : cache_statistics;  (** 缓存统计 *)
  is_initialized : bool;  (** 是否已初始化 *)
}
(** 数据引擎状态 *)

exception RhymeDataEngineError of string
(** 数据引擎异常 *)

(** {1 内部辅助函数} *)

(** 创建空缓存统计 *)
let create_empty_cache_stats () =
  { hits = 0; misses = 0; total_queries = 0; last_reset = Unix.time () }

(** 更新缓存统计 - 命中 *)
let update_cache_hit stats =
  { stats with hits = stats.hits + 1; total_queries = stats.total_queries + 1 }

(** 更新缓存统计 - 未命中 *)
let update_cache_miss stats =
  { stats with misses = stats.misses + 1; total_queries = stats.total_queries + 1 }

(** 构建查找表 *)
let build_lookup_table database =
  let lookup_table = Hashtbl.create 1024 in
  database.groups
  |> List.iter (fun group_data ->
         group_data.items
         |> List.iter (fun item -> Hashtbl.replace lookup_table item.character item));
  lookup_table

(** 构建韵组索引 *)
let build_group_index database =
  let group_index = Hashtbl.create 32 in
  database.groups
  |> List.iter (fun group_data -> Hashtbl.replace group_index group_data.group group_data.items);
  group_index

(** 构建韵类索引 *)
let build_category_index database =
  let category_index = Hashtbl.create 8 in
  (* 初始化所有韵类的空列表 *)
  [ PingSheng; ZeSheng; ShangSheng; QuSheng; RuSheng ]
  |> List.iter (fun category -> Hashtbl.replace category_index category []);

  (* 收集每个韵类的数据项 *)
  database.groups
  |> List.iter (fun group_data ->
         group_data.items
         |> List.iter (fun item ->
                let current_items = Hashtbl.find category_index item.category in
                Hashtbl.replace category_index item.category (item :: current_items)));
  category_index

(** {1 核心功能实现} *)

(** 初始化数据引擎 *)
let initialize () =
  {
    database = create_empty_database ();
    lookup_table = Hashtbl.create 1024;
    group_index = Hashtbl.create 32;
    category_index = Hashtbl.create 8;
    cache_stats = create_empty_cache_stats ();
    is_initialized = false;
  }

(** 加载韵律数据库 *)
let load_database database engine_state =
  (* 验证数据库 *)
  if not (validate_rhyme_database database) then
    raise (RhymeDataEngineError "Invalid rhyme database");

  (* 构建索引 *)
  let lookup_table = build_lookup_table database in
  let group_index = build_group_index database in
  let category_index = build_category_index database in

  { engine_state with database; lookup_table; group_index; category_index; is_initialized = true }

(** 查询字符韵律信息 *)
let lookup_character character engine_state =
  if not engine_state.is_initialized then raise (RhymeDataEngineError "Engine not initialized");

  let _updated_stats, result =
    match Hashtbl.find_opt engine_state.lookup_table character with
    | Some item -> (update_cache_hit engine_state.cache_stats, Some item)
    | None -> (update_cache_miss engine_state.cache_stats, None)
  in

  (* 注意：在实际使用中，需要考虑如何更新引擎状态中的统计信息 *)
  result

(** 查询韵组所有字符 *)
let get_group_characters group engine_state =
  if not engine_state.is_initialized then raise (RhymeDataEngineError "Engine not initialized");

  match Hashtbl.find_opt engine_state.group_index group with Some items -> items | None -> []

(** 查询韵类所有字符 *)
let get_category_characters category engine_state =
  if not engine_state.is_initialized then raise (RhymeDataEngineError "Engine not initialized");

  match Hashtbl.find_opt engine_state.category_index category with
  | Some items -> items
  | None -> []

(** 检查韵律匹配 *)
let check_rhyme_match char1 char2 engine_state =
  if not engine_state.is_initialized then raise (RhymeDataEngineError "Engine not initialized");

  match (lookup_character char1 engine_state, lookup_character char2 engine_state) with
  | Some item1, Some item2 -> item1.group = item2.group
  | _ -> false

(** 检查韵类匹配 *)
let check_category_match char1 char2 engine_state =
  if not engine_state.is_initialized then raise (RhymeDataEngineError "Engine not initialized");

  match (lookup_character char1 engine_state, lookup_character char2 engine_state) with
  | Some item1, Some item2 -> item1.category = item2.category
  | _ -> false

(** 获取缓存统计 *)
let get_cache_stats engine_state = engine_state.cache_stats

(** 清理缓存统计 *)
let clear_cache_stats engine_state = { engine_state with cache_stats = create_empty_cache_stats () }

(** 获取数据库信息 *)
let get_database_info engine_state =
  if not engine_state.is_initialized then raise (RhymeDataEngineError "Engine not initialized");

  let total_items =
    engine_state.database.groups
    |> List.map (fun group_data -> List.length group_data.items)
    |> List.fold_left ( + ) 0
  in

  let group_count = List.length engine_state.database.groups in

  (total_items, group_count, engine_state.database.version)

(** 查找相似韵律的字符 *)
let find_similar_characters character engine_state =
  match lookup_character character engine_state with
  | None -> []
  | Some item ->
      get_group_characters item.group engine_state
      |> List.filter (fun similar_item -> similar_item.character <> character)

(** 批量查询字符 *)
let batch_lookup_characters characters engine_state =
  characters |> List.map (fun char -> (char, lookup_character char engine_state))

(** 验证引擎状态 *)
let validate_engine_state engine_state =
  engine_state.is_initialized
  && validate_rhyme_database engine_state.database
  && Hashtbl.length engine_state.lookup_table > 0

(** 获取引擎性能指标 *)
let get_performance_metrics engine_state =
  let stats = engine_state.cache_stats in
  let hit_rate =
    if stats.total_queries > 0 then float_of_int stats.hits /. float_of_int stats.total_queries
    else 0.0
  in
  let current_time = Unix.time () in
  let uptime = current_time -. stats.last_reset in

  [
    ("hit_rate", string_of_float hit_rate);
    ("total_queries", string_of_int stats.total_queries);
    ("cache_hits", string_of_int stats.hits);
    ("cache_misses", string_of_int stats.misses);
    ("uptime_seconds", string_of_float uptime);
    ("lookup_table_size", string_of_int (Hashtbl.length engine_state.lookup_table));
    ("is_initialized", string_of_bool engine_state.is_initialized);
  ]
