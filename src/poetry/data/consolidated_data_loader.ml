(** Poetry数据加载器整合核心模块实现 - P0专项整合
    
    整合多个重复的unified_data_loader变体，提供统一的数据加载接口。
    
    Author: Whisky, PR Worker - P0专项整合
    @version 1.0 - Phase 2.1
    @since 2025-08-04
    @fix_issue #2174 *)

(** {1 核心数据类型} *)

type consolidated_data_type =
  | RhymeData of rhyme_subtype
  | ToneData of tone_subtype
  | PoetryData of poetry_subtype
  | WordClassData of word_class_subtype
  | ExternalizedData of external_subtype
  | ArtisticData

and rhyme_subtype = PingShengRhymes | ZeShengRhymes | CompleteRhymeDatabase
and tone_subtype = PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng | AllToneData
and poetry_subtype = UnifiedDatabase | DataSourceRegistry | CacheManagement

and word_class_subtype =
  | NatureNouns
  | GeographyPoliticsNouns
  | PersonRelationNouns
  | SocialStatusNouns
  | ToolsObjectsNouns
  | BuildingPlaceNouns
  | AllWordClassData

and external_subtype = CustomJsonData of string | FileSystemData of string

(** {1 错误处理} *)

type consolidated_load_error =
  | RhymeLoadError of string * string
  | ToneLoadError of string * string
  | PoetryLoadError of string * string
  | WordClassLoadError of string * string
  | ExternalLoadError of string * string
  | ArtisticLoadError of string * string
  | ConsolidatedLoadError of string
  | CompatibilityError of string

exception ConsolidatedLoadError of consolidated_load_error

let format_consolidated_error = function
  | RhymeLoadError (msg, detail) -> Printf.sprintf "韵律数据加载错误: %s (详细: %s)" msg detail
  | ToneLoadError (msg, detail) -> Printf.sprintf "声调数据加载错误: %s (详细: %s)" msg detail
  | PoetryLoadError (msg, detail) -> Printf.sprintf "诗词数据加载错误: %s (详细: %s)" msg detail
  | WordClassLoadError (msg, detail) -> Printf.sprintf "词类数据加载错误: %s (详细: %s)" msg detail
  | ExternalLoadError (msg, detail) -> Printf.sprintf "外部数据加载错误: %s (详细: %s)" msg detail
  | ArtisticLoadError (msg, detail) -> Printf.sprintf "艺术数据加载错误: %s (详细: %s)" msg detail
  | ConsolidatedLoadError msg -> Printf.sprintf "整合加载器错误: %s" msg
  | CompatibilityError msg -> Printf.sprintf "兼容性错误: %s" msg

(** {1 加载配置} *)

type consolidated_config = {
  enable_cache : bool;
  cache_size_limit : int;
  enable_fallback : bool;
  enable_performance_tracking : bool;
  timeout_ms : int;
}

let default_config =
  {
    enable_cache = true;
    cache_size_limit = 1000;
    enable_fallback = true;
    enable_performance_tracking = true;
    timeout_ms = 30000;
  }

(** {1 兼容性类型重导出} *)

type rhyme_category = Yyocamlc_lib.Poetry_core.Poetry_types.rhyme_category
type rhyme_group = Yyocamlc_lib.Poetry_core.Poetry_types.rhyme_group
type data_source = Data_source_manager.data_source
type data_source_entry = Data_source_manager.data_source_entry

(** {1 内部状态管理} *)

(** 全局缓存表 *)
let consolidated_cache : (consolidated_data_type, Yojson.Safe.t) Hashtbl.t = Hashtbl.create 64

(** 性能统计 *)
let performance_stats : (consolidated_data_type, float * int) Hashtbl.t = Hashtbl.create 64

(** 配置状态 *)
let global_config = ref default_config

let fallback_mode = ref true
let performance_tracking = ref true

(** {1 工具函数} *)

let data_type_to_string = function
  | RhymeData PingShengRhymes -> "平声韵数据"
  | RhymeData ZeShengRhymes -> "仄声韵数据"
  | RhymeData CompleteRhymeDatabase -> "完整韵律数据库"
  | ToneData PingSheng -> "平声字符"
  | ToneData ZeSheng -> "仄声字符"
  | ToneData ShangSheng -> "上声字符"
  | ToneData QuSheng -> "去声字符"
  | ToneData RuSheng -> "入声字符"
  | ToneData AllToneData -> "所有声调数据"
  | PoetryData UnifiedDatabase -> "统一数据库"
  | PoetryData DataSourceRegistry -> "数据源注册表"
  | PoetryData CacheManagement -> "缓存管理"
  | WordClassData NatureNouns -> "自然名词"
  | WordClassData GeographyPoliticsNouns -> "地理政治名词"
  | WordClassData PersonRelationNouns -> "人物关系名词"
  | WordClassData SocialStatusNouns -> "社会地位名词"
  | WordClassData ToolsObjectsNouns -> "工具物品名词"
  | WordClassData BuildingPlaceNouns -> "建筑场所名词"
  | WordClassData AllWordClassData -> "所有词类数据"
  | ExternalizedData (CustomJsonData path) -> "自定义JSON数据: " ^ path
  | ExternalizedData (FileSystemData path) -> "文件系统数据: " ^ path
  | ArtisticData -> "艺术性数据"

(** 数据类型到文件路径映射 *)
let get_data_file_path = function
  | RhymeData PingShengRhymes -> "data/rhyme_data/ping_sheng_rhymes.json"
  | RhymeData ZeShengRhymes -> "data/rhyme_data/ze_sheng_rhymes.json"
  | RhymeData CompleteRhymeDatabase -> "data/rhyme_data/complete_database.json"
  | ToneData PingSheng -> "data/tone_data/ping_sheng_chars.json"
  | ToneData ZeSheng -> "data/tone_data/ze_sheng_chars.json"
  | ToneData ShangSheng -> "data/tone_data/shang_sheng_chars.json"
  | ToneData QuSheng -> "data/tone_data/qu_sheng_chars.json"
  | ToneData RuSheng -> "data/tone_data/ru_sheng_chars.json"
  | ToneData AllToneData -> "data/tone_data/all_tone_data.json"
  | PoetryData UnifiedDatabase -> "data/poetry_data/unified_database.json"
  | PoetryData DataSourceRegistry -> "data/poetry_data/data_sources.json"
  | PoetryData CacheManagement -> "data/poetry_data/cache_config.json"
  | WordClassData NatureNouns -> "data/word_class/nature_nouns.json"
  | WordClassData GeographyPoliticsNouns -> "data/word_class/geography_politics_nouns.json"
  | WordClassData PersonRelationNouns -> "data/word_class/person_relation_nouns.json"
  | WordClassData SocialStatusNouns -> "data/word_class/social_status_nouns.json"
  | WordClassData ToolsObjectsNouns -> "data/word_class/tools_objects_nouns.json"
  | WordClassData BuildingPlaceNouns -> "data/word_class/building_place_nouns.json"
  | WordClassData AllWordClassData -> "data/word_class/all_word_classes.json"
  | ExternalizedData (CustomJsonData path) -> path
  | ExternalizedData (FileSystemData path) -> path
  | ArtisticData -> "data/artistic/artistic_data.json"

(** 更新性能统计 *)
let update_performance_stats data_type load_time =
  if !performance_tracking then
    let current_stats = try Hashtbl.find performance_stats data_type with Not_found -> (0.0, 0) in
    let total_time, count = current_stats in
    let new_total_time = total_time +. load_time in
    let new_count = count + 1 in
    Hashtbl.replace performance_stats data_type (new_total_time, new_count)

(** {1 数据转换函数} *)

(* 整合原有的数据转换逻辑 *)
let rhyme_data_to_json (rhyme_data : Yyocamlc_lib.Poetry_core.Types.rhyme_data_file) : Yojson.Safe.t
    =
  let rhyme_groups_json =
    List.map
      (fun rhyme_group ->
        `Assoc
          [
            ( "name",
              `String
                (match rhyme_group with
                | Yyocamlc_lib.Poetry_core.Types.AnRhyme -> "安韵"
                | Yyocamlc_lib.Poetry_core.Types.TianRhyme -> "天韵"
                | Yyocamlc_lib.Poetry_core.Types.QuRhyme -> "去韵"
                | _ -> "其他韵") );
            ("category", `String "平水韵");
            ("characters", `List []);
          ])
      rhyme_data.rhyme_groups
  in

  let metadata_json =
    [
      ("version", `String rhyme_data.version);
      ("description", `String rhyme_data.description);
      ("last_updated", `String rhyme_data.last_updated);
    ]
  in

  `Assoc [ ("rhyme_groups", `List rhyme_groups_json); ("metadata", `Assoc metadata_json) ]

(** 解析JSON数据为韵律数据格式 *)
let parse_rhyme_json_data json_data =
  let json_list = Yojson.Safe.Util.to_list json_data in
  List.map
    (fun json ->
      let char = Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "char" json) in
      let category =
        match Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "category" json) with
        | "平声" -> Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng
        | "仄声" -> Yyocamlc_lib.Poetry_core.Poetry_types.ZeSheng
        | "上声" -> Yyocamlc_lib.Poetry_core.Poetry_types.ShangSheng
        | "去声" -> Yyocamlc_lib.Poetry_core.Poetry_types.QuSheng
        | "入声" -> Yyocamlc_lib.Poetry_core.Poetry_types.RuSheng
        | _ -> Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng
      in
      let group =
        match Yojson.Safe.Util.to_string (Yojson.Safe.Util.member "group" json) with
        | "安韵" -> Yyocamlc_lib.Poetry_core.Poetry_types.AnRhyme
        | "思韵" -> Yyocamlc_lib.Poetry_core.Poetry_types.SiRhyme
        | "天韵" -> Yyocamlc_lib.Poetry_core.Poetry_types.TianRhyme
        | "王韵" -> Yyocamlc_lib.Poetry_core.Poetry_types.WangRhyme
        | "曲韵" -> Yyocamlc_lib.Poetry_core.Poetry_types.QuRhyme
        | "玉韵" -> Yyocamlc_lib.Poetry_core.Poetry_types.YuRhyme
        | "华韵" -> Yyocamlc_lib.Poetry_core.Poetry_types.HuaRhyme
        | "风韵" -> Yyocamlc_lib.Poetry_core.Poetry_types.FengRhyme
        | "月韵" -> Yyocamlc_lib.Poetry_core.Poetry_types.YueRhyme
        | "江韵" -> Yyocamlc_lib.Poetry_core.Poetry_types.JiangRhyme
        | "会韵" -> Yyocamlc_lib.Poetry_core.Poetry_types.HuiRhyme
        | _ -> Yyocamlc_lib.Poetry_core.Poetry_types.UnknownRhyme
      in
      (char, category, group))
    json_list

