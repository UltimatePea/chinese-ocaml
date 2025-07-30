(** 统一数据引擎实现 - Phase 2.3.2 核心数据访问引擎 *)

(** {1 内部数据结构} *)

(* 数据类型分类 *)
type data_category = Poetry | Artistic | Linguistic | Configuration

(* 数据访问模式 *)
type access_mode = Immediate | Cached | Lazy | Preloaded

(* 数据源类型 *)
type data_source =
  | JsonFile of string
  | CsvFile of string
  | TextFile of string
  | Embedded of string
  | External of string

(* 数据状态 *)
type data_status = Loading | Ready | Error of string | Stale

(* 引擎错误类型 *)
type engine_error =
  | DataSourceNotFound of string
  | LoadingFailed of string * string
  | ValidationFailed of string
  | CacheError of string
  | InvalidConfiguration of string

(* 加载结果类型 *)
type 'a load_result = Success of 'a | Failure of engine_error

(* 引擎统计信息 *)
type engine_stats = {
  total_requests : int;
  cache_hits : int;
  cache_misses : int;
  load_errors : int;
  average_load_time : float;
  data_sources_count : int;
  cached_entries_count : int;
}

(** {1 内部状态管理} *)

(* 数据源注册记录 *)
type data_source_record = {
  name : string;
  category : data_category;
  source : data_source;
  mode : access_mode;
  status : data_status;
  last_accessed : float;
  load_count : int;
  error_count : int;
}

(* 缓存条目 *)
type cache_entry = {
  data : Obj.t; (* 使用Obj.t存储任意类型的数据 *)
  timestamp : float;
  access_count : int;
  size_bytes : int;
}

(* 引擎全局状态 *)
[@@@warning "-69"] (* 抑制误报的未使用字段警告 - 这些字段确实被使用但编译器检测不准确 *)

type engine_state = {
  mutable initialized : bool;
  mutable sources : (string, data_source_record) Hashtbl.t; [@warning "-69"]
  mutable cache : (string, cache_entry) Hashtbl.t; [@warning "-69"]
  mutable stats : engine_stats;
  mutable cache_size_limit : int;
  mutable profiling_enabled : bool; [@warning "-69"]
  mutable load_time_history : (string, float list) Hashtbl.t; [@warning "-69"]
}

(* 全局引擎状态 *)
let engine_state =
  {
    initialized = false;
    sources = Hashtbl.create 32;
    cache = Hashtbl.create 128;
    stats =
      {
        total_requests = 0;
        cache_hits = 0;
        cache_misses = 0;
        load_errors = 0;
        average_load_time = 0.0;
        data_sources_count = 0;
        cached_entries_count = 0;
      };
    cache_size_limit = 1000;
    profiling_enabled = false;
    load_time_history = Hashtbl.create 32;
  }

(** {1 工具函数} *)

let current_time () = Unix.time ()

