(** 韵律引擎核心模块 - 整合版本
 * 
 * 此模块整合了韵律分析、匹配、验证和查询功能
 * 
 * @author 骆言编程团队 - 韵律引擎整合项目
 * @version 1.0 (新建整合版本)
 * @since 2025-08-02
 * @issue #2117 修复编译警告
 *)

open Poetry_core.Poetry_types

(** {1 韵律引擎核心类型定义} *)

(** 韵律性能统计信息 *)
type rhyme_performance_stats = {
  query_count : int;
  cache_hit_rate : float;
  average_response_time : float;
}

(** 韵律引擎配置 *)
type rhyme_engine_config = {
  enable_cache : bool;
  max_cache_size : int;
  strict_mode : bool;
}

(** 韵律引擎元信息 *)
type rhyme_engine_info = {
  version : string;
  total_entries : int;
  cache_l1_size : int;
  cache_l2_size : int;
  performance_stats : rhyme_performance_stats;
  config : rhyme_engine_config;
  health_status : bool;
}

(** 韵律引擎主结构 *)
type rhyme_engine = {
  info : rhyme_engine_info;
  category_index : (rhyme_category, string list) Hashtbl.t;
  group_index : (rhyme_group, string list) Hashtbl.t;
  char_cache : (string, rhyme_category * rhyme_group) Hashtbl.t;
  mutable initialized : bool;
}

(** {1 引擎初始化和管理} *)

(** 创建默认引擎配置 *)
let create_default_config () = {
  enable_cache = true;
  max_cache_size = 10000;
  strict_mode = false;
}

(** 创建默认性能统计 *)
let create_default_stats () = {
  query_count = 0;
  cache_hit_rate = 0.0;
  average_response_time = 0.0;
}

(** 创建引擎元信息 *)
let create_engine_info () = {
  version = "1.0.0";
  total_entries = 0;
  cache_l1_size = 1000;
  cache_l2_size = 5000;
  performance_stats = create_default_stats ();
  config = create_default_config ();
  health_status = true;
}

(** 创建新的韵律引擎实例 *)
let create_engine () = {
  info = create_engine_info ();
  category_index = Hashtbl.create 16;
  group_index = Hashtbl.create 32;
  char_cache = Hashtbl.create 1000;
  initialized = false;
}

(** {1 辅助函数} *)

(** 索引和状态访问函数 - 修复unused字段警告 *)
let get_category_index engine = engine.category_index
let is_engine_initialized engine = engine.initialized

(** {1 核心引擎功能} *)

(** 初始化引擎数据 *)
let initialize_engine engine =
  if not (is_engine_initialized engine) then (
    (* 加载韵律数据到缓存 *)
    Poetry.Unified_rhyme_data.load_rhyme_data_to_cache ();
    engine.initialized <- true
  )

(** 查找字符的韵律信息 *)
let find_char_rhyme engine char =
  initialize_engine engine;
  match Hashtbl.find_opt engine.char_cache char with
  | Some result -> Some result
  | None -> 
      match Poetry.Unified_rhyme_engine.find_rhyme_info char with
      | Some (category, group) ->
          Hashtbl.add engine.char_cache char (category, group);
          Some (category, group)
      | None -> None

(** 检查两字符是否押韵 *)
let check_rhyme_compatibility engine char1 char2 =
  match (find_char_rhyme engine char1, find_char_rhyme engine char2) with
  | Some (_, group1), Some (_, group2) -> group1 = group2
  | _ -> false

(** 分析诗句的韵律模式 *)
let analyze_verse_pattern engine verses =
  List.map (fun verse ->
    if String.length verse > 0 then
      let last_char = String.sub verse (String.length verse - 1) 1 in
      find_char_rhyme engine last_char
    else None
  ) verses

(** 验证诗词的韵律一致性 *)
let validate_poem_rhyme engine lines =
  let rhyme_info = analyze_verse_pattern engine lines in
  let valid_rhymes = List.filter_map (fun x -> x) rhyme_info in
  match valid_rhymes with
  | [] -> false
  | (_, first_group) :: rest ->
      List.for_all (fun (_, group) -> group = first_group) rest

(** {1 查询和搜索功能} *)

(** 按韵类查找字符 *)
let find_chars_by_category engine category =
  initialize_engine engine;
  let category_idx = get_category_index engine in
  match Hashtbl.find_opt category_idx category with
  | Some chars -> chars
  | None ->
      let chars = Poetry.Unified_rhyme_engine.get_chars_by_category category in
      Hashtbl.add category_idx category chars;
      chars

(** 按韵组查找字符 *)
let find_chars_by_group engine group =
  initialize_engine engine;
  match Hashtbl.find_opt engine.group_index group with
  | Some chars -> chars
  | None ->
      let chars = Poetry.Unified_rhyme_engine.get_rhyme_characters group in
      Hashtbl.add engine.group_index group chars;
      chars

(** 查找与指定字符押韵的所有字符 *)
let find_rhyming_chars engine char =
  match find_char_rhyme engine char with
  | Some (_, group) -> find_chars_by_group engine group
  | None -> []

(** {1 引擎状态和诊断} *)

(** 基础信息访问函数 - 修复unused字段警告 *)
let get_engine_version (info : rhyme_engine_info) = info.version
let get_total_entries (info : rhyme_engine_info) = info.total_entries
let get_cache_sizes (info : rhyme_engine_info) = (info.cache_l1_size, info.cache_l2_size)

(** 性能和配置访问函数 - 修复unused字段警告 *)
let get_performance_stats info = info.performance_stats  
let get_engine_config info = info.config
let is_engine_healthy info = info.health_status

(** 获取引擎运行信息 - 现在已被使用 *)
let get_engine_info engine = engine.info

(** 修复get_engine_info函数使用示例 *)
let print_engine_status engine =
  let info = get_engine_info engine in
  Printf.printf "Engine Status: %s | Version: %s | Entries: %d\n"
    (if info.health_status then "健康" else "异常")
    info.version
    info.total_entries

(** 检查引擎健康状态 *)
let check_engine_health engine =
  let info = get_engine_info engine in
  is_engine_healthy info

(** 获取引擎统计信息 *)
let get_engine_statistics engine =
  let info = get_engine_info engine in
  Printf.sprintf 
    "引擎版本: %s | 总条目数: %d | 缓存L1大小: %d | 缓存L2大小: %d"
    (get_engine_version info)
    (get_total_entries info)
    (fst (get_cache_sizes info))
    (snd (get_cache_sizes info))

(** 清理引擎资源 *)
let cleanup_engine engine =
  let category_idx = get_category_index engine in
  Hashtbl.clear category_idx;
  Hashtbl.clear engine.group_index;
  Hashtbl.clear engine.char_cache;
  engine.initialized <- false

(** {1 全局引擎实例} *)

(** 全局引擎实例 *)
let global_engine = create_engine ()

(** 获取全局引擎实例 *)
let get_global_engine () = global_engine

(** {1 兼容性接口} *)

(** 简化的韵律检查接口 *)
let simple_rhyme_check char1 char2 =
  check_rhyme_compatibility global_engine char1 char2

(** 简化的韵律分析接口 *)
let simple_analyze_verse verse =
  if String.length verse > 0 then
    let last_char = String.sub verse (String.length verse - 1) 1 in
    find_char_rhyme global_engine last_char
  else None

(** 简化的押韵字符查找接口 *)
let simple_find_rhyming_chars char =
  find_rhyming_chars global_engine char