(** {1 核心数据加载函数} *)

let load_data ?(config = default_config) data_type =
  global_config := config;
  let start_time = Sys.time () in
  try
    (* 检查缓存 *)
    if config.enable_cache && Hashtbl.mem consolidated_cache data_type then (
      let cached_data = Hashtbl.find consolidated_cache data_type in
      let load_time = Sys.time () -. start_time in
      update_performance_stats data_type load_time;
      cached_data)
    else
      (* 根据数据类型选择合适的加载策略 *)
      let loaded_data =
        match data_type with
        | RhymeData _ ->
            let file_path = get_data_file_path data_type in
            let rhyme_data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile file_path)
                Poetry_data_loaders.Unified_loader.RhymeData ()
            in
            let parsed_data = Yyocamlc_lib.Poetry_core.Parser.parse_rhyme_json rhyme_data in
            rhyme_data_to_json parsed_data
        | ToneData _ ->
            let file_path = get_data_file_path data_type in
            let rhyme_data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile file_path)
                Poetry_data_loaders.Unified_loader.ToneData ()
            in
            let parsed_data = Yyocamlc_lib.Poetry_core.Parser.parse_rhyme_json rhyme_data in
            rhyme_data_to_json parsed_data
        | PoetryData _ ->
            let file_path = get_data_file_path data_type in
            let rhyme_data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile file_path)
                Poetry_data_loaders.Unified_loader.PoetryData ()
            in
            let parsed_data = Yyocamlc_lib.Poetry_core.Parser.parse_rhyme_json rhyme_data in
            rhyme_data_to_json parsed_data
        | WordClassData _ ->
            let file_path = get_data_file_path data_type in
            let rhyme_data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile file_path)
                Poetry_data_loaders.Unified_loader.WordClassData ()
            in
            let parsed_data = Yyocamlc_lib.Poetry_core.Parser.parse_rhyme_json rhyme_data in
            rhyme_data_to_json parsed_data
        | ExternalizedData (CustomJsonData path) ->
            let data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile path)
                (Poetry_data_loaders.Unified_loader.CustomData "custom_json") ()
            in
            Yojson.Safe.from_string data
        | ExternalizedData (FileSystemData path) ->
            let data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile path)
                (Poetry_data_loaders.Unified_loader.CustomData "filesystem") ()
            in
            Yojson.Safe.from_string data
        | ArtisticData ->
            let file_path = get_data_file_path data_type in
            let rhyme_data =
              Poetry_data_loaders.Unified_loader.load_data
                (Poetry_data_loaders.Unified_loader.JsonFile file_path)
                Poetry_data_loaders.Unified_loader.ArtisticData ()
            in
            let parsed_data = Yyocamlc_lib.Poetry_core.Parser.parse_rhyme_json rhyme_data in
            rhyme_data_to_json parsed_data
      in

      (* 缓存加载的数据 *)
      if config.enable_cache then Hashtbl.replace consolidated_cache data_type loaded_data;

      let load_time = Sys.time () -. start_time in
      update_performance_stats data_type load_time;
      loaded_data
  with
  | Poetry_data_loaders.Unified_loader.UnifiedLoadError err ->
      let error_msg = Poetry_data_loaders.Unified_loader.format_error err in
      raise (ConsolidatedLoadError (ConsolidatedLoadError error_msg))
  | e ->
      let error_msg = Printexc.to_string e in
      raise (ConsolidatedLoadError (CompatibilityError error_msg))

