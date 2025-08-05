(** 统一缓存管理实现 - P0专项整合
    
    整合重复的缓存管理器模块，提供统一的缓存管理接口。
    
    Author: Whisky, PR Worker - P0专项整合
    @version 1.0 - Phase 2.1
    @since 2025-08-04
    @fix_issue #2174 *)

(** {1 基础类型定义} *)

type cache_strategy = LRU | FIFO | LFU

type cache_config = {
  max_size : int;
  strategy : cache_strategy;
  ttl_seconds : int option;
  enable_statistics : bool;
  auto_cleanup : bool;
}

let default_cache_config =
  {
    max_size = 1000;
    strategy = LRU;
    ttl_seconds = Some 3600;
    (* 1小时 *)
    enable_statistics = true;
    auto_cleanup = true;
  }

type cache_key = string

type cache_value =
  | JsonValue of Yojson.Safe.t
  | StringValue of string
  | StringListValue of string list
  | BytesValue of bytes
  | CustomValue of string * bytes

type cache_stats = {
  hits : int;
  misses : int;
  hit_rate : float;
  total_requests : int;
  current_size : int;
  evictions : int;
  expired_count : int;
  memory_usage_bytes : int;
}

(** {1 内部数据结构} *)

type cache_entry = {
  key : cache_key;
  value : cache_value;
  timestamp : float;
  access_time : float;
  access_count : int;
  ttl : int option;
}
(** 缓存项 *)

type cache_instance = {
  mutable config : cache_config;
  mutable entries : (cache_key, cache_entry) Hashtbl.t;
  mutable stats : cache_stats;
  mutable access_order : cache_key list; (* 用于LRU *)
}
(** 缓存实例 *)

(** 全局缓存注册表 *)
let cache_registry : (string, cache_instance) Hashtbl.t = Hashtbl.create 16

(** 后台清理配置 *)
let background_cleanup_enabled = ref false

let cleanup_interval = ref 300 (* 5分钟 *)

(** {1 工具函数} *)

let get_current_time () = Unix.time ()

let is_expired entry =
  match entry.ttl with
  | None -> false
  | Some ttl ->
      let current_time = get_current_time () in
      current_time -. entry.timestamp > float_of_int ttl

let estimate_value_size = function
  | JsonValue json -> String.length (Yojson.Safe.to_string json)
  | StringValue s -> String.length s
  | StringListValue sl -> List.fold_left (fun acc s -> acc + String.length s) 0 sl
  | BytesValue b -> Bytes.length b
  | CustomValue (_, b) -> Bytes.length b

let update_stats cache hit =
  if cache.config.enable_statistics then
    let stats = cache.stats in
    let new_stats =
      if hit then { stats with hits = stats.hits + 1; total_requests = stats.total_requests + 1 }
      else { stats with misses = stats.misses + 1; total_requests = stats.total_requests + 1 }
    in
    let new_hit_rate =
      if new_stats.total_requests > 0 then
        float_of_int new_stats.hits /. float_of_int new_stats.total_requests
      else 0.0
    in
    cache.stats <- { new_stats with hit_rate = new_hit_rate }

let calculate_memory_usage entries =
  Hashtbl.fold
    (fun _ entry acc ->
      acc + estimate_value_size entry.value + String.length entry.key + 64 (* 估算结构开销 *))
    entries 0

(** {1 缓存管理核心函数} *)

let find_cache_by_name name = try Some (Hashtbl.find cache_registry name) with Not_found -> None

let create_cache ?(config = default_cache_config) name =
  let cache =
    {
      config;
      entries = Hashtbl.create config.max_size;
      stats =
        {
          hits = 0;
          misses = 0;
          hit_rate = 0.0;
          total_requests = 0;
          current_size = 0;
          evictions = 0;
          expired_count = 0;
          memory_usage_bytes = 0;
        };
      access_order = [];
    }
  in
  Hashtbl.replace cache_registry name cache;
  Printf.printf "已创建缓存: %s (最大大小: %d, 策略: %s)\n" name config.max_size
    (match config.strategy with LRU -> "LRU" | FIFO -> "FIFO" | LFU -> "LFU")

let evict_entry cache =
  if Hashtbl.length cache.entries = 0 then 0
  else
    let key_to_evict =
      match cache.config.strategy with
      | LRU ->
          (* 选择最近最少使用的项 *)
          let oldest_key = ref "" in
          let oldest_time = ref (get_current_time ()) in
          Hashtbl.iter
            (fun k entry ->
              if entry.access_time < !oldest_time then (
                oldest_time := entry.access_time;
                oldest_key := k))
            cache.entries;
          !oldest_key
      | FIFO ->
          (* 选择最早插入的项 *)
          let oldest_key = ref "" in
          let oldest_time = ref (get_current_time ()) in
          Hashtbl.iter
            (fun k entry ->
              if entry.timestamp < !oldest_time then (
                oldest_time := entry.timestamp;
                oldest_key := k))
            cache.entries;
          !oldest_key
      | LFU ->
          (* 选择使用频率最低的项 *)
          let lfu_key = ref "" in
          let min_count = ref Int.max_int in
          Hashtbl.iter
            (fun k entry ->
              if entry.access_count < !min_count then (
                min_count := entry.access_count;
                lfu_key := k))
            cache.entries;
          !lfu_key
    in
    if key_to_evict <> "" then (
      Hashtbl.remove cache.entries key_to_evict;
      cache.access_order <- List.filter (fun k -> k <> key_to_evict) cache.access_order;
      cache.stats <-
        {
          cache.stats with
          evictions = cache.stats.evictions + 1;
          current_size = cache.stats.current_size - 1;
        };
      1)
    else 0

let cleanup_expired_entries cache =
  let expired_keys = ref [] in
  Hashtbl.iter
    (fun key entry -> if is_expired entry then expired_keys := key :: !expired_keys)
    cache.entries;

  List.iter
    (fun key ->
      Hashtbl.remove cache.entries key;
      cache.access_order <- List.filter (fun k -> k <> key) cache.access_order)
    !expired_keys;

  let expired_count = List.length !expired_keys in
  cache.stats <-
    {
      cache.stats with
      expired_count = cache.stats.expired_count + expired_count;
      current_size = cache.stats.current_size - expired_count;
    };
  expired_count

(** {1 核心缓存接口实现} *)

let get ~cache_name key =
  match find_cache_by_name cache_name with
  | None ->
      Printf.printf "警告: 缓存 '%s' 不存在\n" cache_name;
      None
  | Some cache -> (
      (* 清理过期项 *)
      if cache.config.auto_cleanup then ignore (cleanup_expired_entries cache);

      try
        let entry = Hashtbl.find cache.entries key in
        if is_expired entry then (
          Hashtbl.remove cache.entries key;
          cache.access_order <- List.filter (fun k -> k <> key) cache.access_order;
          update_stats cache false;
          None)
        else
          (* 更新访问信息 *)
          let updated_entry =
            { entry with access_time = get_current_time (); access_count = entry.access_count + 1 }
          in
          Hashtbl.replace cache.entries key updated_entry;

          (* 更新LRU顺序 *)
          cache.access_order <- key :: List.filter (fun k -> k <> key) cache.access_order;

          update_stats cache true;
          Some entry.value
      with Not_found ->
        update_stats cache false;
        None)

let rec set ~cache_name key value =
  match find_cache_by_name cache_name with
  | None ->
      Printf.printf "警告: 缓存 '%s' 不存在，正在创建\n" cache_name;
      create_cache cache_name;
      set ~cache_name key value
  | Some cache ->
      (* 检查是否需要驱逐 *)
      if Hashtbl.length cache.entries >= cache.config.max_size then ignore (evict_entry cache);

      let current_time = get_current_time () in
      let entry =
        {
          key;
          value;
          timestamp = current_time;
          access_time = current_time;
          access_count = 1;
          ttl = cache.config.ttl_seconds;
        }
      in

      let is_update = Hashtbl.mem cache.entries key in
      Hashtbl.replace cache.entries key entry;

      if not is_update then (
        cache.access_order <- key :: cache.access_order;
        cache.stats <- { cache.stats with current_size = cache.stats.current_size + 1 });

      (* 更新内存使用统计 *)
      let memory_usage = calculate_memory_usage cache.entries in
      cache.stats <- { cache.stats with memory_usage_bytes = memory_usage }

let remove ~cache_name key =
  match find_cache_by_name cache_name with
  | None -> false
  | Some cache ->
      let existed = Hashtbl.mem cache.entries key in
      if existed then (
        Hashtbl.remove cache.entries key;
        cache.access_order <- List.filter (fun k -> k <> key) cache.access_order;
        cache.stats <- { cache.stats with current_size = cache.stats.current_size - 1 };
        let memory_usage = calculate_memory_usage cache.entries in
        cache.stats <- { cache.stats with memory_usage_bytes = memory_usage });
      existed

let exists ~cache_name key =
  match find_cache_by_name cache_name with
  | None -> false
  | Some cache -> (
      try
        let entry = Hashtbl.find cache.entries key in
        not (is_expired entry)
      with Not_found -> false)

(** {1 批量操作实现} *)

let set_multiple ~cache_name pairs = List.iter (fun (key, value) -> set ~cache_name key value) pairs
let get_multiple ~cache_name keys = List.map (fun key -> (key, get ~cache_name key)) keys

let remove_multiple ~cache_name keys =
  List.fold_left (fun acc key -> if remove ~cache_name key then acc + 1 else acc) 0 keys

(** {1 缓存管理实现} *)

let clear ~cache_name =
  match find_cache_by_name cache_name with
  | None -> Printf.printf "警告: 缓存 '%s' 不存在\n" cache_name
  | Some cache ->
      Hashtbl.clear cache.entries;
      cache.access_order <- [];
      cache.stats <-
        {
          hits = 0;
          misses = 0;
          hit_rate = 0.0;
          total_requests = 0;
          current_size = 0;
          evictions = 0;
          expired_count = 0;
          memory_usage_bytes = 0;
        };
      Printf.printf "已清空缓存: %s\n" cache_name

let clear_all () =
  Hashtbl.iter (fun name _ -> clear ~cache_name:name) cache_registry;
  Printf.printf "已清空所有缓存\n"

let resize ~cache_name new_size =
  match find_cache_by_name cache_name with
  | None -> Printf.printf "警告: 缓存 '%s' 不存在\n" cache_name
  | Some cache ->
      cache.config <- { cache.config with max_size = new_size };
      (* 如果当前大小超过新限制，进行驱逐 *)
      while Hashtbl.length cache.entries > new_size do
        ignore (evict_entry cache)
      done;
      Printf.printf "缓存 '%s' 大小已调整为: %d\n" cache_name new_size

let set_ttl ~cache_name ttl_seconds =
  match find_cache_by_name cache_name with
  | None -> Printf.printf "警告: 缓存 '%s' 不存在\n" cache_name
  | Some cache ->
      cache.config <- { cache.config with ttl_seconds };
      Printf.printf "缓存 '%s' TTL已设置为: %s\n" cache_name
        (match ttl_seconds with Some t -> string_of_int t ^ "秒" | None -> "永不过期")

(** {1 缓存维护实现} *)

let cleanup_expired ~cache_name =
  match find_cache_by_name cache_name with None -> 0 | Some cache -> cleanup_expired_entries cache

let cleanup_all_expired () =
  Hashtbl.fold (fun _ cache acc -> acc + cleanup_expired_entries cache) cache_registry 0

let force_evict ~cache_name count =
  match find_cache_by_name cache_name with
  | None -> 0
  | Some cache ->
      let rec evict_n n acc =
        if n <= 0 || Hashtbl.length cache.entries = 0 then acc
        else
          let evicted = evict_entry cache in
          evict_n (n - evicted) (acc + evicted)
      in
      evict_n count 0

(** {1 统计和监控实现} *)

let get_stats ~cache_name =
  match find_cache_by_name cache_name with
  | None ->
      Printf.printf "警告: 缓存 '%s' 不存在\n" cache_name;
      {
        hits = 0;
        misses = 0;
        hit_rate = 0.0;
        total_requests = 0;
        current_size = 0;
        evictions = 0;
        expired_count = 0;
        memory_usage_bytes = 0;
      }
  | Some cache ->
      (* 更新当前内存使用量 *)
      let memory_usage = calculate_memory_usage cache.entries in
      {
        cache.stats with
        current_size = Hashtbl.length cache.entries;
        memory_usage_bytes = memory_usage;
      }

let get_all_stats () =
  Hashtbl.fold (fun name _cache acc -> (name, get_stats ~cache_name:name) :: acc) cache_registry []

let reset_stats ~cache_name =
  match find_cache_by_name cache_name with
  | None -> Printf.printf "警告: 缓存 '%s' 不存在\n" cache_name
  | Some cache ->
      cache.stats <-
        {
          cache.stats with
          hits = 0;
          misses = 0;
          hit_rate = 0.0;
          total_requests = 0;
          evictions = 0;
          expired_count = 0;
        }

let print_stats ~cache_name =
  let stats = get_stats ~cache_name in
  Printf.printf "\n=== 缓存 '%s' 统计信息 ===\n" cache_name;
  Printf.printf "命中次数: %d\n" stats.hits;
  Printf.printf "未命中次数: %d\n" stats.misses;
  Printf.printf "命中率: %.2f%%\n" (stats.hit_rate *. 100.0);
  Printf.printf "总请求次数: %d\n" stats.total_requests;
  Printf.printf "当前大小: %d\n" stats.current_size;
  Printf.printf "驱逐次数: %d\n" stats.evictions;
  Printf.printf "过期项目数: %d\n" stats.expired_count;
  Printf.printf "内存使用: %d 字节\n" stats.memory_usage_bytes;
  Printf.printf "========================\n\n"

let print_all_stats () =
  let all_stats = get_all_stats () in
  List.iter (fun (name, _) -> print_stats ~cache_name:name) all_stats

(** {1 缓存配置管理实现} *)

let get_config ~cache_name =
  match find_cache_by_name cache_name with
  | None ->
      Printf.printf "警告: 缓存 '%s' 不存在\n" cache_name;
      default_cache_config
  | Some cache -> cache.config

let update_config ~cache_name config =
  match find_cache_by_name cache_name with
  | None -> Printf.printf "警告: 缓存 '%s' 不存在\n" cache_name
  | Some cache ->
      cache.config <- config;
      (* 如果大小限制变小，可能需要驱逐 *)
      while Hashtbl.length cache.entries > config.max_size do
        ignore (evict_entry cache)
      done

let list_caches () = Hashtbl.fold (fun name _ acc -> name :: acc) cache_registry []

(** {1 专用缓存接口实现} *)

module PoetryCache = struct
  let cache_name = "poetry_data"

  let () =
    if find_cache_by_name cache_name = None then
      create_cache ~config:{ default_cache_config with max_size = 2000 } cache_name

  let get_rhyme_data key =
    match get ~cache_name key with
    | Some (CustomValue ("rhyme_data", bytes)) -> (
        (* 简化的反序列化，实际应用中需要更复杂的序列化/反序列化 *)
        try
          let data_str = Bytes.to_string bytes in
          let items = String.split_on_char ';' data_str in
          Some
            (List.map
               (fun item ->
                 let parts = String.split_on_char ',' item in
                 match parts with [ char; cat; grp ] -> (char, cat, grp) | _ -> ("", "", ""))
               items)
        with _ -> None)
    | _ -> None

  let set_rhyme_data key data =
    let data_str =
      String.concat ";" (List.map (fun (c, cat, grp) -> String.concat "," [ c; cat; grp ]) data)
    in
    let bytes = Bytes.of_string data_str in
    set ~cache_name key (CustomValue ("rhyme_data", bytes))

  let get_tone_data key =
    match get ~cache_name key with Some (StringListValue data) -> Some data | _ -> None

  let set_tone_data key data = set ~cache_name key (StringListValue data)

  let get_word_class_data key =
    match get ~cache_name key with Some (StringListValue data) -> Some data | _ -> None

  let set_word_class_data key data = set ~cache_name key (StringListValue data)
end

module JsonCache = struct
  let cache_name = "json_data"

  let () =
    if find_cache_by_name cache_name = None then
      create_cache ~config:{ default_cache_config with max_size = 500 } cache_name

  let get_json key = match get ~cache_name key with Some (JsonValue json) -> Some json | _ -> None
  let set_json key json = set ~cache_name key (JsonValue json)
  let get_parsed_file file_path = get_json file_path
  let set_parsed_file file_path json = set_json file_path json
end

module FileCache = struct
  let cache_name = "file_content"

  let () =
    if find_cache_by_name cache_name = None then
      create_cache ~config:{ default_cache_config with max_size = 200 } cache_name

  let get_file_content file_path =
    match get ~cache_name file_path with Some (StringValue content) -> Some content | _ -> None

  let set_file_content file_path content = set ~cache_name file_path (StringValue content)

  let get_file_lines file_path =
    match get ~cache_name (file_path ^ "_lines") with
    | Some (StringListValue lines) -> Some lines
    | _ -> None

  let set_file_lines file_path lines =
    set ~cache_name (file_path ^ "_lines") (StringListValue lines)
end

(** {1 高级功能实现} *)

let warm_cache ~cache_name pairs =
  Printf.printf "预热缓存 '%s'，项目数: %d\n" cache_name (List.length pairs);
  set_multiple ~cache_name pairs

let export_cache ~cache_name file_path =
  match find_cache_by_name cache_name with
  | None -> Printf.printf "错误: 缓存 '%s' 不存在\n" cache_name
  | Some cache ->
      let oc = open_out file_path in
      Printf.fprintf oc "# 缓存导出文件: %s\n" cache_name;
      Printf.fprintf oc "# 导出时间: %s\n" (string_of_float (get_current_time ()));
      Hashtbl.iter
        (fun key entry ->
          Printf.fprintf oc "%s|%s|%f|%d\n" key
            (match entry.value with
            | StringValue s -> "string:" ^ s
            | JsonValue j -> "json:" ^ Yojson.Safe.to_string j
            | _ -> "other:serialized")
            entry.timestamp entry.access_count)
        cache.entries;
      close_out oc;
      Printf.printf "缓存 '%s' 已导出到: %s\n" cache_name file_path

let import_cache ~cache_name file_path =
  if not (Sys.file_exists file_path) then Printf.printf "错误: 导入文件不存在: %s\n" file_path
  else
    let ic = open_in file_path in
    let count = ref 0 in
    (try
       while true do
         let line = input_line ic in
         if not (String.starts_with ~prefix:"#" line) then
           match String.split_on_char '|' line with
           | [ key; value_str; _timestamp; _access_count ] -> (
               match String.split_on_char ':' value_str with
               | [ "string"; content ] ->
                   set ~cache_name key (StringValue content);
                   incr count
               | [ "json"; json_str ] -> (
                   try
                     let json = Yojson.Safe.from_string json_str in
                     set ~cache_name key (JsonValue json);
                     incr count
                   with _ -> ())
               | _ -> ())
           | _ -> ()
       done
     with End_of_file -> ());
    close_in ic;
    Printf.printf "已从 '%s' 导入 %d 个缓存项到 '%s'\n" file_path !count cache_name

let migrate_cache ~old_name ~new_name =
  match find_cache_by_name old_name with
  | None -> Printf.printf "错误: 源缓存 '%s' 不存在\n" old_name
  | Some old_cache ->
      if find_cache_by_name new_name = None then create_cache ~config:old_cache.config new_name;

      let pairs =
        Hashtbl.fold (fun key entry acc -> (key, entry.value) :: acc) old_cache.entries []
      in

      set_multiple ~cache_name:new_name pairs;
      Printf.printf "已将 %d 个项目从缓存 '%s' 迁移到 '%s'\n" (List.length pairs) old_name new_name

(** {1 性能优化实现} *)

let enable_background_cleanup enabled =
  background_cleanup_enabled := enabled;
  Printf.printf "后台清理已%s\n" (if enabled then "启用" else "禁用")

let set_cleanup_interval interval =
  cleanup_interval := interval;
  Printf.printf "自动清理间隔已设置为: %d秒\n" interval

let optimize_cache ~cache_name =
  match find_cache_by_name cache_name with
  | None -> Printf.printf "警告: 缓存 '%s' 不存在\n" cache_name
  | Some cache ->
      let before_size = Hashtbl.length cache.entries in
      let expired = cleanup_expired_entries cache in
      let after_size = Hashtbl.length cache.entries in
      Printf.printf "缓存 '%s' 优化完成: 清理 %d 个过期项 (%d -> %d)\n" cache_name expired before_size
        after_size

let get_memory_usage ~cache_name =
  let stats = get_stats ~cache_name in
  stats.memory_usage_bytes

let get_total_memory_usage () =
  List.fold_left (fun acc (name, _) -> acc + get_memory_usage ~cache_name:name) 0 (get_all_stats ())

(** {1 兼容性接口实现} *)

module CacheManagerCompat = struct
  let default_cache = "default_compat"
  let () = if find_cache_by_name default_cache = None then create_cache default_cache

  let get key =
    match get ~cache_name:default_cache key with
    | Some (CustomValue (_, bytes)) -> ( try Some (Marshal.from_bytes bytes 0) with _ -> None)
    | _ -> None

  let set key value =
    let bytes = Marshal.to_bytes value [] in
    set ~cache_name:default_cache key (CustomValue ("marshal", bytes))

  let clear () = clear ~cache_name:default_cache

  let stats () =
    let s = get_stats ~cache_name:default_cache in
    (s.hits, s.misses, s.hit_rate)
end

module ManagersCacheCompat = struct
  let cache_name = "managers_compat"
  let () = if find_cache_by_name cache_name = None then create_cache cache_name
  let cache_get key = match get ~cache_name key with Some (StringValue s) -> Some s | _ -> None
  let cache_set key value = set ~cache_name key (StringValue value)
  let cache_clear () = clear ~cache_name

  let cache_size () =
    let stats = get_stats ~cache_name in
    stats.current_size
end

(** {1 调试和工具实现} *)

let validate_cache_integrity ~cache_name =
  match find_cache_by_name cache_name with
  | None -> (false, [ "缓存不存在: " ^ cache_name ])
  | Some cache ->
      let errors = ref [] in
      let valid = ref true in

      (* 检查访问顺序列表与哈希表的一致性 *)
      let order_keys = List.sort_uniq String.compare cache.access_order in
      let hash_keys =
        Hashtbl.fold (fun k _ acc -> k :: acc) cache.entries [] |> List.sort_uniq String.compare
      in

      if order_keys <> hash_keys then (
        errors := "访问顺序列表与哈希表不一致" :: !errors;
        valid := false);

      (* 检查过期项 *)
      let expired_count = ref 0 in
      Hashtbl.iter (fun _ entry -> if is_expired entry then incr expired_count) cache.entries;

      if !expired_count > 0 then errors := Printf.sprintf "发现 %d 个过期项" !expired_count :: !errors;

      (!valid, !errors)

let benchmark_cache_performance ~cache_name operations =
  match find_cache_by_name cache_name with
  | None -> (0.0, 0.0)
  | Some _ ->
      let test_data =
        Array.init operations (fun i ->
            ("key_" ^ string_of_int i, StringValue ("value_" ^ string_of_int i)))
      in

      (* 基准测试写入 *)
      let start_write = get_current_time () in
      Array.iter (fun (key, value) -> set ~cache_name key value) test_data;
      let write_time = (get_current_time () -. start_write) *. 1000.0 /. float_of_int operations in

      (* 基准测试读取 *)
      let start_read = get_current_time () in
      Array.iter (fun (key, _) -> ignore (get ~cache_name key)) test_data;
      let read_time = (get_current_time () -. start_read) *. 1000.0 /. float_of_int operations in

      (read_time, write_time)

let debug_cache_content ~cache_name =
  match find_cache_by_name cache_name with
  | None -> Printf.printf "缓存 '%s' 不存在\n" cache_name
  | Some cache ->
      Printf.printf "\n=== 缓存 '%s' 内容调试 ===\n" cache_name;
      Printf.printf "总项目数: %d\n" (Hashtbl.length cache.entries);
      Hashtbl.iter
        (fun key entry ->
          let value_desc =
            match entry.value with
            | JsonValue _ -> "JSON数据"
            | StringValue s -> "字符串: " ^ String.sub s 0 (min 20 (String.length s)) ^ "..."
            | StringListValue sl -> "字符串列表: " ^ string_of_int (List.length sl) ^ " 项"
            | BytesValue b -> "字节数据: " ^ string_of_int (Bytes.length b) ^ " 字节"
            | CustomValue (t, b) -> "自定义数据: " ^ t ^ " (" ^ string_of_int (Bytes.length b) ^ " 字节)"
          in
          Printf.printf "键: %s, 值: %s, 访问次数: %d\n" key value_desc entry.access_count)
        cache.entries;
      Printf.printf "==========================\n\n"

let get_cache_health_report ~cache_name =
  match find_cache_by_name cache_name with
  | None -> "缓存不存在: " ^ cache_name
  | Some cache ->
      let stats = get_stats ~cache_name in
      let integrity_ok, integrity_errors = validate_cache_integrity ~cache_name in
      let expired_count =
        Hashtbl.fold (fun _ entry acc -> if is_expired entry then acc + 1 else acc) cache.entries 0
      in

      Printf.sprintf
        "缓存健康报告: %s\n- 完整性: %s\n- 当前大小: %d/%d\n- 命中率: %.2f%%\n- 过期项: %d\n- 内存使用: %d 字节\n- 问题: %s"
        cache_name
        (if integrity_ok then "正常" else "有问题")
        stats.current_size cache.config.max_size (stats.hit_rate *. 100.0) expired_count
        stats.memory_usage_bytes
        (if integrity_errors = [] then "无" else String.concat "; " integrity_errors)
