(** 缓存管理模块 - 统一的诗词数据缓存机制 (Phase 2A 架构修正版本)

    基于Delta代理批判性分析的架构修正，解决原有的单一数据源假设、O(n)性能问题、
    缺乏类型安全等根本性缺陷。
    
    原有问题：
    1. 单一数据源假设错误 (let cached_database = ref None)
    2. O(n)查询性能问题 (List.exists)
    3. 缺乏类型安全 ((char * category * group)元组)
    4. 错误处理不一致

    @author Alpha, 主要工作代理 - 负责功能实现和技术债务处理  
    @version 2.0 - Phase 2A 架构修正版本
    @since 2025-07-28 - 基于Delta批评的架构重构
    @fix_issue #1572 *)

(** {1 类型安全的缓存状态管理} *)

type cached_data_item = {
  character : string;
  category : Data_source_manager.rhyme_category;
  group : Data_source_manager.rhyme_group;
  source_id : string;
  priority : int;
  _timestamp : float;
}
(** 类型安全的缓存数据项 *)

type cache_metadata = { total_items : int; _last_updated : float; _sources_count : int }
(** 缓存元数据 *)

type multi_cache = {
  character_index : (string, cached_data_item) Hashtbl.t; (* O(1)字符查找 *)
  group_index : (Data_source_manager.rhyme_group, string list) Hashtbl.t; (* O(1)韵组查找 *)
  category_index : (Data_source_manager.rhyme_category, string list) Hashtbl.t; (* O(1)韵类查找 *)
  source_index : (string, cached_data_item list) Hashtbl.t; (* 按数据源索引 *)
  cache_metadata : cache_metadata;
}
(** 多数据源缓存容器 - 解决单一数据源问题 *)

type cache_stats = {
  total_queries : int;
  cache_hits : int;
  cache_misses : int;
  index_rebuilds : int;
  _avg_query_time_ms : float;
}
(** 缓存性能统计 *)

(** 全局多数据源缓存 - 替代单一cached_database *)
let global_cache = ref None

(** 缓存性能统计 *)
let cache_statistics =
  ref
    {
      total_queries = 0;
      cache_hits = 0;
      cache_misses = 0;
      index_rebuilds = 0;
      _avg_query_time_ms = 0.0;
    }

(** {1 高性能缓存构建 - 解决O(n)性能问题} *)

(** 创建空的多数据源缓存 *)
let create_empty_cache () =
  {
    character_index = Hashtbl.create 20000;
    (* 增大初始容量 *)
    group_index = Hashtbl.create 200;
    category_index = Hashtbl.create 50;
    source_index = Hashtbl.create 20;
    cache_metadata = { total_items = 0; _last_updated = Unix.time (); _sources_count = 0 };
  }

(** 向后兼容：合并多个数据源，去除重复项 *)
let rec merge_data_sources sources =
  (* 使用优化版本但保持接口兼容 *)
  let cache = merge_data_sources_optimized sources in
  Hashtbl.fold
    (fun _ item acc -> (item.character, item.category, item.group) :: acc)
    cache.character_index []

(** 高性能数据源合并 - 支持多数据源优先级 *)
and merge_data_sources_optimized sources =
  let start_time = Unix.gettimeofday () in
  let cache = create_empty_cache () in
  let seen_characters = Hashtbl.create 20000 in
  let total_items = ref 0 in

  (* 按优先级排序数据源 *)
  let sorted_sources =
    List.sort
      (fun a b -> compare b.Data_source_manager.priority a.Data_source_manager.priority)
      sources
  in

  List.iter
    (fun entry ->
      try
        let data = Data_source_manager.load_from_source entry.Data_source_manager.source in
        let source_items = ref [] in

        List.iter
          (fun (char, category, group) ->
            if not (Hashtbl.mem seen_characters char) then (
              let cached_item =
                {
                  character = char;
                  category;
                  group;
                  source_id = entry.Data_source_manager.name;
                  priority = entry.Data_source_manager.priority;
                  _timestamp = Unix.time ();
                }
              in

              (* O(1) 字符索引更新 *)
              Hashtbl.add cache.character_index char cached_item;
              Hashtbl.add seen_characters char true;

              (* O(1) 韵组索引更新 *)
              let group_chars =
                match Hashtbl.find_opt cache.group_index group with
                | Some lst -> char :: lst
                | None -> [ char ]
              in
              Hashtbl.replace cache.group_index group group_chars;

              (* O(1) 韵类索引更新 *)
              let category_chars =
                match Hashtbl.find_opt cache.category_index category with
                | Some lst -> char :: lst
                | None -> [ char ]
              in
              Hashtbl.replace cache.category_index category category_chars;

              source_items := cached_item :: !source_items;
              incr total_items))
          data;

        (* 按数据源索引 *)
        Hashtbl.add cache.source_index entry.Data_source_manager.name !source_items
      with exn ->
        Printf.eprintf "Warning: Failed to load data from source %s: %s\n"
          entry.Data_source_manager.name (Printexc.to_string exn))
    sorted_sources;

  let end_time = Unix.gettimeofday () in
  cache_statistics :=
    {
      !cache_statistics with
      index_rebuilds = !cache_statistics.index_rebuilds + 1;
      _avg_query_time_ms = (end_time -. start_time) *. 1000.0;
    };

  {
    cache with
    cache_metadata =
      {
        total_items = !total_items;
        _last_updated = end_time;
        _sources_count = List.length sorted_sources;
      };
  }

(** 构建优化的统一数据库 - 内部使用 *)
let build_unified_cache () =
  let sorted_sources = Data_source_manager.get_sorted_sources () in
  merge_data_sources_optimized sorted_sources

(** 向后兼容：构建统一数据库 *)
let build_unified_database () =
  let sorted_sources = Data_source_manager.get_sorted_sources () in
  merge_data_sources sorted_sources

(** 获取优化的统一缓存 (多索引支持) *)
let get_unified_cache () =
  match !global_cache with
  | Some cache -> cache
  | None ->
      let cache = build_unified_cache () in
      global_cache := Some cache;
      cache

(** 向后兼容：获取统一数据库 (旧格式) *)
let get_unified_database () =
  let cache = get_unified_cache () in
  Hashtbl.fold
    (fun _ item acc -> (item.character, item.category, item.group) :: acc)
    cache.character_index []

(** {1 优化的缓存管理操作} *)

(** 清除所有缓存 - 支持统计更新 *)
let clear_cache () =
  global_cache := None;
  cache_statistics :=
    {
      !cache_statistics with
      cache_hits = 0;
      cache_misses = 0;
      total_queries = 0;
      _avg_query_time_ms = 0.0;
    }

(** 重新加载数据库 - 性能监控版本 *)
let reload_database () =
  let start_time = Unix.gettimeofday () in
  clear_cache ();
  let cache = build_unified_cache () in
  global_cache := Some cache;
  let end_time = Unix.gettimeofday () in
  cache_statistics :=
    { !cache_statistics with _avg_query_time_ms = (end_time -. start_time) *. 1000.0 }

(** 检查缓存是否已加载 *)
let is_cache_loaded () = !global_cache <> None

(** 强制刷新缓存 - 带性能统计 *)
let force_refresh_cache () =
  let start_time = Unix.gettimeofday () in
  let cache = build_unified_cache () in
  global_cache := Some cache;
  let end_time = Unix.gettimeofday () in
  cache_statistics :=
    {
      !cache_statistics with
      index_rebuilds = !cache_statistics.index_rebuilds + 1;
      _avg_query_time_ms = (end_time -. start_time) *. 1000.0;
    }

(** {1 高性能查询接口 - O(1)性能保证} *)

(** O(1) 检查字符是否在数据库中 - 解决Delta指出的O(n)性能问题 *)
let is_char_in_database char =
  let _start_time = Unix.gettimeofday () in
  let cache = get_unified_cache () in
  let result = Hashtbl.mem cache.character_index char in
  let _end_time = Unix.gettimeofday () in

  cache_statistics :=
    {
      !cache_statistics with
      total_queries = !cache_statistics.total_queries + 1;
      cache_hits =
        (if result then !cache_statistics.cache_hits + 1 else !cache_statistics.cache_hits);
      cache_misses =
        (if result then !cache_statistics.cache_misses else !cache_statistics.cache_misses + 1);
    };

  result

(** O(1) 获取字符的韵律信息 - 类型安全版本 *)
let get_char_rhyme_info char =
  let _start_time = Unix.gettimeofday () in
  let cache = get_unified_cache () in
  let result =
    match Hashtbl.find_opt cache.character_index char with
    | Some item -> Some (item.character, item.category, item.group)
    | None -> None
  in
  let _end_time = Unix.gettimeofday () in

  cache_statistics :=
    {
      !cache_statistics with
      total_queries = !cache_statistics.total_queries + 1;
      cache_hits =
        (if result <> None then !cache_statistics.cache_hits + 1 else !cache_statistics.cache_hits);
      cache_misses =
        (if result <> None then !cache_statistics.cache_misses
         else !cache_statistics.cache_misses + 1);
    };

  result

(** O(1) 按韵组查询字符 - 高性能索引版本 *)
let get_chars_by_rhyme_group group =
  let _start_time = Unix.gettimeofday () in
  let cache = get_unified_cache () in
  let result =
    match Hashtbl.find_opt cache.group_index group with
    | Some char_list ->
        List.filter_map
          (fun char ->
            match Hashtbl.find_opt cache.character_index char with
            | Some item -> Some (item.character, item.category, item.group)
            | None -> None)
          char_list
    | None -> []
  in
  let _end_time = Unix.gettimeofday () in

  cache_statistics :=
    {
      !cache_statistics with
      total_queries = !cache_statistics.total_queries + 1;
      cache_hits =
        (if result <> [] then !cache_statistics.cache_hits + 1 else !cache_statistics.cache_hits);
      cache_misses =
        (if result <> [] then !cache_statistics.cache_misses else !cache_statistics.cache_misses + 1);
    };

  result

(** O(1) 按韵类查询字符 - 高性能索引版本 *)
let get_chars_by_rhyme_category category =
  let _start_time = Unix.gettimeofday () in
  let cache = get_unified_cache () in
  let result =
    match Hashtbl.find_opt cache.category_index category with
    | Some char_list ->
        List.filter_map
          (fun char ->
            match Hashtbl.find_opt cache.character_index char with
            | Some item -> Some (item.character, item.category, item.group)
            | None -> None)
          char_list
    | None -> []
  in
  let _end_time = Unix.gettimeofday () in

  cache_statistics :=
    {
      !cache_statistics with
      total_queries = !cache_statistics.total_queries + 1;
      cache_hits =
        (if result <> [] then !cache_statistics.cache_hits + 1 else !cache_statistics.cache_hits);
      cache_misses =
        (if result <> [] then !cache_statistics.cache_misses else !cache_statistics.cache_misses + 1);
    };

  result

(** {1 优化的统计信息 - O(1)性能} *)

(** O(1) 获取数据库统计信息 - 从缓存元数据读取 *)
let get_database_stats () =
  let cache = get_unified_cache () in
  let total_chars = cache.cache_metadata.total_items in
  let groups = Hashtbl.length cache.group_index in
  let categories = Hashtbl.length cache.category_index in
  (total_chars, groups, categories)

(** 获取增强的缓存状态信息 *)
let get_cache_info () =
  let is_loaded = is_cache_loaded () in
  let size =
    if is_loaded then
      let cache = get_unified_cache () in
      cache.cache_metadata.total_items
    else 0
  in
  (is_loaded, size)

(** 获取详细的缓存性能统计 - 内部使用 *)
let _get_cache_performance_stats () = !cache_statistics

(** 获取多数据源缓存详细统计 - 内部使用 *)
let _get_detailed_cache_stats () =
  if is_cache_loaded () then
    let cache = get_unified_cache () in
    let source_stats =
      Hashtbl.fold
        (fun source_name items acc -> (source_name, List.length items) :: acc)
        cache.source_index []
    in
    Some (cache.cache_metadata, source_stats, !cache_statistics)
  else None

(** {1 增强的数据完整性验证 - 多数据源支持} *)

(** 高性能数据完整性验证 - 利用缓存索引 *)
let validate_database () =
  let cache = get_unified_cache () in
  let errors = ref [] in

  (* 检查字符索引一致性 *)
  Hashtbl.iter
    (fun char item ->
      if char <> item.character then
        errors :=
          Printf.sprintf "Index inconsistency: key=%s, item.character=%s" char item.character
          :: !errors;
      if char = "" then errors := "Empty character found in index" :: !errors)
    cache.character_index;

  (* 检查韵组索引一致性 *)
  Hashtbl.iter
    (fun group char_list ->
      List.iter
        (fun char ->
          match Hashtbl.find_opt cache.character_index char with
          | Some item ->
              if item.group <> group then
                errors :=
                  Printf.sprintf
                    "Group index inconsistency: char=%s expected_group=%s actual_group=%s" char
                    (Obj.repr group |> Obj.tag |> string_of_int)
                    (Obj.repr item.group |> Obj.tag |> string_of_int)
                  :: !errors
          | None ->
              errors :=
                Printf.sprintf "Character %s in group index but not in character index" char
                :: !errors)
        char_list)
    cache.group_index;

  (* 检查韵类索引一致性 *)
  Hashtbl.iter
    (fun category char_list ->
      List.iter
        (fun char ->
          match Hashtbl.find_opt cache.character_index char with
          | Some item ->
              if item.category <> category then
                errors := Printf.sprintf "Category index inconsistency: char=%s" char :: !errors
          | None ->
              errors :=
                Printf.sprintf "Character %s in category index but not in character index" char
                :: !errors)
        char_list)
    cache.category_index;

  (* 检查数据源索引一致性 *)
  Hashtbl.iter
    (fun source_name items ->
      List.iter
        (fun item ->
          if item.source_id <> source_name then
            errors :=
              Printf.sprintf "Source index inconsistency: item.source_id=%s expected=%s"
                item.source_id source_name
              :: !errors)
        items)
    cache.source_index;

  let is_valid = !errors = [] in
  (is_valid, !errors)

(** 检测数据源间冲突 - 内部使用 *)
let _detect_data_source_conflicts () =
  let cache = get_unified_cache () in
  let conflicts = ref [] in
  let char_sources = Hashtbl.create cache.cache_metadata.total_items in

  Hashtbl.iter
    (fun source_name items ->
      List.iter
        (fun item ->
          match Hashtbl.find_opt char_sources item.character with
          | Some (existing_source, existing_priority) ->
              if existing_source <> source_name then
                conflicts :=
                  (item.character, existing_source, source_name, existing_priority, item.priority)
                  :: !conflicts
          | None -> Hashtbl.add char_sources item.character (source_name, item.priority))
        items)
    cache.source_index;

  !conflicts

(** {1 向后兼容性接口} *)

(** 获取扩展韵律数据库 - 兼容原 expanded_rhyme_data.ml 接口 *)
let get_expanded_rhyme_database () = get_unified_database ()

(** 检查字符是否在扩展韵律数据库中 - 兼容原接口 *)
let is_in_expanded_rhyme_database char = is_char_in_database char

(** 获取扩展韵律字符列表 - 兼容原接口 *)
let get_expanded_char_list () = List.map (fun (char, _, _) -> char) (get_unified_database ())

(** 扩展韵律字符总数 - 兼容原接口 *)
let expanded_rhyme_char_count () =
  let total, _, _ = get_database_stats () in
  total