(** {1 韵律数据接口实现} *)

let load_rhyme_data_with_fallback data_type =
  try
    let json_data = load_data data_type in
    parse_rhyme_json_data json_data
  with
  | ConsolidatedLoadError _ as e -> raise e
  | e when !fallback_mode ->
      Printf.printf "警告: %s数据加载失败，使用默认数据: %s\n" (data_type_to_string data_type)
        (Printexc.to_string e);
      [
        ( "默认",
          Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng,
          Yyocamlc_lib.Poetry_core.Poetry_types.AnRhyme );
      ]
  | e ->
      let type_name = data_type_to_string data_type in
      raise (ConsolidatedLoadError (RhymeLoadError (type_name ^ "加载失败", Printexc.to_string e)))

let load_ping_sheng_rhymes () = load_rhyme_data_with_fallback (RhymeData PingShengRhymes)
let load_ze_sheng_rhymes () = load_rhyme_data_with_fallback (RhymeData ZeShengRhymes)

let load_complete_rhyme_database () =
  let ping_sheng = load_ping_sheng_rhymes () in
  let ze_sheng = load_ze_sheng_rhymes () in
  ping_sheng @ ze_sheng

(** {1 声调数据接口实现} *)

let load_tone_chars data_type =
  try
    let json_data = load_data data_type in
    Yojson.Safe.Util.to_list json_data |> List.map Yojson.Safe.Util.to_string
  with
  | ConsolidatedLoadError _ as e -> raise e
  | e when !fallback_mode ->
      let tone_name = data_type_to_string data_type in
      Printf.printf "警告: %s数据加载失败，使用默认数据: %s\n" tone_name (Printexc.to_string e);
      [ "默认" ]
  | e ->
      let tone_name = data_type_to_string data_type in
      raise (ConsolidatedLoadError (ToneLoadError (tone_name ^ "加载失败", Printexc.to_string e)))

