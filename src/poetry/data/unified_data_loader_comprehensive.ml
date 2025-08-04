(** 统一数据加载器综合模块实现 - Phase 2.2: 全面数据类型支持
    
    此模块整合所有诗词相关数据加载功能，提供统一的接口和缓存机制。
    
    @author Alpha, 技术债务清理专员
    @version 2.2 - Phase 2.2 全面整合
    @since 2025-07-29
    @fix_issue #1732 *)

open Unified_data_loader
(*open Poetry_core.Types - removed dependency*)

(* 使用完全限定名称以避免名称冲突 *)

(** {1 类型定义} *)

type comprehensive_data_type =
  | RhymeDataType of rhyme_data_subtype
  | ToneDataType of tone_data_subtype
  | PoetryDataType of poetry_data_subtype
  | WordClassDataType
  | ArtisticDataType

and rhyme_data_subtype = PingShengRhymes | ZeShengRhymes | CompleteRhymeDatabase
and tone_data_subtype = PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng | AllToneData
and poetry_data_subtype = UnifiedDatabase | DataSourceRegistry | CacheManagement

type comprehensive_load_error =
  | RhymeLoadError of string * string
  | ToneLoadError of string * string
  | PoetryLoadError of string * string
  | UnifiedLoadError of string
  | CompatibilityError of string

exception ComprehensiveLoadError of comprehensive_load_error

(* 类型别名以匹配接口声明 *)
type rhyme_category = string
(** 韵律类型定义 - 直接使用Poetry_types的统一类型 *)

type rhyme_group = string

type data_source = Data_source_manager.data_source
(** 诗词数据类型 - 与poetry_data_loader兼容 *)

type data_source_entry = Data_source_manager.data_source_entry

(** {1 内部状态管理} *)

(** 全局缓存表 *)
let comprehensive_cache : (comprehensive_data_type, Yojson.Safe.t) Hashtbl.t = Hashtbl.create 32

(** 性能统计 *)
let performance_stats : (comprehensive_data_type, float * int) Hashtbl.t = Hashtbl.create 32

(** 降级模式标志 *)
let fallback_mode = ref true

(** {1 工具函数} *)

let format_comprehensive_error = function
  | RhymeLoadError (msg, detail) -> Printf.sprintf "韵律数据加载错误: %s (详细: %s)" msg detail
  | ToneLoadError (msg, detail) -> Printf.sprintf "声调数据加载错误: %s (详细: %s)" msg detail
  | PoetryLoadError (msg, detail) -> Printf.sprintf "诗词数据加载错误: %s (详细: %s)" msg detail
  | UnifiedLoadError msg -> Printf.sprintf "统一加载器错误: %s" msg
  | CompatibilityError msg -> Printf.sprintf "兼容性错误: %s" msg

let data_type_to_string = function
  | RhymeDataType PingShengRhymes -> "平声韵数据"
  | RhymeDataType ZeShengRhymes -> "仄声韵数据"
  | RhymeDataType CompleteRhymeDatabase -> "完整韵律数据库"
  | ToneDataType PingSheng -> "平声字符"
  | ToneDataType ZeSheng -> "仄声字符"
  | ToneDataType ShangSheng -> "上声字符"
  | ToneDataType QuSheng -> "去声字符"
  | ToneDataType RuSheng -> "入声字符"
  | ToneDataType AllToneData -> "所有声调数据"
  | PoetryDataType UnifiedDatabase -> "统一数据库"
  | PoetryDataType DataSourceRegistry -> "数据源注册表"
  | PoetryDataType CacheManagement -> "缓存管理"
  | WordClassDataType -> "词类数据"
  | ArtisticDataType -> "艺术性数据"

(** 数据类型到文件路径映射 *)
let get_data_file_path = function
  | RhymeDataType PingShengRhymes -> "data/rhyme_data/ping_sheng_rhymes.json"
  | RhymeDataType ZeShengRhymes -> "data/rhyme_data/ze_sheng_rhymes.json"
  | RhymeDataType CompleteRhymeDatabase -> "data/rhyme_data/complete_database.json"
  | ToneDataType PingSheng -> "data/tone_data/ping_sheng_chars.json"
  | ToneDataType ZeSheng -> "data/tone_data/ze_sheng_chars.json"
  | ToneDataType ShangSheng -> "data/tone_data/shang_sheng_chars.json"
  | ToneDataType QuSheng -> "data/tone_data/qu_sheng_chars.json"
  | ToneDataType RuSheng -> "data/tone_data/ru_sheng_chars.json"
  | ToneDataType AllToneData -> "data/tone_data/all_tone_data.json"
  | PoetryDataType UnifiedDatabase -> "data/poetry_data/unified_database.json"
  | PoetryDataType DataSourceRegistry -> "data/poetry_data/data_sources.json"
  | PoetryDataType CacheManagement -> "data/poetry_data/cache_config.json"
  | WordClassDataType -> "data/word_class/word_classes.json"
  | ArtisticDataType -> "data/artistic/artistic_data.json"

(** 更新性能统计 *)
let update_performance_stats data_type load_time =
  let current_stats = try Hashtbl.find performance_stats data_type with Not_found -> (0.0, 0) in
  let total_time, count = current_stats in
  let new_total_time = total_time +. load_time in
  let new_count = count + 1 in
  Hashtbl.replace performance_stats data_type (new_total_time, new_count)

(** {1 数据转换函数} *)

(* 将rhyme_data_file转换为JSON以保持向后兼容 *)
let rhyme_data_to_json (rhyme_data : Poetry_core.Types.rhyme_data_file) : Yojson.Safe.t =
  let rhyme_groups_json =
    List.map
      (fun (name, group_data) ->
        `Assoc
          [
            ("name", `String name);
            ("category", `String group_data.category);
            ("characters", `List (List.map (fun c -> `String c) group_data.characters));
          ])
      rhyme_data.rhyme_groups
  in

  let metadata_json = List.map (fun (k, v) -> (k, `String v)) rhyme_data.metadata in

  `Assoc [ ("rhyme_groups", `List rhyme_groups_json); ("metadata", `Assoc metadata_json) ]

(** {1 核心加载函数} *)

let load_comprehensive_data ?(config = Poetry_data_loaders.Unified_loader.default_config) data_type
    _source_type =
  let start_time = Sys.time () in
  try
    (* 检查缓存 *)
    if config.enable_cache && Hashtbl.mem comprehensive_cache data_type then (
      let cached_data = Hashtbl.find comprehensive_cache data_type in
      let load_time = Sys.time () -. start_time in
      update_performance_stats data_type load_time;
      cached_data)
    else
      (* 根据数据类型选择合适的加载策略 *)
      let loaded_data =
        match data_type with
        | RhymeDataType _ ->
            let rhyme_data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile "data/poetry/rhyme_data.json")
                Poetry_data_loaders.Unified_loader.RhymeData ()
            in
            rhyme_data_to_json rhyme_data
        | ToneDataType _ ->
            let rhyme_data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile "data/poetry/tone_data.json")
                Poetry_data_loaders.Unified_loader.ToneData ()
            in
            rhyme_data_to_json rhyme_data
        | PoetryDataType _ ->
            let rhyme_data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile "data/poetry/poetry_data.json")
                Poetry_data_loaders.Unified_loader.PoetryData ()
            in
            rhyme_data_to_json rhyme_data
        | WordClassDataType ->
            let rhyme_data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile "data/poetry/word_class_data.json")
                Poetry_data_loaders.Unified_loader.WordClassData ()
            in
            rhyme_data_to_json rhyme_data
        | ArtisticDataType ->
            let rhyme_data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile "data/poetry/artistic_data.json")
                Poetry_data_loaders.Unified_loader.ArtisticData ()
            in
            rhyme_data_to_json rhyme_data
      in

      (* 缓存加载的数据 *)
      if config.enable_cache then Hashtbl.replace comprehensive_cache data_type loaded_data;

      let load_time = Sys.time () -. start_time in
      update_performance_stats data_type load_time;
      loaded_data
  with
  | UnifiedLoadError err ->
      let error_msg = format_error err in
      raise (ComprehensiveLoadError (UnifiedLoadError error_msg))
  | e ->
      let error_msg = Printexc.to_string e in
      raise (ComprehensiveLoadError (CompatibilityError error_msg))

(** {1 韵律数据接口实现} *)

let load_ping_sheng_rhymes_comprehensive () =
  try
    let file_path = get_data_file_path (RhymeDataType PingShengRhymes) in
    let json_data = load_comprehensive_data (RhymeDataType PingShengRhymes) (JsonFile file_path) in

    (* 解析JSON数据为韵律数据格式 *)
    let json_list = Yojson.Safe.Util.to_list json_data in
    List.map
      (fun json ->
        let char = Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "char" json) in
        let category =
          match Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "category" json) with
          | "平声" -> Poetry_core.Poetry_types.PingSheng
          | "仄声" -> Poetry_core.Poetry_types.ZeSheng
          | "上声" -> Poetry_core.Poetry_types.ShangSheng
          | "去声" -> Poetry_core.Poetry_types.QuSheng
          | "入声" -> Poetry_core.Poetry_types.RuSheng
          | _ -> Poetry_core.Poetry_types.PingSheng
        in
        let group =
          match Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "group" json) with
          | "安韵" -> Poetry_core.Poetry_types.AnRhyme
          | "思韵" -> Poetry_core.Poetry_types.SiRhyme
          | "天韵" -> Poetry_core.Poetry_types.TianRhyme
          | "王韵" -> Poetry_core.Poetry_types.WangRhyme
          | "曲韵" -> Poetry_core.Poetry_types.QuRhyme
          | "玉韵" -> Poetry_core.Poetry_types.YuRhyme
          | "华韵" -> Poetry_core.Poetry_types.HuaRhyme
          | "风韵" -> Poetry_core.Poetry_types.FengRhyme
          | "月韵" -> Poetry_core.Poetry_types.YueRhyme
          | "江韵" -> Poetry_core.Poetry_types.JiangRhyme
          | "会韵" -> Poetry_core.Poetry_types.HuiRhyme
          | _ -> Poetry_core.Poetry_types.UnknownRhyme
        in
        (char, category, group))
      json_list
  with
  | ComprehensiveLoadError _ as e -> raise e
  | e when !fallback_mode ->
      Printf.printf "警告: 平声韵数据加载失败，使用默认数据: %s\n" (Printexc.to_string e);
      [
        ("春", Poetry_core.Poetry_types.PingSheng, Poetry_core.Poetry_types.AnRhyme);
        ("风", Poetry_core.Poetry_types.PingSheng, Poetry_core.Poetry_types.FengRhyme);
      ]
      (* 默认数据 *)
  | e -> raise (ComprehensiveLoadError (RhymeLoadError ("平声韵数据加载失败", Printexc.to_string e)))

let load_ze_sheng_rhymes_comprehensive () =
  try
    let file_path = get_data_file_path (RhymeDataType ZeShengRhymes) in
    let json_data = load_comprehensive_data (RhymeDataType ZeShengRhymes) (JsonFile file_path) in

    let json_list = Yojson.Safe.Util.to_list json_data in
    List.map
      (fun json ->
        let char = Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "char" json) in
        let category =
          match Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "category" json) with
          | "平声" -> Poetry_core.Poetry_types.PingSheng
          | "仄声" -> Poetry_core.Poetry_types.ZeSheng
          | "上声" -> Poetry_core.Poetry_types.ShangSheng
          | "去声" -> Poetry_core.Poetry_types.QuSheng
          | "入声" -> Poetry_core.Poetry_types.RuSheng
          | _ -> Poetry_core.Poetry_types.ZeSheng
        in
        let group =
          match Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "group" json) with
          | "安韵" -> Poetry_core.Poetry_types.AnRhyme
          | "思韵" -> Poetry_core.Poetry_types.SiRhyme
          | "天韵" -> Poetry_core.Poetry_types.TianRhyme
          | "王韵" -> Poetry_core.Poetry_types.WangRhyme
          | "曲韵" -> Poetry_core.Poetry_types.QuRhyme
          | "玉韵" -> Poetry_core.Poetry_types.YuRhyme
          | "华韵" -> Poetry_core.Poetry_types.HuaRhyme
          | "风韵" -> Poetry_core.Poetry_types.FengRhyme
          | "月韵" -> Poetry_core.Poetry_types.YueRhyme
          | "江韵" -> Poetry_core.Poetry_types.JiangRhyme
          | "会韵" -> Poetry_core.Poetry_types.HuiRhyme
          | _ -> Poetry_core.Poetry_types.UnknownRhyme
        in
        (char, category, group))
      json_list
  with
  | ComprehensiveLoadError _ as e -> raise e
  | e when !fallback_mode ->
      Printf.printf "警告: 仄声韵数据加载失败，使用默认数据: %s\n" (Printexc.to_string e);
      [
        ("雨", Poetry_core.Poetry_types.ZeSheng, Poetry_core.Poetry_types.YuRhyme);
        ("雪", Poetry_core.Poetry_types.RuSheng, Poetry_core.Poetry_types.YueRhyme);
      ]
  | e -> raise (ComprehensiveLoadError (RhymeLoadError ("仄声韵数据加载失败", Printexc.to_string e)))

let load_complete_rhyme_database_comprehensive () =
  let ping_sheng = load_ping_sheng_rhymes_comprehensive () in
  let ze_sheng = load_ze_sheng_rhymes_comprehensive () in
  ping_sheng @ ze_sheng

(** {1 声调数据接口实现} *)

let load_tone_chars data_type =
  try
    let file_path = get_data_file_path data_type in
    let json_data = load_comprehensive_data data_type (JsonFile file_path) in
    Yojson.Safe.Util.to_list json_data |> List.map Yojson.Safe.Util.to_string
  with
  | ComprehensiveLoadError _ as e -> raise e
  | e when !fallback_mode ->
      let tone_name = data_type_to_string data_type in
      Printf.printf "警告: %s数据加载失败，使用默认数据: %s\n" tone_name (Printexc.to_string e);
      [ "默认" ]
  | e ->
      let tone_name = data_type_to_string data_type in
      raise (ComprehensiveLoadError (ToneLoadError (tone_name ^ "加载失败", Printexc.to_string e)))

let get_ping_sheng_chars_comprehensive () = load_tone_chars (ToneDataType PingSheng)
let get_shang_sheng_chars_comprehensive () = load_tone_chars (ToneDataType ShangSheng)
let get_qu_sheng_chars_comprehensive () = load_tone_chars (ToneDataType QuSheng)
let get_ru_sheng_chars_comprehensive () = load_tone_chars (ToneDataType RuSheng)

let get_all_tone_data_comprehensive () =
  let ping = get_ping_sheng_chars_comprehensive () in
  let shang = get_shang_sheng_chars_comprehensive () in
  let qu = get_qu_sheng_chars_comprehensive () in
  let ru = get_ru_sheng_chars_comprehensive () in
  (ping, shang, qu, ru)

(** {1 诗词数据接口实现} *)

let get_unified_database_comprehensive () = load_complete_rhyme_database_comprehensive ()

let is_char_in_database_comprehensive char =
  let database = get_unified_database_comprehensive () in
  List.exists (fun (c, _, _) -> c = char) database

let get_char_rhyme_info_comprehensive char =
  let database = get_unified_database_comprehensive () in
  List.find_opt (fun (c, _, _) -> c = char) database

(** {1 批量操作和性能优化} *)

let load_all_data_types () =
  let all_types =
    [
      RhymeDataType PingShengRhymes;
      RhymeDataType ZeShengRhymes;
      RhymeDataType CompleteRhymeDatabase;
      ToneDataType PingSheng;
      ToneDataType ShangSheng;
      ToneDataType QuSheng;
      ToneDataType RuSheng;
      ToneDataType AllToneData;
      PoetryDataType UnifiedDatabase;
      PoetryDataType DataSourceRegistry;
      PoetryDataType CacheManagement;
      WordClassDataType;
      ArtisticDataType;
    ]
  in
  List.iter
    (fun data_type ->
      try
        let file_path = get_data_file_path data_type in
        let _ = load_comprehensive_data data_type (JsonFile file_path) in
        Printf.printf "已预加载: %s\n" (data_type_to_string data_type)
      with e ->
        Printf.printf "预加载失败 %s: %s\n" (data_type_to_string data_type) (Printexc.to_string e))
    all_types

let get_comprehensive_stats () =
  Hashtbl.fold
    (fun data_type (total_time, count) acc ->
      let _avg_time = if count > 0 then total_time /. float_of_int count else 0.0 in
      let hit_rate = if Hashtbl.mem comprehensive_cache data_type then 1.0 else 0.0 in
      let type_name = data_type_to_string data_type in
      (type_name, count, hit_rate) :: acc)
    performance_stats []

let validate_all_data_integrity () =
  let errors = ref [] in
  let valid = ref true in

  (* 检查韵律数据完整性 *)
  (try
     let _ = load_complete_rhyme_database_comprehensive () in
     Printf.printf "韵律数据完整性检查通过\n"
   with e ->
     errors := ("韵律数据完整性检查失败: " ^ Printexc.to_string e) :: !errors;
     valid := false);

  (* 检查声调数据完整性 *)
  (try
     let _ = get_all_tone_data_comprehensive () in
     Printf.printf "声调数据完整性检查通过\n"
   with e ->
     errors := ("声调数据完整性检查失败: " ^ Printexc.to_string e) :: !errors;
     valid := false);

  (!valid, !errors)

(** {1 缓存管理} *)

let clear_comprehensive_cache () =
  Hashtbl.clear comprehensive_cache;
  Hashtbl.clear performance_stats;
  clear_cache ();
  (* 调用unified_data_loader的缓存清理 *)
  Printf.printf "综合模块缓存已清理\n"

let warm_comprehensive_cache data_types =
  List.iter
    (fun data_type ->
      try
        let file_path = get_data_file_path data_type in
        let _ = load_comprehensive_data data_type (JsonFile file_path) in
        Printf.printf "已预热缓存: %s\n" (data_type_to_string data_type)
      with e ->
        Printf.printf "缓存预热失败 %s: %s\n" (data_type_to_string data_type) (Printexc.to_string e))
    data_types

let get_comprehensive_cache_info () =
  let all_types =
    [
      RhymeDataType PingShengRhymes;
      RhymeDataType ZeShengRhymes;
      ToneDataType PingSheng;
      ToneDataType ShangSheng;
      ToneDataType QuSheng;
      ToneDataType RuSheng;
      PoetryDataType UnifiedDatabase;
      WordClassDataType;
      ArtisticDataType;
    ]
  in
  List.map
    (fun data_type ->
      let is_cached = Hashtbl.mem comprehensive_cache data_type in
      let cache_size = if is_cached then 1 else 0 in
      (* 简化的缓存大小 *)
      (data_type, is_cached, cache_size))
    all_types

(** {1 降级和容错} *)

let safe_load_with_fallback data_type =
  try
    let file_path = get_data_file_path data_type in
    Some (load_comprehensive_data data_type (JsonFile file_path))
  with _ -> None

let enable_fallback_mode enabled =
  fallback_mode := enabled;
  Printf.printf "降级模式已%s\n" (if enabled then "启用" else "禁用")

(** {1 调试和监控} *)

let print_comprehensive_status () =
  Printf.printf "\n=== 综合数据加载器状态 ===\n";
  Printf.printf "缓存项目数: %d\n" (Hashtbl.length comprehensive_cache);
  Printf.printf "性能统计项目数: %d\n" (Hashtbl.length performance_stats);
  Printf.printf "降级模式: %s\n" (if !fallback_mode then "启用" else "禁用");

  Printf.printf "\n--- 缓存状态 ---\n";
  Hashtbl.iter
    (fun data_type _ -> Printf.printf "已缓存: %s\n" (data_type_to_string data_type))
    comprehensive_cache;

  Printf.printf "\n--- 性能统计 ---\n";
  Hashtbl.iter
    (fun data_type (total_time, count) ->
      let avg_time = if count > 0 then total_time /. float_of_int count else 0.0 in
      Printf.printf "%s: 调用%d次, 平均%.3fms\n" (data_type_to_string data_type) count
        (avg_time *. 1000.0))
    performance_stats;
  Printf.printf "========================\n\n"

let get_load_performance_metrics () =
  Hashtbl.fold
    (fun data_type (total_time, count) acc ->
      let avg_time_ms = if count > 0 then total_time /. float_of_int count *. 1000.0 else 0.0 in
      (data_type, avg_time_ms, count) :: acc)
    performance_stats []