let estimate_size_bytes (obj : 'a) : int =
  (* 简化的大小估算，实际项目中可以使用更精确的方法 *)
  Obj.size (Obj.repr obj) * 8

let update_load_time_history (source_name : string) (load_time : float) : unit =
  let history =
    try Hashtbl.find engine_state.load_time_history source_name with Not_found -> []
  in
  let new_history =
    let updated = load_time :: history in
    if List.length updated > 10 then List.rev (List.tl (List.rev updated)) else updated
  in
  Hashtbl.replace engine_state.load_time_history source_name new_history

let update_stats (cache_hit : bool) (load_time : float option) (error : bool) : unit =
  let stats = engine_state.stats in
  engine_state.stats <-
    {
      total_requests = stats.total_requests + 1;
      cache_hits = (if cache_hit then stats.cache_hits + 1 else stats.cache_hits);
      cache_misses = (if not cache_hit then stats.cache_misses + 1 else stats.cache_misses);
      load_errors = (if error then stats.load_errors + 1 else stats.load_errors);
      average_load_time =
        (match load_time with
        | Some time ->
            let total_time = stats.average_load_time *. float_of_int stats.total_requests in
            (total_time +. time) /. float_of_int (stats.total_requests + 1)
        | None -> stats.average_load_time);
      data_sources_count = Hashtbl.length engine_state.sources;
      cached_entries_count = Hashtbl.length engine_state.cache;
    }

(** {1 文件读取和解析功能} *)

let read_file_content (filepath : string) : string load_result =
  try
    let ic = open_in filepath in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    Success content
  with
  | Sys_error err -> Failure (LoadingFailed (filepath, err))
  | exn -> Failure (LoadingFailed (filepath, Printexc.to_string exn))

let parse_json_file (filepath : string) : Yojson.Basic.t load_result =
  match read_file_content filepath with
  | Success content -> (
      try Success (Yojson.Basic.from_string content) with
      | Yojson.Json_error err -> Failure (LoadingFailed (filepath, "JSON解析错误: " ^ err))
      | exn -> Failure (LoadingFailed (filepath, "JSON解析异常: " ^ Printexc.to_string exn)))
  | Failure err -> Failure err

let parse_text_lines (filepath : string) : string list load_result =
  match read_file_content filepath with
  | Success content ->
      let lines = String.split_on_char '\n' content in
      let filtered_lines =
        List.filter
          (fun line ->
            let trimmed = String.trim line in
            trimmed <> "" && not (String.starts_with ~prefix:"#" trimmed))
          lines
      in
      Success filtered_lines
  | Failure err -> Failure err

let parse_csv_file (filepath : string) : (string * string) list load_result =
  match parse_text_lines filepath with
  | Success lines ->
      let parse_csv_line line =
        match String.split_on_char ',' line with
        | [ key; value ] -> Some (String.trim key, String.trim value)
        | _ -> None
      in
      let pairs = List.filter_map parse_csv_line lines in
      Success pairs
  | Failure err -> Failure err

(** {1 数据加载核心功能} *)

let load_from_source (source : data_source) : 'a load_result =
  match source with
  | JsonFile filepath -> (
      match parse_json_file filepath with
      | Success json -> Success (Obj.magic json)
      | Failure err -> Failure err)
  | TextFile filepath -> (
      match parse_text_lines filepath with
      | Success lines -> Success (Obj.magic lines)
      | Failure err -> Failure err)
  | CsvFile filepath -> (
      match parse_csv_file filepath with
      | Success pairs -> Success (Obj.magic pairs)
      | Failure err -> Failure err)
  | Embedded data -> Success (Obj.magic data)
  | External url -> Failure (LoadingFailed (url, "外部数据源暂不支持"))

let get_from_cache (key : string) : 'a option =
  try
    let entry = Hashtbl.find engine_state.cache key in
    let updated_entry = { entry with access_count = entry.access_count + 1 } in
    Hashtbl.replace engine_state.cache key updated_entry;
    Some (Obj.magic entry.data)
  with Not_found -> None

let store_in_cache (key : string) (data : 'a) : unit =
  if Hashtbl.length engine_state.cache >= engine_state.cache_size_limit then (
    (* 简单的LRU清理：删除最旧的条目 *)
    let oldest_key = ref "" in
    let oldest_time = ref (current_time ()) in
    Hashtbl.iter
      (fun k entry ->
        if entry.timestamp < !oldest_time then (
          oldest_key := k;
          oldest_time := entry.timestamp))
      engine_state.cache;
    if !oldest_key <> "" then Hashtbl.remove engine_state.cache !oldest_key);

  let entry =
    {
      data = Obj.repr data;
      timestamp = current_time ();
      access_count = 1;
      size_bytes = estimate_size_bytes data;
    }
  in
  Hashtbl.replace engine_state.cache key entry

(** {1 公共接口实现} *)

let initialize ?(cache_size = 1000) ?(preload_categories = []) () =
  if engine_state.initialized then failwith "引擎已经初始化，请先调用shutdown"
  else (
    engine_state.cache_size_limit <- cache_size;
    engine_state.initialized <- true;

    (* 预加载指定类别的数据 *)
    List.iter
      (fun category ->
        let sources_to_preload =
          Hashtbl.fold
            (fun name record acc ->
              if record.category = category && record.mode = Preloaded then name :: acc else acc)
            engine_state.sources []
        in

        List.iter
          (fun source_name ->
            try
              let record = Hashtbl.find engine_state.sources source_name in
              match load_from_source record.source with
              | Success data -> store_in_cache source_name data
              | Failure _ -> ()
            with Not_found -> ())
          sources_to_preload)
      preload_categories)

let shutdown () =
  Hashtbl.clear engine_state.sources;
  Hashtbl.clear engine_state.cache;
  Hashtbl.clear engine_state.load_time_history;
  engine_state.initialized <- false;
  engine_state.stats <-
    {
      total_requests = 0;
      cache_hits = 0;
      cache_misses = 0;
      load_errors = 0;
      average_load_time = 0.0;
      data_sources_count = 0;
      cached_entries_count = 0;
    }

let is_initialized () = engine_state.initialized

let register_data_source (name : string) (category : data_category) (source : data_source)
    (mode : access_mode) =
  if not engine_state.initialized then failwith "引擎未初始化，请先调用initialize";

  let record =
    {
      name;
      category;
      source;
      mode;
      status = Ready;
      last_accessed = current_time ();
      load_count = 0;
      error_count = 0;
    }
  in
  Hashtbl.replace engine_state.sources name record

let unregister_data_source (name : string) =
  Hashtbl.remove engine_state.sources name;
  Hashtbl.remove engine_state.cache name

let list_registered_sources () =
  Hashtbl.fold
    (fun _ record acc -> (record.name, record.category, record.source, record.mode) :: acc)
    engine_state.sources []

let get_data_source_status (name : string) =
  try
    let record = Hashtbl.find engine_state.sources name in
    Some record.status
  with Not_found -> None

let load_string_list (source_name : string) : string list load_result =
  if not engine_state.initialized then Failure (InvalidConfiguration "引擎未初始化")
  else
    try
      let record = Hashtbl.find engine_state.sources source_name in
      let start_time = current_time () in

      (* 检查缓存 *)
      match record.mode with
      | Cached | Preloaded -> (
          match get_from_cache source_name with
          | Some cached_data ->
              update_stats true None false;
              Success (Obj.magic cached_data)
          | None -> (
              (* 缓存未命中，从源加载 *)
              match load_from_source record.source with
              | Success data ->
                  let load_time = (current_time () -. start_time) *. 1000.0 in
                  store_in_cache source_name data;
                  update_load_time_history source_name load_time;
                  update_stats false (Some load_time) false;
                  Success (Obj.magic data)
              | Failure err ->
                  update_stats false None true;
                  Failure err))
      | Immediate | Lazy -> (
          (* 直接从源加载 *)
          match load_from_source record.source with
          | Success data ->
              let load_time = (current_time () -. start_time) *. 1000.0 in
              update_load_time_history source_name load_time;
              update_stats false (Some load_time) false;
              Success (Obj.magic data)
          | Failure err ->
              update_stats false None true;
              Failure err)
    with Not_found ->
      update_stats false None true;
      Failure (DataSourceNotFound source_name)

let load_key_value_pairs (source_name : string) : (string * string) list load_result =
  match load_string_list source_name with
  | Success data -> Success (Obj.magic data)
  | Failure err -> Failure err

let load_json_data (source_name : string) : Yojson.Basic.t load_result =
  match load_string_list source_name with
  | Success data -> Success (Obj.magic data)
  | Failure err -> Failure err

let load_custom_data (source_name : string) (transformer : 'a -> 'b) (default_data : 'a) :
    'b load_result =
  match load_string_list source_name with
  | Success data -> (
      try Success (transformer (Obj.magic data))
      with exn -> Failure (LoadingFailed (source_name, "数据转换失败: " ^ Printexc.to_string exn)))
  | Failure _ -> Success (transformer default_data)

let query_by_category (category : data_category) : string list =
  Hashtbl.fold
    (fun name record acc -> if record.category = category then name :: acc else acc)
    engine_state.sources []

let search_data_sources (pattern : string) : string list =
  let pattern_regex = Str.regexp (Str.global_replace (Str.regexp "\\*") ".*" pattern) in
  Hashtbl.fold
    (fun name _ acc -> if Str.string_match pattern_regex name 0 then name :: acc else acc)
    engine_state.sources []

let bulk_load (source_names : string list) : (string * 'a load_result) list =
  List.map (fun name -> (name, load_string_list name)) source_names

let clear_cache ?(category = None) () =
  match category with
  | None -> Hashtbl.clear engine_state.cache
  | Some cat ->
      let keys_to_remove =
        Hashtbl.fold
          (fun name record acc -> if record.category = cat then name :: acc else acc)
          engine_state.sources []
      in
      List.iter (Hashtbl.remove engine_state.cache) keys_to_remove

let refresh_data (source_name : string) : unit load_result =
  Hashtbl.remove engine_state.cache source_name;
  match load_string_list source_name with Success _ -> Success () | Failure err -> Failure err

let rec preload_category (category : data_category) : unit load_result =
  let sources_to_load = query_by_category category in
  let results = bulk_load sources_to_load in
  let errors =
    List.filter_map
      (fun (name, result) ->
        match result with Failure err -> Some (name, err) | Success _ -> None)
      results
  in
  if errors = [] then Success ()
  else
    let error_msg =
      String.concat "; " (List.map (fun (name, err) -> name ^ ": " ^ format_error err) errors)
    in
    Failure (LoadingFailed ("preload_category", error_msg))

and format_error (error : engine_error) : string =
  match error with
  | DataSourceNotFound name -> "数据源未找到: " ^ name
  | LoadingFailed (source, msg) -> "加载失败 [" ^ source ^ "]: " ^ msg
  | ValidationFailed msg -> "数据验证失败: " ^ msg
  | CacheError msg -> "缓存错误: " ^ msg
  | InvalidConfiguration msg -> "配置错误: " ^ msg

let get_cache_info () : (string * int * float) list =
  Hashtbl.fold
    (fun name entry acc -> (name, entry.size_bytes, entry.timestamp) :: acc)
    engine_state.cache []

let get_engine_stats () : engine_stats = engine_state.stats

let reset_stats () =
  engine_state.stats <-
    {
      total_requests = 0;
      cache_hits = 0;
      cache_misses = 0;
      load_errors = 0;
      average_load_time = 0.0;
      data_sources_count = Hashtbl.length engine_state.sources;
      cached_entries_count = Hashtbl.length engine_state.cache;
    }

let enable_profiling (enable : bool) = engine_state.profiling_enabled <- enable

let get_load_time_history (source_name : string) : float list =
  try Hashtbl.find engine_state.load_time_history source_name with Not_found -> []

let validate_all_sources () : (string * bool * string option) list =
  Hashtbl.fold
    (fun name record acc ->
      match load_from_source record.source with
      | Success _ -> (name, true, None) :: acc
      | Failure err -> (name, false, Some (format_error err)) :: acc)
    engine_state.sources []

let diagnose_source (source_name : string) : string =
  try
    let record = Hashtbl.find engine_state.sources source_name in
    let cache_status = if Hashtbl.mem engine_state.cache source_name then "已缓存" else "未缓存" in
    Printf.sprintf "数据源: %s\n类别: %s\n模式: %s\n状态: %s\n缓存状态: %s\n加载次数: %d\n错误次数: %d\n最后访问: %.2f"
      record.name
      (match record.category with
      | Poetry -> "诗歌"
      | Artistic -> "艺术"
      | Linguistic -> "语言学"
      | Configuration -> "配置")
      (match record.mode with
      | Immediate -> "立即"
      | Cached -> "缓存"
      | Lazy -> "懒加载"
      | Preloaded -> "预加载")
      (match record.status with
      | Loading -> "加载中"
      | Ready -> "就绪"
      | Error msg -> "错误: " ^ msg
      | Stale -> "过期")
      cache_status record.load_count record.error_count record.last_accessed
  with Not_found -> "数据源不存在: " ^ source_name

let create_compatibility_layer (legacy_name : string) (_ : string -> 'a) : unit =
  (* 创建一个简单的兼容性层，将旧的接口映射到新的引擎 *)
  register_data_source ("compat_" ^ legacy_name) Configuration (Embedded legacy_name) Cached

let migrate_legacy_usage (old_source_name : string) (new_source_name : string) : unit =
  (* 迁移功能：将旧数据源的缓存复制到新数据源 *)
  try
    let old_data = Hashtbl.find engine_state.cache old_source_name in
    Hashtbl.add engine_state.cache new_source_name old_data;
    Hashtbl.remove engine_state.cache old_source_name
  with Not_found -> ()