let get_ping_sheng_chars () = load_tone_chars (ToneData PingSheng)
let get_shang_sheng_chars () = load_tone_chars (ToneData ShangSheng)
let get_qu_sheng_chars () = load_tone_chars (ToneData QuSheng)
let get_ru_sheng_chars () = load_tone_chars (ToneData RuSheng)

let get_all_tone_data () =
  let ping = get_ping_sheng_chars () in
  let shang = get_shang_sheng_chars () in
  let qu = get_qu_sheng_chars () in
  let ru = get_ru_sheng_chars () in
  (ping, shang, qu, ru)

(** {1 词类数据接口实现} *)

let get_nature_nouns () = load_tone_chars (WordClassData NatureNouns)
let get_geography_politics_nouns () = load_tone_chars (WordClassData GeographyPoliticsNouns)
let get_person_relation_nouns () = load_tone_chars (WordClassData PersonRelationNouns)
let get_social_status_nouns () = load_tone_chars (WordClassData SocialStatusNouns)
let get_tools_objects_nouns () = load_tone_chars (WordClassData ToolsObjectsNouns)
let get_building_place_nouns () = load_tone_chars (WordClassData BuildingPlaceNouns)

type all_word_class_data = {
  nature_nouns : string list;
  geography_politics_nouns : string list;
  person_relation_nouns : string list;
  social_status_nouns : string list;
  tools_objects_nouns : string list;
  building_place_nouns : string list;
  ping_sheng : string list;
  shang_sheng : string list;
  qu_sheng : string list;
  ru_sheng : string list;
}

let load_all_word_class_data () =
  {
    nature_nouns = get_nature_nouns ();
    geography_politics_nouns = get_geography_politics_nouns ();
    person_relation_nouns = get_person_relation_nouns ();
    social_status_nouns = get_social_status_nouns ();
    tools_objects_nouns = get_tools_objects_nouns ();
    building_place_nouns = get_building_place_nouns ();
    ping_sheng = get_ping_sheng_chars ();
    shang_sheng = get_shang_sheng_chars ();
    qu_sheng = get_qu_sheng_chars ();
    ru_sheng = get_ru_sheng_chars ();
  }

(** {1 诗词数据接口实现} *)

let get_unified_database () = load_complete_rhyme_database ()

let is_char_in_database char =
  let database = get_unified_database () in
  List.exists (fun (c, _, _) -> c = char) database

let get_char_rhyme_info char =
  let database = get_unified_database () in
  List.find_opt (fun (c, _, _) -> c = char) database

(** {1 缓存管理} *)

let warm_cache data_types =
  List.iter
    (fun data_type ->
      try
        let _ = load_data data_type in
        Printf.printf "已预热缓存: %s\n" (data_type_to_string data_type)
      with e ->
        Printf.printf "缓存预热失败 %s: %s\n" (data_type_to_string data_type) (Printexc.to_string e))
    data_types

let clear_cache () =
  Hashtbl.clear consolidated_cache;
  Hashtbl.clear performance_stats;
  Poetry_data_loaders.Unified_loader.clear_cache ();
  Printf.printf "整合模块缓存已清理\n"

let get_cache_stats () =
  let all_types =
    [
      RhymeData PingShengRhymes;
      RhymeData ZeShengRhymes;
      ToneData PingSheng;
      ToneData ShangSheng;
      ToneData QuSheng;
      ToneData RuSheng;
      PoetryData UnifiedDatabase;
      WordClassData AllWordClassData;
      ArtisticData;
    ]
  in
  List.map
    (fun data_type ->
      let is_cached = Hashtbl.mem consolidated_cache data_type in
      let cache_size = if is_cached then 1 else 0 in
      (data_type, is_cached, cache_size))
    all_types

let get_cache_info () =
  let enabled = !global_config.enable_cache in
  let count = Hashtbl.length consolidated_cache in
  (enabled, count)

(** {1 批量操作和性能优化} *)

let load_all_data_types () =
  let all_types =
    [
      RhymeData PingShengRhymes;
      RhymeData ZeShengRhymes;
      RhymeData CompleteRhymeDatabase;
      ToneData PingSheng;
      ToneData ShangSheng;
      ToneData QuSheng;
      ToneData RuSheng;
      ToneData AllToneData;
      PoetryData UnifiedDatabase;
      PoetryData DataSourceRegistry;
      PoetryData CacheManagement;
      WordClassData AllWordClassData;
      ArtisticData;
    ]
  in
  List.iter
    (fun data_type ->
      try
        let _ = load_data data_type in
        Printf.printf "已预加载: %s\n" (data_type_to_string data_type)
      with e ->
        Printf.printf "预加载失败 %s: %s\n" (data_type_to_string data_type) (Printexc.to_string e))
    all_types

let get_comprehensive_stats () =
  Hashtbl.fold
    (fun data_type (total_time, count) acc ->
      let _avg_time = if count > 0 then total_time /. float_of_int count else 0.0 in
      let hit_rate = if Hashtbl.mem consolidated_cache data_type then 1.0 else 0.0 in
      let type_name = data_type_to_string data_type in
      (type_name, count, hit_rate) :: acc)
    performance_stats []

let validate_all_data_integrity () =
  let errors = ref [] in
  let valid = ref true in

  (* 检查韵律数据完整性 *)
  (try
     let _ = load_complete_rhyme_database () in
     Printf.printf "韵律数据完整性检查通过\n"
   with e ->
     errors := ("韵律数据完整性检查失败: " ^ Printexc.to_string e) :: !errors;
     valid := false);

  (* 检查声调数据完整性 *)
  (try
     let _ = get_all_tone_data () in
     Printf.printf "声调数据完整性检查通过\n"
   with e ->
     errors := ("声调数据完整性检查失败: " ^ Printexc.to_string e) :: !errors;
     valid := false);

  (* 检查词类数据完整性 *)
  (try
     let _ = load_all_word_class_data () in
     Printf.printf "词类数据完整性检查通过\n"
   with e ->
     errors := ("词类数据完整性检查失败: " ^ Printexc.to_string e) :: !errors;
     valid := false);

  (!valid, !errors)

(** {1 性能监控} *)

let get_load_performance_metrics () =
  Hashtbl.fold
    (fun data_type (total_time, count) acc ->
      let avg_time_ms = if count > 0 then total_time /. float_of_int count *. 1000.0 else 0.0 in
      (data_type, avg_time_ms, count) :: acc)
    performance_stats []

let enable_performance_tracking enabled =
  performance_tracking := enabled;
  Printf.printf "性能跟踪已%s\n" (if enabled then "启用" else "禁用")

(** {1 降级和容错} *)

let safe_load_with_fallback data_type = try Some (load_data data_type) with _ -> None

let enable_fallback_mode enabled =
  fallback_mode := enabled;
  Printf.printf "降级模式已%s\n" (if enabled then "启用" else "禁用")

(** {1 调试和监控} *)

let print_status () =
  Printf.printf "\n=== 整合数据加载器状态 ===\n";
  Printf.printf "缓存项目数: %d\n" (Hashtbl.length consolidated_cache);
  Printf.printf "性能统计项目数: %d\n" (Hashtbl.length performance_stats);
  Printf.printf "降级模式: %s\n" (if !fallback_mode then "启用" else "禁用");
  Printf.printf "性能跟踪: %s\n" (if !performance_tracking then "启用" else "禁用");

  Printf.printf "\n--- 缓存状态 ---\n";
  Hashtbl.iter
    (fun data_type _ -> Printf.printf "已缓存: %s\n" (data_type_to_string data_type))
    consolidated_cache;

  Printf.printf "\n--- 性能统计 ---\n";
  Hashtbl.iter
    (fun data_type (total_time, count) ->
      let avg_time = if count > 0 then total_time /. float_of_int count else 0.0 in
      Printf.printf "%s: 调用%d次, 平均%.3fms\n" (data_type_to_string data_type) count
        (avg_time *. 1000.0))
    performance_stats;
  Printf.printf "=========================\n\n"

(** {1 向后兼容性接口} *)

(* 兼容unified_data_loader_comprehensive *)
let load_ping_sheng_rhymes_comprehensive = load_ping_sheng_rhymes
let load_ze_sheng_rhymes_comprehensive = load_ze_sheng_rhymes
let load_complete_rhyme_database_comprehensive = load_complete_rhyme_database
let get_ping_sheng_chars_comprehensive = get_ping_sheng_chars
let get_shang_sheng_chars_comprehensive = get_shang_sheng_chars
let get_qu_sheng_chars_comprehensive = get_qu_sheng_chars
let get_ru_sheng_chars_comprehensive = get_ru_sheng_chars
let get_all_tone_data_comprehensive = get_all_tone_data
let get_unified_database_comprehensive = get_unified_database
let is_char_in_database_comprehensive = is_char_in_database
let get_char_rhyme_info_comprehensive = get_char_rhyme_info

(* 兼容unified_data_loader_extended *)
let validate_data_integrity () =
  let valid, _ = validate_all_data_integrity () in
  valid

let warm_word_class_cache () = warm_cache [ WordClassData AllWordClassData ]

let get_word_class_stats () =
  [
    ("自然名词", List.length (get_nature_nouns ()));
    ("地理政治名词", List.length (get_geography_politics_nouns ()));
    ("人物关系名词", List.length (get_person_relation_nouns ()));
    ("社会地位名词", List.length (get_social_status_nouns ()));
    ("工具物品名词", List.length (get_tools_objects_nouns ()));
    ("建筑场所名词", List.length (get_building_place_nouns ()));
  ]

(* 兼容externalized_data_loader *)
module ExternalizedCompat = struct
  type externalized_data_error =
    | FileNotFound of string
    | ParseError of string * string
    | ValidationError of string

  exception ExternalizedDataError of externalized_data_error

  let format_error = function
    | FileNotFound path -> Printf.sprintf "文件未找到: %s" path
    | ParseError (msg, detail) -> Printf.sprintf "解析错误: %s (详细: %s)" msg detail
    | ValidationError msg -> Printf.sprintf "验证错误: %s" msg
end
